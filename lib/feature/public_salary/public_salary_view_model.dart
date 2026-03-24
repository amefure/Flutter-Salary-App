
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/feature/payment_source/data/payment_repository_impl.dart';
import 'package:salary/feature/payment_source/domain/payment_repository.dart';
import 'package:salary/feature/public_salary/public_salary_state.dart';
import 'package:salary/feature/salary/data/salary_repository_impl.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';

final publicSalaryProvider =
StateNotifierProvider.autoDispose<PublicSalaryViewModel, PublicSalaryState>((ref) {
  final repository = RealmRepository();
  final paymentRepository = ref.read(paymentRepositoryProvider);
  final salaryRepository = ref.read(salaryRepositoryProvider);
  return PublicSalaryViewModel(ref, repository, paymentRepository, salaryRepository);
});

class PublicSalaryViewModel extends StateNotifier<PublicSalaryState> {

  final Ref _ref;
  final RealmRepository _repository;
  final PaymentRepository _paymentRepository;
  final SalaryRepository _salaryRepository;

  PublicSalaryViewModel(
      this._ref,
      this._repository,
      this._paymentRepository,
      this._salaryRepository
      ): super(PublicSalaryState.initial()) {
    _fetchAllLocalPaymentSource();
    _fetchAllLocalSalaries();
  }

  /// 全取得
  void _fetchAllLocalPaymentSource() {
    final results = _repository.fetchAll<PaymentSource>()
      ..sort((a, b) {
        final aValue = a.isMain ? 1 : 0;
        final bValue = b.isMain ? 1 : 0;
        return bValue - aValue;
      });
    final isMainPublic = results.any((source) => source.isMain && source.isPublic);
    state = state.copyWith(
        paymentSources: results,
        isMainPublic: isMainPublic
    );
  }

  /// ローカル情報の更新
  Future<bool> updatePaymentSource(
      PaymentSource current,
      bool isPublic
      ) async {
    /// ローカルのpublicUserIdプロパティの更新
    _updatePublicUserIdLocalPaymentSource(current, isPublic);
    /// クラウドのPaymentSourceを更新 + 給料情報のアップロード
    final result = await _createOrDeleteCloudPaymentSource(current, isPublic);
    if (result) {
      /// 成功時のみ
      /// ローカル再取得(State更新)
      _fetchAllLocalPaymentSource();
      /// 公開状態の変化を通知
      _ref.read(premiumFunctionStateProvider.notifier).checkAllPaymentSource();
    }
    return result;
  }

  /// ローカルの[publicUserId]プロパティの更新
  Future<void> _updatePublicUserIdLocalPaymentSource(
      PaymentSource current,
      bool isPublic
      ) async {
    final user = _ref.read(authStateProvider).user;
    final publicUserId = isPublic ? user?.id : null;
    _repository.updateById(current.id, (PaymentSource paymentSource) {
      paymentSource.name = current.name;
      paymentSource.isMain = current.isMain;
      paymentSource.themaColor = current.themaColor;
      paymentSource.memo = current.memo;
      paymentSource.publicUserId = publicUserId;
    });
  }

  /// クラウドのPaymentSourceを更新 + 給料情報のアップロード
  Future<bool> _createOrDeleteCloudPaymentSource(
      PaymentSource current,
      bool isPublic
      ) async {
    return await _ref.runWithGlobalHandling(() async {
      /// 対象PaymentSourceの給与のみ抽出
      final targetSalaries = state.salaries
          .where((salary) => salary.source?.id == current.id)
          .toList();
      if (isPublic) {
        await _paymentRepository.create(
            id: current.id,
            name: current.name,
            themeColor: current.themaColor,
            memo: current.memo,
            isMain: current.isMain
        );
        /// 一括登録
        await _salaryRepository.create(salaries: targetSalaries);
      } else {
        await _paymentRepository.delete(current.id);
        /// 一括登録
        await _salaryRepository.delete(salaries: targetSalaries);
      }
    });
  }

  /// 公開/非公開実行時のステータスチェック
  PublicCheckStatus checkPublicStatus(
      PaymentSource source,
      PublicCheckResult publicCheckResult,
      bool nextValue
  ) {
    if (!publicCheckResult.canPublic) return PublicCheckStatus.blockedByLimit;

    // 非公開にしようとしている時のバリデーション
    if (source.isPublic && !nextValue) {
      if (!_canUnPublic(source)) {
        return PublicCheckStatus.cannotUnPublicMain;
      }
    }

    // ポリシー同意チェック
    if (!_ref.read(authStateProvider).isPolicyAgreed) {
      return PublicCheckStatus.policyRequired;
    }

    return PublicCheckStatus.agreed;
  }


  /// 対象支払い元が非公開可能かどうか
  bool _canUnPublic(PaymentSource target) {
    // 本業以外 かつ 公開中のものが存在するか
    final hasSubPublic = state.paymentSources.any((source) => !source.isMain && source.isPublic,);
    // 対象が本業 かつ 本業が公開中 かつ 本業以外が公開中なら非公開禁止
    if (target.isMain && target.isPublic && hasSubPublic) {
      return false;
    }
    return true;
  }

  /// 対象支払い元が公開可能かどうかの結果
  PublicCheckResult canPublic(PaymentSource target) {
    /// 対象PaymentSourceの給与のみ抽出
    final targetSalaries = state.salaries
        .where((salary) => salary.source?.id == target.id)
        .toList();

    /// 件数
    final count = targetSalaries.length;
    /// 支給額合計
    final totalPaymentAmount = targetSalaries.fold<int>(0, (sum, salary) => sum + salary.paymentAmount,);

    /// 最小条件公開件数
    final minSalaryCountForPublic = target.isMain ? PublicPolicyConfig.mainMinSalaryCountForPublic : PublicPolicyConfig.subMinSalaryCountForPublic;
    /// 最小条件公開総支給合計額
    final minTotalPaymentAmountForPublic = target.isMain ? PublicPolicyConfig.mainMinTotalPaymentAmountForPublic : PublicPolicyConfig.subMinTotalPaymentAmountForPublic;

    /// 件数チェック
    if (count < minSalaryCountForPublic) {
      return PublicCheckResult(
        count: count,
        totalAmount: totalPaymentAmount,
        canPublic: false,
      );
    }
    /// 合計チェック
    if (totalPaymentAmount < minTotalPaymentAmountForPublic) {
      return PublicCheckResult(
        count: count,
        totalAmount: totalPaymentAmount,
        canPublic: false,
      );
    }

    /// 本業を公開していないなら本業以外は公開不可能にする
    if (!state.isMainPublic && !target.isMain) {
      return PublicCheckResult(
        count: count,
        totalAmount: totalPaymentAmount,
        canPublic: false,
      );
    }

    return PublicCheckResult(
      count: count,
      totalAmount: totalPaymentAmount,
      canPublic: true,
    );
  }

  void _fetchAllLocalSalaries() {
    final allSalaries = _repository.fetchAll<Salary>();
    // モック(確認用)
    // final allSalaries = SalaryMockFactory.allGenerateYears();
    state = state.copyWith(
      salaries: allSalaries,
    );
  }
}

class PublicCheckResult {
  final int count;
  final int totalAmount;
  final bool canPublic;

  const PublicCheckResult({
    required this.count,
    required this.totalAmount,
    required this.canPublic,
  });
}

enum PublicCheckStatus {
  /// 承認
  agreed,
  /// 本業以外が公開中なので本業を非公開にできない
  cannotUnPublicMain,
  /// ポリシー同意が必要
  policyRequired,
  /// その他の制限
  blockedByLimit,
}