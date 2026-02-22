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
  final String jobCategory;
  /// 公開規約同意日時
  final String? publishAgreedAt;
  /// 公開規約バージョン 形式:vX.X.X
  final String? publishPolicyVersion;

  AuthUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
    required this.jobCategory,
    required this.publishAgreedAt,
    required this.publishPolicyVersion,
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
      jobCategory: profile[AuthJsonKeys.jobCategory],
      publishAgreedAt: profile[AuthJsonKeys.publishAgreedAt],
      publishPolicyVersion: profile[AuthJsonKeys.publishPolicyVersion],
    );
    logger('======= AuthUser fromJson =======');
    logger(dto);
    logger('======= AuthUser fromJson =======');
    return dto;
  }

  AuthUser toDomain() {
    final birthday = DateTime.parse(this.birthday).toLocal();
    final publishAgreedAt = this.publishAgreedAt?.isNotEmpty ?? false ? DateTime.parse(this.publishAgreedAt!).toLocal() : null;
    return AuthUser(
      id: id,
      name: name,
      email: email,
      region: region,
      // toLocalでJTCに変更する
      birthday: birthday,
      job: job,
      jobCategory: jobCategory,
      // toLocalでJTCに変更する
      publishAgreedAt: publishAgreedAt,
      publishPolicyVersion: publishPolicyVersion
    );
  }
}
