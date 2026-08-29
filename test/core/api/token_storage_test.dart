import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/api/token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(mockSecureStorage);
  });

  group('TokenStorage テスト', () {
    test('save: 正しいキーと値でストレージに書き込まれること', () async {
      // Arrange
      when(() => mockSecureStorage.write(key: 'auth_token', value: 'dummy_token_123'))
          .thenAnswer((_) async {});

      // Act
      await tokenStorage.save('dummy_token_123');

      // Assert
      verify(() => mockSecureStorage.write(key: 'auth_token', value: 'dummy_token_123'))
          .called(1);
    });

    test('read: ストレージからトークンが正しく読み込まれること', () async {
      // Arrange
      when(() => mockSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'saved_token_xyz');

      // Act
      final token = await tokenStorage.read();

      // Assert
      expect(token, 'saved_token_xyz');
      verify(() => mockSecureStorage.read(key: 'auth_token')).called(1);
    });

    test('read: トークンが存在しない場合は null が返ること', () async {
      // Arrange
      when(() => mockSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => null);

      // Act
      final token = await tokenStorage.read();

      // Assert
      expect(token, isNull);
    });

    test('clear: 指定したキーのデータが削除されること', () async {
      // Arrange
      when(() => mockSecureStorage.delete(key: 'auth_token'))
          .thenAnswer((_) async {});

      // Act
      await tokenStorage.clear();

      // Assert
      verify(() => mockSecureStorage.delete(key: 'auth_token')).called(1);
    });
  });
}