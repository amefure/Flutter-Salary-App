import 'package:salary/core/config/json_keys.dart';

abstract class AgeParserUtils {
  /// 年齢層文字列（"30代", "20歳以下" など）を数値範囲に変換する
  static Map<String, int> parse(String? ageRange) {
    // nullなら早期リターン

    if (ageRange == null) {return {}; }
    if (ageRange == '20歳以下') {
      return {
        PremiumQueryKeys.ageFrom: 0,
        PremiumQueryKeys.ageTo: 19,
      };
    }

    final age = int.tryParse(ageRange.replaceAll('代', ''));
    if (age != null) {
      return {
        PremiumQueryKeys.ageFrom: age,
        PremiumQueryKeys.ageTo: age + 9,
      };
    }

    return {};
  }
}
