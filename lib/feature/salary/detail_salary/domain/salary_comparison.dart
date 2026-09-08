import 'package:salary/core/models/salary.dart';

class SalaryComparison {
  final double? netRate;
  final Salary? previousMonth;
  final Salary? previousYear;

  const SalaryComparison({
    required this.netRate,
    required this.previousMonth,
    required this.previousYear,
  });

  static SalaryComparison forSalary(Salary current, Iterable<Salary> history) {
    final salaries = history.where((salary) => salary.id != current.id);
    return SalaryComparison(
      netRate:
          current.paymentAmount == 0
              ? null
              : current.netSalary / current.paymentAmount * 100,
      previousMonth: _nearestInMonth(
        current,
        salaries,
        DateTime(current.createdAt.year, current.createdAt.month - 1),
      ),
      previousYear: _nearestInMonth(
        current,
        salaries,
        DateTime(current.createdAt.year - 1, current.createdAt.month),
      ),
    );
  }

  static Salary? _nearestInMonth(
    Salary current,
    Iterable<Salary> salaries,
    DateTime targetMonth,
  ) {
    final candidates =
        salaries.where((salary) {
          final date = salary.createdAt;
          return date.year == targetMonth.year &&
              date.month == targetMonth.month &&
              salary.source?.id == current.source?.id;
        }).toList();

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final aDistance = (a.createdAt.difference(current.createdAt)).abs();
      final bDistance = (b.createdAt.difference(current.createdAt)).abs();
      final distance = aDistance.compareTo(bDistance);
      return distance == 0 ? a.createdAt.compareTo(b.createdAt) : distance;
    });
    return candidates.first;
  }
}
