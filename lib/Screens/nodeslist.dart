import 'dart:convert';

import 'package:coupolerseditor/Models/node.dart';
import 'package:coupolerseditor/services/jsonbin_io.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helpers/strings.dart';
import '../Models/settings.dart';
import 'node_page.dart';

class NodesList extends StatefulWidget {
  const NodesList(
      {Key? key,
      required this.lang,
      required this.nodesListURL,
      required this.isFromBilling,
      required this.settings})
      : super(key: key);
  final String lang;
  final String nodesListURL;
  final bool isFromBilling;
  final Settings settings;

  @override
  State<NodesList> createState() => _NodesListState();
}

class _NodesListState extends State<NodesList> {
  List<String> nodesJsonStrings = [];
  int selectedNodeIndex = -1;

  @override
  void initState() {
    print('isFromBilling: ${widget.isFromBilling}');
    widget.isFromBilling ? loadListFromBilling() : loadListFromDevice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nodes'), actions: [
        selectedNodeIndex >= 0
            ? IconButton(
                icon: const Icon(Icons.select_all_outlined),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => NodesScreen(
                                node: Node.fromJson(jsonDecode(
                                    nodesJsonStrings[selectedNodeIndex])),
                                //lang: widget.lang,
                                settings: widget.settings,
                              )))
                      .then((value) => setState(() {
                            nodesJsonStrings.clear();
                            widget.isFromBilling
                                ? loadListFromBilling()
                                : loadListFromDevice();
                          }));
                },
              )
            : Container(),
      ]),
      body: Center(
        child: nodesJsonStrings.isNotEmpty
            ? ListView.builder(
                itemCount: nodesJsonStrings.length,
                itemBuilder: (ctx, index) {
                  //print(nodesJsonStrings);
                  Map<String, dynamic> node =
                      jsonDecode(nodesJsonStrings[index]);
                  return ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: TranslateText(
                              'Delete node',
                              language: widget.lang,
                            ),
                            content: TranslateText(
                              'Are you sure you want to delete node?',
                              language: widget.lang,
                            ),
                            actions: [
                              TextButton(
                                child: TranslateText(
                                  'Cancel',
                                  language: widget.lang,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: TranslateText(
                                  'Delete',
                                  language: widget.lang,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    widget.isFromBilling
                                        ? removeFromServer(
                                            name: Node.fromJson(jsonDecode(
                                                    nodesJsonStrings[index]))
                                                .signature()
                                                .hashCode
                                                .toString())
                                        : removeNodeFromStore(
                                            nodesJsonStrings[index]);
                                    nodesJsonStrings.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    title: TextButton(
                      child: Text(
                        node['address'],
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedNodeIndex = index;
                        });
                      },
                    ),
                  );
                })
            : TranslateText('Nodes are loading...', language: widget.lang),
      ),
    );
  }

  loadListFromBilling() {
    JsonbinIO server = JsonbinIO(settings: widget.settings);
    server.loadBins().then((_) async {
      List<MapEntry<String, dynamic>> nodeBinsList =
          server.bins.entries.where((element) {
        Map<String, dynamic> data = (element.value is Map)
            ? element.value
            : {'id': element.value, 'type': 'unknown'};
        return data['type'] == 'node';
      }).toList();
      print('nodeBinsList = $nodeBinsList');
      for (var bin in nodeBinsList) {
        String data = await server.loadDataFromBin(binId: bin.value['id']);
        if (data != '') {
          setState(() {
            nodesJsonStrings.add(data);
          });
        }
      }
    });
  }

  loadListFromDevice() async {
    print('loadListFromDevice');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> codedNodesListKeys = sharedPreferences
        .getKeys()
        .where((element) => element.startsWith('node: '))
        .toList();
    print('codedNodesListKeys: $codedNodesListKeys');
    setState(() {
      nodesJsonStrings = codedNodesListKeys
          .map(
              (codedNodeKey) => sharedPreferences.getString(codedNodeKey) ?? '')
          .toList();
    });
  }

  void removeNodeFromStore(String nodesJsonString) async {
    print('removing: $nodesJsonString');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String key =
        'node: ${(json.decode(nodesJsonString) as Map<String, dynamic>)['address']}';
    sharedPreferences.remove(key);
  }

  void removeFromServer({required String name}) async {
    print('removing: node with hash = $name');
    JsonbinIO server = JsonbinIO(settings: widget.settings);
    server.saveBin(id: '', hash: name, type: 'deleted by at ${DateTime.now()}');
  }
}
