
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/feature/setting/public_salary/public_salary_state.dart';

final publicSalaryProvider =
StateNotifierProvider.autoDispose<PublicSalaryViewModel, PublicSalaryState>((ref) {
  final repository = RealmRepository();
  return PublicSalaryViewModel(repository);
});

class PublicSalaryViewModel extends StateNotifier<PublicSalaryState> {

  final RealmRepository _repository;

  PublicSalaryViewModel(this._repository): super(PublicSalaryState.initial()) {
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
}