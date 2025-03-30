import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
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

  @override
  void initState() {
    // 最初にコピーしておく
    targetSalary = widget.salary;
    super.initState();
  }

  /// エラーダイアログを表示
  void _showDeleteConfirmDialog(BuildContext context, Salary salary) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text("確認"),
          content: Text("給料情報を本当に削除しますか？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text("キャンセル"),
            ),
            TextButton(
              onPressed: () {
                _deleteSalary(context, dialogContext, salary);
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

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: CupertinoNavigationBar(
        middle: CustomText(text: createdAt, fontWeight: FontWeight.bold),
        backgroundColor: CustomColors.foundation,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _editSalary(widget.salary),
          child: const Icon(CupertinoIcons.pencil_circle_fill, size: 28),
        ),
      ),
      // Scaffold を使うことでスタイルが適用される
      child: Scaffold(
        backgroundColor: CustomColors.foundation,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 支払い元ラベル
                      Container(
                        padding: EdgeInsets.all(10),
                        width: 180,
                        decoration: BoxDecoration(
                          color:
                              targetSalary?.source?.themaColorEnum.color ??
                              ThemaColor.blue.color,
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
                            const SizedBox(width: 8),

                            const Icon(
                              CupertinoIcons.building_2_fill,
                              color: Colors.white,
                            ),

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
                      ),

                      const CustomLabelView(labelText: "総支給額"),
                      CustomText(
                        text: targetSalary?.paymentAmount.toString() ?? "",
                      ),

                      const CustomLabelView(labelText: "控除額"),
                      CustomText(
                        text: targetSalary?.deductionAmount.toString() ?? "",
                      ),

                      const CustomLabelView(labelText: "手取り額"),
                      CustomText(
                        text: targetSalary?.netSalary.toString() ?? "",
                      ),

                      const SizedBox(height: 700),

                      CustomElevatedButton(
                        text: "削除",
                        backgroundColor: CustomColors.negative,
                        onPressed: () {
                          // nullでないなら
                          if (targetSalary case Salary salary) {
                            _showDeleteConfirmDialog(context, salary);
                          }
                        },
                      ),
                      const SizedBox(height: 500),
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
}
