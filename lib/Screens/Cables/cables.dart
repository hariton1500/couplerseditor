import 'dart:convert';

import 'package:coupolerseditor/Services/location.dart';
//import 'package:coupolerseditor/services/location.dart';
import 'package:coupolerseditor/Helpers/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helpers/enums.dart';
import '../../Helpers/epsg3395.dart';
import '../../Helpers/map.dart';
import '../../Models/cable.dart';
import '../../Models/cableend.dart';
import '../../Models/fosc.dart';
import '../../Models/node.dart';
import '../../Models/settings.dart';
//import '../../services/jsonbin_io.dart';
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
  bool isViewOnMap = true;
  List<CableEnd> ends = [];
  List<Node> nodes = [];
  List<Mufta> couplers = [];
  List<Cable> cables = [];

  Mufta? selectedFosc;
  String key1 = '', key2 = '';

  final MapController _mapController = MapController();
  MapSource mapSource = MapSource.yandexmap;

  List<Mufta> selectedFoscList = [];
  List<Node> selectedNodeList = [];

  //LatLng? _currentPos;

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
                      cables.add(Cable(
                          end1: ends.first,
                          end2: ends.last,
                          key1: key1,
                          key2: key2));
                      cables.last.saveCable(widget.isFromServer);
                      ends.clear();
                      selectedFosc = null;
                      selectedFoscList.clear();
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
      nonRotatedChildren: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: MapSource.values
                  .map((e) => TextButton(
                      onPressed: () {
                        setState(() {
                          mapSource = e;
                        });
                      },
                      child: Text(e.name)))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...selectedFoscList
                        .map((fosc) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                color: selectedFoscList.indexOf(fosc) == 0
                                    ? Colors.blue
                                    : Colors.red,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '[${fosc.name}]',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ...fosc.cableEnds
                                        .skipWhile(
                                            (value) => isAlreadyUsed(value))
                                        .map((cableEnd) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Draggable<CableEnd>(
                                                data: cableEnd,
                                                feedback: Material(
                                                    child: Text(
                                                        cableEnd.direction)),
                                                child: DragTarget<CableEnd>(
                                                    onAccept: (data) {
                                                      key1 =
                                                          'fosc<|>${selectedFoscList.first.key}<|>${selectedFoscList.first.location?.toJson()}<|>${cableEnd.signature()}';
                                                      key2 =
                                                          'fosc<|>${selectedFoscList.last.key}<|>${selectedFoscList.last.location?.toJson()}<|>${data.signature()}';
                                                      print(
                                                          'cableEnd=${cableEnd.direction}($key1); data=${data.direction}($key2)');
                                                      setState(() {
                                                        ends = [cableEnd, data];
                                                      });
                                                    },
                                                    builder: (context,
                                                            candidateData,
                                                            rejectedData) =>
                                                        Container(
                                                            //width: double.infinity,
                                                            color: Colors.white,
                                                            child: Text(cableEnd
                                                                .direction))),
                                              ),
                                            ))
                                        .toList()
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                    ...selectedNodeList
                        .map((node) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                color: selectedNodeList.indexOf(node) == 0
                                    ? Colors.blue
                                    : Colors.red,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '[${node.address}]',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ...node.cableEnds
                                        .skipWhile(
                                            (value) => isAlreadyUsed(value))
                                        .map((cableEnd) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Draggable<CableEnd>(
                                                data: cableEnd,
                                                feedback: Material(
                                                    child: Text(
                                                        cableEnd.direction)),
                                                child: DragTarget<CableEnd>(
                                                    onAccept: (data) {
                                                      key1 =
                                                          'node<|>${selectedNodeList.first.key}<|>${selectedNodeList.first.location?.toJson()}<|>${cableEnd.signature()}';
                                                      key2 =
                                                          'node<|>${selectedNodeList.last.key}<|>${selectedNodeList.last.location?.toJson()}<|>${data.signature()}';
                                                      print(
                                                          'cableEnd=${cableEnd.direction}($key1); data=${data.direction}($key2)');
                                                      setState(() {
                                                        ends = [cableEnd, data];
                                                      });
                                                    },
                                                    builder: (context,
                                                            candidateData,
                                                            rejectedData) =>
                                                        Container(
                                                            //width: double.infinity,
                                                            color: Colors.white,
                                                            child: Text(cableEnd
                                                                .direction))),
                                              ),
                                            ))
                                        .toList()
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ]),
            )
          ],
        )
      ],
      mapController: _mapController,
      options: MapOptions(
          zoom: 16.0,
          maxZoom: 18.0,
          crs: mapSource == MapSource.yandexsat
              ? const Epsg3395()
              : const Epsg3857(),
          center: widget.settings.baseLocation ?? LatLng(0, 0)),
      layers: [
        layerMap(mapSource),
        if (ends.length == 2)
          PolylineLayerOptions(polylines: [
            Polyline(
                points: ends.map((e) => e.location!).toList(),
                color: Colors.black,
                strokeWidth: 3)
          ]),
        PolylineLayerOptions(
            polylines: cables
                .map((cable) => Polyline(strokeWidth: 3, points: [
                      cable.end1!.location ?? LatLng(0, 0),
                      cable.end2!.location ?? LatLng(0, 0)
                    ]))
                .toList()),
        MarkerLayerOptions(markers: getFOSCS()),
        MarkerLayerOptions(markers: getNodes())
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
      } else {
        print(
            'loading list of stored cables from server URL = ${widget.settings.altServer}');
        Server server = Server(settings: widget.settings);
        server.list(type: 'cable').then((value) {
          if (value != '') {
            print(value);
            setState(() {
              cables.addAll(value.split('\n').map((e) {
                Cable cable = Cable.fromJson(json.decode(e));
                //
                //setting end1 and end2 cableEnds from couplers or nodes
                //
                if (cable.key1 != null && cable.key1!.startsWith('fosc<|>')) {
                  int index = int.tryParse(cable.key1!.split('<|>')[2]) ?? 0;
                  cable.end1 = couplers
                      .where((element) =>
                          element.key == cable.key1!.split('<|>')[1])
                      .first
                      .cableEnds[index];
                } else {
                  print('key=${cable.key1}');
                  int index = int.tryParse(cable.key1!.split('<|>')[2]) ?? 0;
                  cable.end1 = nodes
                      .where((element) =>
                          element.key == cable.key1!.split('<|>')[1])
                      .first
                      .cableEnds[index];
                }
                if (cable.key2 != null && cable.key2!.startsWith('fosc<|>')) {
                  int index = int.tryParse(cable.key2!.split('<|>')[2]) ?? 0;
                  cable.end2 = couplers
                      .where((element) =>
                          element.key == cable.key2!.split('<|>')[1])
                      .first
                      .cableEnds[index];
                } else {
                  int index = int.tryParse(cable.key2!.split('<|>')[2]) ?? 0;
                  cable.end2 = nodes
                      .where((element) =>
                          element.key == cable.key2!.split('<|>')[1])
                      .first
                      .cableEnds[index];
                }
                return cable;
              }).toList());
            });
          }
        });
      }
    }
  }

  List<Marker> getFOSCS() {
    return couplers
        .map((fosc) => Marker(
            width: 40,
            //height: fosc.cableEnds.length * 20,
            point: fosc.location!,
            builder: (context) {
              return Material(
                color: Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      addFOSCToSelected(fosc);
                    },
                    icon: Icon(
                      Icons.blinds_rounded,
                      color: selectedFoscList.contains(fosc)
                          ? selectedFoscList.indexOf(fosc) == 0
                              ? Colors.blue
                              : Colors.red
                          : Colors.black,
                    )),
              );
            }))
        .toList();
  }

  List<Marker> getNodes() {
    return nodes
        .map((node) => Marker(
            width: 40,
            point: node.location!,
            builder: ((context) => Material(
                color: Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      addNodeToSelected(node);
                    },
                    icon: Icon(
                      Icons.ac_unit_rounded,
                      color: selectedNodeList.contains(node)
                          ? selectedNodeList.indexOf(node) == 0
                              ? Colors.blue
                              : Colors.red
                          : Colors.black,
                    ))))))
        .toList();
  }

  void addFOSCToSelected(Mufta fosc) {
    setState(() {
      if (selectedFoscList.contains(fosc)) {
        selectedFoscList.remove(fosc);
      } else {
        if (selectedFoscList.length < 2) {
          selectedFoscList.add(fosc);
        }
      }
    });
  }

  void addNodeToSelected(Node node) {
    setState(() {
      if (selectedNodeList.contains(node)) {
        selectedNodeList.remove(node);
      } else {
        if (selectedNodeList.length < 2) {
          selectedNodeList.add(node);
        }
      }
    });
  }

  bool isAlreadyUsed(CableEnd value) {
    print('isAlreadyUsed ${value.signature()}');
    int count = 0;
    cables.forEach((element) {
      //print(element.end1?.location.toString());
      //print(element.end2?.location.toString());
      if (element.end1!.toString() == value.toString()) {
        print('found at cable ${element.toString()}');
        count++;
      }
      if (element.end2!.toString() == value.toString()) {
        print('found at cable ${element.toString()}');
        count++;
      }
      //print('---------------');
    });
    print(count);
    return count > 0;
  }
}
