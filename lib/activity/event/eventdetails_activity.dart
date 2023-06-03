import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/dialogs/ShowEventCommentsDialog.dart';
import 'package:dikouba_rawstart/activity/dialogs/ShowEventLocationDialog.dart';
import 'package:dikouba_rawstart/activity/dialogs/ShowEventPackageDialog.dart';
import 'package:dikouba_rawstart/activity/dialogs/ShowEventParticipantWidget.dart';
import 'package:dikouba_rawstart/activity/event/eventnewsondage_activity.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/evenementfavoris_model.dart';
import 'package:dikouba_rawstart/model/evenementlike_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/widget/SingleSondageWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:geocoder/geocoder.dart';
import 'package:readmore/readmore.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class EvenDetailsActivity extends StatefulWidget {
  EvenementModel evenementModel;

  EvenDetailsActivity(this.evenementModel,
      {Key? key, required this.analytics, required this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EvenDetailsActivityState createState() => _EvenDetailsActivityState();
}

class _EvenDetailsActivityState extends State<EvenDetailsActivity> {
  static final String TAG = 'EvenDetailsActivityState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late DateTime _startDate;
  late DateTime _endDate;
  bool _isEventFinding = false;
  bool _isEventLiking = false;
  bool _isEventFavoring = false;
  bool _isSondagesFinding = false;

  Completer<GoogleMapController> _controller = Completer();

  late CameraPosition _kGooglePlex;

  late UserModel _userModel;

  List<SondageModel> _listSondages = [];

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    _userModel = UserModel.fromJsonDb(userRows[0]);
    findEventsItem();
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EvenDetailsActivity",
      screenClassOverride: "EvenDetailsActivity",
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

  String _eventLocationAddress = "loading";

  Future<void> getPositionInfo() async {
    final coordinates = new Coordinates(
        double.parse(widget.evenementModel.location!.latitude),
        double.parse(widget.evenementModel.location!.longitude));
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    //DikoubaUtils.toast_infos(context,"getPositionInfo "+double.parse(widget.evenementModel.location.latitude).toString() +"${first.featureName} : ${first.addressLine}");

    setState(() {
      _eventLocationAddress = first.addressLine;
    });
  }

  void findEventsPackage() async {
    setState(() {
      _isPackageFinding = true;
    });
    API
        .findEventPackage(widget.evenementModel.id_evenements!)
        .then((responsePackage) {
      if (responsePackage.statusCode == 200) {
        print(
            "findEventPackages ${responsePackage.statusCode}|${responsePackage.data}");
        List<PackageModel> list = [];
        for (int i = 0; i < responsePackage.data.length; i++) {
          PackageModel packageModelgetMdl =
              PackageModel.fromJson(responsePackage.data[i]);
          list.add(packageModelgetMdl);
        }
        if (!mounted) return;
        setState(() {
          _isPackageFinding = false;
          _listPackage = list;
        });
      } else {
        print("findEventPackages no data ${responsePackage.toString()}");
        if (!mounted) return;
        setState(() {
          _isPackageFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("findEventPackages errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isPackageFinding = false;
      });
    });
  }

  void showEventPackageDialogDialog() async {
    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ShowEventPackageDialog(
              _listPackage,
              widget.evenementModel,
              themeData,
              analytics: widget.analytics,
              observer: widget.observer,
            )));
    print("showEventPackageDialogDialog: ${resAddPackage}");
  }

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    queryUser();
    findSondage();
    findEventsPackage();
    getPositionInfo();

    _kGooglePlex = CameraPosition(
      target: LatLng(double.parse(widget.evenementModel.location!.latitude),
          double.parse(widget.evenementModel.location!.longitude)),
      zoom: 16,
    );
    _startDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(widget.evenementModel.start_date!.seconds) * 1000);
    _endDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(widget.evenementModel.end_date!.seconds) * 1000);
  }

  bool _isPackageFinding = false;
  List<PackageModel> _listPackage = [];

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: _userModel == null
                ? Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          DikoubaColors.blue['pri']!),
                    ),
                  )
                : Scaffold(
                    resizeToAvoidBottomInset: false,
                    floatingActionButton: (_userModel.id_annoncers ==
                            widget.evenementModel.id_annoncers)
                        ? SpeedDial(
                            icon: Icons.add,
                            backgroundColor: DikoubaColors.blue['pri'],
                            children: [
                                SpeedDialChild(
                                  child: const Icon(Icons.add_circle_rounded,
                                      color: Colors.white),
                                  label: 'Add Media',
                                  labelBackgroundColor: Colors.white,
                                  backgroundColor: DikoubaColors.blue['pri'],
                                  onTap: () {/* Do someting */},
                                ),
                                SpeedDialChild(
                                  child: const Icon(Icons.add_a_photo,
                                      color: Colors.white),
                                  label: 'Scan tickets',
                                  labelBackgroundColor: Colors.white,
                                  backgroundColor: DikoubaColors.blue['pri'],
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => QRViewExample(
                                                widget.evenementModel,
                                                _listPackage,
                                                themeData,
                                                customAppTheme)));
                                  },
                                ),
                                SpeedDialChild(
                                  child: const Icon(Icons.analytics,
                                      color: Colors.white),
                                  label: 'Create Sondage',
                                  labelBackgroundColor: Colors.white,
                                  backgroundColor: DikoubaColors.blue['pri'],
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EvenNewSondageActivity(
                                                  widget.evenementModel,
                                                  analytics: widget.analytics,
                                                  observer: widget.observer,
                                                )));
                                  },
                                ),
                              ])
                        /*FloatingActionButton(
                            onPressed: () {
                              _sendAnalyticsEvent("PressCreateSondage");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EvenNewSondageActivity(
                                            widget.evenementModel,
                                            analytics: widget.analytics,
                                            observer: widget.observer,
                                          )));
                            },
                            backgroundColor: DikoubaColors.blue['pri'],
                            child: Icon(
                              MdiIcons.plusBoxMultiple,
                              size: MySize.size32,
                              color: Colors.white,
                            ),
                          )*/
                        : Container(),
                    body: Container(
                      color: customAppTheme.bgLayer1,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child: Container(
                                child: Stack(
                                  children: [
                                    Image(
                                      image: NetworkImage(
                                          "${widget.evenementModel.banner_path}"),
                                      fit: BoxFit.cover,
                                      width: MySize.safeWidth,
                                      height: MySize.getScaledSizeHeight(260),
                                    ),
                                    Positioned(
                                      child: Container(
                                        margin: Spacing.fromLTRB(8, 8, 8, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding: Spacing.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      customAppTheme.bgLayer1,
                                                  border: Border.all(
                                                      color: customAppTheme
                                                          .bgLayer4,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              MySize.size8)),
                                                ),
                                                child: Icon(
                                                    MdiIcons.chevronLeft,
                                                    color: themeData.colorScheme
                                                        .onBackground
                                                        .withAlpha(220),
                                                    size: MySize.size20),
                                              ),
                                            ),
                                            /*Container(
                                          padding: Spacing.all(8),
                                          decoration: BoxDecoration(
                                            color: customAppTheme.bgLayer1,
                                            border: Border.all(
                                                color: customAppTheme.bgLayer4,
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(MySize.size8)),
                                          ),
                                          child: Icon(MdiIcons.shareOutline,
                                              color: themeData.colorScheme.onBackground
                                                  .withAlpha(220),
                                              size: MySize.size20),
                                        ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          Positioned(
                            top: MySize.getScaledSizeHeight(240),
                            left: MySize.size16,
                            child: Container(
                              //padding: Spacing.fromLTRB(8, 4, 8, 4),
                              decoration: BoxDecoration(
                                  color: customAppTheme.bgLayer1,
                                  border: Border.all(
                                      color: customAppTheme.bgLayer3,
                                      width: 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                        color: customAppTheme.shadowColor
                                            .withAlpha(150),
                                        blurRadius: 1,
                                        offset: Offset(0, 1))
                                  ],
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(MySize.size8))),
                              child: InkWell(
                                onTap: () {
                                  _sendAnalyticsEvent(
                                      "tapAnnoncerIcon_detailEvent");
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(MySize.size8)),
                                  child: Image(
                                    image: AssetImage(
                                        './assets/logo/user_template.webp'),
                                    fit: BoxFit.cover,
                                    width: MySize.size60,
                                    height: MySize.size60,
                                  ),
                                ),
                              ),
                              /*Icon(
                            MdiIcons.account,
                            size: 28,
                            color: Colors.black54,
                          ),*/
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: MySize.getScaledSizeHeight(260),
                            child: _isEventFinding
                                ? Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          DikoubaColors.blue['pri']!),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: ListView(
                                      padding: Spacing.vertical(16),
                                      children: [
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 0, 24, 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ReadMoreText(
                                                  "${widget.evenementModel.title}",
                                                  trimLines: 1,
                                                  colorClickableText:
                                                      DikoubaColors.blue['pri'],
                                                  trimMode: TrimMode.Line,
                                                  trimCollapsedText: 'Plus',
                                                  trimExpandedText: 'Moins',
                                                  style: themeData.textTheme.headlineSmall?.copyWith(
                                                    color: themeData.colorScheme.onBackground,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22,
                                                  ),
                                                  moreStyle: TextStyle(
                                                      color: DikoubaColors
                                                          .blue['pri'],
                                                      fontSize: themeData
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  lessStyle: TextStyle(
                                                      color: DikoubaColors
                                                          .blue['pri'],
                                                      fontSize: themeData
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                              _isEventFavoring
                                                  ? Container(
                                                      margin: Spacing.left(8),
                                                      padding: Spacing.all(8),
                                                      decoration: BoxDecoration(
                                                          color: themeData
                                                              .colorScheme
                                                              .primary
                                                              .withAlpha(24)
                                                              .withAlpha(20),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      MySize
                                                                          .size8))),
                                                      child: Icon(
                                                        MdiIcons.bookmark,
                                                        size: MySize.size18,
                                                        color: Colors.black12,
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        print(
                                                            "hello singleEvent like ${widget.evenementModel.id_evenements}");

                                                        if (widget
                                                            .evenementModel
                                                            .has_favoris!) {
                                                          _sendAnalyticsEvent(
                                                              "FavEvent_Detail");
                                                          unFavorisEvent(widget
                                                              .evenementModel
                                                              .id_evenements!);
                                                        } else {
                                                          _sendAnalyticsEvent(
                                                              "unFavEvent_Detail");
                                                          favorisEvent(widget
                                                              .evenementModel
                                                              .id_evenements!);
                                                        }
                                                      },
                                                      child: Container(
                                                        margin: Spacing.left(8),
                                                        padding: Spacing.all(8),
                                                        decoration: BoxDecoration(
                                                            color: themeData
                                                                .colorScheme
                                                                .primary
                                                                .withAlpha(24)
                                                                .withAlpha(20),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        MySize
                                                                            .size8))),
                                                        child: widget
                                                                .evenementModel
                                                                .has_favoris!
                                                            ? Icon(
                                                                MdiIcons
                                                                    .bookmark,
                                                                size: MySize
                                                                    .size18,
                                                                color: Colors
                                                                    .yellow,
                                                              )
                                                            : Icon(
                                                                MdiIcons
                                                                    .bookmarkOutline,
                                                                size: MySize
                                                                    .size18,
                                                                color:
                                                                    DikoubaColors
                                                                            .blue[
                                                                        'pri'],
                                                              ),
                                                      ),
                                                    ),
                                              Container(
                                                margin: Spacing.left(8),
                                                padding: Spacing.all(8),
                                                decoration: BoxDecoration(
                                                    color: themeData
                                                        .colorScheme.primary
                                                        .withAlpha(24)
                                                        .withAlpha(20),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                MySize.size8))),
                                                child: Icon(
                                                    MdiIcons.shareVariant,
                                                    size: MySize.size18,
                                                    color: DikoubaColors
                                                        .blue['pri']),
                                              ),
                                              _isEventLiking
                                                  ? Container(
                                                      margin: Spacing.left(8),
                                                      padding: Spacing.all(8),
                                                      decoration: BoxDecoration(
                                                          color: themeData
                                                              .colorScheme
                                                              .primary
                                                              .withAlpha(24)
                                                              .withAlpha(20),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      MySize
                                                                          .size8))),
                                                      child: Icon(
                                                        MdiIcons.heart,
                                                        size: MySize.size18,
                                                        color: Colors.black12,
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        print(
                                                            "hello singleEvent favoris ${widget.evenementModel.id_evenements}");

                                                        if (widget
                                                            .evenementModel
                                                            .has_like!) {
                                                          _sendAnalyticsEvent(
                                                              "unLikedEvent_Detail");
                                                          unLikeEvent(widget
                                                              .evenementModel
                                                              .id_evenements!);
                                                        } else {
                                                          _sendAnalyticsEvent(
                                                              "likedEvent_Detail");
                                                          likeEvent(widget
                                                              .evenementModel
                                                              .id_evenements!);
                                                        }
                                                      },
                                                      child: Container(
                                                        margin: Spacing.left(8),
                                                        padding: Spacing.all(8),
                                                        decoration: BoxDecoration(
                                                            color: themeData
                                                                .colorScheme
                                                                .primary
                                                                .withAlpha(24)
                                                                .withAlpha(20),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        MySize
                                                                            .size8))),
                                                        child: widget
                                                                .evenementModel
                                                                .has_like!
                                                            ? Icon(
                                                                MdiIcons.heart,
                                                                size: MySize
                                                                    .size18,
                                                                color: Colors
                                                                    .redAccent)
                                                            : Icon(
                                                                MdiIcons
                                                                    .heartOutline,
                                                                size: MySize
                                                                    .size18,
                                                                color:
                                                                    DikoubaColors
                                                                            .blue[
                                                                        'pri'],
                                                              ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 16, 24, 0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: Spacing.all(8),
                                                    decoration: BoxDecoration(
                                                        color: themeData
                                                            .colorScheme.primary
                                                            .withAlpha(24),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    MySize
                                                                        .size8))),
                                                    child: Icon(
                                                      MdiIcons.calendar,
                                                      size: MySize.size18,
                                                      color: DikoubaColors
                                                          .blue['pri'],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin: Spacing.left(16),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            DateFormat('EEEE dd MMMM yyyy, HH:mm').format(_startDate),
                                                            style: themeData.textTheme.bodySmall?.copyWith(
                                                              color: themeData.colorScheme.onBackground,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            DateFormat('EEEE dd MMMM yyyy, HH:mm').format(_endDate),
                                                            style: themeData.textTheme.bodySmall?.copyWith(
                                                              color: themeData.colorScheme.onBackground,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                margin: Spacing.top(16),
                                                child: InkWell(
                                                  onTap: () {
                                                    _sendAnalyticsEvent(
                                                        "tapShowEventLocation_Detail");
                                                    showEventLocation();
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding: Spacing.all(8),
                                                        decoration: BoxDecoration(
                                                            color: themeData
                                                                .colorScheme
                                                                .primary
                                                                .withAlpha(24),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        MySize
                                                                            .size8))),
                                                        child: Icon(
                                                          MdiIcons
                                                              .mapMarkerOutline,
                                                          size: MySize.size18,
                                                          color: DikoubaColors
                                                              .blue['pri'],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          margin:
                                                              Spacing.left(16),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Afficher le lieu",
                                                                style: themeData.textTheme.bodySmall?.copyWith(
                                                                  color: themeData.colorScheme.onBackground,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                              Container(
                                                                margin:
                                                                    Spacing.top(
                                                                        2),
                                                                child: Text(
                                                                  _eventLocationAddress,
                                                                  //"[${widget.evenementModel.location.latitude}, ${widget.evenementModel.location.longitude}]",
                                                                  style: themeData.textTheme.bodyMedium?.copyWith(
                                                                          color: themeData.colorScheme.onBackground,
                                                                          fontWeight: FontWeight.w500,
                                                                          fontSize: 12
                                                                        ),
                                                                      //   AppTheme.getTextStyle(
                                                                      // themeData
                                                                      //     .textTheme
                                                                      //     .caption,
                                                                      // fontSize:
                                                                      //     12,
                                                                      // fontWeight:
                                                                      //     500,
                                                                      // color: themeData
                                                                      //     .colorScheme
                                                                      //     .onBackground,
                                                                      // xMuted:
                                                                      //     true),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        MdiIcons.chevronRight,
                                                        size: MySize.size24,
                                                        color: themeData
                                                            .colorScheme
                                                            .primary,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: Spacing.top(16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: Spacing.all(8),
                                                      decoration: BoxDecoration(
                                                          color: themeData
                                                              .colorScheme
                                                              .primary
                                                              .withAlpha(24),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      MySize
                                                                          .size8))),
                                                      child: Icon(
                                                        MdiIcons.package,
                                                        size: MySize.size18,
                                                        color: DikoubaColors
                                                            .blue['pri'],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        margin:
                                                            Spacing.left(16),
                                                        child: Text(
                                                          widget
                                                                      .evenementModel
                                                                      .categories!
                                                                      .title ==
                                                                  null
                                                              ? 'Non classifié'
                                                              : "${widget.evenementModel.categories!.title}",
                                                          style: themeData.textTheme.bodyMedium?.copyWith(
                                                            color: themeData.colorScheme.onBackground,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: Spacing.top(16),
                                                child: InkWell(
                                                  onTap: () {
                                                    _sendAnalyticsEvent(
                                                        "tapShowEventPackage_Detail");
                                                    showEventPackageDialogDialog();
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding: Spacing.all(8),
                                                        decoration: BoxDecoration(
                                                            color: themeData
                                                                .colorScheme
                                                                .primary
                                                                .withAlpha(24),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        MySize
                                                                            .size8))),
                                                        child: Icon(
                                                          MdiIcons.tagOutline,
                                                          size: MySize.size18,
                                                          color: DikoubaColors
                                                              .blue['pri'],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          margin:
                                                              Spacing.left(16),
                                                          child: Text(
                                                            "Pakages (${widget.evenementModel.nbre_packages})",
                                                            style: themeData.textTheme.bodySmall?.copyWith(
                                                              color: themeData.colorScheme.onBackground,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        MdiIcons.chevronRight,
                                                        size: MySize.size24,
                                                        color: themeData
                                                            .colorScheme
                                                            .primary,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ShowEventParticipantWidget(
                                                            widget.evenementModel,
                                                            _userModel,
                                                            customAppTheme),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 24, 24, 0),
                                          child: Text(
                                            "Description",
                                            style: themeData.textTheme.titleMedium?.copyWith(
                                              color: themeData.colorScheme.onBackground,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 12, 24, 0),
                                          child: ReadMoreText(
                                            "${widget.evenementModel.description}",
                                            trimLines: 3,
                                            colorClickableText:
                                                DikoubaColors.blue['pri'],
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'Afficher plus',
                                            trimExpandedText: 'Afficher moins',
                                            style: themeData.textTheme.bodyMedium?.copyWith(
                                              color: themeData.colorScheme.onBackground,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            moreStyle: TextStyle(
                                                color:
                                                    DikoubaColors.blue['pri'],
                                                fontSize: themeData.textTheme
                                                    .bodyMedium!.fontSize,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 24, 24, 0),
                                          child: Text(
                                            "Localisation",
                                            style: themeData.textTheme.titleMedium?.copyWith(
                                              color: themeData.colorScheme.onBackground,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 16, 24, 0),
                                          width: MySize.screenWidth,
                                          height: MySize.screenWidth,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(MySize.size8)),
                                            child: GoogleMap(
                                              mapType: MapType.normal,
                                              liteModeEnabled: true,
                                              initialCameraPosition:
                                                  _kGooglePlex,
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                _controller
                                                    .complete(controller);
                                              },
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 24, 24, 0),
                                          child: Text(
                                            "Sondages",
                                            style: themeData.textTheme.titleMedium?.copyWith(
                                              color: themeData.colorScheme.onBackground,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        _isSondagesFinding
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          DikoubaColors
                                                              .blue['pri']!),
                                                ),
                                              )
                                            : (_listSondages == null ||
                                                    _listSondages.length == 0)
                                                ? Container(
                                                    margin: Spacing.fromLTRB(
                                                        24, 16, 24, 0),
                                                    child: Text(
                                                      "Aucun sondage trouvé",
                                                      style: themeData.textTheme.bodySmall?.copyWith(
                                                        color: themeData.colorScheme.onBackground,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                      // AppTheme.getTextStyle(
                                                      //         themeData
                                                      //             .textTheme
                                                      //             .caption,
                                                      //         fontSize: 12,
                                                      //         color: themeData
                                                      //             .colorScheme
                                                      //             .onBackground,
                                                      //         fontWeight: 500,
                                                      //         xMuted: true),
                                                    ),
                                                  )
                                                : Container(
                                                    margin: Spacing.top(16),
                                                    height:
                                                        MySize.safeWidth * 0.6,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          _listSondages.length,
                                                      itemBuilder: (BuildContext
                                                              buildcontext,
                                                          int indexCateg) {
                                                        return Container(
                                                          margin:
                                                              Spacing.left(24),
                                                          child: SingleSondageWidget(
                                                              customAppTheme,
                                                              _listSondages[
                                                                  indexCateg],
                                                              _userModel,
                                                              MySize.safeWidth -
                                                                  MySize
                                                                      .size48, onUpdateClickListener: () => {}),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                        Container(
                                          margin:
                                              Spacing.fromLTRB(24, 16, 24, 0),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            /* color: DikoubaColors.blue['pri'],
                                            splashColor: themeData
                                                .colorScheme.onPrimary
                                                .withAlpha(100),
                                            highlightColor:
                                                themeData.colorScheme.primary, */
                                            padding: Spacing.vertical(14),
                                            ),
                                            onPressed: () {
                                              showEventCommentDialog();
                                            },
                                            child: Text(
                                              "Commentaires (${widget.evenementModel.nbre_comments})",
                                              style: themeData.textTheme.bodyMedium?.copyWith(
                                                color: themeData.colorScheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          )
                        ],
                      ),
                    )));
      },
    );
  }

  void findEventsItem() async {
    setState(() {
      _isEventFinding = true;
    });
    API
        .findEventItem(widget.evenementModel.id_evenements!,
            idUser: _userModel.id_users)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementModel evenement = EvenementModel.fromJson(responseEvents.data);

        setState(() {
          _isEventFinding = false;
          widget.evenementModel = evenement;
        });
      } else {
        print("findOperations no data ${responseEvents.toString()}");
        setState(() {
          _isEventFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      setState(() {
        _isEventFinding = false;
      });
    });
  }

  void showEventLocation() async {
    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            ShowEventLocationDialog(widget.evenementModel)));
    print("updateSelectedLocation: ${resAddPackage}");
  }

  void findSondage() async {
    setState(() {
      _isSondagesFinding = true;
    });
    API
        .findSondageEvent(widget.evenementModel.id_evenements!)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findSondage ${responseEvents.statusCode}|${responseEvents.data}");
        List<SondageModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(SondageModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isSondagesFinding = false;
          _listSondages = list;
        });
      } else {
        print("${TAG}:findSondage no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isSondagesFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findSondage errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isSondagesFinding = false;
      });
    });
  }

  void likeEvent(String idEvent) async {
    print("${TAG}:likeEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventLiking = true;
    });
    API.eventAddLike(_userModel.id_users, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:likeEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementLikeModel likeMdl =
            EvenementLikeModel.fromJson(responseEvents.data);

        widget.evenementModel.has_like = true;

        if (!mounted) return;
        setState(() {
          _isEventLiking = false;
        });
      } else {
        print("${TAG}:likeEvent no data ${responseEvents.toString()}");
        setState(() {
          _isEventLiking = false;
        });
      }
    }).catchError((errWalletAddr) {
      setState(() {
        _isEventLiking = false;
      });
      print("${TAG}:likeEvent errorinfo ${errWalletAddr.toString()}");
      print("${TAG}:likeEvent errorinfo ${errWalletAddr.response}");
    });
  }

  void unLikeEvent(String idEvent) async {
    print("${TAG}:likeEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventLiking = true;
    });
    API.eventDeleteLike(_userModel.id_users, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:unLikeEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementLikeModel likeMdl =
            EvenementLikeModel.fromJson(responseEvents.data);

        widget.evenementModel.has_like = false;
        // mapLikemdl.removeWhere((key, value) => key == likeMdl.id_evenements);
        if (!mounted) return;
        setState(() {
          _isEventLiking = false;
        });
      } else {
        print("${TAG}:unLikeEvent no data ${responseEvents.toString()}");
        setState(() {
          _isEventLiking = false;
        });
      }
    }).catchError((errWalletAddr) {
      setState(() {
        _isEventLiking = false;
      });
      print("${TAG}:unLikeEvent errorinfo ${errWalletAddr.toString()}");
      print("${TAG}:unLikeEvent errorinfo ${errWalletAddr.response}");
    });
  }

  void favorisEvent(String idEvent) async {
    print("${TAG}:favorisEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventFavoring = true;
    });
    API.eventAddFavoris(_userModel.id_users, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:favorisEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementFavorisModel favMdl =
            EvenementFavorisModel.fromJson(responseEvents.data);

        widget.evenementModel.has_favoris = true;

        if (!mounted) return;
        setState(() {
          _isEventFavoring = false;
        });
      } else {
        print("${TAG}:favorisEvent no data ${responseEvents.toString()}");
        setState(() {
          _isEventFavoring = false;
        });
      }
    }).catchError((errWalletAddr) {
      setState(() {
        _isEventFavoring = false;
      });
      print("${TAG}:favorisEvent errorinfo ${errWalletAddr.toString()}");
    });
  }

  void unFavorisEvent(String idEvent) async {
    print("${TAG}:favorisEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventFavoring = true;
    });
    API.eventDeleteFavoris(_userModel.id_users, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:favorisEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementFavorisModel favMdl =
            EvenementFavorisModel.fromJson(responseEvents.data);

        widget.evenementModel.has_favoris = false;

        if (!mounted) return;
        setState(() {
          _isEventFavoring = false;
        });
      } else {
        print("${TAG}:favorisEvent no data ${responseEvents.toString()}");
        setState(() {
          _isEventFavoring = false;
        });
      }
    }).catchError((errWalletAddr) {
      setState(() {
        _isEventFavoring = false;
      });
      print("${TAG}:favorisEvent errorinfo ${errWalletAddr.toString()}");
    });
  }

  void showEventCommentDialog() async {
    var resComments = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ShowEventCommentsDialog(
            widget.evenementModel, _userModel, themeData)));
    print("showEventCommentDialog: ${resComments}");

    if (resComments != null &&
        resComments != widget.evenementModel.nbre_comments) {
      setState(() {
        widget.evenementModel.nbre_comments = resComments.toString();
      });
    }
  }
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;
  bool _checkingData = false;

  Future<void> _checkResults(Barcode readedBarcode) async {
    _checkingData = true;
    String scanned_id_users = "";
    String scanned_id_tickets = "";
    String scanned_id_evenements = "";
    String scanned_id_packages = "";
    bool _goodTicket = false;
    String _labelValue = "Bad ticket";

    void showDialogResult(bool result, String _label) {
      showDialog(
          context: context,
          barrierColor: Color(0x00ffffff),
          builder: (BuildContext context) => Dialog(
              backgroundColor: Color(0x00ffffff),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        //margin: EdgeInsets.all(100.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color:
                                result ? Colors.blueAccent : Colors.redAccent,
                            shape: BoxShape.circle),
                        child: Expanded(
                          child: new FittedBox(
                            fit: BoxFit.fill,
                            child: new Icon(
                              result ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    Container(
                        //color: Colors.white,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: Spacing.fromLTRB(MySize.size16,
                                    MySize.size8, MySize.size18, 0),
                                child: Text(
                                  widget._evenement.title!,
                                  maxLines: 1,
                                  style: widget._themeData.textTheme.headlineMedium?.copyWith(
                                    color: result ? Colors.blueAccent : Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                margin: Spacing.fromLTRB(MySize.size16,
                                    MySize.size8, MySize.size18, 0),
                                child: Text(
                                  _label,
                                  maxLines: 1,
                                  style: widget._themeData.textTheme.bodyMedium?.copyWith(
                                        color: result ? Colors.blueAccent : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ]))
                  ]))).then((value) => _checkingData = false);
      //_checkingData = false;
    }

    try {
      scanned_id_users = jsonDecode(readedBarcode.code!)["id_users"];
      scanned_id_tickets = jsonDecode(readedBarcode.code!)["id_tickets"];
      scanned_id_evenements = jsonDecode(readedBarcode.code!)["id_evenements"];
      scanned_id_packages = jsonDecode(readedBarcode.code!)["id_packages"];
    } on Exception catch (_) {
      print('never reached');
    }
    API
        .scanTicketsUsers(scanned_id_users, scanned_id_tickets)
        .then((responsePackage) {
      if (responsePackage.statusCode == 200) {
        print(
            "scanTicketsUsers ${responsePackage.statusCode}|${responsePackage.data}");

        _goodTicket = (responsePackage.data["id_evenements"] ==
                widget._evenement.id_evenements &&
            (responsePackage.data["statut"] == "COMPLETE" ||
                responsePackage.data["statut"] == "COMPLETED"));
        _labelValue = "Check ticket ?";
        for (int idx = 0; idx < widget._packageList.length; idx++) {
          if (widget._packageList[idx].id_packages ==
              responsePackage.data["id_packages"])
            _labelValue = "Package : " + widget._packageList[idx].name!;
        }
        showDialogResult(_goodTicket, _labelValue);
      } else {
        print("scanTicketsUsers no data ${responsePackage.toString()}");
        showDialogResult(false, "Ticket not found");
      }
    }).catchError((errWalletAddr) {
      print("scanTicketsUsers errorinfo ${errWalletAddr.toString()}");
      showDialogResult(false, _labelValue);
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: DikoubaColors.blue['pri']!,
                borderRadius: 10,
                borderLength: 20,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          /*Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                  'Barcode Type: ${(result.format)}   Data: ${result.code}')
                  : Text('Scan a code'),
            ),
          )*/
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_checkingData)
        _checkResults(scanData).then((value) => setState(() {
              result = scanData;
            }));
      /*setState(() {
        result = scanData;
      });*/
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class QRViewExample extends StatefulWidget {
  EvenementModel _evenement;
  List<PackageModel> _packageList;
  ThemeData _themeData;
  CustomAppTheme _customAppTheme;
  QRViewExample(this._evenement, this._packageList, this._themeData,
      this._customAppTheme);

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}
