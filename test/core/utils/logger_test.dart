import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

// 仮の logger 関数（対象の関数）
void logger(Object? message) {
  // テスト環境や設定に合わせて kDebugMode の代わりに条件を入れる場合もありますが、
  // 今回はそのまま記載しています
  print(message);
}

void main() {
  group('logger テスト', () {
    test('渡したメッセージが print によって出力されること', () async {
      // ログ出力をキャッチするためのリスト
      final List<String> printedMessages = [];

      // runZoned グローバルな print をフックしてキャッチする
      await runZoned(() async {
        logger('テストメッセージです');
      }, zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printedMessages.add(line);
        },
      ));

      // 検証
      expect(printedMessages, ['テストメッセージです']);
    });
  });
}