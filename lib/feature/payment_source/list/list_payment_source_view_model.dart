
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/payment_source/list/list_payment_source_state.dart';

final listPaymentSourceProvider =
StateNotifierProvider.autoDispose<ListPaymentSourceViewModel, ListPaymentSourceState>((ref) {
  final localPaymentSourceRepository = ref.read(localPaymentSourceRepositoryProvider);
  return ListPaymentSourceViewModel(localPaymentSourceRepository);
});

class ListPaymentSourceViewModel extends StateNotifier<ListPaymentSourceState> {

  /// ローカル
  final LocalPaymentSourceRepository _localPaymentRepository;

  ListPaymentSourceViewModel(
      this._localPaymentRepository,
      ): super(ListPaymentSourceState.initial()) {
    fetchAll();
  }

  /// 全取得
  void fetchAll() {
    final results = _localPaymentRepository.fetchSortedAllPaymentSources();
    state = state.copyWith(paymentSources: results);
  }

  /// 削除
  void delete(PaymentSource paymentSource) {
    _localPaymentRepository.deleteById(paymentSource.id);
    fetchAll();
  }

  void updateExpanded(String id, bool isExpanded) {
    final newState = Map<String, bool>.from(state.expandedMap);
    newState[id] = !isExpanded;
    state = state.copyWith(expandedMap: newState);
  }
}