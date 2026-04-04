import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final sharedPreferencesRepositoryProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesDataSource(prefs);
});

abstract class ISharedPreferencesDataSource {
  Future<void> saveString(SharedPreferencesKeys key, String value);
  String? getString(SharedPreferencesKeys key);
  Future<void> saveInt(SharedPreferencesKeys key, int value);
  int? getInt(SharedPreferencesKeys key);
  Future<void> saveBool(SharedPreferencesKeys key, bool value);
  bool getBool(SharedPreferencesKeys key);
  bool? getBoolNullable(SharedPreferencesKeys key);
  Future<void> remove(SharedPreferencesKeys key);
  Future<void> clearData();
}

class SharedPreferencesDataSource implements ISharedPreferencesDataSource {

  final SharedPreferences _prefs;
  SharedPreferencesDataSource(this._prefs);

  @override
  Future<void> saveString(SharedPreferencesKeys key, String value) async {
    _prefs.setString(key.key, value);
  }

  @override
  String? getString(SharedPreferencesKeys key) {
    return _prefs.getString(key.key);
  }

  @override
  Future<void> saveInt(SharedPreferencesKeys key, int value) async {
    _prefs.setInt(key.key, value);
  }

  @override
  int? getInt(SharedPreferencesKeys key) {
    return _prefs.getInt(key.key);
  }

  @override
  Future<void> saveBool(SharedPreferencesKeys key, bool value) async {
    _prefs.setBool(key.key, value);
  }

  @override
  bool getBool(SharedPreferencesKeys key) {
    return _prefs.getBool(key.key) ?? false;
  }

  @override
  bool? getBoolNullable(SharedPreferencesKeys key) {
    return _prefs.getBool(key.key);
  }

  @override
  Future<void> remove(SharedPreferencesKeys key) async {
    await _prefs.remove(key.key);
  }

  @override
  Future<void> clearData() async {
    await _prefs.clear();
  }
}
