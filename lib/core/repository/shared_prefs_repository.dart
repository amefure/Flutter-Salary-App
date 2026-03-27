import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SharedPreferencesKeys {
  removeAds('removeAds'),
  premiumFeatureUnlocked('premiumFeatureUnlocked'),
  premiumFullUnlocked('premiumFullUnlocked'),
  themeMode('themeMode'),
  hasShownPremiumIntro('hasShownPremiumIntro'),
  hasShownPremiumTab('hasShownPremiumTab');

  final String key;
  const SharedPreferencesKeys(this.key);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

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

  Future<void> savePremiumFeatureUnlocked(bool value) async {
    _repository.saveBool(SharedPreferencesKeys.premiumFeatureUnlocked, value);
  }

  bool fetchPremiumFeatureUnlocked() => _repository.getBool(SharedPreferencesKeys.premiumFeatureUnlocked);

  Future<void> savePremiumFullUnlocked(bool value) async {
    _repository.saveBool(SharedPreferencesKeys.premiumFullUnlocked, value);
  }

  bool fetchPremiumFullUnlocked() => _repository.getBool(SharedPreferencesKeys.premiumFullUnlocked);

  Future<void> saveThemeMode(bool isDark) async {
    _repository.saveBool(SharedPreferencesKeys.themeMode, isDark);
  }

  bool? fetchThemeModeNullable() {
    return _repository.getBoolNullable(SharedPreferencesKeys.themeMode);
  }

  /// プレミアムプラン紹介ポップアップを表示済みか保存
  Future<void> saveHasShownPremiumIntro(bool value) async {
    await _repository.saveBool(SharedPreferencesKeys.hasShownPremiumIntro, value);
  }

  /// プレミアムプラン紹介ポップアップを表示済みか取得
  bool fetchHasShownPremiumIntro() {
    return _repository.getBool(SharedPreferencesKeys.hasShownPremiumIntro);
  }

  /// プレミアムタブを表示済みか保存
  Future<void> saveHasShownPremiumTab(bool value) async {
    await _repository.saveBool(SharedPreferencesKeys.hasShownPremiumTab, value);
  }

  /// プレミアムタブを表示済みか取得
  bool fetchHasShownPremiumTab() {
    return _repository.getBool(SharedPreferencesKeys.hasShownPremiumTab);
  }
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

  bool? getBoolNullable(SharedPreferencesKeys key) {
    return _prefs?.getBool(key.key);
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
