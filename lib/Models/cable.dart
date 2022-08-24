import 'dart:convert';
import 'package:coupolerseditor/Models/cableend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cable {
  List<CableEnd> ends = [];

  Cable({required this.ends});

  Cable.fromJson(Map<String, dynamic> json) {
    ends = List<CableEnd>.from(json['ends'].map((x) => CableEnd.fromJson(x)));
  }

  Map<String, dynamic> toJson() => {
        'ends': ends,
      };

  String signature() {
    return '${ends[0].signature()}:${ends[1].signature()}';
  }

  void saveCable(bool isFromServer) async {
    if (isFromServer) {

    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cable: ${signature()}', jsonEncode(toJson()));
    }
  }

  Future<void> remove(bool isFromServer) async {
    if (isFromServer) {

    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('cable: ${signature()}');
    }
  }
}
