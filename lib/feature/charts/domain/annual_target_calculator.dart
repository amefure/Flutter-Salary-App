import 'dart:math' as math;

import 'package:salary/core/models/annual_target.dart';
import 'package:salary/core/models/salary.dart';

/// 年間目標の進捗表示に必要な値。
class AnnualTargetProgress {
  final int targetAmount;
  final int actualAmount;
  final int projectedAmount;
  final int remainingAmount;
  final double achievementRate;

  const AnnualTargetProgress({
    required this.targetAmount,
    required this.actualAmount,
    required this.projectedAmount,
    required this.remainingAmount,
    required this.achievementRate,
  });

  int get achievementPercent => achievementRate.round();

  /// バーだけは0〜100%に制限する。達成率の表示値は制限しない。
  double get clampedProgress =>
      (achievementRate / 100).clamp(0.0, 1.0).toDouble();
}

/// 年間目標に対する給与実績の計算を担当するドメインロジック。
class AnnualTargetCalculator {
  const AnnualTargetCalculator();

  AnnualTargetProgress calculate({
    required AnnualTarget target,
    required List<Salary> salaries,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final actualAmount = salaries
        .where((salary) => salary.createdAt.year == currentDate.year)
        .fold<int>(0, (sum, salary) => sum + salary.paymentAmount);
    final elapsedMonths = currentDate.month;
    final projectedAmount =
        actualAmount == 0 ? 0 : (actualAmount / elapsedMonths * 12).round();
    final remainingAmount =
        math.max(target.targetAmount - actualAmount, 0).toInt();

    return AnnualTargetProgress(
      targetAmount: target.targetAmount,
      actualAmount: actualAmount,
      projectedAmount: projectedAmount,
      remainingAmount: remainingAmount,
      achievementRate: actualAmount / target.targetAmount * 100,
    );
  }
}
