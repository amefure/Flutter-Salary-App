import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/chart_salary_view_model.dart';

/// グラフ表示モード切り替えスイッチ
class ChartModeSwitcher extends ConsumerWidget {
  const ChartModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = ref.watch(chartSalaryProvider.select((s) => s.displayMode));
    final notifier = ref.read(chartSalaryProvider.notifier);

    return CupertinoSegmentedControl<ChartDisplayMode>(
      groupValue: displayMode,
      onValueChanged: (_) {
        notifier.toggleDisplayMode();
      },
      children: const {
        ChartDisplayMode.line: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Icon(
            Icons.show_chart,
            size: 22,
          ),
        ),
        ChartDisplayMode.pie: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Icon(
            Icons.pie_chart,
            size: 22,
          ),
        ),
      },
    );
  }
}
