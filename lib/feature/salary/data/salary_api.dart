import 'package:salary/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final salaryApiProvider = Provider<SalaryApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SalaryApi(apiClient);
});

class SalaryApi {
  SalaryApi(this._client);

  final ApiClient _client;

  static const String _END_POINT = '/salaries';

  /// ユーザーに紐づいたデータのみ
  Future<Map<String, dynamic>> fetchAllUserList() async {
    return await _client.get(_END_POINT, requiresAuth: true);
  }

  /// 全ユーザーのデータ
  @Deprecated('公開・非公開に紐づかないデータ取得なので使用しない')
  Future<Map<String, dynamic>> fetchAllList({ required int page }) async {
    return await _client.get('$_END_POINT/all?page=$page', requiresAuth: true);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    return await _client.post(_END_POINT, body: body, requiresAuth: true);
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _client.put('$_END_POINT/$id', body: body, requiresAuth: true);
  }

  Future<void> delete(Map<String, dynamic> body) async {
    await _client.delete(_END_POINT, body: body, requiresAuth: true);
  }

}
