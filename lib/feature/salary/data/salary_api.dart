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
    return await _client.get(_END_POINT);
  }

  /// 全ユーザーのデータ
  Future<Map<String, dynamic>> fetchAllList() async {
    return await _client.get('$_END_POINT/all');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    return await _client.post(_END_POINT, body: body);
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _client.put('$_END_POINT/$id', body: body);
  }

  Future<void> delete(String id) async {
    await _client.delete('$_END_POINT/$id');
  }

}
