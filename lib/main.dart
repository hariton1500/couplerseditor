//import 'package:couplers/Screens/mufta2.dart';
import 'package:flutter/material.dart';

import 'Helpers/strings.dart';
import 'Models/mainmodels.dart';
import 'Screens/mufta.dart';

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
                  TextButton.icon(
                      onPressed: () {
                        setState(() {
                          loadNames().then((value) => localStored = value);
                          isShowImport = !isShowImport;
                        });
                      },
                      icon: const Icon(Icons.import_export_outlined),
                      label:
                          TranslateText('Import', language: settings.language)),
                  if (isShowImport) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TranslateText('From Local:',
                                  language: settings.language),
                              if (localStored.isNotEmpty) ...[
                                DropdownButton<String>(
                                    value: selectedName == ''
                                        ? null
                                        : selectedName,
                                    items: localStored
                                        .map((e) => DropdownMenuItem<String>(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (String? variant) {
                                      //print('selection - $variant');
                                      setState(() {
                                        selectedName = variant!;
                                      });
                                    }),
                                OutlinedButton(
                                    onPressed: () {
                                      //print('selected:');
                                      //print(selectedName);
                                      loadMuftaJson(selectedName).then((value) {
                                        mufta = muftaFromJson(value);
                                        setState(() {
                                          isShowImport = false;
                                          isShowMuftu = true;
                                        });
                                      });
                                    },
                                    child: TranslateText('Import',
                                        language: settings.language))
                              ] else
                                TranslateText('nothing stored',
                                    language: settings.language),
                            ],
                          ),
                          TranslateText('From REST:',
                              language: settings.language)
                        ],
                      ),
                    ),
                  ],
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
