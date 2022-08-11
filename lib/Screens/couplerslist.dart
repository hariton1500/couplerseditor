import 'dart:convert';
//import 'package:coupolerseditor/Helpers/epsg3395.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helpers/strings.dart';
import '../Models/coupler.dart';
import 'mufta.dart';

class CouplersList extends StatefulWidget {
  final String lang;
  final String couplersListURL;
  final bool isFromBilling;

  const CouplersList(
      {Key? key,
      required this.lang,
      required this.couplersListURL,
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
          title: TranslateText(
            widget.isFromBilling
                ? 'List of couplers from billing'
                : 'List of couplers from device',
            language: widget.lang,
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
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MuftaScreen(mufta: Mufta.fromJson(jsonDecode(couplers[selectedCouplerIndex!])), callback: () => setState(() {}), lang: widget.lang)));
                      //Navigator.of(context).pop(couplers[selectedCouplerIndex!]);
                    },
                  )
                : Container(),
          ],
        ),
        body: Center(
          child: couplers.isEmpty
              ? TranslateText('List of couplers is Loading or Empty',
                  language: widget.lang)
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
                                    language: widget.lang,
                                  ),
                                  content: TranslateText(
                                    'Are you sure you want to delete coupler?',
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
                                        removeCoupler(coupler['name']);
                                        setState(() {
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
                              setState(() {
                                selectedCouplerIndex = index;
                              });
                            },
                          ),
                        );
                      },
                    )
                  : FlutterMap(
                      options: MapOptions(
                          //crs: const Epsg3395(),
                          controller: _mapController,
                          center: LatLng(45.200834, 33.351089),
                          zoom: 16.0,
                          maxZoom: 18.0,
                          onTap: (tapPos, latlng) {
                            print(tapPos.relative.toString());
                            setState(() {
                              selectedCouplerIndex = null;
                            });
                          }),
                      layers: [
                        
                        TileLayerOptions(
                            urlTemplate:
                                'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=ru-RU&scale=1&xss=1&yss=1&s=G5zdHJ1c3Q%3D&client=gme-google&style=api%3A1.0.0&key=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY'),
                        
                        /*
                        TileLayerOptions(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                        ),
                        */
                        //TileLayerOptions(urlTemplate: 'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU'),
                        MarkerLayerOptions(
                          markers: couplers.map((e) {
                            Map<String, dynamic> coupler = jsonDecode(e);
                            return Marker(
                              width: 80.0,
                              height: 80.0,
                              point: LatLng(
                                  coupler['location']['coordinates'][1],
                                  coupler['location']['coordinates'][0]),
                              builder: (ctx) =>
                                  selectedCouplerIndex != couplers.indexOf(e)
                                      ? IconButton(
                                          autofocus: true,
                                          icon: const Icon(Icons.location_on, color: Colors.red,),
                                          onPressed: () {
                                            print(
                                                'clicked on marker ${coupler['name']}');
                                            setState(() {
                                              selectedCouplerIndex =
                                                  couplers.indexOf(e);
                                            });
                                          },
                                        )
                                      : Text(coupler['name']),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
        ));
  }

  loadListFromBilling() {}

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
}
