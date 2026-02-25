import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/empty_state_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class EmptyChartView extends StatelessWidget {
  const EmptyChartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(10),

      alignment: Alignment.center,
      child: const EmptyStateView(
        message: '給料データがありません',
        icon: CupertinoIcons.cube,
      ),
    );
  }
}
