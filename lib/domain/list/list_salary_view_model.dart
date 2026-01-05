
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/domain/list/list_salary_state.dart';
import 'package:salary/models/dummy_source.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/salary_mock_factory.dart';
import 'package:salary/repository/realm_repository.dart';

final listSalaryProvider =
StateNotifierProvider<ListSalaryViewModel, ListSalaryState>((ref) {
  final repository = RealmRepository();
  return ListSalaryViewModel(ref, repository);
});


class ListSalaryViewModel extends StateNotifier<ListSalaryState> {
  final Ref ref;
  final RealmRepository _repository;

  ListSalaryViewModel(this.ref, this._repository)
      : super(ListSalaryState.initial()) {
    _loadSalaries();
    _loadPaymentSource();
  }

  /// リフレッシュ
  void refresh() {
    _loadSalaries();
    _loadPaymentSource();
    filterPaymentSource(state.selectedSource);
  }

  /// Realm から Salary を取得
  void _loadSalaries() {
    final allSalariesTmp = _repository.fetchAll<Salary>();
    // モック(確認用)
    // final allSalariesTmp = SalaryMockFactory.allGenerateYears();
    // 日付の降順
    allSalariesTmp.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(
      salaries: allSalariesTmp,
    );
  }

  /// Realm から PaymentSource を取得
  void _loadPaymentSource() {
    // 常に全て取得する
    final allSalaries = _repository.fetchAll<Salary>();
    // モック(確認用)
    // final allSalaries = SalaryMockFactory.allGenerateYears();
    /// 支払い元を全て取得
    final allPayment = allSalaries
        .map((e) => e.source ?? DummySource.unSetDummySource )
        .whereType<PaymentSource>()
        .toSet()
        .toList()
        ..sort((a, b) {
          final aValue = a.isMain ? 1 : 0;
          final bValue = b.isMain ? 1 : 0;
          return bValue - aValue;
        });

    /// ALLを先頭に追加
    final sourceList = [
      DummySource.allDummySource,
      ...allPayment
    ];
    state = state.copyWith(
        sourceList: sourceList
    );
  }

  /// 支払い元でフィルタリング
  void filterPaymentSource(PaymentSource paymentSource) {
    // 再度全部取得する
    _loadSalaries();

    // ALLを選択されたなら処理を終了
    if (paymentSource == DummySource.allDummySource) {
      state = state.copyWith(
          selectedSource: paymentSource
      );
      return;
    }

    // 未選択を選択されたなら
    if (paymentSource == DummySource.unSetDummySource) {
      // キャッシュしてあるALLデータから未選択だけをフィルタリング
      final filteredSalaries = state.salaries.where((s) => s.source == null ).toList();
      state = state.copyWith(
          salaries: filteredSalaries,
          selectedSource: paymentSource
      );
      return;
    }

    // キャッシュしてあるALLデータからフィルタリング
    final filteredSalaries = state.salaries.where((s) => s.source?.id == paymentSource.id ).toList();
    state = state.copyWith(
        salaries: filteredSalaries,
        selectedSource: paymentSource
    );
  }
}