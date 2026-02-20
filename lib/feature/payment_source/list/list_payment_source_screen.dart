import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/app_dialog.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/payment_source/input/input_payment_source_view.dart';
import 'package:salary/feature/payment_source/list/list_payment_source_view_model.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

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
          trailing: Consumer(
              builder: (context, ref, _) {
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
                  onPressed: () {
                    _showInputPaymentSourceModal(context, ref);
                  },
                );
              }
          ),
        ),
        child: const _Body(),
      ),
    );
  }

  /// 支払い元追加画面を表示
  Future<void> _showInputPaymentSourceModal(
      BuildContext context,
      WidgetRef ref
      ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const InputPaymentSourceView();
      },
    );

    /// 保存された場合のみ更新
    if (result == true) {
      ref.read(listPaymentSourceProvider.notifier).fetchAll();
    }
  }
}


/// [ConsumerWidget]でUI更新
class _Body extends ConsumerWidget {
  const _Body();
  /// 支払い元更新画面を表示
  Future<void> _showUpdatePaymentSourceModal(
      BuildContext context,
      PaymentSource paymentSource,
      WidgetRef ref
  ) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return InputPaymentSourceView(paymentSource: paymentSource);
      },
    );
    /// 保存された場合のみ更新
    if (result == true) {
      ref.read(listPaymentSourceProvider.notifier).fetchAll();
    }
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
            _showUpdatePaymentSourceModal(context, paymentSource, ref);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomColors.background(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                  CupertinoColors.systemGrey.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// アイコン
                PaymentIconWrapView(paymentSource: paymentSource),

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
                _DeleteButton(paymentSource: paymentSource, ref: ref)
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeleteButton extends StatefulWidget {
  const _DeleteButton({
    required this.paymentSource,
    required this.ref,
  });

  final PaymentSource paymentSource;
  final WidgetRef ref;

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool isPressed = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: () async {
        final result = await AppDialog.show(
          context: context,
          message:
          '「${widget.paymentSource.name}」を本当に削除しますか？',
          type: DialogType.confirm,
          positiveTitle: '削除',
          isPositiveNegativeType: true,
        );

        if (result ?? false) {
          _deletePaymentSource(
              widget.ref, widget.paymentSource);
        }
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: isPressed ? 0.9 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPressed
                ? CustomColors.negative.withAlpha(40)
                : CustomColors.negative.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.trash_fill,
            size: 18,
            color: CustomColors.negative,
          ),
        ),
      ),
    );
  }
}
