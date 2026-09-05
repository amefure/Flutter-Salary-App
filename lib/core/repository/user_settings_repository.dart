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
  sortOrder('sortOrder'),

  /// 通知の有効状態
  reminderEnabled('reminderEnabled'),

  /// 通知日（例: 25日なら 25）
  reminderDay('reminderDay'),

  /// 通知メッセージ
  reminderMessage('reminderMessage'),

  /// 通知する「時」（0〜23）
  reminderHour('reminderHour'),

  /// 通知する「分」（0〜59）
  reminderMinute('reminderMinute'),

  /// レビューをすでにリクエスト済みか
  hasRequestedReview('hasRequestedReview'),

  /// 給料データの累計登録回数
  salaryRegistrationCount('salaryRegistrationCount');

  final String key;
  const SharedPreferencesKeys(this.key);
}

final userSettingsProvider = Provider((ref) {
  final repo = ref.watch(sharedPreferencesRepositoryProvider);
  return UserSettingsRepository(repo);
});

class UserSettingsRepository {
  final ISharedPreferencesDataSource _dataSource;

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
  String? fetchAuthUser() =>
      _dataSource.getString(SharedPreferencesKeys.authUser);

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
    await _dataSource.saveBool(
      SharedPreferencesKeys.premiumFeatureUnlocked,
      value,
    );
  }

  /// プレミアム機能（一部）のアンロック状態を取得
  bool fetchPremiumFeatureUnlocked() =>
      _dataSource.getBool(SharedPreferencesKeys.premiumFeatureUnlocked);

  /// プレミアムプラン（全機能）のアンロック状態を保存
  Future<void> savePremiumFullUnlocked(bool value) async {
    await _dataSource.saveBool(
      SharedPreferencesKeys.premiumFullUnlocked,
      value,
    );
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
    await _dataSource.saveBool(
      SharedPreferencesKeys.hasShownPremiumIntro,
      value,
    );
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

  // --------------------------------------------------
  // リマインダー設定関連
  // --------------------------------------------------

  /// 通知の有効状態を保存
  Future<void> saveReminderEnabled(bool enabled) async {
    await _dataSource.saveBool(SharedPreferencesKeys.reminderEnabled, enabled);
  }

  /// 通知の有効状態を取得（未設定時はデフォルトでtrueを返す）
  bool fetchReminderEnabled() {
    return _dataSource.getBoolNullable(SharedPreferencesKeys.reminderEnabled) ??
        true;
  }

  /// 通知日を保存
  Future<void> saveReminderDay(int day) async {
    await _dataSource.saveInt(SharedPreferencesKeys.reminderDay, day);
  }

  /// 通知日を取得（未設定時はデフォルトで25日を返す）
  int fetchReminderDay() {
    return _dataSource.getInt(SharedPreferencesKeys.reminderDay) ?? 25;
  }

  /// 通知メッセージを保存
  Future<void> saveReminderMessage(String message) async {
    await _dataSource.saveString(
      SharedPreferencesKeys.reminderMessage,
      message,
    );
  }

  /// 通知メッセージを取得（未設定時はデフォルトメッセージを返す）
  String fetchReminderMessage() {
    return _dataSource.getString(SharedPreferencesKeys.reminderMessage) ??
        '今月の給料データがまだ入力されていません。入力しましょう！';
  }

  Future<void> saveReminderHour(int hour) async {
    await _dataSource.saveInt(SharedPreferencesKeys.reminderHour, hour);
  }

  int fetchReminderHour() {
    return _dataSource.getInt(SharedPreferencesKeys.reminderHour) ?? 19;
  }

  Future<void> saveReminderMinute(int minute) async {
    await _dataSource.saveInt(SharedPreferencesKeys.reminderMinute, minute);
  }

  int fetchReminderMinute() {
    return _dataSource.getInt(SharedPreferencesKeys.reminderMinute) ?? 0;
  }

  Future<void> saveHasRequestedReview(bool value) async {
    await _dataSource.saveBool(SharedPreferencesKeys.hasRequestedReview, value);
  }

  bool fetchHasRequestedReview() {
    return _dataSource.getBool(SharedPreferencesKeys.hasRequestedReview);
  }

  Future<void> saveSalaryRegistrationCount(int count) async {
    await _dataSource.saveInt(SharedPreferencesKeys.salaryRegistrationCount, count);
  }

  int fetchSalaryRegistrationCount() {
    return _dataSource.getInt(SharedPreferencesKeys.salaryRegistrationCount) ?? 0;
  }
}
