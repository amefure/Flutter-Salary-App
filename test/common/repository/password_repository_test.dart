import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/data_source/secure_storage_data_source.dart';
import 'package:salary/core/repository/password_repository.dart';

class MockSecureStorageDataSource extends Mock implements ISecureStorageDataSource {}

void main() {
  late MockSecureStorageDataSource mockDataSource;
  late PasswordRepository repository;

  setUp(() {
    mockDataSource = MockSecureStorageDataSource();
    repository = PasswordRepository(mockDataSource);
  });

  group('PasswordRepository Test', () {
    const testKey = 'app_lock_password';
    test('setPassword: 正しいキーと値で書き込みが行われること', () async {
      when(() => mockDataSource.write(any(), any())).thenAnswer((_) async {});

      await repository.setPassword('secure_pass_123');

      verify(() => mockDataSource.write(testKey, 'secure_pass_123')).called(1);
    });

    group('isLockEnabled', () {
      test('パスワードが保存されている(NotEmpty)なら、trueを返すこと', () async {
        when(() => mockDataSource.read(testKey)).thenAnswer((_) async => 'has_password');

        final result = await repository.isLockEnabled();

        expect(result, isTrue);
      });

      test('パスワードがnullなら、falseを返すこと', () async {
        when(() => mockDataSource.read(testKey)).thenAnswer((_) async => null);

        final result = await repository.isLockEnabled();

        expect(result, isFalse);
      });

      test('パスワードが空文字なら、falseを返すこと', () async {
        when(() => mockDataSource.read(testKey)).thenAnswer((_) async => '');

        final result = await repository.isLockEnabled();

        expect(result, isFalse);
      });
    });

    test('removePassword: 正しいキーで削除が実行されること', () async {
      when(() => mockDataSource.delete(testKey)).thenAnswer((_) async {});

      await repository.removePassword();

      verify(() => mockDataSource.delete(testKey)).called(1);
    });
  });
}