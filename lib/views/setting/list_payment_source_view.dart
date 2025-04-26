import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/viewmodels/reverpod/payment_source_notifier.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/input/input_payment_source.dart';

/// [ConsumerWidget]でUI更新
class ListPaymentSourceView extends ConsumerWidget {
  const ListPaymentSourceView({super.key});

  /// 削除確認ダイアログ
  void _showConfirmDeleteAlert(
    BuildContext context,
    WidgetRef ref,
    PaymentSource paymentSource,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("確認"),
          content: Text("「${paymentSource.name}」を本当に削除しますか？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("キャンセル"),
            ),
            TextButton(
              onPressed: () {
                _deletePaymentSource(dialogContext, ref, paymentSource);
              },
              child: const CustomText(
                text: "削除",
                fontWeight: FontWeight.bold,
                color: CustomColors.negative,
                textSize: TextSize.MS,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 支払い元の削除
  void _deletePaymentSource(
    BuildContext dialogContext,
    WidgetRef ref,
    PaymentSource paymentSource,
  ) {
    ref.read(paymentSourceProvider.notifier).delete(paymentSource);
    // ダイアログを閉じる(コンテキストが異なるので注意)
    Navigator.of(dialogContext).pop();
  }

  /// 支払い元追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return InputPaymentSourceView();
      },
    );
  }

  /// 支払い元更新画面を表示
  Future<void> _showUpdatePaymentSourceModal(
    BuildContext context,
    PaymentSource paymentSource,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return InputPaymentSourceView(paymentSource: paymentSource);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentSources = ref.watch(paymentSourceProvider);

    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('給料MEMO'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            onPressed: () {
              _showInputPaymentSourceModal(context);
            },
          ),
        ),
        child: SafeArea(
          child:
              paymentSources.isEmpty
                  ? _noDataView()
                  : _paymentSourceList(paymentSources, ref),
        ),
      ),
    );
  }

  /// NoData EmptyView
  Widget _noDataView() {
    return const Center(child: CustomText(text: '登録された支払い元データがありません'));
  }

  /// 支払い元リスト
  Widget _paymentSourceList(List<PaymentSource> paymentSources, WidgetRef ref) {
    return ListView.builder(
      itemCount: paymentSources.length,
      itemBuilder: (context, index) {
        final paymentSource = paymentSources[index];
        return InkWell(
          onTap: () {
            _showUpdatePaymentSourceModal(context, paymentSource);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(left: 20, right: 20, top: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              // 角丸
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // アイコン
                Icon(
                  CupertinoIcons.building_2_fill,
                  color: paymentSource.themaColorEnum.color,
                ),
                const SizedBox(width: 20),

                // 支払い元名
                Expanded(
                  child: CustomText(
                    text: paymentSource.name,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // 削除ボタン
                IconButton(
                  onPressed: () {
                    _showConfirmDeleteAlert(context, ref, paymentSource);
                  },
                  icon: Icon(
                    CupertinoIcons.trash_fill,
                    color: CustomColors.negative,
                  ),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
