import 'dart:convert';

import 'package:flutter/material.dart';

class ActiveDevice {
  int id = -1;
  String ip = '';
  int ports = 0;

  ActiveDevice({required this.id, required this.ip, required this.ports});
  ActiveDevice.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    ip = json['ip'] as String;
    ports = json['ports'] as int;
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'ip': ip,
      'ports': ports,
    });
  }

  Widget widget({required void Function(MapEntry<Object, int>, int) callback}) {
    return Column(
      children: [
        Text('id: $id; ip: $ip; ports: $ports'),
        Wrap(
          children: List.generate(
            ports,
            (index) => Draggable<MapEntry<ActiveDevice, int>>(
              feedback: element(index),
              data: MapEntry(this, index),
              child: DragTarget<MapEntry<Object, int>>(
                builder: (BuildContext context,
                    List<MapEntry<Object, int>?> candidateData,
                    List<dynamic> rejectedData) {
                  return element(index);
                },
                onAccept: (data) {
                  print('onAcceptOnActiveDevice: $data; $index');
                  callback(data, index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget element(int index) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          (index + 1).toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
