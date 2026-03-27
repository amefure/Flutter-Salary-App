import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/mock/summary_mock_factory.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/age_parser_utils.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/premium/data/summary_repository_impl.dart';
import 'package:salary/feature/premium/domain/summary_repository.dart';
import 'package:salary/feature/premium/premium_root/premium_root_view_model.dart';
import 'package:salary/feature/premium/premium_summary/premium_summary_state.dart';
import 'package:salary/core/config/json_keys.dart';

final premiumSummaryProvider = StateNotifierProvider.autoDispose<PremiumSummaryViewModel, PremiumSummaryState>((ref) {
  final publicSalaryRepository = ref.read(summaryRepositoryImplProvider);
  final vm = PremiumSummaryViewModel(ref, publicSalaryRepository);
  /// build完了後に実行
  Future.microtask(() => vm.fetchDashboard());
  return vm;
});

class PremiumSummaryViewModel extends StateNotifier<PremiumSummaryState> {

  final Ref _ref;
  final SummaryRepository _summaryRepository;

  PremiumSummaryViewModel(
      this._ref,
      this._summaryRepository
      ): super(PremiumSummaryState.initial()) {
    _ref.listen<bool>(
      premiumRootProvider.select((s) => s.isRefresh),
          (previous, next) {
        logger(next);
        logger(previous);
        if (next == true && previous != true) {
          refresh();
          _ref.read(premiumRootProvider.notifier).clearIsRefresh();
        }
      },
    );
  }

  /// 下限の年を設定
  static const int _startYear = 2010;

  // 現在の年から下限までを格納したリスト
  static final List<int> years = List.generate(
    DateTime.now().year - _startYear + 1,
        (index) => DateTime.now().year - index,
  );

  Future<void> fetchDashboard() async {
    final queries = _createQueries();
    await _ref.runWithGlobalHandling(() async {
      final summaryDto = await _summaryRepository.dashboard(queries: queries);
      // final summaryDto = SummaryMockFactory.create();
      state = state.copyWith(summaryDto: summaryDto);
    });
  }

  Map<String, dynamic> _createQueries() {
    /// 年
    final Map<String, dynamic> queries = {
      PremiumQueryKeys.year: state.selectedYear,
    };

    /// 職種
    if (state.selectedJob != ProfileConfig.undefinedJob) {
      queries[PremiumQueryKeys.job] = state.selectedJob.name;
    }

    /// 地域
    if (state.selectedRegion != null) {
      queries[PremiumQueryKeys.region] = state.selectedRegion;
    }
    /// 年代
    final ageParams = AgeParserUtils.parse(state.selectedAgeRange);
    if (ageParams.isNotEmpty) {
      queries.addAll(ageParams);
    }
    return queries;
  }

  /// フィルタを更新して再取得
  void updateFilter({
    int? year,
    Job? job,
    String? region,
    String? ageRange
  }) async {
    state = state.copyWith(
      selectedYear: year,
      selectedJob: job,
      selectedRegion: region == null ? null : () => (region == ProfileConfig.selectNone ? null : region),
      selectedAgeRange: ageRange == null ? null : () => (ageRange == ProfileConfig.selectNone ? null : ageRange),
    );

    await fetchDashboard();
  }


  /// リフレッシュ処理
  Future<void> refresh() async {
    await fetchDashboard();
  }
}
