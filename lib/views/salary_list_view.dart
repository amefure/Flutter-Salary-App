import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/number_utils.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/text_view.dart';
import 'package:salary/views/input_salary_view.dart';

class SalaryListView extends StatefulWidget {
  const SalaryListView({super.key});

  @override
  State<SalaryListView> createState() => _SalaryListViewState();
}

class _SalaryListViewState extends State<SalaryListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('給料MEMO')),
      body: Consumer<SalaryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.salaries.isEmpty) {
            return Center(child: Text('データがありません'));
          }
          return ListView.builder(
            itemCount: viewModel.salaries.length,
            itemBuilder: (context, index) {
              final salary = viewModel.salaries[index];
              return Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // 角丸
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 年月UI
                    Container(
                      padding: EdgeInsets.all(8),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: CustomColors.thema,
                        // 角丸
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CustomText(
                            text: salary.createdAt.year.toString(),
                            textSize: TextSize.small,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),

                          CustomText(
                            text: salary.createdAt.month.toString() + "月",
                            textSize: TextSize.large,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    // 給料詳細UI
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 総支給
                        Row(
                          children: [
                            CustomText(
                              text: "総支給",
                              textSize: TextSize.small,
                            ),

                            SizedBox(width: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  text: NumberUtils.formatWithComma(
                                    salary.paymentAmount,
                                  ),
                                  textSize: TextSize.large,
                                  color: CustomColors.thema,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(width: 5),

                                CustomText(text: "円", textSize: TextSize.small),
                              ],
                            ),
                          ],
                        ),

                        // 手取り
                        Row(
                          children: [
                            CustomText(text: "手取り", textSize: TextSize.small),

                            SizedBox(width: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  text: NumberUtils.formatWithComma(
                                    salary.netSalary,
                                  ),
                                  textSize: TextSize.large,
                                  color: CustomColors.thema,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(width: 5),

                                CustomText(text: "円", textSize: TextSize.small),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => InputSalaryView()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
