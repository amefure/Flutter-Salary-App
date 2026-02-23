import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/premium_root/data/dto/public_payment_source_dto.dart';
import 'package:salary/feature/premium_root/data/dto/public_user_dto.dart';
import 'package:salary/feature/premium_root/domain/model/public_salary.dart';

class PublicSalaryDto {

  final String id;
  final int paymentAmount;
  final int deductionAmount;
  final int netSalary;
  final DateTime paidAt;
  final bool isBonus;
  final PublicPaymentSourceDto? paymentSource;
  final PublicUserDto user;

  PublicSalaryDto({
    required this.id,
    required this.paymentAmount,
    required this.deductionAmount,
    required this.netSalary,
    required this.paidAt,
    required this.isBonus,
    required this.paymentSource,
    required this.user,
  });

  factory PublicSalaryDto.fromJson(Map<String, dynamic> json) {
    return PublicSalaryDto(
      id: json[SalaryJsonKeys.id],
      paymentAmount: json[SalaryJsonKeys.paymentAmount],
      deductionAmount: json[SalaryJsonKeys.deductionAmount],
      netSalary: json[SalaryJsonKeys.netSalary],
      paidAt: DateTime.parse(json[SalaryJsonKeys.paidAt]),
      isBonus: json[SalaryJsonKeys.isBonus],
      paymentSource: json[SalaryJsonKeys.paymentSource] != null
          ? PublicPaymentSourceDto.fromJson(json[SalaryJsonKeys.paymentSource])
          : null,
      user: PublicUserDto.fromJson(json[CommonJsonKeys.user]),
    );
  }
}

extension PublicSalaryDtoMapper on PublicSalaryDto {
  PublicSalary toDomain() {
    return PublicSalary(
      id: id,
      paymentAmount: paymentAmount,
      deductionAmount: deductionAmount,
      netSalary: netSalary,
      paidAt: paidAt,
      isBonus: isBonus,
      paymentSource: paymentSource?.toDomain(),
      user: user.toDomain(),
    );
  }
}

