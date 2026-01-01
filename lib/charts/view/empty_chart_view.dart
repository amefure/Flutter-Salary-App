import 'package:flutter/cupertino.dart';
import 'package:salary/common/components/custom_text_view.dart';

class EmptyChartView extends StatelessWidget {
  const EmptyChartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const CustomText(
        text: 'データがありません',
        textSize: TextSize.M,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.systemGrey,
      ),
    );
  }
}
