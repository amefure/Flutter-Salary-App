import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/number_utils.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_text_view.dart';

class ChartSalaryView extends StatefulWidget {
  final List<Salary> salaryList;

  ChartSalaryView({required this.salaryList});

  @override
  _ChartSalaryViewState createState() => _ChartSalaryViewState();
}

class _ChartSalaryViewState extends State<ChartSalaryView> {
  late Map<String, List<Salary>> groupedBySource;
  late List<String> sourceList;
  String selectedSource = "全て";

  @override
  void initState() {
    super.initState();
  }

  void _groupSalariesBySource() {
    groupedBySource = {};
    for (var salary in widget.salaryList) {
      String sourceName = salary.source?.name ?? "その他";
      if (!groupedBySource.containsKey(sourceName)) {
        groupedBySource[sourceName] = [];
      }
      groupedBySource[sourceName]!.add(salary);
    }
    sourceList = ["全て", ...groupedBySource.keys];
    if (!sourceList.contains(selectedSource)) {
      selectedSource = "全て";
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Consumer2<SalaryViewModel, PaymentSourceViewModel>(
        builder: (context, salaryViewModel, paymentSourceViewModel, child) {
          _groupSalariesBySource();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSourcePicker(),
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 80,
                          getTitlesWidget: (value, meta) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomText(
                                  text:
                                      "${NumberUtils.formatWithComma(value.toInt())}円",
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
                          minIncluded: false,
                          maxIncluded: false,
                          getTitlesWidget: (value, meta) {
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt(),
                            );
                            return Text(
                              DateFormat("M月").format(date),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: _buildLines(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 支払い元のピッカーを作成
  Widget _buildSourcePicker() {
    return SizedBox(
      height: 100,
      child: CupertinoPicker(
        itemExtent: 40,
        onSelectedItemChanged: (index) {
          setState(() {
            selectedSource = sourceList[index];
          });
        },
        children:
            sourceList
                .map((source) => Text(source, style: TextStyle(fontSize: 16)))
                .toList(),
      ),
    );
  }

  /// 選択された支払い元のデータを取得し、折れ線データを生成
  List<LineChartBarData> _buildLines() {
    List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    int colorIndex = 0;
    List<LineChartBarData> lines = [];

    Map<String, List<Salary>> filteredData =
        selectedSource == "全て"
            ? groupedBySource
            : {selectedSource: groupedBySource[selectedSource] ?? []};

    filteredData.forEach((source, salaries) {
      salaries.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      List<FlSpot> paymentSpots =
          salaries
              .map(
                (s) => FlSpot(
                  s.createdAt.millisecondsSinceEpoch.toDouble(),
                  s.paymentAmount.toDouble(),
                ),
              )
              .toList();

      lines.add(
        LineChartBarData(
          spots: paymentSpots,
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
        ),
      );

      colorIndex++;
    });

    return lines;
  }
}
