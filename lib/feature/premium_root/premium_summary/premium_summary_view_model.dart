import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/mock/summary_mock_factory.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/premium_root/data/summary_repository_impl.dart';
import 'package:salary/feature/premium_root/domain/summary_repository.dart';
import 'package:salary/feature/premium_root/premium_summary/premium_summary_state.dart';

final premiumSummaryProvider = StateNotifierProvider.autoDispose<PremiumSummaryViewModel, PremiumSummaryState>((ref) {
  final publicSalaryRepository = ref.read(summaryRepositoryImplProvider);
  final vm = PremiumSummaryViewModel(ref, publicSalaryRepository);
  /// build完了後に実行
  Future.microtask(() => vm.fetchAllSalaries());
  return vm;
});

class PremiumSummaryViewModel extends StateNotifier<PremiumSummaryState> {

  final Ref _ref;
  final SummaryRepository _summaryRepository;

  PremiumSummaryViewModel(
      this._ref,
      this._summaryRepository
      ): super(PremiumSummaryState.initial());

  // 下限の年を設定
  static const int _startYear = 2010;

  // 現在の年から下限までを格納したリスト
  // static final にすることで、アプリ起動時に動的に生成されます
  static final List<int> years = List.generate(
    DateTime.now().year - _startYear + 1,
        (index) => DateTime.now().year - index,
  );

  static const ages = ['指定なし', '20代', '30代', '40代', '50代', '60代'];

  Future<void> fetchAllSalaries() async {
    // フィルタ文字列をAPI用のパラメータに変換
    final Map<String, dynamic> queries = {
      'year': state.selectedYear,
    };

    if (state.selectedRegion != null) {
      queries['region'] = state.selectedRegion;
    }

    // 年代のパース (例: "30代" -> age_from: 30, age_to: 39)
    if (state.selectedAgeRange != null) {
      final age = int.tryParse(state.selectedAgeRange!.replaceAll('代', ''));
      if (age != null) {
        queries['age_from'] = age;
        queries['age_to'] = age + 9;
      }
    }
    await _ref.runWithGlobalHandling(() async {
      //final summaryDto = await _summaryRepository.dashboard(queries: queries);
      final summaryDto2 = SummaryMockFactory.create();
      state = state.copyWith(summaryDto: summaryDto2);
    });
  }

  /// フィルタを更新して再取得
  void updateFilter({int? year, String? region, String? ageRange}) {
    state = state.copyWith(
      selectedYear: year,
      // '指定なし' が選ばれたら null をセットする
      selectedRegion: region == null ? null : () => (region == '指定なし' ? null : region),
      selectedAgeRange: ageRange == null ? null : () => (ageRange == '指定なし' ? null : ageRange),
    );

    // API叩き直し
    fetchAllSalaries();
  }
}
