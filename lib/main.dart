// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'Helpers/strings.dart';
import 'Models/fosc.dart';
import 'Models/node.dart';
import 'Models/settings.dart';
import 'Screens/cables.dart';
import 'Screens/fosc_page.dart';
import 'Screens/foscslist.dart';
import 'Screens/node_page.dart';
import 'Screens/nodeslist.dart';
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
      home: const MyHomePage(title: 'FOSCs, Nodes & Cables keeper'),
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

  Node node = Node(address: 'no address');

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
                        callback: () => setState(() {}),
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
                          lang: settings.language,
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
                                    callback: () => setState(() {}),
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
                          lang: settings.language,
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
                          node: Node(address: 'no Address'),
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
