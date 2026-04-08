import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/charts/chart_salary_state.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/charts/domain/utility/salary_aggregator.dart';

final chartSalaryProvider = StateNotifierProvider<ChartSalaryViewModel, ChartSalaryState>((ref) {
    final localSalaryRepository = ref.read(localSalaryRepositoryProvider);
    return ChartSalaryViewModel(ref, localSalaryRepository);
  },
);

class ChartSalaryViewModel extends StateNotifier<ChartSalaryState> {
  final Ref ref;

  /// ローカル
  final LocalSalaryRepository _localSalaryRepositoryProvider;

  /// 初期インスタンス化
  ChartSalaryViewModel(this.ref, this._localSalaryRepositoryProvider)
      : super(ChartSalaryState.initial()) {
    /// ALLを選択状態に変更
    changeSource(DummySource.allDummySource);
    /// データロード
    _loadSalaries();
  }

  /// MyData画面以外からのリフレッシュ
  void refresh() {
    /// データを最初から読み込む
    _loadSalaries();
  }

  /// Realm から Salary を取得
  void _loadSalaries() {
    // モック(確認用)
    // final salaries = _localSalaryRepositoryProvider.fetchAll(isMock: true);
    final salaries = _localSalaryRepositoryProvider.fetchAll();
    _setSalaries(salaries);
  }

  /// Salary一覧を受け取り、集計
  void _setSalaries(List<Salary> allSalaries) {
    final grouped = SalaryAggregator.groupBySourceAndMonth(allSalaries);
    /// 支払い元選択ピッカーに表示するリストを取得
    final sourceList = SalaryAggregator.fetchExtractSortedSources(grouped);
    state = state.copyWith(
      allSalaries: allSalaries,
      sourceList: sourceList,
      groupedBySource: grouped,
    );
    _applyMonthlyLineChart();
    _applyYearlySummary();
    _applyYearlyBarChart();
  }

  /// 支払い元切り替え
  void changeSource(PaymentSource source) {
    state = state.copyWith(selectedSource: source);
    _applyMonthlyLineChart();
    _applyYearlySummary();
    _applyYearlyBarChart();
  }

  /// 年数切り替え
  void changeYear(int offset) {
    state = state.copyWith(
      selectedYear: state.selectedYear + offset,
    );
    _applyMonthlyLineChart();
    /// 年数の変更の場合はサマリーのみ更新
    _applyYearlySummary();
  }

  /// グラフ表示切り替え
  void toggleChartDisplayMode() {
    state = state.copyWith(
      chartDisplayMode: state.chartDisplayMode.opposite,
    );
  }

  /// 選択状態が変わるたびに呼ばれる
  void _applyMonthlyLineChart() {
    final lineData = SalaryAggregator.buildLineChartData(
      groupedBySource: state.groupedBySource,
      selectedSource: state.selectedSource,
      selectedYear: state.selectedYear,
    );
    final pieData = SalaryAggregator.buildPieChartData(
      groupedBySource: state.groupedBySource,
      selectedYear: state.selectedYear,
    );
    state = state.copyWith(
        lineChartData: lineData,
        pieChartData: pieData
    );
  }

  /// 「③ 年別合計金額(10年間)棒グラフ用データ」を計算し反映
  void _applyYearlyBarChart() {
    final chartData = SalaryAggregator.buildYearlyPaymentBarChartData(
        selectedSource: state.selectedSource,
        groupedBySource: state.groupedBySource
    );
    state = state.copyWith(
        yearlyBarChartData: chartData
    );
  }

  /// 数値配列の最大値を[paddingRate]係数で増長して丸めた値を取得
  double calculateMaxY(Iterable<double> values, {double paddingRate = 0.1}) {
    return SalaryAggregator.calculateMaxY(values);
  }

  /// 「② 年収 & 賞与サマリーデータ」を計算し反映
  void _applyYearlySummary() {
    final summary = SalaryAggregator.calculateYearlySummary(
        selectedSource: state.selectedSource,
        selectedYear: state.selectedYear,
        allSalaries: state.allSalaries
    );
    state = state.copyWith(
        yearlySummaryData: summary
    );
  }
}





