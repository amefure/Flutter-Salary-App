import 'package:salary/feature/premium/data/dto/summary_dto.dart';

class PremiumSummaryState {
  final SummaryDto? summaryDto;
  final int selectedYear;
  final String? selectedRegion;
  final String? selectedAgeRange;

  PremiumSummaryState({
    required this.summaryDto,
    required this.selectedYear,
    required this.selectedRegion,
    required this.selectedAgeRange,
  });

  static PremiumSummaryState initial() {
    return PremiumSummaryState(
      summaryDto: null,
      selectedYear: 2026,
      selectedRegion: null,
      selectedAgeRange: null,
    );
  }

  PremiumSummaryState copyWith({
    SummaryDto? summaryDto,
    int? selectedYear,
    String? Function()? selectedRegion,
    String? Function()? selectedAgeRange,
  }) {
    return PremiumSummaryState(
      summaryDto: summaryDto ?? this.summaryDto,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedRegion: selectedRegion != null ? selectedRegion() : this.selectedRegion,
      selectedAgeRange: selectedAgeRange != null ? selectedAgeRange() : this.selectedAgeRange,
    );
  }
}