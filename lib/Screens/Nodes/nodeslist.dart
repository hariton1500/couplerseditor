import 'dart:convert';

import 'package:coupolerseditor/Helpers/map.dart';
import 'package:coupolerseditor/Models/node.dart';
//import 'package:coupolerseditor/services/jsonbin_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helpers/enums.dart';
import '../../Helpers/epsg3395.dart';
import '../../Helpers/strings.dart';
import '../../Models/settings.dart';
import '../../services/server.dart';
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
  bool isViewOnMap = false;

  final _mapController = MapController();

  MapSource mapSource = MapSource.yandexmap;

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
        IconButton(
            onPressed: () {
              setState(() {
                isViewOnMap = !isViewOnMap;
              });
            },
            icon: Icon(isViewOnMap ? Icons.list_rounded : Icons.map_rounded))
      ]),
      body: Center(
        child: isViewOnMap
            ? showMap()
            : nodesJsonStrings.isNotEmpty
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
                                                name: (json.decode(
                                                            nodesJsonStrings[index])
                                                        as Map<String,
                                                            dynamic>)['key'] ??
                                                    (json
                                                        .decode(
                                                            nodesJsonStrings[index]) as Map<
                                                        String,
                                                        dynamic>)['address'])
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
                : TranslateText('Nodes are loading... or Empty',
                    language: widget.lang),
      ),
    );
  }

  loadListFromBilling() {
    if (widget.settings.altServer == '' ||
        widget.settings.login == '' ||
        widget.settings.password == '') {
    } else {
      Server server = Server(settings: widget.settings);
      server.list(type: 'node').then((value) {
        if (value != '') {
          setState(() {
            nodesJsonStrings.addAll(value.split('\n'));
          });
        }
      });
    }
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
        'node: ${(json.decode(nodesJsonString) as Map<String, dynamic>)['key'] ?? (json.decode(nodesJsonString) as Map<String, dynamic>)['address']}';
    sharedPreferences.remove(key);
  }

  void removeFromServer({required String name}) async {
    print('removing: node with hash = $name');
    Server server = Server(settings: widget.settings);
    server.remove(type: 'node', key: name);
    //server.saveBin(id: '', hash: name, type: 'deleted by at ${DateTime.now()}');
  }

  Widget showMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
          zoom: 16,
          maxZoom: 18,
          crs: mapSource == MapSource.yandexsat
              ? const Epsg3395()
              : const Epsg3857(),
          center: widget.settings.baseLocation ?? LatLng(0, 0)),
      layers: [layerMap(mapSource), MarkerLayerOptions(markers: getNodes())],
    );
  }

  List<Marker> getNodes() {
    List<Marker> nodesMarkers = [];
    List<Node> nodes =
        nodesJsonStrings.map((e) => Node.fromJson(json.decode(e))).toList();
    for (var node in nodes) {
      nodesMarkers.add(Marker(
          point: node.location!,
          builder: ((context) => IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) =>
                        NodesScreen(node: node, settings: widget.settings))));
              },
              icon: const Icon(Icons.add_box_outlined)))));
    }
    return nodesMarkers;
  }
}
