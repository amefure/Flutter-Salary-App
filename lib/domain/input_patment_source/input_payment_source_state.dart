import 'package:salary/models/thema_color.dart';

class InputPaymentSourceState {
  /// 支払い元名
  String name;
  /// めも
  String memo;
  /// カラー
  ThemaColor selectedColor;
  /// 本業フラグ
  bool isMain;
  /// 本業フラグ活性フラグ
  bool isMainEnabled;


  InputPaymentSourceState({
    required this.name,
    required this.memo,
    required this.selectedColor,
    required this.isMain,
    required this.isMainEnabled
  });


  static InputPaymentSourceState initial() {
    return InputPaymentSourceState(
        name: '',
        memo: '',
        selectedColor: ThemaColor.gray,
        isMain: false,
        isMainEnabled: true
    );
  }

  InputPaymentSourceState copyWith({
    String? name,
    String? memo,
    ThemaColor? selectedColor,
    bool? isMain,
    bool? isMainEnabled
  }) {
    return InputPaymentSourceState(
        name: name ?? this.name,
        memo: memo ?? this.memo,
        selectedColor: selectedColor ?? this.selectedColor,
        isMain: isMain ?? this.isMain,
        isMainEnabled: isMainEnabled ?? this.isMainEnabled
    );
  }
}