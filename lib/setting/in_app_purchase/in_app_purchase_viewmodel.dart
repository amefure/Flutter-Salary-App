import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:salary/models/secrets.dart';
import 'package:salary/utilities/logger.dart';
import 'in_app_purchase_state.dart';
import 'package:salary/viewmodels/reverpod/remove_ads_notifier.dart';

final inAppPurchaseProvider =
NotifierProvider<InAppPurchaseViewModel, InAppPurchaseState>(
  InAppPurchaseViewModel.new,
);

class InAppPurchaseViewModel extends Notifier<InAppPurchaseState> {
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Set<String> productIds = {StaticKey.inAppPurchaseRemoveAdsId};

  @override
  InAppPurchaseState build() {
    // 初期化は build の中で直接行わず microtask で遅延実行
    Future.microtask(() => _initialize());

    // dispose の登録
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return InAppPurchaseState(loading: true);
  }

  /// 初期化
  void _initialize() {
    // 購入ストリーム購読
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => logger('purchaseStream Error: $e'),
    );

    loadProducts();
  }

  /// 商品取得
  Future<void> loadProducts() async {
    state = state.copyWith(loading: true);

    final response = await _iap.queryProductDetails(productIds);

    logger('notFound: ${response.notFoundIDs}');
    logger('products: ${response.productDetails}');

    state = state.copyWith(
      loading: false,
      products: response.productDetails,
    );
  }

  /// 購入
  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// 復元
  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  /// 購入ストリーム
  void _onPurchaseUpdate(List<PurchaseDetails> list) {
    for (final purchase in list) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliver(purchase);
          break;
        case PurchaseStatus.error:
          logger('購入エラー: ${purchase.error}');
          break;
        case PurchaseStatus.pending:
        default:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// 購入反映
  void _deliver(PurchaseDetails details) {
    final id = details.productID;

    state = state.copyWith(
      purchasedIds: [...state.purchasedIds, id],
    );

    if (id == StaticKey.inAppPurchaseRemoveAdsId) {
      ref.read(removeAdsProvider.notifier).update(true);
    }
  }
}
