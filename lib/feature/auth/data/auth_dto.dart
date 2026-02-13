import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';

class AuthUserDto {
  final int id;
  final String name;
  final String email;
  final String region;
  final String birthday;
  final String job;

  AuthUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final user = data['user'];
    final profile = data['profile'];

    final dto = AuthUserDto(
      id: user['id'],
      name: user['name'],
      email: user['email'],
      region: profile['region'],
      birthday: profile['birthday'],
      job: profile['job'],
    );
    logger('======= AuthUser fromJson =======');
    logger(dto);
    logger('======= AuthUser fromJson =======');
    return dto;
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      region: region,
      // toLocalでJTCに変更する
      birthday: DateTime.parse(birthday).toLocal(),
      job: job,
    );
  }
}
