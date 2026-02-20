import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/payment_source/data/payment_repository_impl.dart';
import 'package:salary/feature/payment_source/domain/payment_repository.dart';
import 'package:salary/feature/premium_time_line/premium_time_line_state.dart';
import 'package:salary/feature/salary/data/salary_repository_impl.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';

final premiumTimeLineProvider =
StateNotifierProvider.autoDispose<PremiumTimeLineViewModel, PremiumTimeLineState>((ref) {
  final paymentRepository = ref.read(paymentRepositoryProvider);
  final salaryRepository = ref.read(salaryRepositoryProvider);
  final vm = PremiumTimeLineViewModel(ref, paymentRepository, salaryRepository);
  /// build完了後に実行
  Future.microtask(() => vm.fetchAllSalaries());
  return vm;
});

class PremiumTimeLineViewModel extends StateNotifier<PremiumTimeLineState> {

  final Ref _ref;
  final PaymentRepository _paymentRepository;
  final SalaryRepository _salaryRepository;

  PremiumTimeLineViewModel(
      this._ref,
      this._paymentRepository,
      this._salaryRepository
      ): super(PremiumTimeLineState.initial()) {
  }


  void fetchAllSalaries() async {
    await _ref.runWithGlobalHandling(() async {
      // final allSalaries = await _salaryRepository.fetchAllUserList();
      final page = await _salaryRepository.fetchAllUserList();

      state = state.copyWith(
        salaries: page.salaries.map((e) => e.toDomain()).toList(),
        // currentPage: page.currentPage,
        // lastPage: page.lastPage,
      );
      //
      // state = state.copyWith(
      //   salaries: allSalaries,
      // );
    });
  }
}
