
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/thema_color.dart';

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

  PaymentSource? fetchMainPaymentSource() {
    final mainSource = _dataSource.findFirst<PaymentSource>(
        'isMain == \$0',
        [true]
    );
    return mainSource;
  }

  void add(PaymentSource paymentSource) {
    _dataSource.add(paymentSource);
  }

  /// 支払元の情報を更新する
  void updatePaymentSource({
    required String id,
    required String name,
    required bool isMain,
    required int themaColorValue,
    required String? memo,
  }) {
    _dataSource.updateById<PaymentSource>(id, (paymentSource) {
        paymentSource.name = name;
        paymentSource.isMain = isMain;
        paymentSource.themaColor = themaColorValue;
        paymentSource.memo = memo;
      },
    );
  }

  /// [PublicUserId]を更新する
  void updatePublicUserId({
    required String id,
    required int? publicUserId,
  }) {
    _dataSource.updateById<PaymentSource>(id, (paymentSource) {
        paymentSource.publicUserId = publicUserId;
      },
    );
  }

  void deleteById(String paymentSourceId) {
    _dataSource.deleteById<PaymentSource>(paymentSourceId);
  }
}