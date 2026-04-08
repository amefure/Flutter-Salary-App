import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/charts/chart_display_mode.dart';

class ChartSalaryState {
  /// 全てのSalary一覧(内部保持用)
  final List<Salary> allSalaries;
  /// 支払い元選択ピッカーに表示するリスト
  final List<PaymentSource> sourceList;
  /// 表示中の支払い元
  final PaymentSource selectedSource;
  /// 表示中の年月
  final int selectedYear;
  /// グラフ表示モード
  final ChartDisplayMode chartDisplayMode;

  /// 「① 月別合計金額グラフ」
  /// 折れ線グラフ & 円グラフ
  /// Keyは支払い元のID
  final Map<String, List<MonthlySalarySummaryChartItem>> groupedBySource;
  /// 「② 年収 & 賞与サマリーデータ」
  final YearlySalarySummary yearlySalarySummary;
  /// 「③ 年別合計金額(10年間)棒グラフ用データ」
  final YearlyPaymentChartData yearlyPaymentChartData;

  ChartSalaryState({
    required this.allSalaries,
    required this.sourceList,
    required this.selectedSource,
    required this.selectedYear,
    required this.chartDisplayMode,

    required this.groupedBySource,
    required this.yearlySalarySummary,
    required this.yearlyPaymentChartData,
  });

  static ChartSalaryState initial() {
    return ChartSalaryState(
        allSalaries: [],
        sourceList: [],
        selectedSource: DummySource.allDummySource,
        selectedYear: DateTime.now().year,
        chartDisplayMode: ChartDisplayMode.line,

        groupedBySource: {},
        yearlySalarySummary: YearlySalarySummary.initial(),
        yearlyPaymentChartData: YearlyPaymentChartData.initial()
    );
  }

  ChartSalaryState copyWith({
    List<Salary>? allSalaries,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource,
    int? selectedYear,
    ChartDisplayMode? chartDisplayMode,

    Map<String, List<MonthlySalarySummaryChartItem>>? groupedBySource,
    YearlySalarySummary? yearlySalarySummary,
    YearlyPaymentChartData? yearlyPaymentChartData,
  }) {
    return ChartSalaryState(
      allSalaries: allSalaries ?? this.allSalaries,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedYear: selectedYear ?? this.selectedYear,
      chartDisplayMode: chartDisplayMode ?? this.chartDisplayMode,

      groupedBySource: groupedBySource ?? this.groupedBySource,
      yearlySalarySummary: yearlySalarySummary ?? this.yearlySalarySummary,
      yearlyPaymentChartData: yearlyPaymentChartData ?? this.yearlyPaymentChartData,
    );
  }
}
