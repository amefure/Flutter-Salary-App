import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/view/bar_chart_yearly_view.dart';
import 'package:salary/charts/view/chart_mode_switcher.dart';
import 'package:salary/charts/view/switch_charts_view.dart';
import 'package:salary/charts/view/table_salary_info_view.dart';
import 'package:salary/common/components/ad_banner_widget.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/common/components/payment_icon_view.dart';
import 'package:salary/common/components/payment_source_label_view.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/common/components/custom_label_view.dart';
import 'package:salary/charts/chart_salary_view_model.dart';

class ChartSalaryScreen extends StatelessWidget {
  const ChartSalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final screen = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: 'MyData',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: [
                      SizedBox(width: screen.width),

                      // 支払い元選択UI
                      SizedBox(
                        width: screen.width * 0.5,
                        child: const _SourceSelector(),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                          width: screen.width * 0.95,
                          child: const CustomLabelView(labelText: '月別合計金額')
                      ),

                      const SizedBox(height: 8),

                      // グラフモード切り替えスイッチ
                      SizedBox(
                        width: screen.width ,
                        child: const ChartModeSwitcher(),
                      ),

                      const SizedBox(height: 8),

                      // 月ごとの給料グラフ
                      SizedBox(
                        width: screen.width * 0.95,
                        child: const SwitchChartsView(),
                      ),

                      const _YearSelector(),

                      const SizedBox(height: 20),

                      SizedBox(
                          width: screen.width * 0.9,
                          child: const TableSalaryInfoView()
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                          width: screen.width * 0.95,
                          child: const CustomLabelView(labelText: '年別合計金額(10年間)')
                      ),

                      const SizedBox(height: 8),

                      // 年ごとの給料グラフ(過去10年分)
                      SizedBox(
                        width: screen.width * 0.95,
                        child: const BarChartYearlyView(),
                      ),

                      const SizedBox(height: 20),

                    ]
                ),
              ),
            ),
            const AdMobBannerWidget(),
          ]
      ),
    );
  }
}


/// 給与の支払い元を選択(MenuAnchor)
class _SourceSelector extends ConsumerWidget {

  const _SourceSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartSalaryProvider);
    final notifier = ref.read(chartSalaryProvider.notifier);

    return MenuAnchor(
      builder: (_, controller, __) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: PaymentSourceLabelView(
            paymentSource: state.selectedSource,
            isShowChevronDown: true,
          ),
        );
      },
      menuChildren: state.sourceList.map((source) {
        return MenuItemButton(
          onPressed: () => notifier.changeSource(source),
          child: SizedBox(
            width: 200,
            child: Row(
              children: [
                PaymentIconView(paymentSource: source),
                const SizedBox(width: 8),
                Expanded(child: CustomText(text: source.name, fontWeight: FontWeight.bold)),
                if (state.selectedSource == source)
                  const Icon(CupertinoIcons.checkmark_alt),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 年月選択
class _YearSelector extends ConsumerWidget {
  const _YearSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(chartSalaryProvider.notifier);
    final selectedYear = ref.watch(chartSalaryProvider.select((s) => s.selectedYear));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => notifier.changeYear(-1),
        ),
        CustomText(
          text: '$selectedYear年 1月 〜 12月',
          fontWeight: FontWeight.bold,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.chevron_forward),
          onPressed: () => notifier.changeYear(1),
        ),
      ],
    );
  }
}