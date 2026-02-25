import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium_root/data/dto/income_distribution_dto.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IncomeBarChart extends StatelessWidget {
  final List<IncomeDistributionDto> distribution;

  const IncomeBarChart(this.distribution, {super.key});

  @override
  Widget build(BuildContext context) {
    final tooltipBehavior = TooltipBehavior(enable: true);

    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SfCartesianChart(
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
            dataSource: distribution,
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
      )
    );
  }
}