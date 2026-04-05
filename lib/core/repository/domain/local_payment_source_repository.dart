
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/models/salary.dart';

final localPaymentSourceRepositoryProvider = Provider<LocalPaymentSourceRepository>((ref) {
  final dataSource = RealmDataSource();
  return LocalPaymentSourceRepository(dataSource);
});

class LocalPaymentSourceRepository {
  final IRealmDataSource _dataSource;

  LocalPaymentSourceRepository(this._dataSource);

  List<PaymentSource> fetchSortedAllPaymentSources() {
    final results = _dataSource.fetchAll<PaymentSource>()
      ..sort((a, b) {
        final aValue = a.isMain ? 1 : 0;
        final bValue = b.isMain ? 1 : 0;
        return bValue - aValue;
      });
    return results;
  }

  /// 支払元の情報を更新する
  void updatePaymentSource({
    required PaymentSource current,
    required int? publicUserId,
  }) {
    _dataSource.updateById<PaymentSource>(
      current.id,
          (paymentSource) {
        paymentSource.name = current.name;
        paymentSource.isMain = current.isMain;
        paymentSource.themaColor = current.themaColor;
        paymentSource.memo = current.memo;
        paymentSource.publicUserId = publicUserId;
      },
    );
  }

  void deleteById(String paymentSourceId) {
    _dataSource.deleteById<PaymentSource>(paymentSourceId);
  }
}