import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferencesKeys {
  userName('username');

  final String key;
  const SharedPreferencesKeys(this.key);
}

class SharedPreferencesRepository {
  static final SharedPreferencesRepository _instance =
      SharedPreferencesRepository._internal();
  factory SharedPreferencesRepository() => _instance;
  SharedPreferences? _prefs;

  SharedPreferencesRepository._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveString(SharedPreferencesKeys key, String value) async {
    _prefs?.setString(key.key, value);
  }

  String? getString(SharedPreferencesKeys key) {
    return _prefs?.getString(key.key);
  }

  Future<void> saveInt(SharedPreferencesKeys key, int value) async {
    _prefs?.setInt(key.key, value);
  }

  int? getInt(SharedPreferencesKeys key) {
    return _prefs?.getInt(key.key);
  }

  Future<void> remove(SharedPreferencesKeys key) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.remove(key.key);
  }

  Future<void> clearData() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.clear();
  }
}
