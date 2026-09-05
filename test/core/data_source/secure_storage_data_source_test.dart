import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/data_source/secure_storage_data_source.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageDataSource dataSource;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    dataSource = SecureStorageDataSource(mockStorage);
  });

  group('SecureStorageDataSource', () {
    test('write delegates the key and value to secure storage', () async {
      // Arrange
      when(
        () => mockStorage.write(key: 'token', value: 'secret'),
      ).thenAnswer((_) async {});

      // Act
      await dataSource.write('token', 'secret');

      // Assert
      verify(() => mockStorage.write(key: 'token', value: 'secret')).called(1);
    });

    test('read delegates the key and returns the stored value', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => 'secret');

      // Act
      final value = await dataSource.read('token');

      // Assert
      expect(value, 'secret');
      verify(() => mockStorage.read(key: 'token')).called(1);
    });

    test('read returns null when the key is not stored', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'missing'),
      ).thenAnswer((_) async => null);

      // Act
      final value = await dataSource.read('missing');

      // Assert
      expect(value, isNull);
      verify(() => mockStorage.read(key: 'missing')).called(1);
    });

    test('delete delegates the key to secure storage', () async {
      // Arrange
      when(() => mockStorage.delete(key: 'token')).thenAnswer((_) async {});

      // Act
      await dataSource.delete('token');

      // Assert
      verify(() => mockStorage.delete(key: 'token')).called(1);
    });
  });
}
