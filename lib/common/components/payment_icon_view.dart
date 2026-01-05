import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/models/salary.dart';

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