import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/cable.dart';
import '../Models/coupler.dart';
import '../Models/node.dart';

class ViewerScreen extends StatefulWidget {
  final bool isFromServer;
  final String lang;

  const ViewerScreen({Key? key, required this.lang, required this.isFromServer})
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

  @override
  void initState() {
    super.initState();
    _loadCouplersAndNodes(isSourceLocal: !widget.isFromServer)
        .then((value) => setState(
              () {},
            ));
    _loadCables(isSourceLocal: !widget.isFromServer).then((value) => setState(
          () {},
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewer'),
        actions: [
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
                  //controller: _mapController,
                  center: LatLng(45.200834, 33.351089),
                  zoom: 16.0,
                  maxZoom: 18.0,
                  onTap: (tapPos, latlng) {
                    print(tapPos.relative.toString());
                    setState(() {
                      selectedCouplerIndex = -1;
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
                      width: 80.0,
                      height: 80.0,
                      point: coupler.location!,
                      builder: (ctx) =>
                          selectedCouplerIndex != couplers.indexOf(coupler)
                              ? IconButton(
                                  autofocus: true,
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    print('clicked on marker ${coupler.name}');
                                    setState(() {
                                      selectedCouplerIndex =
                                          couplers.indexOf(coupler);
                                    });
                                  },
                                )
                              : Text(coupler.name),
                    );
                  }).toList(),
                ),
                MarkerLayerOptions(
                  markers: nodes.map((node) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: node.location!,
                      builder: (ctx) =>
                          selectedCouplerIndex != nodes.indexOf(node)
                              ? IconButton(
                                  autofocus: true,
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    print('clicked on marker ${node.address}');
                                    setState(() {
                                      selectedCouplerIndex =
                                          nodes.indexOf(node);
                                    });
                                  },
                                )
                              : Text(node.address),
                    );
                  }).toList(),
                ),
                PolylineLayerOptions(
                  polylines: cables.map((cable) {
                    return Polyline(
                      points: cable.ends.map((end) {
                        return end.location ?? LatLng(45.200834, 33.351089);
                      }).toList(),
                      strokeWidth: 3.0,
                      color: Colors.red,
                    );
                  }).toList(),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  nodes.isEmpty && couplers.isEmpty && cables.isEmpty
                      ? const Center(
                          child: Text('Empty or loading...'),
                        )
                      : Container(),
                  !isViewOnMap && nodes.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: nodes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(nodes[index].address),
                              subtitle: Text(nodes[index].location.toString()),
                            );
                          })
                      : Container(),
                  !isViewOnMap && couplers.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: couplers.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(couplers[index].name),
                              subtitle:
                                  Text(couplers[index].location.toString()),
                            );
                          })
                      : Container(),
                  !isViewOnMap && cables.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: cables.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                  'side 1: ${cables[index].ends[0].location} <---> '),
                              subtitle: Text(
                                  'side 2: ${cables[index].ends[1].location}'),
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
    } else {
      couplers = [];
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
      nodes = [];
    }
  }

  Future<void> _loadCables({required bool isSourceLocal}) async {
    if (isSourceLocal) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> cablesJsonStrings = prefs
          .getKeys()
          .where((element) => element.startsWith('cable:'))
          .toSet();
      cables = cablesJsonStrings
          .map((element) =>
              Cable.fromJson(jsonDecode(prefs.getString(element) ?? '')))
          .toList();
    } else {
      cables = [];
    }
  }
}
