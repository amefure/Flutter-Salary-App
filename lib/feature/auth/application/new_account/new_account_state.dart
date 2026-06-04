import 'package:salary/core/config/profile_config.dart';

class NewAccountState {

  final String email;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  /// メール送信完了フラグ
  final bool isSend;

  const NewAccountState({
    required this.email,
    this.isCompleted = false,
    this.isSend = false,
  });

  factory NewAccountState.initial() {
    return const NewAccountState(
      email: ProfileConfig.empty,
    );
  }

  NewAccountState copyWith({
    String? email,
    bool? isCompleted,
    bool? isSend
  }) {
    return NewAccountState(
        email: email ?? this.email,
        isCompleted: isCompleted ?? this.isCompleted,
        isSend: isSend ?? this.isSend
    );
  }
}
