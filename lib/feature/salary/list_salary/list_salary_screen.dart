import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/domain/salary_list_view.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_view.dart';
import 'package:salary/feature/salary/input_salary/input_salary_view.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

class SalaryListScreen extends ConsumerWidget {
  const SalaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final salaries = ref.watch(listSalaryProvider.select((s) => s.salaries));

    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: CupertinoNavigationBar(
          middle: const CustomText(
            text: 'シンプル給料記録',
            fontWeight: FontWeight.bold,
          ),
          leading: const _BuildSourceSelector(),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.add_circled_solid,
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) =>
                  const InputSalaryView(salary: null),
                ),
              );
            },
          ),
        ),

        child: SalaryListView(
          salaries: salaries,
          onTap: (salary) {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) =>
                    DetailSalaryView(id: salary.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// **給与の支払い元を選択するUI (MenuAnchor)**
class _BuildSourceSelector extends ConsumerWidget {

  const _BuildSourceSelector({super.key});

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