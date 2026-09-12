import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/models/annual_target.dart';
import 'package:salary/feature/charts/domain/annual_target_calculator.dart';
import '../../../helpers/dummy_data_helper.dart';

void main() {
  const calculator = AnnualTargetCalculator();

  test('当年の全支払い元の実績と進捗を計算する', () {
    final target = AnnualTarget(2026, 1_200_000);
    final salaries = [
      fakeSalary(
        id: 'salary-1',
        paymentAmount: 100_000,
        date: DateTime(2026, 1, 1),
      ),
      fakeSalary(
        id: 'salary-2',
        paymentAmount: 200_000,
        date: DateTime(2026, 2, 1),
      ),
      fakeSalary(
        id: 'salary-3',
        paymentAmount: 999_999,
        date: DateTime(2025, 12, 1),
      ),
    ];

    final result = calculator.calculate(
      target: target,
      salaries: salaries,
      now: DateTime(2026, 3, 10),
    );

    expect(result.actualAmount, 300_000);
    expect(result.projectedAmount, 1_200_000);
    expect(result.remainingAmount, 900_000);
    expect(result.achievementPercent, 25);
    expect(result.clampedProgress, 0.25);
  });

  test('達成率が100%を超えても表示値は維持し、バーだけを上限にする', () {
    final result = calculator.calculate(
      target: AnnualTarget(2026, 100),
      salaries: [
        fakeSalary(
          id: 'salary-1',
          paymentAmount: 250,
          date: DateTime(2026, 1, 1),
        ),
      ],
      now: DateTime(2026, 1, 10),
    );

    expect(result.achievementPercent, 250);
    expect(result.remainingAmount, 0);
    expect(result.clampedProgress, 1);
  });

  test('実績0円の着地予想は0円', () {
    final result = calculator.calculate(
      target: AnnualTarget(2026, 1_000),
      salaries: const [],
      now: DateTime(2026, 12, 1),
    );

    expect(result.projectedAmount, 0);
    expect(result.achievementPercent, 0);
  });
}
