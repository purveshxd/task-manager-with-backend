import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize plugin and request permission
  static Future<void> init() async {
    tz.initializeTimeZones();
    final india = tz.getLocation('Asia/Kolkata');
    tz.setLocalLocation(india);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    log('✅ Notifications initialized');

    // Request permission explicitly
    await requestPermission();
  }

  // Request notification permission using permission_handler
  static Future<void> requestPermission() async {
  // ✅ Request Notification Permission
  final permission = await Permission.notification.status;
  if (!permission.isGranted) {
    final result = await Permission.notification.request();
    log('Notification permission requested, result: $result');
  } else {
    log('Notification permission already granted');
  }

  // ✅ Handle Battery Optimization for Android
  if (Platform.isAndroid) {
    final ignoreBatteryOptimizations = await Permission.ignoreBatteryOptimizations.isGranted;

    if (!ignoreBatteryOptimizations) {
      // Request the permission
      final result = await Permission.ignoreBatteryOptimizations.request();
      log('Battery optimization ignore requested: $result');

      // If still not granted, open battery optimization settings
      if (!result.isGranted) {
        final intent = AndroidIntent(
          action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        log('Opened battery optimization settings');
      }
    } else {
      log('Battery optimization already disabled for this app');
    }
  }
}

  // ✅ Cancel single notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    log('Cancelled notification with ID: $id');
  }

  // ✅ Cancel all notifications
  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    log('Cancelled all notifications');
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
    log('✅ Scheduled one-time notification at $tzDateTime');
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
    log('✅ Scheduled daily notification at $nextTime');
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
    log('✅ Scheduled weekly notification at $nextTime');
  }

  // ✅ Monthly Notification
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
    log('✅ Scheduled monthly notification at $nextTime');
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
        log('❌ Unknown repeat type: $repeatType');
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
      log('ℹ No notifications scheduled.');
    } else {
      for (var n in pending) {
        log(
          '🔔 Pending Notification -> ID: ${n.id}, Title: ${n.title}, Body: ${n.body}',
        );
      }
    }
  }
}
