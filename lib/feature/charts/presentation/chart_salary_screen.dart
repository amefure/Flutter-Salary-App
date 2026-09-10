import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/domain/source_selector.dart';
import 'package:salary/feature/charts/presentation/parts/bar_chart_yearly_view.dart';
import 'package:salary/feature/charts/presentation/parts/chart_mode_switcher.dart';
import 'package:salary/feature/charts/presentation/parts/switch_charts_view.dart';
import 'package:salary/feature/charts/presentation/parts/table_salary_info_view.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/common/components/domain/payment_source_label_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';

class ChartSalaryScreen extends ConsumerWidget {
  const ChartSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面サイズを取得
    final screen = MediaQuery.of(context).size;

    final state = ref.watch(chartSalaryProvider);
    final notifier = ref.read(chartSalaryProvider.notifier);
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
                      SourceSelector(
                        selectedSource: state.selectedSource,
                        sourceList: state.sourceList,
                        sourceName: (source) => source?.name ?? '',
                        buildLabelView: (source) => PaymentSourceLabelView(
                          paymentSource: source,
                          isShowChevronDown: true,
                        ),
                        buildIconView: (source) => PaymentIconView(paymentSource: source),
                        onChanged: (source) {
                          if (source != null) {
                            notifier.changeSource(source);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                          width: screen.width * 0.95,
                          child: const CustomLabelView(
                            labelText: '月別合計金額',
                            icon: CupertinoIcons.money_yen_circle_fill,
                            size: 25,
                          )
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
                          child: const CustomLabelView(
                            labelText: '年別合計金額(5年間)',
                            icon: CupertinoIcons.chart_bar_alt_fill,
                            size: 25,
                          )
                      ),

                      const SizedBox(height: 8),

                      // 年ごとの給料グラフ(過去5年分)
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
            const SizedBox(height: 100),
          ]
      ),
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