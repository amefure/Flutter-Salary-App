import 'package:salary/feature/premium_root/data/dto/public_user_dto.dart';

class RankingDto {
  final int userId;
  final int year;
  final int totalPaymentAmount;
  final int totalNetSalary;
  final PublicUserDto user;

  RankingDto({
    required this.userId,
    required this.year,
    required this.totalPaymentAmount,
    required this.totalNetSalary,
    required this.user,
  });

  factory RankingDto.fromJson(Map<String, dynamic> json) {
    return RankingDto(
      userId: json['user_id'],
      year: json['year'],
      totalPaymentAmount: json['total_payment_amount'],
      totalNetSalary: json['total_net_salary'],
      user: PublicUserDto.fromJson(json['user']),
    );
  }
}