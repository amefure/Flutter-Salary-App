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
          leading: const _SalaryDisplayOptionsButton(),
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
                    DetailSalaryView(id: salary.id, isPublic: false),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 給与一覧の表示オプション（並べ替え・絞り込み）を制御するメニューボタン
class _SalaryDisplayOptionsButton extends ConsumerWidget {
  const _SalaryDisplayOptionsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceList = ref.watch(listSalaryProvider.select((s) => s.sourceList));
    final selectedSource = ref.watch(listSalaryProvider.select((s) => s.selectedSource));
    // 現在の並び順を取得
    final currentSort = ref.watch(listSalaryProvider.select((s) => s.sortOrder));
    final vm = ref.read(listSalaryProvider.notifier);

    return MenuAnchor(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
          child: const Icon(CupertinoIcons.slider_horizontal_3, size: 26),
        );
      },
      menuChildren: [
        /// セクション1: 並べ替え
        const _MenuHeader(title: '並べ替え'),
        ...SalarySortOrder.values.map((order) {
          return MenuItemButton(
            onPressed: () => vm.updateSortOrder(order),
            child: _MenuLabelWithCheck(
              label: order.label,
              isSelected: order == currentSort,
            ),
          );
        }),

        const Divider(height: 1),

        /// セクション1: 支払い元で絞り込み
        const _MenuHeader(title: '支払い元で絞り込み'),
        ...sourceList.map((source) {
          return MenuItemButton(
            onPressed: () => vm.filterPaymentSource(source),
            child: Row(
              children: [
                PaymentIconView(paymentSource: source),
                const SizedBox(width: 8),
                _MenuLabelWithCheck(
                  label: source.name,
                  isSelected: source == selectedSource,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final String title;
  const _MenuHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CustomText(
        text: title.toUpperCase(),
        textSize: TextSize.S,
        color: CustomColors.text(context).withAlpha(122),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MenuLabelWithCheck extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _MenuLabelWithCheck({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      constraints: const BoxConstraints(minWidth: 220), // 少し幅を広げる
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              text: label,
              textSize: TextSize.M,
              fontWeight: FontWeight.bold,
              color: isSelected ? CustomColors.themaBlue : null,
            ),
          ),

          if (isSelected)
            const Icon(
              CupertinoIcons.checkmark,
              size: 18,
              color: CustomColors.themaBlue,
            ),
        ],
      ),
    );
  }
}