import 'dart:convert';
import 'dart:math';

import 'package:coupolerseditor/Screens/fosc_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helpers/location.dart';
import '../Helpers/strings.dart';
import '../Models/cable.dart';
import '../Models/fosc.dart';
import '../Models/node.dart';
import '../Models/settings.dart';
import '../services/jsonbin_io.dart';
import 'node_page.dart';

class ViewerScreen extends StatefulWidget {
  final bool isFromServer;
  final Settings settings;

  const ViewerScreen(
      {Key? key, required this.settings, required this.isFromServer})
      : super(key: key);

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  List<Node> nodes = [];
  List<Mufta> couplers = [];
  List<Cable> cables = [];
  bool isViewOnMap = false;
  bool isLoading = true;
  int selectedCouplerIndex = -1;
  int selectedNodeIndex = -1;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer)
        .then((value) => setState(
              () {
                //print(nodes);
                //print(couplers);
              },
            ));
    _loadCables(isSourceLocal: !widget.isFromServer).then((value) => setState(
          () {
            //print(cables);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    print(selectedCouplerIndex);
    print(selectedNodeIndex);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewer'),
        actions: [
          selectedCouplerIndex >= 0
              ? IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MuftaScreen(
                          mufta: couplers[selectedCouplerIndex],
                          callback: () {},
                          settings: widget.settings))),
                  icon: const Icon(Icons.task_alt_outlined))
              : Container(),
          selectedNodeIndex >= 0
              ? IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NodesScreen(
                          node: nodes[selectedNodeIndex],
                          settings: widget.settings))),
                  icon: const Icon(Icons.task_alt_outlined))
              : Container(),
          isViewOnMap
              ? IconButton(
                  onPressed: () {
                    getLocation().then((location) {
                      //print(location);
                      _mapController.move(location!, 16);
                    });
                  },
                  icon: const Icon(Icons.location_on_outlined))
              : Container(),
          IconButton(
            icon: isViewOnMap
                ? const Icon(Icons.list_outlined)
                : const Icon(Icons.map_outlined),
            onPressed: () {
              setState(() {
                isViewOnMap = !isViewOnMap;
              });
            },
          ),
        ],
      ),
      body: isViewOnMap
          ? FlutterMap(
              options: MapOptions(
                  //crs: const Epsg3395(),
                  controller: _mapController,
                  center: LatLng(45.200834, 33.351089),
                  zoom: 16.0,
                  maxZoom: 18.0,
                  onTap: (tapPos, latlng) {
                    print(latlng);
                    setState(() {
                      selectedCouplerIndex = selectedFOSC(latlng);
                      selectedNodeIndex = selectedNode(latlng);
                    });
                  }),
              layers: [
                /*
                TileLayerOptions(
                    urlTemplate:
                        'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=ru-RU&scale=1&xss=1&yss=1&s=G5zdHJ1c3Q%3D&client=gme-google&style=api%3A1.0.0&key=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY'),
                */
                TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                //TileLayerOptions(urlTemplate: 'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU'),
                MarkerLayerOptions(
                  markers: couplers.map((coupler) {
                    return Marker(
                      width: MediaQuery.of(context).size.width,
                      height: 80.0,
                      point: coupler.location!,
                      builder: (ctx) => Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          const Icon(
                            Icons.blinds_rounded,
                            color: Colors.red,
                          ),
                          Positioned(
                              bottom: 10,
                              child: Text(coupler.name,
                                  softWrap: true,
                                  maxLines: 2,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      color: couplers.indexOf(coupler) ==
                                              selectedCouplerIndex
                                          ? Colors.red
                                          : Colors.black)))
                        ],
                      ),
                    );
                  }).toList(),
                ),
                MarkerLayerOptions(
                  markers: nodes.map((node) {
                    return Marker(
                      width: MediaQuery.of(context).size.width,
                      height: 80.0,
                      point: node.location!,
                      builder: (ctx) => Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            const Icon(
                              Icons.api_outlined,
                              color: Colors.red,
                            ),
                            Positioned(
                                bottom: 10,
                                child: Text(
                                  node.address,
                                  softWrap: true,
                                  maxLines: 2,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      color: nodes.indexOf(node) ==
                                              selectedNodeIndex
                                          ? Colors.red
                                          : Colors.black),
                                ))
                          ]),
                    );
                  }).toList(),
                ),
                PolylineLayerOptions(
                  polylines: cables.map((cable) {
                    return Polyline(
                      points: [
                        cable.end1!.location ?? LatLng(0, 0),
                        cable.end2!.location ?? LatLng(0, 0)
                      ],
                      strokeWidth: 3.0,
                      color: Colors.green,
                    );
                  }).toList(),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  nodes.isEmpty && couplers.isEmpty && cables.isEmpty
                      ? Center(
                          child: TranslateText('Empty or loading...',
                              language: widget.settings.language),
                        )
                      : Container(),
                  TranslateText('Nodes:', language: widget.settings.language),
                  !isViewOnMap && nodes.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: nodes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(nodes[index].address),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(nodes[index].cableEnds.join('\n')),
                              ),
                            );
                          })
                      : Container(),
                  TranslateText('FOSCs:', language: widget.settings.language),
                  !isViewOnMap && couplers.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: couplers.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(couplers[index].name),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child:
                                    Text(couplers[index].cableEnds.join('\n')),
                              ),
                            );
                          })
                      : Container(),
                  TranslateText('Cables:', language: widget.settings.language),
                  !isViewOnMap && cables.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: cables.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                  '${cables[index].end1} <=(${cables[index].end1?.fibersNumber})=> ${cables[index].end2}'),
                            );
                          })
                      : Container(),
                ],
              ),
            ),
    );
  }

  Future<void> _loadCouplersAndNodes({required bool isSourceLocal}) async {
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> couplersJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('coupler:'))
          .toSet();
      couplers = couplersJsonStrings
          .map((element) =>
              Mufta.fromJson(jsonDecode(prefs.getString(element) ?? '')))
          .toList();
      Set<String> nodesJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('node:'))
          .toSet();
      nodes = nodesJsonStrings
          .map((element) =>
              Node.fromJson(jsonDecode(prefs.getString(element) ?? '')))
          .toList();
    } else {
      //couplers = [];
      print(
          'loading list of FOSCs from server URL = ${widget.settings.baseUrl}');
      JsonbinIO server = JsonbinIO(settings: widget.settings);
      await server.loadBins();
      List<MapEntry<String, dynamic>> foscBinsList =
          server.bins.entries.where((element) {
        Map<String, dynamic> data = (element.value is Map)
            ? element.value
            : {'id': element.value, 'type': 'unknown'};
        return data['type'] == 'fosc';
      }).toList();
      print('foscBinsList = $foscBinsList');
      for (var bin in foscBinsList) {
        String data = await server.loadDataFromBin(binId: bin.value['id']);
        if (data != '') {
          setState(() {
            couplers.add(Mufta.fromJson(json.decode(data)));
          });
        }
      }
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
            nodes.add(Node.fromJson(json.decode(data)));
          });
        }
      }
    }
  }

  bool isTapedOnIt(LatLng a, b) {
    return pow(a.latitude - b.latitude, 2) +
            pow(a.longitude - b.longitude, 2) <=
        0.00000001;
  }

  int selectedFOSC(LatLng latLng) {
    return couplers.indexWhere((fosc) => isTapedOnIt(fosc.location!, latLng));
  }

  int selectedNode(LatLng latLng) {
    return nodes.indexWhere((node) => isTapedOnIt(node.location!, latLng));
  }

  Future<void> _loadCables({required bool isSourceLocal}) async {
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> cablesJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('cable:'))
          .toSet();
      try {
        cables = cablesJsonStrings
            .map((element) =>
                Cable.fromJson(jsonDecode(prefs.getString(element) ?? '')))
            .toList();
      } catch (e) {
        print(e);
      }
    } else {
      //cables = [];
      print(
          'loading list of stored cables from server URL = ${widget.settings.baseUrl}');
      JsonbinIO server = JsonbinIO(settings: widget.settings);
      server.loadBins().then((_) async {
        List<MapEntry<String, dynamic>> nodeBinsList =
            server.bins.entries.where((element) {
          Map<String, dynamic> data = (element.value is Map)
              ? element.value
              : {'id': element.value, 'type': 'unknown'};
          return data['type'] == 'cable';
        }).toList();
        print('nodeBinsList = $nodeBinsList');
        for (var bin in nodeBinsList) {
          String data = await server.loadDataFromBin(binId: bin.value['id']);
          if (data != '') {
            setState(() {
              cables.add(Cable.fromJson(json.decode(data)));
            });
          }
        }
      });
    }
  }
}
