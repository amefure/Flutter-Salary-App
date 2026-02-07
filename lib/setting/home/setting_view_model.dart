

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/repository/password_service.dart';
import 'package:salary/setting/home/setting_state.dart';
import 'package:salary/utilities/logger.dart';

final settingProvider = StateNotifierProvider<SettingViewModel, SettingState>((ref) {
  return SettingViewModel(ref);
});

class SettingViewModel extends StateNotifier<SettingState> {

  final Ref ref;

  /// 初期インスタンス化
  SettingViewModel(this.ref)
      : super(const SettingState()) {
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    bool isEnabled = await PasswordService().isLockEnabled();
    logger('_loadLockState$isEnabled');
    state = state.copyWith(
      isAppLockEnabled: isEnabled
    );
  }

  void setAppLockEnabled(bool value) {
    logger('setAppLockEnabled$value');
    state = state.copyWith(isAppLockEnabled: value);
  }

  void resetPassword() {
    PasswordService().removePassword();
  }
}