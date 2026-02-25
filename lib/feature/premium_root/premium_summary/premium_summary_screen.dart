import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium_root/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium_root/premium_summary/premium_summary_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PremiumSummaryScreen extends ConsumerWidget {
  const PremiumSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(premiumSummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ====== ランキング ======
          const Text(
            '🏆 年収ランキング TOP10',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...?summary.summaryDto?.top10.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4A90E2),
                    Color(0xFF6FB1FC),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: CupertinoListTile(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  e.user.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${e.user.profile.job} / ${e.user.profile.region} / ${e.user.profile.ageRange}',
                  style: const TextStyle(
                      color: Colors.white70),
                ),
                trailing: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(e.totalPaymentAmount / 10000).toStringAsFixed(0)}万円',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '手取り ${(e.totalNetSalary / 10000).toStringAsFixed(0)}万円',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 40),

          /// ====== 分布 ======
          const Text(
            '📊 年収分布',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (summary.summaryDto?.distribution != null)
            SizedBox(
              height: 250,
              child: _IncomeBarChart(summary.summaryDto!.distribution.withZeroFilled()),
            ),
        ],
      ),
    );
  }
}

class _IncomeBarChart extends StatelessWidget {
  final List<IncomeDistributionDto> distribution;

  const _IncomeBarChart(this.distribution);

  @override
  Widget build(BuildContext context) {
    final tooltipBehavior = TooltipBehavior(enable: true);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      tooltipBehavior: tooltipBehavior,
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(fontSize: 11),
      ),
      primaryYAxis: const NumericAxis(
        isVisible: false,
        majorGridLines: MajorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.hide,
      ),
      series: <CartesianSeries>[
        BarSeries<IncomeDistributionDto, String>(
          dataSource: distribution.reversed.toList(),
          xValueMapper: (data, _) => data.incomeRange,
          yValueMapper: (data, _) => data.userCount,
          borderRadius:
          const BorderRadius.all(Radius.circular(8)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment:
            ChartDataLabelAlignment.outer,
            textStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          gradient: const LinearGradient(
            colors: [
              CustomColors.thema,
              CustomColors.thema
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ],
    );
  }
}