// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'Helpers/strings.dart';
import 'Models/fosc.dart';
import 'Models/node.dart';
import 'Models/settings.dart';
import 'Screens/Cables/cables.dart';
import 'Screens/Foscs/fosc_page.dart';
import 'Screens/Foscs/foscslist.dart';
import 'Screens/Nodes/node_page.dart';
import 'Screens/Nodes/nodeslist.dart';
import 'Screens/setup.dart';
import 'Screens/viewer.dart';

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
        theme: ThemeData(
            primarySwatch: Colors.blue,
            canvasColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.blue),
              actionsIconTheme: IconThemeData(color: Colors.blue),
            )),
        debugShowCheckedModeBanner: false,
        home: const StartScreen() //(title: 'FOSCs, Nodes & Cables keeper'),
        );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset('assets/images/fosc.png'),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset(
            'assets/images/node.png',
            //width: 100,
            //height: 100,
            fit: BoxFit.fitWidth,
          ),
        )
      ],
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
  Mufta mufta = Mufta(cableEnds: [], connections: [], name: '');
  Settings settings = Settings();
  List<String> localStored = [];
  String selectedName = '';

  Node node = Node(address: '');

  //Cable cable = Cable(ends: []);

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: ((context) => SetupScreen(
                              //lang: settings.language,
                              settings: settings,
                            ))))
                    .then((value) => setState(() {})),
                icon: const Icon(Icons.settings_outlined))
          ],
          title: TranslateText(
            widget.title,
            language: settings.language,
            color: Colors.blue,
            size: 16,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Center(
                child: TranslateText('FOSCs:',
                    language: settings.language,
                    size: 16,
                    color: Colors.black)),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MuftaScreen(
                        mufta: mufta,
                        //callback: () => setState(() {}),
                        settings: settings)));
                /*
                      setState(() {
                        isShowMuftu = true;
                      });*/
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
                    onPressed: () async {
                      await Navigator.of(context)
                          .push(MaterialPageRoute<String>(
                        builder: (context) => CouplersList(
                          isFromBilling: true,
                          settings: settings,
                        ),
                      ))
                          .then((value) {
                        setState(() {
                          if (value != null) {
                            mufta = Mufta.fromJson(jsonDecode(value));
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MuftaScreen(
                                    mufta: mufta,
                                    //callback: () => setState(() {}),
                                    settings: settings)));
                          }
                        });
                      });
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: TranslateText('Load from billing software (json)',
                        language: settings.language)),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute<String>(
                        builder: (context) => CouplersList(
                          isFromBilling: false,
                          settings: settings,
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
            //],
            const Divider(),
            Center(
                child: TranslateText('Nodes:',
                    language: settings.language,
                    size: 16,
                    color: Colors.black)),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NodesScreen(
                          node: Node(
                              address:
                                  (strings['Empty'] ?? {})[settings.language] ??
                                      ''),
                          //callback: () => setState(() {}),
                          //lang: settings.language, node: node,
                          settings: settings,
                        )));
              },
              icon: const Icon(Icons.create_outlined),
              label: TranslateText(
                'Create/edit node',
                language: settings.language,
              ),
            ),
            Wrap(
              children: [
                TextButton.icon(
                    onPressed: () async {
                      await Navigator.of(context)
                          .push(MaterialPageRoute<String>(
                        builder: (context) => NodesList(
                          settings: settings,
                          isFromBilling: true,
                          lang: settings.language,
                          nodesListURL: '${settings.baseUrl}/nodeslist',
                        ),
                      ))
                          .then((value) {
                        setState(() {
                          if (value != null) {
                            mufta = Mufta.fromJson(jsonDecode(value));
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NodesScreen(
                                      node: node,
                                      settings: settings,
                                      //callback: () => setState(() {}),
                                      //lang: settings.language
                                    )));
                          }
                        });
                      });
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: TranslateText('Load from billing software (json)',
                        language: settings.language)),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute<String>(
                        builder: (context) => NodesList(
                          settings: settings,
                          isFromBilling: false,
                          lang: settings.language,
                          nodesListURL: '${settings.baseUrl}/nodeslist',
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
            const Divider(),
            Center(
                child: TranslateText('Cables:',
                    language: settings.language,
                    size: 16,
                    color: Colors.black)),
            TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CableScreen(
                            isFromServer: true,
                            lang: settings.language,
                            settings: settings,
                          )));
                },
                icon: const Icon(Icons.create_outlined),
                label: TranslateText('Create/edit cable on billing (json)',
                    language: settings.language)),
            TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CableScreen(
                            isFromServer: false,
                            lang: settings.language,
                            settings: settings,
                          )));
                },
                icon: const Icon(Icons.create_outlined),
                label: TranslateText('Create/edit cable from Local device',
                    language: settings.language)),
            const Divider(),
            Center(
                child: TranslateText(
              'Viewer:',
              language: settings.language,
              size: 16,
              color: Colors.black,
            )),
            TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ViewerScreen(
                            settings: settings,
                            isFromServer: true,
                          )));
                },
                icon: const Icon(Icons.visibility_outlined),
                label: TranslateText('Viewer from Server',
                    language: settings.language)),
            TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ViewerScreen(
                            settings: settings,
                            isFromServer: false,
                          )));
                },
                icon: const Icon(Icons.visibility_outlined),
                label: TranslateText('Viewer from Local device',
                    language: settings.language)),
          ],
        ),
      ),
    );
  }
}
