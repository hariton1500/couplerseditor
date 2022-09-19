
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import '../Models/cable.dart';

class CableEditor extends StatefulWidget {
  const CableEditor({Key? key, required this.cable}) : super(key: key);
  final Cable cable;

  @override
  State<CableEditor> createState() => _CableEditorState();
}

class _CableEditorState extends State<CableEditor> {

  LatLng? _point;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cable.toString()),
        actions: [
          _point != null ? Row(
            children: [
              IconButton(onPressed: () {
                setState(() {
                  widget.cable.points.add(_point!);
                  print(widget.cable.points);
                  _point = null;
                });
              }, icon: const Icon(Icons.add_outlined)),
              IconButton(onPressed: () {
                setState(() {
                  _point = null;
                });
              }, icon: const Icon(Icons.delete_outlined)),
            ],
          ) : Container(),
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
            });
          },
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(
            polylines: widget.cable.polylines(),
          ),
        ],
      ),
    );
  }
}