import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/mock/salary_mock_factory.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/salary/list_salary/list_salary_state.dart';

final listSalaryProvider =
StateNotifierProvider<ListSalaryViewModel, ListSalaryState>((ref) {
  final localSalaryRepository = ref.read(localSalaryRepositoryProvider);
  final userSettings = ref.read(userSettingsProvider);
  return ListSalaryViewModel(ref, localSalaryRepository, userSettings);
});

/// 並べ替えの種類の定義
enum SalarySortOrder {
  dateDesc('日付の新しい順'),
  dateAsc('日付の古い順'),
  amountDesc('総支給の高い順'),
  amountAsc('総支給の低い順');

  final String label;
  const SalarySortOrder(this.label);
  /// labelからSalarySortOrderを取得（見つからない場合はデフォルト値を返す）
  static SalarySortOrder fromLabelWithDefault(String label, {SalarySortOrder defaultValue = SalarySortOrder.dateDesc}) {
    return SalarySortOrder.values.firstWhere(
          (element) => element.label == label,
      orElse: () => defaultValue,
    );
  }
}

class ListSalaryViewModel extends StateNotifier<ListSalaryState> {
  final Ref ref;
  final LocalSalaryRepository _localSalaryRepository;
  final UserSettingsRepository _userSettingsRepository;

  ListSalaryViewModel(this.ref, this._localSalaryRepository, this._userSettingsRepository)
      : super(ListSalaryState.initial()) {
    _loadSortOrder();
    _loadSalaries();
    _loadPaymentSource();
  }

  /// リフレッシュ
  void refresh() {
    _loadSortOrder();
    _loadSalaries();
    _loadPaymentSource();
    filterPaymentSource(state.selectedSource);
  }

  void _loadSortOrder() {
    final order = _userSettingsRepository.fetchSortOrder();
    state = state.copyWith(
      sortOrder: order,
    );
  }

  /// Realm から Salary を取得
  void _loadSalaries() {
    final allSalaries = _localSalaryRepository.fetchAllSortCreatedAt();
    // DEBUG：モック(確認用)
    // DEBUG：モックローカル保存処理
    // for (var item in allSalaries) {
    //   _repository.add(item);
    // }
    state = state.copyWith(
      salaries: allSalaries,
    );
  }

  /// Realm から PaymentSource を取得
  void _loadPaymentSource() {
    // 常に全て取得する
    final allSalaries = _localSalaryRepository.fetchAll();
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
    final sortedSalaries = _fetchSortedSalaries(filteredSalaries);
    state = state.copyWith(
        salaries: sortedSalaries,
        selectedSource: paymentSource
    );
  }

  void updateSortOrder(SalarySortOrder order) {
    state = state.copyWith(sortOrder: order);
    _userSettingsRepository.saveSortOrder(order);
    final sortedSalaries = _fetchSortedSalaries(state.salaries);
    state = state.copyWith(salaries: sortedSalaries);
  }

  List<Salary> _fetchSortedSalaries(List<Salary> list) {
    // スプレッド演算子 [...] で新しいリストのインスタンスを作成しないと変化したと検知されない
    final newList = [...list];
    switch (state.sortOrder) {
      case SalarySortOrder.dateDesc:
        /// 日付の新しい順（降順）
        newList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SalarySortOrder.dateAsc:
        /// 日付の古い順（昇順）
        newList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SalarySortOrder.amountDesc:
        /// 金額の高い順（降順）
        newList.sort((a, b) => b.paymentAmount.compareTo(a.paymentAmount));
        break;
      case SalarySortOrder.amountAsc:
        /// 金額の高い順（降順）
        newList.sort((a, b) => a.paymentAmount.compareTo(b.paymentAmount));
        break;
    }
    return newList;
  }
}