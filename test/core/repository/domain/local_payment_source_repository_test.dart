import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import '../../../helpers/dummy_data_helper.dart';

class MockRealmDataSource extends Mock implements IRealmDataSource {}

void main() {
  late MockRealmDataSource mockDataSource;
  late LocalPaymentSourceRepository repository;

  setUp(() {
    mockDataSource = MockRealmDataSource();
    repository = LocalPaymentSourceRepository(mockDataSource);
  });

  group('LocalPaymentSourceRepository', () {
    test('fetchSortedAllPaymentSources puts main sources first', () {
      // Arrange
      final regularSource = fakePaymentSource(id: 'regular');
      final mainSource = fakePaymentSource(id: 'main', isMain: true);
      when(
        () => mockDataSource.fetchAll<PaymentSource>(),
      ).thenReturn([regularSource, mainSource]);

      // Act
      final result = repository.fetchSortedAllPaymentSources();

      // Assert
      expect(result.map((source) => source.id), ['main', 'regular']);
      verify(() => mockDataSource.fetchAll<PaymentSource>()).called(1);
    });

    test('fetchMainPaymentSource delegates the main-source query', () {
      // Arrange
      final mainSource = fakePaymentSource(id: 'main', isMain: true);
      when(
        () => mockDataSource.findFirst<PaymentSource>('isMain == \$0', [true]),
      ).thenReturn(mainSource);

      // Act
      final result = repository.fetchMainPaymentSource();

      // Assert
      expect(result, same(mainSource));
      verify(
        () => mockDataSource.findFirst<PaymentSource>('isMain == \$0', [true]),
      ).called(1);
    });

    test('fetchMainPaymentSource returns null when no main source exists', () {
      // Arrange
      when(
        () => mockDataSource.findFirst<PaymentSource>('isMain == \$0', [true]),
      ).thenReturn(null);

      // Act
      final result = repository.fetchMainPaymentSource();

      // Assert
      expect(result, isNull);
    });

    test('add delegates the payment source', () {
      // Arrange
      final source = fakePaymentSource(id: 'new');
      when(() => mockDataSource.add<PaymentSource>(source)).thenAnswer((_) {});

      // Act
      repository.add(source);

      // Assert
      verify(() => mockDataSource.add<PaymentSource>(source)).called(1);
    });

    test('updatePaymentSource delegates and applies all changed fields', () {
      // Arrange
      final source = fakePaymentSource(id: 'source');
      when(
        () => mockDataSource.updateById<PaymentSource>('source', any()),
      ).thenAnswer((invocation) {
        final callback =
            invocation.positionalArguments[1] as void Function(PaymentSource);
        callback(source);
      });

      // Act
      repository.updatePaymentSource(
        id: 'source',
        name: '更新後の会社',
        isMain: true,
        themaColorValue: 0xff123456,
        memo: '更新メモ',
      );

      // Assert
      expect(source.name, '更新後の会社');
      expect(source.isMain, isTrue);
      expect(source.themaColor, 0xff123456);
      expect(source.memo, '更新メモ');
      verify(
        () => mockDataSource.updateById<PaymentSource>('source', any()),
      ).called(1);
    });

    test('updatePublicUserId delegates and updates the public user id', () {
      // Arrange
      final source = fakePaymentSource(id: 'source');
      when(
        () => mockDataSource.updateById<PaymentSource>('source', any()),
      ).thenAnswer((invocation) {
        final callback =
            invocation.positionalArguments[1] as void Function(PaymentSource);
        callback(source);
      });

      // Act
      repository.updatePublicUserId(id: 'source', publicUserId: 42);

      // Assert
      expect(source.publicUserId, 42);
      verify(
        () => mockDataSource.updateById<PaymentSource>('source', any()),
      ).called(1);
    });

    test('deleteById delegates the payment source id', () {
      // Arrange
      when(
        () => mockDataSource.deleteById<PaymentSource>('source'),
      ).thenAnswer((_) {});

      // Act
      repository.deleteById('source');

      // Assert
      verify(
        () => mockDataSource.deleteById<PaymentSource>('source'),
      ).called(1);
    });
  });
}
