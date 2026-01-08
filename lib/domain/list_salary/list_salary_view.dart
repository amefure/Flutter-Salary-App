import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/common/components/ad_banner_widget.dart';
import 'package:salary/common/components/payment_icon_view.dart';
import 'package:salary/domain/list_salary/list_salary_view_model.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/utilities/number_utils.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/domain/detail_salary/detail_salary_view.dart';
import 'package:salary/domain/input_salary/input_salary_view.dart';

class SalaryListScreen extends StatelessWidget {

  const SalaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CupertinoPageScaffold(
            backgroundColor: CustomColors.foundation(context),
            navigationBar: CupertinoNavigationBar(
              middle: const CustomText(
                text: 'シンプル給料記録',
                fontWeight: FontWeight.bold,
              ),
              leading: const BuildSourceSelector(),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const InputSalaryView(salary: null),
                    ),
                  );
                },
              ),
            ),
            child: const SalaryListView()
        )
    );
  }
}


/// **給与の支払い元を選択するUI (MenuAnchor)**
class BuildSourceSelector extends ConsumerWidget {

  const BuildSourceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final sourceList = ref.watch(listSalaryProvider.select((s) => s.sourceList ));
    final selectedSource = ref.watch(listSalaryProvider.select((s) => s.selectedSource ));
    final vm = ref.read(listSalaryProvider.notifier);

    return MenuAnchor(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: const Icon(Icons.filter_list, size: 28),
        );
      },
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((_) {
          return CustomColors.background(context);
        }),
      ),
      menuChildren: sourceList.map((source) {
        return MenuItemButton(
          onPressed: () {
            vm.filterPaymentSource(source);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((_) {
              return CustomColors.background(context);
            }),
          ),
          child: SizedBox(
            width: 200,
            child: Row(
              children: [
                // アイコン
                PaymentIconView(paymentSource: source),

                const SizedBox(width: 8),

                Expanded(child: CustomText(text: source.name, fontWeight: FontWeight.bold)),

                if (source == selectedSource)
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CustomColors.text(context),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SalaryListView extends ConsumerWidget {

  const SalaryListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaries = ref.watch(listSalaryProvider.select((s) => s.salaries));
    if (salaries.isEmpty) {
      return const Center(
          child: CustomText(
            text: 'データがありません',
            fontWeight: FontWeight.bold,
          )
      );
    }
    return Column(
      children: [
        Expanded(child: ListView.builder(
          itemCount: salaries.length,
          itemBuilder: (context, index) {
            final salary = salaries[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => DetailSalaryView(id: salary.id),
                  ),
                );
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
                            text: '${salary.createdAt.year}年',
                            textSize: TextSize.S,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),

                          CustomText(
                            text: !salary.isBonus ? '${salary.createdAt.month}月' :  '${salary.createdAt.month}月(賞)',
                            textSize: !salary.isBonus ? TextSize.ML :  TextSize.SS,
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

                          Row(
                              children: [

                                // 本業フラグが true のときだけ表示
                                if (salary.source?.isMain ?? false)
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),

                                CustomText(
                                  text: switch (salary.source?.name) {
                                    String name => name,
                                    _ => '未設定',
                                  },
                                  textSize: TextSize.S,
                                  color: CustomColors.text(context).withValues(alpha: 0.7),
                                ),
                              ]),
                          // 給料詳細UI
                          // 総支給
                          _buildSalaryRow('総支給', salary.paymentAmount),
                          // 手取り
                          _buildSalaryRow('手取り', salary.netSalary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )),

        const AdMobBannerWidget(),
      ],
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
            const CustomText(text: '円', textSize: TextSize.S),
          ],
        ),
      ],
    );
  }
}