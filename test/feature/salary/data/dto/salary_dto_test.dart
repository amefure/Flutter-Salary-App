import 'package:flutter_test/flutter_test.dart';
import 'package:salary/feature/salary/data/dto/amount_item_dto.dart';
import 'package:salary/feature/salary/data/dto/salary_dto.dart';
import 'package:salary/feature/salary/data/dto/salary_page_dto.dart';

void main() {
  group('AmountItemDto', () {
    test('fromJson and toDomain map all fields', () {
      // Arrange
      final json = {'id': 'amount-1', 'key': '基本給', 'value': 300000};

      // Act
      final dto = AmountItemDto.fromJson(json);
      final amountItem = dto.toDomain();

      // Assert
      expect(dto.id, 'amount-1');
      expect(dto.key, '基本給');
      expect(dto.value, 300000);
      expect(amountItem.id, 'amount-1');
      expect(amountItem.key, '基本給');
      expect(amountItem.value, 300000);
    });
  });

  group('SalaryDto', () {
    test('fromJson parses nested data and toDomain converts it', () {
      // Arrange
      final json = {
        'id': 'salary-1',
        'payment_amount': 400000,
        'deduction_amount': 80000,
        'net_salary': 320000,
        'paid_at': '2025-04-01T10:30:00Z',
        'is_bonus': true,
        'memo': '年度賞与',
        'payment_items': [
          {'id': 'payment-1', 'key': '基本給', 'value': 400000},
        ],
        'deduction_items': [
          {'id': 'deduction-1', 'key': '税金', 'value': 80000},
        ],
        'payment_source': {
          'id': 'source-1',
          'name': '株式会社Ame',
          'theme_color': 0xff123456,
          'memo': '本業',
          'is_main': true,
          'user_id': 42,
          'is_public_name': true,
        },
      };

      // Act
      final dto = SalaryDto.fromJson(json);
      final salary = dto.toDomain();

      // Assert
      expect(dto.id, 'salary-1');
      expect(dto.paymentAmount, 400000);
      expect(dto.deductionAmount, 80000);
      expect(dto.netSalary, 320000);
      expect(dto.paidAt, DateTime.parse('2025-04-01T10:30:00Z'));
      expect(dto.isBonus, isTrue);
      expect(dto.memo, '年度賞与');
      expect(dto.paymentItems.single.value, 400000);
      expect(dto.deductionItems.single.key, '税金');
      expect(dto.paymentSource?.publicUserId, 42);
      expect(salary.id, 'salary-1');
      expect(salary.createdAt, dto.paidAt.toLocal());
      expect(salary.memo, '年度賞与');
      expect(salary.paymentAmountItems.single.key, '基本給');
      expect(salary.deductionAmountItems.single.value, 80000);
      expect(salary.source?.id, 'source-1');
    });

    test(
      'fromJson uses an empty memo and null source for omitted optional values',
      () {
        // Arrange
        final json = {
          'id': 'salary-2',
          'payment_amount': 1000,
          'deduction_amount': 100,
          'net_salary': 900,
          'paid_at': '2025-05-01T00:00:00Z',
          'is_bonus': false,
          'memo': null,
          'payment_items': <Map<String, dynamic>>[],
          'deduction_items': <Map<String, dynamic>>[],
          'payment_source': null,
        };

        // Act
        final dto = SalaryDto.fromJson(json);
        final salary = dto.toDomain();

        // Assert
        expect(dto.memo, isEmpty);
        expect(dto.paymentItems, isEmpty);
        expect(dto.deductionItems, isEmpty);
        expect(dto.paymentSource, isNull);
        expect(salary.source, isNull);
        expect(salary.paymentAmountItems, isEmpty);
        expect(salary.deductionAmountItems, isEmpty);
      },
    );
  });

  group('SalaryPageDto', () {
    test('fromJson parses nested salaries and pagination metadata', () {
      // Arrange
      final json = {
        'data': {
          'salaries': {
            'data': [
              {
                'id': 'salary-1',
                'payment_amount': 1000,
                'deduction_amount': 100,
                'net_salary': 900,
                'paid_at': '2025-01-01T00:00:00Z',
                'is_bonus': false,
                'memo': '',
                'payment_items': [],
                'deduction_items': [],
                'payment_source': null,
              },
            ],
            'current_page': 2,
            'last_page': 5,
            'total': 25,
          },
        },
      };

      // Act
      final page = SalaryPageDto.fromJson(json);

      // Assert
      expect(page.salaries, hasLength(1));
      expect(page.salaries.single.id, 'salary-1');
      expect(page.currentPage, 2);
      expect(page.lastPage, 5);
      expect(page.total, 25);
    });

    test('fromJson preserves null pagination metadata', () {
      // Arrange
      final json = {
        'data': {
          'salaries': {
            'data': <Map<String, dynamic>>[],
            'current_page': null,
            'last_page': null,
            'total': null,
          },
        },
      };

      // Act
      final page = SalaryPageDto.fromJson(json);

      // Assert
      expect(page.salaries, isEmpty);
      expect(page.currentPage, isNull);
      expect(page.lastPage, isNull);
      expect(page.total, isNull);
    });
  });
}
