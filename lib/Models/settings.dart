import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  String couplersListUrl = '', couplerUrl = '', language = 'en';

  Future loadSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    couplersListUrl = shared.getString('couplersListUrl') ?? '';
    couplerUrl = shared.getString('couplerUrl') ?? '';
    language = shared.getString('language') ?? 'en';
  }

  void saveSettings() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('couplersListUrl', couplersListUrl);
    shared.setString('couplerUrl', couplerUrl);
    shared.setString('language', language);
  }
}
