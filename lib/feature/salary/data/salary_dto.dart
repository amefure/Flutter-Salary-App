import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/payment_source/data/payment_source_dto.dart';
import 'package:salary/feature/salary/data/amount_item_dto.dart';

class SalaryDto {

  static const keyId = 'id';
  static const keyPaymentAmount = 'payment_amount';
  static const keyDeductionAmount = 'deduction_amount';
  static const keyNetSalary = 'net_salary';
  static const keyPaidAt = 'paid_at';
  static const keyIsBonus = 'is_bonus';
  static const keyMemo = 'memo';
  static const keyPaymentItems = 'payment_items';
  static const keyDeductionItems = 'deduction_items';
  static const keyPaymentSource = 'payment_source';
  static const keyPublication = 'publication';

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
      id: json[keyId],
      paymentAmount: json[keyPaymentAmount],
      deductionAmount: json[keyDeductionAmount],
      netSalary: json[keyNetSalary],
      paidAt: DateTime.parse(json[keyPaidAt]),
      isBonus: json[keyIsBonus],
      memo: json[keyMemo] ?? '',
      paymentItems: (json[keyPaymentItems] as List)
          .map((e) => AmountItemDto.fromJson(e))
          .toList(),
      deductionItems: (json[keyDeductionItems] as List)
          .map((e) => AmountItemDto.fromJson(e))
          .toList(),
      paymentSource: json[keyPaymentSource] != null
          ? PaymentSourceDto.fromJson(json[keyPaymentSource])
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
