import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/payment_source/data/payment_source_dto.dart';
import 'package:salary/feature/salary/data/amount_item_dto.dart';

class SalaryDto {

  final String id;
  final int paymentAmount;
  final int deductionAmount;
  final int netSalary;
  final DateTime paidAt;
  final bool isBonus;
  final String memo;
  final List<AmountItemDto> paymentItems;
  final List<AmountItemDto> deductionItems;
  final PaymentSourceDto? paymentSource;

  SalaryDto({
    required this.id,
    required this.paymentAmount,
    required this.deductionAmount,
    required this.netSalary,
    required this.paidAt,
    required this.isBonus,
    required this.memo,
    required this.paymentItems,
    required this.deductionItems,
    required this.paymentSource,
  });

  factory SalaryDto.fromJson(Map<String, dynamic> json) {
    return SalaryDto(
      id: json[SalaryJsonKeys.id],
      paymentAmount: json[SalaryJsonKeys.paymentAmount],
      deductionAmount: json[SalaryJsonKeys.deductionAmount],
      netSalary: json[SalaryJsonKeys.netSalary],
      paidAt: DateTime.parse(json[SalaryJsonKeys.paidAt]),
      isBonus: json[SalaryJsonKeys.isBonus],
      memo: json[SalaryJsonKeys.memo] ?? '',
      paymentItems: (json[SalaryJsonKeys.paymentItems] as List)
          .map((e) => AmountItemDto.fromJson(e))
          .toList(),
      deductionItems: (json[SalaryJsonKeys.deductionItems] as List)
          .map((e) => AmountItemDto.fromJson(e))
          .toList(),
      paymentSource: json[SalaryJsonKeys.paymentSource] != null
          ? PaymentSourceDto.fromJson(json[SalaryJsonKeys.paymentSource])
          : null,
    );
  }

  Salary toDomain() {
    return Salary(
      id,
      paymentAmount,
      deductionAmount,
      netSalary,
      paidAt.toLocal(),
      isBonus,
      memo,
      paymentAmountItems: paymentItems.map((e) => e.toDomain()).toList(),
      deductionAmountItems: deductionItems.map((e) => e.toDomain()).toList(),
      source: paymentSource?.toDomain(),
    );
  }

}
