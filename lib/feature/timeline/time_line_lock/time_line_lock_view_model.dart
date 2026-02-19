
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/feature/timeline/time_line_lock/time_line_lock_state.dart';

final timeLineLockProvider = StateNotifierProvider.autoDispose<TimeLineLockViewModel, TimeLineLockState>((ref) {
  final repository = RealmRepository();
  return TimeLineLockViewModel(ref, repository);
});

class TimeLineLockViewModel extends StateNotifier<TimeLineLockState> {

  final Ref _ref;
  final RealmRepository _repository;

  TimeLineLockViewModel(
      this._ref,
      this._repository
      ): super(TimeLineLockState(isPublic: false)) {
    _fetchAllPaymentSource();
  }

  /// 全取得
  void _fetchAllPaymentSource() {
    final bool isPublic = _repository.fetchAll<PaymentSource>().contains((source) => source.isPublic);
    state = state.copyWith(isPublic);
  }


}