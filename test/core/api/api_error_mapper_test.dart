import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/api/api_error_mapper.dart';
import 'package:salary/core/api/api_exception.dart';

void main() {
  group('ApiErrorMapper テスト', () {
    test('fromOffline が正しいオフライン用 ApiException を返すこと', () {
      final exception = ApiErrorMapper.fromOffline();

      expect(exception.statusCode, 0);
      expect(exception.type, ApiErrorType.offline);
      expect(exception.code, 'OFFLINE');
      expect(exception.message, contains('インターネットに接続されていません'));
    });

    test('fromPreCheckUnauthorized が正しい未認証用 ApiException を返すこと', () {
      final exception = ApiErrorMapper.fromPreCheckUnauthorized();

      expect(exception.statusCode, 401);
      expect(exception.type, ApiErrorType.unauthorized);
      expect(exception.code, 'AUTH_TOKEN_NOT_FOUND');
      expect(exception.message, contains('ログインセッションがありません'));
    });

    group('fromResponse テスト', () {
      test('通常のレスポンスから正しく ApiException を生成できること', () {
        final Map<String, dynamic> responseBody = {
          'error': {
            'code': 'EA002',
            'message': 'セッションが切れました',
            'title': '認証エラー',
          }
        };

        final exception = ApiErrorMapper.fromResponse(401, responseBody);

        expect(exception.statusCode, 401);
        expect(exception.code, 'EA002');
        expect(exception.message, 'セッションが切れました');
        expect(exception.title, '認証エラー');
        expect(exception.type, ApiErrorType.unauthorized);
      });

      test('message が JSON文字列（Map形式）の場合、改行区切りで結合されること', () {
        // バリデーションエラーなどでありがちな JSON 文字列パターン
        final jsonMessage = '{"email":["メールアドレスの形式が正しくありません。"],"password":["パスワードは6文字以上必要です。"]}';

        final Map<String, dynamic> responseBody = {
          'error': {
            'code': 'EA001',
            'message': jsonMessage,
          }
        };

        final exception = ApiErrorMapper.fromResponse(422, responseBody);

        expect(exception.statusCode, 422);
        expect(exception.type, ApiErrorType.validation);
        // Map の値（List）が展開されて \n で結合されていることを確認
        expect(
          exception.message,
          contains('メールアドレスの形式が正しくありません。'),
        );
        expect(
          exception.message,
          contains('パスワードは6文字以上必要です。'),
        );
      });

      test('message が JSON文字列（List形式）の場合、改行区切りで結合されること', () {
        final jsonMessage = '["エラー1です","エラー2です"]';

        final Map<String, dynamic> responseBody = {
          'error': {
            'code': 'BAD_REQUEST',
            'message': jsonMessage,
          }
        };

        final exception = ApiErrorMapper.fromResponse(400, responseBody);

        expect(exception.message, 'エラー1です\nエラー2です');
      });

      test('error キーや message が存在しない場合は「不明なエラー」を返すこと', () {
        final Map<String, dynamic> responseBody = {};

        final exception = ApiErrorMapper.fromResponse(500, responseBody);

        expect(exception.message, '不明なエラー');
        expect(exception.type, ApiErrorType.unknown);
      });
    });
  });
}