import 'package:salary/core/models/salary.dart';

class PublicSalaryState {
  final List<Salary> salaries;
  final List<PaymentSource> paymentSources;
  final bool isMainPublic;

  PublicSalaryState({
    required this.salaries,
    required this.paymentSources,
    required this.isMainPublic,
  });

  static PublicSalaryState initial() {
    return PublicSalaryState(
        salaries: List.empty(),
        paymentSources: List.empty(),
        isMainPublic: false
    );
  }

  PublicSalaryState copyWith({
    List<Salary>? salaries,
    List<PaymentSource>? paymentSources,
    bool? isMainPublic
  }) {
    return PublicSalaryState(
        salaries: salaries ?? this.salaries,
        paymentSources: paymentSources ?? this.paymentSources,
        isMainPublic: isMainPublic ?? this.isMainPublic
    );
  }
}