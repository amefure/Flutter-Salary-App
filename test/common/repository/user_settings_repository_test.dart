import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/data_source/shared_preferences_data_source.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

class MockSharedPreferencesDataSource extends Mock implements ISharedPreferencesDataSource {}

void main() {
  late MockSharedPreferencesDataSource mockDataSource;
  late UserSettingsRepository repository;

  setUpAll(() {
    // SharedPreferencesKeys の適当な値を fallback として登録する
    registerFallbackValue(SharedPreferencesKeys.authUser);
  });

  setUp(() {
    mockDataSource = MockSharedPreferencesDataSource();
    repository = UserSettingsRepository(mockDataSource);
  });

  group('UserSettingsRepository Test', () {
    // --------------------------------------------------
    // 認証・ユーザー関連
    // --------------------------------------------------
    group('認証・ユーザー関連', () {
      test('saveAuthUser: 指定した文字列が正しいキーで保存されること', () async {
        when(() => mockDataSource.saveString(any(), any()))
            .thenAnswer((_) async {});

        await repository.saveAuthUser('test_token');

        verify(() => mockDataSource.saveString(
          SharedPreferencesKeys.authUser,
          'test_token',
        )).called(1);
      });

      test('clearAuthUser: removeが正しいキーで呼ばれること', () async {
        when(() => mockDataSource.remove(any())).thenAnswer((_) async {});

        await repository.clearAuthUser();

        verify(() => mockDataSource.remove(SharedPreferencesKeys.authUser))
            .called(1);
      });

      test('fetchAuthUser: 保存されている文字列をそのまま返すこと', () {
        when(() => mockDataSource.getString(SharedPreferencesKeys.authUser))
            .thenReturn('saved_token');

        expect(repository.fetchAuthUser(), 'saved_token');
      });
    });

    // --------------------------------------------------
    // 広告・プレミアム機能関連
    // --------------------------------------------------
    group('広告・プレミアム機能関連', () {
      test('広告・プレミアム系の真偽値が正しく保存・取得できること', () async {
        // save系のStub
        when(() => mockDataSource.saveBool(any(), any()))
            .thenAnswer((_) async {});
        // fetch系のStub
        when(() => mockDataSource.getBool(SharedPreferencesKeys.removeAds))
            .thenReturn(true);

        await repository.saveRemoveAds(true);
        final result = repository.fetchRemoveAds();

        verify(() => mockDataSource.saveBool(SharedPreferencesKeys.removeAds, true))
            .called(1);
        expect(result, isTrue);
      });

      test('PremiumFullUnlocked の状態を正しく扱えること', () async {
        when(() => mockDataSource.saveBool(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDataSource.getBool(SharedPreferencesKeys.premiumFullUnlocked))
            .thenReturn(false);

        await repository.savePremiumFullUnlocked(false);
        expect(repository.fetchPremiumFullUnlocked(), isFalse);
      });
    });

    // --------------------------------------------------
    // アプリ設定（テーマ・表示）関連
    // --------------------------------------------------
    group('アプリ設定（テーマ・表示）関連', () {
      test('fetchThemeModeNullable: 設定がない場合にnullを返すこと', () {
        when(() => mockDataSource.getBoolNullable(SharedPreferencesKeys.themeMode))
            .thenReturn(null);

        expect(repository.fetchThemeModeNullable(), isNull);
      });

      test('saveSortOrder: Enumのlabelが文字列として保存されること', () async {
        when(() => mockDataSource.saveString(any(), any()))
            .thenAnswer((_) async {});

        const order = SalarySortOrder.amountDesc;
        await repository.saveSortOrder(order);

        verify(() => mockDataSource.saveString(
          SharedPreferencesKeys.sortOrder,
          order.label,
        )).called(1);
      });

      test('fetchSortOrder: 保存された文字列からEnumへ変換、未設定ならデフォルトを返すこと', () {
        // 保存ありの場合
        when(() => mockDataSource.getString(SharedPreferencesKeys.sortOrder))
            .thenReturn(SalarySortOrder.amountAsc.label);
        expect(repository.fetchSortOrder(), SalarySortOrder.amountAsc);

        // 保存なしの場合
        when(() => mockDataSource.getString(SharedPreferencesKeys.sortOrder))
            .thenReturn(null);
        expect(repository.fetchSortOrder(), SalarySortOrder.dateDesc);
      });
    });

    // --------------------------------------------------
    // オンボーディング・ガイド表示関連
    // --------------------------------------------------
    group('オンボーディング・ガイド表示関連', () {
      test('オンボーディング系フラグが正しく保存・取得されること', () async {
        when(() => mockDataSource.saveBool(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDataSource.getBool(SharedPreferencesKeys.hasShownPremiumIntro))
            .thenReturn(true);

        await repository.saveHasShownPremiumIntro(true);
        expect(repository.fetchHasShownPremiumIntro(), isTrue);

        verify(() => mockDataSource.saveBool(
          SharedPreferencesKeys.hasShownPremiumIntro,
          true,
        )).called(1);
      });
    });
  });
}