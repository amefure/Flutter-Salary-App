import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/charts/domain/model/chart_display_mode.dart';
import 'package:salary/feature/charts/domain/model/monthly_salary_summary_chart_item.dart';
import 'package:salary/feature/charts/domain/model/yearly_payment_chart_data.dart';
import 'package:salary/feature/charts/domain/model/yearly_salary_summary.dart';

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


  /// 折れ線グラフ & 円グラフ
  /// Keyは支払い元のID
  final Map<String, List<MonthlySalarySummaryChartItem>> groupedBySource;

  /// 「① 月別合計金額グラフ」
  final List<List<MonthlySalarySummaryChartItem>> lineChartData;
  /// 「② 年収 & 賞与サマリーデータ」
  final YearlySalarySummary yearlySummaryData;
  /// 「③ 年別合計金額(10年間)棒グラフ用データ」
  final YearlyPaymentChartData yearlyBarChartData;

  ChartSalaryState({
    required this.allSalaries,
    required this.sourceList,
    required this.selectedSource,
    required this.selectedYear,
    required this.chartDisplayMode,

    required this.groupedBySource,
    required this.lineChartData,
    required this.yearlySummaryData,
    required this.yearlyBarChartData,
  });

  static ChartSalaryState initial() {
    return ChartSalaryState(
        allSalaries: [],
        sourceList: [],
        selectedSource: DummySource.allDummySource,
        selectedYear: DateTime.now().year,
        chartDisplayMode: ChartDisplayMode.line,

        groupedBySource: {},
        lineChartData: [],
        yearlySummaryData: YearlySalarySummary.initial(),
        yearlyBarChartData: YearlyPaymentChartData.initial()
    );
  }

  ChartSalaryState copyWith({
    List<Salary>? allSalaries,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource,
    int? selectedYear,
    ChartDisplayMode? chartDisplayMode,

    Map<String, List<MonthlySalarySummaryChartItem>>? groupedBySource,
    List<List<MonthlySalarySummaryChartItem>>? lineChartData,
    YearlySalarySummary? yearlySummaryData,
    YearlyPaymentChartData? yearlyBarChartData,
  }) {
    return ChartSalaryState(
      allSalaries: allSalaries ?? this.allSalaries,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedYear: selectedYear ?? this.selectedYear,
      chartDisplayMode: chartDisplayMode ?? this.chartDisplayMode,

      groupedBySource: groupedBySource ?? this.groupedBySource,
      lineChartData: lineChartData ?? this.lineChartData,
      yearlySummaryData: yearlySummaryData ?? this.yearlySummaryData,
      yearlyBarChartData: yearlyBarChartData ?? this.yearlyBarChartData,
    );
  }
}
