import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/charts/chart_salary_state.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/charts/domain/utility/salary_aggregator.dart';

final chartSalaryProvider =
    StateNotifierProvider<ChartSalaryViewModel, ChartSalaryState>((ref) {
      final localSalaryRepository = ref.read(localSalaryRepositoryProvider);
      return ChartSalaryViewModel(ref, localSalaryRepository);
    });

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
    final availableSources =
        sourceList
            .where((source) => source.id != DummySource.allDummySource.id)
            .toList();
    final availableIds = availableSources.map((source) => source.id).toSet();
    final selected =
        state.selectedSources
            .where(
              (source) =>
                  source.id != DummySource.allDummySource.id &&
                  availableIds.contains(source.id),
            )
            .toList();
    final normalizedSelection =
        selected.isEmpty || selected.length == availableSources.length
            ? [DummySource.allDummySource]
            : selected;
    final currentBarSourceExists =
        state.selectedSource.id == DummySource.allDummySource.id ||
        availableIds.contains(state.selectedSource.id);
    final barSource =
        normalizedSelection.any(
              (source) => source.id == DummySource.allDummySource.id,
            )
            ? DummySource.allDummySource
            : currentBarSourceExists
            ? state.selectedSource
            : DummySource.allDummySource;
    state = state.copyWith(
      allSalaries: allSalaries,
      sourceList: sourceList,
      selectedSources: normalizedSelection,
      selectedSource: barSource,
      groupedBySource: grouped,
    );
    _applyMonthlyLineChart();
    _applyYearlySummary();
    _applyYearlyBarChart();
  }

  /// グラフ・サマリーの支払い元を個別に追加・解除する。
  /// 5年間の棒グラフは既存の単一選択動作を維持する。
  void changeSource(PaymentSource source) {
    if (source.id == DummySource.allDummySource.id) {
      state = state.copyWith(
        selectedSources: [DummySource.allDummySource],
        selectedSource: DummySource.allDummySource,
      );
    } else {
      final availableSources =
          state.sourceList
              .where((item) => item.id != DummySource.allDummySource.id)
              .toList();
      if (!availableSources.any((item) => item.id == source.id)) return;

      final selectedIds =
          state.selectedSources
              .where((item) => item.id != DummySource.allDummySource.id)
              .map((item) => item.id)
              .toSet();
      final wasAllSelected = state.selectedSources.any(
        (item) => item.id == DummySource.allDummySource.id,
      );
      if (wasAllSelected) {
        selectedIds.add(source.id);
      } else if (!selectedIds.add(source.id)) {
        selectedIds.remove(source.id);
      }

      final selectedSources =
          availableSources
              .where((item) => selectedIds.contains(item.id))
              .toList();
      final isAllSelected =
          selectedSources.isEmpty ||
          selectedSources.length == availableSources.length;
      final normalizedSelection =
          isAllSelected ? [DummySource.allDummySource] : selectedSources;
      final barSource =
          isAllSelected
              ? DummySource.allDummySource
              : selectedSources.firstWhere(
                (item) => item.id == source.id,
                orElse: () => selectedSources.first,
              );

      state = state.copyWith(
        selectedSources: normalizedSelection,
        selectedSource: barSource,
      );
    }
    _applyMonthlyLineChart();
    _applyYearlySummary();
    _applyYearlyBarChart();
  }

  /// 年数切り替え
  void changeYear(int offset) {
    state = state.copyWith(selectedYear: state.selectedYear + offset);
    _applyMonthlyLineChart();

    /// 年数の変更の場合はサマリーのみ更新
    _applyYearlySummary();
  }

  /// グラフ表示切り替え
  void toggleChartDisplayMode() {
    state = state.copyWith(chartDisplayMode: state.chartDisplayMode.opposite);
  }

  /// 選択状態が変わるたびに呼ばれる
  void _applyMonthlyLineChart() {
    final lineData = SalaryAggregator.buildLineChartData(
      groupedBySource: state.groupedBySource,
      selectedSources: state.selectedSources,
      selectedYear: state.selectedYear,
    );
    final pieData = SalaryAggregator.buildPieChartData(
      groupedBySource: state.groupedBySource,
      selectedSources: state.selectedSources,
      selectedYear: state.selectedYear,
    );
    state = state.copyWith(lineChartData: lineData, pieChartData: pieData);
  }

  /// 棒グラフの表示期間を1年ずつずらす（offset: -1で過去へ、+1で未来へ）
  void shiftBarChartYear(int offset) {
    state = state.copyWith(barChartEndYear: state.barChartEndYear + offset);
    _applyYearlyBarChart();
  }

  /// 「③ 年別合計金額(5年間)棒グラフ用データ」を計算し反映
  void _applyYearlyBarChart() {
    final chartData = SalaryAggregator.buildYearlyPaymentBarChartData(
      selectedSource: state.selectedSource,
      groupedBySource: state.groupedBySource,
      endYear: state.barChartEndYear,
    );
    state = state.copyWith(yearlyBarChartData: chartData);
  }

  /// 数値配列の最大値を[paddingRate]係数で増長して丸めた値を取得
  double calculateMaxY(Iterable<double> values, {double paddingRate = 0.1}) {
    return SalaryAggregator.calculateMaxY(values);
  }

  /// 「② 年収 & 賞与サマリーデータ」を計算し反映
  void _applyYearlySummary() {
    final summary = SalaryAggregator.calculateYearlySummary(
      selectedSources: state.selectedSources,
      selectedYear: state.selectedYear,
      allSalaries: state.allSalaries,
    );
    state = state.copyWith(yearlySummaryData: summary);
  }
}
