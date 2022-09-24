import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/jsonbin_io.dart';
import 'cableend.dart';
import 'settings.dart';

class Connection {
  //List<int> connectionData = [];
  int cableIndex1, fiberNumber1, cableIndex2, fiberNumber2;
  Connection(
      {required this.cableIndex1,
      required this.fiberNumber1,
      required this.cableIndex2,
      required this.fiberNumber2}) {
    //connectionData = [cableIndex1, fiberNumber1, cableIndex2, fiberNumber2];
  }
  Map<String, dynamic> toJson() => {
        //'connectionData' : connectionData,
        'cableIndex1': cableIndex1,
        'cableIndex2': cableIndex2,
        'fiberNumber1': fiberNumber1,
        'fiberNumber2': fiberNumber2
      };
  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        cableIndex1: json["cableIndex1"],
        cableIndex2: json["cableIndex2"],
        fiberNumber1: json["fiberNumber1"],
        fiberNumber2: json["fiberNumber2"],
      );
}

class Mufta {
  String name = '';
  List<CableEnd> cableEnds = [];
  List<Connection> connections = [];
  LatLng? location;
  String? key;

  Mufta({
    required this.name,
    required this.cableEnds,
    required this.connections,
    this.location,
  });

  @override
  String toString() {
    return 'Key: $key; Mufta: $name; cableEnds: $cableEnds; connections: $connections';
  }

  
  String signature() {
    //return '$name:${location?.latitude}:${location?.longitude}';
    return key ?? name;
  }

  Mufta.fromJson(Map<String, dynamic> json) {
    print('loading Mufta from json:');
    //print(json);
    name = json['name'];
    cableEnds =
        List<CableEnd>.from(json['cables'].map((x) => CableEnd.fromJson(x)));
    connections = List<Connection>.from(
        json['connections'].map((x) => Connection.fromJson(x)));
    location = LatLng.fromJson(json['location']);
    key = json['key'];
  }

  String toJson() {
    return jsonEncode({
      'name': name,
      'cables': cableEnds,
      'connections': connections,
      'location': location!.toJson(),
      'key': key
    });
  }

  void saveToLocal() async {
    for (var cableEnd in cableEnds) {
      cableEnd.location = location;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String jsonString = toJson();
    print('saving to local: $jsonString');
    sharedPreferences.setString('coupler: ${key ?? name}', jsonString);
  }

  Function addConnection() {
    return (int cableIndex, int fiberNumber) {
      connections.add(Connection(
          cableIndex1: cableIndex,
          fiberNumber1: fiberNumber,
          cableIndex2: 0,
          fiberNumber2: 0));
    };
  }

  Future<bool> saveToServer() async {
    print('/////////saveToServer////////////');
    Settings settings = Settings();
    await settings.loadSettings();
    JsonbinIO server = JsonbinIO(settings: settings);
    await server.loadBins();
    print('current bins = ${server.bins}');
    String binId = key ?? signature().hashCode.toString();
    print('binId = $binId');
    if (!server.bins.containsKey(binId)) {
      print('creating new bin');
      key = binId;
      return await server.createJsonRecord(
          key: binId, jsonString: toJson(), type: 'fosc');
    } else {
      print('updating bin $binId');
      return await server.updateJsonRecord(
          type: 'fosc',
          binId: server.bins[binId]['id'], jsonString: toJson());
    }
  }
}
