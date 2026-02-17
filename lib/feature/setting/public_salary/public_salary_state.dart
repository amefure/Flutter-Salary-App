import 'package:salary/core/models/salary.dart';

class PublicSalaryState {
  final List<PaymentSource> paymentSources;

  PublicSalaryState({
    required this.paymentSources,
  });

  static PublicSalaryState initial() {
    return PublicSalaryState(
        paymentSources: List.empty(),
    );
  }

  PublicSalaryState copyWith({
    List<PaymentSource>? paymentSources,
  }) {
    return PublicSalaryState(
        paymentSources: paymentSources ?? this.paymentSources,
    );
  }
}