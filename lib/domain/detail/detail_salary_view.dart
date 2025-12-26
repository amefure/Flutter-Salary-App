import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/domain/detail/detail_salary_state.dart';
import 'package:salary/domain/detail/detail_salary_view_model.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/utilities/date_time_utils.dart';
import 'package:salary/utilities/number_utils.dart';
import 'package:salary/viewmodels/reverpod/salary_notifier.dart';
import 'package:salary/common/components/ad_banner_widget.dart';
import 'package:salary/common/components/custom_label_view.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/domain/input/input_salary_view.dart';

class DetailSalaryView extends ConsumerWidget {
  const DetailSalaryView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailSalaryProvider(id));
    String title = DateTimeUtils.format(
      dateTime: state.salary?.createdAt ?? DateTime.now(),
    );
    if (state.salary?.isBonus ?? false) {
      title = '$title(賞)';
    }

    return CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle: CustomText(
            text: title,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: CustomColors.foundation,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(builder: (_, ref, _) {
                return CupertinoButton(
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
                );
              }),
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
          ),
        ),
        child: _Body(state: state)
    );
  }

  /// エラーダイアログを表示
  void _showDeleteConfirmDialog(
      BuildContext context,
      WidgetRef ref,
      Salary salary,
      ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('確認'),
          content: const Text('給料情報を本当に削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _deleteSalary(context, dialogContext, ref, salary);
              },
              child: const CustomText(
                text: '削除',
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

  void _deleteSalary(
      BuildContext context,
      BuildContext dialogContext,
      WidgetRef ref,
      Salary salary,
      ) {
    // 削除前にnullにして画面を更新
    ref.read(detailSalaryProvider(id).notifier).resetSalary();
    // 削除処理
    ref.read(salaryProvider.notifier).delete(salary);
    // MyData画面のリフレッシュ
    ref.read(chartSalaryProvider.notifier).refresh();
    // ダイアログを閉じる(コンテキストが異なるので注意)
    Navigator.of(dialogContext).pop();
    // リスト画面に戻る(コンテキストが異なるので注意)
    Navigator.of(context).pop();
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

  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Scaffold を使うことでスタイルが適用される
    return Scaffold(
        backgroundColor: CustomColors.foundation,
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
                            // 支払い元ラベル
                            _sourceLabel(state.salary),
                            const Spacer(),

                            Column(
                              children: [
                                const CustomText(
                                  text: '支給日',
                                  fontWeight: FontWeight.bold,
                                ),
                                CustomText(
                                  text: DateTimeUtils.format(
                                    dateTime:
                                    state.salary?.createdAt ?? DateTime.now(),
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
                          state.salary,
                          ThemaColor.black.color.withValues(alpha: 0.8),
                        ),

                        const SizedBox(height: 24),

                        // MEMO
                        const CustomLabelView(labelText: 'MEMO'),

                        const SizedBox(height: 10),
                        // MEMO Body
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white, // 背景色
                            borderRadius: BorderRadius.circular(8), // 角丸
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.comment),
                              const SizedBox(width: 10), // アイコンとテキストの間隔

                              CustomText(
                                text: state.salary?.memo ?? '',
                                maxLines: null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        const AdMobBannerWidget(),
                      ],
                    )
                )
            )
        )
    );
  }

  /// 支払い元UIラベル
  Widget _sourceLabel(
      Salary? targetSalary,
      ) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 180,
      decoration: BoxDecoration(
        color:
        targetSalary?.source?.themaColorEnum.color ?? ThemaColor.blue.color,
        // 角丸
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // 影
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.building_2_fill, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: targetSalary?.source?.name ?? '未設定',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              textSize: TextSize.S,
            ),
          ),
        ],
      ),
    );
  }

  /// 給料テーブル
  Widget _buildSalaryTable(Salary? targetSalary, Color headerColor) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {0: const FlexColumnWidth(1), 1: const FlexColumnWidth(3)},
      children: [
        _buildTableRow(
          '総支給額',
          targetSalary?.paymentAmount,
          headerColor,
          isTotal: true,
        ),
        _buildExpandableRow('', targetSalary?.paymentAmountItems),
        _buildTableRow(
          '控除額',
          targetSalary?.deductionAmount,
          headerColor,
          isTotal: true,
        ),
        _buildExpandableRow('', targetSalary?.deductionAmountItems),
        _buildTableRow(
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
            color: isTotal ? Colors.white : CustomColors.text,
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
                  color: isTotal ? Colors.white : CustomColors.text,
                ),

                const SizedBox(width: 3),

                CustomText(
                  text: '円',
                  textSize: TextSize.SS,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? Colors.white : CustomColors.text,
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
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          // ⚪︎ アイコン
          const Icon(CupertinoIcons.circle, size: 15),
          const SizedBox(width: 5),
          // 項目名
          Expanded(child: CustomText(text: item.key, textSize: TextSize.MS)),
          // 金額
          Expanded(
            child: Align(
              alignment: Alignment.centerRight, // 右寄せ
              child: CustomText(
                text: '${NumberUtils.formatWithComma(item.value)}円',
                textSize: TextSize.MS,
              ),
            ),
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
