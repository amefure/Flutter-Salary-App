import 'package:salary/core/models/salary.dart';

/// テスト用のダミー給料データ作成
Salary fakeSalary({
  String? id,
  int paymentAmount = 300000,
  int deductionAmount = 600000,
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
    source: source,
  );
}

/// 変数として定義して当てはめないと別のオブジェクトとしてみなされる
final _dummySource = fakePaymentSource();
final dummySalaries = [
  // 2024年1月
  fakeSalary(paymentAmount: 1000, date: DateTime(2026, 1, 1), source: _dummySource),
  // 2024年1月
  fakeSalary(paymentAmount: 2000, date: DateTime(2026, 1, 15), source: _dummySource),
  // 2024年2月
  fakeSalary(paymentAmount: 3000, date: DateTime(2026, 2, 1), source: _dummySource),
];

/// テスト用のダミーデータ作成関数
PaymentSource fakePaymentSource({
  String id = 'default_id',
  String name = '株式会社Ame',
  int color = 0xFFFFFFFF,
  bool isMain = false,
  bool isPublicName = false,
  int? publicUserId,
}) {
  return PaymentSource(id, name, color, isMain, isPublicName, publicUserId: publicUserId);
}