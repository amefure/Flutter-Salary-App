import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/core/common/components/domain/attribute_tag.dart';
import 'package:salary/core/common/components/domain/step_item.dart';
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
import 'package:salary/feature/in_app_purchase/in_app_purchase_screen.dart';
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

                // MEMO
                if (!isPublic) ...[
                  const CustomLabelView(labelText: 'MEMO', icon: CupertinoIcons.chat_bubble_text),

                  const SizedBox(height: 10),

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
                        const Icon(CupertinoIcons.chat_bubble_text, size: 20),
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

                if (!isPublic && state.salary != null) ...[
                  // プレミアムが解放されている場合
                  if (ref.watch(premiumFunctionStateProvider).isPremiumFullUnlocked ||
                      ref.watch(premiumFunctionStateProvider).isPremiumFeatureUnlocked)
                    _PremiumComparisonSection(
                      salary: state.salary!,
                      comparison: state.comparison,
                    )
                  // 解放されていない場合（購入誘導用の StepItem を表示）
                  else ...[
                    const CustomLabelView(labelText: 'プレミアム比較(前月比較 & 前年比較)'),
                    const SizedBox(height: 10),
                    _ModernLockedFeatureCard(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const InAppPurchaseScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],

                const AdMobBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 給料テーブル（モダンなカード＆アコーディオン型に変更）
  Widget _buildSalaryTable(
      BuildContext context,
      Salary? targetSalary,
      Color headerColor,
      ) {
    return Column(
      children: [
        // 1. 総支給額カード
        _ExpandableSectionCard(
          title: '総支給額',
          amount: targetSalary?.paymentAmount,
          items: targetSalary?.paymentAmountItems,
          isTotal: true,
          accentColor: CustomColors.thema,
          itemBuilder: (context, item) => _buildAmountItemRow(context, item),
          noItemsMessage: _buildNoItemsMessage(),
        ),
        const SizedBox(height: 12),
        // 2. 控除額カード
        _ExpandableSectionCard(
          title: '控除額',
          amount: targetSalary?.deductionAmount,
          items: targetSalary?.deductionAmountItems,
          isTotal: true,
          accentColor: CustomColors.negative,
          itemBuilder: (context, item) => _buildAmountItemRow(context, item),
          noItemsMessage: _buildNoItemsMessage(),
        ),
        const SizedBox(height: 12),
        // 3. 手取り額カード
        _buildNetSalaryCard(
          context,
          amount: targetSalary?.netSalary,
        ),
      ],
    );
  }

  /// 手取り額のカード（他のUIとトーンを合わせたモダンデザイン）
  Widget _buildNetSalaryCard(BuildContext context, {required int? amount}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: CustomColors.thema,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const CustomText(
                text: '手取り額',
                textSize: TextSize.MS,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CustomText(
                text: NumberUtils.formatWithComma(amount ?? 0),
                textSize: TextSize.ML,
                fontWeight: FontWeight.bold,
                color: CustomColors.thema,
              ),
              const SizedBox(width: 2),
              const CustomText(
                text: '円',
                textSize: TextSize.SS,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 展開時に表示されるAmountItem行
  Widget _buildAmountItemRow(BuildContext context, AmountItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: item.key,
            textSize: TextSize.S,
            color: CustomColors.text(context),
          ),
          CustomText(
            text: '${NumberUtils.formatWithComma(item.value)}円',
            textSize: TextSize.S,
            fontWeight: FontWeight.w600,
            color: CustomColors.text(context),
          ),
        ],
      ),
    );
  }

  /// AmountItemが存在しなかった場合のメッセージ
  Widget _buildNoItemsMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.center,
        child: CustomText(
          text: '詳細項目はありません',
          textSize: TextSize.S,
          color: CupertinoColors.systemGrey,
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
        const CustomLabelView(labelText: 'プレミアム比較', icon: CupertinoIcons.sparkles),
        const SizedBox(height: 12),
        _ComparisonPanel(
          title: '手取り率',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CustomColors.thema.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomText(
              text: netRate == null ? '計算不可' : '${netRate.toStringAsFixed(1)}%',
              textSize: TextSize.ML,
              fontWeight: FontWeight.bold,
              color: CustomColors.thema,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ComparisonCard(
          title: '前月比較',
          current: salary,
          target: comparison?.previousMonth,
          onTap: comparison?.previousMonth == null
              ? null
              : () => _openDetail(context, comparison!.previousMonth!),
        ),
        const SizedBox(height: 12),
        _ComparisonCard(
          title: '前年同月比較',
          current: salary,
          target: comparison?.previousYear,
          onTap: comparison?.previousYear == null
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: title, fontWeight: FontWeight.bold, textSize: TextSize.MS),
          child,
        ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: target == null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, fontWeight: FontWeight.bold, textSize: TextSize.MS),
          const SizedBox(height: 8),
          const CustomText(
            text: '比較対象のデータがありません',
            textSize: TextSize.S,
            color: CupertinoColors.systemGrey,
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: title, fontWeight: FontWeight.bold, textSize: TextSize.MS),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: CustomText(
                      text: '${DateTimeUtils.format(dateTime: target!.createdAt)}${target!.isBonus ? ' (賞与)' : ''}',
                      textSize: TextSize.SS,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 差分を表示するグリッド風レイアウト
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _DifferenceValue(
                    label: '総支給',
                    value: current.paymentAmount - target!.paymentAmount,
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _DifferenceValue(
                      label: '控除',
                      value: current.deductionAmount - target!.deductionAmount,
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _DifferenceValue(
                      label: '手取り',
                      value: current.netSalary - target!.netSalary,
                    ),
                  ),
                ),
              ],
            ),
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
    final color = value > 0
        ? CupertinoColors.activeGreen
        : value < 0
        ? CustomColors.negative
        : CupertinoColors.systemGrey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          textSize: TextSize.SS,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: CustomText(
            text: '${value > 0 ? '+' : ''}${NumberUtils.formatWithComma(value)}円',
            textSize: TextSize.S,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
/// モダンなプレミアム機能ロック中カード
class _ModernLockedFeatureCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ModernLockedFeatureCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // アプリのテーマカラーや上品なグラデーションを意識した背景
          gradient: LinearGradient(
            colors: [
              CustomColors.thema,
              CustomColors.thema.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CustomColors.thema.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左側のアイコン（王冠やキラキラマーク）
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.sparkles,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // テキスト情報
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'プレミアム機能で詳細比較',
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                  SizedBox(height: 4),
                  CustomText(
                    text: '前月・前年同月との比較や手取り率をチェック',
                    textSize: TextSize.SS,
                    color: CupertinoColors.white,
                  ),
                ],
              ),
            ),
            // 右側の矢印
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// 開閉可能かつ、金額が完全に右端に配置されるセクションカード
/// 開閉アニメーション付きのセクションカード
class _ExpandableSectionCard extends StatefulWidget {
  final String title;
  final int? amount;
  final RealmList<AmountItem>? items;
  final bool isTotal;
  final Color accentColor;
  final Widget Function(BuildContext context, AmountItem item) itemBuilder;
  final Widget noItemsMessage;

  const _ExpandableSectionCard({
    required this.title,
    required this.amount,
    required this.items,
    required this.isTotal,
    required this.accentColor,
    required this.itemBuilder,
    required this.noItemsMessage,
  });

  @override
  State<_ExpandableSectionCard> createState() => _ExpandableSectionCardState();
}

class _ExpandableSectionCardState extends State<_ExpandableSectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 初期状態が true なので、コントローラーを最大（展開）にしておく
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.items is RealmList<AmountItem> && widget.items!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ヘッダー（常時表示、タップでアニメーション開閉）
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左側：カラーバー ＋ タイトル ＋ 回転する矢印アイコン
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        text: widget.title,
                        textSize: TextSize.MS,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 6),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                        child: const Icon(
                          CupertinoIcons.chevron_down,
                          size: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                  // 右側：一番右端にピタッと寄った金額
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      CustomText(
                        text: NumberUtils.formatWithComma(widget.amount ?? 0),
                        textSize: TextSize.ML,
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                      const SizedBox(width: 2),
                      CustomText(
                        text: '円',
                        textSize: TextSize.SS,
                        color: CustomColors.text(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // スムーズに伸縮するコンテンツ部分
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const Divider(height: 1, color: CupertinoColors.systemGrey2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      if (hasItems)
                        ...widget.items!.map((item) => widget.itemBuilder(context, item))
                      else
                        widget.noItemsMessage,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}