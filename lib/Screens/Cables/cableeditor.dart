import 'package:coupolerseditor/Helpers/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import '../../Models/cable.dart';
import '../../Models/settings.dart';

class CableEditor extends StatefulWidget {
  const CableEditor(
      {Key? key,
      required this.cable,
      required this.settings,
      required this.isFromServer})
      : super(key: key);
  final Cable cable;
  final Settings settings;
  final bool isFromServer;

  @override
  State<CableEditor> createState() => _CableEditorState();
}

class _CableEditorState extends State<CableEditor> {
  LatLng? _point;
  bool isNetworkProcess = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              TranslateText(
                'Cable editor',
                language: widget.settings.language,
                size: 16,
              ),
              Text(widget.cable.toString()),
            ],
          ),
          actions: [
            _point != null
                ? Row(
                    children: [
                      /*
                      IconButton(
                          onPressed: () {
                            setState(() {
                              widget.cable.points.add(_point!);
                              print(widget.cable.points);
                              _point = null;
                            });
                          },
                          icon: const Icon(Icons.add_outlined)),
                      */
                      IconButton(
                          onPressed: () {
                            setState(() {
                              widget.cable.points.removeLast();
                              _point = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outlined)),
                    ],
                  )
                : Container(),
          ],
        ),
        body: FlutterMap(
          options: MapOptions(
            center: widget.cable.end1?.location,
            zoom: 16,
            maxZoom: 18,
            onTap: (tapPosition, point) {
              setState(() {
                _point = point;
                widget.cable.points.add(point);
              });
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            PolylineLayerOptions(
              polylines: widget.cable.polylines(color: Colors.green),
            ),
            MarkerLayerOptions(
                markers:
                    [widget.cable.end1!.location, widget.cable.end2!.location]
                        .map((e) => Marker(
                            width: 5,
                            height: 5,
                            point: e!,
                            builder: (context) => Container(
                                  color: Colors.red,
                                )))
                        .toList()),
            MarkerLayerOptions(
                markers: widget.cable.points
                    .map((e) => Marker(
                        point: e,
                        builder: (context) => Text(
                            (widget.cable.points.indexOf(e) + 1).toString())))
                    .toList())
          ],
        ),
        persistentFooterButtons: [
          TextButton.icon(
              onPressed: () {
                setState(() {
                  _point = null;
                  widget.cable.points.clear();
                });
              },
              icon: const Icon(Icons.delete_forever_outlined),
              label: TranslateText(
                'Delete all',
                language: widget.settings.language,
              )),
          TextButton.icon(
              onPressed: () async {
                setState(() {
                  isNetworkProcess = true;
                });
                if (await widget.cable.saveCable(widget.isFromServer)) {
                  setState(() {
                    isNetworkProcess = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: TranslateText('Saved',
                          language: widget.settings.language),
                      backgroundColor: Colors.green));
                } else {
                  setState(() {
                    isNetworkProcess = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: TranslateText('Not Saved',
                          language: widget.settings.language),
                      backgroundColor: Colors.red));
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: !isNetworkProcess
                  ? TranslateText(
                      'Save',
                      language: widget.settings.language,
                    )
                  : const CircularProgressIndicator.adaptive())
        ],
      ),
    );
  }
}
