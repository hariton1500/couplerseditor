import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../Helpers/location.dart';
//import '../Helpers/epsg3395.dart';

//import 'package:latlong/latlong.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key, required this.startLocation}) : super(key: key);
  final LatLng startLocation;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  //Location location = Location();

  @override
  void initState() {
    super.initState();
    getMyLocation();
  }

  getMyLocation() async {
    print('get location...');
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('location service is not enabled');
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('permition is not granted (');
        return;
      }
    }

    getLocation().then((locationData) {_mapController.move(
        LatLng(locationData!.latitude!, locationData.longitude!), 16);});
    //print(locationData.toString());
    
  }

  @override
  Widget build(BuildContext context) {
    print('run Location Picker with start location: ${widget.startLocation}');
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pop(_mapController.center), icon: const Icon(Icons.task_alt_outlined)),
          IconButton(onPressed: getMyLocation, icon: const Icon(Icons.navigation_outlined)),
          ...listActions()
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlutterMap(
          options: MapOptions(
              //crs: const Epsg3395(),
              controller: _mapController,
              center: widget.startLocation,
              zoom: 16.0,
              maxZoom: 18.0,
              onTap: (tapPos, latlng) {
                setState(() {
                  _markers.clear();
                  _markers.add(Marker(
                    //width: 80.0,
                    //height: 80.0,
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
            //TileLayerOptions(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.app',),
            //TileLayerOptions(urlTemplate: 'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU'),
            TileLayerOptions(urlTemplate: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=ru-RU&scale=1&xss=1&yss=1&s=G5zdHJ1c3Q%3D&client=gme-google&style=api%3A1.0.0&key=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY'),
            //TileLayerOptions(urlTemplate: 'https://tiles.api-maps.yandex.ru/v1/tiles/?l=map&scale=1.0&x={x}&y={y}&z={z}&lang=ru_RU&apikey='),
            /*
            TileLayerOptions(
                urlTemplate:
                    'http://vec{s}.maps.yandex.net/tiles?l=map&v=4.55.2&z={z}&x={x}&y={y}&scale=1.0&lang=ru_RU',
                subdomains: ['01', '02', '03', '04'],
                backgroundColor: Colors.transparent),*/
            //CircleLayerOptions(circles: _circles),
            MarkerLayerOptions(markers: _markers),
          ],
          mapController: _mapController,
        ),
      ),
    );
  }
  
  List<Widget> listActions() {
    return [];
  }
}
