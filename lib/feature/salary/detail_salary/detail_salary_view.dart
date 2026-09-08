import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/core/common/components/domain/attribute_tag.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/common/components/domain/payment_source_label_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_state.dart';
import 'package:salary/feature/salary/detail_salary/domain/salary_comparison.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_view_model.dart';
import 'package:salary/feature/salary/input_salary/input_salary_view.dart';

class DetailSalaryView extends ConsumerWidget {
  const DetailSalaryView({
    super.key,
    required this.id,
    required this.isPublic,
    this.jobName,
  });

  final String id;
  final bool isPublic;
  final String? jobName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detailSalaryProvider(
      DetailSalaryArgsData(id: id, isPublic: isPublic),
    );
    final state = ref.watch(provider);
    String title = DateTimeUtils.format(
      dateTime: state.salary?.createdAt ?? DateTime.now(),
    );
    if (state.salary?.isBonus ?? false) {
      title = '$title(賞)';
    }

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: CupertinoNavigationBar(
        middle: CustomText(text: title, fontWeight: FontWeight.bold),
        backgroundColor: CustomColors.foundation(context),
        trailing:
            !isPublic
                ? _controlButtonContainer(context, ref, state)
                : const SizedBox.shrink(),
      ),
      child: _Body(state: state, isPublic: isPublic, jobName: jobName),
    );
  }

  /// 削除 & 編集ボタン
  Widget _controlButtonContainer(
    BuildContext context,
    WidgetRef ref,
    DetailSalaryState state,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // nullでないなら
            if (state.salary case Salary salary) {
              _showDeleteConfirmDialog(context, ref, salary);
            }
          },
          child: const Icon(
            CupertinoIcons.trash_circle_fill,
            size: 28,
            color: CustomColors.negative,
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (state.salary case Salary salary) {
              _editSalary(context, salary);
            }
          },
          child: const Icon(CupertinoIcons.pencil_circle_fill, size: 28),
        ),
      ],
    );
  }

  /// エラーダイアログを表示
  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Salary salary,
  ) async {
    final result = await AppDialog.show(
      context: context,
      message: '給料情報を本当に削除しますか？',
      type: DialogType.confirm,
      positiveTitle: '削除',
      isPositiveNegativeType: true,
    );
    if (result ?? false) {
      _deleteSalary(context, ref, salary);
    }
  }

  void _deleteSalary(BuildContext context, WidgetRef ref, Salary salary) async {
    // 削除処理を実行
    final result = await ref
        .read(
          detailSalaryProvider(
            DetailSalaryArgsData(id: id, isPublic: isPublic),
          ).notifier,
        )
        .delete(salary);
    if (result) {
      // リスト画面に戻る
      Navigator.of(context).pop();
    }
  }

  /// 編集画面表示
  void _editSalary(BuildContext context, Salary salary) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => InputSalaryView(salary: salary)),
    );
  }
}

class _Body extends ConsumerWidget {
  final DetailSalaryState state;
  final bool isPublic;
  final String? jobName;

