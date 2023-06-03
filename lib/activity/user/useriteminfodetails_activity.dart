import 'dart:io';
import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/Generator.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class UserItemInfoDetailsActivity extends StatefulWidget {
  UserModel userModel;
  UserModel userInfoModel;
  bool hasFollow;
  UserItemInfoDetailsActivity(this.userModel, this.userInfoModel, this.hasFollow, {required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _UserItemInfoDetailsActivityState createState() => _UserItemInfoDetailsActivityState();
}

class _UserItemInfoDetailsActivityState extends State<UserItemInfoDetailsActivity> {

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late String desc;

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
                style: themeData.textTheme.titleSmall?.copyWith(
                    color: themeData.colorScheme.primary,
                    fontWeight: FontWeight.w600),
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
    desc = Generator.getDummyText(8);
    _setCurrentScreen();
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
                                child: widget.userInfoModel.photo_url == ""
                                    ? Image(
                                  image: AssetImage('./assets/logo/user_transparent.webp'),
                                  width: MySize.size60,
                                  height: MySize.size60,
                                ):Image(
                                    image: NetworkImage(widget.userInfoModel.photo_url!),
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
                                      style: themeData.textTheme.bodyLarge?.copyWith(
                                          color: themeData
                                              .colorScheme.onBackground,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      "${widget.userInfoModel.email}",
                                      style: themeData.textTheme.bodyMedium?.copyWith(
                                          color: themeData
                                              .colorScheme.onBackground,
                                          letterSpacing: 0, ),//muted: true),
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
                                    style: themeData.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: themeData
                                            .colorScheme.onPrimary)),)
                                  : widget.hasFollow
                              ? TextButton(
                                style: TextButton.styleFrom(
                                  padding: Spacing.fromLTRB(24, 8, 24, 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(MySize.size24)),
                                  //color: Colors.redAccent,
                                  //splashColor: themeData.colorScheme.onPrimary.withAlpha(100),
                                 // highlightColor: Colors.redAccent.withOpacity(0.3),
                                ),
                                onPressed: () {
                                  removeFollower();
                                },
                                child: Text("Unfollow",
                                    style: themeData.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color:
                                        themeData.colorScheme.onPrimary)),
                              )
                              : TextButton(
                                style: TextButton.styleFrom(
                                  padding: Spacing.fromLTRB(24, 8, 24, 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(MySize.size24)),
                                  //color: DikoubaColors.blue['pri'],
                                  //splashColor: themeData.colorScheme.onPrimary.withAlpha(100),
                                  //highlightColor: DikoubaColors.blue['pri'].withOpacity(0.3),
                                ),
                                onPressed: () {
                                  addFollower();
                                },
                                child: Text("Follow",
                                    style: themeData.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color:
                                        themeData.colorScheme.onPrimary)),
                              ),
                            ),
                            Container(
                              margin: Spacing.left(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.userInfoModel.nbre_followers}",
                                    style: themeData.textTheme.titleSmall?.copyWith(
                                        color:
                                        themeData.colorScheme.onBackground,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Followers",
                                    style: themeData.textTheme.bodySmall?.copyWith(
                                        color:
                                        themeData.colorScheme.onBackground, ),//muted: true),
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
                                    style: themeData.textTheme.titleSmall?.copyWith(
                                        color:
                                        themeData.colorScheme.onBackground,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Following",
                                    style: themeData.textTheme.caption?.copyWith(
                                        color:
                                        themeData.colorScheme.onBackground,
                                        //muted: true,
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
                          style: themeData.textTheme.titleMedium?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w700),
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
          widget.userInfoModel.nbre_followers = '${int.parse(widget.userInfoModel.nbre_followers!)+1}';
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
          widget.userInfoModel.nbre_followers = '${int.parse(widget.userInfoModel.nbre_followers!)-1}';
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

