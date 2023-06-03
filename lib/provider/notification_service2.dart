import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

class NotificationService2 {
  NotificationService2();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: selectNotification);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void selectNotification(NotificationResponse notificationResponse) {
    String? payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      print('notifService2 $payload');
      behaviorSubject.add(payload);
    }
  }

  Future<NotificationDetails> _notificationDetails() async {

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel id',
      'channel name',
      //'channel description',
      icon: "@mipmap/launcher_icon",
      //groupKey: 'com.example.flutter_push_notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      //ticker: 'ticker',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      /*styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicture),
        hideExpandedLargeIcon: false,
      ),*/
      //color: const Color(0xff2196f3),
    );

    DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
        threadIdentifier: "thread1",
        /*attachments: <IOSNotificationAttachment>[
          IOSNotificationAttachment(bigPicture)
        ]*/);

    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      behaviorSubject.add(details.notificationResponse!.payload.toString());
    }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }


}
