import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/domain/detail/detail_salary_view_model.dart';
import 'package:salary/domain/input/input_salary_state.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/repository/realm_repository.dart';
import 'package:salary/utilities/logger.dart';
import 'package:salary/viewmodels/reverpod/salary_notifier.dart';

final inputSalaryProvider =
StateNotifierProvider.autoDispose.family<InputSalaryViewModel, InputSalaryState, Salary?>(
      (ref, salary) {
    final repository = RealmRepository();
    return InputSalaryViewModel(ref, repository, salary);
  },
);

class InputSalaryViewModel extends StateNotifier<InputSalaryState> {
  final Ref ref;

  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  final Salary? salary;

  /// 初期インスタンス化
  InputSalaryViewModel(this.ref, this._repository, this.salary)
      : super( InputSalaryState.initial()) {
    // 履歴を読み込み
    _loadHistorySalary(salary);
    // 支払い元履歴と編集対象初期値の取得
    _loadSalaryAndPayment(salary);
  }

  /// 現在のSalary履歴を取得　編集対象は除去
  void _loadHistorySalary(Salary? current) {
    final histories = _repository.fetchAll<Salary>().where((salary) => salary.id != current?.id).toList();
    logger('履歴を読み込み${histories.length}');
    state = state.copyWith(
      historyList: histories
    );
  }

  void _loadSalaryAndPayment(Salary? current) {
    final paymentSources = _repository.fetchAll<PaymentSource>();

    if (current case Salary salary) {
      final createdAt = salary.createdAt;
      final paymentAmount = salary.paymentAmount.toString();
      final deductionAmount = salary.deductionAmount.toString();
      final netSalary = salary.netSalary.toString();
      final isBonus = salary.isBonus;
      // mapでコピーを作成しておかないと参照渡しでRealm管理下オブジェクトがわたり
      // write内でないので書き込み権限エラーになる
      // しかしコピーしたものでそのまま更新しようとするとエラーになるので注意
      final paymentAmountItems =
          salary.paymentAmountItems
              .map((item) => AmountItem(item.id, item.key, item.value))
              .toList();

      final deductionAmountItems =
          salary.deductionAmountItems
              .map((item) => AmountItem(item.id, item.key, item.value))
              .toList();
      final selectPaymentSource = salary.source;
      final memo = salary.memo;

      state = state.copyWith(
        isBonus: isBonus,
        paymentAmount: paymentAmount,
        deductionAmount: deductionAmount,
        netSalary: netSalary,
        createdAt: createdAt,
        paymentAmountItems: paymentAmountItems,
        deductionAmountItems: deductionAmountItems,
        memo: memo,

        paymentSources: paymentSources,
        selectPaymentSource: selectPaymentSource,
      );
    } else {
      state = state.copyWith(
        paymentSources: paymentSources,
        // 存在するなら一番最初のものを適応
        selectPaymentSource: paymentSources.firstOrNull
      );
    }
  }

  List<PaymentSource> fetchAndRefreshPaymentSources() {
    final paymentSources = _repository.fetchAll<PaymentSource>();
    state = state.copyWith(
        paymentSources: paymentSources,
    );
    return paymentSources;
  }


  /// 手取りの合計金額を計算しUI反映
  void calcNetSalaryAmount() {
    final int? paymentAmount = int.tryParse(state.paymentAmount);
    final int? deductionAmount = int.tryParse(state.deductionAmount);

    // どれかが null（不正な入力値）の場合はエラーダイアログを表示
    if (paymentAmount == null || deductionAmount == null) { return; }

    final int netSalary = paymentAmount - deductionAmount;
    state = state.copyWith(
        netSalary: netSalary.toString()
    );
  }

  /// 総支給額の合計金額を計算しUI反映
  void updateTotalPaymentAmount() {
    int total = state.paymentAmountItems.fold(0, (sum, item) => sum + item.value);
    state = state.copyWith(
        paymentAmount: total.toString()
    );
    calcNetSalaryAmount();
  }

  /// 控除額の合計金額を計算しUI反映
  void updateTotalDeductionAmount() {
    int total = state.deductionAmountItems.fold(0, (sum, item) => sum + item.value);
    state = state.copyWith(
        deductionAmount: total.toString()
    );
    calcNetSalaryAmount();
  }

  void updatePaymentAmount(String paymentAmount) {
    state = state.copyWith(paymentAmount: paymentAmount);
  }

  void updateDeductionAmount(String deductionAmount) {
    state = state.copyWith(deductionAmount: deductionAmount);
  }

