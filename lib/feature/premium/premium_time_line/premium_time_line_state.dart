import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/premium/domain/model/public_salary.dart';

class PremiumTimeLineState {
  final List<PublicSalary> salaries;
  final List<PaymentSource> paymentSources;
  final int currentPage;
  final int lastPage;

  final Job selectedJob;
  final String? selectedRegion;
  final String? selectedAgeRange;

  final bool isLoadingMore;

  bool get isUndefinedJob => selectedJob == ProfileConfig.undefinedJob;

  PremiumTimeLineState({
    required this.salaries,
    required this.paymentSources,
    required this.currentPage,
    required this.lastPage,
    required this.selectedJob,
    required this.selectedRegion,
    required this.selectedAgeRange,
    required this.isLoadingMore,
  });

  static PremiumTimeLineState initial() {
    return PremiumTimeLineState(
        salaries: List.empty(),
        paymentSources: List.empty(),
        currentPage: 1,
        lastPage: 1,
        selectedJob: ProfileConfig.undefinedJob,
        selectedRegion: null,
        selectedAgeRange: null,
        isLoadingMore: false
    );
  }

  PremiumTimeLineState copyWith({
    List<PublicSalary>? salaries,
    List<PaymentSource>? paymentSources,
    int? currentPage,
    int? lastPage,
    Job? selectedJob,
    String? Function()? selectedRegion,
    String? Function()? selectedAgeRange,
    bool? isLoadingMore
  }) {
    return PremiumTimeLineState(
      salaries: salaries ?? this.salaries,
      paymentSources: paymentSources ?? this.paymentSources,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedRegion: selectedRegion != null ? selectedRegion() : this.selectedRegion,
      selectedAgeRange: selectedAgeRange != null ? selectedAgeRange() : this.selectedAgeRange,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
