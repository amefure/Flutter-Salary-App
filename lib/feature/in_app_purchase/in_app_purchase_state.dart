import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseState {
  final bool loading;
  final bool isRestoring;
  final String? dialogMessage;
  final List<ProductDetails> products;
  final List<String> purchasedIds;

  const InAppPurchaseState({
    this.loading = true,
    this.isRestoring = false,
    this.dialogMessage,
    this.products = const [],
    this.purchasedIds = const [],
  });

  InAppPurchaseState copyWith({
    bool? loading,
    bool? isRestoring,
    String? dialogMessage,
    List<ProductDetails>? products,
    List<String>? purchasedIds,
  }) {
    /// メッセージがnullなら既存の値のまま
    /// 明示的に空ならnullにする
    late final msg;
    if (dialogMessage == null) {
      msg = this.dialogMessage;
    } else if (dialogMessage.isEmpty) {
      msg = null;
    } else {
      msg = dialogMessage;
    }
    return InAppPurchaseState(
      loading: loading ?? this.loading,
      isRestoring: isRestoring ?? this.isRestoring,
      dialogMessage: msg,
      products: products ?? this.products,
      purchasedIds: purchasedIds ?? this.purchasedIds,
    );
  }
}
