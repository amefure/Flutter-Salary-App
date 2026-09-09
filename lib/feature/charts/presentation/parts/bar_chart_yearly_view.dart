import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/charts/presentation/parts/empty_chart_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/number_utils.dart';

/// ③ 年別合計金額(5年間)棒グラフ用ビュー
class BarChartYearlyView extends ConsumerWidget {
  const BarChartYearlyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(chartSalaryProvider.select((s) => s.yearlyBarChartData));
    final vm = ref.read(chartSalaryProvider.notifier);

    if (chartData.isEmpty) {
      return const EmptyChartView();
    }

    final yearsToShow = chartData.years;
    final amounts = chartData.amounts;

    final startYear = yearsToShow.first;
    final endYear = yearsToShow.last;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < yearsToShow.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: amounts[i].toDouble(),
              color: CustomColors.thema,
              width: 20,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // ヘッダー：期間表示 ＆ 1年ずつずらすボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => vm.shiftBarChartYear(-1),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.chevron_left, size: 16),
                    SizedBox(width: 4),
                    CustomText(text: '前年', textSize: TextSize.S),
                  ],
                ),
              ),
              CustomText(
                text: '$startYear年 〜 $endYear年',
                textSize: TextSize.M,
                fontWeight: FontWeight.bold,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => vm.shiftBarChartYear(1),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(text: '翌年', textSize: TextSize.S),
                    SizedBox(width: 4),
                    Icon(CupertinoIcons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 棒グラフ本体
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: chartData.maxY > 0 ? chartData.maxY : 10000,
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
                      reservedSize: 60, // 元のサイズに戻す
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CustomText(
                            text: '${NumberUtils.formatToMan(value.toInt())}万',
                            textSize: TextSize.SS,
                            color: CupertinoColors.systemGrey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (index, meta) {
                        final int i = index.toInt();
                        if (i < 0 || i >= yearsToShow.length) return const SizedBox.shrink();
                        final year = yearsToShow[i];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: CustomText(
                            text: '$year年',
                            textSize: TextSize.SS,
                            color: CupertinoColors.systemGrey,
                          ),
                        );
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
          ),
        ],
      ),
    );
  }
}