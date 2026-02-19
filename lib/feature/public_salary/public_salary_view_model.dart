
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/feature/public_salary/public_salary_state.dart';

final publicSalaryProvider =
StateNotifierProvider.autoDispose<PublicSalaryViewModel, PublicSalaryState>((ref) {
  final repository = RealmRepository();
  return PublicSalaryViewModel(ref, repository);
});

class PublicSalaryViewModel extends StateNotifier<PublicSalaryState> {

  final Ref _ref;
  final RealmRepository _repository;

  PublicSalaryViewModel(this._ref, this._repository): super(PublicSalaryState.initial()) {
    _fetchAllPaymentSource();
    _fetchAllSalaries();
  }

  /// 公開条件(件数 & 総支給額合計)
  static const int minSalaryCountForPublic = 3;//12;
  static const int minTotalPaymentAmountForPublic = 10000;

  /// 全取得
  void _fetchAllPaymentSource() {
    final results = _repository.fetchAll<PaymentSource>()
      ..sort((a, b) {
        final aValue = a.isMain ? 1 : 0;
        final bValue = b.isMain ? 1 : 0;
        return bValue - aValue;
      });
    state = state.copyWith(paymentSources: results);
  }

  /// 更新
  void updatePaymentSource(
      PaymentSource current,
      bool isPublic
      ) {
    final user = _ref.read(authStateProvider).user;
    final publicUserId = isPublic ? user?.id : null;
    _repository.updateById(current.id, (PaymentSource paymentSource) {
      paymentSource.name = current.name;
      paymentSource.isMain = current.isMain;
      paymentSource.themaColor = current.themaColor;
      paymentSource.memo = current.memo;
      paymentSource.publicUserId = publicUserId;
    });
    _fetchAllPaymentSource();
    /// 公開状態の変化を通知
    _ref.read(premiumFunctionStateProvider.notifier).checkAllPaymentSource();
  }

  bool canPublic(PaymentSource target) {
    /// 対象PaymentSourceの給与のみ抽出
    final targetSalaries = state.salaries
        .where((salary) => salary.source?.id == target.id)
        .toList();

    /// 件数チェック
    if (targetSalaries.length < minSalaryCountForPublic) {
      return false;
    }

    /// 支給額合計チェック
    final totalPaymentAmount = targetSalaries.fold<int>(0, (sum, salary) => sum + salary.paymentAmount,);

    if (totalPaymentAmount < minTotalPaymentAmountForPublic) {
      return false;
    }

    return true;
  }

  void _fetchAllSalaries() {
    final allSalaries = _repository.fetchAll<Salary>();
    // モック(確認用)
    // final allSalaries = SalaryMockFactory.allGenerateYears();
    state = state.copyWith(
      salaries: allSalaries,
    );
  }
}