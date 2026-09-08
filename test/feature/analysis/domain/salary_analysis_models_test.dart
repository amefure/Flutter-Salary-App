import 'package:flutter_test/flutter_test.dart';
import 'package:salary/feature/analysis/domain/salary_analysis_models.dart';

import '../../../helpers/dummy_data_helper.dart';

void main() {
  const calculator = SalaryAnalysisCalculator();

  group('SalaryAnalysisCalculator', () {
    test('filters by source ID and ranks gross and net independently', () {
      // Arrange
      final sourceA = fakePaymentSource(id: 'a', name: 'A');
      final sourceB = fakePaymentSource(id: 'b', name: 'B');
      final salaries = [
        fakeSalary(
          id: 'gross-a',
          paymentAmount: 500,
          netSalary: 100,
          date: DateTime(2026, 1, 1),
          source: sourceA,
        ),
        fakeSalary(
          id: 'net-a',
          paymentAmount: 100,
          netSalary: 600,
          date: DateTime(2026, 1, 20),
          source: sourceA,
        ),
        fakeSalary(
          id: 'other-source',
          paymentAmount: 999,
          netSalary: 999,
          date: DateTime(2026, 1, 10),
          source: sourceB,
        ),
      ];

      // Act
      final result = calculator.summarize(
        salaries,
        filter: const SalarySourceFilter.source('a'),
      );

      // Assert
      expect(result.grossRanking.map((salary) => salary.id), [
        'gross-a',
        'net-a',
      ]);
      expect(result.netRanking.map((salary) => salary.id), [
        'net-a',
        'gross-a',
      ]);
      expect(result.grossTotal, 600);
      expect(result.netTotal, 700);
    });

    test(
      'averages monthly totals by months containing data, including bonuses',
      () {
        // Arrange
        final salaries = [
          fakeSalary(
            id: 'jan-salary',
            paymentAmount: 100,
            netSalary: 80,
            date: DateTime(2026, 1, 5),
          ),
          fakeSalary(
            id: 'jan-bonus',
            paymentAmount: 300,
            netSalary: 240,
            date: DateTime(2026, 1, 20),
            isBonus: true,
          ),
          fakeSalary(
            id: 'mar-salary',
            paymentAmount: 200,
            netSalary: 160,
            date: DateTime(2026, 3, 5),
          ),
        ];

        // Act
        final result = calculator.summarize(salaries);

        // Assert
        expect(result.monthCount, 2);
        expect(result.averageMonthlyGross, 300);
        expect(result.averageMonthlyNet, 240);
        expect(result.grossRanking.first.id, 'jan-bonus');
      },
    );

    test('supports explicitly selecting salaries without a payment source', () {
      // Arrange
      final salaries = [
        fakeSalary(id: 'unset', paymentAmount: 100, netSalary: 80),
        fakeSalary(
          id: 'set',
          paymentAmount: 200,
          netSalary: 160,
          source: fakePaymentSource(id: 'source'),
        ),
      ];

      // Act
      final result = calculator.summarize(
        salaries,
        filter: const SalarySourceFilter.unspecified(),
      );

      // Assert
      expect(result.grossRanking.map((salary) => salary.id), ['unset']);
      expect(result.grossTotal, 100);
      expect(result.netTotal, 80);
    });

    test('returns an empty summary for no records', () {
      // Arrange
      const salaries = <dynamic>[];

      // Act
      final result = calculator.summarize(salaries.cast());

      // Assert
      expect(result.isEmpty, isTrue);
      expect(result.monthCount, 0);
      expect(result.averageMonthlyGross, 0);
      expect(result.averageMonthlyNet, 0);
    });
  });
}
