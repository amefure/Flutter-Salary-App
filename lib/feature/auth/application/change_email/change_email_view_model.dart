import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/validation_utils.dart';
import 'package:salary/feature/auth/application/change_email/change_email_state.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';

final changeEmailProvider =
StateNotifierProvider.autoDispose<ChangeEmailViewModel, ChangeEmailState>((ref) {
  final authProvider = ref.read(authStateProvider.notifier);
  final viewModel = ChangeEmailViewModel(ref, authProvider);
  Future.microtask(() {
    // build完了後に最新のユーザー情報を取得
    viewModel._fetchRefreshUser();
  });
  return viewModel;
});

class ChangeEmailViewModel extends StateNotifier<ChangeEmailState> {

  ChangeEmailViewModel(
      this._ref,
      this._authProvider,
      ) : super(ChangeEmailState.initial());

  final Ref _ref;
  final AuthStateNotifier _authProvider;

  Future<bool> requestChangeEmail() async {
    return await _ref.runWithGlobalHandling(() async {
      await _authProvider.changeEmail(
        newEmail: state.newEmail,
        password: state.password,
      );
    });
  }

  Future<void> _setUpUserInfo(AuthUser? initialUser) async {
    state = state.copyWith(
      oldEmail: initialUser?.email,
    );
  }

  Future<void> _fetchRefreshUser() async {
    await _ref.runWithGlobalHandling(() async {
      final user = await _authProvider.fetchUser();
      _setUpUserInfo(user);
    });
  }

  void updateEmail(String value) {
    final isCompleted = _isAllValidation(email: value);
    state = state.copyWith(
        newEmail: value,
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
    final currentEmail = email ?? state.newEmail;
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
