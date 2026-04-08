/// ② 年収 & 賞与サマリーデータクラス
class YearlySalarySummary {
  /// 当年(総支給)
  final int paymentAmount;
  /// 当年(手取り)
  final int netSalary;
  /// 前年差分(総支給)
  final int diffPaymentAmount;
  /// 前年差分(手取り)
  final int diffNetSalary;
  /// 当年夏季賞与(総支給)
  final int summerBonus;
  /// 当年冬季賞与(総支給)
  final int winterBonus;
  /// 前年差分夏季賞与(総支給)
  final int diffSummerBonus;
  /// 前年差分冬季賞与(総支給)
  final int diffWinterBonus;

  static YearlySalarySummary initial() {
    return const YearlySalarySummary(
      paymentAmount: 0,
      netSalary: 0,
      diffPaymentAmount: 0,
      diffNetSalary: 0,
      summerBonus: 0,
      winterBonus: 0,
      diffSummerBonus: 0,
      diffWinterBonus: 0,
    );
  }

  const YearlySalarySummary({
    required this.paymentAmount,
    required this.netSalary,
    required this.diffPaymentAmount,
    required this.diffNetSalary,
    required this.summerBonus,
    required this.winterBonus,
    required this.diffSummerBonus,
    required this.diffWinterBonus,
  });
}