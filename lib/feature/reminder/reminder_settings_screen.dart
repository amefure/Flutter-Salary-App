import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/reminder/reminder_settings_view_model.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(reminderSettingsProvider);
    _messageController = TextEditingController(text: initialState.reminderMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reminderSettingsProvider);
    final notifier = ref.read(reminderSettingsProvider.notifier);

    // 時間の表示形式（例: 19:00）を綺麗にフォーマット
    final timeString = '${state.reminderHour.toString()}:${state.reminderMinute.toString().padLeft(2, '0')}';

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: '給料日リマインダー設定',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const CustomText(
              text: '通知日時',
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
              textSize: TextSize.S,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 通知日選択タイル
                  CupertinoListTile(
                    title: const CustomText(text: '毎月の通知日'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showDayPicker(context, state.reminderDay, notifier),
                          child: CustomText(
                            text: '${state.reminderDay}日',
                            color: CustomColors.thema,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey),
                      ],
                    ),
                  ),
                  // 通知時間選択タイル（追加）
                  CupertinoListTile(
                    title: const CustomText(text: '通知時間'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showTimePicker(context, state.reminderHour, state.reminderMinute, notifier),
                          child: CustomText(
                            text: timeString,
                            color: CustomColors.thema,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const CustomText(
              text: '通知メッセージ',
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
              textSize: TextSize.S,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoTextField(
                controller: _messageController,
                placeholder: '通知メッセージを入力',
                maxLines: 3,
                decoration: const BoxDecoration(color: CupertinoColors.transparent),
                onChanged: (value) {
                  notifier.updateReminderMessage(value);
                },
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: CustomText(
                text: '設定した日時に、上記メッセージでプッシュ通知が届きます。',
                textSize: TextSize.SS,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 日付（1日〜31日）ピッカー
  void _showDayPicker(BuildContext context, int currentDay, ReminderSettingsViewModel notifier) {
    int selectedDay = currentDay;

    showCupertinoModalPopup(
      context: context,
      builder: (modalContext) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const CustomText(text: 'キャンセル'),
                  onPressed: () => Navigator.of(modalContext).pop(),
                ),
                CupertinoButton(
                  child: const CustomText(text: '完了'),
                  onPressed: () {
                    notifier.updateReminderDay(selectedDay);
                    Navigator.of(modalContext).pop();
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: currentDay - 1),
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  selectedDay = index + 1;
                },
                children: List<Widget>.generate(31, (int index) {
                  return Center(
                    child: CustomText(text: '${index + 1}日'),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 時間（時・分）ピッカー（追加）
  void _showTimePicker(BuildContext context, int currentHour, int currentMinute, ReminderSettingsViewModel notifier) {
    int selectedHour = currentHour;
    int selectedMinute = currentMinute;

    showCupertinoModalPopup(
      context: context,
      builder: (modalContext) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const CustomText(text: 'キャンセル'),
                  onPressed: () => Navigator.of(modalContext).pop(),
                ),
                CupertinoButton(
                  child: const CustomText(text: '完了'),
                  onPressed: () {
                    notifier.updateReminderTime(selectedHour, selectedMinute);
                    Navigator.of(modalContext).pop();
                  },
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  // 時（0〜23）
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: currentHour),
                      itemExtent: 32.0,
                      onSelectedItemChanged: (int index) {
                        selectedHour = index;
                      },
                      children: List<Widget>.generate(24, (int index) {
                        return Center(child: CustomText(text: '${index.toString()}時'));
                      }),
                    ),
                  ),
                  // 分（0〜59）
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: currentMinute),
                      itemExtent: 32.0,
                      onSelectedItemChanged: (int index) {
                        selectedMinute = index;
                      },
                      children: List<Widget>.generate(60, (int index) {
                        return Center(child: CustomText(text: '${index.toString().padLeft(2, '0')}分'));
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}