import 'package:salary/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final publicSalaryApiProvider = Provider<PublicSalaryApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PublicSalaryApi(apiClient);
});

class PublicSalaryApi {
  PublicSalaryApi(this._client);

  final ApiClient _client;

  static const String _END_POINT = '/public';

  /// 公開されている給料情報一覧(タイムライン用)
  Future<Map<String, dynamic>> fetchAllList({
    required int page,
    Map<String, dynamic>? queries
  }) async {
    return await _client.get(
        '$_END_POINT/salaries?page=$page',
        queryParameters: queries,
        requiresAuth: true
    );
  }

  /// 公開されている給料情報の詳細
  Future<Map<String, dynamic>> fetchById({
    required String id
  }) async {
    return await _client.get(
        '$_END_POINT/salaries/$id',
        requiresAuth: true
    );
  }

  /// 公開されている給料ユーザー数
  Future<Map<String, dynamic>> fetchUserCount() async {
    return await _client.get('$_END_POINT/user_count', requiresAuth: false);
  }
}
