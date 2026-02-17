import 'package:salary/core/models/salary.dart';

class PublicSalaryState {
  final List<Salary> salaries;
  final List<PaymentSource> paymentSources;

  PublicSalaryState({
    required this.salaries,
    required this.paymentSources,
  });

  static PublicSalaryState initial() {
    return PublicSalaryState(
      salaries: List.empty(),
      paymentSources: List.empty(),
    );
  }

  PublicSalaryState copyWith({
    List<Salary>? salaries,
    List<PaymentSource>? paymentSources,
  }) {
    return PublicSalaryState(
      salaries: salaries ?? this.salaries,
      paymentSources: paymentSources ?? this.paymentSources,
    );
  }
}