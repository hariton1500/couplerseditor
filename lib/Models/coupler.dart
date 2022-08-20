import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cableend.dart';

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
  Mufta({
    required this.name,
    required this.cableEnds,
    required this.connections,
    this.location,
  });

  String name = '';
  List<CableEnd> cableEnds = [];
  List<Connection> connections = [];
  LatLng? location;

  String toString() {
    return 'Mufta: $name; cableEnds: $cableEnds; connections: $connections';
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
  }

  String toJson() {
    return jsonEncode({
      'name': name,
      'cables': cableEnds,
      'connections': connections,
      'location': location!.toJson()
    });
  }

  void saveToLocal() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String jsonString = toJson();
    print('saving to local: $jsonString');
    sharedPreferences.setString('coupler: $name', jsonString);
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
}
