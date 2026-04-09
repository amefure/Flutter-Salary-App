
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/mock/salary_mock_factory.dart';
import 'package:salary/core/models/salary.dart';

final localSalaryRepositoryProvider = Provider<LocalSalaryRepository>((ref) {
  final dataSource = RealmDataSource();
  return LocalSalaryRepository(dataSource);
});

class LocalSalaryRepository {
  final IRealmDataSource _dataSource;

  LocalSalaryRepository(this._dataSource);

  List<Salary> fetchAll({
    bool isMock = false
  }) {
    if (isMock) {
      return SalaryMockFactory.allGenerateYears();
    } else {
      return _dataSource.fetchAll<Salary>();
    }
  }
  List<Salary> fetchAllSortCreatedAt({
    bool isMock = false
  }) {
    final allSalariesTmp = fetchAll(isMock: isMock);
    // 日付の降順
    allSalariesTmp.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allSalariesTmp;
  }
}