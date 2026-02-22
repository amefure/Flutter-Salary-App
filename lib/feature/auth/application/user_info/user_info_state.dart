import 'package:salary/core/config/profile_config.dart';

class UserInfoState {

  final String name;
  final String email;
  final String region;
  final DateTime? birthday;
  final Job job;

  /// 入力ボックスの入力完了フラグ
  final bool isCompleted;
  final bool isEdit;

  const UserInfoState({
    required this.name,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
    this.isCompleted = false,
    this.isEdit = false,
  });

  factory UserInfoState.initial() {
    return const UserInfoState(
      name: '',
      email: '',
      region: ProfileConfig.undefined,
      birthday: null,
      job: ProfileConfig.undefinedJob,
    );
  }

  UserInfoState copyWith({
    String? name,
    String? email,
    String? region,
    DateTime? birthday,
    Job? job,
    bool? isCompleted,
    bool? isEdit
  }) {
    return UserInfoState(
        name: name ?? this.name,
        email: email ?? this.email,
        region: region ?? this.region,
        birthday: birthday ?? this.birthday,
        job: job ?? this.job,
        isCompleted: isCompleted ?? this.isCompleted,
        isEdit: isEdit ?? this.isEdit
    );
  }
}
