import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../Helpers/fibercolors.dart';
import '../Helpers/strings.dart';
import '../Models/mainmodels.dart';
import 'location_picker.dart';

class MuftaScreen extends StatefulWidget {
  const MuftaScreen(
      {Key? key,
      required this.mufta,
      required this.callback,
      required this.lang})
      : super(key: key);
  final Mufta mufta;
  final Function callback;
  final String lang;

  @override
  MuftaScreenState createState() => MuftaScreenState();
}

class MuftaScreenState extends State<MuftaScreen> {
  int? isCableSelected;
  int longestSideHeight = 10;
  bool isShowAddConnections = false;
  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    settings.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    int tmp0 = 0, tmp1 = 0;
    for (var cable in widget.mufta.cables) {
      cable.sideIndex == 0
          ? tmp0 += cable.fibersNumber
          : tmp1 += cable.fibersNumber;
    }
    tmp0 >= tmp1 ? longestSideHeight = tmp0 : longestSideHeight = tmp1;
    //print('List of connections:');
    //for (var connection in widget.mufta.connections!) {print(connection.connectionData);}
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TranslateText('Coupler name:', language: widget.lang),
              TextButton(
                  onPressed: () {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          String name = '';
                          return AlertDialog(
                            title: TranslateText('Name editing',
                                language: widget.lang),
                            content: TextField(
                              onChanged: (text) => name = text,
                            ),
                            actions: [
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context, name);
                                  },
                                  child: TranslateText('Ok',
                                      language: widget.lang))
                            ],
                          );
                        }).then((value) {
                      setState(() {
                        widget.mufta.name = value ?? '';
                      });
                    });
                  },
                  child: Text(widget.mufta.name == '' ? 'NoName' : widget.mufta.name, softWrap: true, maxLines: 2,)
                ),
            ],
          ),
          TextButton(
              onPressed: () => showDialog<ll.LatLng>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: TranslateText(
                        'Location Picker',
                        language: widget.lang,
                      ),
                      content: const LocationPicker(),
                    );
                  }).then((value) => setState(() {
                    widget.mufta.location = value;
                  })),
              child: Row(
                children: [
                  TranslateText(
                    'Location:',
                    language: widget.lang,
                  ),
                  Text((widget.mufta.location != null
                      ? widget.mufta.location!
                          .toJson()['coordinates']
                          .toString()
                      : ''))
                ],
              )),
          GestureDetector(
            onTapDown: (details) {
              //print(details.localPosition);
              //print(widget.mufta.cables!.length);
              int index = widget.mufta.cables.indexWhere((cable) {
                double x = cable.sideIndex == 0
                    ? 50
                    : MediaQuery.of(context).size.width - 60;
                if (details.localPosition.dx >= x - 40 &&
                    details.localPosition.dx <= x + 40 &&
                    details.localPosition.dy >=
                        cable.fiberPosY.values.first - 20 &&
                    details.localPosition.dy <=
                        cable.fiberPosY.values.last + 10) {
                  return true;
                } else {
                  return false;
                }
              });
              //print('taped on cable index = $index');
              setState(() {
                isCableSelected = index;
              });
            },
            child: CustomPaint(
              //size: 500,
              painter: MuftaPainter(widget.mufta,
                  MediaQuery.of(context).size.width, isCableSelected ?? -1),
              //size: 500,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: longestSideHeight * 11 + 100,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: () {
                    showDialog<CableEnd>(
                        context: context,
                        builder: (BuildContext context) {
                          String cableName = '';
                          int fibersNumber = 1;
                          String colorScheme = fiberColors.keys.toList().first;
                          List<DropdownMenuItem<int>> fibersList =
                              [1, 2, 4, 8, 12, 16, 20, 24]
                                  .map((e) => DropdownMenuItem<int>(
                                        value: e,
                                        child: Text(e.toString()),
                                      ))
                                  .toList();
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: TranslateText('Adding of cable',
                                  language: widget.lang),
                              content: Column(
                                children: [
                                  TranslateText('Direction:',
                                      language: widget.lang),
                                  TextField(
                                    keyboardType: TextInputType.text,
                                    onChanged: (text) {
                                      cableName = text;
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
                                                onChanged: (a) => setState(
                                                    () => colorScheme = a!)),
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
                                          direction: cableName,
                                          fibersNumber: fibersNumber,
                                          sideIndex: 0,
                                          colorScheme: colorScheme,
                                          fiberComments: []));
                                    },
                                    child: TranslateText('Add',
                                        language: widget.lang))
                              ],
                            );
                          });
                        }).then((value) => setState(() {
                          if (value != null) widget.mufta.cables.add(value);
                        }));
                  },
                  icon: const Icon(Icons.add_outlined),
                  label: TranslateText('Add cable', language: widget.lang)),
              isCableSelected != null && isCableSelected! >= 0
                  ? Row(
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (widget.mufta.cables[isCableSelected!]
                                        .sideIndex ==
                                    0) {
                                  widget.mufta.cables[isCableSelected!]
                                      .sideIndex = 1;
                                } else {
                                  widget.mufta.cables[isCableSelected!]
                                      .sideIndex = 0;
                                }
                              });
                            },
                            icon: const Icon(Icons.change_circle_outlined),
                            label: TranslateText('Change side',
                                language: widget.lang)),
                        TextButton.icon(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  CableEnd cableEnd =
                                      widget.mufta.cables[isCableSelected!];
                                  return AlertDialog(
                                    title: TranslateText(
                                        'Edit / View fiber comments:',
                                        language: widget.lang),
                                    actions: [
                                      OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Ok'))
                                    ],
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: List.generate(
                                                cableEnd.fibersNumber,
                                                (index) => Text(
                                                    '[${index + 1}]: ${cableEnd.fiberComments[index]}')),
                                          ),
                                          Column(
                                            children: List.generate(
                                                cableEnd.fibersNumber,
                                                (index) => Row(
                                                      children: [
                                                        Text('[${index + 1}]'),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4 *
                                                              2,
                                                          child: TextField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            onChanged:
                                                                ((value) =>
                                                                    setState(
                                                                        () {
                                                                      cableEnd.fiberComments[
                                                                              index] =
                                                                          value;
                                                                    })),
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            icon: const Icon(Icons.edit_rounded),
                            label: TranslateText('Edit/View fibers',
                                language: widget.lang))
                      ],
                    )
                  : Container(),
              isCableSelected != null && isCableSelected! >= 0
                  ? TextButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.mufta.connections.removeWhere((connection) {
                            return (connection.cableIndex1 == isCableSelected ||
                                connection.cableIndex2 == isCableSelected);
                          });
                          widget.mufta.cables.removeAt(isCableSelected!);
                          isCableSelected = -1;
                        });
                      },
                      icon: const Icon(Icons.remove_outlined),
                      label:
                          TranslateText('Delete cable', language: widget.lang))
                  : Container(),
            ],
          ),
          Wrap(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.start,
            children: [
              isCableSelected != null && isCableSelected! >= 0
                  ? TextButton.icon(
                      onPressed: () {
                        showDialog<Connection>(
                            context: context,
                            builder: (BuildContext context) {
                              int cableIndex1 = isCableSelected!,
                                  fiberNumber1 = 1,
                                  cableIndex2 = 0,
                                  fiberNumber2 = 1;
                              List<DropdownMenuItem<int>> fibers1 =
                                  List.generate(
                                      widget.mufta.cables[cableIndex1]
                                          .fibersNumber,
                                      (index) => DropdownMenuItem(
                                          value: index + 1,
                                          child: TranslateText(
                                              (index + 1).toString())));
                              List<DropdownMenuItem<int>> fibers2 =
                                  List.generate(
                                      widget.mufta.cables[cableIndex2]
                                          .fibersNumber,
                                      (index) => DropdownMenuItem(
                                          value: index + 1,
                                          child: TranslateText(
                                              (index + 1).toString())));
                              //print(fibers2.length);
                              List<DropdownMenuItem<int>> cables =
                                  List.generate(
                                      widget.mufta.cables.length,
                                      (index) => DropdownMenuItem(
                                          value: index,
                                          child: TranslateText(widget
                                              .mufta.cables[index].direction)));
                              return StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                //print(cableIndex2);
                                fibers2 = List.generate(
                                    widget
                                        .mufta.cables[cableIndex2].fibersNumber,
                                    (index) => DropdownMenuItem(
                                        value: index + 1,
                                        child: TranslateText(
                                            (index + 1).toString())));
                                return AlertDialog(
                                  title: TranslateText('Add connection',
                                      language: widget.lang),
                                  content: Column(
                                    children: [
                                      TranslateText('From:',
                                          language: widget.lang),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TranslateText(widget.mufta
                                              .cables[cableIndex1].direction),
                                          DropdownButton<int>(
                                            value: fiberNumber1,
                                            items: fibers1,
                                            onChanged: (item) {
                                              setState(() {
                                                fiberNumber1 = item!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      TranslateText('To:'),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          DropdownButton<int>(
                                            value: cableIndex2,
                                            items: cables,
                                            onChanged: (item) {
                                              setState(() {
                                                cableIndex2 = item!;
                                              });
                                            },
                                          ),
                                          DropdownButton<int>(
                                            value: fiberNumber2,
                                            items: fibers2,
                                            onChanged: (item) {
                                              setState(() {
                                                fiberNumber2 = item!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
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
                                          Navigator.of(context).pop(Connection(
                                              cableIndex1: cableIndex1,
                                              fiberNumber1: fiberNumber1 - 1,
                                              cableIndex2: cableIndex2,
                                              fiberNumber2: fiberNumber2 - 1));
                                        },
                                        child: TranslateText('Add',
                                            language: widget.lang))
                                  ],
                                );
                              });
                            }).then((value) => setState(() {
                              if (value != null) {
                                widget.mufta.connections.add(value);
                              }
                            }));
                      },
                      icon: const Icon(Icons.add_outlined),
                      label: TranslateText('Add connection',
                          language: widget.lang))
                  : Container(),
              isCableSelected != null && isCableSelected! >= 0
                  ? TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isShowAddConnections = !isShowAddConnections;
                        });
                      },
                      icon: const Icon(Icons.add_box_outlined),
                      label: TranslateText('Add connections',
                          language: widget.lang))
                  : Container(),
              widget.mufta.connections.isNotEmpty
                  ? TextButton.icon(
                      icon: const Icon(Icons.delete_forever_outlined),
                      onPressed: () {
                        setState(() {
                          widget.mufta.connections.clear();
                        });
                      },
                      label: TranslateText('Delete all connections',
                          language: widget.lang),
                    )
                  : Container(),
            ],
          ),
          if (isShowAddConnections) ...[
            Column(children: [
              //TranslateText('Add connections', language: widget.lang),
              Column(
                children: List.generate(
                    widget.mufta.cables.length,
                    (cableIndex) => Column(
                          children: [
                            Text(
                                '${widget.mufta.cables[cableIndex].direction}:'),
                            Wrap(
                              children: List.generate(
                                  widget.mufta.cables[cableIndex].fibersNumber,
                                  (fiber) => Draggable<Map<int, int>>(
                                      data: {cableIndex: fiber},
                                      childWhenDragging: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: fiberColors[widget
                                                  .mufta
                                                  .cables[cableIndex]
                                                  .colorScheme]![fiber],
                                              shape: BoxShape.circle),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12,
                                          /*
                                          color: fiberColors[widget
                                              .mufta
                                              .cables[cableIndex]
                                              .colorScheme]![fiber],*/
                                        ),
                                      ),
                                      feedback: Material(
                                        child: Center(
                                            child:
                                                Text((fiber + 1).toString())),
                                      ),
                                      child: DragTarget<Map<int, int>>(
                                        onWillAccept: (data) => true,
                                        onAccept: (data) => setState(() {
                                          //print('target: $cableIndex : $fiber, source: $data');
                                          setState(() {
                                            widget.mufta.connections.add(
                                                Connection(
                                                    cableIndex1:
                                                        data.keys.first,
                                                    fiberNumber1:
                                                        data.values.first,
                                                    cableIndex2: cableIndex,
                                                    fiberNumber2: fiber));
                                          });
                                        }),
                                        builder: (context, candidateData,
                                            rejectedData) {
                                          return Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    shape: BoxShape.circle,
                                                    color: fiberColors[widget
                                                        .mufta
                                                        .cables[cableIndex]
                                                        .colorScheme]![fiber]),
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        60) /
                                                    12,
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        60) /
                                                    12,
                                                child: Center(
                                                  child: Text(
                                                    (fiber + 1).toString(),
                                                    style: TextStyle(
                                                        color: fiberColors[widget
                                                                        .mufta
                                                                        .cables[
                                                                            cableIndex]
                                                                        .colorScheme]![
                                                                    fiber] ==
                                                                Colors.black
                                                            ? Colors.white
                                                            : Colors.black),
                                                  ),
                                                )),
                                          );
                                        },
                                      ))),
                            ),
                          ],
                        )),
              )
            ])
          ],
          Row(
            children: [
              widget.mufta.cables.isNotEmpty
                  ? TextButton.icon(
                      onPressed: () {
                        var variants = const [
                          'to Device',
                          'to billing software (json)',
                        ]
                            .map((e) => DropdownMenuItem<String>(
                                value: e, child: TranslateText(e)))
                            .toList();
                        String exportVariant = variants.first.value!;
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: TranslateText('Export',
                                      language: widget.lang),
                                  content: Column(
                                    children: [
                                      DropdownButton<String>(
                                          value: exportVariant,
                                          items: variants,
                                          onChanged: (variant) {
                                            setState(() {
                                              exportVariant = variant!;
                                            });
                                          }),
                                      exportVariant == variants[0].value
                                          ? Column(
                                            children: [
                                              const Text(
                                                  'exporting device:'),
                                              TranslateText(widget.mufta.name, language: widget.lang)
                                            ],
                                          )
                                          : Container(),
                                      exportVariant == variants[1].value
                                          ? Column(
                                            children: [
                                              const Text(
                                                  'exporting to:'),
                                              TranslateText(settings.couplerUrl, language: widget.lang)
                                            ],
                                          )
                                          : Container()
                                    ],
                                  ),
                                  actions: [
                                    OutlinedButton(
                                        onPressed: () {
                                          if (exportVariant ==
                                              variants[0].value) {
                                            widget.mufta.saveToLocal();
                                          }
                                          Navigator.of(context)
                                              .pop(exportVariant);
                                        },
                                        child: TranslateText('Export'))
                                  ],
                                );
                              });
                            }).then((value) => print(value));
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: TranslateText('Export', language: widget.lang))
                  : Container(),
              TextButton.icon(
                  onPressed: () {
                    //super.widget.callback;
                    //print('call back');
                    widget.callback();
                  },
                  icon: const Icon(Icons.arrow_back_outlined),
                  label: TranslateText('Back', language: widget.lang))
            ],
          ),
          isCableSelected != null && isCableSelected! >= 0
              ? Column(
                  children: widget.mufta.connections
                      .where((element) =>
                          element.cableIndex1 == isCableSelected ||
                          element.cableIndex2 == isCableSelected)
                      .map((c) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 40,
                              ),
                              TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      widget.mufta.connections.remove(c);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: TranslateText('Delete')),
                              Text(
                                  '${widget.mufta.cables[c.cableIndex1].direction}[${c.fiberNumber1 + 1}] <--> ${widget.mufta.cables[c.cableIndex2].direction}[${c.fiberNumber2 + 1}]', maxLines: 2,),
                            ],
                          ))
                      .toList(),
                )
              : Container(),
        ],
      ),
    );
  }
}

