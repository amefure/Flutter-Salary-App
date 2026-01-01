import 'package:salary/models/salary.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/charts/chart_display_mode.dart';
import 'package:salary/models/thema_color.dart';

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

  ChartSalaryState({
    required this.allSalaries,
    required this.groupedBySource,
    required this.sourceList,
    required this.selectedSource,
    required this.selectedYear,
    required this.displayMode,
    required this.yearlyPaymentBySource,
  });

  static ChartSalaryState initial() {
    return ChartSalaryState(
      allSalaries: [],
      groupedBySource: {},
      sourceList: [],
      selectedSource: PaymentSource('', ChartSalaryViewModel.ALL_TITLE, ThemaColor.blue.value),
      selectedYear: DateTime.now().year,
      displayMode: ChartDisplayMode.line,
      yearlyPaymentBySource: {},
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
  }) {
    return ChartSalaryState(
      allSalaries: allSalaries ?? this.allSalaries,
      groupedBySource: groupedBySource ?? this.groupedBySource,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedYear: selectedYear ?? this.selectedYear,
      displayMode: displayMode ?? this.displayMode,
      yearlyPaymentBySource: yearlyPaymentBySource ?? this.yearlyPaymentBySource,
    );
  }
}
