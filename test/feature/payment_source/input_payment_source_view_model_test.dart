import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/providers/global_loading_provider.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/payment_source/domain/cloud_payment_repository.dart';
import 'package:salary/feature/payment_source/input/input_payment_source_view_model.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

import '../../helpers/dummy_data_helper.dart';
import 'list_payment_source_view_model_test.dart';

class MockLocalPaymentSourceRepository extends Mock implements LocalPaymentSourceRepository {}
class MockCloudPaymentSourceRepository extends Mock implements CloudPaymentRepository {}
class MockRef extends Mock implements Ref {}
class MockChartSalaryNotifier extends Mock implements ChartSalaryViewModel {}
class MockListSalaryNotifier extends Mock implements ListSalaryViewModel {}
class MockGlobalLoadingNotifier extends Mock implements GlobalLoadingNotifier {}
class MockGlobalErrorNotifier extends Mock implements GlobalErrorNotifier {}

void main() {
  late MockRef mockRef;
  late MockLocalPaymentSourceRepository mockLocalRepo;
  late MockCloudPaymentSourceRepository mockCloudRepo;
  late InputPaymentSourceViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(fakePaymentSource());
    registerFallbackValue(ThemaColor.blue);
  });

  setUp(() {
    mockRef = MockRef();
    mockLocalRepo = MockLocalPaymentSourceRepository();
    mockCloudRepo = MockCloudPaymentSourceRepository();

  });

  group('InputPaymentSourceViewModel テスト', () {
    test('新規登録モードで初期化時に fetchMainPaymentSource が呼ばれ、状態が更新されること', () {
      final mainDummyData = fakePaymentSource(id: '1', isMain: true);

      when(() => mockLocalRepo.fetchMainPaymentSource()).thenReturn(mainDummyData);

      viewModel = InputPaymentSourceViewModel(
          mockRef,
          mockLocalRepo,
          mockCloudRepo,
          /// null(新規登録モード)
          null
      );

      /// 支払い元未指定なのでデフォルト値のfalse
      expect(viewModel.state.isMain, false);
      /// メインはすでに指定済みなのでdisableにするためのfalse
      expect(viewModel.state.isMainEnabled, false);
      verify(() => mockLocalRepo.fetchMainPaymentSource()).called(1);
    });

    test('更新モードで初期化時に fetchMainPaymentSource が呼ばれ、状態が更新されること', () {
      final updateDummyData = fakePaymentSource(id: '1', isMain: true);
      when(() => mockLocalRepo.fetchMainPaymentSource()).thenReturn(null);

      viewModel = InputPaymentSourceViewModel(
          mockRef,
          mockLocalRepo,
          mockCloudRepo,
          updateDummyData
      );

      /// 支払い元指定でisMainはtrue
      expect(viewModel.state.isMain, true);
      /// メインは未指定なのでenableにするためのtrue
      expect(viewModel.state.isMainEnabled, true);
      verify(() => mockLocalRepo.fetchMainPaymentSource()).called(1);
    });

    test('createOrUpdate: 名前が空の場合、保存処理を行わずにfalseを返すこと', () async {
      viewModel = InputPaymentSourceViewModel(mockRef, mockLocalRepo, mockCloudRepo, null);
      viewModel.updateName('');

      final result = await viewModel.createOrUpdate();

      expect(result, isFalse);
      verifyNever(() => mockLocalRepo.add(any()));
    });

    test('createOrUpdate: 新規登録時、LocalRepoのaddが呼ばれ、他Providerがリフレッシュされること', () async {
      // Arrange
      when(() => mockLocalRepo.fetchMainPaymentSource()).thenReturn(null);
      final mockChart = MockChartSalaryNotifier();
      final mockList = MockListSalaryNotifier();
      final mockLoading = MockGlobalLoadingNotifier();
      final mockError = MockGlobalErrorNotifier();

      when(() => mockRef.read(globalLoadingProvider.notifier)).thenReturn(mockLoading);
      when(() => mockRef.read(globalErrorProvider.notifier)).thenReturn(mockError);
      when(() => mockRef.read(chartSalaryProvider.notifier)).thenReturn(mockChart);
      when(() => mockRef.read(listSalaryProvider.notifier)).thenReturn(mockList);
      when(() => mockChart.refresh()).thenReturn(null);
      when(() => mockList.refresh()).thenReturn(null);

      when(() => mockLocalRepo.add(any())).thenReturn(null);

      viewModel = InputPaymentSourceViewModel(mockRef, mockLocalRepo, mockCloudRepo, null);
      viewModel.updateName('新規支払元');

      // Act
      final result = await viewModel.createOrUpdate();

      // Assert
      expect(result, isTrue);
      verify(() => mockLocalRepo.add(any())).called(1);
      verify(() => mockChart.refresh()).called(1);
      verify(() => mockList.refresh()).called(1);
    });
  });

  test('createOrUpdate: 更新時(isPublic=false)、LocalRepoのみ更新されること', () async {
    // Arrange
    final existing = fakePaymentSource(id: 'old_id', publicUserId: null);

    final mockChart = MockChartSalaryNotifier();
    final mockList = MockListSalaryNotifier();
    final mockLoading = MockGlobalLoadingNotifier();
    final mockError = MockGlobalErrorNotifier();

    when(() => mockRef.read(globalLoadingProvider.notifier)).thenReturn(mockLoading);
    when(() => mockRef.read(globalErrorProvider.notifier)).thenReturn(mockError);
    when(() => mockRef.read(chartSalaryProvider.notifier)).thenReturn(mockChart);
    when(() => mockRef.read(listSalaryProvider.notifier)).thenReturn(mockList);
    when(() => mockChart.refresh()).thenReturn(null);
    when(() => mockList.refresh()).thenReturn(null);
    when(() => mockLocalRepo.fetchMainPaymentSource()).thenReturn(null);

    // Repositoryの更新メソッドのMock
    when(() => mockLocalRepo.updatePaymentSource(
      id: any(named: 'id'),
      name: any(named: 'name'),
      isMain: any(named: 'isMain'),
      themaColorValue: any(named: 'themaColorValue'),
      memo: any(named: 'memo'),
    )).thenReturn(null);

    viewModel = InputPaymentSourceViewModel(mockRef, mockLocalRepo, mockCloudRepo, existing);
    viewModel.updateName('変更後の名前');

    // Act
    final result = await viewModel.createOrUpdate();

    // Assert
    expect(result, isTrue);
    verify(() => mockLocalRepo.updatePaymentSource(
      id: 'old_id',
      name: '変更後の名前',
      isMain: any(named: 'isMain'),
      themaColorValue: any(named: 'themaColorValue'),
      memo: any(named: 'memo'),
    )).called(1);
    // Cloud側が呼ばれていないこと
    verifyNever(() => mockCloudRepo.update(
      id: any(named: 'id'),
      name: any(named: 'name'),
      themeColor: any(named: 'themeColor'),
      memo: any(named: 'memo'),
      isMain: any(named: 'isMain'),
    ));
  });

  group('InputPaymentSourceViewModel - 状態更新メソッドのテスト', () {

    setUp(() {
      // 各テストごとにクリーンな状態でViewModelを作成
      // 初期状態: name='', memo='', selectedColor=ThemaColor.blue, isMain=false
      viewModel = InputPaymentSourceViewModel(
        mockRef,
        mockLocalRepo,
        mockCloudRepo,
        null, // 新規登録モード
      );
    });

    test('updateName: 名前を更新したとき、Stateの名前が変更されること', () {
      // Arrange
      const newName = '株式会社Ame';

      // Act
      viewModel.updateName(newName);

      // Assert
      expect(viewModel.state.name, newName);
    });

    test('updateMemo: メモを更新したとき、Stateのメモが変更されること', () {
      // Arrange
      const newMemo = '生活費決済用のメイン口座です。';

      // Act
      viewModel.updateMemo(newMemo);

      // Assert
      expect(viewModel.state.memo, newMemo);
    });

    test('updateColor: カラーを更新したとき、Stateの選択カラーが変更されること', () {
      // Arrange
      const newColor = ThemaColor.red;

      // Act
      viewModel.updateColor(newColor);

      // Assert
      expect(viewModel.state.selectedColor, newColor);
    });

    test('updateIsMain: メイン設定を更新したとき、StateのisMainが変更されること', () {
      // Arrange
      // 初期値がfalseなのでtrueにするテスト
      const isMain = true;

      // Act
      viewModel.updateIsMain(isMain);

      // Assert
      expect(viewModel.state.isMain, isTrue);
    });

    test('連続した更新: 複数の項目を順番に更新しても、それぞれの値が正しく保持されること', () {
      // Act
      viewModel.updateName('マイ銀行');
      viewModel.updateIsMain(true);
      viewModel.updateMemo('テストメモ');

      // Assert
      expect(viewModel.state.name, 'マイ銀行');
      expect(viewModel.state.isMain, isTrue);
      expect(viewModel.state.memo, 'テストメモ');
    });
  });
}
