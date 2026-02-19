import 'package:salary/core/config/json_keys.dart';
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
    final data = json[CommonJsonKeys.data];
    final user = data[CommonJsonKeys.user];
    final profile = data[CommonJsonKeys.profile];

    final dto = AuthUserDto(
      id: user[AuthJsonKeys.id],
      name: user[AuthJsonKeys.name],
      email: user[AuthJsonKeys.email],
      region: profile[AuthJsonKeys.region],
      birthday: profile[AuthJsonKeys.birthday],
      job: profile[AuthJsonKeys.job],
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
