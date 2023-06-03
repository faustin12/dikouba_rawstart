import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService =
  NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /*final AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'channel ID',
    'channel name',
    'channel description',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );
  final IOSNotificationDetails iOSPlatformChannelSpecifics =
  IOSNotificationDetails(
      presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
      presentBadge: true,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
      presentSound: true,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
      sound: "path",  // Specifics the file path to play (only from iOS 10 onwards)
      badgeNumber: 1, // The application's icon badge number
      //attachments: List<IOSNotificationAttachment>, //(only from iOS 10 onwards)
      subtitle: "Subtitle", //Secondary description  (only from iOS 10 onwards)
      threadIdentifier: "Identifyer_1" //(only from iOS 10 onwards)
  );*/

  final BehaviorSubject<String?> behaviorSubject = BehaviorSubject();

  Future<void> init() async {

    //Initialization Settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    /*void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
      print('id $id');
      //Do something
      //Handle notification tapped logic here
      if (payload != null && payload.isNotEmpty) {
        //To edit
        print('notifService $payload');
        behaviorSubject.add(payload);
      }
    }*/

    void onReceiveLocalNotification (NotificationResponse notificationResponse) async {
      //Do something
      //Handle notification tapped logic here
      if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
        //To edit
        print('notifService $notificationResponse.payload');
        behaviorSubject.add(notificationResponse.payload);
      }
    }

    //Initialization Settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      //onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onReceiveLocalNotification);


    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      //'This channel is used for important notifications', // description
      importance: Importance.max,
    ));
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
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

    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      behaviorSubject.add(details.notificationResponse?.payload);
    }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  Future selectNotification(String payload) async {
    //Handle notification tapped logic here
    if (payload != null && payload.isNotEmpty) {
      //To edit
      print('notifService $payload');
      behaviorSubject.add(payload);
    }
  }

  Future<void> showMyNotifications(int id, String title, body, payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      threadIdentifier: "thread1",
      /*attachments: <IOSNotificationAttachment>[
          IOSNotificationAttachment(bigPicture)
        ]*/);
    await flutterLocalNotificationsPlugin.show(
      id,title,body,NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics),
      payload: payload,
    );
  }

  Future<void> showNotifications(NotificationDetails platformChannelSpecifics) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Title',
      'This is the Notification Body',
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }

  Future<void> scheduleNotifications(NotificationDetails platformChannelSpecifics) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Notification Title",
        "This is the Notification Body!",
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelNotifications(int notification_ID) async {
    await flutterLocalNotificationsPlugin.cancel(notification_ID);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

}