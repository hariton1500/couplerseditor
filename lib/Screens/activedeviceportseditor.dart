import 'package:coupolerseditor/Models/activedevice.dart';
import 'package:flutter/material.dart';

import '../Helpers/spliters.dart';
import '../Helpers/strings.dart';

class AvtiveDevicePortsEditor extends StatefulWidget {
  final String lang;
  final ActiveDevice activeDevice;

  const AvtiveDevicePortsEditor(
      {Key? key, required this.lang, required this.activeDevice})
      : super(key: key);

  @override
  State<AvtiveDevicePortsEditor> createState() =>
      _AvtiveDevicePortsEditorState();
}

class _AvtiveDevicePortsEditorState extends State<AvtiveDevicePortsEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslateText(
          'Active Device Ports Editor',
          language: widget.lang,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Wrap(
              children: [
                TranslateText('Device: ', language: widget.lang),
                Text(
                    '${widget.activeDevice.model} (${widget.activeDevice.ip})'),
              ],
            ),
            Column(
              //shrinkWrap: true,
              //physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                  widget.activeDevice.ports,
                  (index) => Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((index + 1).toString()),
                          ),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text:
                                      widget.activeDevice.portComments[index]),
                              onChanged: (value) {
                                widget.activeDevice.portComments[index] = value;
                              },
                            ),
                          ),
                          Checkbox(
                            value: widget.activeDevice.spliters[index] > 0,
                            onChanged: (bool? isSpliter) {
                              print(isSpliter);
                              isSpliter!
                                  ? showDialog<int>(
                                      context: context,
                                      builder: (cntx) {
                                        print(widget.activeDevice.spliters);
                                        print(index);
                                        if (widget
                                            .activeDevice.spliters.isEmpty) {
                                          widget.activeDevice.spliters =
                                              List.filled(
                                                  widget.activeDevice.ports, 0);
                                        }
                                        return AlertDialog(
                                            actions: [
                                              OutlinedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(
                                                          widget.activeDevice
                                                              .spliters[index]),
                                                  child: const Text('Ok'))
                                            ],
                                            content: Column(
                                              children: List.generate(
                                                  spliterList.length,
                                                  (spliter) => OutlinedButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(spliterList[
                                                                  spliter]),
                                                      child: Text(
                                                          spliterList[spliter]
                                                              .toString()))),
                                            ));
                                      }).then((value) => setState(
                                        () {
                                          widget.activeDevice.spliters[index] =
                                              value!;
                                        },
                                      ))
                                  : setState(() =>
                                      widget.activeDevice.spliters[index] = 0);
                            },
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
