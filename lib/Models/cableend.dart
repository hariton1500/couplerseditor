import 'package:flutter/material.dart';

import '../Helpers/fibercolors.dart';

class CableEnd {
  int id = -1;
  int sideIndex = 0;
  String direction = '';
  int fibersNumber = 0;
  String? colorScheme;
  List<String> fiberComments = [];
  //List<int> withSpliter = [];
  Map<int, double> fiberPosY = {};
  List<int> spliters = [];

  CableEnd( 
      {required this.id,
      required this.fibersNumber,
      required this.direction,
      required this.sideIndex,
      required this.colorScheme}) {
    fiberComments = List.filled(fibersNumber, '');
    spliters = List.filled(fibersNumber, 0);
  }

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
        'id': id,
        'direction': direction,
        'sideIndex': sideIndex,
        'fibersNumber': fibersNumber,
        'colorScheme': colorScheme,
        'fiberComments': fiberComments,
        'spliter': spliters,
      };
  CableEnd.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    direction = json["direction"];
    sideIndex = json["sideIndex"];
    fibersNumber = json["fibersNumber"];
    colorScheme = json['colorScheme'] ?? fiberColors.keys.first;
    fiberComments = List.castFrom<dynamic, String>(json['fiberComments']);
    spliters = json['spliters'] ?? List.filled(fibersNumber, 0);
  }
}
