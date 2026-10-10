import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/charts/presentation/parts/bar_chart_yearly_view.dart';
import 'package:salary/feature/charts/presentation/parts/chart_mode_switcher.dart';
import 'package:salary/feature/charts/presentation/parts/switch_charts_view.dart';
import 'package:salary/feature/charts/presentation/parts/table_salary_info_view.dart';
import 'package:salary/feature/charts/presentation/parts/annual_target_progress_view.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/common/components/domain/payment_source_label_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';

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
        middle: CustomText(text: 'MyData', fontWeight: FontWeight.bold),
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
                  _ChartSourceSelector(
                    selectedSources: state.selectedSources,
                    sourceList: state.sourceList,
                    onChanged: notifier.changeSource,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: screen.width * 0.95,
                    child: const CustomLabelView(
                      labelText: '月別合計金額',
                      icon: CupertinoIcons.money_yen_circle_fill,
                      size: 25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // グラフモード切り替えスイッチ
                  SizedBox(
                    width: screen.width,
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
                    child: const TableSalaryInfoView(),
                  ),

                  const SizedBox(height: 20),

                  AnnualTargetProgressView(salaries: state.allSalaries),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: screen.width * 0.95,
                    child: const CustomLabelView(
                      labelText: '年別合計金額(5年間)',
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      size: 25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 年ごとの給料グラフ(過去5年分)
                  SizedBox(
                    width: screen.width * 0.95,
                    child: const BarChartYearlyView(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const AdMobBannerWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// Charts画面専用の複数選択UI。共通SourceSelectorの既存利用箇所には影響させない。
class _ChartSourceSelector extends StatelessWidget {
  const _ChartSourceSelector({
    required this.selectedSources,
    required this.sourceList,
    required this.onChanged,
  });

  final List<PaymentSource> selectedSources;
  final List<PaymentSource> sourceList;
  final ValueChanged<PaymentSource> onChanged;

  bool _isSelected(PaymentSource source) {
    return selectedSources.any((selected) => selected.id == source.id);
  }

  @override
  Widget build(BuildContext context) {
    final isAllSelected = _isSelected(DummySource.allDummySource);
    final selectedIndividuals =
        isAllSelected
            ? <PaymentSource>[]
            : selectedSources
                .where((source) => source.id != DummySource.allDummySource.id)
                .toList();
    final labelSource =
        isAllSelected ? DummySource.allDummySource : selectedIndividuals.first;

    return Column(
      children: [
        MenuAnchor(
          builder: (context, controller, child) {
            return GestureDetector(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child:
                  isAllSelected || selectedIndividuals.length == 1
                      ? PaymentSourceLabelView(
                        paymentSource: labelSource,
                        isShowChevronDown: true,
                      )
                      : Container(
                        width: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: labelSource.themaColorEnum.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            PaymentIconView(
                              paymentSource: labelSource,
                              isWhiteColor: true,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomText(
                                text: '${selectedIndividuals.length}件選択中',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                textSize: TextSize.S,
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
            );
          },
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              CustomColors.background(context),
            ),
          ),
          menuChildren: [
            SizedBox(
              width: 280,
              height: 320,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children:
                    sourceList.map((source) {
                      final selected = _isSelected(source);
                      return InkWell(
                        onTap: () => onChanged(source),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (_) => onChanged(source),
                            ),
                            PaymentIconView(paymentSource: source),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomText(
                                text: source.name,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
        if (selectedIndividuals.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children:
                  selectedIndividuals
                      .map(
                        (source) => Chip(
                          label: Text(source.name),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: source.themaColorEnum.color
                              .withValues(alpha: 0.2),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }
}

/// 年月選択
class _YearSelector extends ConsumerWidget {
  const _YearSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(chartSalaryProvider.notifier);
    final selectedYear = ref.watch(
      chartSalaryProvider.select((s) => s.selectedYear),
    );

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
