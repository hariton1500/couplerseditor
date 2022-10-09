// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:coupolerseditor/Models/cableend.dart';
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
  String? key;

  Cable({required this.end1, required this.end2});

  Cable.fromJson(Map<String, dynamic> json) {
    end1 = CableEnd.fromJson(json['end1']);
    end2 = CableEnd.fromJson(json['end2']);
    try {
      points =
          List.from(json['points']).map((x) => LatLng.fromJson(x)).toList();
    } catch (e) {
      print(e);
    }
    key = json['key'];
  }

  Map<String, dynamic> toJson() =>
      {'end1': end1, 'end2': end2, 'key': key, 'points': points};

  String signature() {
    //print('signature of cable with ends: $end1 and $end2');
    return key ?? '${end1!.signature()}:${end2!.signature()}';
  }

  @override
  String toString() {
    return 'key: $key; ${end1!.direction} <=> ${end2!.direction}';
  }

  Future<bool> saveCable(bool isFromServer) async {
    print('saving cable to ${isFromServer ? 'server' : 'local device'}');
    if (isFromServer) {
      Settings settings = Settings();
      await settings.loadSettings();
      if (settings.altServer == '' ||
          settings.login == '' ||
          settings.password == '') {
        /*
        JsonbinIO server = JsonbinIO(settings: settings);
        await server.loadBins();
        print('current bins = ${server.bins}');
        String binId = signature().hashCode.toString();
        print('binId = $binId');
        if (!server.bins.containsKey(binId)) {
          print('creating new bin');
          return await server.createJsonRecord(
              key: binId, jsonString: json.encode(toJson()), type: 'cable');
        } else {
          print('updating bin $binId');
          return await server.updateJsonRecord(
              type: 'cable',
              binId: server.bins[binId]['id'],
              jsonString: json.encode(toJson()));
        }
      */
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

  List<Polyline> polylines({required MaterialColor color, double? strokeWidth}) {
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
