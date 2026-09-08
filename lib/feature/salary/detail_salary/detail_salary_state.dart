import 'package:salary/core/models/salary.dart';

import 'package:salary/feature/salary/detail_salary/domain/salary_comparison.dart';

class DetailSalaryState {
  final Salary? salary;
  final SalaryComparison? comparison;

  DetailSalaryState({required this.salary, this.comparison});

  DetailSalaryState copyWith({Salary? salary, SalaryComparison? comparison}) {
    return DetailSalaryState(
      salary: salary ?? this.salary,
      comparison: comparison ?? this.comparison,
    );
  }
}
