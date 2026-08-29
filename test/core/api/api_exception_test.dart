import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/api/api_exception.dart';

void main() {
  group('ApiErrorCode テスト', () {
    test('有効なコード文字列から対応する ApiErrorCode が取得できること', () {
      expect(ApiErrorCode.fromCode('EA001'), ApiErrorCode.validation);
      expect(ApiErrorCode.fromCode('EA002'), ApiErrorCode.unauthorized);
      expect(ApiErrorCode.fromCode('EA003'), ApiErrorCode.forbidden);
      expect(ApiErrorCode.fromCode('EA004'), ApiErrorCode.notFound);
      expect(ApiErrorCode.fromCode('EA005'), ApiErrorCode.server);
    });

    test('無効なコードや null が渡された場合に null が返ること', () {
      expect(ApiErrorCode.fromCode('INVALID_CODE'), isNull);
      expect(ApiErrorCode.fromCode(null), isNull);
    });
  });

  group('ApiException テスト', () {
    test('プロパティが正しく保持されること', () {
      const exception = ApiException(
        statusCode: 400,
        message: 'エラーメッセージです',
        type: ApiErrorType.validation,
        title: 'タイトル',
        code: 'EA001',
        details: {'field': 'invalid'},
      );

      expect(exception.statusCode, 400);
      expect(exception.message, 'エラーメッセージです');
      expect(exception.type, ApiErrorType.validation);
      expect(exception.title, 'タイトル');
      expect(exception.code, 'EA001');
      expect(exception.details, {'field': 'invalid'});
    });

    test('toString が想定通りのフォーマットで文字列を返すこと', () {
      const exception = ApiException(
        statusCode: 401,
        message: '認証に失敗しました',
        type: ApiErrorType.unauthorized,
        code: 'EA002',
      );

      expect(exception.toString(), 'ApiException(EA002): 認証に失敗しました');
    });
  });
}