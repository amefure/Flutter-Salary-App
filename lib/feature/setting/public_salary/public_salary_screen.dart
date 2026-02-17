
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class PublicSalaryScreen extends StatelessWidget {
  const PublicSalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: '給料公開設定',
            fontWeight: FontWeight.bold,
          )
      ),
      child: SafeArea(
        child: Consumer(
            builder: (context, ref, _) {
              return Text('');
            }
        ),
      ),
    );
  }
}