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
  /// アプリVer3.0以降 新規登録処理(メール認証あり)
  /// STEP1：メール送信
  Future<Map<String, dynamic>> registerSendEmail(Map<String, dynamic> body) async {
    return await _client.post('/register/send-email', body: body, requiresAuth: false);
  }

  /// アプリVer3.0以降 新規登録処理(メール認証あり)
  /// STEP2：本登録
  Future<Map<String, dynamic>> registerFinal(Map<String, dynamic> body) async {
    return await _client.post('/register/final', body: body, requiresAuth: false);
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

  Future<Map<String, dynamic>> changeEmail(Map<String, dynamic> body) async {
    return await _client.post('/change-email', body: body, requiresAuth: true);
  }
}
