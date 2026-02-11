import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_client.dart';
import 'package:salary/core/api/token_storage.dart';
import 'package:salary/core/models/secrets.dart';
import 'package:salary/feature/auth/data/auth_api.dart';
import 'package:salary/feature/auth/data/auth_dto.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:intl/intl.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
      baseUrl: StaticKey.baseURL,
      tokenStorage: ref.read(tokenStorageProvider)
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthApi(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authApiProvider), ref.read(tokenStorageProvider));
});


class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._tokenStorage);

  final AuthApi _api;
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
  Future<AuthUser> fetchUser() async {
    final result = await _api.fetchUser();
    return AuthUserDto.fromJson(result).toDomain();
  }
}
