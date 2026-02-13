import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/shared_prefs_repository.dart';
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
      'id': user.id,
      'email': user.email,
      'region': user.region,
      'birthday': user.birthday.toIso8601String(),
      'job': user.job,
    });

    await _prefs.setString(_key, json);
  }

  @override
  Future<AuthUser?> getUser() async {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return null;

    final map = jsonDecode(jsonString);

    return AuthUser(
      id: map['id'],
      email: map['email'],
      region: map['region'],
      birthday: DateTime.parse(map['birthday']),
      job: map['job'],
    );
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
