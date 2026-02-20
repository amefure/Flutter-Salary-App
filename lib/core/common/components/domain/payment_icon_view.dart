import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';

/// PaymentSourceのアイコンを薄いレイヤーでラップしたUI
class PaymentIconWrapView extends StatelessWidget {
  const PaymentIconWrapView({
    super.key,
    required this.paymentSource,
  });
  final PaymentSource paymentSource;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CustomColors.themaBlue.withAlpha(20),
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: PaymentIconView(
          paymentSource: paymentSource,
        ),
      );
  }
}

/// PaymentSourceのアイコン
class PaymentIconView extends StatelessWidget {

  const PaymentIconView({
    super.key,
    required this.paymentSource,
    this.isWhiteColor = false,
  });
  final PaymentSource paymentSource;
  /// アイコンを強制的に白色にするフラグ
  final bool isWhiteColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          CupertinoIcons.building_2_fill,
          color: isWhiteColor ? Colors.white : paymentSource.themaColorEnum.color,
          size: 28,
        ),

        // 本業フラグが true のときだけ表示
        if (paymentSource.isMain)
          const Positioned(
            top: -6,
            right: -6,
            child: Icon(
              Icons.star,
              size: 14,
              color: Colors.amber,
            ),
          ),
      ],
    );
  }
}