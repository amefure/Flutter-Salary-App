import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/premium/domain/model/public_payment_source.dart';
import 'package:salary/feature/premium/domain/model/public_user.dart';

class PublicSalary {

  final String id;
  final int paymentAmount;
  final int deductionAmount;
  final int netSalary;
  final DateTime paidAt;
  final bool isBonus;
  final List<AmountItem> paymentItems;
  final List<AmountItem> deductionItems;
  final PublicPaymentSource? paymentSource;
  final PublicUser user;

  PublicSalary({
    required this.id,
    required this.paymentAmount,
    required this.deductionAmount,
    required this.netSalary,
    required this.paidAt,
    required this.isBonus,
    required this.paymentItems,
    required this.deductionItems,
    required this.paymentSource,
    required this.user,
  });
}

extension PublicDetailSalaryMapper on PublicSalary {
  Salary toDomainLocal() {
    return Salary(
      id,
      paymentAmount,
      deductionAmount,
      netSalary,
      paidAt,
      isBonus,
      '', // メモは空
      paymentAmountItems: paymentItems,
      deductionAmountItems: deductionItems,
      source: paymentSource?.toDomainLocal(),
    );
  }
}
