import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/user_settings_repository.dart';

enum AppThemeMode {
  light,
  dark,
}

/// ライト / ダークモード変更
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier(
      this._userSettingsRepository,
      this._platformBrightness,
      ) : super(AppThemeMode.light) {
    _load();
  }

  final UserSettingsRepository _userSettingsRepository;
  final Brightness _platformBrightness;

  void _load() {
    final savedMode = _userSettingsRepository.fetchThemeModeNullable();

    // ユーザー設定があればそれを参照
    if (savedMode != null) {
      state = savedMode ? AppThemeMode.dark : AppThemeMode.light;
      return;
    }

    // ローカルがなければシステム準拠
    final isDark = _platformBrightness == Brightness.dark;
    state = isDark ? AppThemeMode.dark : AppThemeMode.light;
    // 次回以降のためにローカルに保存しておく
    _userSettingsRepository.saveThemeMode(isDark);
  }

  Future<void> toggle(bool isDark) async {
    state = isDark ? AppThemeMode.dark : AppThemeMode.light;
    await _userSettingsRepository.saveThemeMode(isDark);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final userSettings = ref.read(userSettingsProvider);
  final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  return ThemeModeNotifier(userSettings, brightness);
});
