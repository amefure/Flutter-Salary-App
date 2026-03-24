import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:salary/core/models/secrets.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/core/providers/remove_ads_notifier.dart';
import 'package:salary/feature/in_app_purchase/in_app_purchase_state.dart';
import 'package:salary/core/utils/custom_colors.dart';

final inAppPurchaseProvider =
NotifierProvider<InAppPurchaseViewModel, InAppPurchaseState>(
  InAppPurchaseViewModel.new,
);

class InAppPurchaseViewModel extends Notifier<InAppPurchaseState> {
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Set<String> productIds = {
    StaticKey.inAppPurchaseRemoveAdsId,
    StaticKey.inAppPurchasePremiumFullUnlockedId,
    StaticKey.inAppPurchasePremiumFeaturesEnabledId,
  };

  @override
  InAppPurchaseState build() {
    // 初期化は build の中で直接行わず microtask で遅延実行
    Future.microtask(() => _initialize());

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const InAppPurchaseState(loading: true);
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
    state = state.copyWith(isRestoring: true);
    await ref.runWithGlobalHandling(() async {
      await _iap.restorePurchases();
      if (state.isRestoring) {
        state = state.copyWith(isRestoring: false);
      }
    });
  }

  PurchaseState fetchPurchaseState({
    required String productId,
    required bool isUnLimitedInAppPurchase,
    required bool isPublicData,
    required bool isPremiumFullUnlocked
}) {
    /// 購入済みかどうか
    final isPurchased = state.purchasedIds.contains(productId);

    if (productId == StaticKey.inAppPurchasePremiumFullUnlockedId && !isUnLimitedInAppPurchase && !isPurchased) {
      /// プレミアム全解放 && アプリ内課金がアンロック中 && 未購入 なら未解放にする
      /// 給料公開ユーザーなら購入不可にする
      return isPublicData ? PurchaseState.disabled : PurchaseState.locked;
    } else if (productId == StaticKey.inAppPurchasePremiumFeaturesEnabledId && !isPublicData && !isPurchased) {
      /// プレミアム一部解放 && 給料公開していない && 未購入なら
      return PurchaseState.disabled;
    } else if (productId == StaticKey.inAppPurchasePremiumFullUnlockedId && isPublicData && !isPurchased) {
      /// プレミアム全解放 && 給料公開ユーザー &&  未購入 なら未解放にする
      return PurchaseState.disabled;
    } else if (productId == StaticKey.inAppPurchasePremiumFeaturesEnabledId && isPremiumFullUnlocked && !isPurchased) {
      /// プレミアム一部解放 && 全解放購入済み &&  未購入 なら未解放にする
      return PurchaseState.disabled;
    } else {
      return isPurchased ? PurchaseState.purchased : PurchaseState.available;
    }
  }

  /// 購入ストリーム
  void _onPurchaseUpdate(List<PurchaseDetails> list) {
    // 「復元」や「購入」が一件でも成功したか
    bool hasRestoredSuccess = false;
    bool hasErrorOccurred = false;
    for (final purchase in list) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          logger('復元: ${purchase.productID}');
          _deliver(purchase);
          if (state.isRestoring) {
            hasRestoredSuccess = true;
          }
          break;
        case PurchaseStatus.error:
          logger('購入エラー: ${purchase.error}');
          if (state.isRestoring) {
            hasErrorOccurred = true;
          }
          break;
        case PurchaseStatus.pending:
        default:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }

    if (state.isRestoring) {
      if (hasRestoredSuccess) {
        _showResultDialog('購入情報の復元が完了しました。');
      } else if (hasErrorOccurred) {
        _showResultDialog('復元に失敗しました。時間を空けて再度お試しください。');
      }
    }
  }

  void _showResultDialog(String msg) {
    state = state.copyWith(
      isRestoring: false,
      dialogMessage: msg
    );
  }

  /// 購入反映
  void _deliver(PurchaseDetails details) {
    final id = details.productID;

    state = state.copyWith(
      purchasedIds: [...state.purchasedIds, id],
    );

    if (id == StaticKey.inAppPurchaseRemoveAdsId) {
      ref.read(removeAdsProvider.notifier).update(true);
    } else if (id == StaticKey.inAppPurchasePremiumFullUnlockedId) {
      ref.read(premiumFunctionStateProvider.notifier).updateIsPremiumFullUnlocked(true);
    } else if (id == StaticKey.inAppPurchasePremiumFeaturesEnabledId) {
      ref.read(premiumFunctionStateProvider.notifier).updateIsPremiumFeatureUnlocked(true);
    }
  }

  void clearDialogMessage() {
    state = state.copyWith(
      dialogMessage: ''
    );
  }
}

enum PurchaseState {
  /// 購入不可
  disabled('購入不可', CustomColors.themaGray),
  /// ロック中(未解放）
  locked('未解放', CustomColors.themaBlack),
  /// 購入可能
  available('購入する', CustomColors.thema),
  /// 購入済み
  purchased('購入済み', CustomColors.themaBlack),
  /// 復元する
  restore('復元する', CustomColors.thema);

  final String buttonTitle;
  final Color buttonColor;
  const PurchaseState(this.buttonTitle, this.buttonColor);

  bool get isAvailable => this == PurchaseState.available;
}
