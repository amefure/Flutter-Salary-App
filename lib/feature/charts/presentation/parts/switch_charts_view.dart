import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/charts/presentation/parts/empty_chart_view.dart';
import 'package:salary/feature/charts/domain/model/chart_display_mode.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';

/// 「① 月別合計金額グラフ」
/// 折れ線 or 円グラフに切り替え可能
class SwitchChartsView extends ConsumerWidget {

  const SwitchChartsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = ref.watch(chartSalaryProvider.select((s) => s.chartDisplayMode));

    switch (displayMode) {
      case ChartDisplayMode.line:
        return _buildYearSalaryChart(context, ref);

      case ChartDisplayMode.pie:
        return _buildPieChart(context, ref);
    }
  }

  /// グラフ描画 & NoData UI
  Widget _buildYearSalaryChart(
      BuildContext context,
      WidgetRef ref
      ) {
    final selectedSource = ref.watch(chartSalaryProvider.select((s) => s.selectedSource));
    final vm = ref.read(chartSalaryProvider.notifier);

    List<LineChartBarData> lines = _buildLines(ref);
    if (lines.isEmpty) {
      return const EmptyChartView();
    }
    final values = lines.expand((bar) => bar.spots).map((spot) => spot.y);
    // Y軸の最大値を取得
    final maxY = vm.calculateMaxY(values);

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          /// ツールチップ設定
          lineTouchData: LineTouchData(
            enabled: selectedSource != DummySource.allDummySource ? true : false,
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

  List<LineChartBarData> _buildLines(WidgetRef ref) {
    final lineChartData = ref.watch(chartSalaryProvider.select((s) => s.lineChartData));

    return lineChartData.expand((monthlyDataList) {
      final source = monthlyDataList.first.source;
      final baseColor = source?.themaColorEnum.color ?? Colors.blue;

      /// 総支給の線
      final paymentLine = LineChartBarData(
        spots: monthlyDataList.map((d) => FlSpot(d.createdAt.month.toDouble(), d.paymentAmount.toDouble())).toList(),
        isCurved: true,
        color: baseColor,
        barWidth: 3,
        belowBarData: BarAreaData(show: false),
      );

      /// 手取りの線
      final netLine = LineChartBarData(
        spots: monthlyDataList.map((d) => FlSpot(d.createdAt.month.toDouble(), d.netSalary.toDouble())).toList(),
        isCurved: true,
        color: baseColor.withValues(alpha: 0.4),
        barWidth: 3,
        belowBarData: BarAreaData(show: false),
      );

      return [paymentLine, netLine];
    }).toList();
  }


  Widget _buildPieChart(
      BuildContext context,
      WidgetRef ref
      ) {
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

      final titleName = source?.name ?? DummySource.UNSET_TITLE;
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
        color: CustomColors.background(context),
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