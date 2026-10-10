import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/feature/charts/domain/model/monthly_salary_summary_chart_item.dart';
import 'package:salary/feature/charts/domain/utility/salary_aggregator.dart';
import '../../../helpers/dummy_data_helper.dart';

void main() {
  group('SalaryAggregator テスト', () {
    test('groupBySourceAndMonth: 同じ支払い元・同じ月のデータが合算されること', () {
      /// ① Arrange (準備)
      /// なし

      /// ② Act (実行)
      final result = SalaryAggregator.groupBySourceAndMonth(dummySalaries);

      /// ③ Assert (検証)
      expect(result.containsKey('default_id'), isTrue);

      final listA = result['default_id']!;
      expect(listA.length, 2); // 1月分(合算)と2月分の2要素

      // 1月の合算結果 (1000 + 2000 = 3000)
      // createdAt でソートされているか、あるいは追加順序に依存しますが、
      // 通常は 0番目が 1月、1番目が 2月になります。
      expect(listA[0].paymentAmount, 3000);
      expect(listA[0].createdAt.month, 1);

      // 2月の結果
      expect(listA[1].paymentAmount, 3000);
      expect(listA[1].createdAt.month, 2);
    });

    test('buildLineChartData: 選択した年のデータのみが抽出され、月順にソートされること', () {
      final source = fakePaymentSource();

      final dataMap = {
        'default_id': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 12, 1),
            paymentAmount: 100,
            netSalary: 80,
            source: source,
          ),
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1, 1),
            paymentAmount: 50,
            netSalary: 40,
            source: source,
          ),
          MonthlySalarySummaryItem(
            createdAt: DateTime(2023, 1, 1), // 対象外の年
            paymentAmount: 50,
            netSalary: 40,
            source: source,
          ),
        ],
      };

      final result = SalaryAggregator.buildLineChartData(
        groupedBySource: dataMap,
        selectedSources: [source],
        selectedYear: 2024,
      );

      expect(result.length, 1);
      expect(result[0].length, 2);
      expect(result[0][0].createdAt.month, 1); // ソートされているか
      expect(result[0][1].createdAt.month, 12);
    });

    test('buildLineChartData: 複数選択とAllを選択範囲どおりに集計すること', () {
      final sourceA = fakePaymentSource(id: 'A');
      final sourceB = fakePaymentSource(id: 'B');
      final sourceC = fakePaymentSource(id: 'C');
      final grouped = {
        'A': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1),
            paymentAmount: 100,
            netSalary: 80,
            source: sourceA,
          ),
        ],
        'B': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1),
            paymentAmount: 200,
            netSalary: 160,
            source: sourceB,
          ),
        ],
        'C': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1),
            paymentAmount: 300,
            netSalary: 240,
            source: sourceC,
          ),
        ],
      };

      final selected = SalaryAggregator.buildLineChartData(
        groupedBySource: grouped,
        selectedSources: [sourceA, sourceB],
        selectedYear: 2024,
      );
      final all = SalaryAggregator.buildLineChartData(
        groupedBySource: grouped,
        selectedSources: [DummySource.allDummySource],
        selectedYear: 2024,
      );

      expect(selected, hasLength(2));
      expect(
        selected
            .expand((items) => items)
            .map((item) => item.source!.id)
            .toSet(),
        {'A', 'B'},
      );
      expect(all, hasLength(3));
    });

    test('buildPieChartData: 各支払い元の合計金額とパーセンテージが正しく計算されること', () {
      final sourceA = fakePaymentSource(id: 'A', name: '株式会社Ame');
      final sourceB = fakePaymentSource(id: 'B', name: '株式会社Kasa');
      final dataMap = {
        'A': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1, 1),
            paymentAmount: 3000,
            netSalary: 2400,
            source: sourceA,
          ),
        ],
        'B': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1, 1),
            paymentAmount: 1000,
            netSalary: 800,
            source: sourceB,
          ),
        ],
      };

      final result = SalaryAggregator.buildPieChartData(
        groupedBySource: dataMap,
        selectedSources: [DummySource.allDummySource],
        selectedYear: 2024,
      );

      expect(result.length, 2);
      // 合計4000に対してAは3000なので75%
      final sectorA = result.firstWhere((s) => s.name == '株式会社Ame');
      expect(sectorA.percentage, 75.0);
      expect(
        result.fold<double>(0, (sum, sector) => sum + sector.percentage),
        100,
      );
    });

    test('buildPieChartData: 複数選択した支払元内で割合を計算すること', () {
      final sourceA = fakePaymentSource(id: 'A', name: 'A');
      final sourceB = fakePaymentSource(id: 'B', name: 'B');
      final sourceC = fakePaymentSource(id: 'C', name: 'C');
      final grouped = {
        'A': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1),
            paymentAmount: 300,
            netSalary: 250,
            source: sourceA,
          ),
        ],
        'B': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1),
            paymentAmount: 100,
            netSalary: 80,
            source: sourceB,
          ),
        ],
        'C': [
          MonthlySalarySummaryItem(
            createdAt: DateTime(2024, 1),
            paymentAmount: 600,
            netSalary: 500,
            source: sourceC,
          ),
        ],
      };

      final result = SalaryAggregator.buildPieChartData(
        groupedBySource: grouped,
        selectedSources: [sourceA, sourceB],
        selectedYear: 2024,
      );

      expect(result.map((sector) => sector.name).toSet(), {'A', 'B'});
      expect(result.map((sector) => sector.amount).toList(), [300, 100]);
      expect(result.first.percentage, 75);
      expect(result.last.percentage, 25);
      expect(
        result.fold<double>(0, (sum, sector) => sum + sector.percentage),
        100,
      );
    });

    test('calculateYearlySummary: 複数選択した支払元の年次金額・賞与・前年差分を集計すること', () {
      final sourceA = fakePaymentSource(id: 'A');
      final sourceB = fakePaymentSource(id: 'B');
      final excludedSource = fakePaymentSource(id: 'C');
      final salaries = [
        fakeSalary(
          id: 'a-current',
          paymentAmount: 1000,
          netSalary: 700,
          date: DateTime(2024, 1),
          source: sourceA,
        ),
        fakeSalary(
          id: 'a-summer',
          paymentAmount: 400,
          netSalary: 300,
          date: DateTime(2024, 6),
          isBonus: true,
          source: sourceA,
        ),
        fakeSalary(
          id: 'a-winter',
          paymentAmount: 600,
          netSalary: 450,
          date: DateTime(2024, 12),
          isBonus: true,
          source: sourceA,
        ),
        fakeSalary(
          id: 'a-prev',
          paymentAmount: 500,
          netSalary: 400,
          date: DateTime(2023, 1),
          source: sourceA,
        ),
        fakeSalary(
          id: 'a-prev-summer',
          paymentAmount: 100,
          netSalary: 70,
          date: DateTime(2023, 6),
          isBonus: true,
          source: sourceA,
        ),
        fakeSalary(
          id: 'a-prev-winter',
          paymentAmount: 200,
          netSalary: 150,
          date: DateTime(2023, 12),
          isBonus: true,
          source: sourceA,
        ),
        fakeSalary(
          id: 'b-current',
          paymentAmount: 1000,
          netSalary: 800,
          date: DateTime(2024, 1),
          source: sourceB,
        ),
        fakeSalary(
          id: 'excluded',
          paymentAmount: 9000,
          netSalary: 7000,
          date: DateTime(2024, 1),
          source: excludedSource,
        ),
      ];

      final result = SalaryAggregator.calculateYearlySummary(
        selectedSources: [sourceA, sourceB],
        selectedYear: 2024,
        allSalaries: salaries,
      );

      expect(result.paymentAmount, 3000);
      expect(result.netSalary, 2250);
      expect(result.diffPaymentAmount, 2200);
      expect(result.diffNetSalary, 1630);
      expect(result.summerBonus, 400);
      expect(result.winterBonus, 600);
      expect(result.diffSummerBonus, 300);
      expect(result.diffWinterBonus, 400);
    });

    test('calculateMaxY: 数値に応じて適切なキリの良い最大値が返ること', () {
      // 14532 -> 1.1倍で 15985 -> 次の桁で切り上げ 20000
      // ロジックによりますが、14532に対して20000、または16000などを期待
      final maxVal = SalaryAggregator.calculateMaxY([14532]);
      expect(maxVal, greaterThan(14532));
      expect(maxVal % 1000, 0); // キリが良い数値か
    });

    test('buildYearlyPaymentBarChartData: 過去5年分を表示すること', () {
      final source = DummySource.allDummySource;
      final Map<String, List<MonthlySalarySummaryItem>> grouped = {'ALL': []};

      // 12年分のデータを作成
      for (int i = 0; i < 12; i++) {
        grouped['ALL']!.add(
          MonthlySalarySummaryItem(
            createdAt: DateTime(2010 + i, 1, 1),
            paymentAmount: 100,
            netSalary: 80,
            source: source,
          ),
        );
      }

      final result = SalaryAggregator.buildYearlyPaymentBarChartData(
        selectedSource: source,
        groupedBySource: grouped,
        endYear: 2021,
      );

      expect(result.years.length, 5);
      expect(result.years.first, 2017);
      expect(result.years.last, 2021);
    });
  });
}
