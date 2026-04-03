
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

class ListSalaryState {
  /// Salary
  List<Salary> salaries = [];
  /// Salaryに存在する支払い元リスト
  List<PaymentSource> sourceList = [];
  /// 表示中の支払い元
  late PaymentSource selectedSource = DummySource.allDummySource;
  /// Salary
  SalarySortOrder sortOrder = SalarySortOrder.dateDesc;

  ListSalaryState({
    required this.salaries,
    required this.sourceList,
    required this.selectedSource,
    required this.sortOrder,
  });

  static ListSalaryState initial() {
    return ListSalaryState(
        salaries: [],
        sourceList: [],
        selectedSource: DummySource.allDummySource,
        sortOrder: SalarySortOrder.dateDesc
    );
  }

  ListSalaryState copyWith({
    List<Salary>? salaries,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource,
    SalarySortOrder? sortOrder
  }) {
    return ListSalaryState(
      salaries: salaries ?? this.salaries,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
