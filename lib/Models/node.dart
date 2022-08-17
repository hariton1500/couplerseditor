import 'dart:convert';

import 'package:coupolerseditor/Models/activedevice.dart';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Node {
  LatLng? location;
  List<ActiveDevice> equipments = [];
  List<CableEnd> cableEnds = [];
  String address = '';
  List<Connection> connections = [];

  Node({required this.address});

  Node.fromJson(Map<String, dynamic> json) {
    location = LatLng.fromJson(json['location']);
    equipments = json['equipments'];
    address = json['address'];
  }

  String toJson() {
    return jsonEncode({
      'address': address,
      'location': location!.toJson(),
      'equipments': equipments,
      'cableEnds': cableEnds,
      'connections': connections,
    });
  }

  void saveToLocal() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String jsonString = toJson();
    print('saving to local: $jsonString');
    sharedPreferences.setString('node: $address', jsonString);
  }
}

class Connection {
  MapEntry<MapEntry<Object, int>, MapEntry<Object, int>>? connectionData;

  Connection({required this.connectionData});
  Connection.fromJson(Map<String, dynamic> json) {
    for (var connectionMap in json['connections']) {
      var side1 = connectionMap['connectionData'][0];
      var side2 = connectionMap['connectionData'][1];
      (side1['side1'] as Map<String, dynamic>).containsKey('AD')
          ? connectionData = MapEntry(
              MapEntry(
                  ActiveDevice.fromJson(side1['side1'] as Map<String, dynamic>),
                  side1['side1']['port'] as int),
              MapEntry(
                  ActiveDevice.fromJson(side2['side2'] as Map<String, dynamic>),
                  side2['side2']['port'] as int))
          : connectionData = MapEntry(
              MapEntry(
                  CableEnd.fromJson(side1['side1'] as Map<String, dynamic>),
                  side1['side1']['port'] as int),
              MapEntry(
                  CableEnd.fromJson(side2['side2'] as Map<String, dynamic>),
                  side2['side2']['port'] as int));
    }
  }

  Map<String, dynamic> toJson() {
    var side1 = MapEntry(
        connectionData!.key.key is ActiveDevice
            ? ['AD', (connectionData!.key.key as ActiveDevice).ip]
            : ['CE', (connectionData!.key.key as CableEnd).direction],
        connectionData!.key.value);
    var side2 = MapEntry(
        connectionData!.value.key is ActiveDevice
            ? ['AD', (connectionData!.value.key as ActiveDevice).ip]
            : ['CE', (connectionData!.value.key as CableEnd).direction],
        connectionData!.value.value);
    return {
      'connectionData': [
        {'side1': side1.key, 'port': side1.value},
        {'side2': side2.key, 'port': side2.value}
      ]
    };
  }
}
