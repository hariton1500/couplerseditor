import 'dart:convert';

import 'package:coupolerseditor/Models/activedevice.dart';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:coupolerseditor/Models/settings.dart';
import 'package:coupolerseditor/services/jsonbin_io.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/server.dart';

class Node {
  LatLng? location;
  List<ActiveDevice> equipments = [];
  List<CableEnd> cableEnds = [];
  String address = '';
  List<Connection> connections = [];

  Node({required this.address});

  Node.fromJson(Map<String, dynamic> json) {
    location = LatLng.fromJson(json['location']);
    equipments = List.from(json['equipments'])
        .map((x) => ActiveDevice.fromJson(x))
        .toList();
    address = json['address'];
    cableEnds =
        List.from(json['cableEnds']).map((x) => CableEnd.fromJson(x)).toList();
    connections = List.from(json['connections']).map((e) {
      print(e);
      var side1 = e['connectionData'][0];
      var side2 = e['connectionData'][1];
      Object s1, s2;
      side1['side1'][0] == 'AD'
          ? s1 = equipments.firstWhere((x) => x.ip == side1['side1'][1])
          : s1 = cableEnds.firstWhere((x) => x.direction == side1['side1'][1]);
      side2['side2'][0] == 'AD'
          ? s2 = equipments.firstWhere((x) => x.ip == side2['side2'][1])
          : s2 = cableEnds.firstWhere((x) => x.direction == side2['side2'][1]);
      return Connection(
          connectionData: MapEntry(
              MapEntry(s1, side1['port']), MapEntry(s2, side2['port'])));
    }).toList();
  }

  @override
  String toString() {
    return 'Node: $address; equipments: $equipments; cableEnds: $cableEnds; connections: $connections';
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'location': location!.toJson(),
      'equipments': equipments,
      'cableEnds': cableEnds,
      'connections': connections,
    };
  }

  String signature() {
    //return '$address:${location?.latitude}:${location?.longitude}';
    return address;
  }

  void saveToLocal() async {
    for (var cableEnd in cableEnds) {
      cableEnd.location = location;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String jsonString = json.encode(toJson());
    print('saving to local: $jsonString');
    sharedPreferences.setString('node: $address', jsonString);
  }

  Future<bool> saveToServer() async {
    print('/////////saveToServer////////////');
    Settings settings = Settings();
    await settings.loadSettings();

    if (settings.altServer == '' ||
        settings.login == '' ||
        settings.password == '') {
      JsonbinIO server = JsonbinIO(settings: settings);
      await server.loadBins();
      print('current bins = ${server.bins}');
      String binId = signature().hashCode.toString();
      print('binId = $binId');
      if (!server.bins.containsKey(binId)) {
        print('creating new bin');
        return await server.createJsonRecord(
            key: binId, jsonString: json.encode(toJson()), type: 'node');
      } else {
        print('updating bin $binId');
        return await server.updateJsonRecord(
            type: 'node',
            binId: server.bins[binId]['id'],
            jsonString: json.encode(toJson()));
      }
    } else {
      Server server = Server(settings: settings);
      String type = 'fosc';
      Map<String, dynamic> data = toJson();
      List<String> fields = ['cables', 'connections', 'location'];
      return await server.add(
          key: signature().hashCode.toString(),
          type: type,
          data: data,
          fields: fields);
    }
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
