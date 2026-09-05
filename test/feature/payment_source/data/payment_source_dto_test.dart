import 'package:flutter_test/flutter_test.dart';
import 'package:salary/feature/payment_source/data/payment_source_dto.dart';

void main() {
  group('PaymentSourceDto', () {
    test('fromJson and toDomain map required and optional fields', () {
      // Arrange
      final json = {
        'id': 'source-1',
        'name': '株式会社Ame',
        'theme_color': 0xffabcdef,
        'memo': '本業',
        'is_main': true,
        'user_id': 7,
        'is_public_name': true,
      };

      // Act
      final dto = PaymentSourceDto.fromJson(json);
      final source = dto.toDomain();

      // Assert
      expect(dto.id, 'source-1');
      expect(dto.name, '株式会社Ame');
      expect(dto.themeColor, 0xffabcdef);
      expect(dto.memo, '本業');
      expect(dto.isMain, isTrue);
      expect(dto.publicUserId, 7);
      expect(dto.isPublicName, isTrue);
      expect(source.id, 'source-1');
      expect(source.name, '株式会社Ame');
      expect(source.themaColor, 0xffabcdef);
      expect(source.memo, '本業');
      expect(source.isMain, isTrue);
      expect(source.publicUserId, 7);
      expect(source.isPublicName, isTrue);
    });

    test('fromJson preserves nullable memo and public user id', () {
      // Arrange
      final json = {
        'id': 'source-2',
        'name': '副業',
        'theme_color': 0xff000000,
        'memo': null,
        'is_main': false,
        'user_id': null,
        'is_public_name': false,
      };

      // Act
      final dto = PaymentSourceDto.fromJson(json);
      final source = dto.toDomain();

      // Assert
      expect(dto.memo, isNull);
      expect(dto.publicUserId, isNull);
      expect(source.memo, isNull);
      expect(source.publicUserId, isNull);
    });
  });
}
