import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/utilitys/number_utils.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_label_view.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/input/input_salary_view.dart';

class DetailSalaryView extends StatefulWidget {
  const DetailSalaryView({super.key, required this.salary});

  final Salary salary;

  @override
  State<DetailSalaryView> createState() => _DetailSalaryViewState();
}

class _DetailSalaryViewState extends State<DetailSalaryView> {
  /// この画面で表示対象のSalary
  /// initStateでDetailSalaryViewから受けとったものをコピーしておく
  /// 削除前にnullにしてsetStateをしないと画面が真っ赤でエラーになる
  Salary? targetSalary;

  final _memoController = TextEditingController();

  @override
  void initState() {
    // 最初にコピーしておく
    targetSalary = widget.salary;
    _memoController.text = targetSalary?.memo ?? "";
    super.initState();
  }

  /// エラーダイアログを表示
  void _showDeleteConfirmDialog(BuildContext context, Salary salary) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("確認"),
          content: const Text("給料情報を本当に削除しますか？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("キャンセル"),
            ),
            TextButton(
              onPressed: () {
                _deleteSalary(context, dialogContext, salary);
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

  /// 編集画面表示
  void _editSalary(Salary salary) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => InputSalaryView(salary: salary)),
    );
  }

  void _deleteSalary(
    BuildContext context,
    BuildContext dialogContext,
    Salary salary,
  ) {
    // 削除前にnullにして画面を更新
    targetSalary = null;
    setState(() {});
    // 削除処理
    context.read<SalaryViewModel>().delete(salary);
    // ダイアログを閉じる(コンテキストが異なるので注意)
    Navigator.of(dialogContext).pop();
    // リスト画面に戻る(コンテキストが異なるので注意)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String createdAt = DateTimeUtils.format(
      dateTime: targetSalary?.createdAt ?? DateTime.now(),
    );

    String createdAtDay = DateTimeUtils.format(
      dateTime: targetSalary?.createdAt ?? DateTime.now(),
      pattern: "yyyy年M月d日",
    );

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: CupertinoNavigationBar(
        middle: CustomText(text: createdAt, fontWeight: FontWeight.bold),
        backgroundColor: CustomColors.foundation,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // nullでないなら
                if (targetSalary case Salary salary) {
                  _showDeleteConfirmDialog(context, salary);
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
                if (targetSalary case Salary salary) {
                  _editSalary(salary);
                }
              },
              child: const Icon(CupertinoIcons.pencil_circle_fill, size: 28),
            ),
          ],
        ),
      ),
      // Scaffold を使うことでスタイルが適用される
      child: Scaffold(
        backgroundColor: CustomColors.foundation,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Consumer2<SalaryViewModel, PaymentSourceViewModel>(
                builder: (
                  context,
                  salaryViewModel,
                  paymentSourceViewModel,
                  child,
                ) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          // 支払い元ラベル
                          _sourceLabel(),
                          const Spacer(),

                          Column(
                            children: [
                              const CustomText(text: "支払い日"),
                              CustomText(text: createdAtDay),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // テーマカラーで色を変えたい場合
                      // targetSalary?.source?.themaColorEnum.color ?? ThemaColor.blue.color
                      // 給料テーブル
                      _buildSalaryTable(ThemaColor.black.color),

                      const SizedBox(height: 24),


                      // MEMO
                      const CustomLabelView(labelText: "MEMO"),
                      const SizedBox(height: 10),
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
                              text: targetSalary?.memo ?? "",
                              maxLines: null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 支払い元UIラベル
  Widget _sourceLabel() {
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
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.building_2_fill, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: targetSalary?.source?.name ?? "未設定",
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
  Widget _buildSalaryTable(Color headerColor) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
      children: [
        _buildTableRow(
          "総支給額",
          targetSalary?.paymentAmount,
          headerColor,
          isTotal: true,
        ),
        _buildExpandableRow("支給項目詳細", targetSalary?.paymentAmountItems),
        _buildTableRow(
          "控除額",
          targetSalary?.deductionAmount,
          headerColor,
          isTotal: true,
        ),
        _buildExpandableRow("控除項目詳細", targetSalary?.deductionAmountItems),
        _buildTableRow(
          "手取り額",
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
                  text: "円",
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
            title: const CustomText(
              text: "詳細を見る",
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
      padding: EdgeInsets.all(4.0),
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
                text: "${NumberUtils.formatWithComma(item.value)}円",
                textSize: TextSize.MS
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AmountItemが存在しなかった場合のメッセージ
  Widget _buildNoItemsMessage() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.center,
        child: CustomText(
          text: "項目がありません。",
          textSize: TextSize.M,
          color: Colors.grey,
        ),
      ),
    );
  }
}
