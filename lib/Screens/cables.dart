
import 'dart:convert';

import 'package:coupolerseditor/Helpers/strings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/cable.dart';
import '../Models/cableend.dart';
import '../Models/coupler.dart';
import '../Models/node.dart';

class CableScreen extends StatefulWidget {
  const CableScreen({Key? key, required this.lang, required this.cable, required this.isFromServer}) : super(key: key);
  final String lang;
  final Cable cable;
  final bool isFromServer;

  @override
  State<CableScreen> createState() => _CableScreenState();
}

class _CableScreenState extends State<CableScreen> {

  bool isViewOnMap = false;
  List<CableEnd> ends = [];
  List<Node> nodes = [];
  List<Mufta> couplers = [];

  @override
  void initState() {
    super.initState();
    _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cables'),
        actions: <Widget>[
          IconButton(
            icon: isViewOnMap ? const Icon(Icons.list_outlined) : const Icon(Icons.map_outlined),
            onPressed: () {
              setState(() {
                isViewOnMap = !isViewOnMap;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(),
            TranslateText('New cable:', language: widget.lang,),
            Column(
              children: [
                
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: ends.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(ends[index].direction),
                      leading: Text('side ${index + 1}:'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            ends.removeAt(index);
                            _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer, enableFilter: ends.length == 1);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            ends.length == 2 ? TextButton.icon(onPressed: () {
              Navigator.of(context).pop(Cable(ends: ends));
            }, icon: const Icon(Icons.save_outlined), label: TranslateText('Save', language: widget.lang,)) : Container(),
            isViewOnMap ? _buildMap() : _buildList(),
            const Divider(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildList() {
    return Column(
      children: [
        couplers.isNotEmpty ? TranslateText('Cable ends in couplers:', language: widget.lang) : Container(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: couplers.length,
          itemBuilder: (context, index) {
            return couplers[index].cableEnds.isNotEmpty ? ListTile(
              title: Text(couplers[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var end in couplers[index].cableEnds)
                    TextButton.icon(label: Text('${end.direction} (${end.colorScheme}: ${end.fibersNumber})'), icon: const Icon(Icons.local_hospital_outlined), onPressed: () {setState(() {
                      if (ends.length < 2) ends.add(end);
                      _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer, enableFilter: ends.length == 1);
                    });})
                ]
              ),
            ) : Container();
          },
        ),
        const Divider(),
        nodes.isNotEmpty ? TranslateText('Cable ends in nodes:', language: widget.lang) : Container(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            return nodes[index].cableEnds.isNotEmpty ? ListTile(
              title: Text(nodes[index].address),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var end in nodes[index].cableEnds)
                    TextButton.icon(label: Text('${end.direction} (${end.colorScheme}: ${end.fibersNumber})'), icon: const Icon(Icons.local_hospital_outlined), onPressed: () {setState(() {
                      if (ends.length < 2) ends.add(end);
                      _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer, enableFilter: ends.length == 1);
                    });})
                ]
              ),
            ) : Container();
          },
        ),
      ],
    );
  }
  
  Widget _buildMap() {
    return Container();
  }
  
  Future<void> _loadCouplersAndNodes({bool isSourceLocal = true, bool enableFilter = false}) async {
    if (ends.length == 2) {
      couplers = [];
      nodes = [];
      return;
    }
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> couplersJsonStrings = prefs.getKeys().where((element) => element.startsWith('coupler:')).toSet();
      print(couplersJsonStrings);
      couplers = couplersJsonStrings.map((element) => Mufta.fromJson(jsonDecode(prefs.getString(element) ?? ''))).toList();
    } else {
      couplers = [];
    }
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> nodesJsonStrings = prefs.getKeys().where((element) => element.startsWith('node:')).toSet();
      nodes = nodesJsonStrings.map((element) => Node.fromJson(jsonDecode(prefs.getString(element) ?? ''))).toList();
    } else {
      nodes = [];
    }
    if (enableFilter) {
      print('filter couplers and nodes');
      int fNum = ends.first.fibersNumber;
      String color = ends.first.colorScheme!;
      //print('first side - fNum: $fNum, color: $color');
      for (var coupler in couplers) {
        //print('for coupler ${coupler.name}:');
        List<CableEnd> toRemove = [];
        for (var end in coupler.cableEnds) {
          //print('for end ${end.direction} ${end.fibersNumber} ${end.colorScheme}:');
          if (end.fibersNumber != fNum || end.colorScheme != color || end.direction == ends.first.direction) {
            toRemove.add(end);
            //print('remove');
          }
        }
        for (var end in toRemove) {
          coupler.cableEnds.remove(end);
        }
      }
      for (var node in nodes) {
        List<CableEnd> toRemove = [];
        for (var end in node.cableEnds) {
          if (end.fibersNumber != fNum || end.colorScheme != color || end.direction == ends.first.direction) {
            toRemove.add(end);
          }
        }
        for (var end in toRemove) {
          node.cableEnds.remove(end);
        }
      }
    }
    setState(() {});
  }
}