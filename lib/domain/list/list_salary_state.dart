
import 'package:salary/models/dummy_source.dart';
import 'package:salary/models/salary.dart';

class ListSalaryState {
  /// Salary
  List<Salary> salaries = [];
  /// Salaryに存在する支払い元リスト
  List<PaymentSource> sourceList = [];
  /// 表示中の支払い元
  late PaymentSource selectedSource = DummySource.allDummySource;


  ListSalaryState({
    required this.salaries,
    required this.sourceList,
    required this.selectedSource
  });

  static ListSalaryState initial() {
    return ListSalaryState(
        salaries: [],
        sourceList: [],
        selectedSource: DummySource.allDummySource
    );
  }

  ListSalaryState copyWith({
    List<Salary>? salaries,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource
  }) {
    return ListSalaryState(
        salaries: salaries ?? this.salaries,
        sourceList: sourceList ?? this.sourceList,
        selectedSource: selectedSource ?? this.selectedSource
    );
  }
}
