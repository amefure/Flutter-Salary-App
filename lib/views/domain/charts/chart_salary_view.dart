import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
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
  /// グラフに表示するためのグルーピングデータ
  late Map<String, List<Salary>> _groupedBySource;
  // Salaryに存在する支払い元リスト
  late List<PaymentSource> _sourceList;
  // 表示中の支払い元
  late PaymentSource _selectedSource;

  /// "全て" を表すダミーの PaymentSource を作成
  final PaymentSource _allSource = PaymentSource(
    Uuid.v4().toString(),
    "ALL",
    ThemaColor.blue.value,
  );

  @override
  void initState() {
    super.initState();
    _selectedSource = _allSource;
  }

  void _groupSalariesBySource() {
    _groupedBySource = {};
    for (var salary in widget.salaryList) {
      String sourceName = salary.source?.name ?? "未設定";
      if (!_groupedBySource.containsKey(sourceName)) {
        _groupedBySource[sourceName] = [];
      }
      _groupedBySource[sourceName]!.add(salary);
    }

    // 支払い元リストを作成
    _sourceList = [
      _allSource,
      ..._groupedBySource.values.map(
        (name) => name.first?.source ?? _allSource,
      ),
    ];

    // 選択されている支払い元がリストに含まれていない場合、デフォルトを "全て" にする
    if (!_sourceList.contains(_selectedSource)) {
      _selectedSource = _allSource;
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: screen.width),

              SizedBox(
                width: screen.width * 0.5,
                child: _buildSourceSelector(),
              ),

              const SizedBox(height: 20),

              Container(
                width: screen.width * 0.97,
                height: 300,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
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

  /// **給与の支払い元を選択するUI (MenuAnchor)**
  Widget _buildSourceSelector() {
    return MenuAnchor(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: _sourceLabel(_selectedSource),
        );
      },
      menuChildren:
          _sourceList.map((source) {
            return MenuItemButton(
              onPressed: () {
                setState(() {
                  _selectedSource = source;
                });
              },
              child: SizedBox(
                width: 200,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.building_2_fill,
                      color: source.themaColorEnum.color,
                    ),
                    const SizedBox(width: 8),
                    CustomText(text: source.name, fontWeight: FontWeight.bold),
                    const Spacer(),
                    if (_selectedSource == source)
                      const Icon(CupertinoIcons.checkmark_alt),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  /// 支払い元UIラベル
  Widget _sourceLabel(PaymentSource _selectedSource) {
    final PaymentSource? paymentSource =
        _groupedBySource[_selectedSource.name]?.firstOrNull?.source;
    final Color color =
        paymentSource?.themaColorEnum.color ?? ThemaColor.blue.color;

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
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.building_2_fill, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: paymentSource?.name ?? "ALL",
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

  /// 選択された支払い元のデータを取得し、折れ線データを生成
  List<LineChartBarData> _buildLines() {
    List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    int colorIndex = 0;
    List<LineChartBarData> lines = [];

    Map<String, List<Salary>> filteredData =
        _selectedSource.name == "ALL"
            ? _groupedBySource
            : {
              _selectedSource.name:
                  _groupedBySource[_selectedSource.name] ?? [],
            };

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
