import 'dart:convert';

import 'package:coupolerseditor/Models/settings.dart';
import 'package:http/http.dart';

class JsonbinIO {
  String url = 'https://api.jsonbin.io/v3/b';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  final Settings settings; // = Settings()..loadSettings();
  Map<String, dynamic> bins = {};

  JsonbinIO({required this.settings}) {
    headers['X-Master-key'] = settings.xMasterKey;
    headers['X-Collection-Id'] = settings.collectionId;
    //settings.loadSettings();
    loadBins();
  }

  Future<void> loadBins() async {
    print('loading bins list');
    try {
      var response = await get(
          Uri.parse('$url/${settings.binsMapId}?meta=false'),
          headers: headers);
      if (response.statusCode == 200) {
        print(response.body);
        bins = json.decode(response.body);
        print(bins);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> saveBin({required String id, required String hash}) async {
    print('saving bins list');
    try {
      await loadBins();
      bins[hash] = id;
      var response = await put(Uri.parse('$url/${settings.binsMapId}'),
          headers: headers, body: json.encode(bins));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createJsonRecord(
      {required String name, required String jsonString}) async {
    try {
      headers['X-Bin-Name'] = name;
      var response =
          await post(Uri.parse(url), headers: headers, body: jsonString);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        print('record created.');
        print(json.decode(response.body));
        String id = (json.decode(response.body)
            as Map<String, dynamic>)['metadata']['id'];
        print('id = $id');
        return await saveBin(hash: name, id: id);
      } else {
        return false;
      }
    } catch (e) {
      //throw Exception(e);
      return false;
    }
  }

  Future<bool> updateJsonRecord(
      {required String binId, required String jsonString}) async {
    try {
      var response = await put(Uri.parse('$url/$binId'),
          headers: headers, body: jsonString);
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
