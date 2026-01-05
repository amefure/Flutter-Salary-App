import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/common/components/payment_icon_view.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';

/// 支払い元UIラベル
class PaymentSourceLabelView extends ConsumerWidget {
  final PaymentSource? paymentSource;
  final bool isShowChevronDown;

  const PaymentSourceLabelView({
    super.key,
    required this.paymentSource,
    this.isShowChevronDown = false
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      padding: const EdgeInsets.all(10),
      width: 180,
      decoration: BoxDecoration(
        color: paymentSource?.themaColorEnum.color ?? ThemaColor.blue.color,
        // 角丸
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // 影
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
          if (paymentSource != null)
            // アイコン白色
            PaymentIconView(paymentSource: paymentSource!, isWhiteColor: true),

          if (paymentSource == null)
            const Icon(CupertinoIcons.building_2_fill, color: Colors.white),

          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: paymentSource?.name ?? '未設定',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              textSize: TextSize.S,
            ),
          ),

          if (isShowChevronDown)
            const Icon(CupertinoIcons.chevron_down, color: Colors.white),
        ],
      ),
    );
  }
}