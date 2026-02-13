class UserInfoState {

  final String name;
  final String email;
  final String region;
  final DateTime? birthday;
  final String job;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;

  const UserInfoState({
    required this.name,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
    this.isCompleted = false,
  });

  factory UserInfoState.initial() {
    return const UserInfoState(
      name: '',
      email: '',
      region: '',
      birthday: null,
      job: '',
    );
  }

  UserInfoState copyWith({
    String? name,
    String? email,
    String? region,
    DateTime? birthday,
    String? job,
    bool? isCompleted
  }) {
    return UserInfoState(
        name: name ?? this.name,
        email: email ?? this.email,
        region: region ?? this.region,
        birthday: birthday ?? this.birthday,
        job: job ?? this.job,
        isCompleted: isCompleted ?? this.isCompleted
    );
  }
}
