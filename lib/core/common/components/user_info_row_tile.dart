import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';
import 'package:salary/core/config/profile_config.dart';

/// ユーザー情報表示用のタイルView
class UserInfoRowTile extends StatelessWidget {
  final String value;
  final String title;
  final Function() onTap;

  const UserInfoRowTile({
    super.key,
    required this.value,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        if (value == ProfileConfig.undefined)
          const Icon(
            CupertinoIcons.check_mark_circled,
            size: 28,
          ),

        if (value != ProfileConfig.undefined)
          const Icon(
            CupertinoIcons.check_mark_circled_solid,
            size: 28,
          ),

        const SizedBox(width: 8),

        CustomText(
          text: title,
          fontWeight: FontWeight.bold,
        ),

        const Spacer(),

        TextButton(
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: 140,
            decoration: BoxDecoration(
              color: value == ProfileConfig.undefined ? ThemaColor.gray.color : ThemaColor.blue.color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                CustomText(
                  text: value,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  textSize: TextSize.S,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),

      ],
    );
  }
}