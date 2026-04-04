import 'package:salary/core/data_source/shared_preferences_data_source.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SharedPreferencesKeys {
  authUser('auth_user'),
  removeAds('removeAds'),
  premiumFeatureUnlocked('premiumFeatureUnlocked'),
  premiumFullUnlocked('premiumFullUnlocked'),
  themeMode('themeMode'),
  hasShownPremiumIntro('hasShownPremiumIntro'),
  hasShownPremiumTab('hasShownPremiumTab'),
  sortOrder('sortOrder');

  final String key;
  const SharedPreferencesKeys(this.key);
}

final userSettingsProvider = Provider((ref) {
  final repo = ref.watch(sharedPreferencesRepositoryProvider);
  return UserSettingsRepository(repo);
});

class UserSettingsRepository {
  final SharedPreferencesDataSource _dataSource;

  const UserSettingsRepository(this._dataSource);

  // --------------------------------------------------
  // 認証・ユーザー関連
  // --------------------------------------------------

  /// 認証ユーザー情報を保存
  Future<void> saveAuthUser(String value) async {
    await _dataSource.saveString(SharedPreferencesKeys.authUser, value);
  }

  /// 認証ユーザー情報を削除
  Future<void> clearAuthUser() async {
    await _dataSource.remove(SharedPreferencesKeys.authUser);
  }

  /// 認証ユーザー情報を取得
  String? fetchAuthUser() => _dataSource.getString(SharedPreferencesKeys.authUser);

  // --------------------------------------------------
  // 広告・プレミアム機能関連
  // --------------------------------------------------

  /// 広告非表示設定を保存
  Future<void> saveRemoveAds(bool value) async {
    await _dataSource.saveBool(SharedPreferencesKeys.removeAds, value);
  }

  /// 広告非表示設定を取得
  bool fetchRemoveAds() => _dataSource.getBool(SharedPreferencesKeys.removeAds);

  /// プレミアム機能（一部）のアンロック状態を保存
  Future<void> savePremiumFeatureUnlocked(bool value) async {
    await _dataSource.saveBool(SharedPreferencesKeys.premiumFeatureUnlocked, value);
  }

  /// プレミアム機能（一部）のアンロック状態を取得
  bool fetchPremiumFeatureUnlocked() =>
      _dataSource.getBool(SharedPreferencesKeys.premiumFeatureUnlocked);

  /// プレミアムプラン（全機能）のアンロック状態を保存
  Future<void> savePremiumFullUnlocked(bool value) async {
    await _dataSource.saveBool(SharedPreferencesKeys.premiumFullUnlocked, value);
  }

  /// プレミアムプラン（全機能）のアンロック状態を取得
  bool fetchPremiumFullUnlocked() =>
      _dataSource.getBool(SharedPreferencesKeys.premiumFullUnlocked);

  // --------------------------------------------------
  // アプリ設定（テーマ・表示）関連
  // --------------------------------------------------

  /// テーマモード（ダークモードかどうか）を保存
  Future<void> saveThemeMode(bool isDark) async {
    await _dataSource.saveBool(SharedPreferencesKeys.themeMode, isDark);
  }

  /// テーマモードを取得（未設定時はnull）
  bool? fetchThemeModeNullable() {
    return _dataSource.getBoolNullable(SharedPreferencesKeys.themeMode);
  }

  /// 並び順（ソート順）を保存
  Future<void> saveSortOrder(SalarySortOrder order) async {
    await _dataSource.saveString(SharedPreferencesKeys.sortOrder, order.label);
  }

  /// 並び順を取得（未設定時はデフォルト値を返す）
  SalarySortOrder fetchSortOrder() {
    final label = _dataSource.getString(SharedPreferencesKeys.sortOrder) ?? '';
    return SalarySortOrder.fromLabelWithDefault(label);
  }

  // --------------------------------------------------
  // オンボーディング・ガイド表示関連
  // --------------------------------------------------

  /// プレミアムプラン紹介ポップアップを表示済みか保存
  Future<void> saveHasShownPremiumIntro(bool value) async {
    await _dataSource.saveBool(SharedPreferencesKeys.hasShownPremiumIntro, value);
  }

  /// プレミアムプラン紹介ポップアップを表示済みか取得
  bool fetchHasShownPremiumIntro() {
    return _dataSource.getBool(SharedPreferencesKeys.hasShownPremiumIntro);
  }

  /// プレミアムタブを表示済みか保存
  Future<void> saveHasShownPremiumTab(bool value) async {
    await _dataSource.saveBool(SharedPreferencesKeys.hasShownPremiumTab, value);
  }

  /// プレミアムタブを表示済みか取得
  bool fetchHasShownPremiumTab() {
    return _dataSource.getBool(SharedPreferencesKeys.hasShownPremiumTab);
  }
}