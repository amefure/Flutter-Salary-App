import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_text_view.dart';

class DetailSalaryView extends StatefulWidget {
  const DetailSalaryView({super.key, required this.salary});

  final Salary salary;

  @override
  State<DetailSalaryView> createState() => _DetailSalaryViewState();
}

class _DetailSalaryViewState extends State<DetailSalaryView> {
  /// この画面で表示対象のSalary
  /// initStateでDetailSalaryViewから受けっとったものをコピーしておく
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
                color: CustomColors.thema,
                textSize: TextSize.MS,
              ),
            ),
          ],
        );
      },
    );
  }

  void _editSalary() {
    // 編集処理（モーダルを開く or 画面遷移）
    print("編集ボタンが押されました");
    Navigator.of(context).pop();
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
          onPressed: _editSalary,
          child: const Icon(CupertinoIcons.pencil_circle_fill, size: 28),
        ),
      ),
      // Scaffold を使うことでスタイルが適用される
      child: Scaffold(
        backgroundColor: CustomColors.foundation,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width),

                CustomText(text: targetSalary?.netSalary.toString() ?? ""),

                const SizedBox(height: 700), 

                CustomElevatedButton(
                  text: "削除",
                  onPressed: () {
                    // nullでないなら
                    if (targetSalary case Salary salary) {
                      _showDeleteConfirmDialog(context, salary);
                    }
                  },
                ),
                const SizedBox(height: 500), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
