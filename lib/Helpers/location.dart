// ignore_for_file: avoid_print

import 'package:location/location.dart';

Future<LocationData?> getLocation() async {
  print('get location...');
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

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

  return location.getLocation();
}
