import 'dart:convert';

import 'package:coupolerseditor/Models/activedevice.dart';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:latlong2/latlong.dart';

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
      'location': location!.toJson(),
      'equipments': equipments,
      'address': address,
      'connections': connections,
    });
  }
}

class Connection {
  MapEntry<MapEntry<Object, int>, MapEntry<Object, int>>? connectionData;
  Connection({required this.connectionData});
  Connection.fromJson(Map<String, dynamic> json) {
    connectionData =
        json as MapEntry<MapEntry<Object, int>, MapEntry<Object, int>>;
  }
  String toJson() {
    String res = jsonEncode(connectionData);
    print(res);
    return res;
  }
}
