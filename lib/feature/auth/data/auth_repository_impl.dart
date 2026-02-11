import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_client.dart';
import 'package:salary/core/models/secrets.dart';
import 'package:salary/feature/auth/data/auth_api.dart';
import 'package:salary/feature/auth/data/auth_dto.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:intl/intl.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: StaticKey.baseURL,
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthApi(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authApiProvider));
});


class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final AuthApi _api;

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String region,
    required DateTime birthday,
    required String job,
  }) async {
    final formatted = DateFormat('yyyy-MM-dd').format(birthday);
    await _api.register({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirm,
      'region': region,
      'birthday': formatted,
      'job': job,
    });
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _api.login({
      'email': email,
      'password': password,
    });
  }

  @override
  Future<void> logout() async {
    await _api.logout();
  }

  @override
  Future<void> withdrawal() async {
    await _api.withdrawal();
  }

  @override
  Future<AuthUser> fetchUser() async {
    final json = await _api.fetchUser();
    return AuthUserDto.fromJson(json).toDomain();
  }
}
