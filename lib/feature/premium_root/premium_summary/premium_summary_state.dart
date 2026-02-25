import 'package:salary/feature/premium_root/data/dto/summary_dto.dart';

class PremiumSummaryState {

  final SummaryDto? summaryDto;

  PremiumSummaryState({
    required this.summaryDto,
  });

  static PremiumSummaryState initial() {
    return PremiumSummaryState(
      summaryDto: null,
    );
  }

  PremiumSummaryState copyWith({
    SummaryDto? summaryDto,
  }) {
    return PremiumSummaryState(
      summaryDto: summaryDto ?? this.summaryDto,
    );
  }
}
