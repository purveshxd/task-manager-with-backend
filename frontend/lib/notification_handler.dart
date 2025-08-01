

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationProvider {
  // schedule notification
  Future<void> scheduleTaskNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      actionButtons: [
        NotificationActionButton(
          isDangerousOption: true,
          key: 'key',
          label: "Mark Done",
          autoDismissible: true,
        ),
      ],
      content: NotificationContent(
        locked: true,
        id: scheduledDate.millisecondsSinceEpoch.remainder(100000), // unique ID
        channelKey: 'task_channel',
        title: title,
        body: body,

        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        allowWhileIdle: true,
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  // schedule notification
  Future<void> scheduleMinuteNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      actionButtons: [
        NotificationActionButton(
          isDangerousOption: true,
          key: 'key',
          label: "Mark Done",
          autoDismissible: true,
        ),
      ],
      content: NotificationContent(
        locked: true,
        id: scheduledDate.millisecondsSinceEpoch.remainder(100000), // unique ID
        channelKey: 'task_channel',
        title: title,
        body: body,

        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationAndroidCrontab.daily(
        referenceDateTime: DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          scheduledDate.hour,
          scheduledDate.minute,
          0,
        ),
      ),
    );
  }
}
