import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/repository/domain/local_annual_withholding_repository.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import 'package:salary/feature/annual_withholding/annual_withholding_state.dart';

final annualWithholdingProvider =
    StateNotifierProvider<AnnualWithholdingViewModel, AnnualWithholdingState>((
      ref,
    ) {
      return AnnualWithholdingViewModel(
        ref.read(localAnnualWithholdingRepositoryProvider),
        ref.read(localPaymentSourceRepositoryProvider),
      );
    });

class AnnualWithholdingViewModel extends StateNotifier<AnnualWithholdingState> {
  final LocalAnnualWithholdingRepository _annualWithholdingRepository;
  final LocalPaymentSourceRepository _paymentSourceRepository;

  AnnualWithholdingViewModel(
    this._annualWithholdingRepository,
    this._paymentSourceRepository,
  ) : super(AnnualWithholdingState.initial()) {
    fetchAll();
  }

  void fetchAll() {
    final items = _annualWithholdingRepository.fetchAll();
    final paymentSources =
        _paymentSourceRepository.fetchSortedAllPaymentSources();

    state = state.copyWith(items: items, paymentSources: paymentSources);
  }

  List<AnnualWithholding> itemsForYear(int year) {
    final items = state.items.where((item) => item.year == year).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  bool save({required AnnualWithholding item}) {
    if (item.year <= 0 || item.paymentSourceId.trim().isEmpty) {
      return false;
    }

    final duplicate = _annualWithholdingRepository.findByYearAndPaymentSourceId(
      item.year,
      item.paymentSourceId,
    );
    if (duplicate != null && duplicate.id != item.id) {
      return false;
    }

    _annualWithholdingRepository.save(item);
    fetchAll();
    return true;
  }

  void deleteById(String id) {
    _annualWithholdingRepository.deleteById(id);
    fetchAll();
  }

  int totalPaymentAmountForYear(int year) {
    return _annualWithholdingRepository.totalPaymentAmountForYear(year);
  }

  int totalIncomeTaxAmountForYear(int year) {
    return _annualWithholdingRepository.totalIncomeTaxAmountForYear(year);
  }
}
