import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  String couplersListUrl = '', couplerUrl = '', language = 'en';
  String nodesListUrl = '', nodeUrl = '';

  Future loadSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    couplersListUrl = shared.getString('couplersListUrl') ?? '';
    couplerUrl = shared.getString('couplerUrl') ?? '';
    nodesListUrl = shared.getString('nodesListUrl') ?? '';
    nodeUrl = shared.getString('nodeUrl') ?? '';
    language = shared.getString('language') ?? 'en';
  }

  void saveSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('couplersListUrl', couplersListUrl);
    shared.setString('couplerUrl', couplerUrl);
    shared.setString('nodesListUrl', nodesListUrl);
    shared.setString('nodeUrl', nodeUrl);
    shared.setString('language', language);
  }
}
