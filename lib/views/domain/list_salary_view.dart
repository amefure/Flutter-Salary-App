import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/number_utils.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/detail_salary_view.dart';
import 'package:salary/views/domain/input/input_salary_view.dart';

class SalaryListView extends StatefulWidget {
  const SalaryListView({super.key});

  @override
  State<SalaryListView> createState() => _SalaryListViewState();
}

class _SalaryListViewState extends State<SalaryListView> {
  @override
  Widget build(BuildContext context) {
    // Scaffold配下にCupertinoPageScaffold(iOS UI)を設置しないと
    // Textのスタイルが黄色い下線になってしまう
    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('給料MEMO'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => InputSalaryView(salary: null),
                ),
              );
            },
          ),
        ),
        child: Consumer2<SalaryViewModel, PaymentSourceViewModel>(
          builder: (context, salaryViewModel, paymentSourceViewModel, child) {
            if (salaryViewModel.salaries.isEmpty) {
              return Center(child: Text('データがありません'));
            }
            return ListView.builder(
              itemCount: salaryViewModel.salaries.length,
              itemBuilder: (context, index) {
                final salary = salaryViewModel.salaries[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => DetailSalaryView(salary: salary),
                      ),
                    );
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 年月UI
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color:
                                salary.source?.themaColorEnum.color ??
                                CustomColors.thema,
                            // 角丸
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: salary.createdAt.year.toString() + "年",
                                textSize: TextSize.S,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),

                              CustomText(
                                text: salary.createdAt.month.toString() + "月",
                                textSize: TextSize.ML,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: switch (salary.source?.name) {
                                  String name => name,
                                  _ => "未設定",
                                },
                                textSize: TextSize.S,
                                color: CustomColors.text.withValues(alpha: 0.7),
                              ),
                              // 給料詳細UI
                              // 総支給
                              _buildSalaryRow("総支給", salary.paymentAmount),
                              // 手取り
                              _buildSalaryRow("手取り", salary.netSalary),
                            ],
                          ),
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
    );
  }

  /// ラベルと金額表示UI
  Widget _buildSalaryRow(String label, int amount) {
    return Row(
      children: [
        const Spacer(),
        CustomText(text: label, textSize: TextSize.S),
        const SizedBox(width: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: NumberUtils.formatWithComma(amount),
              textSize: TextSize.L,
              color: CustomColors.thema,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(width: 5),
            const CustomText(text: "円", textSize: TextSize.S),
          ],
        ),
      ],
    );
  }
}
