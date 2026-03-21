import 'package:salary/core/config/profile_config.dart';

class RegisterAccountState {

  final String name;
  final String email;
  final String password;
  final String passwordConfirm;
  final String region;
  final DateTime? birthday;
  final Job job;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  const RegisterAccountState({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.region,
    required this.birthday,
    required this.job,
    this.isCompleted = false,
  });

  factory RegisterAccountState.initial() {
    return const RegisterAccountState(
      name: ProfileConfig.empty,
      email: ProfileConfig.empty,
      password: ProfileConfig.empty,
      passwordConfirm: ProfileConfig.empty,
      region: ProfileConfig.undefined,
      birthday: null,
      job: ProfileConfig.undefinedJob,
    );
  }

  RegisterAccountState copyWith({
    String? name,
    String? email,
    String? password,
    String? passwordConfirm,
    String? region,
    DateTime? birthday,
    Job? job,
    bool? isCompleted
  }) {
    return RegisterAccountState(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        passwordConfirm: passwordConfirm ?? this.passwordConfirm,
        region: region ?? this.region,
        birthday: birthday ?? this.birthday,
        job: job ?? this.job,
        isCompleted: isCompleted ?? this.isCompleted
    );
  }
}
