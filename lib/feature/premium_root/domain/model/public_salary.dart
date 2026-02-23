import 'package:salary/feature/premium_root/domain/model/public_payment_source.dart';
import 'package:salary/feature/premium_root/domain/model/public_user.dart';

class PublicSalary {

  final String id;
  final int paymentAmount;
  final int deductionAmount;
  final int netSalary;
  final DateTime paidAt;
  final bool isBonus;
  final PublicPaymentSource? paymentSource;
  final PublicUser user;

  PublicSalary({
    required this.id,
    required this.paymentAmount,
    required this.deductionAmount,
    required this.netSalary,
    required this.paidAt,
    required this.isBonus,
    required this.paymentSource,
    required this.user,
  });

  bool get isHighIncome => netSalary >= 10000000;

  String get formattedIncome =>
      '${(netSalary / 10000).toStringAsFixed(0)}万円';
}
