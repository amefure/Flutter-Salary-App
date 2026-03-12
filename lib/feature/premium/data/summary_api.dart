import 'package:salary/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final summaryApiProvider = Provider<SummaryApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SummaryApi(apiClient);
});

class SummaryApi {
  SummaryApi(this._client);

  final ApiClient _client;

  static const String _END_POINT = '/summary';

  /// 公開されているサマリー情報
  Future<Map<String, dynamic>> dashboard({Map<String, dynamic>? queries}) async {
    return await _client.get('$_END_POINT/dashboard', queryParameters: queries, requiresAuth: true);
  }
}
