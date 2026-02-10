import 'package:salary/feature/auth/domain/auth_user.dart';

class AuthUserDto {
  final int id;
  final String email;
  final String prefecture;
  final String birthday;
  final String job;

  AuthUserDto({
    required this.id,
    required this.email,
    required this.prefecture,
    required this.birthday,
    required this.job,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'],
      email: json['email'],
      prefecture: json['prefecture'],
      birthday: json['birthday'],
      job: json['job'],
    );
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      prefecture: prefecture,
      birthday: DateTime.parse(birthday),
      job: job,
    );
  }
}
