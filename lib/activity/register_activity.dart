import 'dart:io';

import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/home_activity.dart';
import 'package:dikouba/provider/firestorage_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dikouba/model/annoncer_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/provider/databasehelper_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class RegisterActivity extends StatefulWidget {
  UserModel userModel;
  RegisterActivity({Key key, this.userModel, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  RegisterActivityState createState() => RegisterActivityState();
}

class RegisterActivityState extends State<RegisterActivity> {
  static final String TAG = 'RegisterActivityState';

  Size _screenSize;
  String _selectedSexe;
  DateTime _birthday;
  bool _is_creating = false;

  bool _becomeAnnoncer = false;

  File _image;
  final picker = ImagePicker();

  TextEditingController nameCtrler;
  TextEditingController emailCtrler;
  TextEditingController phoneCtrler;
  TextEditingController anceurCompagnyCtrler;
  TextEditingController anceurPhoneCtrler;

  final _formKey = GlobalKey<FormState>();


  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print("$TAG:showDownloadProgress ${(received / total * 100).toStringAsFixed(0) + "%"}");
    }
  }

  void saveUserimgAndPush() async {
    var localFullPath = await API.downloadFileFromUrl(widget.userModel.photo_url, widget.userModel.uid, showDownloadProgress);
    print("$TAG:saveUserimgAndPush localFullPath=$localFullPath");
    if(localFullPath != null) {
      var downloadLink = await FireStorageProvider.fireUploadFileToRef(FireStorageProvider.FIRESTORAGE_REF_USERPROFILE, localFullPath, widget.userModel.uid);
      print("$TAG:saveUserimgAndPush downloadLink=$downloadLink");
      setState(() {
        widget.userModel.photo_url = downloadLink;
      });
    }
  }
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    print("$TAG:getImage downloadLink=${pickedFile.path}");

    if (pickedFile != null) {
      var downloadLink = await FireStorageProvider.fireUploadFileToRef(FireStorageProvider.FIRESTORAGE_REF_USERPROFILE, pickedFile.path, widget.userModel.uid);
      print("$TAG:getImage downloadLink=$downloadLink");
      setState(() {
        widget.userModel.photo_url = downloadLink;
      });
    } else {
      print('No image selected.');
    }
  }

  void _showBottomSheetPickImage(BuildContext buildContext) async {
    var resultAction = await showModalBottomSheet(
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
                        margin: EdgeInsets.only(left: MySize.size12, bottom: MySize.size8),
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
        });
    print("$TAG:showBottomSheetPickImage $resultAction");
    setState(() {
      _isImageUpdating = true;
    });
    PickedFile pickedFile = null;
    if(resultAction == 'camera') {
      pickedFile = await picker.getImage(source: ImageSource.camera);
    } else if(resultAction == 'gallerie') {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      var downloadLink = await FireStorageProvider.fireUploadFileToRef(FireStorageProvider.FIRESTORAGE_REF_USERPROFILE, pickedFile.path, widget.userModel.uid);
      print("$TAG:getImage downloadLink=$downloadLink");
      setState(() {
        widget.userModel.photo_url = downloadLink;
        _isImageUpdating = false;
      });
    } else {
      setState(() {
        _isImageUpdating = false;
      });
    }
  }

  ThemeData themeData;
  bool _passwordVisible = false;
  bool _isImageUpdating = false;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "RegisterActivity",
      screenClassOverride: "RegisterActivity",
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
    super.initState();
    print("$TAG: initState ${widget.userModel.toString()}");

    if(widget.userModel.photo_url == "") {
      saveUserimgAndPush();
    }

    nameCtrler = new TextEditingController();
    emailCtrler = new TextEditingController();
    phoneCtrler = new TextEditingController();
    anceurCompagnyCtrler = new TextEditingController();
    anceurPhoneCtrler = new TextEditingController();

    nameCtrler.text = widget.userModel.name;
    emailCtrler.text = widget.userModel.email;
    phoneCtrler.text = widget.userModel.phone;

    _setCurrentScreen();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                backgroundColor: themeData.scaffoldBackgroundColor,
                body: Container(
                  padding: EdgeInsets.only(left: MySize.size24, right: MySize.size24),
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          SizedBox(height: 30,),
                          Container(
                            child: Text(
                              "Création de compte",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.headline5,
                                  fontWeight: 600,
                                  letterSpacing: 0),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MySize.size24),
                            alignment: Alignment.center,
                            child: _isImageUpdating
                                ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DikoubaColors.blue['pri']),
                              ),
                            )
                                : Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: MySize.size16),
                                      width: MySize.getScaledSizeHeight(120.0),
                                      height: MySize.getScaledSizeHeight(120.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image:  DecorationImage(
                                            image: widget.userModel.photo_url == ""
                                                ? AssetImage('./assets/logo/user_transparent.webp')
                                                : NetworkImage(widget.userModel.photo_url),
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: MySize.size8,
                                      right: 0,
                                      child: Container(
                                        width: MySize.size44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: themeData.scaffoldBackgroundColor,
                                              width: 2,
                                              style: BorderStyle.solid),
                                          color: themeData.colorScheme.primary,
                                        ),
                                        child: Padding(
                                          padding:  EdgeInsets.all(MySize.size0),
                                          child: IconButton(
                                              icon: Icon(
                                                MdiIcons.pencil,
                                                size: MySize.size20,
                                                color: themeData.colorScheme.onPrimary,
                                              ),
                                              onPressed: (){
                                                _showBottomSheetPickImage(context);
                                                // download2(widget.userModel.photo_url, widget.userModel.uid);
                                              }),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Text("${widget.userModel.name}",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.headline6,
                                        fontWeight:600,
                                        letterSpacing: 0)),
                                Text("${widget.userModel.email == "" ? widget.userModel.phone : widget.userModel.email}",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.subtitle2,
                                        fontWeight: 500)),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MySize.size32),
                            child: TextFormField(
                              controller: nameCtrler,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Veuillez saisir le nom et prénom';
                                }
                                return null;
                              },
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Nom et prénom",
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                prefixIcon: Icon(MdiIcons.accountOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MySize.size16),
                            child: TextFormField(
                              controller: emailCtrler,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Veuillez saisir l\'adresse email';
                                }
                                if (!DikoubaUtils.isValidEmail(value.toString())) {
                                  return 'Adresse email invalide';
                                }
                                return null;
                              },
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Adresse email",
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                prefixIcon: Icon(MdiIcons.emailOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MySize.size16),
                            child: TextFormField(
                              controller: phoneCtrler,
                              validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Veuillez saisir le numéro de téléphone';
                                  }
                                  if (value.length < 9) {
                                    return 'Le numéro saisi est court';
                                  }
                                  return null;
                                },
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Numéro de téléphone",
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                prefixIcon: Icon(MdiIcons.phone,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              keyboardType: TextInputType.phone,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          MergeSemantics(
                            child: ListTile(
                              title: Text(
                                'Devenir annonceur',
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
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
                              },
                            ),
                          ),
                          _becomeAnnoncer
                              ? Container(
                            margin: EdgeInsets.only(top: MySize.size16),
                            child: TextFormField(
                              controller: anceurCompagnyCtrler,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Veuillez saisir l\'intitulé du compte annonceur';
                                }
                                return null;
                              },
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Intitulé compte annonceur",
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                prefixIcon: Icon(MdiIcons.hospitalBuilding,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          )
                              : Container(),
                          _becomeAnnoncer
                              ? Container(
                            margin: EdgeInsets.only(top: MySize.size16),
                            child: TextFormField(
                              controller: anceurPhoneCtrler,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Veuillez saisir le numéro de téléphone de l\'annonceur';
                                }
                                if (value.length < 9) {
                                  return 'Le numéro saisi est court';
                                }
                                return null;
                              },
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Numéro de téléphone annonceur",
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: themeData.colorScheme.surface,
                                        width: 1.2)),
                                prefixIcon: Icon(MdiIcons.phoneClassic,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              keyboardType: TextInputType.phone,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          )
                              : Container(),
                          _is_creating
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        DikoubaColors.blue['pri']),
                                  ),)
                              : Container(
                            margin: EdgeInsets.only(top: MySize.size24),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size28)),
                              boxShadow: [
                                BoxShadow(
                                  color: themeData.cardTheme.shadowColor
                                      .withAlpha(18),
                                  blurRadius: 4,
                                  offset: Offset(
                                      0, 3),
                                ),
                              ],
                            ),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(MySize.size28)),
                              splashColor: themeData.colorScheme.secondary,
                              color: themeData.colorScheme.primary,
                              highlightColor: DikoubaColors.blue['lig'],
                              onPressed: () {
                                handlerSaveForm(context);
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             MusicFullApp()));
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "Enregistrer".toUpperCase(),
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        fontWeight: 700,
                                        color:
                                        themeData.backgroundColor,
                                        letterSpacing: 0.5),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: MySize.size16),
                                    child: Icon(
                                      MdiIcons.arrowRight,
                                      color:
                                      themeData.backgroundColor,
                                      size: 18,
                                    ),
                                  )
                                ],
                              ),
                              padding:
                              EdgeInsets.only(top: MySize.size12, bottom: MySize.size12),
                            ),
                          ),
                          SizedBox(height: 24,)
                        ],
                      ),
                    ),
                  ),
                )));
      },
    );
  }

  void handlerSaveForm(BuildContext buildContext) {
    print("${TAG}:handlerSaveForm becomeAnnoncer=${_becomeAnnoncer}");
    // otherwise.
    if (_formKey.currentState.validate()) {
      // If the form is valid, display a Snackbar.
      print("${TAG}:handlerSaveForm ready to save data ");
      updateUserAccount(buildContext);
    }
  }
  void updateUserAccount(BuildContext buildContext) {
    setState(() {
      _is_creating = true;
    });
    UserModel userModel = new UserModel(
        phone: phoneCtrler.text,
        uid: widget.userModel.uid,
        name: nameCtrler.text,
        email: emailCtrler.text,
        photo_url: widget.userModel.photo_url,
        email_verified: 'true'
    );

    API.updateUser(userModel)
        .then((responseUpdated) {
      print("${TAG}:updateUser responseCreated = ${responseUpdated.statusCode}|${responseUpdated.data}");

      if (responseUpdated.statusCode == 200) {
        UserModel userSaved = new UserModel.fromJson(responseUpdated.data);
        if(_becomeAnnoncer) {
          AnnoncerModel annoncerModel = new AnnoncerModel(
            checkout_phone_number: anceurPhoneCtrler.text,
            compagny: anceurCompagnyCtrler.text,
            id_users: widget.userModel.uid,
            cover_picture_path: '',
            picture_path: ''
          );
          API.createAnnoncer(annoncerModel)
              .then((responseAnnon) {
            print("${TAG}:createAnnoncer responseCreated = ${responseAnnon.statusCode}|${responseAnnon.data}");

            if (responseAnnon.statusCode == 200) {
              AnnoncerModel annoncerCreated = new AnnoncerModel.fromJson(responseAnnon.data);

              insertUser(userSaved, annoncerCreated);
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
              DikoubaUtils.toast_error(
                  context, "Service indisponible. veuillez réessayer plus tard");
              setState(() {
                _is_creating = false;
              });
              return;
            }
          }).catchError((errorLogin) {
            print("${TAG}:createAnnoncer catchError ${errorLogin}");
            print("${TAG}:createAnnoncer catchError ${errorLogin.reponse.statusCode}|${errorLogin.reponse.data}");
            DikoubaUtils.toast_error(
                context, "Erreur réseau. Veuillez réessayer plus tard");
            setState(() {
              _is_creating = false;
            });
            return;
          });
        } else {

          insertUser(userSaved, null);
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
      print("${TAG}:updateUser catchError ${errorLogin}");
      print("${TAG}:createAnnoncer catchError ${errorLogin.reponse.statusCode}|${errorLogin.reponse.data}");
      DikoubaUtils.toast_error(
          context, "Erreur réseau. Veuillez réessayer plus tard");
      setState(() {
        _is_creating = false;
      });
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
      DatabaseHelper.COLUMN_USER_EXPIREDATE: userModel.expire_date.seconds,
      DatabaseHelper.COLUMN_USER_EMAILVERIFIED: userModel.email_verified,
      DatabaseHelper.COLUMN_USER_EMAIL: userModel.email,
      DatabaseHelper.COLUMN_USER_CREATEDAT: userModel.created_at.seconds,
      DatabaseHelper.COLUMN_USER_UPDATEAT: userModel.updated_at.seconds,
      DatabaseHelper.COLUMN_USER_IDANNONCER: annoncerModel == null ? '' : annoncerModel.id_annoncers,
      DatabaseHelper.COLUMN_USER_ANNONCER_PICTUREPATH: annoncerModel == null ? '' : annoncerModel.picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_COVERPICTUREPATH: annoncerModel == null ? '' : annoncerModel.cover_picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_COMPAGNY: annoncerModel == null ? '' : annoncerModel.compagny,
      DatabaseHelper.COLUMN_USER_ANNONCER_CHECKOUTPHONE: annoncerModel == null ? '' : annoncerModel.checkout_phone_number,
      DatabaseHelper.COLUMN_USER_ANNONCER_CREATEDAT: annoncerModel == null ? '' : annoncerModel.created_at.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_UPDATEAT: annoncerModel == null ? '' : annoncerModel.updated_at.seconds,
    };
    final id = await dbHelper.insert_user(row);
    print('${TAG}:insertUser inserted row id: $id');
  }
}
