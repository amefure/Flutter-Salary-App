import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/validation_utils.dart';
import 'package:salary/feature/auth/application/password_reset/password_reset_state.dart';
import 'package:salary/feature/auth/data/auth_repository_impl.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';

final passwordResetProvider = StateNotifierProvider.autoDispose<PasswordResetViewModel, PasswordResetState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return PasswordResetViewModel(ref, authRepository);
});

class PasswordResetViewModel extends StateNotifier<PasswordResetState> {

  PasswordResetViewModel(
      this._ref,
      this._authRepository,
      ) : super(PasswordResetState.initial());

  final Ref _ref;
  final AuthRepository _authRepository;

  Future<bool> sendResetMail() async {
    // 送信済み or 未入力なら終了
    if (state.isSend || !state.isCompleted) { return false; }
    return await _ref.runWithGlobalHandling(() async {
      await _authRepository.sendResetPassWordEmail(email: state.email);
      state = state.copyWith(
          isSend: true
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

  /// バリデーション(登録ボタンの活性判定に使用)
  /// バリデーションの通らない値はそもそも送信できない設計になっている
  bool _isAllValidation({
    String? email
  }) {
    final currentEmail = email ?? state.email;

    /// メールバリデーション
    final hasEmail =
        currentEmail.isNotEmpty &&
            ValidationUtils.isValidEmail(currentEmail);
    return hasEmail;
  }
}
