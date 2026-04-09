import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';
import '../../helpers/dummy_data_helper.dart';


class MockLocalSalaryRepository extends Mock implements LocalSalaryRepository {}
class MockUserSettingsRepository extends Mock implements UserSettingsRepository {}

void main() {
  late MockLocalSalaryRepository mockLocalSalaryRepo;
  late MockUserSettingsRepository mockUserSettingsRepo;
  late ProviderContainer container;

  setUpAll(() {
    mockLocalSalaryRepo = MockLocalSalaryRepository();
    mockUserSettingsRepo = MockUserSettingsRepository();
  });

  setUp(() {

    when(() => mockLocalSalaryRepo.fetchAll()).thenReturn(dummySalaries);
    when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn(dummySalaries);
    when(() => mockUserSettingsRepo.fetchSortOrder()).thenReturn(SalarySortOrder.amountAsc);

    container = ProviderContainer(
      overrides: [
        localSalaryRepositoryProvider.overrideWithValue(mockLocalSalaryRepo),
        userSettingsProvider.overrideWithValue(mockUserSettingsRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ListSalaryViewModel テスト', () {
    test('初期化時に各ロード処理が呼ばれ、状態が更新されること', () {
      /// ① Arrange (準備)
      /// なし

      /// ② Act (実行)
      final _ = container.read(listSalaryProvider.notifier);
      final state = container.read(listSalaryProvider);

      /// ③ Assert (検証)
      verify(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).called(1);
      verify(() => mockUserSettingsRepo.fetchSortOrder()).called(1);

      expect(state.sortOrder, SalarySortOrder.amountAsc);
      expect(state.salaries.length, 3);
      // Salaryに紐づくもの1つとAll 1つの2個
      expect(state.sourceList.length, 2);
    });


    test('updateSortOrder: 金額の昇順(amountAsc)を選択したとき、正しく並び替えられること', () {
      /// ① Arrange: バラバラの順序でデータを準備
      final s1 = fakeSalary(id: 'low', paymentAmount: 100000);
      final s2 = fakeSalary(id: 'high', paymentAmount: 300000);
      final s3 = fakeSalary(id: 'mid', paymentAmount: 200000);

      // Repositoryはバラバラの順序で返す
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn([s1, s2, s3]);
      when(() => mockUserSettingsRepo.saveSortOrder(SalarySortOrder.amountAsc)).thenAnswer((_) async => {});

      final viewModel = container.read(listSalaryProvider.notifier);

      /// ② Act: 金額昇順に更新
      viewModel.updateSortOrder(SalarySortOrder.amountAsc);
      final state = container.read(listSalaryProvider);

      /// ③ Assert
      // IDの並びが 10万(low) -> 20万(mid) -> 30万(high) であることを検証
      final ids = state.salaries.map((s) => s.id).toList();
      expect(ids, ['low', 'mid', 'high']);
      expect(state.sortOrder, SalarySortOrder.amountAsc);
    });

    test('updateSortOrder: 金額の降順(amountDesc)を選択したとき、正しく並び替えられること', () {
      /// ① Arrange: バラバラの順序でデータを準備
      final s1 = fakeSalary(id: 'low', paymentAmount: 100000);
      final s2 = fakeSalary(id: 'high', paymentAmount: 300000);
      final s3 = fakeSalary(id: 'mid', paymentAmount: 200000);

      // Repositoryはバラバラの順序で返す
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn([s1, s2, s3]);
      when(() => mockUserSettingsRepo.saveSortOrder(SalarySortOrder.amountDesc)).thenAnswer((_) async => {});

      final viewModel = container.read(listSalaryProvider.notifier);

      /// ② Act: 金額降順に更新
      viewModel.updateSortOrder(SalarySortOrder.amountDesc);
      final state = container.read(listSalaryProvider);

      /// ③ Assert
      // IDの並びが 30万(high) -> 20万(mid) -> 10万(low) であることを検証
      final ids = state.salaries.map((s) => s.id).toList();
      expect(ids, ['high', 'mid', 'low']);
      expect(state.sortOrder, SalarySortOrder.amountDesc);
    });

    test('updateSortOrder: 日付の降順(dateDesc)を選択したとき、新しい順に並び替えられること', () {
      /// ① Arrange
      final oldDate = fakeSalary(id: 'old', date: DateTime(2026, 1, 1));
      final newDate = fakeSalary(id: 'new', date: DateTime(2026, 3, 1));
      final midDate = fakeSalary(id: 'mid', date: DateTime(2026, 2, 1));

      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn([oldDate, newDate, midDate]);
      when(() => mockUserSettingsRepo.saveSortOrder(SalarySortOrder.dateDesc)).thenAnswer((_) async => {});

      final viewModel = container.read(listSalaryProvider.notifier);

      /// ② Act: 日付降順に更新
      viewModel.updateSortOrder(SalarySortOrder.dateDesc);
      final state = container.read(listSalaryProvider);

      /// ③ Assert
      // IDの並びが 3月(new) -> 2月(mid) -> 1月(old) であることを検証
      final ids = state.salaries.map((s) => s.id).toList();
      expect(ids, ['new', 'mid', 'old']);
      expect(state.sortOrder, SalarySortOrder.dateDesc);
    });

    test('updateSortOrder: 日付の降順(dateDesc)を選択したとき、新しい順に並び替えられること', () {
      /// ① Arrange
      final oldDate = fakeSalary(id: 'old', date: DateTime(2026, 1, 1));
      final newDate = fakeSalary(id: 'new', date: DateTime(2026, 3, 1));
      final midDate = fakeSalary(id: 'mid', date: DateTime(2026, 2, 1));

      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn([oldDate, newDate, midDate]);
      when(() => mockUserSettingsRepo.saveSortOrder(SalarySortOrder.dateAsc)).thenAnswer((_) async => {});

      final viewModel = container.read(listSalaryProvider.notifier);

      /// ② Act: 日付降順に更新
      viewModel.updateSortOrder(SalarySortOrder.dateAsc);
      final state = container.read(listSalaryProvider);

      /// ③ Assert
      // IDの並びが 1月(old) -> 2月(mid) -> 3月(new) であることを検証
      final ids = state.salaries.map((s) => s.id).toList();
      expect(ids, ['old', 'mid', 'new']);
      expect(state.sortOrder, SalarySortOrder.dateAsc);
    });

    test('refreshを実行したとき、各リポジトリから最新データを取得し、現在のフィルタを維持して状態を更新すること', () async {
      /// ① Arrange (準備)
      final sourceA = fakePaymentSource(id: 'A', name: '株式会社Ame');
      final sourceB = fakePaymentSource(id: 'B', name: '株式会社Kasa');

      // 初期状態用のデータ
      final initialSalaries = [
        fakeSalary(id: '1', paymentAmount: 1000, source: sourceA),
      ];

      // リフレッシュ後に取得される「最新データ」
      final updatedSalaries = [
        fakeSalary(id: '1', paymentAmount: 1000, source: sourceA),
        fakeSalary(id: '2', paymentAmount: 5000, source: sourceA), // 増えたデータ
        fakeSalary(id: '3', paymentAmount: 2000, source: sourceB), // 別ソースのデータ
      ];

      // スタブの設定
      when(() => mockUserSettingsRepo.fetchSortOrder()).thenReturn(SalarySortOrder.amountAsc);
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn(initialSalaries);
      when(() => mockLocalSalaryRepo.fetchAll()).thenReturn(initialSalaries);

      final viewModel = container.read(listSalaryProvider.notifier);

      // 先に「株式会社Ame」でフィルタリングしておく
      viewModel.filterPaymentSource(sourceA);

      // リフレッシュで返されるデータを「最新版」に差し替え
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn(updatedSalaries);
      when(() => mockLocalSalaryRepo.fetchAll()).thenReturn(updatedSalaries);
      when(() => mockUserSettingsRepo.saveSortOrder(SalarySortOrder.amountAsc)).thenAnswer((_) async => {});

      /// ② Act (実行)
      viewModel.refresh();

      /// ③ Assert (検証)

      // 1. 各ロード処理が呼ばれたことを確認
      verify(() => mockUserSettingsRepo.fetchSortOrder()).called(greaterThan(0));
      verify(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).called(greaterThan(0));

      final state = container.read(listSalaryProvider);

      // 2. フィルタ（株式会社Ame）が維持された状態で、データが更新されているか
      // updatedSalaries のうち、sourceA のものは 2件
      expect(state.salaries.length, 2);
      expect(state.salaries.every((s) => s.source?.id == 'A'), isTrue);

      // 3. sourceList（選択肢）も最新データに基づいて更新されているか
      // ALL + 株式会社Ame + 株式会社Kasa = 3件
      expect(state.sourceList.length, 3);

      // 4. 選択中のソースが維持されているか
      expect(state.selectedSource.id, 'A');
    });
  });

  group('filterPaymentSource テスト', () {

    test('ALL（すべて）を選択したとき、全件が表示され、selectedSourceが更新されること', () {
      /// 1. Arrange: 複数の支払い元データを準備
      final sourceA = fakePaymentSource(id: 'A');
      final salaries = [
        fakeSalary(id: '1', paymentAmount: 1000, source: sourceA),
        fakeSalary(id: '2', paymentAmount: 2000, source: null), // 未選択用
      ];
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn(salaries);

      final viewModel = container.read(listSalaryProvider.notifier);

      /// 2. Act: ALLを選択
      viewModel.filterPaymentSource(DummySource.allDummySource);

      /// 3. Assert
      final state = container.read(listSalaryProvider);
      expect(state.salaries.length, 2); // 全件
      expect(state.selectedSource.id, DummySource.allDummySource.id);
    });

    test('未選択を選択したとき、sourceがnullのデータのみが抽出されること', () {
      /// 1. Arrange
      final sourceA = fakePaymentSource(id: 'A');
      final salaries = [
        fakeSalary(id: '1', paymentAmount: 1000, source: sourceA),
        fakeSalary(id: '2', paymentAmount: 2000, source: null), // これが残るべき
      ];
      // 初期状態として全件ロードさせておく
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn(salaries);

      final viewModel = container.read(listSalaryProvider.notifier);

      /// 2. Act
      viewModel.filterPaymentSource(DummySource.unSetDummySource);

      /// 3. Assert
      final state = container.read(listSalaryProvider);
      expect(state.salaries.length, 1);
      expect(state.salaries.first.source, isNull);
      expect(state.selectedSource.id, DummySource.unSetDummySource.id);
    });

    test('特定の支払い元を選択したとき、そのIDに紐づくデータのみが抽出されること', () {
      /// 1. Arrange
      final sourceA = fakePaymentSource(id: 'A', name: '株式会社Ame');
      final sourceB = fakePaymentSource(id: 'B', name: '株式会社Kasa');
      final salaries = [
        fakeSalary(id: '1', paymentAmount: 1000, source: sourceA), // Hit
        fakeSalary(id: '2', paymentAmount: 2000, source: sourceB), // No hit
        fakeSalary(id: '3', paymentAmount: 3000, source: sourceA), // Hit
      ];
      when(() => mockLocalSalaryRepo.fetchAllSortCreatedAt()).thenReturn(salaries);

      final viewModel = container.read(listSalaryProvider.notifier);

      /// 2. Act: 株式会社Ameを選択
      // 注意: fakeで作った別インスタンスでもIDが同じならフィルタされるか検証
      final selectedSource = fakePaymentSource(id: 'A');
      viewModel.filterPaymentSource(selectedSource);

      /// 3. Assert
      final state = container.read(listSalaryProvider);
      expect(state.salaries.length, 2);
      expect(state.salaries.every((s) => s.source?.id == 'A'), isTrue);
      expect(state.selectedSource.id, 'A');
    });
  });

}