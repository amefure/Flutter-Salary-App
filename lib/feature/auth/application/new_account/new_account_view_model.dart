import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/validation_utils.dart';
import 'package:salary/feature/auth/application/new_account/new_account_state.dart';

final newAccountProvider =
StateNotifierProvider.autoDispose<NewAccountViewModel, NewAccountState>((ref) {
  final authProvider = ref.read(authStateProvider.notifier);
  return NewAccountViewModel(ref, authProvider);
});

class NewAccountViewModel extends StateNotifier<NewAccountState> {

  NewAccountViewModel(
      this._ref,
      this._authProvider,
      ) : super(NewAccountState.initial());

  final Ref _ref;
  final AuthStateNotifier _authProvider;

  Future<bool> registerSendEmail() async {
    // 送信済み or 未入力なら終了
    if (state.isSend || !state.isCompleted) { return false; }
    return await _ref.runWithGlobalHandling(() async {
      await _authProvider.registerSendEmail(
        email: state.email,
      );
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
  bool _isAllValidation({String? email}) {
    final currentEmail = email ?? state.email;
    /// メールバリデーション
    final hasEmail =
        currentEmail.isNotEmpty &&
            ValidationUtils.isValidEmail(currentEmail);
    return hasEmail;
  }
}
