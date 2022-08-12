import 'package:coupolerseditor/Models/cableend.dart';
import 'package:flutter/material.dart';

import '../Helpers/equipments.dart';
import '../Helpers/strings.dart';
import '../Models/node.dart';

class NodesScreen extends StatefulWidget {
  final String lang;
  final Node node;

  const NodesScreen(
      {Key? key,
      required void Function() callback,
      required this.lang,
      required this.node})
      : super(key: key);

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: TranslateText(
          'Nodes:',
          language: widget.lang,
        ),
      ),*/
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
              widget.node.address = value;
            },
          ),
        ),
        for (final equipment in widget.node.equipments!)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              equipment.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        for (final cableEnd in widget.node.cableEnds)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cableEnd.direction,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        TextButton.icon(
            onPressed: () => showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: TranslateText('Add new equipment:',
                          language: widget.lang),
                      content: Column(
                        children: [
                          for (final aquipment in equipmentsList)
                            OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(aquipment),
                                child: Text(aquipment['name']))
                        ],
                      ));
                }).then((value) => widget.node.equipments!.add(value)),
            icon: const Icon(Icons.add),
            label: TranslateText('Add equipment', language: widget.lang)),
        TextButton.icon(
            onPressed: () => showDialog<CableEnd>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title:
                          TranslateText('Add new ODF:', language: widget.lang),
                      content: Column(
                        children: [
                          for (final CableEnd cableEnd in cableEndsList())
                            OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(cableEnd),
                                child: Text(cableEnd.direction))
                        ],
                      ));
                }).then((value) => widget.node.equipments!.add(value)),
            icon: const Icon(Icons.add),
            label: TranslateText('Add equipment', language: widget.lang)),
      ])),
    );
  }

  cableEndsList() {}
}
