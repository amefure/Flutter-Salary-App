import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/notify/notify_reminder_service.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  final service = NotifyReminderService();

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('nextInstanceOfDay', () {
    test('現在月に日付が存在しない場合は月末日に丸める', () {
      final now = tz.TZDateTime.utc(2025, 2, 1, 8);

      final result = service.nextInstanceOfDay(31, 19, 0, now: now);

      expect(result, tz.TZDateTime.utc(2025, 2, 28, 19));
    });

    test('指定時刻を過ぎている場合は翌月にする', () {
      final now = tz.TZDateTime.utc(2025, 12, 25, 20);

      final result = service.nextInstanceOfDay(25, 19, 0, now: now);

      expect(result, tz.TZDateTime.utc(2026, 1, 25, 19));
    });

    test('範囲外の値を受け取ってもクラッシュせず範囲内に補正する', () {
      final now = tz.TZDateTime.utc(2025, 6, 1);

      final result = service.nextInstanceOfDay(0, 30, 90, now: now);

      expect(result, tz.TZDateTime.utc(2025, 6, 1, 23, 59));
    });
  });
}
