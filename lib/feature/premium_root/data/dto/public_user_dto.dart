import 'package:salary/core/config/json_keys.dart';
import 'package:salary/feature/premium_root/data/dto/public_profile_dto.dart';
import 'package:salary/feature/premium_root/domain/model/public_user.dart';

class PublicUserDto {

  final int id;
  final String name;
  final PublicProfileDto profile;

  PublicUserDto({
    required this.id,
    required this.name,
    required this.profile,
  });

  factory PublicUserDto.fromJson(Map<String, dynamic> json) {
    return PublicUserDto(
      id: json[AuthJsonKeys.id],
      name: json[AuthJsonKeys.name],
      profile: PublicProfileDto.fromJson(json[CommonJsonKeys.profile]),
    );
  }
}

extension PublicUserDtoMapper on PublicUserDto {
  PublicUser toDomain() {
    return PublicUser(
      id: id,
      name: name,
      profile: profile.toDomain(),
    );
  }
}
