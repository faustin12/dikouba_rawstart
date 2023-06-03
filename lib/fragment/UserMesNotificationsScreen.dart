import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/model/notification_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class UserMesNotificationsScreen extends StatefulWidget {
  UserModel userModel;
  UserMesNotificationsScreen(this.userModel, {required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _UserMesNotificationsScreenState createState() => _UserMesNotificationsScreenState();
}

class _UserMesNotificationsScreenState extends State<UserMesNotificationsScreen> {
  static final String TAG = '_UserMesNotificationsScreenState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  bool _isFinding = false;
  List<NotificationModel> _listNotifications = [];
  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "UserMesNotificationsScreen",
      screenClassOverride: "UserMesNotificationsScreen",
    );
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

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    findMesNotifications();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                body: Container(
              color: customAppTheme.bgLayer1,
              child: Column(
                children: [
                  Container(
                    margin: Spacing.fromLTRB(
                        MySize.size16, MySize.size8, MySize.size18, MySize.size2), //16 & 8 & 18 & 0
                    child: Text(
                      "Nombre de notifications ${_listNotifications.length}",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w500,
                        fontSize: MySize.size14
                      ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontSize: MySize.size14,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 500,
                          xMuted: true),*/
                    ),
                  ),
                  Expanded(
                      child: _isFinding
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DikoubaColors.blue['pri']!),
                              ),
                            )
                          : (_listNotifications == null || _listNotifications.length == 0)
                              ? Container(
                                  margin: Spacing.fromLTRB(MySize.size16,
                                      MySize.size8, MySize.size18, 0),
                                  child: Text(
                                    "Aucune notification trouvée",
                                    style: themeData.textTheme.bodySmall?.copyWith(
                                      color: themeData.colorScheme.onBackground,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12
                                    ),/*AppTheme.getTextStyle(
                                        themeData.textTheme.caption,
                                        fontSize: 12,
                                        color:
                                            themeData.colorScheme.onBackground,
                                        fontWeight: 500,
                                        xMuted: true),*/
                                  ),
                                )
                              : ListView.separated(
                                  padding: Spacing.zero,
                                  itemCount: _listNotifications.length,
                                  separatorBuilder: (context, index) {
                                    return Container(
                                      margin: Spacing.horizontal(16),
                                      child: Divider(
                                        height: 4,
                                        color: Theme.of(context)
                                            .hintColor
                                            .withOpacity(0.1),
                                      ),
                                    );
                                  },
                                  itemBuilder:
                                      (BuildContext buildcontext, int idx) {
                                    return singleNotification(_listNotifications[idx]);
                                  },
                                ))
                ],
              ),
            )));
      },
    );
  }

  Widget singleNotification(NotificationModel notoficationModel){
    return Container(
      margin: Spacing.symmetric(horizontal: 2, vertical: 2), //24 & 6
      child: SingleNotificationWidget(
          customAppTheme,
          notoficationModel,
          width: MySize.safeWidth - MySize.size48, analytics: widget.analytics, observer: widget.observer,)
    );
  }

  void findMesNotifications() async {
    setState(() {
      _isFinding = true;
    });
    API.findUserComments(widget.userModel.id_users).then((responseEvents) { //To be chaged to findUserNotifications
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesFavoris ${responseEvents.statusCode}|${responseEvents.data}");
        List<NotificationModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(NotificationModel.fromJson(responseEvents.data[i]));
        }

        if (!mounted) return;
        setState(() {
          _isFinding = false;
          _listNotifications = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
        setState(() {
          _isFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isFinding = false;
      });
    });
  }
}

class SingleNotificationWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  NotificationModel notificationModel;
  @required
  double width;
  SingleNotificationWidget(this.customAppTheme, this.notificationModel,
      {required this.width,
        required this.analytics,
        required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  SingleNotificationWidgetState createState() => SingleNotificationWidgetState();
}


class SingleNotificationWidgetState extends State<SingleNotificationWidget> {
  static final String TAG = 'SingleEventsWidgetState';

  late ThemeData themeData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    var _id = widget.notificationModel.id_notifications;

    return Container(
      padding: Spacing.vertical(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
          color: themeData.backgroundColor,
          border: Border.all(color: themeData.backgroundColor,width: 1),
          boxShadow: [
            BoxShadow(
                color: themeData.shadowColor,
                blurRadius: MySize.size4,
                offset: Offset(0, 1))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: Spacing.horizontal(24),
            child: Text(
              widget.notificationModel.title!,
              style: themeData.textTheme.titleSmall?.copyWith(
                color: themeData.colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: Spacing.horizontal(24),
            margin: Spacing.top(4),
            child: Text(
              widget.notificationModel.description!,
              style: themeData.textTheme.bodyMedium?.copyWith(
                color: themeData.colorScheme.onBackground,
                fontWeight: FontWeight.w500,
                height: 1.7,
                letterSpacing: 0.3
              ),
            ),
          ),
          Container(
              margin: Spacing.top(16),
              child: Divider(
                height: 0,
              )),
          Container(
            padding: Spacing.only(left: 24, right: 24, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  DateFormat('dd MMM yy').format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(widget.notificationModel.created_at!.seconds) * 1000)),
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: themeData.colorScheme.primary,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(widget.notificationModel.created_at!.seconds) * 1000)),
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: themeData.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(4),
            padding: Spacing.horizontal(24),
            child: Text(
              widget.notificationModel.action!,
              style: themeData.textTheme.bodyMedium?.copyWith(
                color: themeData.colorScheme.onBackground.withAlpha(160),
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }
}

