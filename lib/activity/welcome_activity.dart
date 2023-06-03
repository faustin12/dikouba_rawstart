import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/home_activity.dart';
import 'package:dikouba_rawstart/activity/register_activity.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
//import 'package:firebase_auth_ui/firebase_auth_ui.dart';
//import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class WelcomeActivity extends StatefulWidget {
  WelcomeActivity({Key? key, required this.analytics, required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  WelcomeActivityState createState() => WelcomeActivityState();
}

class WelcomeActivityState extends State<WelcomeActivity> {
  static final String TAG = 'WelcomeActivityState';
  late ThemeData themeData;

  bool _is_creating = false;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

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
    // TODO: implement initState
    super.initState();
    _setCurrentScreen();
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    themeData = Theme.of(context);

    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                backgroundColor: themeData.scaffoldBackgroundColor,
                body: Container(
                  padding: EdgeInsets.only(
                      left: MySize.size24, right: MySize.size24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 28,
                      ),
                      Container(
                        width: MySize.screenWidth,
                        height: MySize.size180,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/logo/dikouba.webp',
                          width: MySize.size180,
                          height: MySize.size180,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                      ),
                      Expanded(
                        child: Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                          style: themeData.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0),
                        ),
                      ),
                      _is_creating
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DikoubaColors.blue['pri']!),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(MySize.size28)),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeData.cardTheme.shadowColor!.withAlpha(18),
                                    blurRadius: 4,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              width: MySize.screenWidth,
                              margin: EdgeInsets.symmetric(
                                  horizontal: MySize.size16),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.only(top: MySize.size12, bottom: MySize.size12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(MySize.size28)),
                                  //splashColor: themeData.colorScheme.secondary,
                                  //color: themeData.colorScheme.primary,
                                  //highlightColor: DikoubaColors.blue['lig'],
                                ),
                                onPressed: () {
                                  firebaseAuth();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Se connecter".toUpperCase(),
                                      style: themeData.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: themeData.backgroundColor,
                                          letterSpacing: 0.5),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: MySize.size16),
                                      child: Icon(
                                        MdiIcons.chevronRight,
                                        color: themeData.backgroundColor,
                                        size: MySize.size18,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                )));
      },
    );
  }

  void firebaseAuth() async {
    /*FirebaseAuthUi.instance().launchAuth(
      [
        AuthProvider.email(), // Login/Sign up with Email and password
        AuthProvider.google(), // Login with Google
        AuthProvider.phone(), // Login with Phone number
      ],
      tosUrl: "https://my-terms-url", // Optional
      privacyPolicyUrl: "https://my-privacy-policy", // Optional,
    ).then((firebaseUser) {
      print(
          "Logged in user is ${firebaseUser.isNewUser}|${firebaseUser.email}|${firebaseUser.uid}");

      createUserAccount(
          firebaseUser.phoneNumber,
          firebaseUser.uid,
          firebaseUser.displayName,
          firebaseUser.email,
          firebaseUser.photoUri,
          firebaseUser.isNewUser);
    }).catchError((error) => print("Error $error"));*/
  }

  void createUserAccount(String phoneNumber, String firebaseuid, String name,
      String email, String photoUri, bool isNewUser) async {
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
        email_verified: 'true', id_users: '');

    API.createUser(userModel).then((responseCreated) { //to be async
      print(
          "${TAG}:createUserAccount responseCreated = ${responseCreated.statusCode}|${responseCreated.data}");

      if (responseCreated.statusCode == 200) {
        UserModel user = new UserModel.fromJson(responseCreated.data);
        // insertUser(user);
        setState(() {
          _is_creating = false;
        });

        if (isNewUser) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterActivity(
                        userModel: user,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));
        } else {
          insertUser(user); //to be await
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeActivity(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));
        }
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
      DatabaseHelper.COLUMN_USER_EXPIREDATE: userModel.expire_date!.seconds,
      DatabaseHelper.COLUMN_USER_EMAILVERIFIED: userModel.email_verified,
      DatabaseHelper.COLUMN_USER_EMAIL: userModel.email,
      DatabaseHelper.COLUMN_USER_CREATEDAT: userModel.created_at!.seconds,
      DatabaseHelper.COLUMN_USER_UPDATEAT: userModel.updated_at!.seconds,
      DatabaseHelper.COLUMN_USER_IDANNONCER: userModel.id_annoncers,
      DatabaseHelper.COLUMN_USER_ANNONCER_CREATEDAT:
          userModel.annoncer_created_at!.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_UPDATEAT:
          userModel.annoncer_updated_at!.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_CHECKOUTPHONE:
          userModel.annoncer_checkout_phone_number,
      DatabaseHelper.COLUMN_USER_ANNONCER_COMPAGNY: userModel.annoncer_compagny,
      DatabaseHelper.COLUMN_USER_ANNONCER_COVERPICTUREPATH:
          userModel.annoncer_cover_picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_PICTUREPATH:
          userModel.annoncer_picture_path,
    };
    final id = await dbHelper.insert_user(row);
    print('${TAG}:insertUser inserted row id: $id \n $row');
  }
}
