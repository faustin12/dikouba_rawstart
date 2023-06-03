import 'package:dikouba_rawstart/activity/home_activity.dart';
import 'package:dikouba_rawstart/activity/signup_activity.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class LoginActivity extends StatefulWidget {
  LoginActivity({required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  LoginActivityState createState() => new LoginActivityState();
}

class LoginActivityState extends State<LoginActivity> {
  static final String TAG = 'LoginActivityState';
  bool _isSelected = false;
  bool isLoading = false;

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  late String _email, _pass, _email2, _pass2, _name, _id;

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics.instance.setUserId(id: uid);
  }

  Future<void> _setCurrentScreen() async {
    await FirebaseAnalytics.instance.setCurrentScreen(
      screenName: "LoginActivity",
      screenClassOverride: "LoginActivity",
    );
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
  }

  ///
  /// Create Show Password
  ///
  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Widget radioButton(bool isSelected) => Container(
    width: 16.0,
    height: 16.0,
    padding: EdgeInsets.all(2.0),
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 2.0, color: Colors.black)),
    child: isSelected
        ? Container(
      width: double.infinity,
      height: double.infinity,
      decoration:
      BoxDecoration(shape: BoxShape.circle, color: Colors.black),
    )
        : Container(),
  );

  ///
  ///  Create line horizontal
  ///
  Widget horizontalLine() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.0),
    child: Container(
      width: ScreenUtil.getInstance().setWidth(120),
      height: 1.0,
      color: Colors.black26.withOpacity(.2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334);//, allowFontScaling: true);

    ///
    /// Loading user for check email and password to firebase database
    ///
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      ///
      /// Check loading for layout
      ///
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(top: 20.0),
                    alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/image_01.webp",
                  height: 250.0,
                ),
              )),
              Expanded(child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset("assets/images/image_02.webp"),
              ))
            ],
          )),
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
            child: Padding(
              padding:
              EdgeInsets.only(left: 28.0, right: 28.0, top: 100.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Text("Dikouba",
                          style: TextStyle(
                              fontFamily: "Popins",
                              fontSize:
                              ScreenUtil.getInstance().setSp(60),
                              letterSpacing: 1.2,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(180),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, 15.0),
                              blurRadius: 15.0),
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, -10.0),
                              blurRadius: 10.0),
                        ]),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 0.0, right: 0.0, top: 0.0),
                      child: Form(
                        key: _registerFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 120.0,
                              height: 45.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(80.0)),
                                color: DikoubaColors.blue['pri'],
                              ),
                              child: Center(
                                child: Text("Connexion",
                                    style: TextStyle(
                                        fontSize: ScreenUtil.getInstance()
                                            .setSp(36),
                                        fontFamily: "Popins",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: .63)),
                              ),
                            ),
                            SizedBox(
                              height:
                              ScreenUtil.getInstance().setHeight(30),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Email",
                                      style: TextStyle(
                                          fontFamily: "Popins",
                                          fontSize:
                                          ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9)),
                                  TextFormField(
                                    ///
                                    /// Add validator
                                    ///
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir l\'adresse email';
                                      }
                                    },
                                    onSaved: (input) => _email = input!,
                                    controller: loginEmailController,
                                    keyboardType:
                                    TextInputType.emailAddress,
                                    style: TextStyle(
                                        fontFamily: "WorkSansSemiBold",
                                        fontSize: 16.0,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.envelope,
                                        color: Colors.black45,
                                        size: 20.0,
                                      ),
                                      hintText: "Addresse email",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sans",
                                          fontSize: 15.0,
                                          letterSpacing: 1.5,
                                          color: Colors.black45),
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil.getInstance()
                                        .setHeight(30),
                                  ),
                                  Text("Mot de passe",
                                      style: TextStyle(
                                          fontFamily: "Popins",
                                          fontSize:
                                          ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9)),
                                  TextFormField(
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir le mot de passe';
                                      }
                                    },
                                    onSaved: (input) => _pass = input!,
                                    controller: loginPasswordController,
                                    obscureText: _obscureTextLogin,
                                    style: TextStyle(
                                        fontFamily: "Arial",
                                        fontSize: 16.0,
                                        color: Colors.black54),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        size: 20.0,
                                        color: Colors.black45,
                                      ),
                                      hintText: "Mot de passe",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sans",
                                          fontSize: 16.0,
                                          color: Colors.black54),
                                      suffixIcon: GestureDetector(
                                        onTap: _toggleLogin,
                                        child: Icon(
                                          FontAwesomeIcons.eye,
                                          size: 15.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil.getInstance()
                                        .setHeight(35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtil.getInstance().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 8.0,
                          ),
                          GestureDetector(
                            onTap: _radio,
                            child: radioButton(_isSelected),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text("Remember me",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Poppins-Medium")),
                          SizedBox(
                            width: 8.0,
                          ),
                        ],
                      ),
                      Expanded(
                          child: InkWell(
                        child: isLoading
                            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),),)
                            : Container(
                          width: ScreenUtil.getInstance().setWidth(330),
                          height: ScreenUtil.getInstance().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                DikoubaColors.blue['lig']!,
                                DikoubaColors.blue['dar']!
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                    DikoubaColors.blue['pri']!.withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                _sendAnalyticsEvent("Validate_LogIn");
                                checkSignIn(context);
                              },
                              child: Center(
                                child: Text("Se connecter",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 16,
                                        letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(40),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      horizontalLine(),
                      Text("Pas encore de compte ?",
                          style: TextStyle(
                              fontSize: 13.0, fontFamily: "Popins")),
                      horizontalLine()
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: InkWell(
                        onTap: () {
                          _sendAnalyticsEvent("Switch_from_LogIn_to_SignUp");
                          gotoSignUp();
                        },
                        child: Container(
                          height: 50.0,
                          width: 300.0,
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(40.0)),
                            border: Border.all(
                                color: DikoubaColors.blue['pri']!, width: 1.0),
                          ),
                          child: Center(
                            child: Text("Créer un compte",
                                style: TextStyle(
                                    color: DikoubaColors.blue['pri'],
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1.4,
                                    fontSize: 15.0,
                                    fontFamily: "Popins")),
                          ),
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                ],
              ),
            ),
          ))
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

  void checkSignIn(BuildContext buildContext) async {

    final formState =
        _registerFormKey.currentState;
    User? user;
    if (formState!.validate()) {
      formState.save();
      try {
        setState(() {
          isLoading = true;
        });

        UserCredential userCredential =
            await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _email,
          password: _pass,
        );
        user = userCredential.user!;
        // user.sendEmailVerification();

      } on FirebaseAuthException catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
        CircularProgressIndicator();
        print(e.message);
        print(_email);

        print(_pass);
      } catch(e){

      }
      finally {
        if (user != null) {
          print("$TAG: ${user.uid}");
          _setUserId(user.uid);
          makeSignIn(user.uid);
        } else {
          showDialog(
              context: context,
              builder:
                  (BuildContext context) {
                return AlertDialog(
                  title: Text("Échec de connexion"),
                  content: Text(
                      "Veuillez vérifier votre adresse email."),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Fermer"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop();
                      },
                    )
                  ],
                );
              });
          return;
        }
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(
                  "Veuillez vérifier votre adresse email"),
              actions: <Widget>[
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                )
              ],
            );
          });
      return;
    }
  }


  void makeSignIn(String firebaseuid) async {

    // teste si le user existe deja dans le systeme
    API.findUserItem(firebaseuid).then((resTestUser) async {
      print(
          "${TAG}:requestCustomerAddress ${resTestUser.statusCode}|${resTestUser.data}");
      if(resTestUser.statusCode == 200) {
        UserModel user = new UserModel.fromJson(resTestUser.data);
        insertUser(user); //Should be await

        setState(() {
          isLoading = false;
        });

        String fcmToken = (await FirebaseMessaging.instance.getToken())!;
        API.setDeviceToken(user.id_users, fcmToken, "android", "add").then((responseSetToken) {
          if (responseSetToken.statusCode == 200) {
            print(
                "$TAG:setDeviceToken ${responseSetToken.statusCode}|${responseSetToken.data}");

            if (!mounted) return;
          }
        }).catchError((errWalletAddr) {
          if (!mounted) return;
        });
        /*FirebaseMessaging().onTokenRefresh.listen((new_fcmToken) {
          // TODO: If necessary send token to application server.
          API.setDeviceToken(user.id_users, fcmToken, "android", "delete").then((responseSetToken) {
            if (responseSetToken.statusCode == 200) {
              print(
                  "$TAG:setDeviceToken ${responseSetToken.statusCode}|${responseSetToken.data}");
              API.setDeviceToken(user.id_users, new_fcmToken, "android", "add").then((responseSetToken) {
                if (responseSetToken.statusCode == 200) {
                  print(
                      "$TAG:setDeviceToken ${responseSetToken.statusCode}|${responseSetToken.data}");
                  fcmToken = new_fcmToken;
                  if (!mounted) return;
                }
              }).catchError((errWalletAddr) {
                if (!mounted) return;
              });
              if (!mounted) return;
            }
          }).catchError((errWalletAddr) {
            if (!mounted) return;
          });
          // Note: This callback is fired at each app startup and whenever a new
          // token is generated.
        }).onError((err) {
          // Error getting token.
        });*/

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeActivity(
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
        return;
      } else {
        setState(() {
          isLoading = false;
        });
        showDialog(
            context: context,
            builder:
                (BuildContext context) {
              return AlertDialog(
                title: Text("Echec de connexion"),
                content: Text(
                    "Compte inexistant. Veuillez créer un compte"),
                actions: <Widget>[
                  TextButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                  )
                ],
              );
            });
        return;
      }
    }).catchError((onError) {
      print("updateUser:excep $onError");

      setState(() {
        isLoading = false;
      });

      showDialog(
          context: context,
          builder:
              (BuildContext context) {
            return AlertDialog(
              title: Text("Echec de connexion"),
              content: Text(
                  "Compte inexistant. Veuillez créer un compte"),
              actions: <Widget>[
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                )
              ],
            );
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
      DatabaseHelper.COLUMN_USER_ANNONCER_CREATEDAT: userModel.annoncer_created_at!.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_UPDATEAT: userModel.annoncer_updated_at!.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_CHECKOUTPHONE: userModel.annoncer_checkout_phone_number,
      DatabaseHelper.COLUMN_USER_ANNONCER_COMPAGNY: userModel.annoncer_compagny,
      DatabaseHelper.COLUMN_USER_ANNONCER_COVERPICTUREPATH: userModel.annoncer_cover_picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_PICTUREPATH: userModel.annoncer_picture_path,
    };
    final id = await dbHelper.insert_user(row);
    print('${TAG}:insertUser inserted row id: $id \n $row');
  }
}

