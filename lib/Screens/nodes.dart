import 'package:coupolerseditor/Models/activedevice.dart';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:coupolerseditor/Models/settings.dart';
import 'package:flutter/material.dart';
import '../Helpers/fibers.dart';
import '../Helpers/strings.dart';
import '../Models/node.dart';
import 'activedeviceportseditor.dart';
import 'package:latlong2/latlong.dart' as ll;

import 'location_picker.dart';

class NodesScreen extends StatefulWidget {
  final String lang;
  final Node node;
  final Settings settings;

  const NodesScreen({Key? key, required this.lang, required this.node, required this.settings})
      : super(key: key);

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  //Node node = widget.node;
  int selectedAquipmentIndex = -1;
  bool isEdititingAddress = false;

  @override
  Widget build(BuildContext context) {
    print(
        'cableends: ${widget.node.cableEnds.length}; equipments: ${widget.node.equipments.length}');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TranslateText(
              'node address:',
              language: widget.lang,
            ),
          ),
          isEdititingAddress
              ? TextField(
                  autofocus: true,
                  controller: TextEditingController(text: widget.node.address),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    widget.node.address = value;
                    //isEdititingAddress = false;
                  },
                  onEditingComplete: () => setState(() {
                    isEdititingAddress = false;
                  }),
                )
              : TextButton(
                  onPressed: () {
                    setState(() {
                      isEdititingAddress = true;
                    });
                  },
                  child: Text(widget.node.address)),
          TextButton(
              onPressed: () => showDialog<ll.LatLng>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: TranslateText(
                        'Location Picker',
                        language: widget.lang,
                      ),
                      content: LocationPicker(startLocation: widget.node.location ?? widget.settings.baseLocation ?? ll.LatLng(0, 0),),
                    );
                  }).then((value) => setState(() {
                    widget.node.location = value ?? widget.node.location ?? widget.settings.baseLocation ?? ll.LatLng(0, 0);
                  })),
              child: Wrap(
                children: [
                  TranslateText(
                    'Location:',
                    language: widget.lang,
                  ),
                  Text(
                      (widget.node.location != null
                          ? widget.node.location!
                              .toJson()['coordinates']
                              .toString()
                          : ''),
                      style: const TextStyle(fontSize: 10)),
                ],
              )),
          const Divider(),
          //location picker
          for (final equipment in widget.node.equipments)
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedAquipmentIndex =
                        widget.node.equipments.indexOf(equipment));
                  },
                  child: equipment.widget(
                      language: widget.lang,
                      callback: (o, i) {
                        print('$o; $i');
                        Connection connection = Connection(
                            connectionData:
                                MapEntry(o, MapEntry(equipment, i)));
                        widget.node.connections.add(connection);
                        setState(() {});
                      },
                      isSelected: selectedAquipmentIndex ==
                          widget.node.equipments.indexOf(equipment)),
                )),
          for (final cableEnd in widget.node.cableEnds)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '[${widget.node.cableEnds.indexOf(cableEnd) + 1}] ${cableEnd.direction}: ${cableEnd.fibersNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  cableEnd.widget(
                      colors: fiberColors[cableEnd.colorScheme!]!,
                      callback: (o, i) {
                        print('$o; $i');
                        setState(() {
                          widget.node.connections.add(Connection(
                              connectionData:
                                  MapEntry(o, MapEntry(cableEnd, i))));
                        });
                      }),
                ],
              ),
            ),
          widget.node.connections.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TranslateText('Connections:', language: widget.lang),
                )
              : Container(),
          for (final connection in widget.node.connections)
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                dense: true,
                leading: IconButton(
                    splashRadius: 12,
                    iconSize: 12,
                    onPressed: () {
                      setState(() {
                        widget.node.connections.remove(connection);
                      });
                    },
                    icon: const Icon(Icons.delete_outline, size: 12)),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${connection.connectionData!.key.key is CableEnd ? (connection.connectionData!.key.key as CableEnd).direction : (connection.connectionData!.key.key as ActiveDevice).ip}[${connection.connectionData!.key.value + 1}] ',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    const Icon(Icons.plumbing_outlined, size: 10),
                    Text(
                        ' ${connection.connectionData!.value.key is CableEnd ? (connection.connectionData!.value.key as CableEnd).direction : (connection.connectionData!.value.key as ActiveDevice).ip}[${connection.connectionData!.value.value + 1}]',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
            ),

          Wrap(
            children: [
              TextButton.icon(
                  onPressed: () async {
                    var res =
                        await ActiveDevice(id: -1, ip: '', model: '', ports: 8)
                            .fromDialog(context, widget.lang);
                    print(res?.toJson());
                    if (res?.ports != 0 || res?.ip != '' || res?.model != '') {
                      res != null ? widget.node.equipments.add(res) : null;
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: TranslateText('Add equipment', language: widget.lang)),
              if (selectedAquipmentIndex != -1) ...[
                TextButton.icon(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        ActiveDevice activeDevice =
                            widget.node.equipments[selectedAquipmentIndex];
                        return AvtiveDevicePortsEditor(
                            lang: widget.lang, activeDevice: activeDevice);
                      }).then((value) => setState(() {})),
                  icon: const Icon(Icons.edit),
                  label: TranslateText('Edit/View comments',
                      language: widget.lang),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      widget.node.equipments.removeAt(selectedAquipmentIndex);
                      selectedAquipmentIndex = -1;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label:
                      TranslateText('Delete equipment', language: widget.lang),
                ),
              ]
            ],
          ),
          TextButton.icon(
              onPressed: () => showDialog<CableEnd>(
                  context: context,
                  builder: (context) {
                    String direction = '';
                    int fibersNumber = 1;
                    List<DropdownMenuItem<int>> fibersList = fibers
                        .map((e) => DropdownMenuItem<int>(
                              value: e,
                              child: Text(e.toString()),
                            ))
                        .toList();
                    String colorScheme = fiberColors.keys.toList().first;
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        title: TranslateText('Adding of cable',
                            language: widget.lang),
                        content: Column(
                          children: [
                            TranslateText('Direction:', language: widget.lang),
                            TextField(
                              keyboardType: TextInputType.text,
                              onChanged: (text) {
                                direction = text;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TranslateText('Number of Fibers:',
                                  language: widget.lang),
                            ),
                            DropdownButton<int>(
                                value: fibersNumber,
                                onChanged: (i) {
                                  //print(i);
                                  setState(() {
                                    fibersNumber = i!;
                                  });
                                },
                                items: fibersList),
                            TranslateText(
                              'Marking:',
                              language: widget.lang,
                            ),
                            Column(
                                children: fiberColors.entries
                                    .map(
                                      (e) => RadioListTile<String>(
                                          title: Text(e.key),
                                          subtitle: Wrap(
                                            children: e.value
                                                .map((color) => Container(
                                                      width: 5,
                                                      height: 15,
                                                      color: color,
                                                    ))
                                                .toList(),
                                          ),
                                          value: e.key,
                                          groupValue: colorScheme,
                                          onChanged: (a) =>
                                              setState(() => colorScheme = a!)),
                                    )
                                    .toList()),
                          ],
                        ),
                        actions: [
                          OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: TranslateText('Cancel',
                                  language: widget.lang)),
                          OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop(CableEnd(
                                  direction: direction,
                                  fibersNumber: fibersNumber,
                                  sideIndex: 0,
                                  colorScheme: colorScheme,
                                  id: -1,
                                ));
                              },
                              child:
                                  TranslateText('Add', language: widget.lang))
                        ],
                      );
                    });
                  }).then((value) => setState(
                    () => value != null
                        ? widget.node.cableEnds.add(value)
                        : print,
                  )),
              icon: const Icon(Icons.add),
              label: TranslateText('Add cable ending', language: widget.lang)),
          if ((widget.node.cableEnds.isNotEmpty ||
                  widget.node.equipments.isNotEmpty) &&
              widget.node.location != null) ...[
            Wrap(
              children: [
                TextButton.icon(
                  onPressed: () {
                    //print(node.toJson());
                    widget.node.saveToServer();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: TranslateText('Save to Server', language: widget.lang),
                ),
                TextButton.icon(
                  onPressed: () {
                    //print(node.toJson());
                    widget.node.saveToLocal();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: TranslateText('Save to Local device',
                      language: widget.lang),
                ),
              ],
            ),
          ],
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_outlined),
            label: TranslateText('back', language: widget.lang),
          ),
        ])),
      ),
    );
  }
}
