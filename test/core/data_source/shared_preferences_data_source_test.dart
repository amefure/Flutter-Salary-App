import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/data_source/shared_preferences_data_source.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(preferences);
  });

  group('SharedPreferencesDataSource', () {
    test('saves and gets string and int values', () async {
      // Arrange
      const stringKey = SharedPreferencesKeys.authUser;
      const intKey = SharedPreferencesKeys.reminderDay;

      // Act
      await dataSource.saveString(stringKey, 'user-token');
      await dataSource.saveInt(intKey, 25);

      // Assert
      expect(dataSource.getString(stringKey), 'user-token');
      expect(dataSource.getInt(intKey), 25);
    });

    test(
      'saves bool values and returns nullable and default bool values',
      () async {
        // Arrange
        const key = SharedPreferencesKeys.removeAds;

        // Act
        final missingValue = dataSource.getBoolNullable(key);
        final missingDefault = dataSource.getBool(key);
        await dataSource.saveBool(key, true);
        final savedValue = dataSource.getBoolNullable(key);

        // Assert
        expect(missingValue, isNull);
        expect(missingDefault, isFalse);
        expect(savedValue, isTrue);
      },
    );

    test(
      'remove deletes a saved value and missing values return null',
      () async {
        // Arrange
        const key = SharedPreferencesKeys.authUser;
        await dataSource.saveString(key, 'user-token');

        // Act
        await dataSource.remove(key);

        // Assert
        expect(dataSource.getString(key), isNull);
        expect(dataSource.getInt(SharedPreferencesKeys.reminderDay), isNull);
      },
    );

    test('clearData removes all saved values', () async {
      // Arrange
      await dataSource.saveString(SharedPreferencesKeys.authUser, 'user-token');
      await dataSource.saveInt(SharedPreferencesKeys.reminderDay, 25);
      await dataSource.saveBool(SharedPreferencesKeys.removeAds, true);

      // Act
      await dataSource.clearData();

      // Assert
      expect(dataSource.getString(SharedPreferencesKeys.authUser), isNull);
      expect(dataSource.getInt(SharedPreferencesKeys.reminderDay), isNull);
      expect(
        dataSource.getBoolNullable(SharedPreferencesKeys.removeAds),
        isNull,
      );
    });
  });
}
