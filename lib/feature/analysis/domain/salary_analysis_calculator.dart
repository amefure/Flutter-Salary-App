import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/analysis/domain/salary_analysis_models.dart';

class SalaryAnalysisCalculator {
  const SalaryAnalysisCalculator();

  SalarySummary summarize(
      Iterable<Salary> salaries, {
        PaymentSource? selectedSource,
      }) {
    final source = selectedSource ?? DummySource.allDummySource;

    final filtered =
    salaries.where((salary) => _matchesFilter(salary, source)).toList();

    final monthTotals = <String, _MonthlyTotals>{};
    final yearTotals = <int, int>{};

    for (final salary in filtered) {
      final monthKey = '${salary.createdAt.year}-${salary.createdAt.month}';
      final totals = monthTotals.putIfAbsent(monthKey, _MonthlyTotals.new);
      totals.gross += salary.paymentAmount;
      totals.net += salary.netSalary;

      // 年ごとの総支給額・手取りを集計する場合
      yearTotals[salary.createdAt.year] = (yearTotals[salary.createdAt.year] ?? 0) + salary.paymentAmount;
    }

    // 年ごとの手取りも含めて計算したい場合のマップ
    final yearNetTotals = <int, int>{};
    for (final salary in filtered) {
      yearNetTotals[salary.createdAt.year] = (yearNetTotals[salary.createdAt.year] ?? 0) + salary.netSalary;
    }

    final grossRanking = [...filtered]..sort((a, b) {
      final amount = b.paymentAmount.compareTo(a.paymentAmount);
      return amount == 0 ? b.createdAt.compareTo(a.createdAt) : amount;
    });
    final netRanking = [...filtered]..sort((a, b) {
      final amount = b.netSalary.compareTo(a.netSalary);
      return amount == 0 ? b.createdAt.compareTo(a.createdAt) : amount;
    });

    final grossTotal = filtered.fold<int>(
      0,
          (sum, salary) => sum + salary.paymentAmount,
    );
    final netTotal = filtered.fold<int>(
      0,
          (sum, salary) => sum + salary.netSalary,
    );

    final monthCount = monthTotals.length;
    final yearCount = yearTotals.length;

    // 年平均（年収の平均）の計算
    final yearlyGrossSum = yearTotals.values.fold<int>(0, (sum, val) => sum + val);
    final yearlyNetSum = yearNetTotals.values.fold<int>(0, (sum, val) => sum + val);

    return SalarySummary(
      grossRanking: grossRanking.take(3).toList(),
      netRanking: netRanking.take(3).toList(),
      grossTotal: grossTotal,
      netTotal: netTotal,
      averageMonthlyGross: monthCount == 0 ? 0 : grossTotal / monthCount,
      averageMonthlyNet: monthCount == 0 ? 0 : netTotal / monthCount,
      averageYearlyGross: yearCount == 0 ? 0 : yearlyGrossSum / yearCount,
      averageYearlyNet: yearCount == 0 ? 0 : yearlyNetSum / yearCount,
      monthCount: monthCount,
      yearCount: yearCount,
    );
  }

  bool _matchesFilter(Salary salary, PaymentSource selectedSource) {
    if (selectedSource == DummySource.allDummySource) {
      return true;
    }
    if (salary.source == null) {
      return selectedSource.id == '';
    }
    return salary.source?.id == selectedSource.id;
  }
}

class _MonthlyTotals {
  int gross = 0;
  int net = 0;
}