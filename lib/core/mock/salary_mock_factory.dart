import 'package:realm/realm.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/thema_color.dart';

class SalaryMockFactory {

  static List<Salary> allGenerateYears() {
    // 一昨年給料(メイン)
    List<Salary> salaries = _generateYear(year: DateTime.now().year - 2, baseAmount: 200000);
    // 前年給料(メイン)
    salaries += _generateYear(year: DateTime.now().year - 1, baseAmount: 250000);
    // 当年給料(メイン)
    salaries += _generateYear(year: DateTime.now().year);

    // 一昨年給料(サブ)
    salaries += _generateYear(year: DateTime.now().year - 2, baseAmount: 8000, isMainSource: false);
    // 前年給料(サブ)
    salaries += _generateYear(year: DateTime.now().year - 1, baseAmount: 10000, isMainSource: false);
    // 当年給料(サブ)
    salaries += _generateYear(year: DateTime.now().year, baseAmount: 12000, isMainSource: false);

    return salaries;
  }

  /// 指定年の給料モックを12か月分生成
  static List<Salary> _generateYear({
    required int year,
    int baseAmount = 300000,
    bool isMainSource = true,
  }) {
    return List.generate(12, (index) {
      final month = index + 1;
      final isBonus = month == 6 || month == 12;

      // ボーナス金額(2ヶ月分)
      final bonus = baseAmount * 2;
      // 月給料ベース + 月数 × 4000
      final amount = baseAmount + month * 4000;
      final paymentAmount = isBonus ?  bonus: amount;
      final deductionAmount = (paymentAmount * 0.18).round();
      final netSalary = paymentAmount - deductionAmount;

      return Salary(
        Uuid.v4().toString(),
        paymentAmount,
        deductionAmount,
        netSalary,
        DateTime(year, month, 25),
        paymentAmountItems: _paymentItems(paymentAmount, isBonus),
        deductionAmountItems: _deductionItems(deductionAmount),
        source: isMainSource ? _mainSource : _subSource,
        isBonus,
        isBonus ? '$month月 ボーナス' : '$month月分の給料',
      );
    });
  }

  /// 総支給の内訳
  static List<AmountItem> _paymentItems(int total, bool isBonus) {
    if (isBonus) {
      return [
        AmountItem(
          Uuid.v4().toString(),
          '賞与',
          total,
        ),
      ];
    }

    return [
      AmountItem(
        Uuid.v4().toString(),
        '基本給',
        (total * 0.8).round(),
      ),
      AmountItem(
        Uuid.v4().toString(),
        '残業代',
        (total * 0.2).round(),
      ),
    ];
  }

  /// 控除内訳
  static List<AmountItem> _deductionItems(int total) {
    return [
      AmountItem(
        Uuid.v4().toString(),
        '健康保険',
        (total * 0.4).round(),
      ),
      AmountItem(
        Uuid.v4().toString(),
        '年金',
        (total * 0.6).round(),
      ),
    ];
  }

  static const _mainSourceId = 'ac17429c-064a-4bb6-a3a6-091325c1119a';
  static const _subSourceId  = 'ac17429c-064a-4bb6-a3a6-091325c1119b';

  static final PaymentSource _mainSource = PaymentSource(
    _mainSourceId,
    '株式会社ame',
    ThemaColor.orange.value,
    true,
    false,
    publicUserId: null,
    memo: '本業',
  );

  static final PaymentSource _subSource = PaymentSource(
    _subSourceId,
    'ABCデザイン',
    ThemaColor.yellow.value,
    false,
    false,
    publicUserId: null,
    memo: '副業',
  );
}
