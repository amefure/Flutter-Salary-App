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
    return await _client.post('/register', body: body);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    return await _client.post('/login', body: body);
  }

  Future<void> logout() async {
    await _client.post('/logout');
  }

  Future<void> withdrawal() async {
    await _client.post('/withdrawal');
  }

  Future<Map<String, dynamic>> fetchUser() async {
    return await _client.get('/user');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    return await _client.patch('/profile', body: body);
  }
}
