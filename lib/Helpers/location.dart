// ignore_for_file: avoid_print

import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

LatLng zeroLocation = LatLng(33, 35);

Future<LatLng?> getLocation() async {
  print('get location...');
  Location location = Location();

  bool serviceEnabled = false;
  PermissionStatus permissionGranted = PermissionStatus.denied;
  //LocationData locationData;

  if (!Platform.isWindows) {
    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('location service is not enabled');
        return Future.error(Exception('Issue'));
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('permition is not granted (');
        return Future.error(Exception('Issue'));
      }
    }

    var data = await location.getLocation();
    return LatLng(data.latitude!, data.longitude!);
  } else {
    return zeroLocation;
  }
}
