import 'package:shared_preferences/shared_preferences.dart';

class BookPreferences {
  final SharedPreferences _prefs;
  static const String _wifiOnlyKey = 'wifi_only_downloads';

  BookPreferences(this._prefs);

  bool get wifiOnlyDownloads => _prefs.getBool(_wifiOnlyKey) ?? true;

  Future<void> setWifiOnlyDownloads(bool value) async {
    await _prefs.setBool(_wifiOnlyKey, value);
  }

  Future<void> loadPreferences() async {
  }
}