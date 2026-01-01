

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/charts/view/empty_chart_view.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/utilities/number_utils.dart';

/// 年ごとの給料グラフ(過去10年分)
class BarChartYearlyView extends ConsumerWidget {

  const BarChartYearlyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(chartSalaryProvider.notifier);

    final selectedSource = ref.watch(chartSalaryProvider.select((s) => s.selectedSource));
    final groupedBySource = ref.watch(chartSalaryProvider.select((s) => s.groupedBySource));

    final chartData = vm
        .buildYearlyPaymentBarChartData(
        selectedSource: selectedSource,
        groupedBySource: groupedBySource,
    );

    if (chartData.isEmpty) {
      return const EmptyChartView();
    }

    final yearsToShow = chartData.years;
    final amounts = chartData.amounts;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < yearsToShow.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: amounts[i].toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

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
          maxY: chartData.maxY,
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
}