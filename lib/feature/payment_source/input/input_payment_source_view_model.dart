
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/payment_source/data/cloud_payment_repository_impl.dart';
import 'package:salary/feature/payment_source/domain/cloud_payment_repository.dart';
import 'package:salary/feature/payment_source/input/input_payment_source_state.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

final inputPaymentSourceProvider = StateNotifierProvider.autoDispose.family<InputPaymentSourceViewModel, InputPaymentSourceState, PaymentSource?>(
    (ref, paymentSource) {
      final localPaymentSourceRepository = ref.read(localPaymentSourceRepositoryProvider);
      final paymentRepository = ref.read(cloudPaymentRepositoryProvider);
      return InputPaymentSourceViewModel(ref, localPaymentSourceRepository, paymentRepository, paymentSource);
    }
);

class InputPaymentSourceViewModel extends StateNotifier<InputPaymentSourceState> {

  final Ref _ref;
  final LocalPaymentSourceRepository _localPaymentRepository;
  final CloudPaymentRepository _paymentRepository;
  final PaymentSource? paymentSource;

  InputPaymentSourceViewModel(
      this._ref,
      this._localPaymentRepository,
      this._paymentRepository,
      this.paymentSource
      ) : super(InputPaymentSourceState.initial()) {
    _setUpInitialPayment(paymentSource);
  }

  void _setUpInitialPayment(PaymentSource? current) {
    final hasMainPaymentSource = _localPaymentRepository.fetchMainPaymentSource() != null;
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

  Future<bool> createOrUpdate() async {
    if (state.name.isEmpty) {
      return false; // バリデーションエラー
    }

    if (paymentSource case PaymentSource paymentSource) {
      // 更新
      final result = await _updatePaymentSource(
          paymentSource.id,
          state.name,
          state.selectedColor,
          state.memo,
          state.isMain,
          paymentSource.isPublic
      );
      if (!result) { return false; }
    } else {
      // 新規登録
      final payment = PaymentSource(
        Uuid.v4().toString(),
        state.name,
        state.selectedColor.value,
        state.isMain,
        false,
        publicUserId: null,
        memo: state.memo,
      );
      _addPaymentSource(payment);
    }
    // MyData画面のリフレッシュ
    _ref.read(chartSalaryProvider.notifier).refresh();
    // Homeリスト画面のリフレッシュ
    _ref.read(listSalaryProvider.notifier).refresh();
    return true;
  }

  /// 追加
  void _addPaymentSource(PaymentSource paymentSource) {
    _localPaymentRepository.add(paymentSource);
  }

  /// 更新
  Future<bool> _updatePaymentSource(
      String id,
      String name,
      ThemaColor color,
      String? memo,
      bool isMain,
      bool isPublic
      ) async {
    if (isPublic) {
      await _ref.runWithGlobalHandling(() async {
        await _paymentRepository.update(
            id: id,
            name: name,
            themeColor: color.value,
            memo: memo,
            isMain: isMain
        );
        _localPaymentRepository.updatePaymentSource(
            id: id,
            name: name,
            isMain: isMain,
            themaColorValue: color.value,
            memo: memo
        );
      });
    } else {
      _localPaymentRepository.updatePaymentSource(
          id: id,
          name: name,
          isMain: isMain,
          themaColorValue: color.value,
          memo: memo
      );
    }
    return true;
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