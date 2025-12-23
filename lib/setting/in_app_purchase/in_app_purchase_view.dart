
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/common/components/custom_elevated_button.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'in_app_purchase_state.dart';
import 'in_app_purchase_viewmodel.dart';

class InAppPurchaseView extends ConsumerWidget {
  const InAppPurchaseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inAppPurchaseProvider);
    final vm = ref.read(inAppPurchaseProvider.notifier);

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('広告削除'),
      ),
      child: SafeArea(
        child: state.loading
            ? const Center(child: CupertinoActivityIndicator())
            : state.products.isEmpty
            ? const Center(
          child: CustomText(
            text: '商品が見つかりません。\n時間を開けて再度お試しください。',
            maxLines: 2,
          ),
        )
            : _productListView(state, vm),
      ),
    );
  }

  Widget _productListView(InAppPurchaseState state, InAppPurchaseViewModel vm) {
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
                  '購入アイテムを復元する',
                  '一度ご購入いただけますと、\n再インストール時に復元が可能です。',
                  '',
                  '復元する',
                  vm.restore,
                );
              }

              final p = state.products[index];
              final isPurchased = state.purchasedIds.contains(p.id);

              // FIXME なせか空になる時があるのでisEmptyなら明示的に値を返す暫定対応
              return _itemRowView(
                p.title.isEmpty ? '広告削除' : p.title,
                p.description.isEmpty ? 'アプリ内に表示されているバナー広告が非表示になります。' : p.description,
                p.price,
                isPurchased ? '購入済み' : '購入する',
                isPurchased ? () {} : () => vm.buy(p),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _itemRowView(
      String title,
      String description,
      String price,
      String buttonTitle,
      VoidCallback onPressed,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
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
                text: buttonTitle,
                backgroundColor: buttonTitle == '購入済み' ? CustomColors.themaBlack : CustomColors.thema,
                onPressed: onPressed
            )
          ],
        ),
      ),
    );
  }
}
