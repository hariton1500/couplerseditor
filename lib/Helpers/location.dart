// ignore_for_file: avoid_print

import 'dart:io';

import 'package:location/location.dart';

Future<LocationData?> getLocation() async {
  print('get location...');
  Location location = Location();

  bool serviceEnabled = false;
  PermissionStatus permissionGranted = PermissionStatus.denied;
  //LocationData locationData;

  if (!Platform.isWindows) {
    serviceEnabled = await location.serviceEnabled();
  }
  if (!serviceEnabled && !Platform.isWindows) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      print('location service is not enabled');
      return Future.error(Exception('Issue'));
    }
  }
  if (!Platform.isWindows) {
    permissionGranted = await location.hasPermission();
  }
  if (permissionGranted == PermissionStatus.denied && !Platform.isWindows) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      print('permition is not granted (');
      return Future.error(Exception('Issue'));
    }
  }

  return Platform.isWindows
      ? Future.error(Exception('Issue'))
      : location.getLocation();
}
