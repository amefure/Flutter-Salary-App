class IncomeDistributionDto {
  final String incomeRange;
  final int userCount;

  IncomeDistributionDto({
    required this.incomeRange,
    required this.userCount,
  });

  factory IncomeDistributionDto.fromJson(Map<String, dynamic> json) {
    return IncomeDistributionDto(
      incomeRange: json['income_range'],
      userCount: json['user_count'],
    );
  }
}

const _incomeRanges = [
  '0〜100万',
  '100〜200万',
  '200〜300万',
  '300〜400万',
  '400〜500万',
  '500〜600万',
  '600〜700万',
  '700〜800万',
  '800〜900万',
  '900〜1000万',
  '1000〜1100万',
  '1100〜1200万',
  '1200〜1300万',
  '1300〜1400万',
  '1400万〜',
];

extension DistributionExtension on List<IncomeDistributionDto> {
  List<IncomeDistributionDto> withZeroFilled() {
    final map = {
      for (final e in this) e.incomeRange: e.userCount,
    };

    return _incomeRanges.map((range) {
      return IncomeDistributionDto(
        incomeRange: range,
        userCount: map[range] ?? 0,
      );
    }).toList();
  }
}