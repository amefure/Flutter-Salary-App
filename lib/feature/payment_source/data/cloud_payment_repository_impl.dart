import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/payment_source/data/payment_api.dart';
import 'package:salary/feature/payment_source/data/payment_source_dto.dart';
import 'package:salary/feature/payment_source/domain/cloud_payment_repository.dart';

final paymentRepositoryProvider = Provider<CloudPaymentRepository>((ref) {
  final apiSource = ref.read(paymentApiProvider);
  return CloudPaymentRepositoryImpl(apiSource);
});

class CloudPaymentRepositoryImpl implements CloudPaymentRepository {
  CloudPaymentRepositoryImpl(this._api);

  final PaymentApi _api;

  @override
  Future<List<PaymentSource>> fetchAllUserList() async {
    final result = await _api.fetchAllUserList();

    final List<dynamic> list = result[CommonJsonKeys.data][CommonJsonKeys.paymentSources];
    return list.map((json) => PaymentSourceDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<void> create({
    required String id,
    required String name,
    required int themeColor,
    required String? memo,
    required bool isMain,
  }) async {
    await _api.create({
      PaymentSourceJsonKeys.id: id,
      PaymentSourceJsonKeys.name: name,
      PaymentSourceJsonKeys.themeColor: themeColor,
      PaymentSourceJsonKeys.memo: memo,
      PaymentSourceJsonKeys.isMain: isMain,
    });
  }

  @override
  Future<void> update({
    required String id,
    required String name,
    required int themeColor,
    required String? memo,
    required bool isMain,
  }) async {
    await _api.update(
        id,
        {
          PaymentSourceJsonKeys.name: name,
          PaymentSourceJsonKeys.themeColor: themeColor,
          PaymentSourceJsonKeys.memo: memo,
          PaymentSourceJsonKeys.isMain: isMain,
        });
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete(id);
  }
}
