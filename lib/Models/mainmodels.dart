import 'dart:convert';
import 'package:coupolerseditor/Helpers/fibercolors.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

Mufta muftaFromJson(String str) => Mufta.fromJson(json.decode(str));
String muftaToJson(Mufta data) => json.encode(data.toJson());

class CableEnd {
  int sideIndex;
  String direction;
  int fibersNumber;
  String colorScheme;
  Map<int, double> fiberPosY = {};
  CableEnd(
      {required this.fibersNumber,
      required this.direction,
      required this.sideIndex,
      required this.colorScheme});

  Widget widget(List<Color> colors) {
    return Column(
      children: List.generate(
          fibersNumber,
          (index) => Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: colors[index]),
              //color: colors[index],
              width: 30,
              height: 16,
              child: Center(
                  child: Text(
                (index + 1).toString(),
                style: TextStyle(
                    color: (index == 7 || index == 19)
                        ? Colors.white
                        : Colors.black),
              )))),
    );
  }

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'sideIndex': sideIndex,
        'fibersNumber': fibersNumber,
        'colorScheme': colorScheme
        //'fiberPosY': fiberPosY
      };
  factory CableEnd.fromJson(Map<String, dynamic> json) => CableEnd(
        direction: json["direction"],
        sideIndex: json["sideIndex"],
        fibersNumber: json["fibersNumber"],
        colorScheme: json['colorScheme'] ?? fiberColors.keys.first,
      );
}

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
    required this.cables,
    required this.connections,
    this.location,
  });

  String name = '';
  List<CableEnd> cables = [];
  List<Connection> connections = [];
  LatLng? location;

  Map<String, dynamic> toJson() => {
        //'colors' : colors,
        'name': name,
        'cables': cables, //?.map((e) => e.toJson()).toList(),
        'connections': connections, //?.map((e) => e.toJson()).toList()
        'location': location
      };
  factory Mufta.fromJson(Map<String, dynamic> json) => Mufta(
      name: json["name"],
      cables:
          List<CableEnd>.from(json["cables"].map((x) => CableEnd.fromJson(x))),
      connections: List<Connection>.from(
          json["connections"].map((x) => Connection.fromJson(x))),
      location: json["location"]);
}

class Settings {
  String couplersListUrl = '', couplerUrl = '', language = 'en';

  Future loadSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    couplersListUrl = shared.getString('couplersListUrl') ?? '';
    couplerUrl = shared.getString('couplerUrl') ?? '';
    language = shared.getString('language') ?? 'en';
  }

  void saveSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('couplersListUrl', couplersListUrl);
    shared.setString('couplerUrl', couplerUrl);
    shared.setString('language', language);
  }
}
