import 'package:salary/models/salary.dart';

class DetailSalaryState {
  final Salary? salary;

  DetailSalaryState({
    required this.salary
  });

  DetailSalaryState copyWith({
    Salary? salary,
  }) {
    return DetailSalaryState(
      salary: salary ?? this.salary,
    );
  }
}