import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/user_info/user_info_view_model.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: 'アカウント情報',
            fontWeight: FontWeight.bold,
          )
      ),
      child: const SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: _BodyWidget()
          )
      ),
    );
  }
}

class _BodyWidget extends ConsumerStatefulWidget {
  const _BodyWidget();

  @override
  ConsumerState<_BodyWidget> createState() => _Body();
}

class _Body extends ConsumerState<_BodyWidget> {

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userInfoProvider);
    final viewModel = ref.read(userInfoProvider.notifier);
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [
          CustomText(text: state.name),

          CustomText(text: state.email),

          /// 都道府県
          _rowTile(
            title: '都道府県',
            value: state.region,
            onTap: () =>
                _showPrefecturePicker(
                  context,
                  state.region,
                  viewModel.updateRegion,
                ),
          ),

          /// 生年月日
          _rowTile(
              title: '生年月日',
              value: _formatDate(state.birthday),
              onTap: () {
                final date = state.birthday ?? ProfileConfig.defaultDateTime;

                viewModel.updateBirthday(date);

                _showBirthdayPicker(
                  context,
                  date,
                  viewModel.updateBirthday,
                );
              }
          ),

          /// 職業
          _rowTile(
            title: '職業',
            value: state.job,
            onTap: () =>
                _showJobPicker(
                  context,
                  state.job,
                  viewModel.updateJob,
                ),
          ),

          CustomElevatedButton(
              text: '登録する',
              backgroundColor: state.isCompleted ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () {
              }
          )
        ],
      ),
    );
  }

  Widget _rowTile({
    required String title,
    required String value,
    required VoidCallback onTap
  }) {
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

  void _showPrefecturePicker(
      BuildContext context,
      String current,
      void Function(String) onSelected,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController: FixedExtentScrollController(
              initialItem: ProfileConfig.prefectures.indexOf(current),
            ),
            onSelectedItemChanged: (index) {
              onSelected(ProfileConfig.prefectures[index]);
            },
            children: ProfileConfig.prefectures.map(Text.new).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return ProfileConfig.undefined;
    return '${date.year}年${date.month.toString()}月${date.day.toString()}日';
  }
  void _showBirthdayPicker(
      BuildContext context,
      DateTime current,
      void Function(DateTime) onSelected,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: current,
            maximumDate: DateTime.now(),
            minimumYear: 1900,
            onDateTimeChanged: onSelected,
          ),
        );
      },
    );
  }

  void _showJobPicker(
      BuildContext context,
      String current,
      void Function(String) onSelected,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController: FixedExtentScrollController(
              initialItem: ProfileConfig.jobs.indexOf(current),
            ),
            onSelectedItemChanged: (index) {
              onSelected(ProfileConfig.jobs[index]);
            },
            children: ProfileConfig.jobs.map(Text.new).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('成功'),
          content: const Text('アカウントを作成しました。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
