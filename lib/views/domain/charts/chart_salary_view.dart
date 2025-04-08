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
import 'package:salary/views/components/ad_banner_widget.dart';
import 'package:salary/views/components/custom_label_view.dart';
import 'package:salary/views/components/custom_text_view.dart';

class ChartSalaryView extends StatefulWidget {
  ChartSalaryView({super.key});

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
  // 表示中の年月
  late int _selectedYear;

  /// "全て" を表すダミーの PaymentSource を作成
  final PaymentSource _allSource = PaymentSource(
    Uuid.v4().toString(),
    "ALL",
    ThemaColor.blue.value,
  );

   /// "全て" を表すダミーの PaymentSource を作成
  final PaymentSource _unSetSource = PaymentSource(
    Uuid.v4().toString(),
    "未設定",
    ThemaColor.blue.value,
  );

  @override
  void initState() {
    super.initState();
    _selectedSource = _allSource;
    _selectedYear = DateTime.now().year;
  }

  void _groupSalariesBySource(List<Salary> salaryList) {
    _groupedBySource = {};

    for (var salary in salaryList) {
      String sourceName = salary.source?.name ?? "未設定";

      // 支払い元ごとのリストがなければ作成
      if (!_groupedBySource.containsKey(sourceName)) {
        _groupedBySource[sourceName] = [];
      }

      // `createdAt` を "yyyy-MM" の形式でキーにする
      String yearMonthKey = DateFormat("yyyy-MM").format(salary.createdAt);

      // 同じ年月のデータがあるかチェック
      var existingIndex = _groupedBySource[sourceName]!.indexWhere(
        (s) => DateFormat("yyyy-MM").format(s.createdAt) == yearMonthKey,
      );

      // 月初の 0 時 0 分 にリセットする
      DateTime resetToMonthStart(DateTime date) {
        return DateTime(date.year, date.month, 1, 0, 0, 0);
      }

      if (existingIndex == -1) {
        // 初回のデータなら新しいインスタンスを作成して追加
        _groupedBySource[sourceName]!.add(
          Salary(
            salary.id,
            salary.paymentAmount,
            salary.deductionAmount,
            salary.netSalary,
            resetToMonthStart(salary.createdAt),
            salary.memo,
            paymentAmountItems: salary.paymentAmountItems.toList(), // コピー
            deductionAmountItems: salary.deductionAmountItems.toList(), // コピー
            source: salary.source, // 参照のまま
          ),
        );
      } else {
        // すでに存在するデータなら、新しいコピーを作成して置き換える
        var existingSalary = _groupedBySource[sourceName]![existingIndex];

        var updatedSalary = Salary(
          existingSalary.id,
          existingSalary.paymentAmount + salary.paymentAmount,
          existingSalary.deductionAmount + salary.deductionAmount,
          existingSalary.netSalary + salary.netSalary,
          resetToMonthStart(existingSalary.createdAt), // 日付は元のまま
          existingSalary.memo,
          paymentAmountItems: existingSalary.paymentAmountItems.toList(), // コピー
          deductionAmountItems:
              existingSalary.deductionAmountItems.toList(), // コピー
          source: existingSalary.source, // 参照のまま
        );

        // List の要素を更新
        _groupedBySource[sourceName]![existingIndex] = updatedSalary;
      }
    }

    // 支払い元リストを作成
    _sourceList = [
      _allSource,
      ..._groupedBySource.values.map(
        (name) => name.firstOrNull?.source ?? _unSetSource,
      ),
    ];

    // 選択されている支払い元がリストに含まれていない場合、デフォルトを "全て" にする
    if (!_sourceList.contains(_selectedSource)) {
      _selectedSource = _allSource;
    }
  }

  /// 選択年月を変更
  void _changeYear(int offset) {
    setState(() {
      _selectedYear += offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: CupertinoNavigationBar(middle: const Text('')),
      child: Consumer2<SalaryViewModel, PaymentSourceViewModel>(
        builder: (context, salaryViewModel, paymentSourceViewModel, child) {
          _groupSalariesBySource(salaryViewModel.salaries);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: screen.width),

              SizedBox(
                width: screen.width * 0.5,
                child: _buildSourceSelector(),
              ),

              const SizedBox(height: 20),

              SizedBox(width: screen.width * 0.95, child: _buildChart()),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_back),
                    onPressed: () => _changeYear(-1),
                  ),
                  CustomText(
                    text: "$_selectedYear年 1月 〜 12月",
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_forward),
                    onPressed: () => _changeYear(1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(width: screen.width * 0.9, child: _tableSalayInfo()),

              const Spacer(),

              const AdMobBannerWidget(),
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

  Widget _tableSalayInfo() {
    // 選択中のカテゴリでフィルタリング
    Map<String, List<Salary>> filteredData =
        _selectedSource.name == "ALL"
            ? _groupedBySource
            : {
              _selectedSource.name:
                  _groupedBySource[_selectedSource.name] ?? [],
            };
    int paymentAmountSum = 0;
    int netSalarySum = 0;

    filteredData.forEach((source, salaries) {
      // 選択中の年月でフィルタリング
      List<Salary> filteredSalaries =
          salaries.where((s) => s.createdAt.year == _selectedYear).toList();

      // 支給額・手取り額を合計する
      for (var salary in filteredSalaries) {
        paymentAmountSum += salary.paymentAmount;
        netSalarySum += salary.netSalary;
      }
    });

    return Column(
      spacing: 20,
      children: [
        _buildSalaryRow("年収（総支給）", paymentAmountSum),
        _buildSalaryRow("年収（手取り）", netSalarySum),
      ],
    );
  }

  /// ラベルと金額表示UI
  Widget _buildSalaryRow(String label, int amount) {
    return Row(
      children: [
        CustomLabelView(labelText: label),

        const Spacer(),
        const SizedBox(width: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: NumberUtils.formatWithComma(amount),
              textSize: TextSize.L,
              color: CustomColors.thema,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(width: 5),
            const CustomText(text: "円", textSize: TextSize.S),
          ],
        ),
      ],
    );
  }

  /// グラフ描画 & NoData UI
  Widget _buildChart() {
    List<LineChartBarData> lines = _buildLines();

    if (lines.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const CustomText(
          text: "データがありません",
          textSize: TextSize.M,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 300,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 70,
                getTitlesWidget: (value, meta) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "${NumberUtils.formatWithComma(value.toInt())}円",
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
                    text: "${value.toInt()}月",
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
  List<LineChartBarData> _buildLines() {
    List<LineChartBarData> lines = [];

    // 選択中のカテゴリでフィルタリング
    Map<String, List<Salary>> filteredData =
        _selectedSource.name == "ALL"
            ? _groupedBySource
            : {
              _selectedSource.name:
                  _groupedBySource[_selectedSource.name] ?? [],
            };

    filteredData.forEach((source, salaries) {
      // 選択中の年月でフィルタリング
      List<Salary> filteredSalaries =
          salaries.where((s) => s.createdAt.year == _selectedYear).toList();

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
}
