
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/validation_utils.dart';
import 'package:salary/feature/auth/application/login/login_state.dart';

final loginProvider =
StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
  final authController = ref.read(authControllerProvider.notifier);
  return LoginViewModel(ref, authController);
});

class LoginViewModel extends StateNotifier<LoginState> {

  LoginViewModel(
      this._ref,
      this._authController,
      ) : super(LoginState.initial());

  final Ref _ref;
  final AuthController _authController;

  Future<void> login() async {
    await _ref.runWithGlobalHandling(() async {
      await _authController.login(
        email: state.email,
        password: state.password,
      );
    });
  }


  void updateEmail(String value) {
    final isCompleted = _isAllValidation(email: value);
    state = state.copyWith(
        email: value,
        isCompleted: isCompleted
    );
  }

  void updatePassWord(String value) {
    final isCompleted = _isAllValidation(password: value);
    state = state.copyWith(
        password: value,
        isCompleted: isCompleted
    );
  }


  /// バリデーション(登録ボタンの活性判定に使用)
  /// バリデーションの通らない値はそもそも送信できない設計になっている
  bool _isAllValidation({
    String? email,
    String? password,
  }) {
    final currentEmail = email ?? state.email;
    final currentPassword = password ?? state.password;

    /// メールバリデーション
    final hasEmail =
        currentEmail.isNotEmpty &&
            ValidationUtils.isValidEmail(currentEmail);

    /// パスワードバリデーション
    final hasPassword =
        currentPassword.isNotEmpty &&
            ValidationUtils.isValidPassword(currentPassword);
    return hasEmail && hasPassword;
  }
}
