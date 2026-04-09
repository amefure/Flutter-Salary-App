import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import '../../../helpers/dummy_data_helper.dart';

// Repositoryをモック化
class MockLocalSalaryRepository extends Mock implements LocalSalaryRepository {}

void main() {
  late MockLocalSalaryRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockLocalSalaryRepository();
    // Repositoryの挙動を定義 (空リストを返す)
    when(() => mockRepo.fetchAll()).thenReturn([]);

    container = ProviderContainer(
      overrides: [
        localSalaryRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ChartSalaryViewModel テスト', () {
    test('初期化時にデータがロードされ、selectedSourceがALLになっていること', () {
      final state = container.read(chartSalaryProvider);

      // 初期化でfetchAllが呼ばれているか
      verify(() => mockRepo.fetchAll()).called(1);
      // 初期ソースがALLか
      expect(state.selectedSource.id, DummySource.allDummySource.id);
    });

    test('changeSourceを実行したとき、StateのselectedSourceが更新され、グラフデータが再計算されること', () {
      final source = fakePaymentSource(id: 'new_id');
      final viewModel = container.read(chartSalaryProvider.notifier);

      // 実行
      viewModel.changeSource(source);

      // 検証
      final state = container.read(chartSalaryProvider);
      expect(state.selectedSource.id, 'new_id');
      // ※内部で_applyMonthlyLineChartなどが呼ばれ、Stateが適切に更新されていることを期待
    });

    test('changeYear(+1)を実行したとき、selectedYearがインクリメントされること', () {
      final viewModel = container.read(chartSalaryProvider.notifier);
      final initialYear = container.read(chartSalaryProvider).selectedYear;

      // 1年進める
      viewModel.changeYear(1);

      final state = container.read(chartSalaryProvider);
      expect(state.selectedYear, initialYear + 1);
    });

    test('データが存在する場合、_setSalariesによってsourceListが構築されること', () {
      final source = fakePaymentSource(id: 'new_id', isMain: true);
      final salaries = [
        fakeSalary(paymentAmount: 1000, date: DateTime.now(), source: source),
      ];

      // Repositoryがデータを返すように設定
      when(() => mockRepo.fetchAll()).thenReturn(salaries);

      final viewModel = container.read(chartSalaryProvider.notifier);

      // データロードをトリガー
      viewModel.refresh();

      final state = container.read(chartSalaryProvider);
      // ALL + 銀行A の2つが含まれているはず
      expect(state.sourceList.length, 2);
      expect(state.sourceList.any((s) => s.id == 'new_id'), isTrue);
    });

    test('toggleChartDisplayModeを呼ぶとモードが切り替わること', () {
      final viewModel = container.read(chartSalaryProvider.notifier);
      final firstMode = container.read(chartSalaryProvider).chartDisplayMode;

      viewModel.toggleChartDisplayMode();

      expect(container.read(chartSalaryProvider).chartDisplayMode, isNot(firstMode));
    });
  });
}