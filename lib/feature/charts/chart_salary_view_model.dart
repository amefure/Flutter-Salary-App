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
    _applyYearlySummary();
    _applyYearlyPaymentBarChartData();
  }

  /// 支払い元切り替え
  void changeSource(PaymentSource source) {
    state = state.copyWith(selectedSource: source);
    _applyYearlySummary();
    _applyYearlyPaymentBarChartData();
  }

  /// 年数切り替え
  void changeYear(int offset) {
    state = state.copyWith(
      selectedYear: state.selectedYear + offset,
    );
    /// 年数の変更の場合はサマリーのみ更新
    _applyYearlySummary();
  }

  /// グラフ表示切り替え
  void toggleChartDisplayMode() {
    state = state.copyWith(
      chartDisplayMode: state.chartDisplayMode.opposite,
    );
  }

  /// 「③ 年別合計金額(10年間)棒グラフ用データ」を計算し反映
  void _applyYearlyPaymentBarChartData() {
    final chartData = SalaryAggregator.buildYearlyPaymentBarChartData(
        selectedSource: state.selectedSource,
        groupedBySource: state.groupedBySource
    );
    state = state.copyWith(
        yearlyPaymentChartData: chartData
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
        yearlySalarySummary: summary
    );
  }
}

/// ① 月別合計金額グラフアイテムデータクラス
/// 支払い元ごとの月単位の総支給額・手取り額の合計を表示
/// これをリストで保持して1年分表示する
class MonthlySalarySummaryChartItem {
  /// 生成日時(対象年月の1日が格納される)
  final DateTime createdAt;
  /// 対象年月の合計総支給額
  final int paymentAmount;
  /// 対象年月の合計手取り額
  final int netSalary;
  /// 対象年月の支払い元(未設定もあり)
  final PaymentSource? source;

  MonthlySalarySummaryChartItem({
    required this.createdAt,
    required this.paymentAmount,
    required this.netSalary,
    required this.source,
  });
}

/// ② 年収 & 賞与サマリーデータクラス
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

/// ③ 年別合計金額(10年間)棒グラフ用データクラス
/// 年ごとの総支給額を支払い元は識別にせずに統合して計算
/// グラフで表示すべきデータ全体を保持する
class YearlyPaymentChartData {
  final List<int> years;
  final List<int> amounts;
  final double maxY;

  const YearlyPaymentChartData({
    required this.years,
    required this.amounts,
    required this.maxY,
  });

  static YearlyPaymentChartData initial() {
    return const YearlyPaymentChartData(
        years: [],
        amounts: [],
        maxY: 0
    );
  }

  bool get isEmpty => years.isEmpty;
}
