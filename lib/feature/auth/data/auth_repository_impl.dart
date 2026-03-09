import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/token_storage.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/feature/auth/data/data_source/auth_api.dart';
import 'package:salary/feature/auth/data/auth_dto.dart';
import 'package:salary/feature/auth/data/data_source/auth_local_source.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:intl/intl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiSource = ref.read(authApiProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return AuthRepositoryImpl(apiSource, localDataSource, tokenStorage);
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._local, this._tokenStorage);

  final AuthApi _api;
  final AuthLocalSource _local;
  final TokenStorage _tokenStorage;

  Future<void> saveToken(Map<String, dynamic> result) async {
    final data = result[CommonJsonKeys.data];
    final token = data[CommonJsonKeys.accessToken];
    await _tokenStorage.save(token);
  }

  Future<void> clearToken() async {
    await _tokenStorage.clear();
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory,
  }) async {
    final formatted = DateFormat('yyyy-MM-dd').format(birthday);

    final result = await _api.register({
      AuthJsonKeys.name : name,
      AuthJsonKeys.email: email,
      AuthJsonKeys.password: password,
      AuthJsonKeys.passwordConfirmation: passwordConfirm,
      AuthProfileJsonKeys.region: region,
      AuthProfileJsonKeys.birthday: formatted,
      AuthProfileJsonKeys.job: job,
      AuthProfileJsonKeys.jobCategory: jobCategory,
    });

    await saveToken(result);
    return AuthUserDto.fromJson(result).toDomain();
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.login({
      AuthJsonKeys.email: email,
      AuthJsonKeys.password: password,
    });
    await saveToken(result);
    return AuthUserDto.fromJson(result).toDomain();
  }

  @override
  Future<void> logout() async {
    await _api.logout();
    clearToken();
  }

  @override
  Future<void> withdrawal() async {
    await _api.withdrawal();
    clearToken();
  }

  @override
  Future<AuthUser?> getCachedUser() async {
    return await _local.getUser();
  }

  @override
  Future<AuthUser> fetchUserFromApi() async {
    final result = await _api.fetchUser();
    final user = AuthUserDto.fromJson(result).toDomain();
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<void> clearCachedUser() async {
    await _local.clear();
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory
  }) async {
    final formatted = DateFormat('yyyy-MM-dd').format(birthday);
    await _api.updateProfile({
      AuthJsonKeys.name: name,
      AuthProfileJsonKeys.region: region,
      AuthProfileJsonKeys.birthday: formatted,
      AuthProfileJsonKeys.job: job,
      AuthProfileJsonKeys.jobCategory: jobCategory,
    });
  }

  /// プロフィール更新(ポリシー限定)
  /// 同意日はサーバー側で生成するためバージョンのみ送信
  @override
  Future<void> updatePolicyProfile({
    required String publishPolicyVersion
  }) async {
    await _api.updateProfile({
      AuthProfileJsonKeys.publishPolicyVersion: publishPolicyVersion,
    });
  }

  @override
  Future<void> sendResetPassWordEmail({
    required String email
  }) async {
    await _api.sendResetPassWordEmail({
      AuthJsonKeys.email: email,
    });
  }
}
