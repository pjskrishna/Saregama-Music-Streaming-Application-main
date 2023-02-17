import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:saregama/Helpers/config.dart';
import 'package:saregama/Helpers/handle_native.dart';
import 'package:saregama/Helpers/route_handler.dart';
import 'package:saregama/Screens/About/about.dart';
import 'package:saregama/Screens/Home/home.dart';
import 'package:saregama/Screens/Library/nowplaying.dart';
import 'package:saregama/Screens/Library/playlists.dart';
import 'package:saregama/Screens/Library/recent.dart';
import 'package:saregama/Screens/Login/auth.dart';
import 'package:saregama/Screens/Login/pref.dart';
import 'package:saregama/Screens/Player/audioplayer.dart';
import 'package:saregama/Screens/Settings/setting.dart';
import 'package:saregama/Services/audio_service.dart';
import 'package:saregama/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/*
* This saregama app is developed by Pankil and Krishna
*/

Future<void> main() async {
  /// ensureInitialized() :-
  /// Returns an instance of the binding that implements WidgetsBinding.
  /// If no binding has yet been initialized, the WidgetsFlutterBinding class is used to create and initialize one.
  /// You only need to call this method if you need the binding to be initialized before calling runApp.
  /// In the flutter_test framework, testWidgets initializes the binding instance to a TestWidgetsFlutterBinding, not a WidgetsFlutterBinding.
  /// See TestWidgetsFlutterBinding.ensureInitialized.

  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    /// This is the use of HIVE database from Spotify API supported
    /// It will help to store local sessions in the Storage...
    await Hive.initFlutter('saregama');
  } else {
    await Hive.initFlutter();
  }

  /// This are the various options which are available for the user

  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();
  runApp(MyApp());
}

/// setOptimalDisplayMode() :-
/// A Flutter plugin to set display mode in Android.
/// This library should be used as a temporary
/// until this API gets added to Flutter engine itself.
/// */

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;

  final List<DisplayMode> sameResolution = supported
      .where(
        (DisplayMode m) => m.width == active.width && m.height == active.height,
      )
      .toList()
    ..sort(
      (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
    );

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;

  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> startService() async {
  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.shadow.saregama.channel.audio',
      androidNotificationChannelName: 'saregama',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      notificationColor: Colors.grey[700],
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

/// openHiveBox() :-
/// All of your data is stored in boxes.
/// This is used to store data in the form of boxes.

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/saregama/$boxName.hive');
      lockFile = File('$dirPath/saregama/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

class MyApp extends StatefulWidget {
  @override

  /// The framework can call this method multiple times over the lifetime of a StatefulWidget.
  /// For example, if the widget is inserted into the tree in multiple locations,
  /// the framework will create a separate State object for each location.
  /// Similarly, if the widget is removed from the tree and later inserted into the tree again,
  /// the framework will call createState again to create a fresh State object,
  /// simplifying the lifecycle of State objects.
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  /// For the initial release ENGLISH will be the default selected language.
  Locale _locale = const Locale('en', '');
  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final String lang =
        Hive.box('settings').get('lang', defaultValue: 'English') as String;
    final Map<String, String> codes = {
      'English': 'en',
    };
    _locale = Locale(codes[lang]!);

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen(
      (String value) {
        handleSharedText(value, navigatorKey);
      },
      onError: (err) {
        // print("ERROR in getTextStream: $err");
      },
    );

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(
      (String? value) {
        if (value != null) handleSharedText(value, navigatorKey);
      },
    );
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget initialFuntion() {
    return Hive.box('settings').get('userId') != null
        ? HomePage()
        : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.themeMode == ThemeMode.dark
            ? Colors.black38
            : Colors.white,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'saregama',
      restorationScopeId: 'saregama',
      debugShowCheckedModeBanner: false,
      themeMode: AppTheme.themeMode,
      theme: AppTheme.lightTheme(
        context: context,
      ),
      darkTheme: AppTheme.darkTheme(
        context: context,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      routes: {
        '/': (context) => initialFuntion(),
        '/pref': (context) => const PrefScreen(),
        '/setting': (context) => const SettingPage(),
        '/about': (context) => AboutScreen(),
        '/playlists': (context) => PlaylistScreen(),
        '/nowplaying': (context) => NowPlaying(),
        '/recent': (context) => RecentlyPlayed(),
      },
      navigatorKey: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return HandleRoute.handleRoute(settings.name);
      },
    );
  }
}
