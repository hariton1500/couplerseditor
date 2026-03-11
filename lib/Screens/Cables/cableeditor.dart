import 'package:coupolerseditor/Helpers/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../Helpers/enums.dart';
import '../../Helpers/epsg3395.dart';
import '../../Helpers/map.dart';
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
  MapSource mapSource = MapSource.openstreet;

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
              Text(
                () {
                  if (widget.cable.distance() < 1) {
                    return '${(widget.cable.distance() * 1000).round()} m';
                  } else {
                    return '${widget.cable.distance().toStringAsFixed(3)} km';
                  }
                }(),
                style: const TextStyle(color: Colors.black),
              ),
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
        body: map(),
        persistentFooterButtons: [
          TextButton.icon(
              onPressed: () {
                setState(() {
                  _point = null;
                  widget.cable.points.clear();
                  widget.cable.points.add(widget.cable.end1!.location!);
                  widget.cable.points.add(widget.cable.end2!.location!);
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

  List<Widget> listActions() {
    return MapSource.values
        .map((e) => TextButton(
              onPressed: () => setState(() {
                mapSource = e;
              }),
              child: Text(e.name),
            ))
        .toList();
  }

  final MapController _mapController = MapController();

  Widget map() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            //controller: _mapController,
            crs: mapSource == MapSource.yandexsat
                ? epsg3395()
                : const Epsg3857(),
            initialCenter: widget.cable.end1?.location ?? const LatLng(0, 0),
            initialZoom: 16,
            maxZoom: 18,
            onTap: (tapPosition, point) {
              setState(() {
                _point = point;
                bool found = false;
                for (var i = 0; i < widget.cable.points.length - 1; i++) {
                  print([
                    widget.cable.points[i],
                    point,
                    widget.cable.points[i + 1]
                  ]);
                  if (point.latitude < widget.cable.points[i].latitude &&
                      point.latitude > widget.cable.points[i + 1].latitude &&
                      point.longitude > widget.cable.points[i].longitude &&
                      point.longitude < widget.cable.points[i + 1].longitude) {
                    print('between $i and ${i + 1}');
                    widget.cable.points.insert(i + 1, point);
                    found = true;
                    break;
                  }
                }
                if (!found) {
                  widget.cable.points
                      .insert(widget.cable.points.length - 1, point);
                }
              });
            },
          ),
          children: [
            layerMap(mapSource),
            PolylineLayer(
              polylines: widget.cable.polylines(color: Colors.green),
            ),
            MarkerLayer(
                markers: [
              widget.cable.end1!.location,
              widget.cable.end2!.location
            ]
                    .map((e) => Marker(
                        width: 5,
                        height: 5,
                        point: e!,
                        child: Container(
                          color: Colors.red,
                        )))
                    .toList()),
            MarkerLayer(
                markers: widget.cable.points
                    .map((e) => Marker(
                        point: e,
                        child: Text(
                            (widget.cable.points.indexOf(e) + 1).toString())))
                    .toList()),
            MarkerLayer(
                markers: widget.cable.points
                    .map((e) => Marker(
                        width: 10,
                        height: 10,
                        point: e,
                        child: Draggable(
                          onDragUpdate: (details) => setState(() {
                            final index = widget.cable.points
                                .indexWhere((element) => element == e);
                            if (index < 0) return;
                            final current = widget.cable.points[index];
                            final latDelta = details.delta.dy /
                                200000 /
                                18 *
                                _mapController.camera.zoom;
                            final lonDelta = details.delta.dx /
                                200000 /
                                18 *
                                _mapController.camera.zoom;
                            widget.cable.points[index] = LatLng(
                              current.latitude - latDelta,
                              current.longitude + lonDelta,
                            );
                          }),
                          feedback: Material(
                            child: Container(
                              color: Colors.red,
                            ),
                          ),
                          child: Container(
                            color: Colors.green,
                          ),
                        )))
                    .toList())
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Row(children: listActions()),
        )
      ],
    );
  }
}
