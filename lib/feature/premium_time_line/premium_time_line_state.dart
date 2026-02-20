
import 'package:salary/core/models/salary.dart';

class PremiumTimeLineState {
  final List<Salary> salaries;
  final List<PaymentSource> paymentSources;

  PremiumTimeLineState({
    required this.salaries,
    required this.paymentSources,
  });

  static PremiumTimeLineState initial() {
    return PremiumTimeLineState(
      salaries: List.empty(),
      paymentSources: List.empty(),
    );
  }

  PremiumTimeLineState copyWith({
    List<Salary>? salaries,
    List<PaymentSource>? paymentSources,
  }) {
    return PremiumTimeLineState(
      salaries: salaries ?? this.salaries,
      paymentSources: paymentSources ?? this.paymentSources,
    );
  }
}
