
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/view/empty_chart_view.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'dart:math';
import 'package:salary/models/salary.dart';
import 'package:salary/utilities/number_utils.dart';
import 'package:salary/charts/chart_salary_view_model.dart';

class SwitchChartsView extends ConsumerWidget {

  const SwitchChartsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = ref.watch(chartSalaryProvider.select((s) => s.displayMode));

    switch (displayMode) {
      case ChartDisplayMode.line:
        return _buildYearSalaryChart(ref);

      case ChartDisplayMode.pie:
        return _buildPieChart(ref);
    }
  }

  /// グラフ描画 & NoData UI
  Widget _buildYearSalaryChart(WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);
    final vm = ref.read(chartSalaryProvider.notifier);

    final selectedSource = state.selectedSource;

    List<LineChartBarData> lines = _buildLines(ref);
    if (lines.isEmpty) {
      return const EmptyChartView();
    }
    final values = lines.expand((bar) => bar.spots).map((spot) => spot.y);
    // Y軸の最大値を取得
    final maxY = vm.calculateMaxYFromValues(values);

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
            enabled: selectedSource != ChartSalaryViewModel.allDummySource ? true : false,
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


  /// 選択された支払い元のデータを取得し、折れ線データを生成
  List<LineChartBarData> _buildLines(WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);
    final selectedSource = state.selectedSource;
    final selectedYear = state.selectedYear;
    final groupedBySource = state.groupedBySource;
    List<LineChartBarData> lines = [];

    // 選択中のカテゴリでフィルタリング
    Map<String, List<MonthlySalarySummary>> filteredData =
    selectedSource.id == ChartSalaryViewModel.allDummySource.id
        ? groupedBySource
        : { selectedSource.id : groupedBySource[selectedSource.id] ?? [] };

    filteredData.forEach((source, salaries) {
      // 選択中の年月でフィルタリング
      List<MonthlySalarySummary> filteredSalaries =
      salaries.where((s) => s.createdAt.year == selectedYear).toList();

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


  Widget _buildPieChart(WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);

    final selectedYear = state.selectedYear;
    final groupedBySource = state.groupedBySource;

    if (groupedBySource.isEmpty) {
      return const EmptyChartView();
    }

    // 支払い元ごとの合計金額（年フィルタ済）
    final Map<String, int> sumsBySource = {};
    // 色取得用
    final Map<String, PaymentSource?> sourceMap = {};

    groupedBySource.forEach((sourceName, list) {
      // 年フィルタ
      final yearlyList = list.where((s) => s.createdAt.year == selectedYear).toList();

      if (yearlyList.isEmpty) return;

      final sum = yearlyList.fold<int>(0, (prev, s) => prev + s.paymentAmount,);

      if (sum > 0) {
        sumsBySource[sourceName] = sum;
        sourceMap[sourceName] = yearlyList.first.source;
      }
    });

    if (sumsBySource.isEmpty) {
      return const EmptyChartView();
    }

    final total =
    sumsBySource.values.fold<int>(0, (a, b) => a + b);

    final sections = sumsBySource.entries.map((e) {
      final sourceName = e.key;
      final value = e.value;
      final source = sourceMap[sourceName];

      final titleName = source?.name ?? ChartSalaryViewModel.UNSET_TITLE;
      final titlePercent = '${(value / total * 100).toStringAsFixed(1)}%';

      return PieChartSectionData(
        value: value.toDouble(),
        title: '$titleName\n$titlePercent',
        color: source?.themaColorEnum.color ?? Colors.grey,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

}