import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/models/salary.dart';

class AnnualWithholdingState {
  final List<AnnualWithholding> items;
  final List<PaymentSource> paymentSources;

  const AnnualWithholdingState({
    required this.items,
    required this.paymentSources,
  });

  factory AnnualWithholdingState.initial() {
    return const AnnualWithholdingState(items: [], paymentSources: []);
  }

  AnnualWithholdingState copyWith({
    List<AnnualWithholding>? items,
    List<PaymentSource>? paymentSources,
  }) {
    return AnnualWithholdingState(
      items: items ?? this.items,
      paymentSources: paymentSources ?? this.paymentSources,
    );
  }
}
