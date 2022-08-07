//import 'package:couplers/Screens/mufta2.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'Helpers/strings.dart';
import 'Models/mainmodels.dart';
import 'Screens/mufta.dart';
import 'Screens/couplerslist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, canvasColor: Colors.white),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isShowMuftu = false, isShowSetup = false, isShowImport = false;
  Mufta mufta = Mufta(cables: [], connections: [], name: '');
  Settings settings = Settings();
  List<String> localStored = [];
  String selectedName = '';

  @override
  void initState() {
    loadNames().then((value) {
      setState(() {
        localStored = value;
      });
    });
    settings.loadSettings().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: isShowMuftu
          ? SafeArea(
              child: MuftaScreen(
                lang: settings.language,
                mufta: mufta,
                callback: () {
                  //print('recieved callback');
                  setState(() {
                    isShowMuftu = false;
                  });
                },
              ),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isShowMuftu = true;
                      });
                    },
                    icon: const Icon(Icons.create_outlined),
                    label: TranslateText(
                      'Create/edit coupler',
                      language: settings.language,
                    ),
                  ),
                  Wrap(
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute<String>(
                              builder: (context) => CouplersList(
                                isFromBilling: true,
                                lang: settings.language,
                                couplersListURL: settings.couplersListUrl,
                              ),
                            ))
                                .then((value) {
                              setState(() {
                                if (value != null) {
                                  mufta = Mufta.fromJson(jsonDecode(value));
                                }
                              });
                            });
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: TranslateText(
                              'Load from billing software (json)',
                              language: settings.language)),
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute<String>(
                              builder: (context) => CouplersList(
                                isFromBilling: false,
                                lang: settings.language,
                                couplersListURL: settings.couplersListUrl,
                              ),
                            ))
                                .then((value) {
                              setState(() {
                                if (value != null) {
                                  mufta = Mufta.fromJson(jsonDecode(value));
                                  isShowMuftu = true;
                                }
                              });
                            });
                          },
                          icon: const Icon(Icons.download_for_offline_rounded),
                          label: TranslateText('Load from device',
                              language: settings.language)),
                    ],
                  ),
                  TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isShowSetup = !isShowSetup;
                        });
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: TranslateText('Settings',
                          language: settings.language)),
                  if (isShowSetup) ...[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          //Settings
                          TranslateText('Language:',
                              language: settings.language),
                          Row(
                            children: [
                              Radio<String>(
                                  value: 'en',
                                  groupValue: settings.language,
                                  onChanged: (lang) => setState(
                                      () => settings.language = lang!)),
                              const Text('English'),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                  value: 'ru',
                                  groupValue: settings.language,
                                  onChanged: (lang) => setState(
                                      () => settings.language = lang!)),
                              const Text('Русский'),
                            ],
                          ),
                          TranslateText('Load list of couplers URL:',
                              language: settings.language),
                          TextFormField(
                            initialValue: settings.couplersListUrl,
                            onChanged: (value) =>
                                settings.couplersListUrl = value,
                          ),
                          TranslateText('Load coupler URL:',
                              language: settings.language),
                          TextFormField(
                            initialValue: settings.couplerUrl,
                            onChanged: (value) => settings.couplerUrl = value,
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isShowSetup = false;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_upward_outlined),
                                  label: TranslateText('Hide',
                                      language: settings.language)),
                              TextButton.icon(
                                  onPressed: () => settings.saveSettings(),
                                  icon: const Icon(Icons.save_outlined),
                                  label: TranslateText('Save to device',
                                      language: settings.language)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
    );
  }
}
