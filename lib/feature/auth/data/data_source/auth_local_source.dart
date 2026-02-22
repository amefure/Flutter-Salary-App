import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/repository/shared_prefs_repository.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authLocalDataSourceProvider = Provider<AuthLocalSource>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AuthLocalSourceImpl(prefs);
});

abstract class AuthLocalSource {
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();
  Future<void> clear();
}

/// 認証ユーザー情報をローカルにキャッシュするためのクラス
class AuthLocalSourceImpl implements AuthLocalSource {
  final SharedPreferences _prefs;

  AuthLocalSourceImpl(this._prefs);

  static const _key = 'auth_user';

  @override
  Future<void> saveUser(AuthUser user) async {
    final json = jsonEncode({
      AuthJsonKeys.id : user.id,
      AuthJsonKeys.name : user.name,
      AuthJsonKeys.email : user.email,
      AuthJsonKeys.region : user.region,
      AuthJsonKeys.birthday : user.birthday.toIso8601String(),
      AuthJsonKeys.job : user.job,
      AuthJsonKeys.jobCategory : user.jobCategory,
      AuthJsonKeys.publishAgreedAt: user.publishAgreedAt?.toIso8601String(),
      AuthJsonKeys.publishPolicyVersion: user.publishPolicyVersion,
    });

    await _prefs.setString(_key, json);
  }

  @override
  Future<AuthUser?> getUser() async {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return null;

    final map = jsonDecode(jsonString);

    final publishAgreedAtStr = map[AuthJsonKeys.publishAgreedAt];
    return AuthUser(
      id: map[AuthJsonKeys.id],
      name: map[AuthJsonKeys.name],
      email: map[AuthJsonKeys.email],
      region: map[AuthJsonKeys.region],
      birthday: DateTime.parse(map[AuthJsonKeys.birthday]),
      job: map[AuthJsonKeys.job],
      jobCategory: map[AuthJsonKeys.jobCategory],
      /// nullではないならDateTimeにパースする
      publishAgreedAt: publishAgreedAtStr != null ? DateTime.parse(publishAgreedAtStr) : null,
      publishPolicyVersion: map[AuthJsonKeys.publishPolicyVersion],
    );
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
