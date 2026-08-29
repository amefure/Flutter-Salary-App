import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/api/token_storage.dart';
import 'package:salary/core/api/api_client.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockTokenStorage extends Mock implements TokenStorage {}
class FakeUri extends Fake implements Uri {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHttpClient mockHttpClient;
  late MockTokenStorage mockTokenStorage;
  late ApiClient apiClient;

  const baseUrl = 'https://api.example.com';

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockTokenStorage = MockTokenStorage(); // 変数名修正
    mockTokenStorage = MockTokenStorage();

    // ★ connectivity_plus のプラットフォームチャンネルをモック化（常にオンラインを返す）
    const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return ['wifi']; // 接続ありの状態を返す
      }
      return null;
    });

    apiClient = ApiClient(
      baseUrl: baseUrl,
      tokenStorage: mockTokenStorage,
      client: mockHttpClient,
    );
  });

  group('ApiClient テスト', () {
    test('ステータスコード 401 の場合、tokenStorage.clear() が呼ばれ、例外がスローされること', () async {
      // Arrange
      when(() => mockTokenStorage.read()).thenAnswer((_) async => 'expired_token');
      when(() => mockTokenStorage.clear()).thenAnswer((_) async => {});

      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'message': 'Unauthorized'}), 401));

      // Act & Assert
      expect(
            () async => await apiClient.get('/test', requiresAuth: true),
        throwsA(anyOf(isA<Exception>(), isA<Error>())),
      );

      // 少し遅延を入れて非同期のクリア処理を待つ、あるいはそのまま検証
      await pumpEventQueue();

      // tokenStorage.clear() が呼ばれたことの検証
      verify(() => mockTokenStorage.clear()).called(1);
    });

    test('POST リクエスト時に正しい Body が jsonEncode されて送信されること', () async {
      // Arrange
      when(() => mockTokenStorage.read()).thenAnswer((_) async => 'dummy_token');

      when(() => mockHttpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: jsonEncode({'name': 'test'}),
      )).thenAnswer((_) async => http.Response(jsonEncode({'id': 1}), 201));

      // Act
      final result = await apiClient.post(
        '/items',
        body: {'name': 'test'},
        requiresAuth: true,
      );

      // Assert
      expect(result, {'id': 1});
      verify(() => mockHttpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: jsonEncode({'name': 'test'}),
      )).called(1);
    });
  });
}