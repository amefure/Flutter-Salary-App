
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/feature/setting/list_payment_source/list_payment_source_state.dart';

final listPaymentSourceProvider =
StateNotifierProvider.autoDispose<ListPaymentSourceViewModel, ListPaymentSourceState>((ref) {
  final repository = RealmRepository();
  return ListPaymentSourceViewModel(repository);
});

class ListPaymentSourceViewModel extends StateNotifier<ListPaymentSourceState> {

  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  ListPaymentSourceViewModel(this._repository): super(ListPaymentSourceState.initial()) {
    fetchAll();
  }

  /// 全取得
  void fetchAll() {
    final results = _repository.fetchAll<PaymentSource>()
      ..sort((a, b) {
        final aValue = a.isMain ? 1 : 0;
        final bValue = b.isMain ? 1 : 0;
        return bValue - aValue;
      });
    state = state.copyWith(paymentSources: results);
  }

  /// 削除
  void delete(PaymentSource paymentSource) {
    _repository.deleteById<PaymentSource>(paymentSource.id);
    fetchAll();
  }

  void updateExpanded(String id, bool isExpanded) {
    final newState = Map<String, bool>.from(state.expandedMap);
    newState[id] = !isExpanded;
    state = state.copyWith(expandedMap: newState);
  }
}