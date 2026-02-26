import 'package:salary/feature/premium/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium/data/dto/ranking_dto.dart';

class SummaryDto {
  final List<RankingDto> top10;
  final List<IncomeDistributionDto> distribution;

  SummaryDto({
    required this.top10,
    required this.distribution,
  });

  factory SummaryDto.fromJson(Map<String, dynamic> json) {
    return SummaryDto(
      top10: (json['top10'] as List)
          .map((e) => RankingDto.fromJson(e))
          .toList(),
      distribution: (json['distribution'] as List)
          .map((e) => IncomeDistributionDto.fromJson(e))
          .toList(),
    );
  }
}