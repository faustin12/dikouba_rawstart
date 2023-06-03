import 'dart:io';
import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/user/useriteminfodetails_activity.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/model/userfollow_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/Generator.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class UserItemInfoActivity extends StatefulWidget {
  UserModel userModel;
  UserModel userInfoModel;
  UserItemInfoActivity(this.userModel, this.userInfoModel, {required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _UserItemInfoActivityState createState() => _UserItemInfoActivityState();
}

class _UserItemInfoActivityState extends State<UserItemInfoActivity> {

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late String desc;
  bool _hasFollowed = false;
  bool _isFollowChanging = true;
  List<UserFollowModel> usersFollow = [];

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "UserItemInfoActivity",
      screenClassOverride: "UserItemInfoActivity",
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
    findUserItem();
    findFollowers();
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
                body: Container(
                  child: Stack(
                    children: [
                      (widget.userInfoModel.photo_url == "" || widget.userInfoModel.photo_url == "null")
                          ? Image(
                        image: AssetImage('./assets/logo/user_transparent.webp'),
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ):Image(
                        image: NetworkImage(widget.userInfoModel.photo_url!),
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Positioned(
                        top: 48,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: Spacing.horizontal(24),
                          child: Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    MdiIcons.chevronLeft,
                                    size: MySize.size32,
                                    color: Colors.black,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withAlpha(220),
                                    Colors.black.withAlpha(160),
                                    Colors.black.withAlpha(100),
                                    Colors.black.withAlpha(0)
                                  ],
                                  stops: [
                                    0.25,
                                    0.5,
                                    0.75,
                                    1
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter)),
                          padding: Spacing.fromLTRB(24, 56, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.userInfoModel.name}",
                                style: themeData.textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "${widget.userInfoModel.email}",
                                style: themeData.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    //muted: true,
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                margin: Spacing.top(24),
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "125",
                                            style: themeData.textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            margin: Spacing.top(4),
                                            child: Text(
                                              "Posts",
                                              style: themeData.textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                  //muted: true,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(),
                                      Column(
                                        children: [
                                          Text(
                                            "${widget.userInfoModel.nbre_following}",
                                            style: themeData.textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            margin: Spacing.top(4),
                                            child: Text(
                                              "Following",
                                              style: themeData.textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                  //muted: true,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(),
                                      Column(
                                        children: [
                                          Text(
                                            "${widget.userInfoModel.nbre_followers}",
                                            style: themeData.textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            margin: Spacing.top(4),
                                            child: Text(
                                              "Followers",
                                              style: themeData.textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                  //muted: true,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: Spacing.top(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _isFollowChanging
                                      ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(120),
                                          borderRadius: BorderRadius.circular(MySize.size32)
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: MySize.size8, vertical: MySize.size12),
                                        alignment: Alignment.center,
                                        child: Text("Veuillez patienter",
                                            style: themeData.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: themeData
                                                    .colorScheme.onPrimary)),)
                                      : _hasFollowed
                                            ? TextButton(
                                                    style: TextButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(
                                                              MySize.size32)),
                                                      //color: Colors.redAccent,
                                                      //splashColor: Colors.white,
                                                      //highlightColor: themeData.primaryColor,
                                                    ),
                                                    onPressed: () {
                                                      removeFollower();
                                                    },
                                                    child: Text("Unfollow",
                                                        style: themeData.textTheme.bodyMedium?.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                            color: themeData
                                                                .colorScheme.onPrimary)),
                                                  )
                                            : TextButton(
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  MySize.size32)),
                                          //color: DikoubaColors.blue['pri'],
                                          //splashColor: Colors.white,
                                          //highlightColor: DikoubaColors.blue['pri'].withOpacity(0.3),
                                        ),
                                        onPressed: () {
                                          addFollower();
                                        },
                                        child: Text("Follow",
                                            style: themeData.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: themeData
                                                    .colorScheme.onPrimary)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        var resDetail = await Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => UserItemInfoDetailsActivity(widget.userModel, widget.userInfoModel, _hasFollowed,
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                        )));

                                        findFollowers();
                                      },
                                      child: Container(
                                          margin: Spacing.left(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(120),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: Spacing.all(12),
                                          child:Icon(MdiIcons.arrowRight,size: MySize.size20,color: Colors.white,)
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
      },
    );
  }

  void findUserItem() async {
    API.findUserItem(widget.userInfoModel.id_users).then((resUser) {
      if (resUser.statusCode == 200) {
        print(
            "requestCustomerAddress ${resUser.statusCode}|${resUser.data}");
        UserModel user = new UserModel.fromJson(resUser.data);
        setState(() {
          widget.userInfoModel = user;
        });

      } else {
        print("findOperations no data ${resUser.toString()}");
      }
    }).catchError((errWalletAddr) {
      print("infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
    });
  }
  
  void findFollowers() async {
    setState(() {
      _isFollowChanging = true;
    });
    API.findUserFollowers(widget.userInfoModel.id_users).then((responseParticipant) {
      if (responseParticipant.statusCode == 200) {
        print(
            "findUserFollowers ${responseParticipant.statusCode}|${responseParticipant.data}");
        List<UserFollowModel> list = [];
        for (int i = 0; i < responseParticipant.data.length; i++) {
          UserFollowModel papantMdl = UserFollowModel.fromJson(responseParticipant.data[i]);
          list.add(papantMdl);
          if(papantMdl.id_users_from == widget.userModel.id_users) {
            _hasFollowed = true;
          }
        }

        setState(() {
          _isFollowChanging = false;
          usersFollow = list;
          widget.userInfoModel.nbre_followers = list.length.toString();
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
          _hasFollowed = true;
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
          _hasFollowed = false;
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

