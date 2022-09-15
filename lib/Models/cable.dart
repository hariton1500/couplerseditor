// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/jsonbin_io.dart';
import 'settings.dart';

class Cable {
  CableEnd? end1, end2;

  Cable({required this.end1, required this.end2});

  Cable.fromJson(Map<String, dynamic> json) {
    end1 = CableEnd.fromJson(json['end1']);
    end2 = CableEnd.fromJson(json['end2']);
  }

  Map<String, dynamic> toJson() => {'end1': end1, 'end2': end2};

  String signature() {
    print('signature of cable with ends: $end1 and $end2');
    return '${end1!.signature()}:${end2!.signature()}';
  }

  @override
  String toString() {
    return signature();
  }

  Future<bool> saveCable(bool isFromServer) async {
    print('saving cable to ${isFromServer ? 'server' : 'local device'}');
    if (isFromServer) {
      Settings settings = Settings();
      await settings.loadSettings();
      JsonbinIO server = JsonbinIO(settings: settings);
      await server.loadBins();
      print('current bins = ${server.bins}');
      String binId = signature().hashCode.toString();
      print('binId = $binId');
      if (!server.bins.containsKey(binId)) {
        print('creating new bin');
        return await server.createJsonRecord(
            name: binId, jsonString: json.encode(toJson()), type: 'cable');
      } else {
        print('updating bin $binId');
        return await server.updateJsonRecord(
            binId: server.bins[binId]['id'], jsonString: json.encode(toJson()));
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cable: ${signature()}', jsonEncode(toJson()));
      return true;
    }
  }

  Future<void> remove(bool isFromServer) async {
    print('removing cable from ${isFromServer ? 'server' : 'local device'}');
    if (isFromServer) {
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('cable: ${signature()}');
    }
  }
}
