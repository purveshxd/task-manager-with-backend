import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize time zones for scheduling
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // ✅ Base Notification Details
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel', // channel id
        'Task Notifications', // channel name
        channelDescription: 'Notifications for scheduled tasks',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,

        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // ✅ One-time Notification
  Future<void> scheduleTaskNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch.remainder(100000), // unique ID
      title,
      body,
      tzDateTime,
      _notificationDetails(),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    log('Scheduled one-time notification at $tzDateTime');
  }

  // ✅ Daily Notification
  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final nextTime = _nextInstanceOfTime(
      scheduledDate.hour,
      scheduledDate.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      nextTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    log('Scheduled daily notification at $nextTime');
  }

  // ✅ Weekly Notification
  Future<void> scheduleWeeklyNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final nextTime = _nextInstanceOfWeekdayTime(
      scheduledDate.weekday,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      nextTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    log('Scheduled weekly notification at $nextTime');
  }

  // ✅ Monthly Notification (Approach: Match day & time)
  Future<void> scheduleMonthlyNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final nextTime = _nextInstanceOfMonthDayTime(
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      nextTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
    log('Scheduled monthly notification at $nextTime');
  }

  // ✅ Dynamic schedule based on repeat type
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required String repeatType, // once, daily, weekly, monthly
  }) async {
    switch (repeatType.toLowerCase()) {
      case "once":
        await scheduleTaskNotification(
          title: title,
          body: body,
          scheduledDate: dateTime,
        );
        break;
      case "daily":
        await scheduleDailyNotification(
          title: title,
          body: body,
          scheduledDate: dateTime,
        );
        break;
      case "weekly":
        await scheduleWeeklyNotification(
          title: title,
          body: body,
          scheduledDate: dateTime,
        );
        break;
      case "monthly":
        await scheduleMonthlyNotification(
          title: title,
          body: body,
          scheduledDate: dateTime,
        );
        break;
      default:
        log('Unknown repeat type: $repeatType');
    }
  }

  // ✅ Helper Functions for next instances
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMonthDayTime(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        day,
        hour,
        minute,
      );
    }
    return scheduledDate;
  }

  // ✅ Debug function to check pending notifications
  Future<void> debugScheduledNotifications() async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    if (pending.isEmpty) {
      log('No notifications scheduled.');
    } else {
      for (var n in pending) {
        log(
          'Pending Notification -> ID: ${n.id}, Title: ${n.title}, Body: ${n.body} ',
        );
      }
    }
  }
}
