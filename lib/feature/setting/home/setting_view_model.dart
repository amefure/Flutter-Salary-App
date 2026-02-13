import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/repository/password_service.dart';
import 'package:salary/feature/setting/home/setting_state.dart';
import 'package:salary/core/utils/logger.dart';

final settingProvider = StateNotifierProvider<SettingViewModel, SettingState>((ref) {
  final authController = ref.read(authControllerProvider.notifier);
  return SettingViewModel(ref, authController);
});

class SettingViewModel extends StateNotifier<SettingState> {

  final Ref _ref;
  final AuthController _authController;

  /// 初期インスタンス化
  SettingViewModel(
      this._ref,
      this._authController
      ) : super(const SettingState()) {
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

  Future<bool> logout() async {
    return await _ref.runWithGlobalHandling(() async {
      await _authController.logout();
    });
  }

  Future<bool> withdrawal() async {
    return await _ref.runWithGlobalHandling(() async {
      await _authController.withdrawal();
    });
  }

}