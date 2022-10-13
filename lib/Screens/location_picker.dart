import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import '../Helpers/enums.dart';
import '../Helpers/epsg3395.dart';
import '../Helpers/map.dart';
import '../services/location.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key, required this.startLocation})
      : super(key: key);
  final LatLng startLocation;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  MapSource mapSource = MapSource.openstreet;

  LatLng? location;

  @override
  Widget build(BuildContext context) {
    print('run Location Picker with start location: ${widget.startLocation}');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.startLocation.toString()),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pop(location),
              icon: const Icon(Icons.task_alt_outlined)),
          IconButton(
              onPressed: () async {
                getLocation().then((value) {
                  if (value is LatLng) {
                    _mapController.move(value, 18);
                    setState(() {
                      location = value;
                    });
                  }
                });
              },
              icon: const Icon(Icons.navigation_outlined)),
        ],
      ),
      bottomSheet: Wrap(
        children: listActions(),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: map(),
      ),
    );
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
          //crs: mapSource == MapSource.yandexsat ? const Epsg3395() : const Epsg3857(),
          controller: _mapController,
          center: widget.startLocation,
          zoom: 16.0,
          maxZoom: 18.0,
          onTap: (tapPos, latlng) {
            setState(() {
              _markers.clear();
              _markers.add(Marker(
                point: latlng,
                builder: (ctx) => const Icon(
                  Icons.control_point_outlined,
                  size: 10.0,
                  color: Colors.red,
                ),
              ));
            });
            Navigator.of(context).pop(latlng);
            //markLocation(latlng);
          }),
      layers: [
        layerMap(mapSource),
        MarkerLayerOptions(markers: _markers),
        //TileLayerOptions(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.app',),
        //TileLayerOptions(urlTemplate: 'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU'),
        //TileLayerOptions(urlTemplate: 'https://tiles.api-maps.yandex.ru/v1/tiles/?l=map&scale=1.0&x={x}&y={y}&z={z}&lang=ru_RU&apikey='),
        //TileLayerOptions(urlTemplate: 'http://vec{s}.maps.yandex.net/tiles?l=map&v=4.55.2&z={z}&x={x}&y={y}&scale=1.0&lang=ru_RU', subdomains: ['01', '02', '03', '04'], backgroundColor: Colors.transparent),
      ],
      mapController: _mapController,
    );
  }
}
