
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/validation_utils.dart';
import 'package:salary/feature/auth/application/register_account/register_account_state.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';
import 'package:salary/core/config/profile_config.dart';

final registerAccountProvider =
StateNotifierProvider.autoDispose<RegisterAccountViewModel, RegisterAccountState>((ref) {
    final authController = ref.read(authControllerProvider.notifier);
    return RegisterAccountViewModel(ref, authController);
});

class RegisterAccountViewModel extends StateNotifier<RegisterAccountState> {

  RegisterAccountViewModel(
      this._ref,
      this._authController,
      ) : super(RegisterAccountState.initial());

  final Ref _ref;
  final AuthController _authController;

  Future<void> registerAccount() async {
    if (state.birthday == null) return;
    await _ref.runWithGlobalHandling(() async {
      // 成功すれば_authControllerのステータスが変化し、ログイン状態にUIも変わる
      await _authController.registerAccount(
        name: state.name,
        email: state.email,
        password: state.password,
        passwordConfirm: state.passwordConfirm,
        region: state.region,
        birthday: state.birthday!,
        job: state.job,
      );
    });
  }

  /// 日付表示用整形
  String displayDate(DateTime? date) {
    if (date == null) return ProfileConfig.undefined;
    return DateTimeUtils.format(dateTime: date, pattern: 'yyyy年M月d日');
  }

  void updateName(String value) {
    final isCompleted = _isAllValidation(name: value);
    state = state.copyWith(
        name: value,
        isCompleted: isCompleted
    );
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

  void updatePassWordConfirm(String value) {
    final isCompleted = _isAllValidation(passwordConfirm: value);
    state = state.copyWith(
        passwordConfirm: value,
        isCompleted: isCompleted
    );
  }

  void updateRegion(String value) {
    final isCompleted = _isAllValidation(region: value);
    state = state.copyWith(
        region: value,
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

  /// バリデーション(登録ボタンの活性判定に使用)
  /// バリデーションの通らない値はそもそも送信できない設計になっている
  bool _isAllValidation({
    String? name,
    String? email,
    String? password,
    String? passwordConfirm,
    String? region,
    DateTime? birthday,
    String? job,
  }) {
    final currentName = name ?? state.name;
    final currentEmail = email ?? state.email;
    final currentPassword = password ?? state.password;
    final currentPasswordConfirm = passwordConfirm ?? state.passwordConfirm;
    final currentRegion = region ?? state.region;
    final currentBirthday = birthday ?? state.birthday;
    final currentJob = job ?? state.job;

    /// アカウント名
    final hasName = currentName.isNotEmpty;

    /// メールバリデーション
    final hasEmail =
        currentEmail.isNotEmpty &&
            ValidationUtils.isValidEmail(currentEmail);

    /// パスワードバリデーション
    final hasPassword =
        currentPassword.isNotEmpty &&
            ValidationUtils.isValidPassword(currentPassword);

    /// パスワードバリデーション
    final hasPasswordConfirm =
        currentPasswordConfirm.isNotEmpty &&
            ValidationUtils.isValidPassword(currentPasswordConfirm) &&
            currentPassword == currentPasswordConfirm;

    final hasRegion = currentRegion != ProfileConfig.undefined;
    final hasBirthday = currentBirthday != null;
    final hasJob = currentJob != ProfileConfig.undefined;
    return hasName && hasEmail && hasPassword && hasPasswordConfirm && hasRegion && hasBirthday && hasJob;
  }

}
