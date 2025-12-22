import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/utilities/logger.dart';
import 'package:salary/utilities/number_utils.dart';
import 'package:salary/viewmodels/reverpod/remove_ads_notifier.dart';
import 'package:salary/viewmodels/reverpod/payment_source_notifier.dart';
import 'package:salary/viewmodels/reverpod/salary_notifier.dart';
import 'package:salary/views/components/ad_banner_widget.dart';
import 'package:salary/views/components/custom_label_view.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/charts/chart_salary_state.dart';
import 'package:salary/views/domain/charts/chart_salary_view_model.dart';

class ChartSalaryView extends ConsumerWidget {
  const ChartSalaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: 'MyData',
            fontWeight: FontWeight.bold,
          )
      ),
      child: _Body(state: state),
    );
  }
}

class _Body extends ConsumerWidget {
  final ChartSalaryState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.of(context).size;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: SingleChildScrollView(
            child: Column(
                children: [
                  SizedBox(width: screen.width),

                  SizedBox(
                    width: screen.width * 0.5,
                    child: _SourceSelector(),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: screen.width * 0.95,
                      child: const CustomLabelView(labelText: '月別合計金額')
                  ),

                  // 月ごとの給料グラフ
                  SizedBox(
                      width: screen.width * 0.95,
                      child: _buildYearSalaryChart(ref),
                  ),

                  _YearSelector(year: state.selectedYear),

                  const SizedBox(height: 20),

                  SizedBox(width: screen.width * 0.9, child: _tableSalaryInfo(ref)),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: screen.width * 0.95,
                      child: const CustomLabelView(labelText: '年別合計金額(10年間)')
                  ),

                  // 年ごとの給料グラフ
                  SizedBox(
                      width: screen.width * 0.95,
                      child: _buildYearlyPaymentBarChart(ref),
                  ),

                  const SizedBox(height: 20),

                ]
            ),
          ))
        ]
    );
  }

  /// グラフ描画 & NoData UI
  Widget _buildYearSalaryChart(WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);
    final notifier = ref.read(chartSalaryProvider.notifier);

    // 🔽 ここで「今までのメンバ変数」を再現する
    final _selectedSource = state.selectedSource;

    // ViewModel が持っているダミーSource
    final _allSource = notifier.allSource;

    List<LineChartBarData> lines = _buildLines(ref);
    if (lines.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const CustomText(
          text: 'データがありません',
          textSize: TextSize.M,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
        ),
      );
    }
    // Y軸の最大値を取得
    final maxY = _calculateMaxY(lines);

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          // ツールチップ設定
          lineTouchData: LineTouchData(
            enabled: _selectedSource != _allSource ? true : false,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                touchedSpots.removeLast();
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.x.toInt()}月\n${NumberUtils.formatWithComma(spot.y.toInt())}円',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          // 最大Y軸
          maxY: maxY,
          // 最小Y軸
          minY: 0,
          // 各方向のラベル(目盛り)制御
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 70,
                getTitlesWidget: (value, meta) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: '${NumberUtils.formatWithComma(value.toInt())}円',
                        textSize: TextSize.SS,
                      ),
                      const SizedBox(width: 5),
                    ],
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return CustomText(
                    text: '${value.toInt()}月',
                    textSize: TextSize.SS,
                  );
                },
              ),
            ),
          ),
          lineBarsData: lines,
        ),
      ),
    );
  }

  /// Y軸の最大値を取得
  double _calculateMaxY(List<LineChartBarData> lines) {
    final maxY = lines.expand((bar) => bar.spots).map((e) => e.y).fold(0.0, max);
    final padded = maxY * 1.1;

    // 例：14532 → 15000 に切り上げ
    final magnitude = pow(10, padded.toInt().toString().length - 1);
    return (padded / magnitude).ceil() * magnitude.toDouble();
  }

  /// 選択された支払い元のデータを取得し、折れ線データを生成
  List<LineChartBarData> _buildLines(WidgetRef ref) {
    final _selectedSource = state.selectedSource;
    final _selectedYear = state.selectedYear;
    final _groupedBySource = state.groupedBySource;
    List<LineChartBarData> lines = [];

    // 選択中のカテゴリでフィルタリング
    Map<String, List<MonthlySalarySummary>> filteredData =
        _selectedSource.name == 'ALL'
            ? _groupedBySource
            : {
              _selectedSource.name:
                  _groupedBySource[_selectedSource.name] ?? [],
            };

    filteredData.forEach((source, salaries) {
      // 選択中の年月でフィルタリング
      List<MonthlySalarySummary> filteredSalaries =
          salaries.where((s) => s.createdAt.year == _selectedYear).toList();

      // 日付順にソート
      filteredSalaries.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      List<FlSpot> paymentSpots =
          filteredSalaries
              .map(
                (s) => FlSpot(
                  s.createdAt.month.toDouble(),
                  s.paymentAmount.toDouble(),
                ),
              )
              .toList();

      List<FlSpot> netSalarySpots =
          filteredSalaries
              .map(
                (s) => FlSpot(
                  s.createdAt.month.toDouble(),
                  s.netSalary.toDouble(),
                ),
              )
              .toList();
      // ALLを選択中のみ複数Line格納される
      if (paymentSpots.isNotEmpty) {
        lines.add(
          LineChartBarData(
            spots: paymentSpots,
            isCurved: true,
            color: filteredSalaries.firstOrNull?.source?.themaColorEnum.color,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
          ),
        );
      }

       // ALLを選択中のみ複数Line格納される
      if (netSalarySpots.isNotEmpty) {
        lines.add(
          LineChartBarData(
            spots: netSalarySpots,
            isCurved: true,
            color: filteredSalaries.firstOrNull?.source?.themaColorEnum.color.withValues(alpha: 0.4),
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    });
    return lines;
  }

  Widget _buildYearlyPaymentBarChart(WidgetRef ref) {
    final _selectedSource = state.selectedSource;
    final _groupedBySource = state.groupedBySource;
    // 年ごとの総支給額を集計
    Map<int, int> yearlyPaymentSums = {};

    Map<String, List<MonthlySalarySummary>> filteredData =
    _selectedSource.name == 'ALL'
        ? _groupedBySource
        : {
      _selectedSource.name:
      _groupedBySource[_selectedSource.name] ?? [],
    };

    filteredData.forEach((source, salaryList) {
      for (var s in salaryList) {
        final year = s.createdAt.year;
        yearlyPaymentSums[year] = (yearlyPaymentSums[year] ?? 0) + s.paymentAmount;
      }
    });

    if (yearlyPaymentSums.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CustomText(
          text: 'データがありません',
          textSize: TextSize.M,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    // 年をソートし、最大10年分だけ使用
    final sortedYears = yearlyPaymentSums.keys.toList()..sort();
    final yearsToShow = sortedYears.length > 5
        ? sortedYears.sublist(sortedYears.length - 5)
        : sortedYears;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < yearsToShow.length; i++) {
      final year = yearsToShow[i];
      final amount = yearlyPaymentSums[year]!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: amount.toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    final maxY =
        barGroups.expand((g) => g.barRods).map((r) => r.toY).fold(0.0, max) * 1.1;

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final year = yearsToShow[group.x.toInt()];
                final value = rod.toY.toInt();
                return BarTooltipItem(
                  '$year年\n${NumberUtils.formatWithComma(value)}円',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) => CustomText(
                  text: '${NumberUtils.formatWithComma(value.toInt())}円',
                  textSize: TextSize.SS,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (index, meta) {
                  final year = yearsToShow[index.toInt()];
                  return CustomText(text: '$year年', textSize: TextSize.SS);
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _tableSalaryInfo( WidgetRef ref) {
    final _selectedSource = state.selectedSource;
    final _selectedYear = state.selectedYear;
    final _groupedBySource = state.groupedBySource;
    final _allSalaries = state.allSalaries;
    // 選択中のカテゴリでフィルタリング
    final List<Salary> filteredSourceList =
    _selectedSource.name == 'ALL'
        ? _allSalaries
        : _allSalaries
        .where((salary) =>
    salary.source?.name == _selectedSource.name)
        .toList();

    // 当年(総支給)
    int paymentAmountSum = 0;
    // 当年(手取り)
    int netSalarySum = 0;
    // 前年(総支給)
    int prevPaymentAmountSum = 0;
    // 前年(手取り)
    int prevNetSalarySum = 0;

    // 当年夏季賞与(総支給)
    int summerBonus = 0;
    // 当年冬季賞与(総支給)
    int winterBonus = 0;
    // 前年夏季賞与(総支給)
    int prevSummerBonus = 0;
    // 前年冬季賞与(総支給)
    int prevWinterBonus = 0;

    // 当年
    final theYearSalaries = filteredSourceList.where((s) => s.createdAt.year == _selectedYear).toList();
    for (var salary in theYearSalaries) {
      paymentAmountSum += salary.paymentAmount;
      netSalarySum += salary.netSalary;

      // 夏季賞与計算(総支給)
      if (salary.isBonus && salary.createdAt.month <= DateTime.june) {
        summerBonus += salary.paymentAmount;
      }

      // 冬季賞与計算
      if (salary.isBonus && salary.createdAt.month > DateTime.june && salary.createdAt.month <= 12) {
        winterBonus += salary.paymentAmount;
      }
    }

    // 当年
    final preYearSalaries = filteredSourceList.where((s) => s.createdAt.year == _selectedYear - 1).toList();
    for (var salary in preYearSalaries) {
      prevPaymentAmountSum += salary.paymentAmount;
      prevNetSalarySum += salary.netSalary;

      // 夏季賞与計算(総支給)
      if (salary.isBonus && salary.createdAt.month <= 6) {
        prevSummerBonus += salary.paymentAmount;
      }

      // 冬季賞与計算
      if (salary.isBonus) {
        prevWinterBonus += salary.paymentAmount;
      }
    }


    return Column(
      spacing: 20,
      children: [
        _buildSalaryRow(
          '年収（総支給）',
          paymentAmountSum,
          diff: paymentAmountSum - prevPaymentAmountSum,
        ),
        _buildSalaryRow(
          '年収（手取り）',
          netSalarySum,
          diff: netSalarySum - prevNetSalarySum,
        ),
        _buildSalaryRow(
          '夏季賞与（総支給）',
          summerBonus,
          diff: summerBonus - prevSummerBonus,
        ),
        _buildSalaryRow(
          '冬季賞与（総支給）',
          winterBonus,
          diff: winterBonus - prevWinterBonus,
        ),
      ],
    );
  }

  Widget _buildSalaryRow(String label, int amount, {int diff = 0}) {
    Color diffColor;
    String diffText = '';

    if (diff > 0) {
      diffColor = Colors.green;
      diffText = '+${NumberUtils.formatWithComma(diff)}円';
    } else if (diff < 0) {
      diffColor = Colors.red;
      diffText = '${NumberUtils.formatWithComma(diff)}円';
    } else {
      diffColor = CustomColors.text.withAlpha(120);
      diffText = '±0';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomLabelView(labelText: label),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: NumberUtils.formatWithComma(amount),
                  textSize: TextSize.L,
                  color: CustomColors.thema,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(width: 5),
                const CustomText(text: '円', textSize: TextSize.S),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Spacer(),
            const CustomText(text: '前年', textSize: TextSize.SS),
            const SizedBox(width: 5),
            CustomText(
              text: diffText,
              textSize: TextSize.SS,
              color: diffColor,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }
}

/// 給与の支払い元を選択(MenuAnchor)
class _SourceSelector extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);
    final notifier = ref.read(chartSalaryProvider.notifier);

    return MenuAnchor(
      builder: (_, controller, __) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: _SourceLabel(selectedSource: state.selectedSource),
        );
      },
      menuChildren: state.sourceList.map((source) {
        return MenuItemButton(
          onPressed: () => notifier.changeSource(source),
          child: SizedBox(
            width: 200,
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.building_2_fill,
                  color: source.themaColorEnum.color,
                ),
                const SizedBox(width: 8),
                Expanded(child: CustomText(text: source.name, fontWeight: FontWeight.bold)),
                if (state.selectedSource == source)
                  const Icon(CupertinoIcons.checkmark_alt),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 年月選択
class _YearSelector extends ConsumerWidget {
  final int year;

  const _YearSelector({required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(chartSalaryProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => notifier.changeYear(-1),
        ),
        CustomText(
          text: '$year年 1月 〜 12月',
          fontWeight: FontWeight.bold,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.chevron_forward),
          onPressed: () => notifier.changeYear(1),
        ),
      ],
    );
  }
}

/// 支払い元UIラベル
class _SourceLabel extends ConsumerWidget {
  final PaymentSource selectedSource;

  const _SourceLabel({required this.selectedSource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = selectedSource.themaColorEnum.color;

    return Container(
      padding: const EdgeInsets.all(10),
      width: 180,
      decoration: BoxDecoration(
        color: color,
        // 角丸
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // 影
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.building_2_fill, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: selectedSource.name,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              textSize: TextSize.S,
            ),
          ),

          const Icon(CupertinoIcons.chevron_down, color: Colors.white),
        ],
      ),
    );
  }
}
// class ChartSalaryView extends StatefulWidget {
//   const ChartSalaryView({super.key});
//
//   @override
//   ChartSalaryViewState createState() => ChartSalaryViewState();
// }
//
// class ChartSalaryViewState extends State<ChartSalaryView> {
//   /// グラフに表示するためのグルーピングデータ
//   late Map<String, List<Salary>> _groupedBySource;
//   /// Salaryに存在する支払い元リスト
//   late List<PaymentSource> _sourceList;
//
//   /// 全てのSalary一覧
//   List<Salary> _allSalaries = List.empty();
//
//   /// 表示中の支払い元
//   late PaymentSource _selectedSource;
//   /// 表示中の年月
//   late int _selectedYear;
//
//   /// "全て" を表すダミーの PaymentSource を作成
//   final PaymentSource _allSource = PaymentSource(
//     Uuid.v4().toString(),
//     'ALL',
//     ThemaColor.blue.value,
//   );
//
//    /// "未設定" を表すダミーの PaymentSource を作成
//   final PaymentSource _unSetSource = PaymentSource(
//     Uuid.v4().toString(),
//     '未設定',
//     ThemaColor.blue.value,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedSource = _allSource;
//     _selectedYear = DateTime.now().year;
//   }
//
//   /// 月(yyyy-MM)単位にデータをまとめてグルーピング
//   void _groupSalariesBySource(List<Salary> salaryList) {
//     _groupedBySource = {};
//
//     for (var salary in salaryList) {
//       String sourceName = salary.source?.name ?? '未設定';
//
//       // 支払い元ごとのリストがなければ作成
//       if (!_groupedBySource.containsKey(sourceName)) {
//         _groupedBySource[sourceName] = [];
//       }
//
//       // `createdAt` を "yyyy-MM" の形式でキーにする
//       String yearMonthKey = DateFormat('yyyy-MM').format(salary.createdAt);
//
//       // 同じ年月のデータがあるかチェック
//       var existingIndex = _groupedBySource[sourceName]!.indexWhere(
//         (s) => DateFormat('yyyy-MM').format(s.createdAt) == yearMonthKey,
//       );
//
//       // 月初の 0 時 0 分 にリセットする
//       DateTime resetToMonthStart(DateTime date) {
//         return DateTime(date.year, date.month, 1, 0, 0, 0);
//       }
//
//       if (existingIndex == -1) {
//         // 初回のデータなら新しいインスタンスを作成して追加
//         _groupedBySource[sourceName]!.add(
//           Salary(
//             salary.id,
//             salary.paymentAmount,
//             salary.deductionAmount,
//             salary.netSalary,
//             resetToMonthStart(salary.createdAt),
//             salary.isBonus,
//             salary.memo,
//             paymentAmountItems: salary.paymentAmountItems.toList(), // コピー
//             deductionAmountItems: salary.deductionAmountItems.toList(), // コピー
//             source: salary.source, // 参照のまま
//           ),
//         );
//       } else {
//         // すでに存在するデータなら、金額をaddした新しいコピーを作成して置き換える
//         var existingSalary = _groupedBySource[sourceName]![existingIndex];
//
//         var updatedSalary = Salary(
//           existingSalary.id,
//           existingSalary.paymentAmount + salary.paymentAmount,
//           existingSalary.deductionAmount + salary.deductionAmount,
//           existingSalary.netSalary + salary.netSalary,
//           resetToMonthStart(existingSalary.createdAt), // 日付は元のまま
//           existingSalary.isBonus,
//           existingSalary.memo,
//           paymentAmountItems: existingSalary.paymentAmountItems.toList(), // コピー
//           deductionAmountItems:
//               existingSalary.deductionAmountItems.toList(), // コピー
//           source: existingSalary.source, // 参照のまま
//         );
//
//         // List の要素を更新
//         _groupedBySource[sourceName]![existingIndex] = updatedSalary;
//       }
//     }
//
//     // 支払い元リストを作成
//     _sourceList = [
//       _allSource,
//       ..._groupedBySource.values.map(
//         (name) => name.firstOrNull?.source ?? _unSetSource,
//       ),
//     ];
//
//     // 選択されている支払い元がリストに含まれていない場合、デフォルトを "全て" にする
//     if (!_sourceList.contains(_selectedSource)) {
//       _selectedSource = _allSource;
//     }
//   }
//
//   /// 選択年月を変更
//   void _changeYear(int offset) {
//     setState(() {
//       _selectedYear += offset;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screen = MediaQuery.of(context).size;
//
//     return CupertinoPageScaffold(
//       backgroundColor: CustomColors.foundation,
//       navigationBar: const CupertinoNavigationBar(
//           middle: CustomText(
//             text: 'MyData',
//             fontWeight: FontWeight.bold,
//           )
//       ),
//       child: Consumer(
//         builder: (context, ref, child) {
//
//           /// 広告削除フラグ
//           final removeAds = ref.watch(removeAdsProvider);
//
//           _allSalaries = ref.watch(salaryProvider.notifier).allSalaries;
//           final _ = ref.watch(paymentSourceProvider);
//           _groupSalariesBySource(_allSalaries);
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//
//               Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         SizedBox(width: screen.width),
//
//                         SizedBox(
//                           width: screen.width * 0.5,
//                           child: _buildSourceSelector(),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         SizedBox(
//                             width: screen.width * 0.95,
//                             child: const CustomLabelView(labelText: '月別合計金額')
//                         ),
//
//                         // 月ごとの給料グラフ
//                         SizedBox(
//                             width: screen.width * 0.95,
//                             child: _buildYearSalaryChart()
//                         ),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               icon: const Icon(CupertinoIcons.chevron_back),
//                               onPressed: () => _changeYear(-1),
//                             ),
//                             CustomText(
//                               text: '$_selectedYear年 1月 〜 12月',
//                               fontWeight: FontWeight.bold,
//                             ),
//                             IconButton(
//                               icon: const Icon(CupertinoIcons.chevron_forward),
//                               onPressed: () => _changeYear(1),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         SizedBox(width: screen.width * 0.9, child: _tableSalaryInfo()),
//
//                         const SizedBox(height: 20),
//
//                         SizedBox(
//                             width: screen.width * 0.95,
//                             child: const CustomLabelView(labelText: '年別合計金額(10年間)')
//                         ),
//
//                         // 年ごとの給料グラフ
//                         SizedBox(
//                             width: screen.width * 0.95,
//                             child: _buildYearlyPaymentBarChart(_allSalaries)
//                         ),
//
//                         const SizedBox(height: 20),
//
//                       ],
//                     ),
//                   )
//               ),
//
//               if (!removeAds)
//                 const AdMobBannerWidget(),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   /// **給与の支払い元を選択するUI (MenuAnchor)**
//   Widget _buildSourceSelector() {
//     return MenuAnchor(
//       builder: (context, controller, child) {
//         return GestureDetector(
//           onTap: () {
//             if (controller.isOpen) {
//               controller.close();
//             } else {
//               controller.open();
//             }
//           },
//           child: _sourceLabel(_selectedSource),
//         );
//       },
//       menuChildren:
//           _sourceList.map((source) {
//             return MenuItemButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedSource = source;
//                 });
//               },
//               child: SizedBox(
//                 width: 200,
//                 child: Row(
//                   children: [
//                     Icon(
//                       CupertinoIcons.building_2_fill,
//                       color: source.themaColorEnum.color,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(child: CustomText(text: source.name, fontWeight: FontWeight.bold)),
//                     if (_selectedSource == source)
//                       const Icon(CupertinoIcons.checkmark_alt),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//     );
//   }
//
//   /// 支払い元UIラベル
//   Widget _sourceLabel(PaymentSource selectedSource) {
//     final PaymentSource? paymentSource =
//         _groupedBySource[selectedSource.name]?.firstOrNull?.source;
//     final Color color =
//         paymentSource?.themaColorEnum.color ?? ThemaColor.blue.color;
//
//     return Container(
//       padding: const EdgeInsets.all(10),
//       width: 180,
//       decoration: BoxDecoration(
//         color: color,
//         // 角丸
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           // 影
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.3),
//             blurRadius: 5,
//             spreadRadius: 1,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const Icon(CupertinoIcons.building_2_fill, color: Colors.white),
//           const SizedBox(width: 8),
//           Expanded(
//             child: CustomText(
//               text: paymentSource?.name ?? 'ALL',
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               textSize: TextSize.S,
//             ),
//           ),
//
//           const Icon(CupertinoIcons.chevron_down, color: Colors.white),
//         ],
//       ),
//     );
//   }
//
//   Widget _tableSalaryInfo() {
//     // 選択中のカテゴリでフィルタリング
//     final List<Salary> filteredSourceList =
//     _selectedSource.name == 'ALL'
//         ? _allSalaries
//         : _allSalaries
//         .where((salary) =>
//     salary.source?.name == _selectedSource.name)
//         .toList();
//
//     // 当年(総支給)
//     int paymentAmountSum = 0;
//     // 当年(手取り)
//     int netSalarySum = 0;
//     // 前年(総支給)
//     int prevPaymentAmountSum = 0;
//     // 前年(手取り)
//     int prevNetSalarySum = 0;
//
//     // 当年夏季賞与(総支給)
//     int summerBonus = 0;
//     // 当年冬季賞与(総支給)
//     int winterBonus = 0;
//     // 前年夏季賞与(総支給)
//     int prevSummerBonus = 0;
//     // 前年冬季賞与(総支給)
//     int prevWinterBonus = 0;
//
//     // 当年
//     final theYearSalaries = filteredSourceList.where((s) => s.createdAt.year == _selectedYear).toList();
//     for (var salary in theYearSalaries) {
//       paymentAmountSum += salary.paymentAmount;
//       netSalarySum += salary.netSalary;
//
//       // 夏季賞与計算(総支給)
//       if (salary.isBonus && salary.createdAt.month <= DateTime.june) {
//         summerBonus += salary.paymentAmount;
//       }
//
//       // 冬季賞与計算
//       if (salary.isBonus && salary.createdAt.month > DateTime.june && salary.createdAt.month <= 12) {
//         winterBonus += salary.paymentAmount;
//       }
//     }
//
//     // 当年
//     final preYearSalaries = filteredSourceList.where((s) => s.createdAt.year == _selectedYear - 1).toList();
//     for (var salary in preYearSalaries) {
//       prevPaymentAmountSum += salary.paymentAmount;
//       prevNetSalarySum += salary.netSalary;
//
//       // 夏季賞与計算(総支給)
//       if (salary.isBonus && salary.createdAt.month <= 6) {
//         prevSummerBonus += salary.paymentAmount;
//       }
//
//       // 冬季賞与計算
//       if (salary.isBonus) {
//         prevWinterBonus += salary.paymentAmount;
//       }
//     }
//
//
//     return Column(
//       spacing: 20,
//       children: [
//         _buildSalaryRow(
//           '年収（総支給）',
//           paymentAmountSum,
//           diff: paymentAmountSum - prevPaymentAmountSum,
//         ),
//         _buildSalaryRow(
//           '年収（手取り）',
//           netSalarySum,
//           diff: netSalarySum - prevNetSalarySum,
//         ),
//         _buildSalaryRow(
//           '夏季賞与（総支給）',
//           summerBonus,
//           diff: summerBonus - prevSummerBonus,
//         ),
//         _buildSalaryRow(
//           '冬季賞与（総支給）',
//           winterBonus,
//           diff: winterBonus - prevWinterBonus,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSalaryRow(String label, int amount, {int diff = 0}) {
//     Color diffColor;
//     String diffText = '';
//
//     if (diff > 0) {
//       diffColor = Colors.green;
//       diffText = '+${NumberUtils.formatWithComma(diff)}円';
//     } else if (diff < 0) {
//       diffColor = Colors.red;
//       diffText = '${NumberUtils.formatWithComma(diff)}円';
//     } else {
//       diffColor = CustomColors.text.withAlpha(120);
//       diffText = '±0';
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             CustomLabelView(labelText: label),
//             const Spacer(),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 CustomText(
//                   text: NumberUtils.formatWithComma(amount),
//                   textSize: TextSize.L,
//                   color: CustomColors.thema,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 const SizedBox(width: 5),
//                 const CustomText(text: '円', textSize: TextSize.S),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 2),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             const Spacer(),
//             const CustomText(text: '前年', textSize: TextSize.SS),
//             const SizedBox(width: 5),
//             CustomText(
//               text: diffText,
//               textSize: TextSize.SS,
//               color: diffColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//
//   /// グラフ描画 & NoData UI
//   Widget _buildYearSalaryChart() {
//     List<LineChartBarData> lines = _buildLines();
//     if (lines.isEmpty) {
//       return Container(
//         width: double.infinity,
//         height: 300,
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: CupertinoColors.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         alignment: Alignment.center,
//         child: const CustomText(
//           text: 'データがありません',
//           textSize: TextSize.M,
//           fontWeight: FontWeight.bold,
//           color: CupertinoColors.systemGrey,
//         ),
//       );
//     }
//     // Y軸の最大値を取得
//     final maxY = _calculateMaxY(lines);
//
//     return Container(
//       width: double.infinity,
//       height: 300,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: CupertinoColors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: LineChart(
//         LineChartData(
//           // ツールチップ設定
//           lineTouchData: LineTouchData(
//             enabled: _selectedSource != _allSource ? true : false,
//             touchTooltipData: LineTouchTooltipData(
//               getTooltipItems: (touchedSpots) {
//                 touchedSpots.removeLast();
//                 return touchedSpots.map((spot) {
//                   return LineTooltipItem(
//                     '${spot.x.toInt()}月\n${NumberUtils.formatWithComma(spot.y.toInt())}円',
//                     const TextStyle(color: Colors.white),
//                   );
//                 }).toList();
//               },
//             ),
//           ),
//           // 最大Y軸
//           maxY: maxY,
//           // 最小Y軸
//           minY: 0,
//           // 各方向のラベル(目盛り)制御
//           titlesData: FlTitlesData(
//             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 70,
//                 getTitlesWidget: (value, meta) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       CustomText(
//                         text: '${NumberUtils.formatWithComma(value.toInt())}円',
//                         textSize: TextSize.SS,
//                       ),
//                       const SizedBox(width: 5),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 interval: 1,
//                 getTitlesWidget: (value, meta) {
//                   return CustomText(
//                     text: '${value.toInt()}月',
//                     textSize: TextSize.SS,
//                   );
//                 },
//               ),
//             ),
//           ),
//           lineBarsData: lines,
//         ),
//       ),
//     );
//   }
//
//   /// Y軸の最大値を取得
//   double _calculateMaxY(List<LineChartBarData> lines) {
//     final maxY = lines.expand((bar) => bar.spots).map((e) => e.y).fold(0.0, max);
//     final padded = maxY * 1.1;
//
//     // 例：14532 → 15000 に切り上げ
//     final magnitude = pow(10, padded.toInt().toString().length - 1);
//     return (padded / magnitude).ceil() * magnitude.toDouble();
//   }
//
//   /// 選択された支払い元のデータを取得し、折れ線データを生成
//   List<LineChartBarData> _buildLines() {
//     List<LineChartBarData> lines = [];
//
//     // 選択中のカテゴリでフィルタリング
//     Map<String, List<Salary>> filteredData =
//         _selectedSource.name == 'ALL'
//             ? _groupedBySource
//             : {
//               _selectedSource.name:
//                   _groupedBySource[_selectedSource.name] ?? [],
//             };
//
//     filteredData.forEach((source, salaries) {
//       // 選択中の年月でフィルタリング
//       List<Salary> filteredSalaries =
//           salaries.where((s) => s.createdAt.year == _selectedYear).toList();
//
//       // 日付順にソート
//       filteredSalaries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//
//       List<FlSpot> paymentSpots =
//           filteredSalaries
//               .map(
//                 (s) => FlSpot(
//                   s.createdAt.month.toDouble(),
//                   s.paymentAmount.toDouble(),
//                 ),
//               )
//               .toList();
//
//       List<FlSpot> netSalarySpots =
//           filteredSalaries
//               .map(
//                 (s) => FlSpot(
//                   s.createdAt.month.toDouble(),
//                   s.netSalary.toDouble(),
//                 ),
//               )
//               .toList();
//       // ALLを選択中のみ複数Line格納される
//       if (paymentSpots.isNotEmpty) {
//         lines.add(
//           LineChartBarData(
//             spots: paymentSpots,
//             isCurved: true,
//             color: filteredSalaries.firstOrNull?.source?.themaColorEnum.color,
//             barWidth: 3,
//             belowBarData: BarAreaData(show: false),
//           ),
//         );
//       }
//
//        // ALLを選択中のみ複数Line格納される
//       if (netSalarySpots.isNotEmpty) {
//         lines.add(
//           LineChartBarData(
//             spots: netSalarySpots,
//             isCurved: true,
//             color: filteredSalaries.firstOrNull?.source?.themaColorEnum.color.withValues(alpha: 0.4),
//             barWidth: 3,
//             belowBarData: BarAreaData(show: false),
//           ),
//         );
//       }
//     });
//     return lines;
//   }
//
//   Widget _buildYearlyPaymentBarChart(List<Salary> salaries) {
//     // 年ごとの総支給額を集計
//     Map<int, int> yearlyPaymentSums = {};
//
//     Map<String, List<Salary>> filteredData =
//     _selectedSource.name == 'ALL'
//         ? _groupedBySource
//         : {
//       _selectedSource.name:
//       _groupedBySource[_selectedSource.name] ?? [],
//     };
//
//     filteredData.forEach((source, salaryList) {
//       for (var s in salaryList) {
//         final year = s.createdAt.year;
//         yearlyPaymentSums[year] = (yearlyPaymentSums[year] ?? 0) + s.paymentAmount;
//       }
//     });
//
//     if (yearlyPaymentSums.isEmpty) {
//       return Container(
//         width: double.infinity,
//         height: 250,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: CupertinoColors.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const CustomText(
//           text: 'データがありません',
//           textSize: TextSize.M,
//           fontWeight: FontWeight.bold,
//           color: CupertinoColors.systemGrey,
//         ),
//       );
//     }
//
//     // 年をソートし、最大10年分だけ使用
//     final sortedYears = yearlyPaymentSums.keys.toList()..sort();
//     final yearsToShow = sortedYears.length > 5
//         ? sortedYears.sublist(sortedYears.length - 5)
//         : sortedYears;
//
//     List<BarChartGroupData> barGroups = [];
//     for (int i = 0; i < yearsToShow.length; i++) {
//       final year = yearsToShow[i];
//       final amount = yearlyPaymentSums[year]!;
//
//       barGroups.add(
//         BarChartGroupData(
//           x: i,
//           barsSpace: 0,
//           barRods: [
//             BarChartRodData(
//               toY: amount.toDouble(),
//               color: Colors.blue,
//               width: 20,
//               borderRadius: BorderRadius.zero,
//             ),
//           ],
//         ),
//       );
//     }
//
//     final maxY =
//         barGroups.expand((g) => g.barRods).map((r) => r.toY).fold(0.0, max) * 1.1;
//
//     return Container(
//       width: double.infinity,
//       height: 250,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: CupertinoColors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: BarChart(
//         BarChartData(
//           maxY: maxY,
//           minY: 0,
//           barTouchData: BarTouchData(
//             enabled: true,
//             touchTooltipData: BarTouchTooltipData(
//               getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                 final year = yearsToShow[group.x.toInt()];
//                 final value = rod.toY.toInt();
//                 return BarTooltipItem(
//                   '$year年\n${NumberUtils.formatWithComma(value)}円',
//                   const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 );
//               },
//             ),
//           ),
//           barGroups: barGroups,
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 60,
//                 getTitlesWidget: (value, meta) => CustomText(
//                   text: '${NumberUtils.formatWithComma(value.toInt())}円',
//                   textSize: TextSize.SS,
//                 ),
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 interval: 1,
//                 getTitlesWidget: (index, meta) {
//                   final year = yearsToShow[index.toInt()];
//                   return CustomText(text: '$year年', textSize: TextSize.SS);
//                 },
//               ),
//             ),
//             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           gridData: const FlGridData(show: true),
//           borderData: FlBorderData(show: false),
//         ),
//       ),
//     );
//   }
// }
