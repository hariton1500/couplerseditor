import 'package:coupolerseditor/Models/activedevice.dart';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:flutter/material.dart';
import '../Helpers/fibers.dart';
import '../Helpers/strings.dart';
import '../Models/node.dart';

class NodesScreen extends StatefulWidget {
  final String lang;
  //final Node node= Node(address: 'asdasd');

  const NodesScreen({
    Key? key,
    required this.lang,
  }) : super(key: key);

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  Node node = Node(address: '');
  int selectedAquipmentIndex = -1;

  @override
  Widget build(BuildContext context) {
    print(
        'cableends: ${node.cableEnds.length}; equipments: ${node.equipments.length}');
    return Scaffold(
      body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TranslateText(
            'Node address:',
            language: widget.lang,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              node.address = value;
            },
          ),
        ),
        for (final equipment in node.equipments)
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedAquipmentIndex = node.equipments.indexOf(equipment));
                },
                child: equipment.widget(callback: (o, i) {
                  print('$o; $i');
                  Connection connection = Connection(
                      connectionData: MapEntry(o, MapEntry(equipment, i)));
                  node.connections.add(connection);
                  setState(() {
                  });
                }, isSelected: selectedAquipmentIndex == node.equipments.indexOf(equipment)),
              )),
        for (final cableEnd in node.cableEnds)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '[${node.cableEnds.indexOf(cableEnd) + 1}]${cableEnd.direction}: ${cableEnd.fibersNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                cableEnd.widget(
                    colors: fiberColors[cableEnd.colorScheme!]!,
                    callback: (o, i) {
                      print('$o; $i');
                      setState(() {
                        node.connections.add(Connection(
                            connectionData:
                                MapEntry(o, MapEntry(cableEnd, i))));
                      });
                    }),
              ],
            ),
          ),
        for (final connection in node.connections)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            node.connections.remove(connection);
                          });
                        },
                        icon: const Icon(Icons.delete_outline)),
                    Text(
                      '${connection.connectionData!.key.key is CableEnd ? (connection.connectionData!.key.key as CableEnd).direction : (connection.connectionData!.key.key as ActiveDevice).ip}[${connection.connectionData!.key.value + 1}]',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.plumbing_outlined),
                    Text(
                        '${connection.connectionData!.value.key is CableEnd ? (connection.connectionData!.value.key as CableEnd).direction : (connection.connectionData!.value.key as ActiveDevice).ip}[${connection.connectionData!.value.value + 1}]',
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),
          ),
        Wrap(
          children: [
            TextButton.icon(
                onPressed: () async {
                  var res = await ActiveDevice(id: -1, ip: '', model: '', ports: 8).fromDialog(context, widget.lang);
                  print(res?.toJson());
                  if (res?.ports != 0 || res?.ip != '' || res?.model != '') {
                    res != null ? node.equipments.add(res) : null;
                  }
                  setState(() {});
                },
                  //node.equipments.add(},//ActiveDevice().askForNewDevice(context, widget.lang).then((value) => setState(() => value != null ? node.equipments.add(value) : print,)),
                icon: const Icon(Icons.add),
                label: TranslateText('Add equipment', language: widget.lang)),
            
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
                            child:
                                TranslateText('Cancel', language: widget.lang)),
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
                            child: TranslateText('Add', language: widget.lang))
                      ],
                    );
                  });
                }).then((value) => setState(
                  () => value != null ? node.cableEnds.add(value) : print,
                )),
            icon: const Icon(Icons.add),
            label: TranslateText('Add cable ending', language: widget.lang)),
        if (node.cableEnds.isNotEmpty || node.equipments.isNotEmpty) ...[
          Wrap(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined),
                label: TranslateText('Save to Server', language: widget.lang),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_outlined),
                label: TranslateText('back', language: widget.lang),
              ),
            ],
          ),
        ]
      ])),
    );
  }
}
