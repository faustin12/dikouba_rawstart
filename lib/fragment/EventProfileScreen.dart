import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/Generator.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EventProfileScreen extends StatefulWidget {
  UserModel userModel;

  EventProfileScreen(this.userModel,{required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventProfileScreenState createState() => _EventProfileScreenState();
}

class _EventProfileScreenState extends State<EventProfileScreen> {
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late String desc;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventProfileScreen",
      screenClassOverride: "EventProfileScreen",
    );
  }
  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics.instance.setUserId(id : uid);
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
    desc = Generator.getDummyText(8);
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
              child: ListView(
                padding: Spacing.top(48),
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: Spacing.fromLTRB(24, 8, 24, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                                Radius.circular(MySize.size50)),
                            child: widget.userModel == null
                                ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!))
                                : widget.userModel.photo_url == ""
                                ?Image(
                              image: AssetImage('./assets/logo/user_transparent.webp'),
                              width: MySize.size100,
                              height: MySize.size100,
                              fit: BoxFit.cover,
                            ):Image(
                              image: NetworkImage(widget.userModel.photo_url!),
                              width: MySize.size100,
                              height: MySize.size100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          margin: Spacing.top(8),
                          child: Text(
                            "${widget.userModel.name}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.titleLarge?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: customAppTheme.bgLayer1,
                        borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size8)),
                        border: Border.all(
                            color: customAppTheme.bgLayer4, width: 1)),
                    margin: Spacing.fromLTRB(24, 24, 24, 0),
                    padding: Spacing.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "My balance".toUpperCase(),
                              style: themeData.textTheme.bodySmall?.copyWith(
                                color: themeData.colorScheme.onBackground,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                              ),/*AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  fontSize: 12,
                                  fontWeight: 600,
                                  xMuted: true),*/
                            ),
                            Text(
                              "\$ 24",
                              style: themeData.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: Spacing.fromLTRB(16,8,16,8),
                          decoration: BoxDecoration(
                            color: themeData.colorScheme.primary.withAlpha(28),
                            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))
                          ),
                          child: Row(
                            children: [
                              Icon(
                                MdiIcons.plus,
                                color: themeData.colorScheme.primary,
                                size: MySize.size20,
                              ),
                              Container(
                                margin: Spacing.left(8),
                                  child: Text(
                                "Add Money",
                                style: themeData.textTheme.bodyMedium?.copyWith(
                                  color: themeData.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: Spacing.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "INVITE",
                          style: themeData.textTheme.bodyMedium?.copyWith(
                            color: themeData.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5
                          ),/*AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              fontSize: 11.5,
                              fontWeight: 600,
                              xMuted: true),*/
                        ),
                        Container(
                          margin: Spacing.top(16),
                          child: Row(
                            children: [
                              Container(
                                padding: Spacing.all(8),
                                decoration: BoxDecoration(
                                    color: themeData.colorScheme.primary,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(MySize.size8))),
                                child: Icon(
                                  MdiIcons.plus,
                                  size: MySize.size22,
                                  color: themeData.colorScheme.onPrimary,
                                ),
                              ),
                              Container(
                                margin: Spacing.left(16),
                                child: Text(
                                  "Add Friend",
                                  style: themeData.textTheme.bodyMedium?.copyWith(
                                    color: themeData.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: Spacing.top(16),
                          child: singleInvite(
                              image: './assets/images/avatar-2.jpg',
                              name: "Walter Gale",
                              status: "Joined"),
                        ),
                        Container(
                          margin: Spacing.top(16),
                          child: singleInvite(
                              image: './assets/images/avatar-3.jpg',
                              name: "Tala Deacon",
                              status: "Joined"),
                        ),
                        Container(
                          margin: Spacing.top(16),
                          child: singleInvite(
                              image: './assets/images/avatar-4.jpg',
                              name: "Isha Cameron",
                              status: "Invite"),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
      },
    );
  }

  Widget singleInvite({required String image, required String name, required String status}) {
    return Container(
      child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
              child: Image(
                image: AssetImage(image),
                width: MySize.size40,
                height: MySize.size40,
              )),
          Expanded(
            child: Container(
              margin: Spacing.left(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: themeData.textTheme.bodyMedium?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    status,
                    style: themeData.textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                    ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 500,
                        muted: true),*/
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: Spacing.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: themeData.colorScheme.primary.withAlpha(40),
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
            ),
            child: Text(
              "+ \$9",
              style: themeData.textTheme.bodySmall?.copyWith(
                color: themeData.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3
              ),
            ),
          )
        ],
      ),
    );
  }
}
