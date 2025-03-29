import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/input/input_payment_source.dart';

class ListPaymentSourceView extends StatefulWidget {
  const ListPaymentSourceView({super.key});

  @override
  State<ListPaymentSourceView> createState() => _ListPaymentSourceViewState();
}

class _ListPaymentSourceViewState extends State<ListPaymentSourceView> {
  /// 削除確認ダイアログ
  void _showConfirmDeleteAlert(
    BuildContext context,
    PaymentSource paymentSource,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text("確認"),
          content: Text("「" + paymentSource.name + "」を本当に削除しますか？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text("キャンセル"),
            ),
            TextButton(
              onPressed: () {
                _deletePaymentSource(dialogContext, paymentSource);
              },
              child: CustomText(
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

  void _deletePaymentSource(
    BuildContext dialogContext,
    PaymentSource paymentSource,
  ) {
    setState(() {});
    // 削除処理
    context.read<PaymentSourceViewModel>().delete(paymentSource);
    // ダイアログを閉じる(コンテキストが異なるので注意)
    Navigator.of(dialogContext).pop();
  }

  // 金額詳細アイテム追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return InputPaymentSourceView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: Consumer<PaymentSourceViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.paymentSources.isEmpty) {
                return Center(child: Text('登録された支払い元データがありません'));
              }
              return ListView.builder(
                itemCount: viewModel.paymentSources.length,
                itemBuilder: (context, index) {
                  final paymentSources = viewModel.paymentSources[index];
                  return InkWell(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   CupertinoPageRoute(
                      //     builder: (context) => DetailSalaryView(salary: salary),
                      //   ),
                      // );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: 20, right: 20, top: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // 角丸
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.building_2_fill),
                          SizedBox(width: 20),

                          Expanded(
                            child: CustomText(text: paymentSources.name),
                          ),

                          IconButton(
                            onPressed: () {
                              _showConfirmDeleteAlert(context, paymentSources);
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
            },
          ),
        ),
      ),
    );
  }
}
