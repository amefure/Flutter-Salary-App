/// グラフ表示タブ
enum ChartDisplayMode {
  /// 折れ線
  line,
  /// 円グラフ
  pie;

  /// 現在と反対のモードを取得
  ChartDisplayMode get opposite => this == ChartDisplayMode.line ? ChartDisplayMode.pie : ChartDisplayMode.line;
}