class MuftaPainter extends CustomPainter {
  final Mufta mufta;
  final double width;
  final int selectedCableIndex;
  MuftaPainter(this.mufta, this.width, this.selectedCableIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.strokeWidth = 2;
    double wd = width - 60;
    double st = 50;

    double yPos0 = 20, yPos1 = 20;
    for (var cable in mufta.cables) {
      var tpDirection = TextPainter(
          text: TextSpan(
              text: cable.direction,
              style: mufta.cables.indexOf(cable) != selectedCableIndex
                  ? const TextStyle(fontSize: 10, color: Colors.black)
                  : const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      tpDirection.layout();
      if (cable.sideIndex == 0) {
        tpDirection.paint(canvas, Offset(st - 30, yPos0 - 17));
      } else {
        tpDirection.paint(canvas, Offset(wd - 25, yPos1 - 17));
      }

      for (var i = 0; i < cable.fibersNumber; i++) {
        TextStyle ts = const TextStyle(fontSize: 10);
        if (mufta.cables.indexOf(cable) == selectedCableIndex) {
          ts = ts.copyWith(color: Colors.red);
          ts = ts.copyWith(fontWeight: FontWeight.bold);
          //print('printing bold');
        } else {
          ts = ts.copyWith(color: Colors.black);
        }
        var tp = TextPainter(
            text: TextSpan(text: '${i + 1}', style: ts),
            textDirection: TextDirection.ltr);
        tp.layout();
        if (cable.sideIndex == 0) {
          tp.paint(canvas, Offset(st - 12, yPos0 - 7));
        } else {
          tp.paint(canvas, Offset(wd + 17, yPos1 - 7));
        }
        paint.color = fiberColors[cable.colorScheme]![i];
        if (cable.sideIndex == 0) {
          canvas.drawLine(Offset(st, yPos0), Offset(st + 10, yPos0), paint);
          cable.fiberPosY[i] = yPos0;
          yPos0 += 11;
        } else {
          canvas.drawLine(Offset(wd, yPos1), Offset(wd + 10, yPos1), paint);
          cable.fiberPosY[i] = yPos1;
          yPos1 += 11;
        }
      }

      if (cable.sideIndex == 0) {
        yPos0 += 22;
      } else {
        yPos1 += 22;
      }
    }

    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;

    for (var connection in mufta.connections) {
      //List<int> conList = connection.connectionData;

      int cableIndex1 = connection.cableIndex1;
      int cableIndex2 = connection.cableIndex2;
      int fiberNumber1 = connection.fiberNumber1;
      int fiberNumber2 = connection.fiberNumber2;

      CableEnd cable1 = mufta.cables[cableIndex1],
          cable2 = mufta.cables[cableIndex2];
      if (cable1.sideIndex != cable2.sideIndex) {
        canvas.drawLine(
            Offset(cable1.sideIndex == 0 ? st + 10 : wd,
                cable1.fiberPosY[fiberNumber1]!),
            Offset(cable2.sideIndex == 0 ? st + 10 : wd,
                cable2.fiberPosY[fiberNumber2]!),
            paint);
      } else {
        Path path = Path();
        path.moveTo(cable1.sideIndex == 0 ? st + 10 : wd,
            cable1.fiberPosY[fiberNumber1]!);
        path.arcToPoint(
            Offset(cable2.sideIndex == 0 ? st + 10 : wd,
                cable2.fiberPosY[fiberNumber2]!),
            radius: const Radius.elliptical(20, 10),
            clockwise: cable2.sideIndex == 0 &&
                cable1.fiberPosY[fiberNumber1]! <
                    cable2.fiberPosY[fiberNumber2]!);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Future<List<String>> loadNames() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getKeys().toList();
}

Future<String> loadMuftaJson(String json) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(json) ?? '';
}
