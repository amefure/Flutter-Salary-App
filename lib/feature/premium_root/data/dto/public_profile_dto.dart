import 'package:salary/core/config/json_keys.dart';
import 'package:salary/feature/premium_root/domain/model/public_profile.dart';

class PublicProfileDto {

  final String jobCategory;
  final String job;
  final String region;
  final String ageRange;

  PublicProfileDto({
    required this.jobCategory,
    required this.job,
    required this.region,
    required this.ageRange,
  });

  factory PublicProfileDto.fromJson(Map<String, dynamic> json) {
    return PublicProfileDto(
      jobCategory: json[AuthProfileJsonKeys.jobCategory],
      job: json[AuthProfileJsonKeys.job],
      region: json[AuthProfileJsonKeys.region],
      ageRange: json[AuthProfileJsonKeys.ageRange],
    );
  }
}

extension PublicProfileDtoMapper on PublicProfileDto {
  PublicProfile toDomain() {
    return PublicProfile(
      jobCategory: jobCategory,
      job: job,
      region: region,
      ageRange: ageRange,
    );
  }
}

