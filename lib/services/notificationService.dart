import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationServices {
  Future<void> initilaliseNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'my_note',
          channelName: 'Note Update',
          channelDescription: "Notify User About Reminder",
          channelGroupKey: 'my_notes_group',
          importance: NotificationImportance.Max,
          playSound: true,
          criticalAlerts: true,
          onlyAlertOnce: true,
          enableVibration: true,
          locked: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'my_notes_group',
            channelGroupName: 'My Note Group')
      ],
      debug: true,
    );

    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("Action from user received");
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print("Notification created");
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    print("Notification displayed");
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("Dismiss action received");
  }

  static Future<void> displayNotification({
    required final String notificationTitle,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final NotificationActionButton? actionButton,
    bool scheduled = true,
    final DateTime? time,
  }) async {
    Random random = Random();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: random.nextInt(1000) + 1,
        channelKey: 'my_note',
        title: notificationTitle,
        body: body,
        summary: summary,
        payload: payload,
        actionType: actionType,
        notificationLayout: NotificationLayout.BigText,
        bigPicture: bigPicture,
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
        autoDismissible: false,
      ),
      // schedule: NotificationCalendar.fromDate(date: time!),
      schedule: NotificationCalendar(
        minute: time!.minute,
        hour: time.hour,
        day: time.day,
        weekday: time.weekday,
        month: time.month,
        year: time.year,
        preciseAlarm: true,
        allowWhileIdle: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
      ),
    );
  }
}
