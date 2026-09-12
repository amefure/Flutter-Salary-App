import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/models/annual_target.dart';
import 'package:salary/core/repository/domain/local_annual_target_repository.dart';

class MockRealmDataSource extends Mock implements IRealmDataSource {}

void main() {
  late MockRealmDataSource dataSource;
  late LocalAnnualTargetRepository repository;

  setUp(() {
    dataSource = MockRealmDataSource();
    repository = LocalAnnualTargetRepository(dataSource);
  });

  test('目標を年の降順で取得する', () {
    when(
      () => dataSource.fetchAll<AnnualTarget>(),
    ).thenReturn([AnnualTarget(2025, 1_000), AnnualTarget(2026, 2_000)]);

    final result = repository.fetchAll();

    expect(result.map((target) => target.year), [2026, 2025]);
  });

  test('年をキーに目標を検索する', () {
    final target = AnnualTarget(2026, 2_000);
    when(
      () => dataSource.findFirst<AnnualTarget>('year == \$0', [2026]),
    ).thenReturn(target);

    expect(repository.findByYear(2026), same(target));
  });

  test('保存はRealmのUPSERTを使う', () {
    repository.save(year: 2026, targetAmount: 2_000);

    verify(() => dataSource.addAll<AnnualTarget>(any())).called(1);
  });
}
