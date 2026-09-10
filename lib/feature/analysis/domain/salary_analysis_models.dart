import 'package:salary/core/models/salary.dart';

class SalarySummary {
  final List<Salary> grossRanking;
  final List<Salary> netRanking;
  final int grossTotal;
  final int netTotal;
  final double averageMonthlyGross;
  final double averageMonthlyNet;
  final int monthCount;
  /// 平均年収（総支給）
  final double averageYearlyGross;
  /// 平均年収（手取り）
  final double averageYearlyNet;
  final int yearCount;

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
  });

  bool get isEmpty => grossRanking.isEmpty && netRanking.isEmpty;
}