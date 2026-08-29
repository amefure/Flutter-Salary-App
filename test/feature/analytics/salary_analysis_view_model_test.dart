import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/analysis/salary_analysis_view_model.dart';

import '../../helpers/dummy_data_helper.dart';

class MockLocalSalaryRepository extends Mock implements LocalSalaryRepository {}

void main() {
  late MockLocalSalaryRepository mockRepository;
  late SalaryAnalysisViewModel viewModel;

  setUp(() {
    mockRepository = MockLocalSalaryRepository();
  });

  group('SalaryAnalysisViewModel テスト', () {
    test('初期化時にリポジトリからデータが取得され、状態が正しく初期化されること', () {
      // Arrange
      // 支給項目を持ったダミーデータをテスト用に定義
      final customDummySalaries = [
        fakeSalary(id: '1', paymentAmount: 1000, date: DateTime(2026, 1, 1), paymentAmountItems: [AmountItem('p1', '基本給', 1000)]),
        fakeSalary(id: '2', paymentAmount: 2000, date: DateTime(2026, 1, 15), paymentAmountItems: [AmountItem('p1', '基本給', 2000)]),
        fakeSalary(id: '3', paymentAmount: 3000, date: DateTime(2026, 2, 1), paymentAmountItems: [AmountItem('p1', '基本給', 3000)]),
      ];
      when(() => mockRepository.fetchAll()).thenReturn(customDummySalaries);

      // Act
      viewModel = SalaryAnalysisViewModel(mockRepository);

      // Assert
      expect(viewModel.state.allSalaries.length, 3);
      expect(viewModel.state.availableItemNames, ['基本給']);
      expect(viewModel.state.selectedItemName, '基本給');
      // 日付が一番新しいものが target (id: '3' -> 2026-02-01)
      expect(viewModel.state.targetSalaryId, '3');
      // 2番目に新しいものが base (id: '2' -> 2026-01-15)
      expect(viewModel.state.baseSalaryId, '2');
    });

    test('初期化時にデータが1件のみの場合、targetとbaseが同じIDになること', () {
      // Arrange
      final singleSalaryList = [
        fakeSalary(id: 'only_one', date: DateTime(2026, 5, 10), deductionAmountItems: [AmountItem('d1', '所得税', 10000)]),
      ];
      when(() => mockRepository.fetchAll()).thenReturn(singleSalaryList);

      // Act
      viewModel = SalaryAnalysisViewModel(mockRepository);

      // Assert
      expect(viewModel.state.allSalaries.length, 1);
      expect(viewModel.state.availableItemNames, ['所得税']);
      expect(viewModel.state.targetSalaryId, 'only_one');
      expect(viewModel.state.baseSalaryId, 'only_one');
    });

    test('updateBaseSalaryId, updateTargetSalaryId, selectItemNameが状態を更新すること', () {
      // Arrange
      when(() => mockRepository.fetchAll()).thenReturn([]);
      viewModel = SalaryAnalysisViewModel(mockRepository);

      // Act & Assert
      viewModel.updateBaseSalaryId('base_id');
      expect(viewModel.state.baseSalaryId, 'base_id');

      viewModel.updateTargetSalaryId('target_id');
      expect(viewModel.state.targetSalaryId, 'target_id');

      viewModel.selectItemName('残業手当');
      expect(viewModel.state.selectedItemName, '残業手当');
    });

    test('findSalaryById: 指定したIDの給与データを取得できること、存在しない場合はnullを返すこと', () {
      // Arrange
      final targetSalary = fakeSalary(id: '1', date: DateTime(2026, 1, 1));
      when(() => mockRepository.fetchAll()).thenReturn([targetSalary]);
      viewModel = SalaryAnalysisViewModel(mockRepository);

      // Act & Assert
      expect(viewModel.findSalaryById('1')?.id, '1');
      expect(viewModel.findSalaryById('xyz'), isNull);
      expect(viewModel.findSalaryById(null), isNull);
    });

    test('calculateMaxY: 値に応じて適切な最大値を計算すること', () {
      when(() => mockRepository.fetchAll()).thenReturn([]);
      viewModel = SalaryAnalysisViewModel(mockRepository);

      expect(viewModel.calculateMaxY([]), 10000);
      expect(viewModel.calculateMaxY([0.0, 0.0]), 10000);
      expect(viewModel.calculateMaxY([100.0, 500.0]), 600.0);
    });

    test('changeYear: 年のデルタ変更が正しく反映されること', () {
      when(() => mockRepository.fetchAll()).thenReturn([]);
      viewModel = SalaryAnalysisViewModel(mockRepository);

      final initialYear = viewModel.state.selectedYear;

      viewModel.changeYear(1);
      expect(viewModel.state.selectedYear, initialYear + 1);

      viewModel.changeYear(-2);
      expect(viewModel.state.selectedYear, initialYear - 1);
    });

    test('支給・控除項目の判定および月別データの集計が正しく行われること', () {
      // Arrange
      final salariesWithItems = [
        fakeSalary(
          id: '100',
          date: DateTime(2026, 5, 15),
          paymentAmountItems: [AmountItem('p1', '基本給', 250000)],
          deductionAmountItems: [AmountItem('d1', '健康保険', 15000)],
        ),
      ];
      when(() => mockRepository.fetchAll()).thenReturn(salariesWithItems);

      viewModel = SalaryAnalysisViewModel(mockRepository);

      // Act & Assert
      expect(viewModel.paymentItemNames, ['基本給']);
      expect(viewModel.deductionItemNames, ['健康保険']);

      expect(viewModel.isItemDeduction('基本給'), isFalse);
      expect(viewModel.isItemDeduction('健康保険'), isTrue);

      // 控除項目の選択テスト
      viewModel.selectItemName('健康保険');
      expect(viewModel.isSelectedItemSelectedAsDeduction, isTrue);

      // 2026年5月の月別データ確認 (index 4 が 5月)
      viewModel.state = viewModel.state.copyWith(selectedYear: 2026);
      final monthlyData = viewModel.getMonthlyDataForYear();
      expect(monthlyData[4], 15000.0);
      expect(monthlyData[0], 0.0);
    });
  });
}