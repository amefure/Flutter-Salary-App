import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/charts/chart_display_mode.dart';

class ChartSalaryState {
  /// 全てのSalary一覧
  final List<Salary> allSalaries;
  /// 支払い元でグルーピングした総データ
  /// Keyは支払い元のID
  final Map<String, List<MonthlySalarySummary>> groupedBySource;
  /// Salaryに存在する支払い元リスト
  final List<PaymentSource> sourceList;
  /// 表示中の支払い元
  final PaymentSource selectedSource;
  /// 表示中の年月
  final int selectedYear;
  /// グラフ表示モード
  final ChartDisplayMode displayMode;
  /// 円グラフ表示用データ
  final Map<PaymentSource, int> yearlyPaymentBySource;
  /// 給料合計テーブル表示用データ
  final YearlySalarySummary yearlySalarySummary;

  ChartSalaryState({
    required this.allSalaries,
    required this.groupedBySource,
    required this.sourceList,
    required this.selectedSource,
    required this.selectedYear,
    required this.displayMode,
    required this.yearlyPaymentBySource,
    required this.yearlySalarySummary,
  });

  static ChartSalaryState initial() {
    return ChartSalaryState(
        allSalaries: [],
        groupedBySource: {},
        sourceList: [],
        selectedSource: DummySource.allDummySource,
        selectedYear: DateTime.now().year,
        displayMode: ChartDisplayMode.line,
        yearlyPaymentBySource: {},
        yearlySalarySummary: YearlySalarySummary.initial()
    );
  }

  ChartSalaryState copyWith({
    List<Salary>? allSalaries,
    Map<String, List<MonthlySalarySummary>>? groupedBySource,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource,
    int? selectedYear,
    ChartDisplayMode? displayMode,
    Map<PaymentSource, int>? yearlyPaymentBySource,
    YearlySalarySummary? yearlySalarySummary,
  }) {
    return ChartSalaryState(
      allSalaries: allSalaries ?? this.allSalaries,
      groupedBySource: groupedBySource ?? this.groupedBySource,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedYear: selectedYear ?? this.selectedYear,
      displayMode: displayMode ?? this.displayMode,
      yearlyPaymentBySource: yearlyPaymentBySource ?? this.yearlyPaymentBySource,
      yearlySalarySummary: yearlySalarySummary ?? this.yearlySalarySummary,
    );
  }
}
