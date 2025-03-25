import 'package:intl/intl.dart';

class DateTimeUtils {
  // 指定フォーマットで日付を文字列に変換
  static String format({
    required DateTime dateTime,
    String pattern = "yyyy年M月",
  }) {
    return DateFormat(pattern).format(dateTime);
  }

  // 指定フォーマットの文字列を DateTime に変換
  static DateTime? parse({
    required String dateString, 
    String pattern = "yyyy年M月",
  }) {
    try {
      return DateFormat(pattern).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
