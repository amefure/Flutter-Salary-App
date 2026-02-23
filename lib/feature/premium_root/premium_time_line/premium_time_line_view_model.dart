import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/payment_source/data/payment_repository_impl.dart';
import 'package:salary/feature/payment_source/domain/payment_repository.dart';
import 'package:salary/feature/premium_root/data/public_salary_repository_impl.dart';
import 'package:salary/feature/premium_root/domain/public_salary_repository.dart';
import 'package:salary/feature/premium_root/premium_time_line/premium_time_line_state.dart';
import 'package:salary/feature/salary/data/salary_repository_impl.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';

final premiumTimeLineProvider =
StateNotifierProvider.autoDispose<PremiumTimeLineViewModel, PremiumTimeLineState>((ref) {
  final paymentRepository = ref.read(paymentRepositoryProvider);
  final salaryRepository = ref.read(salaryRepositoryProvider);
  final publicSalaryRepository = ref.read(publicSalaryRepositoryProvider);
  final vm = PremiumTimeLineViewModel(ref, paymentRepository, salaryRepository, publicSalaryRepository);
  /// build完了後に実行
  Future.microtask(() => vm.fetchAllSalaries());
  return vm;
});

class PremiumTimeLineViewModel extends StateNotifier<PremiumTimeLineState> {

  final Ref _ref;
  final PaymentRepository _paymentRepository;
  final SalaryRepository _salaryRepository;
  final PublicSalaryRepository _publicSalaryRepository;

  PremiumTimeLineViewModel(
      this._ref,
      this._paymentRepository,
      this._salaryRepository,
      this._publicSalaryRepository
      ): super(PremiumTimeLineState.initial());

  Future<void> fetchAllSalaries() async {
    await _ref.runWithGlobalHandling(() async {
      final page = await _publicSalaryRepository.fetchAllList();
      state = state.copyWith(
        salaries: page.salaries.map((e) => e.toDomain()).toList(),
        currentPage: page.currentPage,
        lastPage: page.lastPage,
      );
    });
  }

  /// ページング読み込み
  Future<void> loadNextPage() async {
    if (state.currentPage >= state.lastPage) { return; }

    if (state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;

    final page = await _publicSalaryRepository.fetchAllList(page: nextPage);

    state = state.copyWith(
      salaries: [
        ...state.salaries,
        ...page.salaries.map((e) => e.toDomain()),
      ],
      currentPage: page.currentPage,
      lastPage: page.lastPage,
      isLoadingMore: false,
    );
  }

  /// リフレッシュ処理
  Future<void> refresh() async {
    state = state.copyWith(
      salaries: [],
      currentPage: 1,
      lastPage: null,
    );
    await fetchAllSalaries();
  }

}
