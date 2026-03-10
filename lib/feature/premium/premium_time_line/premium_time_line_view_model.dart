import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/premium/data/dto/public_salary_page_dto.dart';
import 'package:salary/feature/premium/data/public_salary_repository_impl.dart';
import 'package:salary/feature/premium/domain/public_salary_repository.dart';
import 'package:salary/feature/premium/premium_root/premium_root_view_model.dart';
import 'package:salary/feature/premium/premium_time_line/premium_time_line_state.dart';
import 'package:salary/core/config/json_keys.dart';

final premiumTimeLineProvider =
StateNotifierProvider.autoDispose<PremiumTimeLineViewModel, PremiumTimeLineState>((ref) {
  final publicSalaryRepository = ref.read(publicSalaryRepositoryProvider);
  final vm = PremiumTimeLineViewModel(ref, publicSalaryRepository);
  /// build完了後に実行
  Future.microtask(() => vm.fetchAllSalaries());
  return vm;
});

class PremiumTimeLineViewModel extends StateNotifier<PremiumTimeLineState> {

  final Ref _ref;
  final PublicSalaryRepository _publicSalaryRepository;

  PremiumTimeLineViewModel(
      this._ref,
      this._publicSalaryRepository
      ): super(PremiumTimeLineState.initial()) {
    _ref.listen<bool>(
      premiumRootProvider.select((s) => s.isRefresh),
          (previous, next) {
        if (next == true && previous != true) {
          refresh();
          _ref.read(premiumRootProvider.notifier).clearIsRefresh();
        }
      },
    );
  }

  Future<void> fetchAllSalaries() async {
    await _ref.runWithGlobalHandling(() async {
      final queries = _createQueries();
      final page = await _publicSalaryRepository.fetchAllList(queries: queries);
      state = state.copyWith(
        salaries: page.toDomain(),
        currentPage: page.currentPage,
        lastPage: page.lastPage,
      );
    });
  }

  Map<String, dynamic>? _createQueries() {
    if (state.selectedJob == ProfileConfig.undefinedJob) {
      return null;
    } else {
      return {
        PremiumQueryKeys.job: state.selectedJob.name
      };
    }
  }

  /// ページング読み込み
  Future<void> loadNextPage() async {
    if (state.currentPage >= state.lastPage) { return; }

    if (state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;

    final queries = _createQueries();
    final page = await _publicSalaryRepository.fetchAllList(page: nextPage, queries: queries);

    state = state.copyWith(
      salaries: [
        ...state.salaries,
        ...page.toDomain(),
      ],
      currentPage: page.currentPage,
      lastPage: page.lastPage,
      isLoadingMore: false,
    );
  }

  /// フィルタを更新して再取得
  void updateFilter({Job? job}) async {
    state = state.copyWith(
      selectedJob: job
    );
    await fetchAllSalaries();
  }

  /// リフレッシュ処理
  Future<void> refresh() async {
    state = state.copyWith(
      salaries: [],
      currentPage: 1,
      lastPage: null,
      selectedJob: ProfileConfig.undefinedJob
    );
    await fetchAllSalaries();
  }

}
