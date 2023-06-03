import 'package:dikouba_rawstart/activity/home_activity.dart';
import 'package:dikouba_rawstart/activity/login_activity.dart';
import 'package:dikouba_rawstart/model/annoncer_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/provider/firestorage_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbUser;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class SignUpActivity extends StatefulWidget {
  SignUpActivity({required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SignUpActivityState createState() => _SignUpActivityState();
}

class _SignUpActivityState extends State<SignUpActivity> {
  static final String TAG = '_SignUpActivityState';

  bool _isSelected = false;
  late File selectedImage;
  late String filename;
  late File tempImage;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  late File _image;
  final picker = ImagePicker();

  late UserModel _userModel;
  late TextEditingController nameCtrler;
  late TextEditingController emailCtrler;
  late TextEditingController phoneCtrler;
  late TextEditingController passwordCtrler;
  late TextEditingController passwordConfCtrler;
  late TextEditingController anceurCompagnyCtrler;
  late TextEditingController anceurPhoneCtrler;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "SignUpActivity",
      screenClassOverride: "SignUpActivity",
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

  ///
  /// Response file from image picker
  ///
  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
        } else {}
      });
    } else {}
  }

  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;
  bool _becomeAnnoncer = false;

  late ThemeData themeData;

  late PickedFile _pickedFileprofil;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  ///
  /// Show password
  ///
  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  ///
  /// Show password
  ///
  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

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

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

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

    nameCtrler = new TextEditingController();
    emailCtrler = new TextEditingController();
    phoneCtrler = new TextEditingController();
    anceurCompagnyCtrler = new TextEditingController();
    anceurPhoneCtrler = new TextEditingController();
    passwordConfCtrler = new TextEditingController();
    passwordCtrler = new TextEditingController();

    _setCurrentScreen();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334);//, allowFontScaling: true);

    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 100.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Text("Dikouba",
                          style: TextStyle(
                              fontFamily: "Sofia",
                              fontSize: ScreenUtil.getInstance().setSp(60),
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
                              color: Colors.black12.withOpacity(0.08),
                              offset: Offset(0.0, 15.0),
                              blurRadius: 15.0),
                          BoxShadow(
                              color: Colors.black12.withOpacity(0.01),
                              offset: Offset(0.0, -10.0),
                              blurRadius: 10.0),
                        ]),
                    child: Padding(
                      padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 160.0,
                              height: 45.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(80.0)),
                                color: DikoubaColors.blue['pri'],
                              ),
                              child: Center(
                                child: Text("Création de compte ",
                                    style: TextStyle(
                                        fontSize:
                                        ScreenUtil.getInstance().setSp(32),
                                        fontFamily: "Sofia",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: .63)),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().setHeight(30),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: 100.0,
                                          width: 100.0,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50.0)),
                                              color: DikoubaColors.blue['pri'],
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    blurRadius: 10.0,
                                                    spreadRadius: 4.0)
                                              ]),
                                          child: new Stack(
                                            children: <Widget>[
                                              selectedImage == null
                                                  ? CircleAvatar(
                                                backgroundColor:
                                                DikoubaColors.blue['pri'],
                                                radius: 400.0,
                                                backgroundImage:
                                                AssetImage(
                                                  "./assets/logo/user_transparent.webp",
                                                ),)
                                                  : new CircleAvatar(
                                                backgroundImage:
                                                new FileImage(
                                                    selectedImage),
                                                radius: 400.0,
                                              ),
                                              Align(
                                                alignment:
                                                Alignment.bottomRight,
                                                child: InkWell(
                                                  onTap: () {
                                                    _showBottomSheetPickImage(context);
                                                  },
                                                  child: Container(
                                                    height: 30.0,
                                                    width: 30.0,
                                                    decoration:
                                                    BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              50.0)),
                                                      color: DikoubaColors.blue['pri'],
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        color:
                                                        Colors.white,
                                                        size: 18.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          "Photo de Profile",
                                          style: TextStyle(
                                              fontFamily: "Sofia",
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text("Nom et prénom",
                                      style: TextStyle(
                                          fontFamily: "Sofia",
                                          fontSize: ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9,
                                          fontWeight: FontWeight.w600)),
                                  TextFormField(
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir le nom et prénom';
                                      }
                                      return null;
                                    },
                                    controller: nameCtrler,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                    TextCapitalization.words,
                                    style: TextStyle(
                                        fontFamily: "WorkSofiaSemiBold",
                                        fontSize: 16.0,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.user,
                                        size: 19.0,
                                        color: Colors.black45,
                                      ),
                                      hintText: "Nom et prénom",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sofia", fontSize: 15.0),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text("Adresse email",
                                      style: TextStyle(
                                          fontFamily: "Sofia",
                                          fontSize: ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9,
                                          fontWeight: FontWeight.w600)),
                                  TextFormField(
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir l\'adresse email';
                                      }
                                      if (!DikoubaUtils.isValidEmail(input.toString())) {
                                        return 'Adresse email invalide';
                                      }
                                      return null;
                                    },
                                    controller: emailCtrler,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                        fontFamily: "WorkSofiaSemiBold",
                                        fontSize: 16.0,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.envelope,
                                        color: Colors.black45,
                                        size: 18.0,
                                      ),
                                      hintText: "Adresse email",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sofia", fontSize: 16.0),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text("Numéro de téléphone",
                                      style: TextStyle(
                                          fontFamily: "Sofia",
                                          fontSize: ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9,
                                          fontWeight: FontWeight.w600)),
                                  TextFormField(
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir le numéro de téléphone';
                                      }
                                      if (input.length < 6) {
                                        return 'Le numéro saisi est court';
                                      }
                                      return null;
                                    },
                                    controller: phoneCtrler,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                        fontFamily: "WorkSofiaSemiBold",
                                        fontSize: 16.0,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.envelope,
                                        color: Colors.black45,
                                        size: 18.0,
                                      ),
                                      hintText: "Numéro de téléphone",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sofia", fontSize: 16.0),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text("Mot de passe",
                                      style: TextStyle(
                                          fontFamily: "Sofia",
                                          fontSize: ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9,
                                          fontWeight: FontWeight.w600)),
                                  TextFormField(
                                    controller: passwordCtrler,
                                    obscureText: _obscureTextSignup,
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir le Mot de passe';
                                      }
                                      if (input.length < 8) {
                                        return 'Le Mot de passe doit avoir au moins 6 caractères';
                                      }
                                    },
                                    style: TextStyle(
                                        fontFamily: "WorkSofiaSemiBold",
                                        fontSize: 16.0,
                                        color: Colors.black45),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.black45,
                                        size: 18.0,
                                      ),
                                      hintText: "Mot de passe",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sofia", fontSize: 16.0),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggleSignup();
                                        },
                                        child: Icon(
                                          FontAwesomeIcons.eye,
                                          size: 15.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text("Confirmer le mot de passe",
                                      style: TextStyle(
                                          fontFamily: "Sofia",
                                          fontSize: ScreenUtil.getInstance()
                                              .setSp(30),
                                          letterSpacing: .9,
                                          fontWeight: FontWeight.w600)),
                                  TextFormField(
                                    controller: passwordConfCtrler,
                                    obscureText: _obscureTextSignupConfirm,
                                    validator: (input) {
                                      if (input!.isEmpty) {
                                        return 'Veuillez saisir de nouveau le Mot de passe';
                                      }
                                      if (input.length < 8) {
                                        return 'Le Mot de passe doit avoir au moins 6 caractères';
                                      }
                                      if (passwordCtrler.text != passwordConfCtrler.text) {
                                        return 'Les Mots de passe ne correspondent pas';
                                      }
                                    },
                                    style: TextStyle(
                                        fontFamily: "WorkSofiaSemiBold",
                                        fontSize: 16.0,
                                        color: Colors.black45),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.black45,
                                        size: 18.0,
                                      ),
                                      hintText: "Mot de passe",
                                      hintStyle: TextStyle(
                                          fontFamily: "Sofia", fontSize: 16.0),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggleSignupConfirm();
                                        },
                                        child: Icon(
                                          FontAwesomeIcons.eye,
                                          size: 15.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  MergeSemantics(
                                    child: ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text(
                                        'Devenir annonceur',
                                        style: themeData.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      trailing: CupertinoSwitch(
                                        value: _becomeAnnoncer,
                                        onChanged: (bool value) {
                                          setState(() {
                                            _becomeAnnoncer = value;
                                          });
                                        },
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _becomeAnnoncer = !_becomeAnnoncer;
                                        });
                                        _sendAnalyticsEvent("Becomme_annonceur_=_" + _becomeAnnoncer.toString());
                                      },
                                    ),
                                  ),
                                  !_becomeAnnoncer
                                      ? Container()
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text("Intitulé compte annonceur",
                                          style: TextStyle(
                                              fontFamily: "Sofia",
                                              fontSize: ScreenUtil.getInstance()
                                                  .setSp(30),
                                              letterSpacing: .9,
                                              fontWeight: FontWeight.w600)),
                                      TextFormField(
                                        validator: (input) {
                                          if (input!.isEmpty) {
                                            return 'Veuillez saisir l\'intitulé du compte annonceur';
                                          }
                                          return null;
                                        },
                                        controller: anceurCompagnyCtrler,
                                        keyboardType: TextInputType.text,
                                        style: TextStyle(
                                            fontFamily: "WorkSofiaSemiBold",
                                            fontSize: 16.0,
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          icon: Icon(
                                            FontAwesomeIcons.envelope,
                                            color: Colors.black45,
                                            size: 18.0,
                                          ),
                                          hintText: "Intitulé compte annonceur",
                                          hintStyle: TextStyle(
                                              fontFamily: "Sofia", fontSize: 16.0),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text("Numéro de téléphone annonceur",
                                          style: TextStyle(
                                              fontFamily: "Sofia",
                                              fontSize: ScreenUtil.getInstance()
                                                  .setSp(30),
                                              letterSpacing: .9,
                                              fontWeight: FontWeight.w600)),
                                      TextFormField(
                                        validator: (input) {
                                          if (input!.isEmpty) {
                                            return 'Veuillez saisir le numéro de téléphone de l\'annonceur';
                                          }
                                          if (input.length < 6) {
                                            return 'Le numéro saisi est trop court';
                                          }
                                          return null;
                                        },
                                        controller: anceurPhoneCtrler,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(
                                            fontFamily: "WorkSofiaSemiBold",
                                            fontSize: 16.0,
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          icon: Icon(
                                            FontAwesomeIcons.envelope,
                                            color: Colors.black45,
                                            size: 18.0,
                                          ),
                                          hintText: "Numéro de téléphone",
                                          hintStyle: TextStyle(
                                              fontFamily: "Sofia", fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  // Text("Re-Password",
                                  //     style: TextStyle(
                                  //         fontFamily: "Sofia",
                                  //         fontSize:
                                  //             ScreenUtil.getInstance()
                                  //                 .setSp(30),
                                  //         letterSpacing: .9,
                                  //         fontWeight: FontWeight.w600)),
                                  // TextFormField(
                                  //   controller:
                                  //       signupConfirmPasswordController,
                                  //   obscureText:
                                  //       _obscureTextSignupConfirm,
                                  //   validator: (input) {
                                  //     if (input.isEmpty) {
                                  //       return 'Please re-input your password';
                                  //     }
                                  //   },
                                  //   onSaved: (input) => _pass2 = input,
                                  //   style: TextStyle(
                                  //       fontFamily: "WorkSofiaSemiBold",
                                  //       fontSize: 16.0,
                                  //       color: Colors.black45),
                                  //   decoration: InputDecoration(
                                  //     border: InputBorder.none,
                                  //     icon: Icon(
                                  //       FontAwesomeIcons.lock,
                                  //       color: Colors.black45,
                                  //       size: 18.0,
                                  //     ),
                                  //     hintText: "Password",
                                  //     hintStyle: TextStyle(
                                  //         fontFamily: "Sofia",
                                  //         fontSize: 16.0),
                                  //     suffixIcon: GestureDetector(
                                  //       onTap: () {
                                  //         _toggleSignupConfirm();
                                  //       },
                                  //       child: Icon(
                                  //         FontAwesomeIcons.eye,
                                  //         size: 15.0,
                                  //         color: Colors.black,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height:
                                    ScreenUtil.getInstance().setHeight(35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: "Poppins-Medium")),
                          SizedBox(
                            width: 8.0,
                          ),
                        ],
                      ),
                      Expanded(child: InkWell(
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
                                    color: DikoubaColors.blue['pri']!.withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                handlerSaveForm(context);
                                _sendAnalyticsEvent("Validate_SignUp");
                              },
                              child: Center(
                                child: Text("S'inscrire",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 18,
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
                      Text("Avez-vous un compte?",
                          style:
                          TextStyle(fontSize: 13.0, fontFamily: "Sofia")),
                      horizontalLine()
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _sendAnalyticsEvent("Switch_from_SignUp_to_LogIn");
                            gotoLogin(context);
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
                              child: Text("Se connecter",
                                  style: TextStyle(
                                      color: DikoubaColors.blue['pri'],
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 1.4,
                                      fontSize: 15.0,
                                      fontFamily: "Sofia")),
                            ),
                          ),
                        ),
                      )
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

  void gotoLogin(BuildContext buildContext) {

    Navigator.pushReplacement(
        buildContext,
        MaterialPageRoute(
            builder: (context) => LoginActivity(
              analytics: widget.analytics,
              observer: widget.observer,
            )));
  }

  void _showBottomSheetPickImage(BuildContext buildContext) async {
    /*var resultAction = await showModalBottomSheet(
        context: buildContext,
        builder: (BuildContext buildContext) {
          return Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: themeData.backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(MySize.size16),
                      topRight: Radius.circular(MySize.size16))),
              child: Padding(
                padding: EdgeInsets.all(MySize.size16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          "Choisir a partir de",
                          style: themeData.textTheme.caption.merge(TextStyle(
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(200),
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w700)),
                        )),
                    ListTile(
                      dense: true,
                      onTap: (){
                        Navigator.of(buildContext).pop('camera');
                      },
                      leading: Icon(MdiIcons.camera,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(220)),
                      title: Text(
                        "Caméra",
                        style: themeData.textTheme.bodyText1.merge(TextStyle(
                            color: themeData.colorScheme.onBackground,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500)),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: (){
                        Navigator.of(buildContext).pop('gallerie');
                      },
                      leading: Icon(MdiIcons.imageAlbum,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(220)),
                      title: Text(
                        "Gallerie",
                        style: themeData.textTheme.bodyText1.merge(TextStyle(
                            color: themeData.colorScheme.onBackground,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });*/
    var resultAction = 'gallerie';
    if(resultAction == 'camera') {
      _pickedFileprofil = (await picker.getImage(source: ImageSource.camera))!;
    } else if(resultAction == 'gallerie') {
      _pickedFileprofil = (await picker.getImage(source: ImageSource.gallery))!;
    }
    setState(() {
      selectedImage = new File(_pickedFileprofil.path);
    });
  }

  void handlerSaveForm(BuildContext buildContext) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });
      
      UserModel userMdl = new UserModel(id_users: '');
      userMdl.name = nameCtrler.text;
      userMdl.email = emailCtrler.text;
      userMdl.phone = phoneCtrler.text;
      userMdl.password = passwordCtrler.text;
      userMdl.annoncer_compagny = anceurCompagnyCtrler.text;
      userMdl.annoncer_checkout_phone_number = anceurPhoneCtrler.text;
      userMdl.photo_url = '';
      userMdl.email_verified = 'true';

      try {
        fbUser.UserCredential userCredential =
        await fbUser.FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: userMdl.email!, password: userMdl.password!);

        if (userCredential.user == null) {
          showDialog(
              context: buildContext,
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

        print("$TAG:register ${userCredential.user!.uid}");

        userMdl.uid = userCredential.user!.uid;

        _setUserId(userMdl.uid!);

        AnnoncerModel annoncerModel = new AnnoncerModel(
            checkout_phone_number: anceurPhoneCtrler.text,
            compagny: anceurCompagnyCtrler.text,
            id_users: userMdl.uid,
            cover_picture_path: '',
            picture_path: ''
        );

        if (_pickedFileprofil != null) {
          var downloadLink = await FireStorageProvider.fireUploadFileToRef(FireStorageProvider.FIRESTORAGE_REF_USERPROFILE, _pickedFileprofil.path, userMdl.uid!);
          print("$TAG:getImage downloadLink=$downloadLink");
          userMdl.photo_url = downloadLink;
        }

        createUserAccount(buildContext, userMdl, annoncerModel);

      } on fbUser.FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showDialog(
              context: buildContext,
              builder:
                  (BuildContext context) {
                return AlertDialog(
                  title: Text("Échec de connexion"),
                  content: Text(
                      "Mot de passe incorrect."),
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
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          showDialog(
              context: buildContext,
              builder:
                  (BuildContext context) {
                return AlertDialog(
                  title: Text("Échec de connexion"),
                  content: Text(
                      "Cet adresse email est déjà utilisé"),
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
      } catch (e) {
        showDialog(
            context: buildContext,
            builder:
                (BuildContext context) {
              return AlertDialog(
                title: Text("Échec de connexion"),
                content: Text(
                    "Impossible de créer votre compte"),
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
  }

  void handlerSaveFormInit(BuildContext buildContext) {
    print("${TAG}:handlerSaveForm becomeAnnoncer=${_becomeAnnoncer}");
    // otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a Snackbar.
      print("${TAG}:handlerSaveForm ready to save data ");
      // updateUserAccount(buildContext);
    }
  }

  void createUserAccount(BuildContext buildContext, UserModel userModel, AnnoncerModel annoncerModel) {

    API.createUser(userModel)
        .then((responseUpdated) {
      print("${TAG}:updateUser responseCreated = ${responseUpdated.statusCode}|${responseUpdated.data}");

      if (responseUpdated.statusCode == 200) {
        UserModel userSaved = new UserModel.fromJson(responseUpdated.data);
        if(_becomeAnnoncer) {
          API.createAnnoncer(annoncerModel)
              .then((responseAnnon) { //Should be async
            print("${TAG}:createAnnoncer responseCreated = ${responseAnnon.statusCode}|${responseAnnon.data}");

            if (responseAnnon.statusCode == 200) {
              AnnoncerModel annoncerCreated = new AnnoncerModel.fromJson(responseAnnon.data);

              insertUser(userSaved, annoncerCreated); //Should be await
              setState(() {
                isLoading = false;
              });

              Navigator.pushReplacement(
                  buildContext,
                  MaterialPageRoute(
                      builder: (context) => HomeActivity(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));
              return;
            } else {
              DikoubaUtils.toast_error(
                  buildContext, "Service indisponible. veuillez réessayer plus tard");
              setState(() {
                isLoading = false;
              });
              return;
            }
          }).catchError((errorLogin) {
            print("${TAG}:createAnnoncer catchError ${errorLogin}");
            print("${TAG}:createAnnoncer catchError ${errorLogin.reponse.statusCode}|${errorLogin.reponse.data}");
            DikoubaUtils.toast_error(
                buildContext, "Erreur réseau. Veuillez réessayer plus tard");
            setState(() {
              isLoading = false;
            });
            return;
          });
        } else {

          insertUser(userSaved, new AnnoncerModel());
          setState(() {
            isLoading = false;
          });

          Navigator.pushReplacement(
              buildContext,
              MaterialPageRoute(
                  builder: (context) => HomeActivity(
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )));
        }
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Service indisponible. veuillez réessayer plus tard");
        setState(() {
          isLoading = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        isLoading = false;
      });
      print("${TAG}:updateUser catchError ${errorLogin}");
      print("${TAG}:createAnnoncer catchError ${errorLogin.reponse.statusCode}|${errorLogin.reponse.data}");
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      return;
    });
  }

  void insertUser(UserModel userModel, AnnoncerModel annoncerModel) async {
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
      DatabaseHelper.COLUMN_USER_IDANNONCER: annoncerModel == null ? '' : annoncerModel.id_annoncers,
      DatabaseHelper.COLUMN_USER_ANNONCER_PICTUREPATH: annoncerModel == null ? '' : annoncerModel.picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_COVERPICTUREPATH: annoncerModel == null ? '' : annoncerModel.cover_picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_COMPAGNY: annoncerModel == null ? '' : annoncerModel.compagny,
      DatabaseHelper.COLUMN_USER_ANNONCER_CHECKOUTPHONE: annoncerModel == null ? '' : annoncerModel.checkout_phone_number,
      DatabaseHelper.COLUMN_USER_ANNONCER_CREATEDAT: annoncerModel == null ? '' : annoncerModel.created_at!.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_UPDATEAT: annoncerModel == null ? '' : annoncerModel.updated_at!.seconds,
    };
    final id = await dbHelper.insert_user(row);
    print('${TAG}:insertUser inserted row id: $id');
  }
}
