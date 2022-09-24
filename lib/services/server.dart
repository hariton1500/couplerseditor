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
    print('server.add($url$type/add.php?name=$key)');
    try {
      Map<String, dynamic> body = {'name': key};
      for (var field in fields) {
        body[field] = data[field];
      }
      var response = await post(Uri.parse('$url$type/add.php?name=$key'),
          headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        print(response.statusCode);
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
    print('server.edit()');
    try {
      Map<String, dynamic> body = {'name': data['name']};
      for (var field in fields) {
        body[field] = data[field];
      }
      var response = await put(Uri.parse('$url$type/put.php?name=$key'),
          headers: headers, body: json.encode(body));
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

  Future<String> list(
      {required String type, Map<String, dynamic>? filter}) async {
    try {
      if (filter != null) headers['filter'] = json.encode(filter);
      var response =
          await get(Uri.parse('$url$type/get.php'), headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print(e);
    }
    return '';
  }
}
