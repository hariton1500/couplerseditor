import 'dart:convert';

import 'package:coupolerseditor/services/location.dart';
import 'package:coupolerseditor/Helpers/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/cable.dart';
import '../../Models/cableend.dart';
import '../../Models/fosc.dart';
import '../../Models/node.dart';
import '../../Models/settings.dart';
import '../../services/jsonbin_io.dart';
import '../../services/server.dart';
import 'cableeditor.dart';

class CableScreen extends StatefulWidget {
  const CableScreen(
      {Key? key,
      required this.lang,
      //required this.cable,
      required this.isFromServer,
      required this.settings})
      : super(key: key);
  final String lang;
  //final Cable cable;
  final bool isFromServer;
  final Settings settings;

  @override
  State<CableScreen> createState() => _CableScreenState();
}

class _CableScreenState extends State<CableScreen> {
  bool isViewOnMap = false;
  List<CableEnd> ends = [];
  List<Node> nodes = [];
  List<Mufta> couplers = [];
  List<Cable> cables = [];

  Mufta? selectedFosc;

  final MapController _mapController = MapController();

  LatLng? _currentPos;

  @override
  void initState() {
    super.initState();
    _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer);
    _loadCables(isSourceLocal: !widget.isFromServer)
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    //print(ends);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: TranslateText(
            'Cables',
            language: widget.settings.language,
            size: 16,
          ),
          actions: <Widget>[
            if (ends.length == 2) ...[
              IconButton(
                  onPressed: () {
                    setState(() {
                      cables.add(Cable(end1: ends.first, end2: ends.last));
                      cables.last.saveCable(widget.isFromServer);
                      ends.clear();
                      selectedFosc = null;
                    });
                  },
                  icon: const Icon(Icons.save_rounded))
            ],
            if (selectedFosc != null) ...[
              IconButton(
                  onPressed: () => setState(() {
                        selectedFosc = null;
                      }),
                  icon: const Icon(Icons.deselect_outlined))
            ],
            isViewOnMap
                ? IconButton(
                    onPressed: () {
                      getLocation().then((locationData) {
                        print(locationData);
                        _mapController.move(
                            LatLng(
                                locationData!.latitude, locationData.longitude),
                            16);
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
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DragTarget<CableEnd>(onAccept: (ce) {
              print('$ce to 1');
              setState(() {
                if (ends.isNotEmpty) {
                  ends[0] = ce;
                } else {
                  ends.add(ce);
                }
              });
            }, builder: ((context, candidateData, rejectedData) {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.green,
                child: TextButton(
                    onPressed: () => setState(() {
                          if (ends.isNotEmpty) ends.removeAt(0);
                        }),
                    child: Text(
                      '1: ${ends.isNotEmpty ? ends[0].direction : ''}',
                      style: const TextStyle(color: Colors.black),
                    )),
              );
            })),
            DragTarget<CableEnd>(onAccept: (ce) {
              print('$ce to 2');
              setState(() {
                if (ends.length == 2) {
                  ends[1] = ce;
                } else {
                  ends.add(ce);
                }
              });
            }, builder: ((context, candidateData, rejectedData) {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.red,
                child: TextButton(
                    onPressed: () => setState(() {
                          if (ends.length == 2) ends.removeAt(1);
                        }),
                    child: Text(
                      '2: ${ends.length == 2 ? ends[1].direction : ''}',
                      style: const TextStyle(color: Colors.black),
                    )),
              );
            })),
          ],
        ),
        body: !isViewOnMap
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    const Divider(),
                    Column(
                      children: [
                        TranslateText(
                          'New cable:',
                          language: widget.lang,
                        ),
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
                                    _loadCouplersAndNodes(
                                        isSourceLocal: !widget.isFromServer,
                                        enableFilter: ends.length == 1);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    ends.length == 2
                        ? TextButton.icon(
                            onPressed: () {
                              if (cables.any((cable) =>
                                  cable.end1!.signature() ==
                                      ends[0].signature() ||
                                  cable.end1!.signature() ==
                                      ends[1].signature() ||
                                  cable.end2!.signature() ==
                                      ends[0].signature() ||
                                  cable.end2!.signature() ==
                                      ends[1].signature())) {
                                return;
                              }
                              print('creating cable from $ends');
                              Cable cable = Cable(end1: ends[0], end2: ends[1]);
                              cable.saveCable(widget.isFromServer);
                              setState(() {
                                cables.add(cable);
                                ends.clear();
                                _loadCouplersAndNodes(
                                    isSourceLocal: !widget.isFromServer);
                              });
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: TranslateText(
                              'Save',
                              language: widget.lang,
                            ))
                        : Container(),
                    isViewOnMap ? _buildMap() : _buildList(),
                    const Divider(),
                    TranslateText(
                      'Stored cables:',
                      language: widget.lang,
                    ),
                    Column(
                      children: cables
                          .map((cable) => ListTile(
                                leading: IconButton(
                                    onPressed: () {
                                      cable
                                          .remove(widget.isFromServer)
                                          .then((value) => setState(() {
                                                cables.remove(cable);
                                                ends.clear();
                                                _loadCouplersAndNodes(
                                                    isSourceLocal:
                                                        !widget.isFromServer);
                                              }));
                                    },
                                    icon: const Icon(Icons.delete_outline)),
                                title: Text(
                                    '${cable.end1!.signature()} - ${cable.end2!.signature()}'),
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => CableEditor(
                                                    cable: cable,
                                                    settings: widget.settings,
                                                    isFromServer:
                                                        widget.isFromServer,
                                                  )));
                                    },
                                    icon: const Icon(Icons.edit_road_outlined)),
                              ))
                          .toList(),
                    )
                  ],
                ),
              )
            : _buildMap(),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        couplers.isNotEmpty
            ? TranslateText('From couplers:', language: widget.lang)
            : Container(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: couplers.length,
          itemBuilder: (context, index) {
            return couplers[index].cableEnds.isNotEmpty
                ? ListTile(
                    title: Text(couplers[index].name),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var end in couplers[index].cableEnds)
                            cables.any((cable) =>
                                    cable.end1!.signature() ==
                                        end.signature() ||
                                    cable.end2!.signature() == end.signature())
                                ? Container()
                                : TextButton.icon(
                                    label: Text(
                                        '${end.direction} (${end.colorScheme}: ${end.fibersNumber})'),
                                    icon: const Icon(
                                        Icons.local_hospital_outlined),
                                    onPressed: () {
                                      setState(() {
                                        if (ends.length < 2) ends.add(end);
                                        _loadCouplersAndNodes(
                                            isSourceLocal: !widget.isFromServer,
                                            enableFilter: ends.length == 1);
                                      });
                                    })
                        ]),
                  )
                : Container();
          },
        ),
        const Divider(),
        nodes.isNotEmpty
            ? TranslateText('From nodes:', language: widget.lang)
            : Container(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            return nodes[index].cableEnds.isNotEmpty
                ? ListTile(
                    title: Text(nodes[index].address),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var end in nodes[index].cableEnds)
                            cables.any((cable) =>
                                    cable.end1!.signature() ==
                                        end.signature() ||
                                    cable.end2!.signature() == end.signature())
                                ? Container()
                                : TextButton.icon(
                                    label: Text(
                                        '${end.direction} (${end.colorScheme}: ${end.fibersNumber})'),
                                    icon: const Icon(
                                        Icons.local_hospital_outlined),
                                    onPressed: () {
                                      setState(() {
                                        if (ends.length < 2) ends.add(end);
                                        _loadCouplersAndNodes(
                                            isSourceLocal: !widget.isFromServer,
                                            enableFilter: ends.length == 1);
                                      });
                                    })
                        ]),
                  )
                : Container();
          },
        ),
      ],
    );
  }

  Widget _buildMap() {
    print('building map for creating cables from cableends');
    print(widget.settings.baseLocation.toString());
    return FlutterMap(
      options: MapOptions(
          zoom: 16.0,
          maxZoom: 18.0,
          controller: _mapController,
          center: widget.settings.baseLocation ?? LatLng(0, 0)),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        PolylineLayerOptions(
            polylines: cables
                .map((cable) => Polyline(strokeWidth: 3, points: [
                      cable.end1!.location ?? LatLng(0, 0),
                      cable.end2!.location ?? LatLng(0, 0)
                    ]))
                .toList()),
        MarkerLayerOptions(
            markers: couplers
                .map((e) => Marker(
                    width: 400,
                    height: 100,
                    point: e.location!,
                    builder: (context) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                color: selectedFosc == e
                                    ? Colors.red
                                    : Colors.green,
                                onPressed: () {
                                  print('${e.name} selected');
                                  setState(() {
                                    selectedFosc = e;
                                  });
                                },
                                icon: const Icon(Icons.blinds_rounded)),
                            selectedFosc == e
                                ? Column(
                                    children: e.cableEnds
                                        .map((ce) => Draggable<CableEnd>(
                                              data: ce,
                                              feedback: const Icon(Icons.cable),
                                              child: TextButton.icon(
                                                  onPressed: () {
                                                    print(ce.toString());
                                                  },
                                                  icon: const Icon(
                                                      Icons.cable_rounded),
                                                  label: Text(ce.toString())),
                                            ))
                                        .toList(),
                                  )
                                : Container()
                          ],
                        )))
                .toList())
      ],
    );
  }

  Future<void> _loadCouplersAndNodes(
      {bool isSourceLocal = true, bool enableFilter = false}) async {
    if (ends.length == 2) {
      couplers = [];
      nodes = [];
      return;
    }
    //loading Couplers
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> couplersJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('coupler:'))
          .toSet();
      print(couplersJsonStrings);
      couplers = couplersJsonStrings
          .map((element) =>
              Mufta.fromJson(jsonDecode(prefs.getString(element) ?? '')))
          .toList();
    } else {
      if (widget.settings.altServer == '' ||
          widget.settings.login == '' ||
          widget.settings.password == '') {
        print(
            'loading list of FOSCs from server URL = ${widget.settings.baseUrl}');
        JsonbinIO server = JsonbinIO(settings: widget.settings);
        server.loadBins().then((_) async {
          List<MapEntry<String, dynamic>> nodeBinsList =
              server.bins.entries.where((element) {
            Map<String, dynamic> data = (element.value is Map)
                ? element.value
                : {'id': element.value, 'type': 'unknown'};
            return data['type'] == 'fosc';
          }).toList();
          print('nodeBinsList = $nodeBinsList');
          for (var bin in nodeBinsList) {
            String data = await server.loadDataFromBin(binId: bin.value['id']);
            if (data != '') {
              //setState(() {
              couplers.add(Mufta.fromJson(json.decode(data)));
              //});
            }
          }
        });
      } else {
        print('loading from altserver');
        Server server = Server(settings: widget.settings);
        server.list(type: 'fosc').then((value) {
          print('|$value|');
          if (value != '') {
            setState(() {
              couplers.addAll(
                  value.split('\n').map((e) => Mufta.fromJson(json.decode(e))));
            });
          }
        });
      }
    }
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> nodesJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('node:'))
          .toSet();
      nodes = nodesJsonStrings
          .map((element) =>
              Node.fromJson(jsonDecode(prefs.getString(element) ?? '')))
          .toList();
    } else {
      //nodes = [];
      if (widget.settings.altServer == '' ||
          widget.settings.login == '' ||
          widget.settings.password == '') {
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
                nodes.add(Node.fromJson(json.decode(data)));
              });
            }
          }
        });
      } else {
        Server server = Server(settings: widget.settings);
        server.list(type: 'node').then((value) {
          if (value != '') {
            setState(() {
              nodes.addAll(
                  value.split('\n').map((e) => Node.fromJson(json.decode(e))));
            });
          }
        });
      }
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
          if (end.fibersNumber != fNum ||
              end.colorScheme != color ||
              end.direction == ends.first.direction) {
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
          if (end.fibersNumber != fNum ||
              end.colorScheme != color ||
              end.direction == ends.first.direction) {
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

  Future<void> _loadCables({required bool isSourceLocal}) async {
    print('loading cables from ${isSourceLocal ? 'local device' : 'server'}');
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> cablesJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('cable:'))
          .toSet();
      print('cables keys: $cablesJsonStrings');
      try {
        cables = cablesJsonStrings
            .map((element) =>
                Cable.fromJson(jsonDecode(prefs.getString(element) ?? '')))
            .toList();
      } catch (e) {
        print(e);
      }
      print('${cables.length} loaded');
    } else {
      //cables = [];
      if (widget.settings.altServer == '' ||
          widget.settings.login == '' ||
          widget.settings.password == '') {
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
      } else {
        Server server = Server(settings: widget.settings);
        server.list(type: 'cable').then((value) {
          if (value != '') {
            setState(() {
              cables.addAll(value
                  .split('\n')
                  .map((e) => Cable.fromJson(json.decode(e)))
                  .toList());
            });
          }
        });
      }
    }
  }
}
