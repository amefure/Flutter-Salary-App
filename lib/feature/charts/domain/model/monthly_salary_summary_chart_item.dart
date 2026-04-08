import 'package:salary/core/models/salary.dart';

/// 各グラフの計算元となる支払い元ベースの給料データ
/// 支払い元ごとの月単位の総支給額・手取り額の合計を表示
/// これをリストで保持して1年分表示する
class MonthlySalarySummaryItem {
  /// 生成日時(対象年月の1日が格納される)
  final DateTime createdAt;
  /// 対象年月の合計総支給額
  final int paymentAmount;
  /// 対象年月の合計手取り額
  final int netSalary;
  /// 対象年月の支払い元(未設定もあり)
  final PaymentSource? source;

  MonthlySalarySummaryItem({
    required this.createdAt,
    required this.paymentAmount,
    required this.netSalary,
    required this.source,
  });
}