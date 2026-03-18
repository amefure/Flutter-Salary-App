
class ChangeEmailState {

  final String oldEmail;
  final String newEmail;
  final String password;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  const ChangeEmailState({
    required this.oldEmail,
    required this.newEmail,
    required this.password,
    this.isCompleted = false,
  });

  factory ChangeEmailState.initial() {
    return const ChangeEmailState(
      oldEmail: 'test@example.com', //ProfileConfig.empty,
      newEmail: 'test@example.com', //ProfileConfig.empty,
      password: 'password123', // ProfileConfig.empty,
    );
  }

  ChangeEmailState copyWith({
    String? oldEmail,
    String? newEmail,
    String? password,
    bool? isCompleted,
  }) {
    return ChangeEmailState(
        oldEmail: oldEmail ?? this.oldEmail,
        newEmail: newEmail ?? this.newEmail,
        password: password ?? this.password,
        isCompleted: isCompleted ?? this.isCompleted
    );
  }
}
