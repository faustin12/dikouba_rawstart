import 'dart:async';
import 'dart:io';

import 'package:dikouba/activity/home_activity.dart';
import 'package:dikouba/activity/onboarding_activity.dart';
import 'package:dikouba/activity/welcome_activity.dart';
import 'package:dikouba/provider/databasehelper_provider.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

/// Component UI
class SplashScreen extends StatefulWidget {
  SplashScreen({this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {

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
    startTime();
    _setCurrentScreen();
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "SplashScreen",
      screenClassOverride: "SplashScreen",
    );
  }

  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 4500), NavigatorPage);
  }

  /// Navigate user if already login or no
  void NavigatorPage() async {
    final dbHelper = DatabaseHelper.instance;

    final userRows = await dbHelper.query_user();
    print('Main:queryUser query all rows:${userRows.length} | ${userRows.toString()}');

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>  userRows.length == 0 ? OnBoardingActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            ) : HomeActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            )),
    );
  }

  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    ///
    /// Check connectivity
    ///
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/cover.webp",
                  ),
                  fit: BoxFit.cover)),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Dikouba",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w200,
                        fontSize: 36.0,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
