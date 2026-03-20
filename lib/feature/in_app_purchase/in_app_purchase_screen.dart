import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/empty_state_view.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/feature/in_app_purchase/in_app_purchase_state.dart';
import 'package:salary/feature/in_app_purchase/in_app_purchase_view_model.dart';

class InAppPurchaseScreen extends ConsumerWidget {
  const InAppPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inAppPurchaseProvider);
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: '広告削除 & プレミアム機能解放',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: state.loading
            ? const Center(child: CupertinoActivityIndicator())
            : state.products.isEmpty
            ? _noDataView() : _productListView(ref, state),
      ),
    );
  }

  /// NoData EmptyView
  Widget _noDataView() {
    return const Center(
      child: EmptyStateView(
        message: '商品が見つかりません。\n時間をあけて再度お試しください。',
        icon: CupertinoIcons.gift,
      ),
    );
  }

  Widget _productListView(
      WidgetRef ref,
      InAppPurchaseState state
      ) {
    final vm = ref.read(inAppPurchaseProvider.notifier);
    final premiumState = ref.watch(premiumFunctionStateProvider);
    return Column(
      spacing: 20,
      children: [
        const CustomText(
          text: '購入後のキャンセルは致しかねますのでご了承ください。',
          textSize: TextSize.S,
          maxLines: 2,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.products.length + 1,
            itemBuilder: (context, index) {
              final isLast = index == state.products.length;
              if (isLast) {
                return _itemRowView(
                  context,
                  '購入アイテムを復元する',
                  '一度ご購入いただけますと、\n再インストール時に復元が可能です。',
                  '',
                  PurchaseState.restore,
                  vm.restore,
                );
              }

              final p = state.products[index];
              final status = vm.fetchPurchaseState(p.id, premiumState.isUnLimitedInAppPurchase);

              // FIXME なせか空になる時があるのでisEmptyなら明示的に値を返す暫定対応
              return _itemRowView(
                context,
                p.title.isEmpty ? '広告削除' : p.title,
                p.description.isEmpty ? 'アプリ内に表示されているバナー広告が非表示になります。' : p.description,
                p.price,
                status,
                status.isAvailable ? () => vm.buy(p) : () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _itemRowView(
      BuildContext context,
      String title,
      String description,
      String price,
      PurchaseState state,
      VoidCallback onPressed,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CustomColors.background(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 8,
          children: [
            CustomText(
              text: title,
              textSize: TextSize.M,
              fontWeight: FontWeight.bold,
            ),
            CustomText(
              text: '・$description',
              textSize: TextSize.SS,
              maxLines: 3,
            ),
            if (price.isNotEmpty)
              CustomText(
                text: price,
                textSize: TextSize.L,
                fontWeight: FontWeight.bold,
              ),

            CustomElevatedButton(
                text: state.buttonTitle,
                backgroundColor: state.buttonColor,
                onPressed: onPressed
            )
          ],
        ),
      ),
    );
  }
}