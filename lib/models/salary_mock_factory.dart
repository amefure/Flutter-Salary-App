import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';

class SalaryMockFactory {
  /// 指定年の給料モックを12か月分生成
  static List<Salary> generateYear({
    required int year,
  }) {
    return List.generate(12, (index) {
      final month = index + 1;
      final isBonus = month == 6 || month == 12;

      final paymentAmount = isBonus ? 800000 : 300000 + month * 2000;
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
        source: _paymentSource(),
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

  /// 支払い元（固定）
  static PaymentSource _paymentSource() {
    return PaymentSource(
      'source_company',
      '株式会社サンプル',
      ThemaColor.blue.value,
      memo: '本業',
    );
  }
}
