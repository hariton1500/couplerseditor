import 'dart:convert';
import 'dart:math';

import 'package:coupolerseditor/Helpers/enums.dart';
import 'package:coupolerseditor/Helpers/epsg3395.dart';
import 'package:coupolerseditor/Helpers/map.dart';
import 'package:coupolerseditor/Screens/Foscs/fosc_page.dart';
import 'package:coupolerseditor/services/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/location.dart';
import '../Helpers/strings.dart';
import '../Models/cable.dart';
import '../Models/cableend.dart';
import '../Models/fosc.dart';
import '../Models/node.dart';
import '../Models/settings.dart';
//import '../services/jsonbin_io.dart';
import 'Nodes/node_page.dart';

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
  MapSource mapSource = MapSource.openstreet;

  bool _isNonEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  T? _decodeJson<T>(String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (!_isNonEmpty(raw)) return null;
    try {
      final decoded = jsonDecode(raw!);
      if (decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  CableEnd? _resolveCableEnd(
      String? ref, List<Mufta> couplers, List<Node> nodes) {
    if (ref == null || ref.trim().isEmpty) return null;
    final parts = ref.split('<|>');
    if (parts.length >= 3) {
      final type = parts[0];
      final ownerKey = parts[1];
      final payload =
          parts.length >= 4 ? parts.last : parts.sublist(2).join('<|>');
      final owner = type == 'fosc'
          ? couplers.firstWhere(
              (c) => c.key == ownerKey,
              orElse: () => Mufta(name: '', cableEnds: [], connections: []))
          : nodes.firstWhere(
              (n) => n.key == ownerKey,
              orElse: () => Node(address: ''));
      final list = owner is Mufta ? owner.cableEnds : (owner as Node).cableEnds;
      if (list.isNotEmpty) {
        final index = int.tryParse(payload);
        if (index != null && index >= 0 && index < list.length) {
          return list[index];
        }
        final bySignature =
            list.where((e) => e.signature() == payload).toList();
        if (bySignature.isNotEmpty) return bySignature.first;
      }
      return null;
    }
    // Fallback: treat ref as signature and search all ends.
    for (final coupler in couplers) {
      final match =
          coupler.cableEnds.where((e) => e.signature() == ref).toList();
      if (match.isNotEmpty) return match.first;
    }
    for (final node in nodes) {
      final match =
          node.cableEnds.where((e) => e.signature() == ref).toList();
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isFromServer) {
      _loadCouplersAndNodes(isSourceLocal: false).then((_) {
        _loadCables(isSourceLocal: false).then((_) => setState(() {}));
      });
    } else {
      _loadCouplersAndNodes(isSourceLocal: true).then((_) {
        _loadCables(isSourceLocal: true).then((_) => setState(() {}));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewer'),
        actions: [
          selectedCouplerIndex >= 0
              ? IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MuftaScreen(
                          mufta: couplers[selectedCouplerIndex],
                          //callback: () {},
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
                  onPressed: () async {
                    LatLng? ll = await getLocation();
                    if (ll != null) {
                      _mapController.move(ll, 16);
                    }
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
          ? map()
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

  Widget map() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              crs:
                  mapSource == MapSource.yandexsat ? epsg3395() : const Epsg3857(),
              initialCenter: const LatLng(45.200834, 33.351089),
              initialZoom: 16.0,
              maxZoom: 18.0,
              onTap: (tapPos, latlng) {
                print(latlng);
                setState(() {
                  selectedCouplerIndex = selectedFOSC(latlng);
                  selectedNodeIndex = selectedNode(latlng);
                });
              }),
          children: [
            layerMap(mapSource),
            MarkerLayer(
              markers: couplers
                  .where((coupler) => coupler.location != null)
                  .map((coupler) {
                return Marker(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  point: coupler.location!,
                  child: Stack(
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
            MarkerLayer(
              markers: nodes.where((node) => node.location != null).map((node) {
                return Marker(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  point: node.location!,
                  child: Stack(
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
            ...cables
                .where((cable) =>
                    cable.end1?.location != null &&
                    cable.end2?.location != null)
                .map((cable) => PolylineLayer(
                    polylines: cable.polylines(
                        color: Colors.green,
                        strokeWidth: log(cable.end1!.fibersNumber.toDouble()))))
                .toList(),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            child: Row(
              children: MapSource.values
                  .map((source) => TextButton(
                      onPressed: () => setState(() {
                            mapSource = source;
                          }),
                      child: Text(source.name)))
                  .toList(),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _loadCouplersAndNodes({required bool isSourceLocal}) async {
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> couplersJsonStrings = prefs
          .getKeys()
          .where((element) =>
              element.startsWith('coupler:') || element.startsWith('coupler: '))
          .toSet();
      couplers = couplersJsonStrings
          .map((element) => _decodeJson(prefs.getString(element), Mufta.fromJson))
          .whereType<Mufta>()
          .toList();
      Set<String> nodesJsonStrings = prefs
          .getKeys()
          .where((element) =>
              element.startsWith('node:') || element.startsWith('node: '))
          .toSet();
      nodes = nodesJsonStrings
          .map((element) => _decodeJson(prefs.getString(element), Node.fromJson))
          .whereType<Node>()
          .toList();
    } else {
      Server server = Server(settings: widget.settings);
      server.list(type: 'node').then((value) {
        if (value != '') {
          setState(() {
            nodes.addAll(value.split('\n').map((e) => Node.fromJson(json.decode(e))));
          });
        }
      });
      server.list(type: 'fosc').then((value) {
        if (value != '') {
          setState(() {
            couplers.addAll(value.split('\n').map((e) => Mufta.fromJson(json.decode(e))));
          });
        }
      });
    }
  }

  Future<void> _loadCables({required bool isSourceLocal}) async {
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> cablesJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('cable:'))
          .toSet();
      try {
        final decoded = cablesJsonStrings
            .map((element) =>
                _decodeJson(prefs.getString(element), Cable.fromJson))
            .whereType<Cable>()
            .toList();
        final resolved = <Cable>[];
        for (final cable in decoded) {
          final end1 = _resolveCableEnd(cable.key1, couplers, nodes);
          final end2 = _resolveCableEnd(cable.key2, couplers, nodes);
          if (end1 == null || end2 == null) continue;
          cable.end1 = end1;
          cable.end2 = end2;
          resolved.add(cable);
        }
        cables = resolved;
      } catch (e) {
        print(e);
      }
    } else {
      Server server = Server(settings: widget.settings);
      server.list(type: 'cable').then((value) {
        if (value != '') {
          setState(() {
            final decoded = value
                .split('\n')
                .map((e) => Cable.fromJson(json.decode(e)))
                .toList();
            final resolved = <Cable>[];
            for (final cable in decoded) {
              final end1 = _resolveCableEnd(cable.key1, couplers, nodes);
              final end2 = _resolveCableEnd(cable.key2, couplers, nodes);
              if (end1 == null || end2 == null) continue;
              cable.end1 = end1;
              cable.end2 = end2;
              resolved.add(cable);
            }
            cables.addAll(resolved);
          });
        }
      });
    }
  }

  bool isTapedOnIt(LatLng a, LatLng b) {
    return pow(a.latitude - b.latitude, 2) +
            pow(a.longitude - b.longitude, 2) <=
        0.00000001;
  }

  int selectedFOSC(LatLng latLng) {
    return couplers.indexWhere(
        (fosc) => fosc.location != null && isTapedOnIt(fosc.location!, latLng));
  }

  int selectedNode(LatLng latLng) {
    return nodes.indexWhere(
        (node) => node.location != null && isTapedOnIt(node.location!, latLng));
  }
}

