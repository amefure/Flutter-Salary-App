import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/app_dialog.dart';
import 'package:salary/core/common/components/payment_icon_view.dart';
import 'package:salary/feature/domain/list_salary/list_salary_view_model.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/domain/input_payment_source/input_payment_source_view.dart';
import 'package:salary/feature/setting/list_payment_source/list_payment_source_view_model.dart';

class ListPaymentSourceScreen extends StatelessWidget {
  const ListPaymentSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: CupertinoNavigationBar(
          middle: const CustomText(
            text: '支払い元一覧',
            fontWeight: FontWeight.bold,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            onPressed: () {
              _showInputPaymentSourceModal(context);
            },
          ),
        ),
        child: const _Body(),
      ),
    );
  }

  /// 支払い元追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const InputPaymentSourceView();
      },
    );
  }
}


/// [ConsumerWidget]でUI更新
class _Body extends ConsumerWidget {
  const _Body();

  /// 支払い元の削除
  void _deletePaymentSource(
    WidgetRef ref,
    PaymentSource paymentSource,
  ) {
    // 削除
    ref.read(listPaymentSourceProvider.notifier).delete(paymentSource);
    // MyData画面のリフレッシュ
    ref.read(chartSalaryProvider.notifier).refresh();
    // Homeリスト画面のリフレッシュ
    ref.read(listSalaryProvider.notifier).refresh();
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
    final paymentSources = ref.watch(listPaymentSourceProvider.select((s) => s.paymentSources));
    return SafeArea(
      child: paymentSources.isEmpty
          ? _noDataView()
          : _paymentSourceList(paymentSources, ref),
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
        final viewModel = ref.read(listPaymentSourceProvider.notifier);

        /// アイテムの開閉状態を取得
        final expandedStates = ref.watch(listPaymentSourceProvider.select((s) => s.expandedMap));
        bool isExpanded = expandedStates[paymentSource.id] ?? false;

        return InkWell(
          onTap: () {
            _showUpdatePaymentSourceModal(context, paymentSource);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(left: 20, right: 20, top: 1),
            decoration: BoxDecoration(
              color: CustomColors.background(context),
              // 角丸
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // アイコン
                PaymentIconView(paymentSource: paymentSource),

                const SizedBox(width: 20),

                // 名前 + メモ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 名前は常に表示
                      CustomText(
                        text: paymentSource.name,
                        fontWeight: FontWeight.bold,
                      ),

                      // メモと開閉アイコン
                      if (paymentSource.memo != null && paymentSource.memo!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: paymentSource.memo!,
                                  color: CustomColors.text(context).withAlpha(80),
                                  maxLines: isExpanded ? null : 1,
                                ),
                              ),
                              // 開閉アイコン
                              GestureDetector(
                                onTap: () {
                                  viewModel.updateExpanded(paymentSource.id, isExpanded);
                                },
                                child: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 20,
                                  color: CustomColors.text(context).withAlpha(80),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 削除ボタン
                IconButton(
                  onPressed: () async {
                    final result = await AppDialog.show(
                      context: context,
                      message: '「${paymentSource.name}」を本当に削除しますか？',
                      type: DialogType.confirm,
                      positiveTitle: '削除',
                      isPositiveNegativeType: true
                    );
                    if (result ?? false) {
                      _deletePaymentSource(ref, paymentSource);
                    }
                  },
                  icon: const Icon(
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