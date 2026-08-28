import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifyReminderService {
  static final NotifyReminderService _instance =
      NotifyReminderService._internal();
  factory NotifyReminderService() => _instance;
  NotifyReminderService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int _reminderNotificationId = 0;
  static const String _channelId = 'salary_reminder_channel';
  static const String _channelName = '給料日リマインダー';
  static const String _channelDescription = '給料の入力忘れを防ぐための通知です';
  Future<void>? _initialization;
  bool _notificationPermissionRequestStarted = false;
  bool _exactAlarmPermissionRequestStarted = false;

  /// 初期化
  Future<void> init() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    tz.initializeTimeZones();
    await _setLocalTimezone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    final initialized = await _notificationsPlugin.initialize(
      initializationSettings,
    );
    if (initialized != true) {
      throw StateError('通知プラグインの初期化に失敗しました');
    }

    // 通知をスケジュールする前にチャンネルを明示的に作成する。
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
  }

  /// 端末のタイムゾーンを通知スケジュールに反映する。
  Future<void> _setLocalTimezone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (error) {
      // タイムゾーン取得に失敗しても、tz.local（UTC）でアプリが起動できる
      // ようにする。ネイティブ対応端末では通常この分岐には入らない。
      logger('端末のタイムゾーン取得に失敗しました: $error');
    }
  }

  /// OSの通知権限と、Android 12以降の正確なアラーム権限を要求する。
  ///
  /// Androidの権限要求はActivityが表示された後に行う必要があるため、
  /// [init]とは分離している。
  Future<void> requestPermissions() async {
    await init();

    final android =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (android != null) {
      final notificationsEnabled = await android.areNotificationsEnabled();
      if (notificationsEnabled != true &&
          !_notificationPermissionRequestStarted) {
        _notificationPermissionRequestStarted = true;
        await android.requestNotificationsPermission();
      }

      final exactAlarmAllowed = await android.canScheduleExactNotifications();
      if (exactAlarmAllowed == false && !_exactAlarmPermissionRequestStarted) {
        _exactAlarmPermissionRequestStarted = true;
        await android.requestExactAlarmsPermission();
      }
    }

    final ios =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
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
    await init();
    await requestPermissions();

    // 既存の通知をリセット
    await _notificationsPlugin.cancel(_reminderNotificationId);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 次回通知すべき日時の計算
    final scheduledDate = nextInstanceOfDay(payDay, hour, minute);
    logger('scheduledDate$scheduledDate');

    final android =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final exactAlarmAllowed = await android?.canScheduleExactNotifications();

    // 毎月繰り返しの通知を登録
    await _notificationsPlugin.zonedSchedule(
      _reminderNotificationId,
      '給料の記録はお済みですか？',
      body,
      scheduledDate,
      notificationDetails,
      // 正確なアラーム権限がない端末では、通知自体が登録されないことを
      // 避けるため省電力中も動く不正確なアラームにフォールバックする。
      androidScheduleMode:
          exactAlarmAllowed == true
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  /// 指定した日付・時間の初回日時を計算するヘルパー（月末日の丸め処理付き）
  tz.TZDateTime nextInstanceOfDay(
    int day,
    int hour,
    int minute, {
    tz.TZDateTime? now,
  }) {
    final current = now ?? tz.TZDateTime.now(tz.local);
    final requestedDay = day.clamp(1, 31).toInt();
    final requestedHour = hour.clamp(0, 23).toInt();
    final requestedMinute = minute.clamp(0, 59).toInt();

    var targetYear = current.year;
    var targetMonth = current.month;

    // 指定された日（例: 31日）がその月に存在するかチェックし、存在しない場合は月末日に丸める
    // （例: 2月なら28日or29日、4月なら30日に調整）
    var targetDay = requestedDay;
    final lastDayOfThisMonth = _daysInMonth(targetYear, targetMonth);
    if (targetDay > lastDayOfThisMonth) {
      targetDay = lastDayOfThisMonth;
    }

    var scheduledDate = tz.TZDateTime(
      tz.local,
      targetYear,
      targetMonth,
      targetDay,
      requestedHour,
      requestedMinute,
    );

    // すでに今月のその日時を過ぎている場合は「来月」の予定にする
    if (!scheduledDate.isAfter(current)) {
      targetMonth += 1;
      if (targetMonth > 12) {
        targetMonth = 1;
        targetYear += 1;
      }

      // 来月の月末日も考慮して丸める
      final lastDayOfNextMonth = _daysInMonth(targetYear, targetMonth);
      targetDay = requestedDay;
      if (targetDay > lastDayOfNextMonth) {
        targetDay = lastDayOfNextMonth;
      }

      scheduledDate = tz.TZDateTime(
        tz.local,
        targetYear,
        targetMonth,
        targetDay,
        requestedHour,
        requestedMinute,
      );
    }

    return scheduledDate;
  }

  /// 指定した年月の最終日（日数）を取得するヘルパー
  int _daysInMonth(int year, int month) {
    // 翌月の0日目を指定すると、当月の最終日（28〜31）が取得できる
    return tz.TZDateTime(tz.local, year, month + 1, 0).day;
  }
}
