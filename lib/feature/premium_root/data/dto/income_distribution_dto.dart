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