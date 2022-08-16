import 'dart:convert';
import 'package:flutter/material.dart';
import '../Helpers/strings.dart';

class ActiveDevice {
  int id = -1;
  String ip = '';
  int ports = 0;
  String model = '';

  ActiveDevice({required this.id, required this.ip, required this.ports, required this.model});
  ActiveDevice.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    ip = json['ip'] as String;
    ports = json['ports'] as int;
    model = json['name'] as String;
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'ip': ip,
      'ports': ports,
      'model': model,
    });
  }

  Widget widget({required void Function(MapEntry<Object, int>, int) callback, bool? isSelected}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text('id: $id; model: $model; ip: $ip; ports: $ports', style: TextStyle(color: isSelected ?? false ? Colors.red : Colors.black)),
        ),
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
                  if (data.key != this) {
                    callback(data, index);
                  }
                  //callback(data, index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget element(int index, {bool isLarge = false}) {
    return Container(
      width: isLarge ? 30 * 1.1 : 30,
      height: isLarge ? 30 * 1.1 : 30,
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        (index + 1).toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Future<ActiveDevice?> fromDialog(BuildContext context, String language) async {
    var res = await showDialog<ActiveDevice>(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        String id = '-1', ports = '8', ip = '', model = '';
                        return AlertDialog(
                            title: TranslateText('Add new equipment:',
                                language: language),
                            content: Column(
                              children: [
                                TextField(
                                  keyboardType: TextInputType.text,
                                  controller: TextEditingController(text: ip),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Model',
                                  ),
                                  onChanged: (value) {
                                    model = value;
                                  },
                                ),
                                const Divider(),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(text: ip),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'IP address',
                                  ),
                                  onChanged: (value) {
                                    ip = value;
                                  },
                                ),
                                const Divider(),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(text: id),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'ID',
                                  ),
                                  onChanged: (value) {
                                    id = value;
                                  },
                                ),
                                const Divider(),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      TextEditingController(text: ports),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Ports',
                                  ),
                                  onChanged: (value) {
                                    ports = value;
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.cancel_outlined),
                                label: TranslateText(
                                  'cancel',
                                  language: language,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add_outlined),
                                label: TranslateText(
                                  'Add device',
                                  language: language,
                                ),
                                onPressed: () {
                                  RegExp ipExp = RegExp(
                                      r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$",
                                      caseSensitive: false,
                                      multiLine: false);
                                  if (int.tryParse(id) != null) {
                                    if (int.tryParse(ports) != null) {
                                      if (ipExp.hasMatch(ip)) {
                                        Navigator.of(context).pop(ActiveDevice(
                                            id: int.parse(id),
                                            ip: ip,
                                            ports: int.parse(ports), model: model));
                                      } else {
                                        setState(() {
                                          ip = '';
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        ports = '8';
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      id = '-1';
                                    });
                                  }
                                },
                              )
                            ]);
                      });
                    });
    return res;
  }

}