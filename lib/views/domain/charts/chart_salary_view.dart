import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/number_utils.dart';
import 'package:salary/views/components/custom_text_view.dart';

class ChartSalaryView extends StatelessWidget {
  final List<Salary> salaryList;

  ChartSalaryView({required this.salaryList});

  @override
  Widget build(BuildContext context) {
    Map<String, List<Salary>> groupedBySource = {};

    // データを支払い元ごとにグループ化
    for (var salary in salaryList) {
      String sourceName = salary.source?.name ?? "その他";
      if (!groupedBySource.containsKey(sourceName)) {
        groupedBySource[sourceName] = [];
      }
      groupedBySource[sourceName]!.add(salary);
    }

    final screen = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('給料MEMO'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
          onPressed: () {},
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screen.width * 0.97,
            height: 300,
            child: LineChart(
              LineChartData(
                minY: 0,
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // 左ラベル
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (value, meta) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              text: NumberUtils.formatWithComma(value.toInt()) + "円",
                            ),
                            const SizedBox(width: 5),
                          ],
                        );
                      },
                    ), // Y軸（給与）
                  ),
                  // 下ラベル
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      minIncluded: false,
                      maxIncluded: false,
                      getTitlesWidget: (value, meta) {
                        // ミリ秒から DateTime に変換
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          value.toInt(),
                        );

                        // "2024年4月" 形式にフォーマット
                        String formattedDate = DateFormat("M月").format(date);

                        if (true) {
                          return Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12),
                          );
                        } else {
                          return SizedBox(width: 0);
                        }
                      },
                    ),
                  ),
                ),
                // borderData: FlBorderData(show: true),
                // gridData: FlGridData(show: true),
                lineBarsData: _buildLines(groupedBySource),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // グラフ用の折れ線データを生成
  List<LineChartBarData> _buildLines(
    Map<String, List<Salary>> groupedBySource,
  ) {
    List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];

    int colorIndex = 0;
    List<LineChartBarData> lines = [];

    print("----" + groupedBySource.length.toString());

    groupedBySource.forEach((source, salaries) {
      salaries.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // X軸のデータ（年月を数値に変換）
      List<FlSpot> paymentSpots =
          salaries
              .map(
                (s) => FlSpot(
                  s.createdAt.millisecondsSinceEpoch.toDouble(),
                  s.paymentAmount.toDouble(),
                ),
              )
              .toList();

      List<FlSpot> netSalarySpots =
          salaries
              .map(
                (s) => FlSpot(
                  s.createdAt.millisecondsSinceEpoch.toDouble(),
                  s.netSalary.toDouble(),
                ),
              )
              .toList();

      // 総支給額の折れ線
      lines.add(
        LineChartBarData(
          spots: paymentSpots,
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
        ),
      );

      // // 手取り額の折れ線（少し透明にする）
      // lines.add(
      //   LineChartBarData(
      //     spots: netSalarySpots,
      //     isCurved: true,
      //     color: colors[colorIndex % colors.length].withOpacity(0.5),
      //     barWidth: 3,
      //     belowBarData: BarAreaData(show: false),
      //   ),
      // );

      colorIndex++;
    });
    print("----" + lines.length.toString());
    return lines;
  }
}
