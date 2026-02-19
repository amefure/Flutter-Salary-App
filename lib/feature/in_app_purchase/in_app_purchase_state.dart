import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseState {
  final bool loading;
  final List<ProductDetails> products;
  final List<String> purchasedIds;

  const InAppPurchaseState({
    this.loading = true,
    this.products = const [],
    this.purchasedIds = const [],
  });

  InAppPurchaseState copyWith({
    bool? loading,
    List<ProductDetails>? products,
    List<String>? purchasedIds,
  }) {
    return InAppPurchaseState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      purchasedIds: purchasedIds ?? this.purchasedIds,
    );
  }
}
