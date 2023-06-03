import 'dart:async';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:dikouba/activity/home_activity.dart';
import 'package:dikouba/activity/login_activity.dart';
import 'package:dikouba/activity/register_activity.dart';
import 'package:dikouba/activity/signup_activity.dart';
import 'package:dikouba/activity/welcome_activity.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/provider/databasehelper_provider.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class ChoseLoginSignupActivity extends StatefulWidget {
  ChoseLoginSignupActivity({this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  ChoseLoginSignupActivityState createState() => ChoseLoginSignupActivityState();
}

/// Component Widget this layout UI
class ChoseLoginSignupActivityState extends State<ChoseLoginSignupActivity> with TickerProviderStateMixin {
  static final String TAG = 'ChoseLoginSignupActivityState';
  /// Declare Animation
  AnimationController animationController;
  var tapLogin = 0;
  var tapSignup = 0;
  bool _is_creating = false;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "ChoseLoginSignupActivity",
      screenClassOverride: "ChoseLoginSignupActivity",
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
    // TODO: implement initState
    /// Animation proses duration
    animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 300))
      ..addStatusListener((statuss) {
        if (statuss == AnimationStatus.dismissed) {
          setState(() {
            tapLogin = 0;
            tapSignup = 0;
          });
        }
      });
    super.initState();
    _setCurrentScreen();
  }

  /// To dispose animation controller
  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  /// Play animation set forward reverse
  Future<Null> _Playanimation() async {
    try {
      await animationController.forward();
      await animationController.reverse();
    } on TickerCanceled {}
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    mediaQuery.devicePixelRatio;
    mediaQuery.size.height;
    mediaQuery.size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          ///
          /// Set background image slider
          ///
          Container(
            color: Colors.white,
            child: new Carousel(
              boxFit: BoxFit.cover,
              autoplay: true,
              animationDuration: Duration(milliseconds: 300),
              dotSize: 0.0,
              dotSpacing: 16.0,
              dotBgColor: Colors.transparent,
              showIndicator: false,
              overlayShadow: false,
              images: [
                AssetImage(
                  "assets/carousel/event1.gif",
                ),
                AssetImage(
                  "assets/carousel/event1_img.webp",
                ),
                AssetImage(
                  "assets/carousel/event2.gif",
                ),
                AssetImage(
                  "assets/carousel/event2_img.webp",
                ),
                AssetImage(
                  "assets/carousel/event3.gif",
                ),
              ],
            ),
          ),
          Container(
            child: Container(
              /// Set gradient color in image (Click to open code)
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.3),
                        Color.fromRGBO(0, 0, 0, 0.4)
                      ],
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: mediaQuery.padding.top),
                  ),
                  Center(
                    /// Animation text event country accept from splashscreen layout (Click to open code)
                    child: Hero(
                      tag: "Event",
                      child: Text(
                        "DIKOUBA",
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.w900,
                          fontSize: 32.0,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w200,
                        fontFamily: "Sans",
                        letterSpacing: 1.3),
                  ),
                  Padding(padding: EdgeInsets.only(top: 0.0)),
                  _is_creating
                      ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white,
                          onTap: () {
                            _sendAnalyticsEvent("SignUp_Tap");
                            gotoSignUp();
                          },
                          child: ButtonCustom(txt: "Créer un compte"),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 15.0)),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            /// To set white line (Click to open code)
                            Container(
                              color: Colors.white,
                              height: 0.2,
                              width: 80.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0, right: 10.0),

                              /// navigation to home screen if user click "OR SKIP" (Click to open code)
                              child: Text(
                                "OU",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: "Sans",
                                    fontSize: 15.0),
                              ),
                            ),

                            /// To set white line (Click to open code)
                            Container(
                              color: Colors.white,
                              height: 0.2,
                              width: 80.0,
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 15.0)),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white,
                          onTap: () {
                            _sendAnalyticsEvent("Login_Tap");
                            gotoLogin();
                          },
                          child: ButtonCustom(txt: "Se connecter"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: MySize.size12,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void gotoSignUp() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            )));
  }

  void gotoLogin() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            )));
  }

  void firebaseAuth() async {
    FirebaseAuthUi.instance()
        .launchAuth(
      [
        AuthProvider.email(), // Login/Sign up with Email and password
        AuthProvider.google(), // Login with Google
        AuthProvider.phone(), // Login with Phone number
      ],
      tosUrl: "https://my-terms-url", // Optional
      privacyPolicyUrl: "https://my-privacy-policy", // Optional,
    ).then((firebaseUser) {
      print("Logged in user is ${firebaseUser.isNewUser}|${firebaseUser.email}|${firebaseUser.uid}");

      createUserAccount(firebaseUser.phoneNumber, firebaseUser.uid, firebaseUser.displayName, firebaseUser.email, firebaseUser.photoUri, firebaseUser.isNewUser);

    }
    )
        .catchError((error) => print("Error $error"));
  }


  void createUserAccount(String phoneNumber, String firebaseuid, String name, String email, String photoUri, bool isNewUser) async {
    setState(() {
      _is_creating = true;
    });
    UserModel userModel = new UserModel(
        phone: phoneNumber,
        uid: firebaseuid,
        name: name,
        email: email,
        photo_url: photoUri,
        password: firebaseuid,
        email_verified: 'true'
    );

    // teste si le user existe deja dans le systeme
    API.findUserItem(firebaseuid).then((resTestUser) async {
      print(
          "${TAG}:requestCustomerAddress ${resTestUser.statusCode}|${resTestUser.data}");
      if(resTestUser.statusCode == 200) {
        UserModel user = new UserModel.fromJson(resTestUser.data);
        await insertUser(user);
        setState(() {
          _is_creating = false;
        });

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeActivity(
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
        return;
      } else {
        createUserAccountNext(userModel);
      }
    }).catchError((onError) {
      print("updateUser:excep $onError");
      createUserAccountNext(userModel);
    });

  }

  void createUserAccountNext(UserModel userModel) {
    API.createUser(userModel)
        .then((responseCreated) async {
      print("${TAG}:createUserAccount responseCreated = ${responseCreated.statusCode}|${responseCreated.data}");

      if (responseCreated.statusCode == 200) {
        UserModel user = new UserModel.fromJson(responseCreated.data);
        // insertUser(user);
        setState(() {
          _is_creating = false;
        });

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterActivity(userModel: user,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));

      } else {
        DikoubaUtils.toast_error(
            context, "Service indisponible. veuillez réessayer plus tard");
        setState(() {
          _is_creating = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      print("${TAG}: ${errorLogin}");
      DikoubaUtils.toast_error(
          context, "Erreur réseau. Veuillez réessayer plus tard");
      setState(() {
        _is_creating = false;
      });
      return;
    });
  }

  void insertUser(UserModel userModel) async {
    dbHelper.delete_user();
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.COLUMN_USER_UID: userModel.uid,
      DatabaseHelper.COLUMN_USER_PHOTOURL: userModel.photo_url,
      DatabaseHelper.COLUMN_USER_PHONE: userModel.phone,
      DatabaseHelper.COLUMN_USER_PASSWORDHASH: userModel.password_hash,
      DatabaseHelper.COLUMN_USER_PASSWORD: userModel.password,
      DatabaseHelper.COLUMN_USER_NBREFOLLOWING: userModel.nbre_following,
      DatabaseHelper.COLUMN_USER_NBREFOLLOWERS: userModel.nbre_followers,
      DatabaseHelper.COLUMN_USER_NAME: userModel.name,
      DatabaseHelper.COLUMN_USER_IDUSERS: userModel.id_users,
      DatabaseHelper.COLUMN_USER_EXPIREDATE: userModel.expire_date.seconds,
      DatabaseHelper.COLUMN_USER_EMAILVERIFIED: userModel.email_verified,
      DatabaseHelper.COLUMN_USER_EMAIL: userModel.email,
      DatabaseHelper.COLUMN_USER_CREATEDAT: userModel.created_at.seconds,
      DatabaseHelper.COLUMN_USER_UPDATEAT: userModel.updated_at.seconds,
      DatabaseHelper.COLUMN_USER_IDANNONCER: userModel.id_annoncers,
      DatabaseHelper.COLUMN_USER_ANNONCER_CREATEDAT: userModel.annoncer_created_at.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_UPDATEAT: userModel.annoncer_updated_at.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_CHECKOUTPHONE: userModel.annoncer_checkout_phone_number,
      DatabaseHelper.COLUMN_USER_ANNONCER_COMPAGNY: userModel.annoncer_compagny,
      DatabaseHelper.COLUMN_USER_ANNONCER_COVERPICTUREPATH: userModel.annoncer_cover_picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_PICTUREPATH: userModel.annoncer_picture_path,
    };
    final id = await dbHelper.insert_user(row);
    print('${TAG}:insertUser inserted row id: $id \n $row');
  }
}

/// Button Custom widget
class ButtonCustom extends StatelessWidget {
  @override
  String txt;
  GestureTapCallback ontap;

  ButtonCustom({this.txt});

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.white,
        child: LayoutBuilder(builder: (context, constraint) {
          return Container(
            width: 300.0,
            height: 52.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.transparent,
                border: Border.all(color: Colors.white)),
            child: Center(
                child: Text(
                  txt,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Sans",
                      letterSpacing: 0.5),
                )),
          );
        }),
      ),
    );
  }
}

/// Set Animation Login if user click button login
class AnimationSplashLogin extends StatefulWidget {
  AnimationSplashLogin({this.analytics, this.observer, Key key, this.animationController})
      : animation = new Tween(
    end: 900.0,
    begin: 70.0,
  ).animate(CurvedAnimation(
      parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashLoginState createState() => _AnimationSplashLoginState();
}

/// Set Animation Login if user click button login
class _AnimationSplashLoginState extends State<AnimationSplashLogin> {

  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => new WelcomeActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            )));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}

/// Set Animation signup if user click button signup
class AnimationSplashSignup extends StatefulWidget {
  AnimationSplashSignup({this.analytics, this.observer, Key key, this.animationController})
      : animation = new Tween(
    end: 900.0,
    begin: 70.0,
  ).animate(CurvedAnimation(
      parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashSignupState createState() => _AnimationSplashSignupState();
}

/// Set Animation signup if user click button signup
class _AnimationSplashSignupState extends State<AnimationSplashSignup> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => new HomeActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            )));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}
