import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';

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
        'salary_$year\_$month',
        paymentAmount,
        deductionAmount,
        netSalary,
        DateTime(year, month, 25),
        paymentAmountItems: _paymentItems(paymentAmount, isBonus),
        deductionAmountItems: _deductionItems(deductionAmount),
        source: isMainSource ? _paymentMainSource() : _paymentSubSource(),
        isBonus,
        isBonus ? '${month}月 ボーナス' : '${month}月分の給料',
      );
    });
  }

  /// 総支給の内訳
  static List<AmountItem> _paymentItems(int total, bool isBonus) {
    if (isBonus) {
      return [
        AmountItem(
          'bonus',
          '賞与',
          total,
        ),
      ];
    }

    return [
      AmountItem(
        'base',
        '基本給',
        (total * 0.8).round(),
      ),
      AmountItem(
        'overtime',
        '残業代',
        (total * 0.2).round(),
      ),
    ];
  }

  /// 控除内訳
  static List<AmountItem> _deductionItems(int total) {
    return [
      AmountItem(
        'health',
        '健康保険',
        (total * 0.4).round(),
      ),
      AmountItem(
        'pension',
        '年金',
        (total * 0.6).round(),
      ),
    ];
  }

  /// 支払い元
  static PaymentSource _paymentMainSource() {
    return PaymentSource(
      'source_main_company',
      '株式会社ame',
      ThemaColor.orange.value,
      true,
      memo: '本業',
    );
  }

  /// 支払い元
  static PaymentSource _paymentSubSource() {
    return PaymentSource(
      'source_sub_company',
      'ABCデザイン',
      ThemaColor.yellow.value,
      false,
      memo: '副業',
    );
  }
}
