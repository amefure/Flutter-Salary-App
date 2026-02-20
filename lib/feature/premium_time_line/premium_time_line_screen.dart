
import 'package:flutter/cupertino.dart';
import 'package:salary/core/utils/custom_colors.dart';

class PremiumTimeLineScreen extends StatelessWidget {
  const PremiumTimeLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          /// 🔒 上部アイコン
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColors.themaOrange.withAlpha(20),
            ),
            child: const Icon(
              CupertinoIcons.lock_fill,
              size: 32,
              color: CustomColors.themaOrange,
            ),
          ),
        ]
      )
    );
  }
}