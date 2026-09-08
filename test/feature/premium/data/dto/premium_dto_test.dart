import 'package:flutter_test/flutter_test.dart';
import 'package:salary/feature/premium/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium/data/dto/public_payment_source_dto.dart';
import 'package:salary/feature/premium/data/dto/public_profile_dto.dart';
import 'package:salary/feature/premium/data/dto/public_salary_dto.dart';
import 'package:salary/feature/premium/data/dto/public_salary_page_dto.dart';
import 'package:salary/feature/premium/data/dto/public_user_dto.dart';
import 'package:salary/feature/premium/data/dto/ranking_dto.dart';
import 'package:salary/feature/premium/data/dto/summary_dto.dart';
import 'package:salary/feature/premium/domain/model/public_payment_source.dart';

Map<String, dynamic> profileJson() {
  return {
    'job_category': 'IT',
    'job': 'エンジニア',
    'region': '東京都',
    'age_range': '30代',
  };
}

Map<String, dynamic> userJson() {
  return {'id': 10, 'name': '公開ユーザー', 'profile': profileJson()};
}

Map<String, dynamic> publicSalaryJson({
  List<Map<String, dynamic>>? paymentItems,
  List<Map<String, dynamic>>? deductionItems,
  Map<String, dynamic>? paymentSource,
}) {
  return {
    'id': 'public-salary-1',
    'payment_amount': 500000,
    'deduction_amount': 100000,
    'net_salary': 400000,
    'paid_at': '2025-06-01T12:00:00Z',
    'is_bonus': false,
    'payment_items': paymentItems,
    'deduction_items': deductionItems,
    'payment_source': paymentSource,
    'user': userJson(),
  };
}

