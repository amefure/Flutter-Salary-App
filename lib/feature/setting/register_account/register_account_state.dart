import 'package:salary/feature/setting/register_account/register_account_view.dart';

class RegisterAccountState {

  final String email;
  final String password;
  final String prefecture;
  final DateTime? birthday;
  final String job;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  const RegisterAccountState({
    required this.email,
    required this.password,
    required this.prefecture,
    required this.birthday,
    required this.job,
    this.isCompleted = false,
  });

  factory RegisterAccountState.initial() {
    return const RegisterAccountState(
      email: ProfileConfig.empty,
      password: ProfileConfig.empty,
      prefecture: ProfileConfig.undefined,
      birthday: null,
      job: ProfileConfig.undefined,
    );
  }

  RegisterAccountState copyWith({
    String? email,
    String? password,
    String? prefecture,
    DateTime? birthday,
    String? job,
    bool? isCompleted
  }) {
    return RegisterAccountState(
        email: email ?? this.email,
        password: password ?? this.password,
        prefecture: prefecture ?? this.prefecture,
        birthday: birthday ?? this.birthday,
        job: job ?? this.job,
        isCompleted: isCompleted ?? this.isCompleted
    );
  }
}
