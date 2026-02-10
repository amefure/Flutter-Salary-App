
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/auth/application/register_account_state.dart';
import 'package:salary/feature/auth/presentation/register_account_view.dart';

final registerAccountProvider =
StateNotifierProvider.autoDispose<RegisterAccountViewModel, RegisterAccountState>(
      (ref) => RegisterAccountViewModel(),
);

class RegisterAccountViewModel extends StateNotifier<RegisterAccountState> {

  RegisterAccountViewModel() : super(RegisterAccountState.initial());

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

  void updatePrefecture(String value) {
    final isCompleted = _isAllValidation(prefecture: value);
    state = state.copyWith(
        prefecture: value,
        isCompleted: isCompleted
    );
  }

  void updateBirthday(DateTime value) {
    final isCompleted = _isAllValidation(birthday: value);
    state = state.copyWith(
        birthday: value,
        isCompleted: isCompleted
    );
  }

  void updateJob(String value) {
    final isCompleted = _isAllValidation(job: value);
    state = state.copyWith(
        job: value,
        isCompleted: isCompleted
    );
  }

  /// バリデーション
  bool _isAllValidation({
    String? email,
    String? password,
    String? prefecture,
    DateTime? birthday,
    String? job,
  }) {
    final currentEmail = email ?? state.email;
    final currentPassword = password ?? state.password;
    final currentPrefecture = prefecture ?? state.prefecture;
    final currentBirthday = birthday ?? state.birthday;
    final currentJob = job ?? state.job;

    /// メールバリデーション
    final hasEmail =
        currentEmail.isNotEmpty &&
            _isValidEmail(currentEmail);

    /// パスワードバリデーション
    final hasPassword =
        currentPassword.isNotEmpty &&
            _isValidPassword(currentPassword);

    final hasPrefecture = currentPrefecture != ProfileConfig.undefined;
    final hasBirthday = currentBirthday != null;
    final hasJob = currentJob != ProfileConfig.undefined;
    return hasEmail && hasPassword && hasPrefecture && hasBirthday && hasJob;
  }

  /// 空でない
  ///  @ と . を含む（正規表現）
  ///  先頭・末尾に空白がない
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );
    return emailRegExp.hasMatch(email);
  }

  /// 空でない
  /// 8文字以上
  /// 英数字混在（最低限）
  bool _isValidPassword(String password) {
    if (password.length < 8) return false;

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    return hasLetter && hasNumber;
  }

}