  void updateNetSalary(String netSalary) {
    state = state.copyWith(netSalary: netSalary);
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  void updateIsBonus(bool isBonus) {
    state = state.copyWith(isBonus: isBonus);
  }

  void updateSelectPaymentSource(PaymentSource source) {
    state = state.copyWith(selectPaymentSource: source);
  }

  void addPaymentAmountItem(AmountItem item) {
    state = state.copyWith(
      paymentAmountItems: [...state.paymentAmountItems, item],
    );
    updateTotalPaymentAmount();
  }

  void addDeductionAmountItem(AmountItem item) {
    state = state.copyWith(
      deductionAmountItems: [...state.deductionAmountItems, item],
    );
    updateTotalDeductionAmount();
  }

  void updatePaymentAmountItem({
    required AmountItem oldItem,
    required AmountItem newItem,
  }) {
    state.paymentAmountItems.remove(oldItem);
    state = state.copyWith(
      paymentAmountItems: [...state.paymentAmountItems, newItem],
    );
    updateTotalPaymentAmount();
  }

  void updateDeductionAmountItem({
    required AmountItem oldItem,
    required AmountItem newItem,
  }) {
    state.deductionAmountItems.remove(oldItem);
    state = state.copyWith(
      deductionAmountItems: [...state.deductionAmountItems, newItem],
    );
    updateTotalPaymentAmount();
  }

  void removePaymentAmountItem(AmountItem item) {
    state.paymentAmountItems.remove(item);
    updateTotalPaymentAmount();
  }

  void removeDeductionAmountItem(AmountItem item) {
    state.deductionAmountItems.remove(item);
    updateTotalDeductionAmount();
  }


  void selectDate(DateTime newDate) {
   // final dateString = _formatDate(newDate);
    // final selectYearAndMonth =
    //     DateTimeUtils.parse(
    //       dateString: dateString,
    //       pattern: 'yyyy/M/d',
    //     ) ?? DateTime.now();
    // selectYearAndMonthは時間は0:00になっている
    // JTCの9時間の差分保存後にずれてしまうので
    // 先に12時間ほどずらしておく
    final createdAt = newDate.add(
      const Duration(hours: 12),
    );
    state = state.copyWith(
        createdAt: createdAt
    );
  }

  void copySalaryFromPast(Salary pastSalary) {
    final selectPaymentSource = pastSalary.source;
    final paymentAmountItems =
        pastSalary.paymentAmountItems
            .map(
              (item) =>
              AmountItem(Uuid.v4().toString(), item.key, item.value),
        )
            .toList();
    String? paymentAmount;
    if (paymentAmountItems.isEmpty) {
      paymentAmount = pastSalary.paymentAmount.toString();
    } else {
      updateTotalPaymentAmount();
    }
    final deductionAmountItems =
        pastSalary.deductionAmountItems
            .map(
              (item) =>
              AmountItem(Uuid.v4().toString(), item.key, item.value),
        )
            .toList();
    String? deductionAmount;
    if (deductionAmountItems.isEmpty) {
      deductionAmount = pastSalary.deductionAmount.toString();
    } else {
      updateTotalDeductionAmount();
    }

    state = state.copyWith(
      paymentAmount: paymentAmount,
      deductionAmount: deductionAmount,
      memo: pastSalary.memo,
      selectPaymentSource: selectPaymentSource,
    );
    calcNetSalaryAmount();
  }

  /// **桁数バリデーション**
  bool _validationLength() {
    // 桁数バリデーション
    // int は 64ビット整数 であり、以下の範囲の値を保持できます。
    // 最小値: -9,223,372,036,854,775,808 (-2^63)
    // 最大値: 9,223,372,036,854,775,807 (2^63 - 1)
    return state.paymentAmount.length > 19 || state.deductionAmount.length > 19 || state.netSalary.length > 19;
  }

  /// 給料情報新規追加
  void addOrUpdate() {
    // 桁数バリデーション
    if (_validationLength()) {
      throw const ValidationException('19桁以上は入力できません。');
    }

    final int? paymentAmount = int.tryParse(state.paymentAmount);
    final int? deductionAmount = int.tryParse(state.deductionAmount);
    final int? netSalary = int.tryParse(state.netSalary);

    // どれかが null（不正な入力値）の場合はエラーダイアログを表示
    if (paymentAmount == null || deductionAmount == null || netSalary == null) {
      throw const ValidationException(
        '総支給額、控除額、手取り額を入力してください。',
      );
    }

    final newSalary = Salary(
      Uuid.v4().toString(),
      paymentAmount,
      deductionAmount,
      netSalary,
      state.createdAt,
      state.isBonus,
      state.memo,
      paymentAmountItems: state.paymentAmountItems,
      deductionAmountItems: state.deductionAmountItems,
      source: state.selectPaymentSource,
    );

    if (salary case Salary salary) {
      ref.read(salaryProvider.notifier).update(salary, newSalary);
      ref.read(detailSalaryProvider(salary.id).notifier).loadSalary(salary.id);
    } else {
      ref.read(salaryProvider.notifier).add(newSalary);
    }

    // MyData画面のリフレッシュ
    ref.read(chartSalaryProvider.notifier).refresh();
  }
}

sealed class InputSalaryException implements Exception {
  final String message;
  const InputSalaryException(this.message);
}

class ValidationException extends InputSalaryException {
  const ValidationException(String message) : super(message);
}
