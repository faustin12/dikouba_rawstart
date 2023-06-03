import 'dart:convert';

import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/home_activity.dart';
import 'package:dikouba/activity/register_activity.dart';
import 'package:dikouba/fragment/EventCreateSession.dart';
import 'package:dikouba/model/evenement_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/provider/databasehelper_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EvenNewSessionActivity extends StatefulWidget {
  EvenementModel evenementModel;

  EvenNewSessionActivity(this.evenementModel, {Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  EvenNewSessionActivityState createState() => EvenNewSessionActivityState();
}

class EvenNewSessionActivityState extends State<EvenNewSessionActivity> {
  static final String TAG = 'EvenNewSessionActivityState';

  ThemeData themeData;
  CustomAppTheme customAppTheme;

  UserModel _userModel;

  bool _is_creating = false;
  bool _isSessionsFinding = false;

  List<Widget> _listWidget;
  List<EvenementModel> _listSessions = new List();

  Future<List<Widget>> widgetsView;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    setState(() {
      _userModel = UserModel.fromJsonDb(userRows[0]);
    });
  }

  void setWidgetsView() {
    setState(() {
      widgetsView = initWidgetListview();
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EvenNewSessionActivity",
      screenClassOverride: "EvenNewSessionActivity",
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
    queryUser();
    _setCurrentScreen();
  }

  @override
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
                          child: FutureBuilder<List<Widget>>(
                              future: initWidgetListview(),
                              builder: (BuildContext buildcontext, AsyncSnapshot<List<Widget>> snapshot) {
                                if( snapshot.connectionState == ConnectionState.waiting){
                                  return  Center(child: Container(
                                    width: MySize.size32,
                                    height: MySize.size32,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),),));
                                }else{
                                  if (snapshot.hasError)
                                    return Center(child: Text('Erreur: ${snapshot.error}'));
                                  else
                                    return ListView(
                                      padding: Spacing.vertical(16),
                                      children: snapshot.data,
                                    );
                                }

                              }),
                        ),
                        Container(
                          color: customAppTheme.bgLayer1,
                          padding: Spacing.fromLTRB(24, 16, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop('quit');
                                },
                                child: Container(
                                  padding: Spacing.fromLTRB(8, 8, 8, 8),
                                  decoration: BoxDecoration(
                                      color: DikoubaColors.blue['pri'],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40))),
                                  child: Text(
                                    "  Finir  ".toUpperCase(),
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
                              InkWell(
                                onTap: () {
                                  gotoAddSession(context);
                                },
                                child: Container(
                                  padding: Spacing.fromLTRB(8, 8, 8, 8),
                                  decoration: BoxDecoration(
                                      color: DikoubaColors.blue['pri'],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40))),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: Spacing.left(12),
                                        child: Text(
                                          "Nouvelle session".toUpperCase(),
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
                                          MdiIcons.plusCircleOutline,
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

  void gotoAddSession(BuildContext buildContext) async {
    var resAddSession = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EventCreateSession(_userModel, widget.evenementModel,
      analytics: widget.analytics,
      observer: widget.observer,
    )));
    print("$TAG:gotoAddSession ${resAddSession}");
    if(resAddSession == null) return;
    try {
      print("$TAG:gotoAddSession try");
      EvenementModel evenementModel = EvenementModel.fromJson(json.decode(resAddSession));
      setState(() {

      });
    } catch(e) {

    }
  }

  Future<List<Widget>> initWidgetListview() async {
    List<Widget> listWidget = new List();
    DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(int.parse(widget.evenementModel.start_date.seconds) * 1000);
    DateTime _endDate = DateTime.fromMillisecondsSinceEpoch(int.parse(widget.evenementModel.end_date.seconds) * 1000);

    listWidget.add(Container(
      margin: Spacing.fromLTRB(24, 24, 24, 0),
      child: Text(
        "Ajout des sessions a l'évènement",
        style: AppTheme.getTextStyle(
            themeData.textTheme.bodyText2,
            color: themeData
                .colorScheme.onBackground,
            fontWeight: 600),
      ),
    ));
    listWidget.add(Container(
      margin: Spacing.fromLTRB(24, 8, 24, 0),
      child: Text("${widget.evenementModel.title}",
        style: AppTheme.getTextStyle(themeData.textTheme.headline5,
            color: themeData.colorScheme.onBackground,
            fontWeight: 600),),
    ));
    listWidget.add(Container(
      margin: Spacing.fromLTRB(24, 24, 24, 0),
      child: Text(
        "Du ${DateFormat('dd MMM yyyy HH:mm').format(_startDate)}\nAu ${DateFormat('dd MMM yyyy HH:mm').format(_endDate)}",
        style: AppTheme.getTextStyle(
            themeData.textTheme.bodyText2,
            color: themeData
                .colorScheme.onBackground,
            fontWeight: 600),
      ),
    ));

    var resFindSession = await API.findAllSession([widget.evenementModel.id_evenements]);
    print(
        "${TAG}:requestCustomerAddress ${resFindSession.statusCode}|${resFindSession.data}");
    if(resFindSession.statusCode == 200) {
      List<EvenementModel> list = new List();
      for (int i = 0; i < resFindSession.data.length; i++) {
        EvenementModel itemSession = EvenementModel.fromJson(resFindSession.data[i]);
        // list.add(EvenementModel.fromJson(resFindSession.data[i]));

        DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(int.parse(itemSession.start_date.seconds) * 1000);
        DateTime _endDate = DateTime.fromMillisecondsSinceEpoch(int.parse(itemSession.end_date.seconds) * 1000);

        listWidget.add(singleEvent(
            image: '${itemSession.banner_path}',
            time: "${DateFormat('HH:mm').format(_startDate)}",
            date: "${DateFormat('dd MMM yyyy').format(_startDate)}",
            name: "${itemSession.title}"));
      }
    }

    return Future.value(listWidget);
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

    API.createUser(userModel)
        .then((responseCreated) async {
      print("${TAG}:createUserAccount responseCreated = ${responseCreated.statusCode}|${responseCreated.data}");

      if (responseCreated.statusCode == 200) {
        UserModel user = new UserModel.fromJson(responseCreated.data);
        // insertUser(user);
        setState(() {
          _is_creating = false;
        });

        if(isNewUser) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterActivity(userModel: user,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )));
        } else {
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

  void findEventSessions() async {
    setState(() {
      _isSessionsFinding = true;
    });
    API.findAllSession([widget.evenementModel.id_evenements]).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = new List();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }
        setState(() {
          _isSessionsFinding = false;
          _listSessions = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        setState(() {
          _isSessionsFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      setState(() {
        _isSessionsFinding = false;
      });
    });
  }

  Widget singleEvent({String image, String name, String date, String time}) {
    return Container(
      margin: Spacing.all(16),
      child: InkWell(
        onTap: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => EventTicketScreen()));
        },
        child: Row(
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child: Image(
                  image: image.contains('assets') ? AssetImage(image) : NetworkImage(image),
                  width: MySize.getScaledSizeHeight(80),
                  height: MySize.size72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.subtitle2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            )),
                        InkWell(
                          onTap: (){
                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) =>
                            //         EventTicketDialog());
                          },
                          child: Container(
                            padding: Spacing.all(6),
                            child: Icon(
                              MdiIcons.qrcode,
                              color:
                              themeData.colorScheme.onBackground.withAlpha(200),
                              size: MySize.size20,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: Spacing.top(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    fontSize: 12,
                                    color: themeData.colorScheme.onBackground,
                                    xMuted: true),
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  date,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color:
                                      themeData.colorScheme.onBackground),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Heure",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: 12,
                                    xMuted: true),
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  time,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color:
                                      themeData.colorScheme.onBackground),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
