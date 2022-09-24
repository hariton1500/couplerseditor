import 'dart:convert';
import 'package:coupolerseditor/Models/settings.dart';
import 'package:http/http.dart';

class Server {
  final Settings settings;
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String url = '';

  Server({required this.settings}) {
    headers['login'] = settings.login;
    headers['password'] = settings.password;
    url = settings.altServer;
  }

  Future<bool> add(
      {required String key,
      required String type,
      required Map<String, dynamic> data,
      required List<String> fields}) async {
    try {
      Map<String, dynamic> body = {'name': data['name']};
      for (var field in fields) {
        body[field] = data[field];
      }
      var response = await post(Uri.parse('$url$type/add.php'), body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> edit(
      {required String key,
      required String type,
      required Map<String, dynamic> data,
      required List<String> fields}) async {
    try {
      Map<String, dynamic> body = {'name': data['name']};
      for (var field in fields) {
        body[field] = data[field];
      }
      var response =
          await put(Uri.parse('$url$type/put.php?name=$key'), body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
