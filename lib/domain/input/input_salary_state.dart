
import 'package:salary/models/salary.dart';

class InputSalaryState {
  /// ボーナスかどうかのフラグ
  bool isBonus;
  /// 総支給額
  String paymentAmount;
  /// 控除額
  String deductionAmount;
  /// 手取り額
  String netSalary;
  /// 作成日(給料支給日)
  DateTime createdAt = DateTime.now();
  /// 総支給詳細アイテム
  List<AmountItem> paymentAmountItems = [];
  /// 控除額詳細アイテム
  List<AmountItem> deductionAmountItems = [];
  /// メモ
  String memo;

  /// 支払い元一覧
  List<PaymentSource> paymentSources = [];
  /// 選択中の支払い元
  PaymentSource? selectPaymentSource;

  /// Salary履歴
  List<Salary> historyList = [];

  InputSalaryState({
    required this.isBonus,
    required this.paymentAmount,
    required this.deductionAmount,
    required this.netSalary,
    required this.createdAt,
    required this.paymentAmountItems,
    required this.deductionAmountItems,
    required this.memo,

    required this.paymentSources,
    required this.selectPaymentSource,

    required this.historyList,
  });

  String getDisplayDate() {
    return '${createdAt.year}/${createdAt.month}/${createdAt.day}';
  }
  String getPaymentSourceName() {
    return selectPaymentSource?.name ?? '未設定';
  }

  static InputSalaryState initial() {
    return InputSalaryState(
      isBonus: false,
      paymentAmount: '',
      deductionAmount: '',
      netSalary: '',
      createdAt: DateTime.now(),
      paymentAmountItems: List.empty(),
      deductionAmountItems: List.empty(),
      memo: '',

      paymentSources: List.empty(),
      selectPaymentSource: null,

      historyList: List.empty(),
    );
  }

  InputSalaryState copyWith({
    bool? isBonus,
    String? paymentAmount,
    String? deductionAmount,
    String? netSalary,
    DateTime? createdAt,
    List<AmountItem>? paymentAmountItems,
    List<AmountItem>? deductionAmountItems,
    String? memo,

    List<PaymentSource>? paymentSources,
    PaymentSource? selectPaymentSource,

    List<Salary>? historyList,
  }) {
    return InputSalaryState(
      isBonus: isBonus ?? this.isBonus,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      deductionAmount: deductionAmount ?? this.deductionAmount,
      netSalary: netSalary ?? this.netSalary,
      createdAt: createdAt ?? this.createdAt,
      paymentAmountItems: paymentAmountItems ?? this.paymentAmountItems,
      deductionAmountItems: deductionAmountItems ?? this.deductionAmountItems,
      memo: memo ?? this.memo,

      paymentSources: paymentSources ?? this.paymentSources,
      selectPaymentSource: selectPaymentSource ?? this.selectPaymentSource,

      historyList: historyList ?? this.historyList,
    );
  }
}