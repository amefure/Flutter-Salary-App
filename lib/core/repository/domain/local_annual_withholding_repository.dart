import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/models/annual_withholding.dart';

final localAnnualWithholdingRepositoryProvider =
    Provider<LocalAnnualWithholdingRepository>((ref) {
      return LocalAnnualWithholdingRepository(RealmDataSource());
    });

class LocalAnnualWithholdingRepository {
  final IRealmDataSource _dataSource;

  LocalAnnualWithholdingRepository(this._dataSource);

  List<AnnualWithholding> fetchAll() {
    final items = _dataSource.fetchAll<AnnualWithholding>();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<AnnualWithholding> fetchByYear(int year) {
    final items = _dataSource.findByQuery<AnnualWithholding>('year == \$0', [
      year,
    ]);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  AnnualWithholding? findByYearAndPaymentSourceId(
    int year,
    String paymentSourceId,
  ) {
    return _dataSource.findFirst<AnnualWithholding>(
      'year == \$0 AND paymentSourceId == \$1',
      [year, paymentSourceId],
    );
  }

  void save(AnnualWithholding item) {
    _dataSource.addAll([item]);
  }

  void deleteById(String id) {
    _dataSource.deleteById<AnnualWithholding>(id);
  }

  int totalPaymentAmountForYear(int year) {
    return fetchByYear(
      year,
    ).fold<int>(0, (sum, item) => sum + item.paymentAmount);
  }

  int totalIncomeTaxAmountForYear(int year) {
    return fetchByYear(
      year,
    ).fold<int>(0, (sum, item) => sum + item.incomeTaxAmount);
  }
}
