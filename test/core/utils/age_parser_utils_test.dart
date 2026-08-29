import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/utils/age_parser_utils.dart';

void main() {
  group('AgeParserUtils テスト', () {
    test('引数が null の場合、空のマップを返すこと', () {
      final result = AgeParserUtils.parse(null);
      expect(result, isEmpty);
    });

    test('"20歳以下" の場合、0歳から19歳の範囲を返すこと', () {
      final result = AgeParserUtils.parse('20歳以下');
      expect(result, {
        PremiumQueryKeys.ageFrom: 0,
        PremiumQueryKeys.ageTo: 19,
      });
    });

    test('代の文字列（例: "30代"）の場合、該当する10年間の範囲を返すこと', () {
      final result = AgeParserUtils.parse('30代');
      expect(result, {
        PremiumQueryKeys.ageFrom: 30,
        PremiumQueryKeys.ageTo: 39,
      });
    });

    test('別の代の文字列（例: "20代"）でも正しく計算されること', () {
      final result = AgeParserUtils.parse('20代');
      expect(result, {
        PremiumQueryKeys.ageFrom: 20,
        PremiumQueryKeys.ageTo: 29,
      });
    });

    test('パースできない不正な文字列の場合、空のマップを返すこと', () {
      final result = AgeParserUtils.parse('不明');
      expect(result, isEmpty);
    });
  });
}