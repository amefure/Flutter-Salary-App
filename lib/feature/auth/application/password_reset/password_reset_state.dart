
class PasswordResetState {

  final String email;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  /// 入力ボックスの入力完了フラグ
  final bool isSend;

  const PasswordResetState({
    required this.email,
    this.isCompleted = false,
    this.isSend = false
  });

  factory PasswordResetState.initial() {
    return const PasswordResetState(
      email: 'test@example.com', //ProfileConfig.empty,
    );
  }

  PasswordResetState copyWith({
    String? email,
    bool? isCompleted,
    bool? isSend,
  }) {
    return PasswordResetState(
        email: email ?? this.email,
        isCompleted: isCompleted ?? this.isCompleted,
        isSend: isSend ?? this.isSend
    );
  }
}
