// ignore_for_file: avoid_print

import 'dart:convert';
//import 'package:coupolerseditor/Helpers/epsg3395.dart';
import 'package:coupolerseditor/Models/settings.dart';
import 'package:coupolerseditor/services/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helpers/enums.dart';
import '../../Helpers/epsg3395.dart';
import '../../Helpers/strings.dart';
import '../../Models/fosc.dart';
//import '../../services/jsonbin_io.dart';
import '../Foscs/fosc_page.dart';

class CouplersList extends StatefulWidget {
  final Settings settings;
  final bool isFromBilling;

  const CouplersList(
      {Key? key,
      required this.settings,
      required this.isFromBilling})
      : super(key: key);

  @override
  State<CouplersList> createState() => _CouplersListState();
}

class _CouplersListState extends State<CouplersList> {
  List<String> couplers = [];

  bool showAsMap = false;

  final MapController _mapController = MapController();

  int? selectedCouplerIndex;

  MapSource mapSource = MapSource.openstreet;

  @override
  void initState() {
    print('isFromBilling: ${widget.isFromBilling}');
    widget.isFromBilling ? loadListFromBilling() : loadListFromDevice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              TranslateText(
                widget.isFromBilling
                    ? 'List of couplers from billing'
                    : 'List of couplers from device',
                language: widget.settings.language,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: showAsMap
                  ? const Icon(Icons.list_alt_rounded)
                  : const Icon(Icons.map_rounded),
              onPressed: () {
                setState(() {
                  showAsMap = !showAsMap;
                });
              },
            ),
            selectedCouplerIndex != null
                ? IconButton(
                    icon: const Icon(Icons.task_alt_outlined),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => MuftaScreen(
                                  mufta: Mufta.fromJson(jsonDecode(
                                      couplers[selectedCouplerIndex!])),
                                  callback: () {
                                    setState(() {
                                      couplers.clear();
                                      widget.isFromBilling
                                          ? loadListFromBilling()
                                          : loadListFromDevice();
                                    });
                                  },
                                  settings: widget.settings)))
                          .then((value) {});
                      //Navigator.of(context).pop(couplers[selectedCouplerIndex!]);
                    },
                  )
                : Container(),
          ],
        ),
        bottomSheet: showAsMap
            ? Wrap(
                children: listActions(),
              )
            : const Text(''),
        body: Center(
          child: couplers.isEmpty
              ? TranslateText('List of couplers is Loading or Empty',
                  language: widget.settings.language)
              : !showAsMap
                  ? ListView.builder(
                      itemCount: couplers.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> coupler =
                            jsonDecode(couplers[index]);
                        return ListTile(
                          leading: IconButton(
                            icon: const Icon(Icons.delete_rounded),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: TranslateText(
                                    'Delete coupler',
                                    language: widget.settings.language,
                                  ),
                                  content: TranslateText(
                                    'Are you sure you want to delete coupler?',
                                    language: widget.settings.language,
                                  ),
                                  actions: [
                                    TextButton(
                                      child: TranslateText(
                                        'Cancel',
                                        language: widget.settings.language,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: TranslateText(
                                        'Delete',
                                        language: widget.settings.language,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          widget.isFromBilling
                                              ? removeFromServer(
                                                  name: Mufta.fromJson(coupler)
                                                      .signature()
                                                      .hashCode
                                                      .toString())
                                              : removeCoupler(coupler['name']);
                                          couplers.removeAt(index);
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
                              coupler['name'],
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {
                              //check
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => MuftaScreen(
                                          mufta: Mufta.fromJson(jsonDecode(
                                              couplers[index])),
                                          callback: () {
                                            setState(() {
                                              couplers.clear();
                                              widget.isFromBilling
                                                  ? loadListFromBilling()
                                                  : loadListFromDevice();
                                            });
                                          },
                                          settings: widget.settings)));
                              /*
                              setState(() {
                                selectedCouplerIndex = index;
                              });*/
                            },
                          ),
                        );
                      },
                    )
                  : map(),
        ));
  }

  LayerOptions layerMap() {
    switch (mapSource) {
      case MapSource.google:
        return TileLayerOptions(
            urlTemplate:
                'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=ru-RU&scale=1&xss=1&yss=1&s=G5zdHJ1c3Q%3D&client=gme-google&style=api%3A1.0.0&key=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY');
      case MapSource.openstreet:
        return TileLayerOptions(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        );
      case MapSource.yandex:
        return TileLayerOptions(
            urlTemplate:
                'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU');
      default:
        return TileLayerOptions(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        );
    }
  }

  List<Widget> listActions() {
    return MapSource.values
        .map((e) => TextButton(
              onPressed: () => setState(() {
                mapSource = e;
              }),
              child: Text(e.name),
            ))
        .toList();
  }

  Widget map() {
    return FlutterMap(
      options: MapOptions(
          crs: mapSource == MapSource.yandex
              ? const Epsg3395()
              : const Epsg3857(),
          controller: _mapController,
          center: widget.settings.baseLocation,
          zoom: 16.0,
          maxZoom: 18.0,
          /*
          onTap: (tapPos, latlng) {
            setState(() {
              selectedCouplerIndex = null;
            });
            //Navigator.of(context).pop(latlng);
            //markLocation(latlng);
          }*/
      ),
      layers: [
        layerMap(),
        MarkerLayerOptions(
          markers: couplers
              .map((foscEncoded) => json.decode(foscEncoded))
              .toList()
              .map((e) => Marker(
                  point: LatLng.fromJson(e['location']!),
                  builder: (ctx) => IconButton(onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => MuftaScreen(
                                mufta: Mufta.fromJson(e),
                                callback: () {
                                  setState(() {
                                    couplers.clear();
                                    widget.isFromBilling
                                        ? loadListFromBilling()
                                        : loadListFromDevice();
                                  });
                                },
                                settings: widget.settings)));
                  }, icon: const Icon(Icons.blinds_rounded))))
              .toList(),
        )
        //TileLayerOptions(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.app',),
        //TileLayerOptions(urlTemplate: 'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU'),
        //TileLayerOptions(urlTemplate: 'https://tiles.api-maps.yandex.ru/v1/tiles/?l=map&scale=1.0&x={x}&y={y}&z={z}&lang=ru_RU&apikey='),
        //TileLayerOptions(urlTemplate: 'http://vec{s}.maps.yandex.net/tiles?l=map&v=4.55.2&z={z}&x={x}&y={y}&scale=1.0&lang=ru_RU', subdomains: ['01', '02', '03', '04'], backgroundColor: Colors.transparent),
      ],
      mapController: _mapController,
    );
  }

  loadListFromBilling() async {
    if (widget.settings.altServer == '' ||
        widget.settings.login == '' ||
        widget.settings.password == '') {
      print(
          'loading list of FOSCs from server URL = ${widget.settings.baseUrl}');
      /*
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
            setState(() {
              couplers.add(data);
            });
          }
        }
      });*/
    } else {
      print('loading from altserver');
      Server server = Server(settings: widget.settings);
      server.list(type: 'fosc').then((value) {
        print('|$value|');
        if (value != '') {
          setState(() {
            couplers.addAll(value.split('\n'));
          });
        }
      });
    }
  }

  loadListFromDevice() async {
    print('loadListFromDevice');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> codedCouplersListKeys = sharedPreferences
        .getKeys()
        .where((element) => element.startsWith('coupler: '))
        .toList();
    print('codedCouplersListKeys: $codedCouplersListKeys');
    setState(() {
      couplers = codedCouplersListKeys
          .map((codedCouplerKey) =>
              sharedPreferences.getString(codedCouplerKey) ?? '')
          .toList();
    });
  }

  void removeCoupler(String couplerName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('coupler: $couplerName');
  }

  void removeFromServer({required String name}) async {
    print('removing: node with hash = $name');
    //JsonbinIO server = JsonbinIO(settings: widget.settings);
    //server.saveBin(id: '', hash: name, type: 'deleted by at ${DateTime.now()}');
  }
}
