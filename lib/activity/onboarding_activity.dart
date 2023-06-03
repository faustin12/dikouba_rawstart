
import 'package:dikouba/activity/choseloginsignup_activity.dart';
import 'package:dikouba/activity/welcome_activity.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/widget/UI/Models/page_view_model.dart';
import 'package:dikouba/widget/intro_views_flutter.dart';
import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class OnBoardingActivity extends StatefulWidget {
  OnBoardingActivity({this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  OnBoardingActivityState createState() => OnBoardingActivityState();
}

var _fontHeaderStyle = TextStyle(
    fontFamily: "Arial",
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
    letterSpacing: 1.5);

var _fontDescriptionStyle = TextStyle(
    fontFamily: "Sans",
    fontSize: 17.0,
    color: Colors.black26,
    fontWeight: FontWeight.w300);

///
/// Page View Model for on boarding
///
final pages = [
  new PageViewModel(
      pageColor: Colors.white,
      iconColor: Colors.black,
      bubbleBackgroundColor: Colors.black,
      title: Text(
        'Planifier',
        style: _fontHeaderStyle,
      ),
      body: Container(
        height: 500.0,
        child: Text(
            'C’est dorénavant plus facile pour vous de planifier, faire la promotion et monétiser des événements virtuels, hybrides ou physiques.',
            textAlign: TextAlign.center,
            style: _fontDescriptionStyle),
      ),
      mainImage: Image.asset(
        'assets/images/onBoarding1.webp',
        height: 355.0,
        width: 355.0,
        alignment: Alignment.center,
      )),
  new PageViewModel(
      pageColor: Colors.white,
      iconColor: Colors.black,
      bubbleBackgroundColor: Colors.black,
      title: Text(
        'Promouvoir',
        style: _fontHeaderStyle,
      ),
      body: Container(
        height: 250.0,
        child: Text(
            'Dikouba vous offre la possibilité de susciter l’intérêt à travers l’ajout de spot vidéos, mais aussi de divertir votre audience physique ou virtuelle durant l’évènement à travers des sondages.',
            textAlign: TextAlign.center,
            style: _fontDescriptionStyle),
      ),
      mainImage: Image.asset(
        'assets/images/onBoarding2.webp',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      )),
  new PageViewModel(
      pageColor: Colors.white,
      iconColor: Colors.black,
      bubbleBackgroundColor: Colors.black,
      title: Text(
        'Rapprocher',
        style: _fontHeaderStyle,
      ),
      body: Container(
        height: 250.0,
        child: Text(
            'A travers son Live, il est désormais plus aisé de suivre l’événement à distance. Aussi, ne vous inquiétez plus si vous n’avez pas eu le temps d’échanger les contacts, vous avez la possibilité de suivre les autres participants sur Dikouba.',
            textAlign: TextAlign.center,
            style: _fontDescriptionStyle),
      ),
      mainImage: Image.asset(
        'assets/images/onBoarding3.webp',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      )),
  new PageViewModel(
      pageColor: Colors.white,
      iconColor: Colors.black,
      bubbleBackgroundColor: Colors.black,
      title: Text(
        'Interagir',
        style: _fontHeaderStyle,
      ),
      body: Container(
        height: 250.0,
        child: Text(
            'Dikouba, un moyen simple de communication entre organisateur et participants à travers un espace commentaire dédié et des sondages.',
            textAlign: TextAlign.center,
            style: _fontDescriptionStyle),
      ),
      mainImage: Image.asset(
        'assets/images/onBoarding4.webp',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      )),
];

class OnBoardingActivityState extends State<OnBoardingActivity> {
  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics().setUserId(uid);
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await FirebaseAnalytics().logEvent(
      name: name,
      parameters: <String, dynamic>{},
    );
  }
  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "OnBoardingActivity",
      screenClassOverride: "OnBoardingActivity",
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
    return IntroViewsFlutter(
      pages,
      pageButtonsColor: Colors.black45,
      skipText: Text(
        "Passer",
        style: _fontDescriptionStyle.copyWith(
            color: DikoubaColors.blue['pri'],
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            fontSize: 16.0),
      ),
      doneText: Text(
        "Continuer",
        style: _fontDescriptionStyle.copyWith(
            color: DikoubaColors.blue['pri'],
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            fontSize: 16.0),
      ),
      onTapSkipButton: () {
        _sendAnalyticsEvent("Boarding_Skip");
      },
      onTapDoneButton: () {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => new ChoseLoginSignupActivity(
            analytics: widget.analytics,
            observer: widget.observer,
          ),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget widget) {
            return Opacity(
              opacity: animation.value,
              child: widget,
            );
          },
          transitionDuration: Duration(milliseconds: 1500),
        ));
      },
    );
  }
}