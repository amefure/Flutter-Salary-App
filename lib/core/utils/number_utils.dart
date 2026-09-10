import 'package:intl/intl.dart';

abstract class NumberUtils {
  // 数値をカンマ区切りのフォーマットに変換する
  static String formatWithComma(int number) {
    return NumberFormat('#,###').format(number);
  }
  /// 数値を「◯万円」形式の文字列に変換する
  /// 例: 150000 -> "15万円"
  static String formatToMan(int number) {
    if (number < 10000) {
      return '${formatWithComma(number)}円';
    }
    final man = (number / 10000).round();
    return '${NumberFormat('#,###').format(man)}万円';
  }
}
