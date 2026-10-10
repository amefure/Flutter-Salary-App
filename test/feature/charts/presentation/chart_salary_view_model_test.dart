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
      overrides: [localSalaryRepositoryProvider.overrideWithValue(mockRepo)],
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
      final otherSource = fakePaymentSource(id: 'other_id');
      when(() => mockRepo.fetchAll()).thenReturn([
        fakeSalary(id: 'salary', date: DateTime.now(), source: source),
        fakeSalary(
          id: 'other-salary',
          date: DateTime.now(),
          source: otherSource,
        ),
      ]);
      final viewModel = container.read(chartSalaryProvider.notifier);

      // 実行
      viewModel.changeSource(source);

      // 検証
      final state = container.read(chartSalaryProvider);
      expect(state.selectedSource.id, 'new_id');
      expect(state.selectedSources.map((item) => item.id), ['new_id']);
      expect(state.lineChartData, hasLength(1));
      expect(state.pieChartData.map((sector) => sector.name), ['株式会社Ame']);
    });

    test('Allから個別選択に入り、複数選択を追加・解除できること', () {
      final sourceA = fakePaymentSource(id: 'A', name: 'A');
      final sourceB = fakePaymentSource(id: 'B', name: 'B');
      final sourceC = fakePaymentSource(id: 'C', name: 'C');
      when(() => mockRepo.fetchAll()).thenReturn([
        fakeSalary(
          id: 'salary-a',
          paymentAmount: 1000,
          date: DateTime.now(),
          source: sourceA,
        ),
        fakeSalary(
          id: 'salary-b',
          paymentAmount: 2000,
          date: DateTime.now(),
          source: sourceB,
        ),
        fakeSalary(
          id: 'salary-c',
          paymentAmount: 4000,
          date: DateTime.now(),
          source: sourceC,
        ),
      ]);
      final viewModel = container.read(chartSalaryProvider.notifier);

      viewModel.changeSource(sourceA);
      var state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id), ['A']);
      expect(state.lineChartData, hasLength(1));
      expect(state.yearlySummaryData.paymentAmount, 1000);
      expect(state.pieChartData.map((sector) => sector.name), ['A']);

      viewModel.changeSource(sourceB);
      state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id).toSet(), {
        'A',
        'B',
      });
      expect(state.lineChartData, hasLength(2));
      expect(state.yearlySummaryData.paymentAmount, 3000);
      expect(state.pieChartData.map((sector) => sector.name).toSet(), {
        'A',
        'B',
      });
      // The five-year chart retains its legacy single-source selection.
      expect(state.selectedSource.id, 'B');

      viewModel.changeSource(sourceA);
      state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id), ['B']);
      expect(state.yearlySummaryData.paymentAmount, 2000);
    });

    test('全個別支払元の選択と最後の解除をAllに正規化すること', () {
      final sourceA = fakePaymentSource(id: 'A');
      final sourceB = fakePaymentSource(id: 'B');
      when(() => mockRepo.fetchAll()).thenReturn([
        fakeSalary(
          id: 'salary-a',
          paymentAmount: 1000,
          date: DateTime.now(),
          source: sourceA,
        ),
        fakeSalary(
          id: 'salary-b',
          paymentAmount: 2000,
          date: DateTime.now(),
          source: sourceB,
        ),
      ]);
      final viewModel = container.read(chartSalaryProvider.notifier);

      viewModel.changeSource(sourceA);
      viewModel.changeSource(sourceB);
      var state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id), [
        DummySource.allDummySource.id,
      ]);
      expect(state.selectedSource.id, DummySource.allDummySource.id);
      expect(state.yearlySummaryData.paymentAmount, 3000);
      expect(state.lineChartData, hasLength(2));
      expect(state.pieChartData, hasLength(2));

      viewModel.changeSource(sourceA);
      state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id), ['A']);
      viewModel.changeSource(sourceA);
      state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id), [
        DummySource.allDummySource.id,
      ]);
      expect(state.yearlySummaryData.paymentAmount, 3000);
    });

    test('更新後に存在しなくなった選択元をAllへ戻すこと', () {
      final sourceA = fakePaymentSource(id: 'A');
      final sourceB = fakePaymentSource(id: 'B');
      final sourceC = fakePaymentSource(id: 'C');
      when(() => mockRepo.fetchAll()).thenReturn([
        fakeSalary(id: 'salary-a', date: DateTime.now(), source: sourceA),
        fakeSalary(id: 'salary-b', date: DateTime.now(), source: sourceB),
      ]);
      final viewModel = container.read(chartSalaryProvider.notifier);
      viewModel.changeSource(sourceA);

      when(() => mockRepo.fetchAll()).thenReturn([
        fakeSalary(id: 'salary-b', date: DateTime.now(), source: sourceB),
        fakeSalary(id: 'salary-c', date: DateTime.now(), source: sourceC),
      ]);
      viewModel.refresh();

      final state = container.read(chartSalaryProvider);
      expect(state.selectedSources.map((source) => source.id), [
        DummySource.allDummySource.id,
      ]);
      expect(state.sourceList.any((source) => source.id == 'A'), isFalse);
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

      expect(
        container.read(chartSalaryProvider).chartDisplayMode,
        isNot(firstMode),
      );
    });
  });
}
