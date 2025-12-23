import 'package:salary/models/salary.dart';
import 'package:salary/charts/chart_salary_view_model.dart';

class ChartSalaryState {
  /// 全てのSalary一覧
  final List<Salary> allSalaries;
  /// グラフに表示するためのグルーピングデータ
  final Map<String, List<MonthlySalarySummary>> groupedBySource;
  /// Salaryに存在する支払い元リスト
  final List<PaymentSource> sourceList;
  /// 表示中の支払い元
  final PaymentSource selectedSource;
  /// 表示中の年月
  final int selectedYear;

  ChartSalaryState({
    required this.allSalaries,
    required this.groupedBySource,
    required this.sourceList,
    required this.selectedSource,
    required this.selectedYear,
  });

  ChartSalaryState copyWith({
    List<Salary>? allSalaries,
    Map<String, List<MonthlySalarySummary>>? groupedBySource,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource,
    int? selectedYear,
  }) {
    return ChartSalaryState(
      allSalaries: allSalaries ?? this.allSalaries,
      groupedBySource: groupedBySource ?? this.groupedBySource,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}
