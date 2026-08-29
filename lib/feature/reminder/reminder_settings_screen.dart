import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/reminder/reminder_settings_view_model.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  late TextEditingController _messageController;
  bool _isNotificationGranted = true;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(reminderSettingsProvider);
    _messageController = TextEditingController(text: initialState.reminderMessage);

    // 画面が開いた直後に通知許可をチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }

  /// 通知許可をチェックし、状態を保持する
  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;

    // デバッグ用ログ
    logger('現在の通知権限ステータス: $status');

    if (mounted) {
      setState(() {
        // granted または limited であれば許可されているとみなす
        _isNotificationGranted = status.isGranted || status.isLimited;
      });
    }
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
            // 通知がOFFの場合のみ表示する注意喚起エリア
            if (!_isNotificationGranted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemYellow, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemOrange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            text: '端末の通知設定がオフになっています。',
                            fontWeight: FontWeight.bold,
                            textSize: TextSize.S,
                          ),
                          const SizedBox(height: 2),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 0,
                            onPressed: () async {
                              await openAppSettings();
                            },
                            child: const CustomText(
                              text: '端末の設定から許可する ＞',
                              color: CustomColors.thema,
                              textSize: TextSize.SS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const CustomLabelView(labelText:'通知日時'),

            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CupertinoListTile(
                    title: const CustomText(text: '毎月の通知日', fontWeight: FontWeight.bold, textSize: TextSize.S),
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
                  CupertinoListTile(
                    title: const CustomText(text: '通知時間', fontWeight: FontWeight.bold, textSize: TextSize.S),
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
            const CustomLabelView(labelText:'通知メッセージ'),
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
                text: '設定した日時に、毎月上記メッセージでプッシュ通知が届きます。',
                textSize: TextSize.SS,
                color: CupertinoColors.systemGrey,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

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