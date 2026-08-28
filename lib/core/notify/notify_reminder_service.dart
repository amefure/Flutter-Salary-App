import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifyReminderService {
  static final NotifyReminderService _instance = NotifyReminderService._internal();
  factory NotifyReminderService() => _instance;
  NotifyReminderService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// 初期化
  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// 毎月の給料日リマインダーをスケジュール設定
  /// [payDay]: 給料日（例: 25日なら 25）
  /// [body]: ユーザーがカスタマイズした通知メッセージ
  /// [hour], [minute]: 通知を送る時刻
  Future<void> scheduleMonthlyReminder({
    required int payDay,
    required String body,
    required int hour,
    int minute = 10,
  }) async {
    // 既存の通知をリセット
    await _notificationsPlugin.cancel(0);

    final androidDetails = const AndroidNotificationDetails(
      'salary_reminder_channel',
      '給料日リマインダー',
      channelDescription: '給料の入力忘れを防ぐための通知です',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // 次回通知すべき日時の計算
    final scheduledDate = _nextInstanceOfDay(payDay, hour, minute);
    logger('scheduledDate${scheduledDate}');
    // 毎月繰り返しの通知を登録
    await _notificationsPlugin.zonedSchedule(
      0, // 通知ID
      '給料の記録はお済みですか？',
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  /// 指定した日付・時間の初回日時を計算するヘルパー（月末日の丸め処理付き）
  tz.TZDateTime _nextInstanceOfDay(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var targetYear = now.year;
    var targetMonth = now.month;

    // 指定された日（例: 31日）がその月に存在するかチェックし、存在しない場合は月末日に丸める
    // （例: 2月なら28日or29日、4月なら30日に調整）
    var targetDay = day;
    final lastDayOfThisMonth = _daysInMonth(targetYear, targetMonth);
    if (targetDay > lastDayOfThisMonth) {
      targetDay = lastDayOfThisMonth;
    }

    var scheduledDate = tz.TZDateTime(tz.local, targetYear, targetMonth, targetDay, hour, minute);

    // すでに今月のその日時を過ぎている場合は「来月」の予定にする
    if (scheduledDate.isBefore(now)) {
      targetMonth += 1;
      if (targetMonth > 12) {
        targetMonth = 1;
        targetYear += 1;
      }

      // 来月の月末日も考慮して丸める
      final lastDayOfNextMonth = _daysInMonth(targetYear, targetMonth);
      targetDay = day;
      if (targetDay > lastDayOfNextMonth) {
        targetDay = lastDayOfNextMonth;
      }

      scheduledDate = tz.TZDateTime(tz.local, targetYear, targetMonth, targetDay, hour, minute);
    }

    return scheduledDate;
  }

  /// 指定した年月の最終日（日数）を取得するヘルパー
  int _daysInMonth(int year, int month) {
    // 翌月の0日目を指定すると、当月の最終日（28〜31）が取得できる
    return tz.TZDateTime(tz.local, year, month + 1, 0).day;
  }
}