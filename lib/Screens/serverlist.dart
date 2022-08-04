
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import '../Helpers/strings.dart';

class ServerList extends StatefulWidget {
  final String lang;
  final String serverListURL;

  const ServerList({Key? key, required this.lang, required this.serverListURL}) : super(key: key);

  @override
  State<ServerList> createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  
  List<String> couplers = [];
  
  bool showAsMap = false;
  
  final MapController _mapController = MapController();

  @override
  void initState() {
    loadListFromBilling();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslateText('List of couplers from billing', language: widget.lang,),
        actions: [
          IconButton(
            icon: showAsMap ? const Icon(Icons.list_alt_rounded) : const Icon(Icons.map_rounded),
            onPressed: () {setState(() {
              showAsMap = !showAsMap;
            });},
          )
        ],
      ),
      body: Center(
        child: couplers.isEmpty ? TranslateText('List of couplers is Loading...', language: widget.lang) :
          !showAsMap ?
            ListView.builder(
              itemCount: couplers.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> coupler = jsonDecode(couplers[index]);
                return ListTile(
                  title: Text(coupler['direction']),
                );
              },
            ) :
            FlutterMap(
              options: MapOptions(
                controller: _mapController,
                center: LatLng(45.200834, 33.351089),
                zoom: 16.0,
                maxZoom: 18.0
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(
                  markers: couplers.map((e) {
                    Map<String, dynamic> coupler = jsonDecode(e);
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(coupler['location']['latitude'], coupler['location']['longitude']),
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: () {
                          _mapController.move(
                              LatLng(coupler['location']['latitude'], coupler['location']['longitude']), 16);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
      ),
    ));
  }
  
  void loadListFromBilling() {}
}