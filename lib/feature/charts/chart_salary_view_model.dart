import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/charts/chart_salary_state.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/charts/chart_display_mode.dart';
import 'package:salary/feature/charts/domain/salary_aggregator.dart';

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
    // ALLを選択状態に変更
    changeSource(DummySource.allDummySource);
    // データロード
    _loadSalaries();
  }

  /// リフレッシュ
  void refresh() {
    // データロード
    _loadSalaries();
  }

  /// Realm から Salary を取得
  void _loadSalaries() {
    // モック(確認用)
    // final salaries = _localSalaryRepositoryProvider.fetchAll(isMock: true);
    final salaries = _localSalaryRepositoryProvider.fetchAll();
    setSalaries(salaries);
  }

  /// Salary一覧を受け取り、集計
  void setSalaries(List<Salary> allSalaries) {
    final grouped = SalaryAggregator.groupBySourceAndMonth(allSalaries);
    final sources = SalaryAggregator.extractSortedSources(grouped);
    state = state.copyWith(
      allSalaries: allSalaries,
      groupedBySource: grouped,
      sourceList: sources,
    );
    _applyYearlySummary();
  }

  void changeSource(PaymentSource source) {
    state = state.copyWith(selectedSource: source);
    _applyYearlySummary();
  }

  void changeYear(int offset) {
    state = state.copyWith(
      selectedYear: state.selectedYear + offset,
    );
    _applyYearlySummary();
  }

  /// グラフ切り替え
  void toggleDisplayMode() {
    state = state.copyWith(
      displayMode: state.displayMode == ChartDisplayMode.line
          ? ChartDisplayMode.pie
          : ChartDisplayMode.line,
    );
  }

  /// 10年分棒グラフ表示用データの生成
  /// 年ごとの総支給額を支払い元は識別にせずに統合して計算
  YearlyPaymentChartData buildYearlyPaymentBarChartData({
    required PaymentSource selectedSource,
    required Map<String, List<MonthlySalarySummary>> groupedBySource
  }) {
    return SalaryAggregator.buildYearlyPaymentBarChartData(
        selectedSource: selectedSource,
        groupedBySource: groupedBySource
    );
  }

  /// 数値配列の最大値を[paddingRate]係数で増長して丸めた値を取得
  double calculateMaxY(Iterable<double> values, {double paddingRate = 0.1}) {
    return SalaryAggregator.calculateMaxY(values);
  }


  /// 年別 × 支払い元ごとの総支給額を集計
  Map<String, int> buildYearlyPaymentBySource(
      List<Salary> salaries,
      int year,
      PaymentSource selectedSource,
      ) {
    final Map<String, int> result = {};

    for (final salary in salaries) {
      if (salary.createdAt.year != year) continue;

      final source = salary.source ?? DummySource.unSetDummySource;

      if (selectedSource.name != DummySource.ALL_TITLE &&
          source.name != selectedSource.name) {
        continue;
      }

      result[source.id] =
          (result[source.id] ?? 0) + salary.paymentAmount;
    }

    return result;
  }

  /// 給料合計テーブル用データクラス
  void _applyYearlySummary() {
    final summary = SalaryAggregator.calculateYearlySummary(
        selectedSource: state.selectedSource,
        selectedYear: state.selectedYear,
        allSalaries: state.allSalaries
    );
    state = state.copyWith(
        yearlySalarySummary: summary
    );
  }
}

/// 月別合計データクラス
/// 生成日時
class MonthlySalarySummary {
  /// 生成日時(対象年月の1日が格納される)
  final DateTime createdAt;
  /// 対象年月の合計総支給額
  final int paymentAmount;
  /// 対象年月の合計手取り額
  final int netSalary;
  /// 対象年月の支払い元
  final PaymentSource? source;

  MonthlySalarySummary({
    required this.createdAt,
    required this.paymentAmount,
    required this.netSalary,
    required this.source,
  });
}

/// 給料合計テーブル用データクラス
class YearlySalarySummary {
  /// 当年(総支給)
  final int paymentAmount;
  /// 当年(手取り)
  final int netSalary;
  /// 前年差分(総支給)
  final int diffPaymentAmount;
  /// 前年差分(手取り)
  final int diffNetSalary;
  /// 当年夏季賞与(総支給)
  final int summerBonus;
  /// 当年冬季賞与(総支給)
  final int winterBonus;
  /// 前年差分夏季賞与(総支給)
  final int diffSummerBonus;
  /// 前年差分冬季賞与(総支給)
  final int diffWinterBonus;

  static YearlySalarySummary initial() {
    return const YearlySalarySummary(
      paymentAmount: 0,
      netSalary: 0,
      diffPaymentAmount: 0,
      diffNetSalary: 0,
      summerBonus: 0,
      winterBonus: 0,
      diffSummerBonus: 0,
      diffWinterBonus: 0,
    );
  }

  const YearlySalarySummary({
    required this.paymentAmount,
    required this.netSalary,
    required this.diffPaymentAmount,
    required this.diffNetSalary,
    required this.summerBonus,
    required this.winterBonus,
    required this.diffSummerBonus,
    required this.diffWinterBonus,
  });
}

/// 10年分棒グラフ用データクラス
class YearlyPaymentChartData {
  final List<int> years;
  final List<int> amounts;
  final double maxY;

  const YearlyPaymentChartData({
    required this.years,
    required this.amounts,
    required this.maxY,
  });

  bool get isEmpty => years.isEmpty;
}
