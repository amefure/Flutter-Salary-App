import 'package:salary/core/models/salary.dart';

/// テスト用のダミー給料データ作成
Salary fakeSalary({
  String? id,
  int paymentAmount = 300000,
  int deductionAmount = 600000, // 必要に応じて調整
  int netSalary = 240000,
  DateTime? date,
  bool isBonus = false,
  String memo = '',
  Iterable<AmountItem> paymentAmountItems = const [],
  Iterable<AmountItem> deductionAmountItems = const [],
  PaymentSource? source,
}) {
  return Salary(
    id ?? 'test_salary_id',
    paymentAmount,
    deductionAmount,
    netSalary,
    date ?? DateTime.now(),
    isBonus,
    memo,
    paymentAmountItems: paymentAmountItems,
    deductionAmountItems: deductionAmountItems,
    source: source ?? fakePaymentSource(),
  );
}

/// テスト用のダミーデータ作成関数
PaymentSource fakePaymentSource({
  String id = 'default_id',
  String name = 'テスト支払元',
  int color = 0xFFFFFFFF,
  bool isMain = false,
  bool isPublicName = false,
  int? publicUserId,
}) {
  return PaymentSource(id, name, color, isMain, isPublicName, publicUserId: publicUserId);
}