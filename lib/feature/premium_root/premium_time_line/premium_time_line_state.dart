
import 'package:salary/core/models/salary.dart';

class PremiumTimeLineState {
  final List<Salary> salaries;
  final List<PaymentSource> paymentSources;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  PremiumTimeLineState({
    required this.salaries,
    required this.paymentSources,
    required this.currentPage,
    required this.lastPage,
    required this.isLoadingMore,
  });

  static PremiumTimeLineState initial() {
    return PremiumTimeLineState(
        salaries: List.empty(),
        paymentSources: List.empty(),
        currentPage: 1,
        lastPage: 1,
        isLoadingMore: false
    );
  }

  PremiumTimeLineState copyWith({
    List<Salary>? salaries,
    List<PaymentSource>? paymentSources,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore
  }) {
    return PremiumTimeLineState(
      salaries: salaries ?? this.salaries,
      paymentSources: paymentSources ?? this.paymentSources,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
