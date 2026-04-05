import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/biometrics_service.dart';
import 'package:salary/core/repository/password_repository.dart';
import 'package:salary/feature/app_lock/app_lock_setting_state.dart';

final appLockSettingProvider =
StateNotifierProvider.autoDispose.family<AppLockSettingViewModel, AppLockSettingState, bool>((ref, isEntry) {
  final passwordRepository = ref.read(passwordRepositoryProvider);
  final biometricsService = BiometricsService();
  return AppLockSettingViewModel(isEntry, passwordRepository, biometricsService);
  },
);

class AppLockSettingViewModel extends StateNotifier<AppLockSettingState> {
  final bool _isEntry;
  final PasswordRepository _passwordRepository;
  final BiometricsService _biometricsService;

  /// 初期インスタンス化
  AppLockSettingViewModel(
      this._isEntry,
      this._passwordRepository,
      this._biometricsService
      ) : super(AppLockSettingState.initial()) {
    if (!_isEntry) {
      // 起動時に生体認証有効ユーザーには認証リクエスト
      executeBiometricsAuth();
    }
  }

  /// パスワード認証
  Future<void> executeInputPassword() async {
    /// 全て未入力なら処理終了
    if (!state.isInputComplete) return;
    String? storedPassword = await _passwordRepository.getPassword();
    String password = state.inputPassword.join('');

    /// 保存済みのパスワードと入力されたパスワードが一致しているかどうか
    final isAuthenticated = storedPassword == password;
    if (!isAuthenticated) {
      /// 認証失敗なら入力パスワードをリセット
      state = state.copyWith(
          inputPassword: List.empty(),
          isFailed: true
      );
    } else {
      /// 認証成功
      state = state.copyWith(
          isAuthenticated: isAuthenticated
      );
    }
  }

  void savePassword() async {
    /// 全て未入力なら処理終了
    if (!state.isInputComplete) return;
    String password = state.inputPassword.join('');
    await _passwordRepository.setPassword(password);
    /// 認証成功として流す
    state = state.copyWith(
        isAuthenticated: true
    );
  }

  void addPassword(String value) {
    /// 4桁入力済みなら終了
    if (state.isInputComplete) return;
    final newPassword = [...state.inputPassword, value];
    state = state.copyWith(
        inputPassword: newPassword
    );
  }

  void removeLast() {
    if (state.inputPassword.isEmpty) return;
    final removedPassword = [...state.inputPassword];
    removedPassword.removeLast();
    state = state.copyWith(
        inputPassword: removedPassword
    );
  }

  /// 生体認証
  Future<void> executeBiometricsAuth() async {
    bool isAuthenticated = await _biometricsService.authenticateWithBiometrics();
    if (!isAuthenticated) {
      /// 認証失敗なら入力パスワードをリセット
      state = state.copyWith(
          isFailed: true
      );
    } else {
      /// 認証成功
      state = state.copyWith(
          isAuthenticated: isAuthenticated
      );
    }
  }

  void resetIsFailed() {
    state = state.copyWith(
        isFailed: false
    );
  }
}
