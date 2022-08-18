import 'dart:convert';

import 'package:coupolerseditor/Models/node.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helpers/strings.dart';
import 'nodes.dart';

class NodesList extends StatefulWidget {
  const NodesList(
      {Key? key,
      required this.lang,
      required this.nodesListURL,
      required this.isFromBilling})
      : super(key: key);
  final String lang;
  final String nodesListURL;
  final bool isFromBilling;

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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NodesScreen(
                            node: Node.fromJson(jsonDecode(
                                nodesJsonStrings[selectedNodeIndex])),
                            lang: widget.lang,
                          ))).then((value) => setState(() {widget.isFromBilling ? loadListFromBilling() : loadListFromDevice();}));
                },
              )
            : Container(),
      ]),
      body: Center(
        child: nodesJsonStrings.isNotEmpty
            ? ListView.builder(
                itemCount: nodesJsonStrings.length,
                itemBuilder: (ctx, index) {
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
                                  removeNode(1);
                                  setState(() {
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

  loadListFromBilling() {}

  loadListFromDevice() async {
    print('loadListFromDevice');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> codedNodesListKeys = sharedPreferences
        .getKeys()
        .where((element) => element.startsWith('node: '))
        .toList();
    print('codedNodessListKeys: $codedNodesListKeys');
    setState(() {
      nodesJsonStrings = codedNodesListKeys
          .map(
              (codedNodeKey) => sharedPreferences.getString(codedNodeKey) ?? '')
          .toList();
    });
  }

  void removeNode(coupler) {}
}
