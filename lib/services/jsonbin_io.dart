import 'dart:convert';
import 'package:coupolerseditor/Models/settings.dart';
import 'package:http/http.dart';

class JsonbinIO {
  String url = '';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  final Settings settings; // = Settings()..loadSettings();
  Map<String, dynamic> bins = {};

  JsonbinIO({required this.settings}) {
    headers['X-Master-key'] = settings.xMasterKey;
    headers['X-Collection-Id'] = settings.collectionId;
    //headers['X-Access-Key'] = settings.xAccessKey;
    url = settings.baseUrl;
  }

  Future<void> loadBins() async {
    print('loading bins list');
    try {
      var response = await get(
          Uri.parse('$url/${settings.binsMapId}?meta=false'),
          headers: headers);
      if (response.statusCode == 200) {
        //print(response.body);
        bins = json.decode(response.body);
        //print(bins);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> loadDataFromBin({required String binId}) async {
    print('loading data from bin = $binId');
    try {
      //print('headers = $headers');
      var response =
          await get(Uri.parse('$url/$binId?meta=false'), headers: headers);
      //print(response.body);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<bool> saveBin(
      {required String id, required String hash, required String type}) async {
    print('saving bins list');
    try {
      await loadBins();
      bins[hash] = {'id': id, 'type': type};
      var response = await put(Uri.parse('$url/${settings.binsMapId}'),
          headers: headers, body: json.encode(bins));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createJsonRecord(
      {required String key,
      required String jsonString,
      required String type}) async {
    try {
      headers['X-Bin-Name'] = key;
      if (settings.altServer != '') {
        post(Uri.parse('${settings.altServer}$type/add.php'), body: jsonString)
            .then((altResp) {
          print(altResp.statusCode);
          print(altResp.body);
        });
      }
      var response =
          await post(Uri.parse(url), headers: headers, body: jsonString);
      //print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        print('record created.');
        //print(json.decode(response.body));
        String id = (json.decode(response.body)
            as Map<String, dynamic>)['metadata']['id'];
        print('id = $id');
        return await saveBin(hash: key, id: id, type: type);
      } else {
        return false;
      }
    } catch (e) {
      //throw Exception(e);
      return false;
    }
  }

  Future<bool> updateJsonRecord(
      {required String binId,
      required String jsonString,
      required String type}) async {
    try {
      if (settings.altServer != '') {
        put(Uri.parse('${settings.altServer}$type/?id=$binId'),
                body: jsonString)
            .then((altResp) {
          print(altResp.statusCode);
          print(altResp.body);
        });
      }
      var response = await put(Uri.parse('$url/$binId'),
          headers: headers, body: jsonString);
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
