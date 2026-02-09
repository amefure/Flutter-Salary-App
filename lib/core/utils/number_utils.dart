import 'package:intl/intl.dart';

class NumberUtils {
  // 数値をカンマ区切りのフォーマットに変換する
  static String formatWithComma(int number) {
    return NumberFormat('#,###').format(number);
  }
}
