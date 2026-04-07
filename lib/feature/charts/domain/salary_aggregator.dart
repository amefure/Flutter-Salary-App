import 'dart:math';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart'; // 型定義参照用

class SalaryAggregator {

  /// 棒グラフの最大表示年数：10年
  static const int DISPLAY_BAR_CHARTS = 10;

  /// 1. 支払い元 ＋ 年月でグルーピング
  static Map<String, List<MonthlySalarySummary>> groupBySourceAndMonth(
      List<Salary> salaries,
      ) {
    final Map<String, List<MonthlySalarySummary>> result = {};

    for (final salary in salaries) {
      final sourceId = salary.source?.id ?? DummySource.unSetDummySource.id;
      result.putIfAbsent(sourceId, () => []);

      final createdAt = DateTime(salary.createdAt.year, salary.createdAt.month, 1);

      final index = result[sourceId]!.indexWhere(
            (s) => s.createdAt.year == createdAt.year && s.createdAt.month == createdAt.month,
      );

      if (index == -1) {
        result[sourceId]!.add(
          MonthlySalarySummary(
            createdAt: createdAt,
            paymentAmount: salary.paymentAmount,
            netSalary: salary.netSalary,
            source: salary.source,
          ),
        );
      } else {
        final old = result[sourceId]![index];
        result[sourceId]![index] = MonthlySalarySummary(
          createdAt: createdAt,
          paymentAmount: old.paymentAmount + salary.paymentAmount,
          netSalary: old.netSalary + salary.netSalary,
          source: old.source,
        );
      }
    }

    return result;
  }

  /// 2. グループ化されたデータから表示用の支払い元リストを抽出・ソート
  static List<PaymentSource> extractSortedSources(
      Map<String, List<MonthlySalarySummary>> grouped,
      ) {
    final List<PaymentSource> sources = [
      ...grouped.values.map(
            (e) => e.firstOrNull?.source ?? DummySource.unSetDummySource,
      )
    ]..sort((a, b) {
      // メイン設定を優先してソート
      final aValue = a.isMain ? 1 : 0;
      final bValue = b.isMain ? 1 : 0;
      return bValue - aValue;
    });
    /// ALLを追加
    return [DummySource.allDummySource, ...sources];
  }

  /// 3. 年別サマリー（前年比較含む）の計算
  static YearlySalarySummary calculateYearlySummary({
    required PaymentSource selectedSource,
    required int selectedYear,
    required List<Salary> allSalaries,
  }) {
    final filtered = selectedSource.name == DummySource.ALL_TITLE
        ? allSalaries
        : allSalaries.where((s) =>
    (s.source?.name ?? DummySource.UNSET_TITLE) == selectedSource.name,
    ).toList();

    // 当年(総支給)
    int payment = 0;
    // 当年(手取り)
    int net = 0;
    // 前年(総支給)
    int prevPayment = 0;
    // 前年(手取り)
    int prevNet = 0;

    // 当年夏季賞与(総支給)
    int summerBonus = 0;
    // 当年冬季賞与(総支給)
    int winterBonus = 0;
    // 前年夏季賞与(総支給)
    int prevSummerBonus = 0;
    // 前年冬季賞与(総支給)
    int prevWinterBonus = 0;

    for (final s in filtered) {
      if (s.createdAt.year == selectedYear) {
        payment += s.paymentAmount;
        net += s.netSalary;

        if (s.isBonus && s.createdAt.month <= 6) {
          summerBonus += s.paymentAmount;
        }
        if (s.isBonus && s.createdAt.month > 6) {
          winterBonus += s.paymentAmount;
        }
      }

      if (s.createdAt.year == selectedYear - 1) {
        prevPayment += s.paymentAmount;
        prevNet += s.netSalary;

        if (s.isBonus && s.createdAt.month <= 6) {
          prevSummerBonus += s.paymentAmount;
        }
        if (s.isBonus && s.createdAt.month > 6) {
          prevWinterBonus += s.paymentAmount;
        }
      }
    }

    return YearlySalarySummary(
      paymentAmount: payment,
      netSalary: net,
      diffPaymentAmount: payment - prevPayment,
      diffNetSalary: net - prevNet,
      summerBonus: summerBonus,
      winterBonus: winterBonus,
      diffSummerBonus: summerBonus - prevSummerBonus,
      diffWinterBonus: winterBonus - prevWinterBonus,
    );
  }

  /// 10年分棒グラフ表示用データの生成
  /// 年ごとの総支給額を支払い元は識別にせずに統合して計算
  static YearlyPaymentChartData buildYearlyPaymentBarChartData({
    required PaymentSource selectedSource,
    required Map<String, List<MonthlySalarySummary>> groupedBySource
  }) {
    // 年ごとの総支給額
    final Map<int, int> yearlySums = {};

    // 支払い元でフィルタリング
    final filtered = selectedSource.id == DummySource.allDummySource.id
        ? groupedBySource
        : { selectedSource.id: groupedBySource[selectedSource.id] ?? [] };

    for (final list in filtered.values) {
      for (final s in list) {
        final year = s.createdAt.year;
        yearlySums[year] = (yearlySums[year] ?? 0) + s.paymentAmount;
      }
    }

    if (yearlySums.isEmpty) {
      return const YearlyPaymentChartData(
        years: [],
        amounts: [],
        maxY: 0,
      );
    }

    // 年を昇順ソート → 最大10年
    final years = yearlySums.keys.toList()..sort();
    final yearsToShow = years.length > DISPLAY_BAR_CHARTS ? years.sublist(years.length - DISPLAY_BAR_CHARTS) : years;

    final amounts = yearsToShow.map((y) => yearlySums[y]!).toList();
    final maxY = calculateMaxY(amounts.map((e) => e.toDouble()),);

    return YearlyPaymentChartData(
      years: yearsToShow,
      amounts: amounts,
      maxY: maxY.toDouble(),
    );
  }

  /// 数値配列の最大値を[paddingRate]係数で増長して丸めた値を取得
  static double calculateMaxY(Iterable<double> values, {double paddingRate = 0.1}) {
    if (values.isEmpty) return 0;
    final maxValue = values.reduce(max);
    final padded = maxValue * (1 + paddingRate);
    // 例: 14532 → 15000
    final magnitude = pow(10, padded.toInt().toString().length - 1);
    return (padded / magnitude).ceil() * magnitude.toDouble();
  }
}