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

  void saveCableToServer() async {}

  void saveCableToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cable: ${signature()}', jsonEncode(toJson()));
  }
}
