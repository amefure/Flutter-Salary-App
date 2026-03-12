import 'package:salary/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthApi(apiClient);
});

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  /// ======== ユーザー認証まわり ========
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    return await _client.post('/register', body: body, requiresAuth: false);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    return await _client.post('/login', body: body, requiresAuth: false);
  }

  Future<void> logout() async {
    await _client.post('/logout', requiresAuth: false);
  }

  Future<void> withdrawal() async {
    await _client.post('/withdrawal', requiresAuth: true);
  }

  Future<Map<String, dynamic>> fetchUser() async {
    return await _client.get('/user', requiresAuth: true);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    return await _client.patch('/profile', body: body, requiresAuth: true);
  }

  Future<Map<String, dynamic>> sendResetPassWordEmail(Map<String, dynamic> body) async {
    return await _client.post('/password/email', body: body, requiresAuth: false);
  }
}
