import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/config/profile_config.dart';

/// ユーザー情報表示用のタイルView
class UserInfoRowTile extends StatelessWidget {
  final String value;
  final String title;
  final bool isEdit;
  final Function() onTap;

  const UserInfoRowTile({
    super.key,
    required this.value,
    required this.title,
    this.isEdit = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        /// 非編集モード
        if (!isEdit)
          const Icon(
            CupertinoIcons.profile_circled,
            size: 28,
          ),

        /// 編集モード AND 未設定
        if (value == ProfileConfig.undefined && isEdit)
          const Icon(
            CupertinoIcons.check_mark_circled,
            size: 28,
          ),

        /// 編集モード AND 設定済み
        if (value != ProfileConfig.undefined && isEdit)
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
          onPressed: isEdit ? onTap : () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            constraints: const BoxConstraints(
              minWidth: 140,
            ),
            decoration: BoxDecoration(
              color: value == ProfileConfig.undefined ? ThemaColor.gray.color : ThemaColor.blue.color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: CustomText(
                text: value,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                textSize: TextSize.S,
                maxLines: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}