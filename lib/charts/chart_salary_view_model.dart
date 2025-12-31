import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/charts/chart_salary_state.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/salary_mock_factory.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/repository/realm_repository.dart';

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

  static const String ALL_TITLE = 'ALL';
  static const String UNSET_TITLE = '未設定';
  /// 棒グラフの最大表示年数：10年
  static const int DISPLAY_BAR_CHARTS = 10;

  /// "全て" を表すダミーの PaymentSource を作成
  static final PaymentSource allDummySource = PaymentSource(
    Uuid.v4().toString(),
    ALL_TITLE,
    ThemaColor.blue.value,
  );

  /// "未設定" を表すダミーの PaymentSource を作成
  static final PaymentSource _unSetDummySource = PaymentSource(
    Uuid.v4().toString(),
    UNSET_TITLE,
    ThemaColor.blue.value,
  );

  /// 初期インスタンス化
  ChartSalaryViewModel(this.ref, this._repository)
      : super(ChartSalaryState.initial()) {
    // ALLを選択状態に変更
    changeSource(allDummySource);
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
    // final salaries = SalaryMockFactory.generateYear(year: DateTime.now().year);
    setSalaries(salaries);
  }

  /// Salary一覧を受け取り、集計
  void setSalaries(List<Salary> salaries) {
    final grouped = _groupBySourceAndMonth(salaries);
    final sources = [
      allDummySource,
      ...grouped.values.map(
            (e) => e.firstOrNull?.source ?? _unSetDummySource,
      ),
    ];

    state = state.copyWith(
      allSalaries: salaries,
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

  /// 支払い元＋年月でグルーピング
  Map<String, List<MonthlySalarySummary>> _groupBySourceAndMonth(
      List<Salary> salaries,
      ) {
    final Map<String, List<MonthlySalarySummary>> result = {};

    for (final salary in salaries) {
      final sourceId = salary.source?.id ?? _unSetDummySource.id;
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
            deductionAmount: salary.deductionAmount,
            netSalary: salary.netSalary,
            isBonus: salary.isBonus,
            source: salary.source,
          ),
        );
      } else {
        final old = result[sourceId]![index];
        result[sourceId]![index] = MonthlySalarySummary(
          createdAt: createdAt,
          paymentAmount: old.paymentAmount + salary.paymentAmount,
          deductionAmount: old.deductionAmount + salary.deductionAmount,
          netSalary: old.netSalary + salary.netSalary,
          isBonus: old.isBonus,
          source: old.source,
        );
      }
    }

    return result;
  }

  YearlySalarySummary buildYearlySummary() {
    final selectedSource = state.selectedSource;
    final selectedYear = state.selectedYear;
    final allSalaries = state.allSalaries;

    final filtered = selectedSource.name == ALL_TITLE
        ? allSalaries
        : allSalaries.where((s) =>
    (s.source?.name ?? UNSET_TITLE) == selectedSource.name,
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
  YearlyPaymentChartData buildYearlyPaymentBarChartData() {
    final selectedSource = state.selectedSource;
    final groupedBySource = state.groupedBySource;

    // 年ごとの総支給額
    final Map<int, int> yearlySums = {};

    // 支払い元でフィルタリング
    final filtered = selectedSource.id == allDummySource.id
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
    final maxY = amounts.reduce((a, b) => a > b ? a : b) * 1.1;

    return YearlyPaymentChartData(
      years: yearsToShow,
      amounts: amounts,
      maxY: maxY.toDouble(),
    );
  }

}

/// 月別折れ線グラフ用データクラス
class MonthlySalarySummary {
  final DateTime createdAt;
  final int paymentAmount;
  final int deductionAmount;
  final int netSalary;
  final bool isBonus;
  final PaymentSource? source;

  MonthlySalarySummary({
    required this.createdAt,
    required this.paymentAmount,
    required this.deductionAmount,
    required this.netSalary,
    required this.isBonus,
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
