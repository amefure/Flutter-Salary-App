import 'dart:ui';

/// 円グラフの1セクションを表すデータ
class PieChartSectorData {
  final String name;
  final int amount;
  final double percentage;
  final Color color;

  PieChartSectorData({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}