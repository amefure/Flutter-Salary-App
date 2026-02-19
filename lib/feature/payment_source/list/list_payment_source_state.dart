import 'package:salary/core/models/salary.dart';

class ListPaymentSourceState {
  final List<PaymentSource> paymentSources;
  final Map<String, bool> expandedMap;

  ListPaymentSourceState({
    required this.paymentSources,
    required this.expandedMap
  });

  static ListPaymentSourceState initial() {
    return ListPaymentSourceState(
        paymentSources: List.empty(),
        expandedMap: <String, bool>{}
    );
  }

  ListPaymentSourceState copyWith({
    List<PaymentSource>? paymentSources,
    Map<String, bool>? expandedMap
  }) {
    return ListPaymentSourceState(
        paymentSources: paymentSources ?? this.paymentSources,
        expandedMap: expandedMap ?? this.expandedMap
    );
  }
}