import 'package:flutter_test/flutter_test.dart';
import 'package:salary/feature/salary/detail_salary/domain/salary_comparison.dart';

import '../../../../helpers/dummy_data_helper.dart';

void main() {
  group('SalaryComparison', () {
    test('finds nearest same-source records for previous month and year', () {
      // Arrange
      final source = fakePaymentSource(id: 'same');
      final current = fakeSalary(
        id: 'current',
        paymentAmount: 300,
        deductionAmount: 30,
        netSalary: 270,
        date: DateTime(2026, 3, 20),
        source: source,
      );
      final nearest = fakeSalary(
        id: 'nearest',
        paymentAmount: 200,
        deductionAmount: 20,
        netSalary: 180,
        date: DateTime(2026, 2, 19),
        source: fakePaymentSource(id: 'same'),
      );
      final farther = fakeSalary(
        id: 'farther',
        paymentAmount: 500,
        deductionAmount: 50,
        netSalary: 450,
        date: DateTime(2026, 2, 1),
        source: fakePaymentSource(id: 'same'),
      );
      final previousYear = fakeSalary(
        id: 'previous-year',
        paymentAmount: 100,
        deductionAmount: 10,
        netSalary: 90,
        date: DateTime(2025, 3, 21),
        source: fakePaymentSource(id: 'same'),
      );
      final differentSource = fakeSalary(
        id: 'different-source',
        date: DateTime(2026, 2, 20),
        source: fakePaymentSource(id: 'other'),
      );

      // Act
      final result = SalaryComparison.forSalary(current, [
        current,
        nearest,
        farther,
        previousYear,
        differentSource,
      ]);

      // Assert
      expect(result.previousMonth?.id, 'nearest');
      expect(result.previousYear?.id, 'previous-year');
      expect(result.netRate, 90);
    });

    test(
      'does not turn missing comparisons into zero and handles year boundaries',
      () {
        // Arrange
        final current = fakeSalary(
          id: 'current',
          paymentAmount: 0,
          date: DateTime(2026, 1, 10),
        );

        // Act
        final result = SalaryComparison.forSalary(current, [current]);

        // Assert
        expect(result.netRate, isNull);
        expect(result.previousMonth, isNull);
        expect(result.previousYear, isNull);
      },
    );

    test('matches unset sources by source ID semantics', () {
      // Arrange
      final current = fakeSalary(
        id: 'current',
        paymentAmount: 100,
        netSalary: 80,
        date: DateTime(2026, 2, 10),
      );
      final unsetPrevious = fakeSalary(
        id: 'previous',
        date: DateTime(2026, 1, 10),
      );
      final setPrevious = fakeSalary(
        id: 'set',
        date: DateTime(2026, 1, 11),
        source: fakePaymentSource(id: 'source'),
      );

      // Act
      final result = SalaryComparison.forSalary(current, [
        current,
        unsetPrevious,
        setPrevious,
      ]);

      // Assert
      expect(result.previousMonth?.id, 'previous');
    });
  });
}
