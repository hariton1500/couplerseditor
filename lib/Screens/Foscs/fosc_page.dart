import 'package:coupolerseditor/Screens/fiberseditor.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../Models/fosc.dart';
import '../../Helpers/fibers.dart';
import '../../Helpers/strings.dart';
import '../../Models/cableend.dart';
import '../../Models/settings.dart';
import '../location_picker.dart';

class MuftaScreen extends StatefulWidget {
  const MuftaScreen(
      {Key? key,
      required this.mufta,
      //required this.callback,
      required this.settings})
      : super(key: key);
  final Mufta mufta;
  //final Function callback;
  final Settings settings;

  @override
  MuftaScreenState createState() => MuftaScreenState();
}

class MuftaScreenState extends State<MuftaScreen> {
  int? isCableSelected;
  int longestSideHeight = 10;
  bool isShowAddConnections = false;
  Settings settings = Settings();
  bool isNetworkProcess = false;
  bool isEditingAddress = false;
  bool isEditCableName = false;

  @override
  void initState() {
    super.initState();
    settings.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    int tmp0 = 0, tmp1 = 0;
    for (var cableEnd in widget.mufta.cableEnds) {
      cableEnd.sideIndex == 0
          ? tmp0 += cableEnd.fibersNumber
          : tmp1 += cableEnd.fibersNumber;
    }
    tmp0 >= tmp1 ? longestSideHeight = tmp0 : longestSideHeight = tmp1;
    //print('List of connections:');
    //for (var connection in widget.mufta.connections!) {print(connection.connectionData);}
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  TextButton.icon(onPressed: () {
                    setState(() {
                      isEditingAddress = true;
                    });
                  }, icon: const Icon(Icons.edit), label: TranslateText('Coupler name:', language: widget.settings.language)),
                  Text(widget.mufta.name, style: const TextStyle(fontSize: 10),)
                ],
              ),
              isEditingAddress
                  ? Wrap(
                    children: [
                      TextField(
                        autofocus: true,
                        controller: TextEditingController(text: widget.mufta.name),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          widget.mufta.name = value;
                          //isEdititingAddress = false;
                        },
                        onSubmitted: (value) => setState(() {
                          widget.mufta.name = value;
                          isEditingAddress = false;
                        }),
                        onEditingComplete: () => setState(() {
                          isEditingAddress = false;
                        }),
                      ),
                      IconButton(onPressed: () {
                        setState(() {
                          isEditingAddress = false;
                        });
                      }, icon: const Icon(Icons.done))
                    ],
                  )
                  : Container(),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LocationPicker(
                  startLocation: widget.mufta.location ??
                      widget.settings.baseLocation ??
                      ll.LatLng(0, 0),
                ))).then((value) => setState(() {
                  widget.mufta.location = value ??
                      widget.mufta.location ??
                      widget.settings.baseLocation ??
                      ll.LatLng(0, 0);
                  for (var cableEnd in widget.mufta.cableEnds) {
                    cableEnd.location = widget.mufta.location;
                  }
                })),
                label: Wrap(
                children: [
                  TranslateText(
                    'Location:',
                      language: widget.settings.language,
                    ),
                    Text(
                        (widget.mufta.location != null
                            ? widget.mufta.location!
                            .toJson()['coordinates']
                            .toString()
                            : ''),
                        style: const TextStyle(fontSize: 10)),
                ],
              )),
              const Divider(),
              GestureDetector(
                onTapDown: (details) {
                  int index = widget.mufta.cableEnds.indexWhere((cable) {
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
                child: widget.mufta
                    .show(context, isCableSelected, longestSideHeight),
              ),
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  (isCableSelected ?? -1) > -1 &&
                          widget.mufta.cableEnds[isCableSelected!].fiberComments
                              .where((comment) => comment != '')
                              .toList()
                              .isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TranslateText(
                              'Fibers with comments and spliters:',
                              language: widget.settings.language),
                        )
                      : Container(),
                  (isCableSelected == null || isCableSelected == -1)
                      ? Container()
                      : Column(
                          children: [
                            Column(
                              children: widget.mufta.cableEnds[isCableSelected!]
                                  .fiberComments
                                  .where((comment) => comment != '')
                                  .toList()
                                  .map((comment) => Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                                '[${widget.mufta.cableEnds[isCableSelected!].fiberComments.indexOf(comment) + 1}]: '),
                                          ),
                                          Text(comment),
                                        ],
                                      ))
                                  .toList(),
                            ),
                            Column(
                              children: widget
                                  .mufta.cableEnds[isCableSelected!].spliters
                                  .where((spliter) => spliter != 0)
                                  .map((spliter) => Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                                '[${widget.mufta.cableEnds[isCableSelected!].spliters.indexOf(spliter) + 1}]: '),
                                          ),
                                          Row(
                                            children: [
                                              TranslateText('Spliter of ',
                                                  language:
                                                      widget.settings.language),
                                              Text('$spliter'),
                                            ],
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            )
                          ],
                        ),
                  TextButton.icon(
                      onPressed: () {
                        showDialog<CableEnd>(
                            context: context,
                            builder: (BuildContext context) {
                              String cableName = '';
                              int fibersNumber = 1;
                              String colorScheme =
                                  fiberColors.keys.toList().first;
                              List<DropdownMenuItem<int>> fibersList = fibers
                                  .map((e) => DropdownMenuItem<int>(
                                        value: e,
                                        child: Text(e.toString()),
                                      ))
                                  .toList();
                              return StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: TranslateText('Adding of cable',
                                      language: widget.settings.language),
                                  content: Column(
                                    children: [
                                      TranslateText('Direction:',
                                          language: widget.settings.language),
                                      TextField(
                                        keyboardType: TextInputType.text,
                                        onChanged: (text) {
                                          cableName = text;
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TranslateText(
                                            'Number of Fibers:',
                                            language: widget.settings.language),
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
                                        language: widget.settings.language,
                                      ),
                                      Column(
                                          children: fiberColors.entries
                                              .map(
                                                (e) => RadioListTile<String>(
                                                    title: Text(e.key),
                                                    subtitle: Wrap(
                                                      children: e.value
                                                          .map((color) =>
                                                              Container(
                                                                width: 5,
                                                                height: 15,
                                                                color: color,
                                                              ))
                                                          .toList(),
                                                    ),
                                                    value: e.key,
                                                    groupValue: colorScheme,
                                                    onChanged: (a) => setState(
                                                        () =>
                                                            colorScheme = a!)),
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
                                            language:
                                                widget.settings.language)),
                                    OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(CableEnd(
                                            direction: cableName,
                                            fibersNumber: fibersNumber,
                                            sideIndex: 0,
                                            colorScheme: colorScheme,
                                            id: DateTime.now().microsecondsSinceEpoch.hashCode,
                                          ));
                                        },
                                        child: TranslateText('Add',
                                            language: widget.settings.language))
                                  ],
                                );
                              });
                            }).then((value) => setState(() {
                              if (value != null) {
                                value.location = widget.mufta.location;
                                widget.mufta.cableEnds.add(value);
                              }
                            }));
                      },
                      icon: const Icon(Icons.add_outlined),
                      label: TranslateText('Add cable',
                          language: widget.settings.language)),
                  isCableSelected != null && isCableSelected! >= 0
                      ? Wrap(
                          children: [
                            TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (widget.mufta.cableEnds[isCableSelected!]
                                            .sideIndex ==
                                        0) {
                                      widget.mufta.cableEnds[isCableSelected!]
                                          .sideIndex = 1;
                                    } else {
                                      widget.mufta.cableEnds[isCableSelected!]
                                          .sideIndex = 0;
                                    }
                                  });
                                },
                                icon: const Icon(Icons.change_circle_outlined),
                                label: TranslateText('Change side',
                                    language: widget.settings.language)),
                            TextButton.icon(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      CableEnd cableEnd = widget
                                          .mufta.cableEnds[isCableSelected!];
                                      return FibersEditor(
                                          lang: widget.settings.language,
                                          cableEnd: cableEnd);
                                    }).then((value) => setState(() {})),
                                icon: const Icon(Icons.edit_rounded),
                                label: TranslateText('Edit/View fibers',
                                    language: widget.settings.language))
                          ],
                        )
                      : Container(),
                  isCableSelected != null && isCableSelected! >= 0
                      ? Wrap(
                        children: [
                          TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  widget.mufta.connections
                                      .removeWhere((connection) {
                                    return (connection.cableIndex1 ==
                                            isCableSelected ||
                                        connection.cableIndex2 == isCableSelected);
                                  });
                                  widget.mufta.cableEnds.removeAt(isCableSelected!);
                                  isCableSelected = -1;
                                });
                              },
                              icon: const Icon(Icons.remove_outlined),
                              label: TranslateText('Delete cable',
                                  language: widget.settings.language)),
                          TextButton.icon(onPressed: () {
                            setState(() {
                              isEditCableName = true;
                            });
                          }, icon: const Icon(Icons.edit_outlined), label: TranslateText('Edit cable name', language: widget.settings.language)),
                          if (isEditCableName) ... [
                            TextField(
                              autofocus: true,
                              controller: TextEditingController(text: widget.mufta.cableEnds[isCableSelected!].direction),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                widget.mufta.cableEnds[isCableSelected!].direction = value;
                                //isEdititingAddress = false;
                              },
                              onSubmitted: (value) => setState(() {
                                widget.mufta.cableEnds[isCableSelected!].direction = value;
                                isEditCableName = false;
                              }),
                              onEditingComplete: () => setState(() {
                                isEditCableName = false;
                              }),
                            ),
                            IconButton(onPressed: () {
                              setState(() {
                                isEditCableName = false;
                              });
                            }, icon: const Icon(Icons.done))
                          ]
                        ],
                      )
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
                                          widget.mufta.cableEnds[cableIndex1]
                                              .fibersNumber,
                                          (index) => DropdownMenuItem(
                                              value: index + 1,
                                              child: TranslateText(
                                                  (index + 1).toString())));
                                  List<DropdownMenuItem<int>> fibers2 =
                                      List.generate(
                                          widget.mufta.cableEnds[cableIndex2]
                                              .fibersNumber,
                                          (index) => DropdownMenuItem(
                                              value: index + 1,
                                              child: TranslateText(
                                                  (index + 1).toString())));
                                  //print(fibers2.length);
                                  List<DropdownMenuItem<int>> cables =
                                      List.generate(
                                          widget.mufta.cableEnds.length,
                                          (index) => DropdownMenuItem(
                                              value: index,
                                              child: TranslateText(widget
                                                  .mufta
                                                  .cableEnds[index]
                                                  .direction)));
                                  return StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    //print(cableIndex2);
                                    fibers2 = List.generate(
                                        widget.mufta.cableEnds[cableIndex2]
                                            .fibersNumber,
                                        (index) => DropdownMenuItem(
                                            value: index + 1,
                                            child: TranslateText(
                                                (index + 1).toString())));
                                    return AlertDialog(
                                      title: TranslateText('Add connection',
                                          language: widget.settings.language),
                                      content: Column(
                                        children: [
                                          TranslateText('From:',
                                              language:
                                                  widget.settings.language),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TranslateText(widget
                                                  .mufta
                                                  .cableEnds[cableIndex1]
                                                  .direction),
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
                                                language:
                                                    widget.settings.language)),
                                        OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(
                                                  Connection(
                                                      cableIndex1: cableIndex1,
                                                      fiberNumber1:
                                                          fiberNumber1 - 1,
                                                      cableIndex2: cableIndex2,
                                                      fiberNumber2:
                                                          fiberNumber2 - 1));
                                            },
                                            child: TranslateText('Add',
                                                language:
                                                    widget.settings.language))
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
                              language: widget.settings.language))
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
                              language: widget.settings.language))
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
                              language: widget.settings.language),
                        )
                      : Container(),
                ],
              ),
              if (isShowAddConnections) ...[
                Column(children: [
                  //TranslateText('Add connections', language: widget.settings.language),
                  Column(
                    children: List.generate(
                        widget.mufta.cableEnds.length,
                        (cableIndex) => Column(
                              children: [
                                Text(
                                    '${widget.mufta.cableEnds[cableIndex].direction}:'),
                                Wrap(
                                  children: List.generate(
                                      widget.mufta.cableEnds[cableIndex]
                                          .fibersNumber,
                                      (fiber) => Draggable<Map<int, int>>(
                                          data: {cableIndex: fiber},
                                          childWhenDragging: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: fiberColors[widget
                                                      .mufta
                                                      .cableEnds[cableIndex]
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
                                                child: Text(
                                                    (fiber + 1).toString())),
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
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        shape: BoxShape.circle,
                                                        color: fiberColors[widget
                                                                .mufta
                                                                .cableEnds[
                                                                    cableIndex]
                                                                .colorScheme]![
                                                            fiber]),
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                60) /
                                                            12,
                                                    height:
                                                        (MediaQuery.of(context)
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
                                                                        .cableEnds[
                                                                            cableIndex]
                                                                        .colorScheme]![fiber] ==
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
              widget.mufta.cableEnds.isNotEmpty && widget.mufta.location != null
                  ? Wrap(
                      children: [
                        TextButton.icon(
                            onPressed: () => widget.mufta.saveToLocal(),
                            icon: const Icon(Icons.save_outlined),
                            label: TranslateText('Save to Local Device',
                                language: settings.language)),
                        !isNetworkProcess
                            ? TextButton.icon(
                                onPressed: () async {
                                  setState(() {
                                    isNetworkProcess = true;
                                  });
                                  widget.mufta.saveToServer().then((value) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: TranslateText(
                                          value ? 'Saved' : 'Not Saved'),
                                      backgroundColor:
                                          value ? Colors.green : Colors.red,
                                    ));
                                    setState(() {
                                      isNetworkProcess = false;
                                    });
                                  });
                                },
                                icon: const Icon(Icons.save_outlined),
                                label: TranslateText('Save to Server',
                                    language: settings.language))
                            : const CircularProgressIndicator.adaptive()
                      ],
                    )
                  : Container(),
              Row(
                children: [
                  TextButton.icon(
                      onPressed: () {
                        //widget.callback();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_outlined),
                      label: TranslateText('Back',
                          language: widget.settings.language))
                ],
              ),
              isCableSelected != null && isCableSelected! >= 0
                  ? Column(
                      children: widget.mufta.connections
                          .where((element) =>
                              element.cableIndex1 == isCableSelected ||
                              element.cableIndex2 == isCableSelected)
                          .map((c) => ListTile(
                                dense: true,
                                //mainAxisAlignment: MainAxisAlignment.start,
                                //children: [
                                leading: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.mufta.connections.remove(c);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                title: Text(
                                  '${widget.mufta.cableEnds[c.cableIndex1].direction}[${c.fiberNumber1 + 1}] <--> ${widget.mufta.cableEnds[c.cableIndex2].direction}[${c.fiberNumber2 + 1}]',
                                  maxLines: 2,
                                ),
                                //],
                              ))
                          .toList(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Function addConnection() {
    return () {
      //print('add connection');
    };
  }
}

Future<List<String>> loadNames() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getKeys().toList();
}

Future<String> loadMuftaJson(String json) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(json) ?? '';
}
