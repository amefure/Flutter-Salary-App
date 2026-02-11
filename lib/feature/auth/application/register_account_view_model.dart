
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/auth/application/register_account_state.dart';
import 'package:salary/feature/auth/data/auth_repository_impl.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';
import 'package:salary/feature/auth/presentation/register_account_view.dart';

final registerAccountProvider =
StateNotifierProvider.autoDispose<RegisterAccountViewModel, RegisterAccountState>((ref) {
    final authRepository = ref.read(authRepositoryProvider);
    return RegisterAccountViewModel(ref, authRepository);
});

class RegisterAccountViewModel extends StateNotifier<RegisterAccountState> {

  RegisterAccountViewModel(this._ref, this._authRepository) : super(RegisterAccountState.initial());

  final Ref _ref;
  final AuthRepository _authRepository;

  Future<void> registerAccount() async {
    if (state.birthday == null) return;

    await _ref.runWithGlobalHandling(() async {
      await _authRepository.register(
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
            _isValidEmail(currentEmail);

    /// パスワードバリデーション
    final hasPassword =
        currentPassword.isNotEmpty &&
            _isValidPassword(currentPassword);

    /// パスワードバリデーション
    final hasPasswordConfirm =
        currentPasswordConfirm.isNotEmpty &&
            _isValidPassword(currentPasswordConfirm) &&
            currentPassword == currentPasswordConfirm;

    final hasRegion = currentRegion != ProfileConfig.undefined;
    final hasBirthday = currentBirthday != null;
    final hasJob = currentJob != ProfileConfig.undefined;
    return hasName && hasEmail && hasPassword && hasPasswordConfirm && hasRegion && hasBirthday && hasJob;
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
