import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferencesKeys {
  removeAds('removeAds');

  final String key;
  const SharedPreferencesKeys(this.key);
}

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
  SharedPreferencesService._internal();
  factory SharedPreferencesService() => _instance;

  SharedPreferencesService._internal();

  late final _SharedPreferencesRepository _repository;

  Future<void> init() async {
    _repository = _SharedPreferencesRepository();
    _repository.init();
  }

  Future<void> saveRemoveAds(bool value) async {
    _repository.saveBool(SharedPreferencesKeys.removeAds, value);
  }

  bool fetchRemoveAds() => _repository.getBool(SharedPreferencesKeys.removeAds);
}

/// シングルトン設計
/// ```
/// // 普通にインスタンス化するだけでシングルトンになる
/// final repository = RealmRepository();
/// ```
class _SharedPreferencesRepository {
  static final _SharedPreferencesRepository _instance =
  _SharedPreferencesRepository._internal();
  factory _SharedPreferencesRepository() => _instance;
  SharedPreferences? _prefs;

  _SharedPreferencesRepository._internal();

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

  Future<void> saveBool(SharedPreferencesKeys key, bool value) async {
    _prefs?.setBool(key.key, value);
  }

  bool getBool(SharedPreferencesKeys key) {
    return _prefs?.getBool(key.key) ?? false;
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
