/// ③ 年別合計金額(10年間)棒グラフ用データクラス
/// 年ごとの総支給額を支払い元は識別にせずに統合して計算
/// グラフで表示すべきデータ全体を保持する
class YearlyPaymentChartData {
  final List<int> years;
  final List<int> amounts;
  final double maxY;

  const YearlyPaymentChartData({
    required this.years,
    required this.amounts,
    required this.maxY,
  });

  static YearlyPaymentChartData initial() {
    return const YearlyPaymentChartData(
        years: [],
        amounts: [],
        maxY: 0
    );
  }

  bool get isEmpty => years.isEmpty;
}
