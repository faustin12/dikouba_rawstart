import 'dart:io';
import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/register_activity.dart';
import 'package:dikouba/activity/user/updateuser_activity.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/Generator.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class UserItemInfoDetailsActivity extends StatefulWidget {
  UserModel userModel;
  UserModel userInfoModel;
  bool hasFollow;
  UserItemInfoDetailsActivity(this.userModel, this.userInfoModel, this.hasFollow, {this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _UserItemInfoDetailsActivityState createState() => _UserItemInfoDetailsActivityState();
}

class _UserItemInfoDetailsActivityState extends State<UserItemInfoDetailsActivity> {

  ThemeData themeData;
  CustomAppTheme customAppTheme;

  String desc;

  List<String> _imageList = [
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
    './assets/logo/dikouba.webp',
  ];

  bool _isFollowChanging = false;

  _generateGridItems() {
    List<Widget> list = [];
    int size = 12;
    for (int i = 0; i < size; i++) {
      if (i < size-1) {
        list.add(Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8))
          ),
          child: Image(image: AssetImage(_imageList[i % 14]), fit: BoxFit.fill),
        ));
      } else {
        list.add(InkWell(
          splashColor: themeData.colorScheme.primary.withAlpha(100),
          highlightColor:  themeData.colorScheme.primary.withAlpha(28),
          onTap: (){

          },
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
                color: themeData.colorScheme.primary.withAlpha(28),
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8))
            ),

            child: Center(
              child: Text(
                "View All",
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                    color: themeData.colorScheme.primary,
                    fontWeight: 600),
              ),
            ),
          ),
        ));
      }
    }
    return list;
  }

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

                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      MdiIcons.chevronLeft,
                      size: MySize.size24,
                      color: themeData.colorScheme.onBackground,
                    ),
                  ),
                ),
                body: Container(
                  color: customAppTheme.bgLayer1,
                  child: ListView(
                    padding: Spacing.zero,
                    children: [
                      Container(
                        margin: Spacing.fromLTRB(24, 0, 24, 0),
                        child: Row(
                          children: [
                            Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(MySize.size30)),
                                child: Image(
                                  image: widget.userInfoModel.photo_url == ""
                                      ? AssetImage('./assets/logo/user_transparent.webp')
                                      : NetworkImage(widget.userInfoModel.photo_url),
                                  width: MySize.size60,
                                  height: MySize.size60,
                                ),
                              ),
                            ),
                            Container(
                              margin: Spacing.left(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      "${widget.userInfoModel.name}",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText1,
                                          color: themeData
                                              .colorScheme.onBackground,
                                          letterSpacing: 0,
                                          fontWeight: 600),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      "${widget.userInfoModel.email}",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData
                                              .colorScheme.onBackground,
                                          letterSpacing: 0,
                                          muted: true),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _isFollowChanging
                                  ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(MySize.size32)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: MySize.size8, vertical: MySize.size12),
                                alignment: Alignment.center,
                                child: Text("Veuillez patienter",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        fontWeight: 600,
                                        color: themeData
                                            .colorScheme.onPrimary)),)
                                  : widget.hasFollow
                              ? FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(MySize.size24)),
                                color: Colors.redAccent,
                                splashColor: themeData.colorScheme.onPrimary
                                    .withAlpha(100),
                                highlightColor: Colors.redAccent.withOpacity(0.3),
                                onPressed: () {
                                  removeFollower();
                                },
                                child: Text("Unfollow",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        fontWeight: 500,
                                        color:
                                        themeData.colorScheme.onPrimary)),
                                padding: Spacing.fromLTRB(24, 8, 24, 8),
                              )
                              : FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(MySize.size24)),
                                color: DikoubaColors.blue['pri'],
                                splashColor: themeData.colorScheme.onPrimary
                                    .withAlpha(100),
                                highlightColor: DikoubaColors.blue['pri'].withOpacity(0.3),
                                onPressed: () {
                                  addFollower();
                                },
                                child: Text("Follow",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        fontWeight: 500,
                                        color:
                                        themeData.colorScheme.onPrimary)),
                                padding: Spacing.fromLTRB(24, 8, 24, 8),
                              ),
                            ),
                            Container(
                              margin: Spacing.left(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.userInfoModel.nbre_followers}",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.subtitle2,
                                        color:
                                        themeData.colorScheme.onBackground,
                                        fontWeight: 600),
                                  ),
                                  Text(
                                    "Followers",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.caption,
                                        color:
                                        themeData.colorScheme.onBackground,
                                        muted: true),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: Spacing.left(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.userInfoModel.nbre_following}",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.subtitle2,
                                        color:
                                        themeData.colorScheme.onBackground,
                                        letterSpacing: 0,
                                        fontWeight: 600),
                                  ),
                                  Text(
                                    "Following",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.caption,
                                        color:
                                        themeData.colorScheme.onBackground,
                                        muted: true,
                                        letterSpacing: 0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(24, 24, 0, 0),
                        child: Text(
                          "Posts",
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle1,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 700),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: MySize.size8),
                        child: GridView.count(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            padding: Spacing.fromLTRB(24, 12, 24, 24),
                            crossAxisCount: 2,
                            mainAxisSpacing: MySize.size16,
                            crossAxisSpacing: MySize.size16,
                            children: _generateGridItems()),
                      )
                    ],
                  ),
                )));
      },
    );
  }
  void addFollower() async {
    setState(() {
      _isFollowChanging = true;
    });
    API.addFollower(widget.userModel.id_users, widget.userInfoModel.id_users).then((responseParticipant) {
      if (responseParticipant.statusCode == 200) {
        print(
            "findUserFollowers ${responseParticipant.statusCode}|${responseParticipant.data}");

        setState(() {
          _isFollowChanging = false;
          widget.hasFollow = true;
          widget.userInfoModel.nbre_followers = '${int.parse(widget.userInfoModel.nbre_followers)+1}';
        });
      } else {
        print("findEventsParticiapnts no data ${responseParticipant.toString()}");
        setState(() {
          _isFollowChanging = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("findEventsParticiapnts errorinfo ${errWalletAddr.toString()}");
      setState(() {
        _isFollowChanging = false;
      });
    });
  }

  void removeFollower() async {
    setState(() {
      _isFollowChanging = true;
    });
    API.deleteFollower(widget.userModel.id_users, widget.userInfoModel.id_users).then((responseParticipant) {
      if (responseParticipant.statusCode == 200) {
        print(
            "findUserFollowers ${responseParticipant.statusCode}|${responseParticipant.data}");

        setState(() {
          _isFollowChanging = false;
          widget.hasFollow = false;
          widget.userInfoModel.nbre_followers = '${int.parse(widget.userInfoModel.nbre_followers)-1}';
        });
      } else {
        print("findEventsParticiapnts no data ${responseParticipant.toString()}");
        setState(() {
          _isFollowChanging = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("findEventsParticiapnts errorinfo ${errWalletAddr.toString()}");
      setState(() {
        _isFollowChanging = false;
      });
    });
  }
}

