import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/token_storage.dart';
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
    final data = result['data'];
    final token = data['access_token'];
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
  }) async {
    final formatted = DateFormat('yyyy-MM-dd').format(birthday);
    final result = await _api.register({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirm,
      'region': region,
      'birthday': formatted,
      'job': job,
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
      'email': email,
      'password': password,
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
    required String job
  }) async {
    final formatted = DateFormat('yyyy-MM-dd').format(birthday);
    await _api.updateProfile({
      'name': name,
      'region': region,
      'birthday': formatted,
      'job': job,
    });
  }
}
