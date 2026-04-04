import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authLocalDataSourceProvider = Provider<AuthLocalSource>((ref) {
  final userSettings = ref.read(userSettingsProvider);
  return AuthLocalSourceImpl(userSettings);
});

abstract class AuthLocalSource {
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();
  Future<void> clear();
}

/// 認証ユーザー情報をローカルにキャッシュするためのクラス
class AuthLocalSourceImpl implements AuthLocalSource {
  final UserSettingsRepository _userSettingsRepository;

  AuthLocalSourceImpl(this._userSettingsRepository);

  @override
  Future<void> saveUser(AuthUser user) async {
    final json = jsonEncode({
      AuthJsonKeys.id : user.id,
      AuthJsonKeys.name : user.name,
      AuthJsonKeys.email : user.email,
      AuthProfileJsonKeys.region : user.region,
      AuthProfileJsonKeys.birthday : user.birthday.toIso8601String(),
      AuthProfileJsonKeys.job : user.job,
      AuthProfileJsonKeys.jobCategory : user.jobCategory,
      AuthProfileJsonKeys.publishAgreedAt: user.publishAgreedAt?.toIso8601String(),
      AuthProfileJsonKeys.publishPolicyVersion: user.publishPolicyVersion,
    });

    await _userSettingsRepository.saveAuthUser(json);
  }

  @override
  Future<AuthUser?> getUser() async {
    final jsonString = _userSettingsRepository.fetchAuthUser();
    if (jsonString == null) return null;

    final map = jsonDecode(jsonString);

    final publishAgreedAtStr = map[AuthProfileJsonKeys.publishAgreedAt];
    return AuthUser(
      id: map[AuthJsonKeys.id],
      name: map[AuthJsonKeys.name],
      email: map[AuthJsonKeys.email],
      region: map[AuthProfileJsonKeys.region],
      birthday: DateTime.parse(map[AuthProfileJsonKeys.birthday]),
      job: map[AuthProfileJsonKeys.job],
      jobCategory: map[AuthProfileJsonKeys.jobCategory],
      /// nullではないならDateTimeにパースする
      publishAgreedAt: publishAgreedAtStr != null ? DateTime.parse(publishAgreedAtStr) : null,
      publishPolicyVersion: map[AuthProfileJsonKeys.publishPolicyVersion],
    );
  }

  @override
  Future<void> clear() async {
    await _userSettingsRepository.clearAuthUser();
  }
}
