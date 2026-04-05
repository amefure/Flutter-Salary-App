import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/repository/password_repository.dart';
import 'package:salary/feature/settings/setting_state.dart';
import 'package:salary/core/utils/logger.dart';

final settingProvider = StateNotifierProvider<SettingViewModel, SettingState>((ref) {
  final authProvider = ref.read(authStateProvider.notifier);
  final passwordRepository = ref.read(passwordRepositoryProvider);
  return SettingViewModel(ref, authProvider, passwordRepository);
});

class SettingViewModel extends StateNotifier<SettingState> {

  final Ref _ref;
  final AuthStateNotifier _authProvider;
  final PasswordRepository _passwordRepository;

  /// 初期インスタンス化
  SettingViewModel(
      this._ref,
      this._authProvider,
      this._passwordRepository
      ) : super(const SettingState()) {
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    bool isEnabled = await _passwordRepository.isLockEnabled();
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
    _passwordRepository.removePassword();
  }

  Future<bool> logout() async {
    return await _ref.runWithGlobalHandling(() async {
      await _authProvider.logout();
    });
  }

  Future<bool> withdrawal() async {
    return await _ref.runWithGlobalHandling(() async {
      await _authProvider.withdrawal();
    });
  }

}