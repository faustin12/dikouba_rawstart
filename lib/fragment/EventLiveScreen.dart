import 'dart:async';

import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/fragment/LiveItemFragment.dart';
import 'package:dikouba/library/bubbleTabCustom/bubbleTab.dart';
import 'package:dikouba/main.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EventLiveScreen extends StatefulWidget {
  EventLiveScreen({this.analytics, this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  _EventLiveScreenState createState() => _EventLiveScreenState();
}

class _EventLiveScreenState extends State<EventLiveScreen> {
  CustomAppTheme customAppTheme;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventCategoriseScreen",
      screenClassOverride: "EventCategoriseScreen",
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
    _setCurrentScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget child) {
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return MaterialApp(
          navigatorKey: MyApp.LiveNavigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DefaultTabController(
                  length: 6,
                  child: new Scaffold(
                    backgroundColor: Colors.white,
                    appBar: PreferredSize(
                      preferredSize:
                      Size.fromHeight(40.0), // here the desired height
                      child: new AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          centerTitle: true,
                          automaticallyImplyLeading: false,
                          title: new TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            unselectedLabelColor: Colors.black54,
                            labelColor: Colors.white,isScrollable: true,
                            labelStyle: TextStyle(fontSize: 19.0),
                            indicator: new BubbleTabIndicator(
                              indicatorHeight: 36.0,
                              indicatorColor: DikoubaColors.blue['pri'],//Color(0xFF928CEF),
                              tabBarIndicatorSize: TabBarIndicatorSize.tab,
                            ),
                            onTap: (indextab){
                              print("TabBar: indextab=$indextab");
                            },
                            tabs: <Widget>[
                              new Tab(
                                child: Text(
                                  "All",
                                  style: TextStyle(
                                    fontSize: 11.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              new Tab(
                                child: Text(
                                  "Sport",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              new Tab(
                                child: Text(
                                  "Art",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              new Tab(
                                child: Text(
                                  "Music",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              new Tab(
                                child: Text(
                                  "Ingenierie",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              new Tab(
                                child: Text(
                                  "Politique",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    body: Container(
                      child: LiveItemFragment(this.customAppTheme,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
        },
    );
  }
}
