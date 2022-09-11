import 'dart:convert';

import 'package:coupolerseditor/services/keys.dart';
import 'package:http/http.dart';

class JsonbinIO {
  //String key = keys['jsonbin_io']!['X-Master-Key']!;
  String collectionId = keys['jsonbin_io']!['collectionId']!;
  String url = 'https://api.jsonbin.io/v3/b';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-Master-key': keys['jsonbin_io']!['X-Master-Key']!,
    'X-Collection-Id': keys['jsonbin_io']!['collectionId']!,
  };

  String binlistId = '631e2315e13e6063dca44944';

  Map<String, dynamic> bins = {};

  Future<void> loadBins() async {
    print('loading bins list');
    try {
      var response =
          await get(Uri.parse('$url/$binlistId?meta=false'), headers: headers);
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
      var response = await put(Uri.parse('$url/$binlistId'),
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

  Future<bool> updateJsonRecord() {}
}
