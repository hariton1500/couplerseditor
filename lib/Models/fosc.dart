import 'dart:convert';
import 'package:coupolerseditor/services/server.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:shared_preferences/shared_preferences.dart';
import '../Helpers/fibers.dart';
//import '../services/jsonbin_io.dart';
import 'cableend.dart';
import 'settings.dart';

class Connection {
  //List<int> connectionData = [];
  int cableIndex1, fiberNumber1, cableIndex2, fiberNumber2;
  Connection(
      {required this.cableIndex1,
      required this.fiberNumber1,
      required this.cableIndex2,
      required this.fiberNumber2}) {
    //connectionData = [cableIndex1, fiberNumber1, cableIndex2, fiberNumber2];
  }
  Map<String, dynamic> toJson() => {
        //'connectionData' : connectionData,
        'cableIndex1': cableIndex1,
        'cableIndex2': cableIndex2,
        'fiberNumber1': fiberNumber1,
        'fiberNumber2': fiberNumber2
      };
  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        cableIndex1: json["cableIndex1"],
        cableIndex2: json["cableIndex2"],
        fiberNumber1: json["fiberNumber1"],
        fiberNumber2: json["fiberNumber2"],
      );
}

class Mufta {
  String name = '';
  List<CableEnd> cableEnds = [];
  List<Connection> connections = [];
  ll.LatLng? location;
  String? key;

  Mufta({
    required this.name,
    required this.cableEnds,
    required this.connections,
    this.location,
  });

  @override
  String toString() {
    return 'Key: $key; Mufta: $name; cableEnds: $cableEnds; connections: $connections';
  }

  String signature() {
    //return '$name:${location?.latitude}:${location?.longitude}';
    return key ?? name + location.toString();
  }

  Mufta.fromJson(Map<String, dynamic> json) {
    print('loading Mufta from json:');
    //print(json);
    name = json['name'];
    cableEnds =
        List<CableEnd>.from(json['cables'].map((x) => CableEnd.fromJson(x)));
    connections = List<Connection>.from(
        json['connections'].map((x) => Connection.fromJson(x)));
    location = ll.LatLng.fromJson(json['location']);
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cables': cableEnds,
      'connections': connections,
      'location': location!.toJson(),
      'key': key
    };
  }

  void saveToLocal() async {
    for (var cableEnd in cableEnds) {
      cableEnd.location = location;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String jsonString = json.encode(toJson());
    print('saving to local: $jsonString');
    sharedPreferences.setString('coupler: ${key ?? name}', jsonString);
  }

  Function addConnection() {
    return (int cableIndex, int fiberNumber) {
      connections.add(Connection(
          cableIndex1: cableIndex,
          fiberNumber1: fiberNumber,
          cableIndex2: 0,
          fiberNumber2: 0));
    };
  }

  Future<bool> saveToServer() async {
    print('/////////saveToServer////////////');
    Settings settings = Settings();
    await settings.loadSettings();

    if (settings.altServer == '' ||
        settings.login == '' ||
        settings.password == '') {
      /*
      JsonbinIO server = JsonbinIO(settings: settings);
      await server.loadBins();
      print('current bins = ${server.bins}');
      String binId = key ?? signature().hashCode.toString();
      print('binId = $binId');
      if (!server.bins.containsKey(binId)) {
        print('creating new bin');
        key = binId;
        return await server.createJsonRecord(
            key: binId, jsonString: json.encode(toJson()), type: 'fosc');
      } else {
        print('updating bin $binId');
        return await server.updateJsonRecord(
            type: 'fosc',
            binId: server.bins[binId]['id'],
            jsonString: json.encode(toJson()));
      }*/
      return false;
    } else {
      Server server = Server(settings: settings);
      String type = 'fosc';
      Map<String, dynamic> data = toJson();
      if (key == null) {
        key = signature().hashCode.toString();
        return await server.add(key: key!, type: type, data: data);
      } else {
        return await server.edit(key: key!, type: type, data: data);
      }
    }
  }

  Widget show(
      BuildContext context, int? isCableSelected, num longestSideHeight) {
    return CustomPaint(
      //size: 500,
      painter: MuftaPainter(
          this, MediaQuery.of(context).size.width, isCableSelected ?? -1),
      //size: 500,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: longestSideHeight * 11 + 100,
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
    for (var cable in mufta.cableEnds) {
      var tpDirection = TextPainter(
          text: TextSpan(
              text: cable.direction,
              style: mufta.cableEnds.indexOf(cable) != selectedCableIndex
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
        if (mufta.cableEnds.indexOf(cable) == selectedCableIndex) {
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

      CableEnd cable1 = mufta.cableEnds[cableIndex1],
          cable2 = mufta.cableEnds[cableIndex2];
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
