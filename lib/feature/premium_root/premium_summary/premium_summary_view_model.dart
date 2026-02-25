
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/premium_root/data/summary_repository_impl.dart';
import 'package:salary/feature/premium_root/domain/summary_repository.dart';
import 'package:salary/feature/premium_root/premium_summary/premium_summary_state.dart';

final premiumSummaryProvider =
StateNotifierProvider.autoDispose<PremiumSummaryViewModel, PremiumSummaryState>((ref) {
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

  Future<void> fetchAllSalaries() async {
    await _ref.runWithGlobalHandling(() async {
      final summaryDto = await _summaryRepository.dashboard();
      state = state.copyWith(
        summaryDto: summaryDto
      );
    });
  }
}
