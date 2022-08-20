
import 'dart:convert';

import 'package:coupolerseditor/Helpers/strings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/cable.dart';
import '../Models/cableend.dart';
import '../Models/coupler.dart';
import '../Models/node.dart';

class CableScreen extends StatefulWidget {
  const CableScreen({Key? key, required this.lang, required this.cable}) : super(key: key);
  final String lang;
  final Cable cable;

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
    _loadCouplersAndNodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cable'),
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
            ends.isNotEmpty ? Column(
              children: [
                TranslateText('Cable:', language: widget.lang,),
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
                            _loadCouplersAndNodes(enableFilter: ends.length == 1);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ) : Container(),
            isViewOnMap ? _buildMap() : _buildList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildList() {
    return Column(
      children: [
        couplers.isNotEmpty ? TranslateText('Couplers', language: widget.lang) : Container(),
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
                      _loadCouplersAndNodes(enableFilter: ends.length == 1);
                    });})
                ]
              ),
            ) : Container();
          },
        ),
        const Divider(),
        nodes.isNotEmpty ? TranslateText('Nodes', language: widget.lang) : Container(),
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
                      _loadCouplersAndNodes(enableFilter: ends.length == 1);
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
      int fNum = ends.first.fibersNumber;
      String color = ends.first.colorScheme!;
      for (var coupler in couplers) {
        List<CableEnd> toRemove = [];
        for (var end in coupler.cableEnds) {
          if (end.fibersNumber != fNum || end.colorScheme != color || end != ends.first) {
            toRemove.add(end);
            //coupler.cableEnds.remove(end);
          }
        }
        for (var end in toRemove) {
          coupler.cableEnds.remove(end);
        }
      }
      for (var node in nodes) {
        List<CableEnd> toRemove = [];
        for (var end in node.cableEnds) {
          if (end.fibersNumber != fNum || end.colorScheme != color || end != ends.first) {
            //node.cableEnds.remove(end);
            toRemove.add(end);
          }
        }
        for (var end in toRemove) {
          node.cableEnds.remove(end);
        }
      }
    }
    for (var coupler in couplers) {
      print(coupler.toString());
    }
    print(nodes);
    setState(() {});
  }
}