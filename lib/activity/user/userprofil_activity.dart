import 'dart:io';
import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/register_activity.dart';
import 'package:dikouba/activity/user/updateuser_activity.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/utils/Generator.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class UserProfileActivity extends StatefulWidget {
  UserModel userModel;
  UserProfileActivity(this.userModel, {this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _UserProfileActivityState createState() => _UserProfileActivityState();
}

class _UserProfileActivityState extends State<UserProfileActivity> {

  ThemeData themeData;
  CustomAppTheme customAppTheme;

  String desc;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "WelcomeActivity",
      screenClassOverride: "WelcomeActivity",
    );
  }
  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics().setUserId(uid);
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await FirebaseAnalytics().logEvent(
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
    desc = Generator.getDummyText(8);
    _setCurrentScreen();
    findUserItem();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                body: Container(
                  color: customAppTheme.bgLayer1,
                  child: ListView(
                    padding: Spacing.top(48),
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: Spacing.fromLTRB(24, 8, 24, 0),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size50)),
                              child: Image(
                                image: widget.userModel.photo_url == ''
                                  ? AssetImage('./assets/logo/user_transparent.webp')
                                : NetworkImage(widget.userModel.photo_url),
                                fit: BoxFit.cover,
                                width: MySize.size100,
                                height: MySize.size100,
                              ),
                            ),
                          ),
                          Container(

                          )
                        ],
                      ),
                      Container(
                        padding: Spacing.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${widget.userModel.name}",
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.headline6,
                                      fontWeight: 600),
                                ),
                                Container(
                                  margin: Spacing.top(4),
                                  child: Text(
                                    "${widget.userModel.annoncer_compagny}",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.caption),
                                  ),
                                ),
                                Text(
                                  "${widget.userModel.email}",
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.caption),
                                ),
                              ],
                            ),
                            FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(MySize.size4)),
                                color: themeData.colorScheme.primary,
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                                highlightColor: themeData.colorScheme.primary,
                                splashColor: themeData.splashColor,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UpdateUserActivity(userModel: widget.userModel,
                                            analytics: widget.analytics,
                                            observer: widget.observer,
                                          )));
                                },
                                child: Text(
                                  "Modifier",
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      fontWeight: 600,
                                      letterSpacing: 0.3,
                                      color: themeData.colorScheme.onPrimary),
                                ))
                          ],
                        ),
                      ),
                      Container(
                        padding: Spacing.fromLTRB(24, 24, 24, 0),
                        child: Container(
                          padding: EdgeInsets.all(MySize.size16),
                          decoration: BoxDecoration(
                              color: themeData.backgroundColor,
                              borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size4)),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: MySize.size2,
                                    color: customAppTheme.shadowColor),
                              ],
                              border: Border.all(
                                  color: customAppTheme.bgLayer4, width: 0.7)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    "15",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.subtitle1,
                                        fontWeight: 700),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: MySize.size8),
                                    child: Text("Posts",
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.subtitle2,
                                            fontWeight: 600,
                                            letterSpacing: 0)),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "${widget.userModel.nbre_followers}",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.subtitle1,
                                        fontWeight: 700),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: MySize.size8),
                                    child: Text(
                                      "Followers",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.subtitle2,
                                          fontWeight: 600,
                                          letterSpacing: 0),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "${widget.userModel.nbre_following}",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.subtitle1,
                                        fontWeight: 700),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: MySize.size8),
                                    child: Text(
                                      "Following",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.subtitle2,
                                          fontWeight: 600,
                                          letterSpacing: 0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Complete your profile",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.subtitle2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600,
                                  letterSpacing: 0),
                            ),
                            RichText(
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: "2 OF 4 ",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          fontSize: 11,
                                          fontWeight: 600,
                                          color: customAppTheme.colorSuccess)),
                                  TextSpan(
                                      text: " COMPLETE",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          color: themeData.colorScheme.onBackground,
                                          xMuted: true,
                                          fontSize: 11,
                                          fontWeight: 600)),
                                ]))
                          ],
                        ),
                      ),
                      Container(
                        margin: Spacing.top(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: Spacing.left(24),
                                child: singleCompleteWidget(
                                    iconData: MdiIcons.accountOutline,
                                    option: "Add Photo",
                                    title: "Add Profile Photo",
                                    desc: desc),
                              ),
                              Container(
                                margin: Spacing.left(24),
                                child: singleCompleteWidget(
                                    iconData: MdiIcons.chatOutline,
                                    option: "Add Bio",
                                    title: "Add Bio",
                                    desc: desc),
                              ),
                              Container(
                                margin: Spacing.horizontal(24),
                                child: singleCompleteWidget(
                                    iconData: MdiIcons.accountMultipleOutline,
                                    option: "Find More",
                                    title: "Find people",
                                    desc: desc),
                              ),

                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )));
      },
    );
  }

  Widget singleCompleteWidget(
      {IconData iconData, String title, String desc, String option}) {
    return Container(
      padding: Spacing.fromLTRB(24, 24, 24, 16),
      width: MySize.getScaledSizeWidth(220),
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer2,
          borderRadius: BorderRadius.all(Radius.circular(MySize.size4)),
          border: Border.all( color: customAppTheme.bgLayer4,width: 1)
      ),
      child: Column(
        children: [
          Container(
            padding: Spacing.all(8),
            decoration: BoxDecoration(
                border: Border.all(
                    color: themeData.colorScheme.onBackground.withAlpha(120),
                    width: 1.5),
                shape: BoxShape.circle),
            child: Icon(
              iconData,
              color: themeData.colorScheme.onBackground.withAlpha(180),
              size: MySize.size26,
            ),
          ),
          Container(
            margin: Spacing.top(12),
            child: Text(
              title,
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground, fontWeight: 600,letterSpacing: 0),
            ),
          ),
          Container(
            margin: Spacing.top(4),
            child: Text(
              desc,
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground, fontWeight: 400,letterSpacing: -0.2),textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: Spacing.top(12),
            padding: Spacing.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
                color: themeData.colorScheme.primary,
                borderRadius: BorderRadius.all(Radius.circular(MySize.size4))
            ),
            child: Text(
              option,
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onPrimary, fontWeight: 600),
            ),
          ),
        ],
      ),
    );
  }

  void findUserItem() async {
    API.findUserItem(widget.userModel.id_users).then((resUser) {
      if (resUser.statusCode == 200) {
        print(
            "requestCustomerAddress ${resUser.statusCode}|${resUser.data}");
        UserModel user = new UserModel.fromJson(resUser.data);
        setState(() {
          widget.userModel = user;
        });

      } else {
        print("findOperations no data ${resUser.toString()}");
      }
    }).catchError((errWalletAddr) {
      print("infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
    });
  }
}

