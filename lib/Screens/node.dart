import 'package:coupolerseditor/Models/cableend.dart';
import 'package:flutter/material.dart';

import '../Helpers/equipments.dart';
import '../Helpers/fibers.dart';
import '../Helpers/strings.dart';
import '../Models/node.dart';

class NodesScreen extends StatefulWidget {
  final String lang;
  //final Node node= Node(address: 'asdasd');

  const NodesScreen({
    Key? key,
    required void Function() callback,
    required this.lang,
  }) : super(key: key);

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  Node node = Node(address: '');
  //List equipments = [];
  //List<CableEnd> cableEnds = [];
  String direction = '';
  int fibersNumber = 1;
  List<DropdownMenuItem<int>> fibersList = fibers
      .map((e) => DropdownMenuItem<int>(
            value: e,
            child: Text(e.toString()),
          ))
      .toList();
  String colorScheme = fiberColors.keys.toList().first;

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
        for (final Map equipment in node.equipments)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: equipment.containsKey('widget')
                ? equipment['widget']
                : Text(
                    '[${node.equipments.indexOf(equipment) + 1}]${equipment['name']}: ${equipment['value'].toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        for (final cableEnd in node.cableEnds)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '[${node.cableEnds.indexOf(cableEnd) + 1}]${cableEnd.direction}: ${cableEnd.fibersNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                cableEnd.widget(colors: fiberColors[cableEnd.colorScheme!]!),
              ],
            ),
          ),
        Wrap(
          children: [
            TextButton.icon(
                onPressed: () => showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: TranslateText('Add new equipment:',
                              language: widget.lang),
                          content: Column(
                            children: [
                              for (final equipment in equipmentsList)
                                OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(equipment),
                                    child: Text(equipment['name']))
                            ],
                          ),
                          actions: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.cancel_outlined),
                              label: TranslateText(
                                'cancel',
                                language: widget.lang,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ]);
                    }).then((value) => setState(
                      () => value != null ? node.equipments.add(value) : print,
                    )),
                icon: const Icon(Icons.add),
                label: TranslateText('Add equipment', language: widget.lang)),
          ],
        ),
        TextButton.icon(
            onPressed: () => showDialog<CableEnd>(
                context: context,
                builder: (context) {
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
        if ((node.cableEnds.length + node.equipments.length) >= 2) ...[
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_outlined),
            label: TranslateText('Add connection', language: widget.lang),
          ),
        ]
      ])),
    );
  }
}
