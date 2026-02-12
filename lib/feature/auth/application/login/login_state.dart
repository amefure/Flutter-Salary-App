import 'package:salary/feature/auth/presentation/register_account_screen.dart';

class LoginState {

  final String email;
  final String password;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  const LoginState({
    required this.email,
    required this.password,
    this.isCompleted = false,
  });

  factory LoginState.initial() {
    return const LoginState(
      email: 'test@example.com', //ProfileConfig.empty,
      password: 'password123', // ProfileConfig.empty,
    );
  }

  LoginState copyWith({
    String? email,
    String? password,
    bool? isCompleted,
  }) {
    return LoginState(
        email: email ?? this.email,
        password: password ?? this.password,
        isCompleted: isCompleted ?? this.isCompleted
    );
  }
}
