import 'dart:async';
import 'dart:convert';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/annoncer/eventnewannoncer_activity.dart';
import 'package:dikouba_rawstart/activity/choseloginsignup_activity.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/activity/user/userprofil_activity.dart';
import 'package:dikouba_rawstart/fragment/EventAgendaScreen.dart';
import 'package:dikouba_rawstart/fragment/EventLiveScreen.dart';
import 'package:dikouba_rawstart/fragment/EventHomeScreen.dart';
import 'package:dikouba_rawstart/fragment/EventMapScreen.dart';
import 'package:dikouba_rawstart/fragment/EventMesTicketsScreen.dart';
import 'package:dikouba_rawstart/fragment/EventMesFavorisScreen.dart';
import 'package:dikouba_rawstart/fragment/EventScanTicketScreen.dart';
import 'package:dikouba_rawstart/fragment/UserMesNotificationsScreen.dart';
import 'package:dikouba_rawstart/fragment/EventSondagesScreen.dart';
import 'package:dikouba_rawstart/fragment/EventMesEvenementsScreen.dart';
import 'package:dikouba_rawstart/main.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/notification_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/sondagereponse_model.dart';
import 'package:dikouba_rawstart/model/ticket_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/provider/notification_service.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class HomeActivity extends StatefulWidget {
  HomeActivity({Key? key, required this.analytics, required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  HomeActivityState createState() => HomeActivityState();

}

class HomeActivityState extends State<HomeActivity> with SingleTickerProviderStateMixin {
  static final String TAG = 'HomeActivityState';

  NotificationService notificationService = NotificationService();
  //NotificationService2 notificationService2 = NotificationService2();

  void onMessageReceived(Map<String, dynamic> message) {
    // TODO(developer): Handle FCM messages here.
    // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
    //{notification: {title: Test notification, body: This is only for testing purpose}, data: {Nick: Mario, Room: PortugalVSDenmark}}

    print("${TAG}:pushMessage ${message}");

    if(message['data']['exist']=="true"){
      print("${TAG}:pushMessage ${message['data']}");
      notificationService.showMyNotifications(
          0,
          message['notification']['title'],
          message['notification']['body'],
          json.encode(message['data']));
    }else notificationService.showMyNotifications(
        1,
        message['notification']['title'],
        message['notification']['body'],
        json.encode(message['data']));
    // Also if you intend on generating your own notifications as a result of a received FCM
    // message, here is where that should be initiated. See sendNotification method below.
  }

  static void onBackgroundMessageReceived(Map<String, dynamic> message) {
    // TODO(developer): Handle FCM messages here.
    // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
    print("${TAG}:pushMessage ${message}");

    // Also if you intend on generating your own notifications as a result of a received FCM
    // message, here is where that should be initiated. See sendNotification method below.
  }

  static Future<dynamic>? myBackgroundMessageHandler(Map<String, dynamic> message) {
    print("onBackgroundMessage _backgroundMessageHandler");
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print('onBackgroundMessage' + data);
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print('onBackgroundMessage' + notification);
    }
    // Or do other work.
  }

  int _currentIndex = 0;

  late UserModel _userModel;

  late CustomAppTheme customAppTheme;

  late TabController _tabController;

  _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  bool _showTabview = true;
  Widget _bodyCustom = Container();

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    setState(() {
      _userModel = UserModel.fromJsonDb(userRows[0]);
    });
    _setUserId(_userModel.uid!);

    findNotifications();
    findSondages();
    findTickets();
  }

  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics.instance.setUserId(id: uid);
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: <String, dynamic>{},
    );
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "HomeActivity",
      screenClassOverride: "HomeActivity",
    );
  }

  @override
  void didPush() {
    // Called when the current route has been pushed.
    _setCurrentScreen();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off,
    // and the current route shows up.
    _setCurrentScreen();
  }

  late List<NotificationModel> _notifications;
  final _notifCount= ValueNotifier<int>(0);
  void findNotifications(){
    int count=0;
    API.findUserComments(_userModel.id_users).then((responseEvents) { //To be chaged to findUserNotifications
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesFavoris ${responseEvents.statusCode}|${responseEvents.data}");
        List<NotificationModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(NotificationModel.fromJson(responseEvents.data[i]));
          if(NotificationModel.fromJson(responseEvents.data[i]).status == "unread")  count++;
        }

        if (!mounted) return;
        _notifCount.value = list.length; //To be deleted, only unread needed
        setState(() {
          _notifications = list;
        });
      }
    }).catchError((errWalletAddr) {
      if (!mounted) return;
    });
  }
  void countNotifications(){
    int count=0;
    API.findUserComments(_userModel.id_users).then((responseEvents) { //To be chaged to findUserNotifications
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesFavoris ${responseEvents.statusCode}|${responseEvents.data}");
        for (int i = 0; i < responseEvents.data.length; i++) {
          count++;
          //if(NotificationModel.fromJson(responseEvents.data[i]).status == "unread")  count++;
        }

        if (!mounted) return;
        _notifCount.value = count; //To be deleted, only unread needed
      }
    }).catchError((errWalletAddr) {
      if (!mounted) return;
    });
  }

  late List<SondageModel> _sondages;
  final _sondagesCount= ValueNotifier<int>(0);
  void findSondages(){
    API.findSondageUsers(_userModel.id_users).then((responseSondageRes) {
      if (responseSondageRes.statusCode == 200) {
        print(
            "${TAG}:findSondageParticipate ${responseSondageRes.statusCode}|${responseSondageRes.data}");
        List<SondageModel> list = [];
        for (int i = 0; i < responseSondageRes.data.length; i++) {
          list.add(SondageReponseModel.fromJson(responseSondageRes.data[i]).sondages!);
        }

        if (!mounted) return;
        _sondagesCount.value = list.length;
        setState(() {
          _sondages = list;
        });
      } else {
        print("${TAG}:findSondageParticipate no data ${responseSondageRes.toString()}");

        if (!mounted) return;
        setState(() {
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:findSondageParticipate errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
      });
    });
  }
  void countSondages(){
    API.findSondageUsers(_userModel.id_users).then((responseSondageRes) {
      if (responseSondageRes.statusCode == 200) {
        print(
            "${TAG}:findSondageParticipate ${responseSondageRes.statusCode}|${responseSondageRes.data}");
        List<SondageModel> list = [];
        for (int i = 0; i < responseSondageRes.data.length; i++) {
          list.add(SondageReponseModel.fromJson(responseSondageRes.data[i]).sondages!);
        }

        if (!mounted) return;
        _sondagesCount.value = list.length;
      } else {
        print("${TAG}:findSondageParticipate no data ${responseSondageRes.toString()}");

        if (!mounted) return;
        setState(() {
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:findSondageParticipate errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
      });
    });
  }

  late List<TicketModel> _tickets;
  final _unpaidticketCount= ValueNotifier<int>(0);
  void findTickets(){
    int count=0;
    API.findTicketsUsers(_userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesTickets ${responseEvents.statusCode}|${responseEvents.data}");
        List<TicketModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          TicketModel tempTicket = TicketModel.fromJson(responseEvents.data[i]);
          list.add(tempTicket);
          if(!(tempTicket.statut == "COMPLETE") && !(tempTicket.statut == "COMPLETED")) count++;
        }

        _unpaidticketCount.value = count;
        if (!mounted) return;
        setState(() {
          _tickets = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
        setState(() {
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
      });
    });
  }
  void countTickets(){
    int count=0;
    API.findTicketsUsers(_userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesTickets ${responseEvents.statusCode}|${responseEvents.data}");
        for (int i = 0; i < responseEvents.data.length; i++) {
          TicketModel tempTicket = TicketModel.fromJson(responseEvents.data[i]);
          if(!(tempTicket.statut == "COMPLETE") && !(tempTicket.statut == "COMPLETED")) count++;
        }

        if (!mounted) return;
        _unpaidticketCount.value = count;

      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
    });
  }

  void notify () async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel ID',
      'channel name',
      //'channel description',
      icon: "@mipmap/launcher_icon",
      playSound: true,
      priority: Priority.high,
      importance: Importance.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
        presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentBadge: true,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentSound: true,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        sound: "path",  // Specifics the file path to play (only from iOS 10 onwards)
        badgeNumber: 1, // The application's icon badge number
        //attachments: List<IOSNotificationAttachment>, //(only from iOS 10 onwards)
        subtitle: "Subtitle", //Secondary description  (only from iOS 10 onwards)
        threadIdentifier: "Identifyer_1" //(only from iOS 10 onwards)
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    NotificationService _notificationService = NotificationService();

    _notificationService.showNotifications(platformChannelSpecifics);

  }

  late StreamSubscription _sub;

  /*Future<void> _initReceiveIntent() async {
    // ... check initialIntent
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final receivedIntent = await ReceiveIntent.getInitialIntent();

      if (receivedIntent.isNotNull){
        String _data = receivedIntent.data;
        print('receivedIntent $_data');
      }
      // Validate receivedIntent and warn the user, if it is not correct,
      // but keep in mind it could be `null` or "empty"(`receivedIntent.isNull`).
    } on PlatformException {
      // Handle exception
    }
    // Attach a listener to the stream
    /*_sub = ReceiveIntent.receivedIntentStream.listen((Intent intent) {
      // Validate receivedIntent and warn the user, if it is not correct,
    }, onError: (err) {
      // Handle exception
    });*/

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }*/

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print('notifPayload $payload');
        if (payload != null && payload.isNotEmpty) {
          Map<String, dynamic> _notificationData = json.decode(payload);

          if(_notificationData['type']=='open'){
            print('notifAction = opening a page');
            switch(_notificationData['page']) {
              case 'home': {
                // statements;
              }
              break;
              case 'event_detail': {
                // statements;
                API.findEventItem(_notificationData['id_for_page']).then((response) {
                  if (response.statusCode == 200) {
                    print("$TAG:responseEvent ${response.statusCode}|${response.data}");
                    EvenementModel evenement = EvenementModel.fromJson(response.data);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
                                appBar: _myAppBar(),
                                body:EvenDetailsActivity(
                                  evenement,
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                )
                            )));

                    if (!mounted) return;
                  }
                }).catchError((errWalletAddr) {
                  if (!mounted) return;
                });
              }
              break;
              case 'event_comment': {
                // statements;
              }
              break;
              case 'invitation_handle': {
                // statements;
              }
              break;
              case 'invitation_listing': {
                // statements;
              }
              break;
              case 'follower_listing': {
                // statements;
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileActivity(
                          _userModel,
                          analytics: widget.analytics,
                          observer: widget.observer,
                        )));
              }
              break;
              case 'sondage_listing': {
                // statements;
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => EventSondagesScreen(
                          _userModel,
                          analytics: widget.analytics,
                          observer: widget.observer,
                        )));
              }
              break;
              case 'detail': {
                //statements;
                final snackBar = SnackBar(
                    content: Text('Notification received ' + _notificationData['page']),
                    duration: const Duration(milliseconds: 2000));
                //_scaffoldKey.currentState
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              break;
              default: {
                //statements;
              }
              break;
            }
          }

        }
      });


  late Future<String> permissionStatusFuture;
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";

  /// Checks the notification permission status
  Future<String> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
          return status.toString();
      /*switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        case PermissionStatus.unknown:
          return permUnknown;
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return null;
      }*/
    });
  }

  Future<void> permissionChecker() async{
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("Location Permission is granted");
    }else{
      print("Location Permission is denied.");
    }
    if (await Permission.camera.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("Camera Permission is granted");
    }else{
      print("Camera Permission is denied.");
    }
    if (await Permission.notification.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("Camera Permission is granted");
    }else{
      print("Camera Permission is denied.");
    }

  }

  late Timer timer1,timer2,timer3;

  @override
  void initState() {
    queryUser();

    timer1 = Timer.periodic(Duration(seconds: 60*1), (Timer t) => {countNotifications()});
    timer2 = Timer.periodic(Duration(seconds: 60*1), (Timer t) => {countSondages()});
    timer3 = Timer.periodic(Duration(seconds: 60*1), (Timer t) => {countTickets()});

    permissionChecker();

    //_initReceiveIntent();

    notificationService.init();
    listenToNotificationStream();

    permissionStatusFuture = getCheckNotificationPermStatus();
    print('notifPermission ' + permissionStatusFuture.toString());

    //Notification handler ?
    //FirebaseMessaging().requestNotificationPermissions();

    /*FirebaseMessaging.instance.configure(
        onMessage: (Map<String, dynamic> message){onMessageReceived(message);},
        //onBackgroundMessage: (Map<String, dynamic> message){onBackgroundMessageReceived(message);}
    );*/

    _tabController = new TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    _tabController.animation!.addListener(() {
      final aniValue = _tabController.animation!.value;
      if (aniValue - _currentIndex > 0.5) {
        setState(() {
          _currentIndex = _currentIndex + 1;
        });
      } else if (aniValue - _currentIndex < -0.5) {
        setState(() {
          _currentIndex = _currentIndex - 1;
        });
      }
    });
    super.initState();

    _setCurrentScreen();
  }

  onTapped(value) {
    setState(() {
      _currentIndex = value;
    });
    _sendAnalyticsEvent("Page_Index_=_" + _currentIndex.toString());
  }

  dispose() {
    super.dispose();
    _tabController.dispose();
    timer1.cancel();
    timer2.cancel();
    timer3.cancel();
    _notifCount.dispose();
    _sondagesCount.dispose();
    _unpaidticketCount.dispose();
  }

  late ThemeData themeData;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  late DateTime currentBackPressTime;

  //OnWillPop If no tab go back to tab view
  Future<bool> onWillPop2() {
    setState(() {
      _scaffoldKey.currentState!.openEndDrawer();
      _showTabview = true;
      _bodyCustom = Container();
    });
    return Future.value(false);
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    final snackBar = SnackBar(
        content: Text('Appuyez une seconde fois pour quitter'),
        duration: const Duration(milliseconds: 2000));

    /*DikoubaUtils.toast_infos(context, "Route " + MyApp.HomeNavigatorKey.currentState?.canPop().toString().compareTo("true").toString()
        + MyApp.AgendaNavigatorKey.currentState?.canPop().toString().compareTo("true").toString()
        + MyApp.MapNavigatorKey.currentState?.canPop().toString().compareTo("true").toString()
        + MyApp.LiveNavigatorKey.currentState?.canPop().toString().compareTo("true").toString()
    );*/

    if (false){//_scaffoldKey.currentState?.isDrawerOpen) {
      return Future.value(true);
    }

    if (MyApp.HomeNavigatorKey.currentState
            ?.canPop()
            .toString()
            .compareTo("true") ==
        0) return Future.value(true);
    if (MyApp.AgendaNavigatorKey.currentState
            ?.canPop()
            .toString()
            .compareTo("true") ==
        0) return Future.value(true);
    if (MyApp.MapNavigatorKey.currentState
            ?.canPop()
            .toString()
            .compareTo("true") ==
        0) return Future.value(true);
    if (MyApp.LiveNavigatorKey.currentState
            ?.canPop()
            .toString()
            .compareTo("true") ==
        0) return Future.value(true);

    if (_tabController.index > 0) {
      _tabController.animateTo(0);
      return Future.value(false);
    }

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      //_scaffoldKey.currentState
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar);
      return Future.value(false);
    }

    return Future.value(true);
  }

  /*Scaffold _homeWithTab(){
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
          elevation: 0,
          shape: CircularNotchedRectangle(),
          child: Container(
            decoration: BoxDecoration(
              color: themeData.bottomAppBarTheme.color,
              boxShadow: [
                BoxShadow(
                  color: customAppTheme.shadowColor,
                  blurRadius: 3,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: themeData.colorScheme.primary,
              tabs: <Widget>[
                Container(
                  child: (_currentIndex == 0)
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        MdiIcons.home,
                        color: DikoubaColors.blue['pri'],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                            color:
                            DikoubaColors.blue['pri'],
                            borderRadius:
                            new BorderRadius.all(
                                Radius.circular(2.5))),
                        height: 5,
                        width: 5,
                      )
                    ],
                  )
                      : Icon(
                    MdiIcons.homeOutline,
                    color: DikoubaColors.blue['pri'],
                  ),
                ),
                Container(
                    child: (_currentIndex == 1)
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          MdiIcons.calendar,
                          color: DikoubaColors.blue['pri'],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                              color:
                              DikoubaColors.blue['pri'],
                              borderRadius: new BorderRadius
                                  .all(
                                  Radius.circular(2.5))),
                          height: 5,
                          width: 5,
                        )
                      ],
                    )
                        : Icon(
                      MdiIcons.calendarOutline,
                      color: DikoubaColors.blue['pri'],
                    )),
                Container(
                    child: (_currentIndex == 2)
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.place,
                          color: DikoubaColors.blue['pri'],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                              color:
                              DikoubaColors.blue['pri'],
                              borderRadius: new BorderRadius
                                  .all(
                                  Radius.circular(2.5))),
                          height: 5,
                          width: 5,
                        )
                      ],
                    )
                        : Icon(
                      Icons.place_outlined, //mapOutline,
                      color: DikoubaColors.blue['pri'],
                    )),
                Container(
                    child: (_currentIndex == 3)
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          MdiIcons
                              .youtubeTv, //ticketConfirmation,
                          color: DikoubaColors.blue['pri'],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                              color:
                              DikoubaColors.blue['pri'],
                              borderRadius: new BorderRadius
                                  .all(
                                  Radius.circular(2.5))),
                          height: 5,
                          width: 5,
                        )
                      ],
                    )
                        : Icon(
                      Icons
                          .live_tv_rounded, //ticketConfirmationOutline,
                      color: DikoubaColors.blue['pri'],
                    )),
              ],
            ),
          )),
      drawer: _userModel == null
          ? Container()
          : Drawer(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  gotoUpdateUserprofile();
                },
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                  ),
                  accountName: Text(
                    _userModel.name,
                    style: Theme.of(context)
                        .textTheme
                        .headline6,
                  ),
                  accountEmail: Text(
                    _userModel.email,
                    style:
                    Theme.of(context).textTheme.caption,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).accentColor,
                    backgroundImage:
                    NetworkImage(_userModel.photo_url),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = true;
                    _bodyCustom = Container();
                  });
                },
                leading: Icon(
                  Icons.home,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  'Accueil',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = EventMyEventScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  });
                },
                leading: Icon(
                  Icons.event_note,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  'Mes évènements',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = EventSondagesScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  });
                },
                leading: Icon(
                  Icons.trending_up_rounded,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                trailing: (_sondagesCount>0) ? Container(
                  alignment: Alignment.center,
                  width: 22,//MySize.size6,
                  height: 22,//MySize.size6,
                  decoration: BoxDecoration(
                      color: customAppTheme.colorError,
                      shape: BoxShape.circle),
                  child: Text(_sondagesCount.toString(), style: AppTheme.getTextStyle(
                      themeData.textTheme.caption,
                      fontWeight: 600,
                      letterSpacing: 0,
                      fontSize: 12,
                      color: Colors.white),),
                ) : Container(child:Text("")),
                title: Text(
                  'Mes sondages',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = UserMesNotificationsScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  });
                },
                leading: Icon(
                  Icons.notifications,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  'Notifications',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = EventMesTicketsScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  });
                },
                leading: Icon(
                  Icons.shopping_cart,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                trailing: (_notifCount>0) ? Container(
                  alignment: Alignment.center,
                  width: 22,//MySize.size6,
                  height: 22,//MySize.size6,
                  decoration: BoxDecoration(
                      color: customAppTheme.colorError,
                      shape: BoxShape.circle),
                  child: Text(_notifCount.toString(), style: AppTheme.getTextStyle(
                      themeData.textTheme.caption,
                      fontWeight: 600,
                      letterSpacing: 0,
                      fontSize: 12,
                      color: Colors.white),),
                ) : Container(child:Text("")),
                title: Text(
                  'Mes Achats',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = EventMesFavorisScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  });
                },
                /*onTap: () {
                                      Navigator.of(context)
                                          .pushNamed('/Favorites');
                                    },*/
                leading: Icon(
                  Icons.favorite,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  "Mes Favoris",
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _scaffoldKey.currentState
                        .openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = EventScanTicketScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  });
                },
                leading: Icon(
                  Icons.add_a_photo,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  'Scan tickets',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  "Autres",
                  style:
                  Theme.of(context).textTheme.bodyText2,
                ),
                trailing: Icon(
                  Icons.remove,
                  color: Theme.of(context)
                      .focusColor
                      .withOpacity(0.3),
                ),
              ),
              ListTile(
                onTap: () {
                  gotoDevenirAnnoncer();
                },
                leading: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  (_userModel.id_annoncers == null ||
                      _userModel.id_annoncers == "")
                      ? 'Devenir annonceur'
                      : 'Modifier annonceur',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  // Navigator.of(context).pop();
                  signOut(context);
                },
                leading: Icon(
                  Icons.logout,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  'Se déconnecter',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed('/Help');
                },
                leading: Icon(
                  Icons.help,
                  color: DikoubaColors.blue[
                  'pri'], //Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  'Support',
                  style:
                  Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  "Dikouba 1.0.4",
                  style:
                  Theme.of(context).textTheme.bodyText2,
                ),
                trailing: Icon(
                  Icons.remove,
                  color: Theme.of(context)
                      .focusColor
                      .withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: customAppTheme.bgLayer1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Dikouba",
          style: AppTheme.getTextStyle(
              themeData.textTheme.headline5,
              fontSize: 24,
              fontWeight: 700,
              letterSpacing: -0.3,
              color: DikoubaColors.blue['pri']),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: Spacing.all(10),
                decoration: BoxDecoration(
                    color: customAppTheme.bgLayer1,
                    borderRadius: BorderRadius.all(
                        Radius.circular(MySize.size8)),
                    boxShadow: [
                      BoxShadow(
                          color: customAppTheme.shadowColor,
                          blurRadius: MySize.size4)
                    ]),
                child: InkWell(onTap: (){
                  setState(() {
                    _scaffoldKey.currentState.openEndDrawer();
                    _showTabview = false;
                    _bodyCustom = UserMesNotificationsScreen(
                      _userModel,
                      analytics: widget.analytics,
                      observer: widget.observer,);
                  });
                },
                  child:Icon(
                    MdiIcons.bell,
                    size: MySize.size18,
                    color: DikoubaColors.blue[
                    'pri'], //themeData.colorScheme.onBackground.withAlpha(160),
                  ),),
              ),
              (_notifCount>0) ? Positioned(
                right: 4,
                top: MySize.size12,
                child: Container(
                  alignment: Alignment.center,
                  width: 12,//MySize.size6,
                  height: 12,//MySize.size6,
                  decoration: BoxDecoration(
                      color: customAppTheme.colorError,
                      shape: BoxShape.circle),
                  child: Text("", style: AppTheme.getTextStyle(
                      themeData.textTheme.caption,
                      fontWeight: 600,
                      letterSpacing: 0,
                      fontSize: 12,
                      color: Colors.white),),
                ),
              ) : Container()
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () {
                  gotoUpdateUserprofile();
                },
                child: Container(
                  margin: Spacing.left(16),
                  decoration: BoxDecoration(
                      color: customAppTheme.bgLayer1,
                      borderRadius: BorderRadius.all(
                          Radius.circular(MySize.size8)),
                      boxShadow: [
                        BoxShadow(
                            color: customAppTheme.shadowColor,
                            blurRadius: MySize.size4)
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(MySize.size8)),
                    child: _userModel == null
                        ? CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                            DikoubaColors.blue['pri']))
                        : Image(
                      image: _userModel.photo_url == ""
                          ? AssetImage(
                          './assets/logo/user_transparent.webp')
                          : NetworkImage(
                          _userModel.photo_url),
                      fit: BoxFit.cover,
                      width: MySize.size36,
                      height: MySize.size36,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            width: 12,
          )
        ],
      ),
      body: _userModel == null
          ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              DikoubaColors.blue['pri']))
          : TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          EventHomeScreen(
            _userModel,
            analytics: widget.analytics,
            observer: widget.observer,
          ),
          EventAgendaScreen(
            _userModel,
            analytics: widget.analytics,
            observer: widget.observer,
          ),
          EventMapScreen(
            analytics: widget.analytics,
            observer: widget.observer,
          ),
          EventLiveScreen(
            analytics: widget.analytics,
            observer: widget.observer,
          ),
          // EventProfileScreen(_userModel)
        ],
      ),
      //)
    );
  }*/

  /*Scaffold _homeWithoutTab(){
    return Scaffold(
        key: _scaffoldKey,
        drawer: _userModel == null
            ? Container()
            : Drawer(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    gotoUpdateUserprofile();
                  },
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface,
                    ),
                    accountName: Text(
                      _userModel.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline6,
                    ),
                    accountEmail: Text(
                      _userModel.email,
                      style:
                      Theme.of(context).textTheme.caption,
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor:
                      Theme.of(context).accentColor,
                      backgroundImage:
                      NetworkImage(_userModel.photo_url),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = true;
                      _bodyCustom = Container();
                    });
                  },
                  leading: Icon(
                    Icons.home,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    'Accueil',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = false;
                      _bodyCustom = EventMyEventScreen(
                        _userModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.event_note,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    'Mes évènements',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = false;
                      _bodyCustom = EventSondagesScreen(
                        _userModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.trending_up_rounded,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  trailing: (_sondagesCount>0) ? Container(
                    alignment: Alignment.center,
                    width: 22,//MySize.size6,
                    height: 22,//MySize.size6,
                    decoration: BoxDecoration(
                        color: customAppTheme.colorError,
                        shape: BoxShape.circle),
                    child: Text(_sondagesCount.toString(), style: AppTheme.getTextStyle(
                        themeData.textTheme.caption,
                        fontWeight: 600,
                        letterSpacing: 0,
                        fontSize: 12,
                        color: Colors.white),),
                  ) : Container(child:Text("")),
                  title: Text(
                    'Mes sondages',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = false;
                      _bodyCustom = UserMesNotificationsScreen(
                        _userModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.notifications,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  trailing: (_notifCount>0) ? Container(
                    alignment: Alignment.center,
                    width: 22,//MySize.size6,
                    height: 22,//MySize.size6,
                    decoration: BoxDecoration(
                        color: customAppTheme.colorError,
                        shape: BoxShape.circle),
                    child: Text(_notifCount.toString(), style: AppTheme.getTextStyle(
                        themeData.textTheme.caption,
                        fontWeight: 600,
                        letterSpacing: 0,
                        fontSize: 12,
                        color: Colors.white),),
                  ) : Container(child:Text("")),
                  title: Text(
                    'Notifications',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = false;
                      _bodyCustom = EventMesTicketsScreen(
                        _userModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.shopping_cart,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    'Mes Achats',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = false;
                      _bodyCustom = EventMesFavorisScreen(
                        _userModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    });
                  },
                  /*onTap: () {
                                      Navigator.of(context)
                                          .pushNamed('/Favorites');
                                    },*/
                  leading: Icon(
                    Icons.favorite,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    "Mes Favoris",
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _scaffoldKey.currentState
                          .openEndDrawer();
                      _showTabview = false;
                      _bodyCustom = EventScanTicketScreen(
                        _userModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.add_a_photo,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    'Scan tickets',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    "Autres",
                    style:
                    Theme.of(context).textTheme.bodyText2,
                  ),
                  trailing: Icon(
                    Icons.remove,
                    color: Theme.of(context)
                        .focusColor
                        .withOpacity(0.3),
                  ),
                ),
                ListTile(
                  onTap: () {
                    gotoDevenirAnnoncer();
                  },
                  leading: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    (_userModel.id_annoncers == null ||
                        _userModel.id_annoncers == "")
                        ? 'Devenir annonceur'
                        : 'Modifier annonceur',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    // Navigator.of(context).pop();
                    signOut(context);
                  },
                  leading: Icon(
                    Icons.logout,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    'Se déconnecter',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Help');
                  },
                  leading: Icon(
                    Icons.help,
                    color: DikoubaColors.blue[
                    'pri'], //Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    'Support',
                    style:
                    Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    "Dikouba 1.0.4",
                    style:
                    Theme.of(context).textTheme.bodyText2,
                  ),
                  trailing: Icon(
                    Icons.remove,
                    color: Theme.of(context)
                        .focusColor
                        .withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: customAppTheme.bgLayer1,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            "Dikouba",
            style: AppTheme.getTextStyle(
                themeData.textTheme.headline5,
                fontSize: 24,
                fontWeight: 700,
                letterSpacing: -0.3,
                color: DikoubaColors.blue['pri']),
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    padding: Spacing.all(10),
                    decoration: BoxDecoration(
                        color: customAppTheme.bgLayer1,
                        borderRadius: BorderRadius.all(
                            Radius.circular(MySize.size8)),
                        boxShadow: [
                          BoxShadow(
                              color: customAppTheme.shadowColor,
                              blurRadius: MySize.size4)
                        ]),
                    child: InkWell(onTap: (){
                      setState(() {
                        _scaffoldKey.currentState.openEndDrawer();
                        _showTabview = false;
                        _bodyCustom = UserMesNotificationsScreen(
                          _userModel,
                          analytics: widget.analytics,
                          observer: widget.observer,);
                      });
                    },
                      child:Icon(
                        MdiIcons.bell,
                        size: MySize.size18,
                        color: themeData.colorScheme.onBackground
                            .withAlpha(160),
                      ),)
                ),
                Positioned(
                  right: 4,
                  top: MySize.size22,
                  child: Container(
                    width: MySize.size6,
                    height: MySize.size6,
                    decoration: BoxDecoration(
                        color: customAppTheme.colorError,
                        shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  onTap: () {
                    gotoUpdateUserprofile();
                  },
                  child: Container(
                    margin: Spacing.left(16),
                    decoration: BoxDecoration(
                        color: customAppTheme.bgLayer1,
                        borderRadius: BorderRadius.all(
                            Radius.circular(MySize.size8)),
                        boxShadow: [
                          BoxShadow(
                              color: customAppTheme.shadowColor,
                              blurRadius: MySize.size4)
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(MySize.size8)),
                      child: _userModel == null
                          ? CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                              DikoubaColors.blue['pri']))
                          : Image(
                        image: _userModel.photo_url == ""
                            ? AssetImage(
                            './assets/logo/user_transparent.webp')
                            : NetworkImage(
                            _userModel.photo_url),
                        fit: BoxFit.cover,
                        width: MySize.size36,
                        height: MySize.size36,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 12,
            )
          ],
        ),
        body: WillPopScope(
          onWillPop: onWillPop2,
          child: _userModel == null
              ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  DikoubaColors.blue['pri']))
              : Container(
            child: _bodyCustom,
          ),
        ));
  }*/

  Drawer _appDrawer(){
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                gotoUpdateUserprofile();
              },
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,
                ),
                accountName: Text(
                  _userModel.name!,
                  style: Theme.of(context)
                      .textTheme
                      .headline6,
                ),
                accountEmail: Text(
                  _userModel.email!,
                  style:
                  Theme.of(context).textTheme.caption,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                  Theme.of(context).accentColor,
                  backgroundImage:
                  NetworkImage(_userModel.photo_url!),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = true;
                  _bodyCustom = Container();
                });
              },
              leading: Icon(
                Icons.home,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Accueil',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = EventMyEventScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                });
              },
              leading: Icon(
                Icons.event_note,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Mes évènements',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = EventSondagesScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                });
              },
              leading: Icon(
                Icons.trending_up_rounded,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              trailing: ValueListenableBuilder(
                valueListenable: _sondagesCount,
                builder: (_, value, __) => (value>0) ? Container(
                alignment: Alignment.center,
                width: 22,//MySize.size6,
                height: 22,//MySize.size6,
                decoration: BoxDecoration(
                    color: customAppTheme.colorError,
                    shape: BoxShape.circle),
                child: Text(value.toString(), /*style: AppTheme.getTextStyle(
                    themeData.textTheme.caption,
                    fontWeight: 600,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: Colors.white),*/),
              ) : Container(child:Text(""))),
              title: Text(
                'Mes sondages',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = UserMesNotificationsScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                });
              },
              leading: Icon(
                Icons.notifications,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              trailing: ValueListenableBuilder(
                valueListenable: _notifCount,
                builder: (_, value, __) => (value>0) ? Container(
                alignment: Alignment.center,
                width: 22,//MySize.size6,
                height: 22,//MySize.size6,
                decoration: BoxDecoration(
                    color: customAppTheme.colorError,
                    shape: BoxShape.circle),
                child: Text(value.toString(), /*style: AppTheme.getTextStyle(
                    themeData.textTheme.caption,
                    fontWeight: 600,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: Colors.white),*/),
              ) : Container(child:Text(""))),
              title: Text(
                'Notifications',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = EventMesTicketsScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                });
              },
              leading: Icon(
                Icons.shopping_cart,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              trailing: ValueListenableBuilder(
                valueListenable: _unpaidticketCount,
                builder: (_, value, __) => (value>0) ? Container(
                  alignment: Alignment.center,
                  width: 22,//MySize.size6,
                  height: 22,//MySize.size6,
                  decoration: BoxDecoration(
                      color: customAppTheme.colorError,
                      shape: BoxShape.circle),
                  child: Text(value.toString(), /*style: AppTheme.getTextStyle(
                      themeData.textTheme.caption,
                      fontWeight: 600,
                      letterSpacing: 0,
                      fontSize: 12,
                      color: Colors.white),*/),
                ) : Container(child:Text("")),
              ),
              title: Text(
                'Mes Achats',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = EventMesFavorisScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                });
              },
              leading: Icon(
                Icons.favorite,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                "Mes Favoris",
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  /*_scaffoldKey.currentState
                      .openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = EventScanTicketScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                });
              },
              leading: Icon(
                Icons.add_a_photo,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Scan tickets',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Autres",
                style:
                Theme.of(context).textTheme.bodyText2,
              ),
              trailing: Icon(
                Icons.remove,
                color: Theme.of(context)
                    .focusColor
                    .withOpacity(0.3),
              ),
            ),
            ListTile(
              onTap: () {
                gotoDevenirAnnoncer();
              },
              leading: Icon(
                Icons.admin_panel_settings_rounded,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                (_userModel.id_annoncers == null ||
                    _userModel.id_annoncers == "")
                    ? 'Devenir annonceur'
                    : 'Modifier annonceur',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                // Navigator.of(context).pop();
                signOut(context);
              },
              leading: Icon(
                Icons.logout,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Se déconnecter',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                //notify(); //To be deleted
                Navigator.of(context).pushNamed('/Help');
              },
              leading: Icon(
                Icons.help,
                color: DikoubaColors.blue[
                'pri'], //Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Support',
                style:
                Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Dikouba 1.0.4",
                style:
                Theme.of(context).textTheme.bodyText2,
              ),
              trailing: Icon(
                Icons.remove,
                color: Theme.of(context)
                    .focusColor
                    .withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _myAppBar(){
    return AppBar(
      centerTitle: false,
      elevation: 0,
      backgroundColor: customAppTheme.bgLayer1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        "Dikouba",
        /*style: AppTheme.getTextStyle(
            themeData.textTheme.headline5,
            fontSize: 24,
            fontWeight: 700,
            letterSpacing: -0.3,
            color: DikoubaColors.blue['pri']),*/
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: Spacing.all(10),
              decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  borderRadius: BorderRadius.all(
                      Radius.circular(MySize.size8)),
                  boxShadow: [
                    BoxShadow(
                        color: customAppTheme.shadowColor,
                        blurRadius: MySize.size4)
                  ]),
              child: InkWell(onTap: (){
                setState(() {
                  /*_scaffoldKey.currentState.openEndDrawer();*/ //To be corrected
                  _showTabview = false;
                  _bodyCustom = UserMesNotificationsScreen(
                    _userModel,
                    analytics: widget.analytics,
                    observer: widget.observer,);
                });
              },
                child:Icon(
                  MdiIcons.bell,
                  size: MySize.size18,
                  color: DikoubaColors.blue[
                  'pri'], //themeData.colorScheme.onBackground.withAlpha(160),
                ),),
            ),
            ValueListenableBuilder(
              valueListenable: _notifCount,
              builder: (_, value, __) => (value>0) ? Positioned(
              right: 4,
              top: MySize.size12,
              child: Container(
                alignment: Alignment.center,
                width: 12,//MySize.size6,
                height: 12,//MySize.size6,
                decoration: BoxDecoration(
                    color: customAppTheme.colorError,
                    shape: BoxShape.circle),
                child: Text("", /*style: AppTheme.getTextStyle(
                    themeData.textTheme.caption,
                    fontWeight: 600,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: Colors.white),*/),
              ),
            ) : Container())
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: () {
                gotoUpdateUserprofile();
              },
              child: Container(
                margin: Spacing.left(16),
                decoration: BoxDecoration(
                    color: customAppTheme.bgLayer1,
                    borderRadius: BorderRadius.all(
                        Radius.circular(MySize.size8)),
                    boxShadow: [
                      BoxShadow(
                          color: customAppTheme.shadowColor,
                          blurRadius: MySize.size4)
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(MySize.size8)),
                  child: _userModel == null
                      ? CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                          DikoubaColors.blue['pri']!))
                      : _userModel.photo_url == ""
                      ? Image(
                    image: AssetImage(
                        './assets/logo/user_transparent.webp'),
                    fit: BoxFit.cover,
                    width: MySize.size36,
                    height: MySize.size36,
                  ):Image(
                    image: NetworkImage(_userModel.photo_url!),
                    fit: BoxFit.cover,
                    width: MySize.size36,
                    height: MySize.size36,
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          width: 12,
        )
      ],
    );
  }
  
  Widget build(BuildContext context) {
    MySize().init(context);
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: _showTabview
              ? WillPopScope(
                  onWillPop: onWillPop,
                  child: Scaffold(
                    key: _scaffoldKey,
                    bottomNavigationBar: BottomAppBar(
                        elevation: 0,
                        shape: CircularNotchedRectangle(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeData.bottomAppBarTheme.color,
                            boxShadow: [
                              BoxShadow(
                                color: customAppTheme.shadowColor,
                                blurRadius: 3,
                                offset: Offset(0, -3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor: themeData.colorScheme.primary,
                            tabs: <Widget>[
                              Container(
                                child: (_currentIndex == 0)
                                    ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.home,
                                      color: DikoubaColors.blue['pri'],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                          color:
                                          DikoubaColors.blue['pri'],
                                          borderRadius:
                                          new BorderRadius.all(
                                              Radius.circular(2.5))),
                                      height: 5,
                                      width: 5,
                                    )
                                  ],
                                )
                                    : Icon(
                                  MdiIcons.homeOutline,
                                  color: DikoubaColors.blue['pri'],
                                ),
                              ),
                              Container(
                                  child: (_currentIndex == 1)
                                      ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        MdiIcons.calendar,
                                        color: DikoubaColors.blue['pri'],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                            color:
                                            DikoubaColors.blue['pri'],
                                            borderRadius: new BorderRadius
                                                .all(
                                                Radius.circular(2.5))),
                                        height: 5,
                                        width: 5,
                                      )
                                    ],
                                  )
                                      : Icon(
                                    MdiIcons.calendarOutline,
                                    color: DikoubaColors.blue['pri'],
                                  )),
                              Container(
                                  child: (_currentIndex == 2)
                                      ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.place,
                                        color: DikoubaColors.blue['pri'],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                            color:
                                            DikoubaColors.blue['pri'],
                                            borderRadius: new BorderRadius
                                                .all(
                                                Radius.circular(2.5))),
                                        height: 5,
                                        width: 5,
                                      )
                                    ],
                                  )
                                      : Icon(
                                    Icons.place_outlined, //mapOutline,
                                    color: DikoubaColors.blue['pri'],
                                  )),
                              Container(
                                  child: (_currentIndex == 3)
                                      ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        MdiIcons
                                            .youtubeTv, //ticketConfirmation,
                                        color: DikoubaColors.blue['pri'],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                            color:
                                            DikoubaColors.blue['pri'],
                                            borderRadius: new BorderRadius
                                                .all(
                                                Radius.circular(2.5))),
                                        height: 5,
                                        width: 5,
                                      )
                                    ],
                                  )
                                      : Icon(
                                    Icons
                                        .live_tv_rounded, //ticketConfirmationOutline,
                                    color: DikoubaColors.blue['pri'],
                                  )),
                            ],
                          ),
                        )),
                    drawer: _userModel == null
                        ? Container()
                        : _appDrawer(),
                    appBar: _myAppBar(),
                    body: _userModel == null
                        ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            DikoubaColors.blue['pri']!))
                        : TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        EventHomeScreen(
                          _userModel,
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ),
                        EventAgendaScreen(
                          _userModel,
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ),
                        EventMapScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ),
                        EventLiveScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ),
                        // EventProfileScreen(_userModel)
                      ],
                    ),
                    //)
                  ))
              : Scaffold(
                  key: _scaffoldKey,
                  drawer: _userModel == null
                      ? Container()
                      : _appDrawer(),
                  appBar: _myAppBar(),
                  body: WillPopScope(
                    onWillPop: onWillPop2,
                    child: _userModel == null
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                DikoubaColors.blue['pri']!))
                        : Container(
                            child: _bodyCustom,
                          ),
                  )),
        );
      },
    );
  }

  void gotoUpdateUserprofile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfileActivity(
                  _userModel,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
  }

  void signOut(BuildContext buildContext) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("NON"),
      onPressed: () {
        Navigator.of(context).pop("non");
      },
    );
    Widget continueButton = TextButton(
      child: Text("OUI"),
      onPressed: () {
        Navigator.of(context).pop("oui");
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Déconnexion"),
      content: Text("Voulez-vous vraiment vous déconnecter ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    var resPrompt = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    print("$TAG:resPrompt=$resPrompt");
    if (resPrompt == null || resPrompt == "non") return;

    await FirebaseAuthUi.instance().logout();
    await dbHelper.delete_user();

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    API.setDeviceToken(_userModel.id_users, fcmToken, "android", "delete").then((responseSetToken) {
      if (responseSetToken.statusCode == 200) {
        print(
            "$TAG:setDeviceToken ${responseSetToken.statusCode}|${responseSetToken.data}");

        if (!mounted) return;
      }
    }).catchError((errWalletAddr) {
      if (!mounted) return;
    });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChoseLoginSignupActivity(
            analytics: widget.analytics,
            observer: widget.observer,
          ),
        ));
  }

  void gotoDevenirAnnoncer() async {
    var resAc = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EvenNewAnnoncerActivity(
                  _userModel,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
    queryUser();
  }
}