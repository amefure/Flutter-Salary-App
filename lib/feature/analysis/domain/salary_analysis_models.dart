import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';

class SalarySummary {
  final List<Salary> grossRanking;
  final List<Salary> netRanking;
  final int grossTotal;
  final int netTotal;
  final double averageMonthlyGross;
  final double averageMonthlyNet;
  final int monthCount;

  const SalarySummary({
    required this.grossRanking,
    required this.netRanking,
    required this.grossTotal,
    required this.netTotal,
    required this.averageMonthlyGross,
    required this.averageMonthlyNet,
    required this.monthCount,
  });

  bool get isEmpty => grossRanking.isEmpty && netRanking.isEmpty;
}


class SalaryAnalysisCalculator {
  const SalaryAnalysisCalculator();

  SalarySummary summarize(
      Iterable<Salary> salaries, {
        PaymentSource? selectedSource,
      }) {
    // null の場合はすべてを表す DummySource.allDummySource を使う
    final source = selectedSource ?? DummySource.allDummySource;

    final filtered =
    salaries.where((salary) => _matchesFilter(salary, source)).toList();
    final monthTotals = <String, _MonthlyTotals>{};

    for (final salary in filtered) {
      final monthKey = '${salary.createdAt.year}-${salary.createdAt.month}';
      final totals = monthTotals.putIfAbsent(monthKey, _MonthlyTotals.new);
      totals.gross += salary.paymentAmount;
      totals.net += salary.netSalary;
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

    return SalarySummary(
      grossRanking: grossRanking.take(3).toList(),
      netRanking: netRanking.take(3).toList(),
      grossTotal: grossTotal,
      netTotal: netTotal,
      averageMonthlyGross: monthCount == 0 ? 0 : grossTotal / monthCount,
      averageMonthlyNet: monthCount == 0 ? 0 : netTotal / monthCount,
      monthCount: monthCount,
    );
  }

  bool _matchesFilter(Salary salary, PaymentSource selectedSource) {
    if (selectedSource == DummySource.allDummySource) {
      return true;
    }
    // 未設定（null）の扱いを合わせる場合
    if (salary.source == null) {
      return selectedSource.id == ''; // あるいは未設定用のID判定
    }
    return salary.source?.id == selectedSource.id;
  }
}

class _MonthlyTotals {
  int gross = 0;
  int net = 0;
}