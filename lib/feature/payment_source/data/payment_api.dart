import 'package:salary/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentApiProvider = Provider<PaymentApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PaymentApi(apiClient);
});

class PaymentApi {
  PaymentApi(this._client);

  final ApiClient _client;

  static const String _END_POINT = '/payment-sources';

  Future<Map<String, dynamic>> fetchAllUserList() async {
    return await _client.get(_END_POINT, requiresAuth: true);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    return await _client.post(_END_POINT, body: body, requiresAuth: true);
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _client.put('$_END_POINT/$id', body: body, requiresAuth: true);
  }

  Future<void> delete(String id) async {
    await _client.delete('$_END_POINT/$id', requiresAuth: true);
  }

}
