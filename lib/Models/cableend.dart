import 'package:flutter/material.dart';
import '../Helpers/fibers.dart';

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
  //Function callback = (Object asd) {};

  CableEnd(
      {required this.id,
      required this.fibersNumber,
      required this.direction,
      required this.sideIndex,
      required this.colorScheme}) {
    fiberComments = List.filled(fibersNumber, '');
    spliters = List.filled(fibersNumber, 0);
  }

  @override
  String toString() {
    return 'CableEnd{direction: $direction, fibersNumber: $fibersNumber, colorScheme: $colorScheme}';
  }
  
  Widget widget(
      {required List<Color> colors,
      required void Function(MapEntry<Object, int>, int) callback}) {
    return Wrap(
      children: List.generate(
          fibersNumber,
          (index) => Draggable<MapEntry<CableEnd, int>>(
              data: MapEntry(this, index),
              feedback: element(index, colors),
              child: DragTarget<MapEntry<Object, int>>(builder:
                  (BuildContext context,
                      List<MapEntry<Object, int>?> candidateData,
                      List<dynamic> rejectedData) {
                return element(index, colors);
              }, onAccept: (data) {
                print('onAcceptOnCableEnd: $data');
                if (data.key != this) {
                  callback(data, index);
                }
          }))),
    );
  }

  Widget element(int index, List<Color> colors) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black), color: colors[index]),
        //color: colors[index],
        width: 30,
        height: 20,
        child: Center(
            child: Text(
          (index + 1).toString(),
          style: const TextStyle(color: Colors.black),
        )));
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
