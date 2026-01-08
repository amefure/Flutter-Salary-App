
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/domain/input_payment_source/input_payment_source_state.dart';
import 'package:salary/domain/list_salary/list_salary_view_model.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/repository/realm_repository.dart';
import 'package:salary/providers/payment_source_notifier.dart';

final inputPaymentSourceProvider = StateNotifierProvider.autoDispose.family<InputPaymentSourceViewModel, InputPaymentSourceState, PaymentSource?>(
    (ref, paymentSource) {
      final repository = RealmRepository();
      return InputPaymentSourceViewModel(ref, repository, paymentSource);
    }
);

class InputPaymentSourceViewModel extends StateNotifier<InputPaymentSourceState> {

  final Ref ref;

  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  final PaymentSource? paymentSource;

  InputPaymentSourceViewModel(
      this.ref,
      this._repository,
      this.paymentSource
      ) : super(InputPaymentSourceState.initial()) {
    _setUpInitialPayment(paymentSource);
  }


  void _setUpInitialPayment(PaymentSource? current) {
    final allPayments = _repository.fetchAll<PaymentSource>();
    final hasMainPaymentSource = allPayments.any((p) => p.isMain == true);

    if (current case PaymentSource paymentSource) {
      state = state.copyWith(
          name: paymentSource.name,
          memo: paymentSource.memo,
          selectedColor: paymentSource.themaColorEnum,
          isMain: paymentSource.isMain,
          isMainEnabled: current.isMain ? true : !hasMainPaymentSource
      );
    } else {
      // 初期値はデフォルトのまま
      // isMainがtrueのデータが既にある場合はdisabledにするためfalseを渡す
      state = state.copyWith(
          isMainEnabled: !hasMainPaymentSource
      );
    }
  }

  void createOrUpdate({
    required VoidCallback onComplete,
    required VoidCallback onError,
}) {
    if (state.name.isEmpty) {
      // バリデーションエラー
      onError();
      return;
    }

    if (paymentSource case PaymentSource paymentSource) {
      // 更新
      ref
          .read(paymentSourceProvider.notifier)
          .update(paymentSource.id, state.name, state.selectedColor, state.memo, state.isMain);
    } else {
      // 新規登録
      final payment = PaymentSource(
        Uuid.v4().toString(),
        state.name,
        state.selectedColor.value,
        state.isMain,
        memo: state.memo,
      );
      ref.read(paymentSourceProvider.notifier).add(payment);
    }
    // MyData画面のリフレッシュ
    ref.read(chartSalaryProvider.notifier).refresh();
    // Homeリスト画面のリフレッシュ
    ref.read(listSalaryProvider.notifier).refresh();
    onComplete();
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  void updateColor(ThemaColor? color) {
    state = state.copyWith(selectedColor: color);
  }

  void updateIsMain(bool isMain) {
    state = state.copyWith(isMain: isMain);
  }

}