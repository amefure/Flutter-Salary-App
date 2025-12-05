
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:salary/models/secrets.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/logger.dart';
import 'dart:async';
import 'package:salary/viewmodels/reverpod/remove_ads_notifier.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_text_view.dart';

class InAppPurchaseView extends ConsumerStatefulWidget {
  const InAppPurchaseView({super.key});

  @override
  ConsumerState<InAppPurchaseView> createState() => _InAppPurchaseState();
}

class _InAppPurchaseState extends ConsumerState<InAppPurchaseView> {
  final _iap = InAppPurchase.instance;

  final Set<String> _productIds = { StaticKey.inAppPurchaseRemoveAdsId };

  List<ProductDetails> _products = [];
  bool _loading = true;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final List<String> _purchasedIds = [];

  @override
  void initState() {
    super.initState();

    /// 購入ストリームの監視開始
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        logger('purchaseStream Error: $error');
      },
    );

    /// 商品取得
    _loadProducts();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);

    final response = await _iap.queryProductDetails(_productIds);
    logger('notFound: ${response.notFoundIDs}');
    logger('products: ${response.productDetails}');

    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  /// 購入処理
  Future<void> _buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 購入更新コールバック
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          logger('購入処理中...');
          break;

        case PurchaseStatus.purchased:
          logger('購入成功！');
          _deliverProduct(purchaseDetails);
          break;

        case PurchaseStatus.error:
          logger('購入エラー: ${purchaseDetails.error}');
          break;

        case PurchaseStatus.restored:
          logger('購入復元！');
          _deliverProduct(purchaseDetails);
          break;

        default:
          break;
      }

      // iOSでは完了処理が必要
      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// 購入成功処理
  void _deliverProduct(PurchaseDetails purchaseDetails) {
    setState(() {
      _purchasedIds.add(purchaseDetails.productID);
    });
    logger('購入成功: ${purchaseDetails.productID}');
    if (purchaseDetails.productID == StaticKey.inAppPurchaseRemoveAdsId) {
      final notifier = ref.read(removeAdsProvider.notifier);
      notifier.update(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('広告削除'),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : _products.isEmpty
            ? const Center(child: CustomText(text: '商品が見つかりません。\n時間を開けて再度お試しください。'))
            : _productListView(_products),
      ),
    );
  }

  /// 課金アイテムリストView
  Widget _productListView(
      List<ProductDetails> products
  ) {
   return Column(
       spacing: 20,
       children: [

         const CustomText(
           text: '購入後のキャンセルは致しかねますのでご了承ください。',
           textSize: TextSize.S,
           maxLines: 2,
         ),

         // ListViewを設置する場合はExpandedで領域を確保する
         Expanded(
             child:
             ListView.builder(
               itemCount: products.length,
               itemBuilder: (context, index) {
                 final product = products[index];
                 return Card(
                   color: Colors.white,
                   margin: const EdgeInsets.symmetric(
                       horizontal: 16, vertical: 8),
                   child: Padding(
                     padding: const EdgeInsets.all(12),
                     child: Column(
                       spacing: 8,
                       children: [
                         // アイテムタイトル
                         CustomText(
                           text: product.title,
                           textSize: TextSize.M,
                           fontWeight: FontWeight.bold,
                         ),
                         // アイテム説明
                         CustomText(
                           text: '・${product.description}',
                           textSize: TextSize.SS,
                         ),
                         // 金額
                         CustomText(
                           text: product.price,
                           textSize: TextSize.L,
                           fontWeight: FontWeight.bold,
                         ),

                         _purchasedIds.contains(product.id) ?
                         CustomElevatedButton(
                             text: '購入ずみ',
                             onPressed: () {}
                         ) : CustomElevatedButton(
                             text: '購入する',
                             onPressed: () => _buy(product)
                         )

                       ],
                     ),
                   ),
                 );
               },
             )
         )
       ]
   );
  }
}
