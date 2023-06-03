import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/favoris_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:geocoder/geocoder.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EventMesFavorisScreen extends StatefulWidget {
  UserModel userModel;
  EventMesFavorisScreen(this.userModel, {required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventMesFavorisScreenState createState() => _EventMesFavorisScreenState();
}

class _EventMesFavorisScreenState extends State<EventMesFavorisScreen> {
  static final String TAG = '_EventMesFavorisScreenState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  bool _isFinding = false;
  List<FavorisModel> _listFavoris = [];

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventMesFavorisScreen",
      screenClassOverride: "EventMesFavorisScreen",
    );
  }

  Future<void> _setUserId(String uid) async {
    await widget.analytics.setUserId(id: uid);
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await widget.analytics.logEvent(
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
    findMesFavoris();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                body: Container(
                  color: customAppTheme.bgLayer1,
                  child: _isFinding
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),),)
                      : (_listFavoris == null || _listFavoris.length == 0)
                      ? Container(
                    margin: Spacing.fromLTRB(24, 16, 24, 0),
                    child: Text("Aucun favoris trouvé",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w500,
                        fontSize: 12
                      ),/*AppTheme.getTextStyle(
                          themeData.textTheme.caption,
                          fontSize: 12,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 500,
                          xMuted: true),*/),)
                      : ListView.separated(
                          padding: Spacing.zero,
                          itemCount: _listFavoris.length,
                          separatorBuilder: (context, index) {
                            return Container(
                              margin: Spacing.horizontal(16),
                              child: Divider(
                                height: 4,
                                color: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.1),
                              ),
                            );
                          },
                          itemBuilder:
                              (BuildContext buildcontext, int indexCateg) {
                            return _singleFavoris(_listFavoris[indexCateg]);
                          },
                        ),
            )));
      },
    );
  }

  Widget singleFavoris(FavorisModel favorisModel) {
    DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(favorisModel.evenements!.start_date!.seconds) * 1000);
    return Container(
      margin:
          Spacing.symmetric(horizontal: MySize.size12, vertical: MySize.size8),
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => EvenDetailsActivity(evenementModel,
          //   analytics: widget.analytics,
          //   observer: widget.observer,
          // )));DateFormat('dd').format(_startDate)
        },
        child: Row(
          children: [
            Container(
              padding: Spacing.fromLTRB(8, 4, 8, 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  border:
                      Border.all(color: customAppTheme.bgLayer3, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                        color: customAppTheme.shadowColor.withAlpha(150),
                        blurRadius: 1,
                        offset: Offset(0, 1))
                  ],
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size8))),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(_startDate),
                    style: themeData.textTheme.titleLarge?.copyWith(
                      color: DikoubaColors.blue['pri'],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('MMM').format(_startDate),
                    style: themeData.textTheme.bodyLarge?.copyWith(
                      color: DikoubaColors.blue['pri'],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('HH:mm').format(_startDate),
                    style: themeData.textTheme.bodyMedium?.copyWith(
                      color: DikoubaColors.blue['pri'],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: Spacing.left(MySize.size10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          favorisModel.evenements!.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: themeData.textTheme.titleSmall?.copyWith(
                            color: themeData.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        InkWell(
                          onTap: () {
                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) =>
                            //         EventTicketDialog());
                          },
                          child: Container(
                            padding: Spacing.all(6),
                            child: Icon(
                              MdiIcons.qrcode,
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(200),
                              size: MySize.size20,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: Spacing.top(MySize.size8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Like",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: MySize.size12,
                                  letterSpacing: 0
                                ),/*AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    fontSize: MySize.size12,
                                    color: themeData.colorScheme.onBackground,
                                    xMuted: true),*/
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  favorisModel.evenements!.nbre_likes!,
                                  style: themeData.textTheme.labelLarge?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12,
                                  ),
                                ),
                              )
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Comment",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: MySize.size12,
                                  letterSpacing: 0
                                ),/*AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12,
                                    xMuted: true),*/
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  favorisModel.evenements!.nbre_comments!,
                                  style: themeData.textTheme.labelLarge?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12
                                  ),
                                ),
                              )
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Favoris",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: MySize.size12,
                                  letterSpacing: 0
                                ),/*AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12,
                                    xMuted: true),*/
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  favorisModel.evenements!.nbre_favoris!,
                                  style: themeData.textTheme.labelLarge?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12
                                  ),
                                ),
                              )
                            ],
                          )),
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

  Widget _singleFavoris(FavorisModel favorisModel){
    return Container(
      margin: Spacing.symmetric(horizontal: 2, vertical: 2), //24 & 6
      child: SingleEventsWidget(
          customAppTheme,
          favorisModel.evenements!,
          favorisModel.id_users!,
          width: MySize.safeWidth - MySize.size48, analytics: widget.analytics, observer: widget.observer,)
    );
  }

  Widget new_singleFavoris(FavorisModel favorisModel) {
    DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(favorisModel.evenements!.start_date!.seconds) * 1000);

    String _eventLocationAddress = "loading";

    Future<void> getPositionInfo() async {
      final coordinates = new Coordinates(
          double.parse(favorisModel.evenements!.latitude!),
          double.parse(favorisModel.evenements!.longitude!));
      var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      //setState(() {
        _eventLocationAddress = first.addressLine;
      //});
    }
    String _title = favorisModel.evenements!.title!;
    String _date = DateFormat('dd').format(_startDate) + DateFormat('MMM').format(_startDate) +
                    DateFormat('yy').format(_startDate);
    String _time = DateFormat('HH:mm').format(_startDate);
    String _img = favorisModel.evenements!.banner_path;
    String _desc = favorisModel.evenements!.description!;
    String _desc2 = favorisModel.evenements!.description!;
    String _desc3 = favorisModel.evenements!.description!;
    String _price = favorisModel.evenements!.nbre_packages!;
    String _category = favorisModel.evenements!.categories!.title!;
    String _id = favorisModel.evenements!.id_evenements!;
    String _place = _eventLocationAddress;
    String _userID = favorisModel.id_users!;
    return Container(
        margin:
        Spacing.symmetric(horizontal: MySize.size12, vertical: MySize.size8),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    EvenDetailsActivity(favorisModel.evenements,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    )));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12.withOpacity(0.2),
                            spreadRadius: 3.0,
                            blurRadius: 10.0)
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Hero(
                        tag: 'hero-tag-list-$_id',
                        child: Material(
                          child: Container(
                            height: 165.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(_img), fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0)),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.only(top: 10.0, right: 10.0),
                              child: InkWell(
                                onTap: () {
                                  //
                                },
                                child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.black38,
                                    )),
                              ),
                            ),
                            alignment: Alignment.topRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 13.0, top: 7.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            Text(
                              _title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17.0,
                                  fontFamily: "Popins"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Icon(
                                      Icons.place,
                                      size: 17.0,
                                    ),
                                    Container(
                                        width: 120.0,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              _place,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: "popins",
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black38),
                                              overflow: TextOverflow.ellipsis,
                                            )))
                                  ]),
                                  Row(children: <Widget>[
                                    Icon(
                                      Icons.timer,
                                      size: 17.0,
                                    ),
                                    Container(
                                        width: 140.0,
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            _date,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontFamily: "popins",
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black38),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                ,
              )
          )
          ,
        )
    );
}

  void findMesFavoris() async {
    setState(() {
      _isFinding = true;
    });
    API.findUserFavoris(widget.userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesFavoris ${responseEvents.statusCode}|${responseEvents.data}");
        List<FavorisModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(FavorisModel.fromJson(responseEvents.data[i]));
        }

        if (!mounted) return;
        setState(() {
          _isFinding = false;
          _listFavoris = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
        setState(() {
          _isFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isFinding = false;
      });
    });
  }
}

class SingleEventsWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  EvenementModel evenementModel;
  String idUser;
  @required
  double width;
  SingleEventsWidget(this.customAppTheme, this.evenementModel, this.idUser,
      {required this.width,
        required this.analytics,
        required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  SingleEventsWidgetState createState() => SingleEventsWidgetState();
}


class SingleEventsWidgetState extends State<SingleEventsWidget> {
  static final String TAG = 'SingleEventsWidgetState';

  late ThemeData themeData;

  String _eventLocationAddress = "loading";

  Future<void> getPositionInfo() async {
    final coordinates = new Coordinates(
        double.parse(widget.evenementModel.location!.latitude),
        double.parse(widget.evenementModel.location!.longitude));
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _eventLocationAddress = first.addressLine;
    });
  }

  @override
  void initState() {
    super.initState();
    getPositionInfo();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    var _id = widget.evenementModel.id_evenements;

    return Container(
        margin:
        Spacing.symmetric(horizontal: MySize.size12, vertical: MySize.size8), //12 & 8
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 0.0), //20 instead of 2
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    EvenDetailsActivity(widget.evenementModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    )));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0), //15 each
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12.withOpacity(0.2),
                            spreadRadius: 3.0,
                            blurRadius: 10.0)
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Hero(
                        tag: 'hero-tag-list-$_id',
                        child: Material(
                          child: Container(
                            height: 165.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(widget.evenementModel.banner_path), fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0)),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.only(top: 10.0, right: 10.0),
                              child: InkWell(
                                /*onTap: () {
                                  //
                                },*/
                                /*child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.black38,
                                    )),*/
                              ),
                            ),
                            alignment: Alignment.topRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 13.0, top: 7.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            Text(
                              widget.evenementModel.title!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17.0,
                                  fontFamily: "Popins"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Icon(
                                      Icons.place,
                                      size: 17.0,
                                      color: Colors.black38,
                                    ),
                                    Container(
                                        width: 120.0,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              _eventLocationAddress,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: "popins",
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black38),
                                              overflow: TextOverflow.ellipsis,
                                            )))
                                  ]),
                                  Row(children: <Widget>[
                                    Icon(
                                      Icons.timer,
                                      color: Colors.black38,
                                      size: 17.0,
                                    ),
                                    Container(
                                        width: 140.0,
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            DateFormat('dd MMM yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(widget.evenementModel.start_date!.seconds) * 1000)),
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontFamily: "popins",
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black38),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                ,
              )
          )
          ,
        )
    );
  }
}

