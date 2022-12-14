// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:coupolerseditor/Helpers/map.dart';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:coupolerseditor/Services/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import '../services/jsonbin_io.dart';
import '../services/server.dart';
import 'settings.dart';

class Cable {
  CableEnd? end1, end2;
  List<LatLng> points = [];
  String? key, key1, key2;

  Cable({required this.end1, required this.end2, this.key1, this.key2}) {
    points.add(end1!.location ?? zeroLocation);
    points.add(end2!.location ?? zeroLocation);
  }

  Cable.fromJson(Map<String, dynamic> json) {
    print('load cable from json');
    print(json);
    //end1 = json.containsKey('end1') ? CableEnd.fromJson(json['end1']) : null;
    //end2 = json.containsKey('end2') ? CableEnd.fromJson(json['end2']) : null;
    key1 = json['end1'];
    key2 = json['end2'];

    try {
      points =
          List.from(json['points']).map((x) => LatLng.fromJson(x)).toList();
    } catch (e) {
      print(e);
    }
    key = json['key'];
  }

  Map<String, dynamic> toJson() => {
        'end1': key1,
        'end2': key2,
        'key': key,
        'points': points,
        //'key1': key1,
        //'key2': key2
      };

  String signature() {
    //print('signature of cable with ends: $end1 and $end2');
    //return key ?? '${end1!.signature()}:${end2!.signature()}';
    return key ?? '$key1:$key2';
  }

  @override
  String toString() {
    return 'key: $key; ${end1?.direction} <=> ${end2?.direction}';
  }

  double distance() {
    double d = 0;
    //LatLng p1 = end1!.location!;
    List<LatLng> cable = [end1!.location!, ...points, end2!.location!];
    for (var i = 1; i < cable.length; i++) {
      d += calculateDistance(cable[i - 1], cable[i]);
      //p1 = points[i];
    }
    return d;
  }

  Future<bool> saveCable(bool isFromServer) async {
    print('saving cable to ${isFromServer ? 'server' : 'local device'}');
    if (isFromServer) {
      Settings settings = Settings();
      await settings.loadSettings();
      if (settings.altServer == '' ||
          settings.login == '' ||
          settings.password == '') {
        return false;
      } else {
        Server server = Server(settings: settings);
        String type = 'cable';
        Map<String, dynamic> data = toJson();
        if (key == null) {
          key = signature().hashCode.toString();
          return await server.add(key: key!, type: type, data: data);
        } else {
          return await server.edit(key: key!, type: type, data: data);
        }
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cable: ${key ?? signature()}', jsonEncode(toJson()));
      return true;
    }
  }

  Future<void> remove(bool isFromServer) async {
    print('removing cable from ${isFromServer ? 'server' : 'local device'}');
    if (isFromServer) {
      Settings settings = Settings();
      await settings.loadSettings();
      Server server = Server(settings: settings);
      server.remove(type: 'cable', key: key!);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('cable: ${key ?? signature()}');
    }
  }

  List<Polyline> polylines(
      {required MaterialColor color, double? strokeWidth}) {
    /*
    List<LatLng> list = [];
    list.add(end1!.location!);
    list.addAll(points);
    list.add(end2!.location!);
    */
    return [
      Polyline(
          points: [end1!.location!, ...points, end2!.location!],
          strokeWidth: strokeWidth ?? 2,
          color: color)
    ];
  }
}
