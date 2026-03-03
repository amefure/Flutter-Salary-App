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
  Future<Map<String, dynamic>> fetchAllList({ required int page }) async {
    return await _client.get('$_END_POINT/salaries?page=$page');
  }

  /// 公開されている給料ユーザー数
  Future<Map<String, dynamic>> fetchUserCount() async {
    return await _client.get('$_END_POINT/user_count');
  }
}
