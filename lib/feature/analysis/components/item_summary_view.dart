import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/analysis/salary_analysis_view_model.dart';

class ItemSummaryView extends ConsumerWidget {
  const ItemSummaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);

    // 選択項目が控除項目かどうかで色を分ける
    final isDeduction = vm.isSelectedItemSelectedAsDeduction;
    final chartColor = isDeduction ? CustomColors.negative : CustomColors.thema;

    // 1年分の月次データを取得
    final monthlyData = vm.getMonthlyDataForYear();
    final totalSum = monthlyData.reduce((a, b) => a + b);

    // スポットデータ作成（1月〜12月）
    final spots = monthlyData.asMap().entries.map((e) {
      return FlSpot((e.key + 1).toDouble(), e.value);
    }).toList();

    final values = spots.map((spot) => spot.y);
    final maxY = vm.calculateMaxY(values);

    return Column(
      children: [
        // 1. 項目選択用ピル型スクロールリスト
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.availableItemNames.length,
            itemBuilder: (context, index) {
              final itemName = state.availableItemNames[index];
              final isSelected = state.selectedItemName == itemName;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => vm.selectItemName(itemName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? chartColor
                          : CustomColors.background(context),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: CustomColors.themaGray, width: 0.5),
                    ),
                    child: CustomText(
                      text: itemName,
                      color: isSelected ? CustomColors.textWhite : CustomColors.text(context),
                      fontWeight: FontWeight.w600,
                      textSize: TextSize.S,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 2. 年選択UI
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: () => vm.changeYear(-1),
              child: const Icon(CupertinoIcons.chevron_back),
            ),
            CustomText(
              text: '${state.selectedYear}年',
              fontWeight: FontWeight.bold,
              textSize: TextSize.M,
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: () => vm.changeYear(1),
              child: const Icon(CupertinoIcons.chevron_forward),
            ),
          ],
        ),

        // 3. 年間累計額カード（支給か控除かのラベル＆色分け付き）
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CustomColors.background(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: '年間累計額',
                      textSize: TextSize.S,
                      color: CustomColors.themaGray,
                    ),
                    // 支給 / 控除の種別バッジ
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: chartColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomText(
                        text: isDeduction ? '控除項目' : '支給項目',
                        textSize: TextSize.SS,
                        color: chartColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: '${NumberUtils.formatWithComma(totalSum.toInt())} 円',
                  textSize: TextSize.L,
                  fontWeight: FontWeight.bold,
                  color: chartColor,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 4. 折れ線グラフエリア
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CustomColors.background(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.x.toInt()}月\n${NumberUtils.formatWithComma(spot.y.toInt())}円',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
                maxY: maxY,
                minY: 0,
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
                gridData: const FlGridData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false, // 直線でカクつきを防止
                    color: chartColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: chartColor.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}