  const _Body({
    required this.state,
    required this.isPublic,
    required this.jobName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CustomColors.foundation(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    /// ローカルであれば支払い元を表示
                    if (!isPublic)
                      PaymentSourceLabelView(
                        paymentSource: state.salary?.source,
                      ),

                    /// 公開であれば属性タグを表示
                    if (isPublic && jobName != null) ...[
                      AttributeTag(
                        text: jobName!,
                        baseColor: CustomColors.themaOrange,
                      ),
                    ],

                    const Spacer(),

                    Column(
                      children: [
                        const CustomText(
                          text: '支給日',
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          text: DateTimeUtils.format(
                            dateTime: state.salary?.createdAt ?? DateTime.now(),
                            pattern: 'yyyy年M月d日',
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // テーマカラーで色を変えたい場合
                // targetSalary?.source?.themaColorEnum.color ?? ThemaColor.blue.color
                // 給料テーブル
                _buildSalaryTable(
                  context,
                  state.salary,
                  ThemaColor.black.color.withValues(alpha: 0.8),
                ),

                const SizedBox(height: 24),

                if (!isPublic &&
                    state.salary != null &&
                    (ref
                            .watch(premiumFunctionStateProvider)
                            .isPremiumFullUnlocked ||
                        ref
                            .watch(premiumFunctionStateProvider)
                            .isPremiumFeatureUnlocked))
                  _PremiumComparisonSection(
                    salary: state.salary!,
                    comparison: state.comparison,
                  ),

                // MEMO
                if (!isPublic) ...[
                  const CustomLabelView(labelText: 'MEMO'),

                  const SizedBox(height: 10),

                  // MEMO Body
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColors.background(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.comment),
                        const SizedBox(width: 10),

                        CustomText(
                          text: state.salary?.memo ?? '',
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],

                const AdMobBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 給料テーブル
  Widget _buildSalaryTable(
    BuildContext context,
    Salary? targetSalary,
    Color headerColor,
  ) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {0: const FlexColumnWidth(1), 1: const FlexColumnWidth(3)},
      children: [
        _buildTableRow(
          context,
          '総支給額',
          targetSalary?.paymentAmount,
          headerColor,
          isTotal: true,
        ),
        _buildExpandableRow('', targetSalary?.paymentAmountItems),
        _buildTableRow(
          context,
          '控除額',
          targetSalary?.deductionAmount,
          headerColor,
          isTotal: true,
        ),
        _buildExpandableRow('', targetSalary?.deductionAmountItems),
        _buildTableRow(
          context,
          '手取り額',
          targetSalary?.netSalary,
          headerColor,
          isTotal: true,
        ),
      ],
    );
  }

  /// 1行単位のUI
  TableRow _buildTableRow(
    BuildContext context,
    String label,
    int? amount,
    Color headerColor, {
    bool isTotal = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        // ヘッダーカラー
        color: isTotal ? headerColor : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomText(
            text: label,
            textSize: TextSize.M,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.white : CustomColors.text(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: NumberUtils.formatWithComma(amount ?? 0),
                  textSize: TextSize.ML,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? Colors.white : CustomColors.text(context),
                ),

                const SizedBox(width: 3),

                CustomText(
                  text: '円',
                  textSize: TextSize.SS,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? Colors.white : CustomColors.text(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 展開可能な行(項目詳細)
  TableRow _buildExpandableRow(String title, RealmList<AmountItem>? items) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomText(
            text: title,
            textSize: TextSize.S,
            fontWeight: FontWeight.bold,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ExpansionTile(
            // デフォルトを展開状態にする
            initiallyExpanded: true,
            title: const CustomText(
              text: '詳細を見る',
              textSize: TextSize.S,
              fontWeight: FontWeight.bold,
            ),
            children: [
              if (items is RealmList<AmountItem> && items.isNotEmpty)
                for (var item in items) _buildAmountItemRow(item)
              else
                _buildNoItemsMessage(),
            ],
          ),
        ),
      ],
    );
  }

  /// 展開時に表示されるAmountItem行
  Widget _buildAmountItemRow(AmountItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.circle, size: 12),
              const SizedBox(width: 8),
              CustomText(text: item.key, textSize: TextSize.MS),
            ],
          ),

          CustomText(
            text: '${NumberUtils.formatWithComma(item.value)}円',
            textSize: TextSize.MS,
          ),
        ],
      ),
    );
  }

  /// AmountItemが存在しなかった場合のメッセージ
  Widget _buildNoItemsMessage() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.center,
        child: CustomText(
          text: '項目がありません。',
          textSize: TextSize.M,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _PremiumComparisonSection extends StatelessWidget {
  final Salary salary;
  final SalaryComparison? comparison;

  const _PremiumComparisonSection({
    required this.salary,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    final netRate = comparison?.netRate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomLabelView(labelText: 'プレミアム比較'),
        const SizedBox(height: 10),
        _ComparisonPanel(
          title: '手取り率',
          child: CustomText(
            text: netRate == null ? '計算不可' : '${netRate.toStringAsFixed(1)}%',
            textSize: TextSize.L,
            fontWeight: FontWeight.bold,
            color: CustomColors.thema,
          ),
        ),
        const SizedBox(height: 12),
        _ComparisonCard(
          title: '前月比較',
          current: salary,
          target: comparison?.previousMonth,
          onTap:
              comparison?.previousMonth == null
                  ? null
                  : () => _openDetail(context, comparison!.previousMonth!),
        ),
        const SizedBox(height: 10),
        _ComparisonCard(
          title: '前年同月比較',
          current: salary,
          target: comparison?.previousYear,
          onTap:
              comparison?.previousYear == null
                  ? null
                  : () => _openDetail(context, comparison!.previousYear!),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _openDetail(BuildContext context, Salary target) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DetailSalaryView(id: target.id, isPublic: false),
      ),
    );
  }
}

class _ComparisonPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _ComparisonPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [CustomText(text: title, fontWeight: FontWeight.bold), child],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final Salary current;
  final Salary? target;
  final VoidCallback? onTap;

  const _ComparisonCard({
    required this.title,
    required this.current,
    required this.target,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          target == null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: title, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  const CustomText(
                    text: '比較対象なし',
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: title,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text:
                        '${DateTimeUtils.format(dateTime: target!.createdAt)}${target!.isBonus ? ' (賞与)' : ''}',
                    textSize: TextSize.S,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DifferenceValue(
                        label: '総支給',
                        value: current.paymentAmount - target!.paymentAmount,
                      ),
                      _DifferenceValue(
                        label: '控除',
                        value:
                            current.deductionAmount - target!.deductionAmount,
                      ),
                      _DifferenceValue(
                        label: '手取り',
                        value: current.netSalary - target!.netSalary,
                      ),
                    ],
                  ),
                ],
              ),
    );

    return onTap == null
        ? content
        : CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: content,
        );
  }
}

class _DifferenceValue extends StatelessWidget {
  final String label;
  final int value;

  const _DifferenceValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color =
        value > 0
            ? CupertinoColors.activeGreen
            : value < 0
            ? CustomColors.negative
            : CupertinoColors.systemGrey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          textSize: TextSize.S,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 3),
        CustomText(
          text: '${value > 0 ? '+' : ''}${NumberUtils.formatWithComma(value)}円',
          textSize: TextSize.S,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ],
    );
  }
}
