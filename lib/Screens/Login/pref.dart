import 'package:saregama/CustomWidgets/gradient_containers.dart';
import 'package:saregama/CustomWidgets/snackbar.dart';
// import 'package:saregama/Helpers/countrycodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class PrefScreen extends StatefulWidget {
  const PrefScreen({super.key});

  @override
  _PrefScreenState createState() => _PrefScreenState();
}

class _PrefScreenState extends State<PrefScreen> {
  List<String> languages = ['English'];
  List<bool> isSelected = [true, false];
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList() as List;
  String region =
      Hive.box('settings').get('region', defaultValue: 'India') as String;

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const GradientContainer(
                child: null,
                opacity: true,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/');
                        },
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text:
                                          '${AppLocalizations.of(context)!.welcome}\n',
                                      style: TextStyle(
                                        fontSize: 65,
                                        height: 1.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .aboard,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 75,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '!\n',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 70,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .prefReq,
                                          style: const TextStyle(
                                            height: 1.5,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ListTile(
                                  title: Text(
                                    AppLocalizations.of(context)!.langQue,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 10,
                                      right: 10,
                                    ),
                                    height: 57.0,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        preferredLanguage.isEmpty
                                            ? 'None'
                                            : preferredLanguage.join(', '),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    showModalBottomSheet(
                                      isDismissible: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) {
                                        final List checked =
                                            List.from(preferredLanguage);
                                        return StatefulBuilder(
                                          builder: (
                                            BuildContext context,
                                            StateSetter setStt,
                                          ) {
                                            return BottomGradientContainer(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: ListView.builder(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                        0,
                                                        10,
                                                        0,
                                                        10,
                                                      ),
                                                      itemCount:
                                                          languages.length,
                                                      itemBuilder:
                                                          (context, idx) {
                                                        return CheckboxListTile(
                                                          activeColor: Theme.of(
                                                            context,
                                                          )
                                                              .colorScheme
                                                              .secondary,
                                                          value:
                                                              checked.contains(
                                                            languages[idx],
                                                          ),
                                                          title: Text(
                                                            languages[idx],
                                                          ),
                                                          onChanged:
                                                              (bool? value) {
                                                            value!
                                                                ? checked.add(
                                                                    languages[
                                                                        idx],
                                                                  )
                                                                : checked
                                                                    .remove(
                                                                    languages[
                                                                        idx],
                                                                  );
                                                            setStt(() {});
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        style: TextButton.styleFrom(
                                                            // foregroundColor:
                                                            //     Theme.of(context)
                                                            //         .colorScheme
                                                            //         .secondary,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .cancel,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        style: TextButton.styleFrom(
                                                            // foregroundColor:
                                                            //     Theme.of(context)
                                                            //         .colorScheme
                                                            //         .secondary,
                                                            ),
                                                        onPressed: () {
                                                          setState(() {
                                                            preferredLanguage =
                                                                checked;
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Hive.box('settings')
                                                                .put(
                                                              'preferredLanguage',
                                                              checked,
                                                            );
                                                          });
                                                          if (preferredLanguage
                                                              .isEmpty) {
                                                            ShowSnackBar()
                                                                .showSnackBar(
                                                              context,
                                                              AppLocalizations
                                                                      .of(
                                                                context,
                                                              )!
                                                                  .noLangSelected,
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .ok,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.popAndPushNamed(context, '/');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      // color: Theme.of(context).accentColor,
                                      color: Colors.purple[900],
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.finish,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