void main() {
  group('PublicProfileDto', () {
    test('fromJson and toDomain map profile fields', () {
      // Arrange
      final json = profileJson();

      // Act
      final dto = PublicProfileDto.fromJson(json);
      final profile = dto.toDomain();

      // Assert
      expect(dto.jobCategory, 'IT');
      expect(dto.job, 'エンジニア');
      expect(dto.region, '東京都');
      expect(dto.ageRange, '30代');
      expect(profile.jobCategory, 'IT');
      expect(profile.job, 'エンジニア');
      expect(profile.region, '東京都');
      expect(profile.ageRange, '30代');
    });
  });

  group('PublicPaymentSourceDto', () {
    test('fromJson and toDomain map a public payment source', () {
      // Arrange
      final json = {
        'id': 'public-source-1',
        'public_name': '公開会社',
        'theme_color': 0xff123456,
      };

      // Act
      final dto = PublicPaymentSourceDto.fromJson(json);
      final source = dto.toDomain();

      // Assert
      expect(dto.id, 'public-source-1');
      expect(dto.publicName, '公開会社');
      expect(dto.themaColor, 0xff123456);
      expect(source.id, 'public-source-1');
      expect(source.publicName, '公開会社');
      expect(source.themaColor, 0xff123456);
    });

    test('fromJson defaults a missing public name to an empty string', () {
      // Arrange
      final json = {
        'id': 'public-source-2',
        'public_name': null,
        'theme_color': 0xff000000,
      };

      // Act
      final dto = PublicPaymentSourceDto.fromJson(json);
      final source = dto.toDomain();

      // Assert
      expect(dto.publicName, isEmpty);
      expect(source.displayName, '非公開');
      expect(source.toDomainLocal().isPublicName, isTrue);
    });
  });

  group('PublicUserDto', () {
    test('fromJson and toDomain map nested profile data', () {
      // Arrange
      final json = userJson();

      // Act
      final dto = PublicUserDto.fromJson(json);
      final user = dto.toDomain();

      // Assert
      expect(dto.id, 10);
      expect(dto.name, '公開ユーザー');
      expect(dto.profile.job, 'エンジニア');
      expect(user.id, 10);
      expect(user.name, '公開ユーザー');
      expect(user.profile.region, '東京都');
    });
  });

  group('PublicSalaryDto', () {
    test('fromJson parses nested data and toDomain converts it', () {
      // Arrange
      final json = publicSalaryJson(
        paymentItems: [
          {'id': 'payment-1', 'key': '基本給', 'value': 500000},
        ],
        deductionItems: [
          {'id': 'deduction-1', 'key': '税金', 'value': 100000},
        ],
        paymentSource: {
          'id': 'public-source-1',
          'public_name': '公開会社',
          'theme_color': 0xff123456,
        },
      );

      // Act
      final dto = PublicSalaryDto.fromJson(json);
      final salary = dto.toDomain();

      // Assert
      expect(dto.id, 'public-salary-1');
      expect(dto.paymentAmount, 500000);
      expect(dto.paidAt, DateTime.parse('2025-06-01T12:00:00Z'));
      expect(dto.paymentItems.single.key, '基本給');
      expect(dto.deductionItems.single.value, 100000);
      expect(dto.paymentSource?.publicName, '公開会社');
      expect(dto.user.profile.ageRange, '30代');
      expect(salary.id, 'public-salary-1');
      expect(salary.paymentItems.single.value, 500000);
      expect(salary.deductionItems.single.key, '税金');
      expect(salary.paymentSource?.publicName, '公開会社');
      expect(salary.user.profile.jobCategory, 'IT');
    });

    test(
      'fromJson uses empty lists and null source for nullable nested values',
      () {
        // Arrange
        final json = publicSalaryJson();

        // Act
        final dto = PublicSalaryDto.fromJson(json);
        final salary = dto.toDomain();

        // Assert
        expect(dto.paymentItems, isEmpty);
        expect(dto.deductionItems, isEmpty);
        expect(dto.paymentSource, isNull);
        expect(salary.paymentItems, isEmpty);
        expect(salary.deductionItems, isEmpty);
        expect(salary.paymentSource, isNull);
      },
    );
  });

  group('PublicSalaryPageDto', () {
    test('fromJson and toDomain map the page and its salaries', () {
      // Arrange
      final json = {
        'data': [publicSalaryJson(paymentItems: [], deductionItems: [])],
        'current_page': 1,
        'last_page': 3,
        'total': 21,
      };

      // Act
      final dto = PublicSalaryPageDto.fromJson(json);
      final salaries = dto.toDomain();

      // Assert
      expect(dto.salaries, hasLength(1));
      expect(dto.currentPage, 1);
      expect(dto.lastPage, 3);
      expect(dto.total, 21);
      expect(salaries.single.id, 'public-salary-1');
    });
  });

  group('RankingDto and SummaryDto', () {
    test('fromJson parses ranking and summary nested DTOs', () {
      // Arrange
      final rankingJson = {
        'user_id': 10,
        'year': 2025,
        'total_payment_amount': 6000000,
        'total_net_salary': 4800000,
        'user': userJson(),
      };
      final summaryJson = {
        'top10': [rankingJson],
        'distribution': [
          {'income_range': '500〜600万', 'user_count': 4},
        ],
      };

      // Act
      final ranking = RankingDto.fromJson(rankingJson);
      final summary = SummaryDto.fromJson(summaryJson);

      // Assert
      expect(ranking.userId, 10);
      expect(ranking.year, 2025);
      expect(ranking.totalPaymentAmount, 6000000);
      expect(ranking.totalNetSalary, 4800000);
      expect(ranking.user.profile.job, 'エンジニア');
      expect(summary.top10.single.userId, 10);
      expect(summary.distribution.single.incomeRange, '500〜600万');
      expect(summary.distribution.single.userCount, 4);
    });
  });

  group('IncomeDistributionDto', () {
    test('fromJson maps the distribution entry', () {
      // Arrange
      final json = {'income_range': '500〜600万', 'user_count': 4};

      // Act
      final dto = IncomeDistributionDto.fromJson(json);

      // Assert
      expect(dto.incomeRange, '500〜600万');
      expect(dto.userCount, 4);
    });

    test(
      'withZeroFilled includes all ranges and fills missing ranges with zero',
      () {
        // Arrange
        final distributions = [
          IncomeDistributionDto(incomeRange: '0〜100万', userCount: 2),
          IncomeDistributionDto(incomeRange: '500〜600万', userCount: 4),
        ];

        // Act
        final result = distributions.withZeroFilled();

        // Assert
        expect(result, hasLength(15));
        expect(result.first.incomeRange, '0〜100万');
        expect(result.first.userCount, 2);
        expect(result[1].incomeRange, '100〜200万');
        expect(result[1].userCount, 0);
        expect(result[5].userCount, 4);
        expect(result.last.incomeRange, '1400万〜');
        expect(result.last.userCount, 0);
      },
    );
  });
}
