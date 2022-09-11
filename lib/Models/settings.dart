import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  String baseUrl = '';
  String language = 'en';
  LatLng? baseLocation;

  Future loadSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    baseUrl = shared.getString('baseUrl') ?? '';
    language = shared.getString('language') ?? 'en';
    baseLocation = LatLng.fromJson(json.decode(
        shared.getString('baseLocation') ?? '{"coordinates":[0.0,0.0]}'));
  }

  void saveSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('baseUrl', baseUrl);
    shared.setString('language', language);
    shared.setString('baseLocation', json.encode(baseLocation?.toJson()));
  }
}
