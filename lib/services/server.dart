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
      required Map<String, dynamic> data}) async {
    print('server.add($url$type/add.php?key=$key)');
    data['key'] = key;
    try {
      var response = await post(Uri.parse('$url$type/add.php?key=$key'),
          headers: headers, body: json.encode(data));
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
      required Map<String, dynamic> data}) async {
    print('server.edit($url$type/put.php?key=$key');
    try {
      var response = await put(Uri.parse('$url$type/put.php?key=$key'),
          headers: headers, body: json.encode(data));
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
