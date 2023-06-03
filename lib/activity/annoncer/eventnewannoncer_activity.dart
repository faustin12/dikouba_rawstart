import 'dart:convert';
import 'dart:io';

import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/eventnewsessions_activity.dart';
import 'package:dikouba/activity/home_activity.dart';
import 'package:dikouba/activity/register_activity.dart';
import 'package:dikouba/fragment/EventCreateSession.dart';
import 'package:dikouba/model/annoncer_model.dart';
import 'package:dikouba/model/category_model.dart';
import 'package:dikouba/model/evenement_model.dart';
import 'package:dikouba/model/firebaselocation_model.dart';
import 'package:dikouba/model/package_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/provider/databasehelper_provider.dart';
import 'package:dikouba/provider/firestorage_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
//import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EvenNewAnnoncerActivity extends StatefulWidget {
  UserModel userModel;

  EvenNewAnnoncerActivity(this.userModel, {Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  EvenNewAnnoncerActivityState createState() => EvenNewAnnoncerActivityState();
}

class EvenNewAnnoncerActivityState extends State<EvenNewAnnoncerActivity> {
  static final String TAG = 'EvenNewAnnoncerActivityState';

  ThemeData themeData;
  CustomAppTheme customAppTheme;

  UserModel _userModel;

  Future<List<Widget>> widgetsView;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  GlobalKey<FormState> _formEventKey;

  TextEditingController libelleCtrler;
  TextEditingController phoneCtrler;

  final picker = ImagePicker();

  bool _isEventCreating = false;
  PickedFile _eventbanner;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    setState(() {
      _userModel = UserModel.fromJsonDb(userRows[0]);
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EvenNewAnnoncerActivity",
      screenClassOverride: "EvenNewAnnoncerActivity",
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
  void initState() {
    super.initState();
    _setCurrentScreen();
    queryUser();

    _formEventKey = GlobalKey<FormState>();
    libelleCtrler = new TextEditingController();
    phoneCtrler = new TextEditingController();

    libelleCtrler.text = widget.userModel.annoncer_compagny;
    phoneCtrler.text = widget.userModel.annoncer_checkout_phone_number;
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Container(
                    color: customAppTheme.bgLayer2,
                    child: Column(
                      children: [
                        Expanded(
                          child: Form(
                              key: _formEventKey,
                              child: ListView(
                                padding: Spacing.vertical(16),
                                children: [
                                  SizedBox(height: MySize.size26,),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 24, 24, 0),
                                    child: Text(
                                      "Devenir annonceur",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData
                                              .colorScheme.onBackground,
                                          fontWeight: 600),
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 8, 24, 0),
                                    child: TextFormField(
                                      controller: libelleCtrler,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Veuillez saisir le titre';
                                        }
                                        return null;
                                      },
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.headline6,
                                          color: themeData.colorScheme.onBackground,
                                          letterSpacing: -0.4,
                                          fontWeight: 800),
                                      decoration: InputDecoration(
                                        fillColor: themeData.colorScheme.background,
                                        hintStyle: AppTheme.getTextStyle(
                                            themeData.textTheme.headline5,
                                            color:
                                            themeData.colorScheme.onBackground,
                                            letterSpacing: -0.4,
                                            fontWeight: 800),
                                        filled: false,
                                        hintText: "Nom de l'annonceur",
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      autocorrect: false,
                                      autovalidate: false,
                                      textCapitalization:
                                      TextCapitalization.sentences,
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 0, 24, 0),
                                    child: TextFormField(
                                      controller: phoneCtrler,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Veuillez saisir le numéro de téléphone';
                                        }
                                        return null;
                                      },
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: 500,
                                          letterSpacing: 0,
                                          muted: true),
                                      decoration: InputDecoration(
                                        hintText: "Numéro de téléphone",
                                        hintStyle: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText2,
                                            color:
                                            themeData.colorScheme.onBackground,
                                            fontWeight: 600,
                                            letterSpacing: 0,
                                            xMuted: true),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(50)),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.4,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(50)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(50)),
                                        ),
                                      ),
                                      maxLines: 1,
                                      minLines: 1,
                                      autofocus: false,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  eventBannerWidget(),
                                ],
                              )),
                        ),
                        Container(
                          color: customAppTheme.bgLayer1,
                          padding: Spacing.fromLTRB(24, 16, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop('cancel');
                                },
                                child: Container(
                                  padding: Spacing.fromLTRB(8, 8, 8, 8),
                                  decoration: BoxDecoration(
                                      color: DikoubaColors.red['pri'],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40))),
                                  child: Container(
                                    margin: Spacing.left(12),
                                    child: Text(
                                      "Retour".toUpperCase(),
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          fontSize: 12,
                                          letterSpacing: 0.7,
                                          color:
                                          themeData.colorScheme.onPrimary,
                                          fontWeight: 600),
                                    ),
                                  ),
                                ),
                              ),
                              _isEventCreating
                                  ? Container(
                                width: MySize.size32,
                                height: MySize.size32,
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),),)
                                  : InkWell(
                                onTap: () {
                                  checkEventForm(context);
                                },
                                child: Container(
                                  padding: Spacing.fromLTRB(8, 8, 8, 8),
                                  decoration: BoxDecoration(
                                      color: themeData.colorScheme.primary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40))),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: Spacing.left(12),
                                        child: Text(
                                          "Enregistrer".toUpperCase(),
                                          style: AppTheme.getTextStyle(
                                              themeData.textTheme.caption,
                                              fontSize: 12,
                                              letterSpacing: 0.7,
                                              color:
                                              themeData.colorScheme.onPrimary,
                                              fontWeight: 600),
                                        ),
                                      ),
                                      Container(
                                        margin: Spacing.left(16),
                                        padding: Spacing.all(4),
                                        decoration: BoxDecoration(
                                            color:
                                            themeData.colorScheme.onPrimary,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          MdiIcons.chevronRight,
                                          size: MySize.size20,
                                          color: themeData.colorScheme.primary,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ))));
      },
    );
  }

  Widget eventBannerWidget() {
    return Container(
        margin: Spacing.fromLTRB(24, 24, 24, 0),
        height: MySize.screenWidth*0.7,
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            border: Border.all(color: customAppTheme.bgLayer3, width: 1),

            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        child: Container(
          height: MySize.size80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: Spacing.left(16),
                child: Row(
                  children: [
                    Expanded(child: Text(
                      "Bannière",
                      style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground),
                    )),
                    IconButton(icon: Icon(
                      MdiIcons.fileEdit,
                      color: themeData.colorScheme.onBackground,
                    ), onPressed: () {
                      _showBottomSheetPickImage(context);
                    })
                  ],
                ),
              ),
              Expanded(
                  child: widget.userModel.annoncer_cover_picture_path != ""
                    ? Container(
                    margin: Spacing.top(4),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage("${widget.userModel.annoncer_cover_picture_path}"),
                            fit: BoxFit.fill
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(MySize.size8), bottomRight: Radius.circular(MySize.size8))),
                  )
                  : (_eventbanner == null)
                      ? Container(
                    margin: Spacing.symmetric(vertical: 2, horizontal: 16),
                    alignment: Alignment.center,
                    child: Text("Aucune image selectionnée",
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontSize: 12,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground,
                          xMuted: true),
                    ),)
                      : Container(
                    margin: Spacing.top(4),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(new File(_eventbanner.path)),
                            fit: BoxFit.fill
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(MySize.size8), bottomRight: Radius.circular(MySize.size8))),
                  ))
            ],
          ),
        )
    );
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
    if(resultAction == 'camera') {
      PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        _eventbanner = pickedFile;
      });
    } else if(resultAction == 'gallerie') {
      PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _eventbanner = pickedFile;
      });
    }
  }

  void checkEventForm(BuildContext buildContext) {
    if(_formEventKey.currentState.validate()) {

      print("$TAG:checkEventForm all is OK");
      saveEvent(buildContext);
    }
  }

  void saveEvent(BuildContext buildContext) async {
    setState(() {
      _isEventCreating = true;
    });
    var downloadLink= "";
    if(_eventbanner != null) {
      // Enregistrement de la banniere dans Fire Storage
      downloadLink = await FireStorageProvider.fireUploadFileToRef(FireStorageProvider.FIRESTORAGE_REF_ANNONCER, _eventbanner.path, widget.userModel.id_users);

    }
    print("$TAG:saveEvent downloadLink=$downloadLink");

    AnnoncerModel annoncerModel = new AnnoncerModel(
        checkout_phone_number: phoneCtrler.text,
        compagny: libelleCtrler.text,
        id_users: widget.userModel.uid,
        cover_picture_path: downloadLink,
        picture_path: ''
    );
    API.createAnnoncer(annoncerModel)
        .then((responseAnnon) {
      print("${TAG}:createAnnoncer responseCreated = ${responseAnnon.statusCode}|${responseAnnon.data}");

      if (responseAnnon.statusCode == 200) {
        AnnoncerModel annoncerCreated = new AnnoncerModel.fromJson(responseAnnon.data);

        updateDbAnnoncer(annoncerCreated);
        setState(() {
          _isEventCreating = false;
        });

        Navigator.of(buildContext).pop('ok');
        return;
      } else {
        DikoubaUtils.toast_error(
            context, "Service indisponible. veuillez réessayer plus tard");
        setState(() {
          _isEventCreating = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      print("${TAG}:createAnnoncer catchError ${errorLogin}");
      print("${TAG}:createAnnoncer catchError ${errorLogin.reponse.statusCode}|${errorLogin.reponse.data}");
      DikoubaUtils.toast_error(
          context, "Erreur réseau. Veuillez réessayer plus tard");
      setState(() {
        _isEventCreating = false;
      });
      return;
    });
  }

  void updateDbAnnoncer(AnnoncerModel annoncerModel) async {
    // dbHelper.delete_user();
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.COLUMN_USER_IDANNONCER: annoncerModel == null ? '' : annoncerModel.id_annoncers,
      DatabaseHelper.COLUMN_USER_ANNONCER_PICTUREPATH: annoncerModel == null ? '' : annoncerModel.picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_COVERPICTUREPATH: annoncerModel == null ? '' : annoncerModel.cover_picture_path,
      DatabaseHelper.COLUMN_USER_ANNONCER_COMPAGNY: annoncerModel == null ? '' : annoncerModel.compagny,
      DatabaseHelper.COLUMN_USER_ANNONCER_CHECKOUTPHONE: annoncerModel == null ? '' : annoncerModel.checkout_phone_number,
      DatabaseHelper.COLUMN_USER_ANNONCER_CREATEDAT: annoncerModel == null ? '' : annoncerModel.created_at.seconds,
      DatabaseHelper.COLUMN_USER_ANNONCER_UPDATEAT: annoncerModel == null ? '' : annoncerModel.updated_at.seconds,
    };
    final id = await dbHelper.update_user(row);
    print('${TAG}:updateDbAnnoncer updated row id: $id');
  }
}

