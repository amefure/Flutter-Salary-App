import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/chart_salary_state.dart';
import 'package:salary/models/dummy_source.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/salary_mock_factory.dart';
import 'package:salary/repository/realm_repository.dart';
import 'package:salary/charts/chart_display_mode.dart';

final chartSalaryProvider =
StateNotifierProvider<ChartSalaryViewModel, ChartSalaryState>((
    ref
    ) {
    final repository = RealmRepository();
    return ChartSalaryViewModel(ref, repository);
  },
);

class ChartSalaryViewModel extends StateNotifier<ChartSalaryState> {
  final Ref ref;

  /// 引数でRepositoryをセット
  final RealmRepository _repository;
  /// 棒グラフの最大表示年数：10年
  static const int DISPLAY_BAR_CHARTS = 10;

  /// 初期インスタンス化
  ChartSalaryViewModel(this.ref, this._repository)
      : super(ChartSalaryState.initial()) {
    // ALLを選択状態に変更
    changeSource(DummySource.allDummySource);
    // データロード
    _loadSalaries();
  }

  /// リフレッシュ
  void refresh() {
    // データロード
    _loadSalaries();
  }

  /// Realm から Salary を取得
  void _loadSalaries() {

    final salaries = _repository.fetchAll<Salary>();
    // モック(確認用)
    // final salaries = SalaryMockFactory.allGenerateYears();
    setSalaries(salaries);
  }

  /// Salary一覧を受け取り、集計
  void setSalaries(List<Salary> allSalaries) {
    final grouped = _groupBySourceAndMonth(allSalaries);
    List<PaymentSource> sources = [
      ...grouped.values.map(
            (e) => e.firstOrNull?.source ?? DummySource.unSetDummySource,
      )
    ]..sort((a, b) {
      final aValue = a.isMain ? 1 : 0;
      final bValue = b.isMain ? 1 : 0;
      return bValue - aValue;
    });
    // ALLを追加
    sources = [
      DummySource.allDummySource,
      ...sources
    ];

    state = state.copyWith(
      allSalaries: allSalaries,
      groupedBySource: grouped,
      sourceList: sources,
    );
  }

  void changeSource(PaymentSource source) {
    state = state.copyWith(selectedSource: source);
  }

  void changeYear(int offset) {
    state = state.copyWith(
      selectedYear: state.selectedYear + offset,
    );
  }

  /// グラフ切り替え
  void toggleDisplayMode() {
    state = state.copyWith(
      displayMode: state.displayMode == ChartDisplayMode.line
          ? ChartDisplayMode.pie
          : ChartDisplayMode.line,
    );
  }

  /// 支払い元＋年月でグルーピング
  Map<String, List<MonthlySalarySummary>> _groupBySourceAndMonth(
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

  /// 年別 × 支払い元ごとの総支給額を集計
  Map<String, int> buildYearlyPaymentBySource(
      List<Salary> salaries,
      int year,
      PaymentSource selectedSource,
      ) {
    final Map<String, int> result = {};

    for (final salary in salaries) {
      if (salary.createdAt.year != year) continue;

      final source = salary.source ?? DummySource.unSetDummySource;

      if (selectedSource.name != DummySource.ALL_TITLE &&
          source.name != selectedSource.name) {
        continue;
      }

      result[source.id] =
          (result[source.id] ?? 0) + salary.paymentAmount;
    }

    return result;
  }

  YearlySalarySummary buildYearlySummary({
    required PaymentSource selectedSource,
    required int selectedYear,
    required List<Salary> allSalaries
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
  YearlyPaymentChartData buildYearlyPaymentBarChartData({
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
    final maxY = calculateMaxYFromValues(amounts.map((e) => e.toDouble()),);

    return YearlyPaymentChartData(
      years: yearsToShow,
      amounts: amounts,
      maxY: maxY.toDouble(),
    );
  }

  /// 数値配列の最大値を[paddingRate]係数で増長して丸めた値を取得
  double calculateMaxYFromValues(
      Iterable<double> values, {
        double paddingRate = 0.1,
      }) {
    if (values.isEmpty) return 0;

    final maxValue = values.reduce(max);
    final padded = maxValue * (1 + paddingRate);

    // 例: 14532 → 15000
    final magnitude = pow(10, padded.toInt().toString().length - 1);
    return (padded / magnitude).ceil() * magnitude.toDouble();
  }

}

/// 月別合計データクラス
/// 生成日時
class MonthlySalarySummary {
  /// 生成日時(対象年月の1日が格納される)
  final DateTime createdAt;
  /// 対象年月の合計総支給額
  final int paymentAmount;
  /// 対象年月の合計手取り額
  final int netSalary;
  /// 対象年月の支払い元
  final PaymentSource? source;

  MonthlySalarySummary({
    required this.createdAt,
    required this.paymentAmount,
    required this.netSalary,
    required this.source,
  });
}

/// 給料合計テーブル用データクラス
class YearlySalarySummary {
  /// 当年(総支給)
  final int paymentAmount;
  /// 当年(手取り)
  final int netSalary;
  /// 前年差分(総支給)
  final int diffPaymentAmount;
  /// 前年差分(手取り)
  final int diffNetSalary;
  /// 当年夏季賞与(総支給)
  final int summerBonus;
  /// 当年冬季賞与(総支給)
  final int winterBonus;
  /// 前年差分夏季賞与(総支給)
  final int diffSummerBonus;
  /// 前年差分冬季賞与(総支給)
  final int diffWinterBonus;

  const YearlySalarySummary({
    required this.paymentAmount,
    required this.netSalary,
    required this.diffPaymentAmount,
    required this.diffNetSalary,
    required this.summerBonus,
    required this.winterBonus,
    required this.diffSummerBonus,
    required this.diffWinterBonus,
  });
}

/// 10年分棒グラフ用データクラス
class YearlyPaymentChartData {
  final List<int> years;
  final List<int> amounts;
  final double maxY;

  const YearlyPaymentChartData({
    required this.years,
    required this.amounts,
    required this.maxY,
  });

  bool get isEmpty => years.isEmpty;
}
