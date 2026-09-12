import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/models/annual_target.dart';
import 'package:salary/core/repository/domain/local_annual_target_repository.dart';
import 'package:salary/feature/settings/annual_target_view_model.dart';

class MockLocalAnnualTargetRepository extends Mock
    implements LocalAnnualTargetRepository {}

void main() {
  late MockLocalAnnualTargetRepository repository;

  setUp(() {
    repository = MockLocalAnnualTargetRepository();
    when(() => repository.fetchAll()).thenReturn([]);
  });

  test('初期化時に目標一覧を読み込む', () {
    AnnualTargetViewModel(repository);

    verify(() => repository.fetchAll()).called(1);
  });

  test('不正な目標金額は保存しない', () {
    final viewModel = AnnualTargetViewModel(repository);

    expect(viewModel.saveTarget(year: 2026, targetAmount: 0), isFalse);
    verifyNever(
      () => repository.save(
        year: any(named: 'year'),
        targetAmount: any(named: 'targetAmount'),
      ),
    );
  });

  test('有効な目標を保存して状態を更新する', () {
    final target = AnnualTarget(2026, 2_000);
    when(() => repository.fetchAll()).thenReturn([target]);
    final viewModel = AnnualTargetViewModel(repository);

    expect(viewModel.saveTarget(year: 2026, targetAmount: 2_000), isTrue);

    verify(() => repository.save(year: 2026, targetAmount: 2_000)).called(1);
    expect(viewModel.state.targets.single.targetAmount, 2_000);
  });
}
