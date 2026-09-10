import 'package:salary/core/models/salary.dart';

class SalarySummary {
  final List<Salary> grossRanking;
  final List<Salary> netRanking;
  /// 合計総支給
  final int grossTotal;
  /// 合計手取り
  final int netTotal;
  final double averageMonthlyGross;
  final double averageMonthlyNet;
  final int monthCount;
  /// 平均年収（総支給）
  final double averageYearlyGross;
  /// 平均年収（手取り）
  final double averageYearlyNet;
  final int yearCount;
  /// ボーナス合計
  final int bonusTotal;

  const SalarySummary({
    required this.grossRanking,
    required this.netRanking,
    required this.grossTotal,
    required this.netTotal,
    required this.averageMonthlyGross,
    required this.averageMonthlyNet,
    required this.monthCount,
    required this.averageYearlyGross,
    required this.averageYearlyNet,
    required this.yearCount,
    required this.bonusTotal
  });

  bool get isEmpty => grossRanking.isEmpty && netRanking.isEmpty;

  // 総支給額に対するボーナス比率（%）を算出するgetter
  double get bonusRatio {
    if (grossTotal == 0) return 0.0;
    return (bonusTotal / grossTotal) * 100;
  }
}