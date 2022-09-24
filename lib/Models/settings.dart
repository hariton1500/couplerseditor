import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  String baseUrl = '';
  String language = 'en';
  LatLng? baseLocation;
  String binsMapId = '';
  String xMasterKey = '';
  String collectionId = '';
  String xAccessKey = '';
  String altServer = '';
  String login = '';
  String password = '';

  Future loadSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    baseUrl = shared.getString('baseUrl') ?? '';
    language = shared.getString('language') ?? 'en';
    baseLocation = LatLng.fromJson(json.decode(
        shared.getString('baseLocation') ?? '{"coordinates":[0.0,0.0]}'));
    binsMapId = shared.getString('binsMapId') ?? '';
    xMasterKey = shared.getString('xMasterKey') ?? '';
    xAccessKey = shared.getString('xAccessKey') ?? '';
    collectionId = shared.getString('collectionId') ?? '';
    altServer = shared.getString('altServer') ?? '';
    login = shared.getString('login') ?? '';
    password = shared.getString('password') ?? '';
  }

  void saveSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('baseUrl', baseUrl);
    shared.setString('language', language);
    shared.setString('baseLocation', json.encode(baseLocation?.toJson()));
    shared.setString('binsMapId', binsMapId);
    shared.setString('xMasterKey', xMasterKey);
    shared.setString('xAccessKey', xAccessKey);
    shared.setString('collectionId', collectionId);
    shared.setString('altServer', altServer);
    shared.setString('login', login);
    shared.setString('password', password);
  }
}
