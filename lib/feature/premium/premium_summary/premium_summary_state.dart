import 'package:salary/core/config/profile_config.dart';
import 'package:salary/feature/premium/data/dto/summary_dto.dart';

class PremiumSummaryState {
  final SummaryDto? summaryDto;
  final int selectedYear;
  final Job selectedJob;
  final String? selectedRegion;
  final String? selectedAgeRange;

  bool get isUndefinedJob => selectedJob == ProfileConfig.undefinedJob;

  PremiumSummaryState({
    required this.summaryDto,
    required this.selectedYear,
    required  this.selectedJob,
    required this.selectedRegion,
    required this.selectedAgeRange,
  });

  static PremiumSummaryState initial() {
    return PremiumSummaryState(
      summaryDto: null,
      selectedYear: 2026,
      selectedJob: ProfileConfig.undefinedJob,
      selectedRegion: null,
      selectedAgeRange: null,
    );
  }

  PremiumSummaryState copyWith({
    SummaryDto? summaryDto,
    int? selectedYear,
    Job? selectedJob,
    String? Function()? selectedRegion,
    String? Function()? selectedAgeRange,
  }) {
    return PremiumSummaryState(
      summaryDto: summaryDto ?? this.summaryDto,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedRegion: selectedRegion != null ? selectedRegion() : this.selectedRegion,
      selectedAgeRange: selectedAgeRange != null ? selectedAgeRange() : this.selectedAgeRange,
    );
  }
}