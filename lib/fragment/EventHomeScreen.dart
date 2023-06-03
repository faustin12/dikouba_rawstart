import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/activity/event/eventdetailslive_activity.dart';
import 'package:dikouba_rawstart/activity/event/eventnewevent_activity.dart';
import 'package:dikouba_rawstart/activity/eventnewsessions_activity.dart';
import 'package:dikouba_rawstart/main.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/evenementfavoris_model.dart';
import 'package:dikouba_rawstart/model/evenementlike_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/sondagereponse_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:dikouba_rawstart/widget/SingleSondageWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:geocoder/geocoder.dart';

class EventHomeScreen extends StatefulWidget {
  UserModel userModel;

  EventHomeScreen(this.userModel, {required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventHomeScreenState createState() => _EventHomeScreenState();
}

class _EventHomeScreenState extends State<EventHomeScreen> {
  static final String TAG = '_EventHomeScreenState';

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  bool _isEventAllFinding = false;
  late List<EvenementModel> _listEventsAll;

  List<Widget> _listPageWidgets = [];
  Map<String, EvenementLikeModel> mapLikemdl = {};
  Map<String, EvenementFavorisModel> mapFavorismdl = {};

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventHomeScreen",
      screenClassOverride: "EventHomeScreen",
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
    MyApp.findUserEventLikes.start();
    findUserEventLikes();
    MyApp.findUserEventLikes.stop();
    MyApp.findUserEventFavoris.start();
    findUserEventFavoris();
    MyApp.findUserEventFavoris.stop();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            navigatorKey: MyApp.HomeNavigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                floatingActionButton: (widget.userModel.id_annoncers == null ||
                        widget.userModel.id_annoncers == "")
                    ? Container()
                    : FloatingActionButton(
                        onPressed: () {
                          _sendAnalyticsEvent("PressCreateEvent_inHome");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EvenNewEventActivity(
                                        analytics: widget.analytics,
                                        observer: widget.observer,
                                      )));
                        },
                        backgroundColor: DikoubaColors.blue['pri'],
                        child: Icon(
                          MdiIcons.plus,
                          size: MySize.size32,
                          color: Colors.white,
                        ),
                      ),
                body: Container(
                  color: customAppTheme.bgLayer1,
                  child: FutureBuilder<List<Widget>>(
                      future: initWidgetListview(),
                      builder: (BuildContext buildcontext,
                          AsyncSnapshot<List<Widget>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: Container(
                            width: MySize.size32,
                            height: MySize.size32,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  DikoubaColors.blue['pri']!),
                            ),
                          ));
                        } else {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Erreur: ${snapshot.error}'));
                          } else {
                            return ListView(
                              padding: Spacing.vertical(0),
                              children: snapshot.data!,
                            );
                          }
                        }
                      }),
                )));
      },
    );
  }

  Future<List<Widget>> initWidgetListview() async {
    _listPageWidgets = [];

    _listPageWidgets.add(Container(
      margin: Spacing.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: Spacing.vertical(4),
              decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  border: Border.all(color: customAppTheme.bgLayer3, width: 1),
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size8))),
              child: Row(
                children: [
                  Container(
                    margin: Spacing.left(12),
                    child: Icon(
                      MdiIcons.magnify,
                      color: themeData.colorScheme.onBackground.withAlpha(200),
                      size: MySize.size16,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: Spacing.left(12),
                      child: TextFormField(
                        style: themeData.textTheme.bodyMedium?.copyWith(
                          color: themeData.colorScheme.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          fillColor: customAppTheme.bgLayer1,
                          hintStyle: themeData.textTheme.bodyMedium?.copyWith(
                            color: themeData.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                          // AppTheme.getTextStyle(
                          //     themeData.textTheme.bodyText2,
                          //     color: themeData.colorScheme.onBackground,
                          //     muted: true,
                          //     fontWeight: 500),
                          hintText: "Find Events...",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // showDialog(
              //     context: context,
              //     builder: (BuildContext context) =>
              //         EventFilterDialog());
            },
            child: Container(
              margin: Spacing.left(16),
              padding: Spacing.all(8),
              decoration: BoxDecoration(
                  color: DikoubaColors.blue['pri'],
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                  boxShadow: [
                    BoxShadow(
                        color: themeData.colorScheme.primary.withAlpha(80),
                        blurRadius: MySize.size4,
                        offset: Offset(0, MySize.size2))
                  ]),
              child: Icon(
                MdiIcons.tune,
                size: MySize.size20,
                color: themeData.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    ));
    _listPageWidgets.add(Container(
      margin: Spacing.top(8),
      padding: Spacing.vertical(8),
      child: MultipleEventsWidget(customAppTheme, widget.userModel, analytics: widget.analytics, observer: widget.observer, ),
    ));
    _listPageWidgets.add(Container(
      margin: Spacing.fromLTRB(24, 16, 24, 0),
      child: Text(
        "Tous les évènements",
        style: themeData.textTheme.titleMedium?.copyWith(
          color: themeData.colorScheme.onBackground,
          fontWeight: FontWeight.w700,
        )
      ),
    ));

    MyApp.getAllEventServer.start();
    var responseEvents = await API.findAllEvents();
    MyApp.getAllEventServer.stop();

    print(
        "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
    if (responseEvents.statusCode == 200) {
      List<EvenementModel> list = [];
      List<Widget> listWidgets = [];
      for (int i = 0; i < responseEvents.data.length; i++) {
        EvenementModel item = EvenementModel.fromJson(responseEvents.data[i]);
        DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(item.start_date!.seconds) * 1000);
        DateTime _endDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(item.end_date!.seconds) * 1000);

        list.add(item);
        listWidgets.add(Container(
          margin: Spacing.symmetric(horizontal: 24, vertical: 6),
          child: SingleEventsWidget(
              customAppTheme,
              item,
              widget.userModel.id_users,
              mapLikemdl.containsKey(item.id_evenements),
              mapFavorismdl.containsKey(item.id_evenements),
              title: "${item.title}",
              image: item.banner_path,
              date: DateFormat('dd').format(_startDate),
              month: DateFormat('MMM').format(_startDate),
              subject: "${item.description}",
              time:
                  "Du ${DateFormat('dd MMM HH:mm').format(_startDate)}\nAu ${DateFormat('dd MMM HH:mm').format(_endDate)}",
              width: MySize.safeWidth - MySize.size48, analytics: widget.analytics, observer: widget.observer,),
        ));
      }
      _listPageWidgets.addAll(listWidgets);
    }

    return Future.value(_listPageWidgets);
  }

  void findUserEventLikes() async {
    API.findUserLikes(widget.userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findUserEventLikes ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          EvenementLikeModel item =
              EvenementLikeModel.fromJson(responseEvents.data[i]);

          mapLikemdl[item.id_evenements!] = item;
        }

        if (!mounted) return;
        setState(() {});
      } else {
        print("${TAG}:findUserEventLikes no data ${responseEvents.toString()}");
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findUserEventLikes errorinfo ${errWalletAddr.toString()}");
    });
  }

  void findUserEventFavoris() async {
    API.findUserFavoris(widget.userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findUserEventFavoris ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          EvenementFavorisModel item =
              EvenementFavorisModel.fromJson(responseEvents.data[i]);

          mapFavorismdl[item.id_evenements!] = item;
        }

        if (!mounted) return;
        setState(() {});
      } else {
        print(
            "${TAG}:findUserEventFavoris no data ${responseEvents.toString()}");
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:findUserEventFavoris errorinfo ${errWalletAddr.toString()}");
    });
  }
}

class MultipleEventsWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  UserModel userModel;
  MultipleEventsWidget(this.customAppTheme, this.userModel,
      {required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  MultipleEventsWidgetState createState() => MultipleEventsWidgetState();
}

class MultipleEventsWidgetState extends State<MultipleEventsWidget> {
  static const String TAG = 'MultipleEventsWidgetState';
  static const int INDEX_POPULAR = 0;
  static const int INDEX_SONDAGE = 2;
  static const int INDEX_LIVE = 1;

  bool _isEventPendingFinding = false;
  List<EvenementModel> _listEventsPending = [];
  List<SondageModel> _listSondages = [];

  int selectedCategory = INDEX_POPULAR;

  late ThemeData themeData;

  @override
  void initState() {
    super.initState();

    updateEventList();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Container(
      margin: Spacing.top(8),
      padding: Spacing.vertical(8),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  margin: Spacing.left(12),
                  child: singleCategory(
                      title: "Populaire",
                      iconData: MdiIcons.partyPopper,
                      index: INDEX_POPULAR),
                ),
                singleCategory(
                    title: "Live", iconData: MdiIcons.play, index: INDEX_LIVE),
                Container(
                  margin: Spacing.right(24),
                  child: singleCategory(
                      title: "Sondage",
                      iconData: MdiIcons.frequentlyAskedQuestions,
                      index: INDEX_SONDAGE),
                ),
              ],
            ),
          ),
          // Container(
          //   margin: Spacing.fromLTRB(24, 4, 24, 0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Text(
          //           "",
          //           style: AppTheme.getTextStyle(
          //               themeData.textTheme.subtitle1,
          //               fontWeight: 700,
          //               color: themeData.colorScheme.onBackground),
          //         ),
          //       ),
          //       Text(
          //         "Tout voir",
          //         style: AppTheme.getTextStyle(
          //             themeData.textTheme.caption,
          //             fontWeight: 600,
          //             color: themeData.colorScheme.primary),
          //       ),
          //     ],
          //   ),
          // ),
          _isEventPendingFinding
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        DikoubaColors.blue['pri']!),
                  ),
                )
              : (selectedCategory == INDEX_SONDAGE)
                  ? (_listSondages == null || _listSondages.length == 0)
                      ? Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: Text(
                            "Aucun sondage trouvé",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            // AppTheme.getTextStyle(
                            //     themeData.textTheme.caption,
                            //     fontSize: 12,
                            //     color: themeData.colorScheme.onBackground,
                            //     fontWeight: 500,
                            //     xMuted: true),
                          ),
                        )
                      : Container(
                          margin: Spacing.top(16),
                          height: MySize.safeWidth * 0.6,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: _listSondages.length,
                            itemBuilder:
                                (BuildContext buildcontext, int indexCateg) {
                              return Container(
                                margin: Spacing.left(24),
                                child: SingleSondageWidget(
                                    widget.customAppTheme,
                                    _listSondages[indexCateg],
                                    widget.userModel,
                                    MySize.safeWidth - MySize.size48, onUpdateClickListener: () => {},), // TODO : Change onUpdateClickListener
                              );
                            },
                          ),
                        )
                  : (_listEventsPending == null ||
                          _listEventsPending.length == 0)
                      ? Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: Text(
                            "Aucun évènement trouvé",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            // AppTheme.getTextStyle(
                            //     themeData.textTheme.caption,
                            //     fontSize: 12,
                            //     color: themeData.colorScheme.onBackground,
                            //     fontWeight: 500,
                            //     xMuted: true),
                          ),
                        )
                      : Container(
                          margin: Spacing.top(16),
                          height: MySize.safeWidth * 0.53,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: _listEventsPending.length,
                            itemBuilder:
                                (BuildContext buildcontext, int indexCateg) {
                              EvenementModel item =
                                  _listEventsPending[indexCateg];

                              DateTime _startDate =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(item.start_date!.seconds) *
                                          1000);
                              DateTime _endDate =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(item.end_date!.seconds) * 1000);

                              return Container(
                                margin: Spacing.left(24),
                                child: singleEvent(item,
                                    title: "${item.title}",
                                    image: item.banner_path,
                                    date:
                                        DateFormat('dd').format(_startDate),
                                    month:
                                        DateFormat('MMM').format(_startDate),
                                    subject: "${item.description}",
                                    time:
                                        "${DateFormat('dd MMM HH:mm').format(_startDate)} - ${DateFormat('dd MMM HH:mm').format(_endDate)}",
                                    width: MySize.safeWidth * 0.6,
                                    isLive: true),
                              );
                            },
                          ),
                        ),
        ],
      ),
    );
  }

  Widget singleCategory({IconData? iconData, String? title, int? index}) {
    bool isSelected = (selectedCategory == index);
    return InkWell(
        onTap: () {
          if (!isSelected) {
            setState(() {
              selectedCategory = index!;
              updateEventList();
            });
          }
        },
        child: Container(
          margin: Spacing.fromLTRB(12, 8, 0, 8),
          decoration: BoxDecoration(
              color: isSelected
                  ? DikoubaColors.blue['pri']
                  : widget.customAppTheme.bgLayer1,
              border: Border.all(
                  color: widget.customAppTheme.bgLayer3,
                  width: isSelected ? 0 : 0.8),
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: themeData.colorScheme.primary.withAlpha(80),
                          blurRadius: MySize.size6,
                          spreadRadius: 1,
                          offset: Offset(0, MySize.size2))
                    ]
                  : []),
          padding: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                size: MySize.size22,
                color: isSelected
                    ? themeData.colorScheme.onPrimary
                    : themeData.colorScheme.onBackground,
              ),
              Container(
                margin: Spacing.left(8),
                child: Text(
                  title!,
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                          ? themeData.colorScheme.onPrimary
                          : themeData.colorScheme.onBackground,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget singleEvent(EvenementModel evenementModel,
      {String? image,
      String? date,
      String? month,
      String? title,
      String? subject,
      String? time,
      required double width,
      required bool isLive}) {
    return InkWell(
      onTap: () {
        if (isLive) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EvenDetailsActivity(
                    evenementModel,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )));
          /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EvenDetailsLiveActivity(
                        evenementModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));*/
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EvenDetailsActivity(
                        evenementModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));
        }
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: widget.customAppTheme.bgLayer1,
            border:
                Border.all(color: widget.customAppTheme.bgLayer3, width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(MySize.size8),
                        topRight: Radius.circular(MySize.size8)),
                    child: image!.contains('assets') ? Image(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                      width: width,
                      height: width * 0.5,
                    ) : Image(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                      width: width,
                      height: width * 0.5,
                    ),
                  ),
                  Positioned(
                    bottom: -MySize.size16,
                    left: MySize.size16,
                    child: Container(
                      padding: Spacing.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                          color: widget.customAppTheme.bgLayer1,
                          border: Border.all(
                              color: widget.customAppTheme.bgLayer3,
                              width: 0.5),
                          boxShadow: [
                            BoxShadow(
                                color: widget.customAppTheme.shadowColor
                                    .withAlpha(150),
                                blurRadius: 1,
                                offset: Offset(0, 1))
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size8))),
                      child: Column(
                        children: [
                          Text(
                            date!,
                            style: themeData.textTheme.bodyMedium?.copyWith(
                              color: DikoubaColors.blue['pri']!,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            month!,
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: DikoubaColors.blue['pri']!,
                              fontWeight: FontWeight.w600,
                              fontSize: 11
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: Spacing.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.textTheme.bodyMedium?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void updateEventList() {
    print(
        "$TAG:updateEventList selectedCategory=$selectedCategory INDEX_SONDAGE=$INDEX_SONDAGE");
    switch (selectedCategory) {
      case INDEX_LIVE:
        findEventsPending();
        break;
      case INDEX_POPULAR:
        findEventsPopular();
        break;
      case INDEX_SONDAGE:
        _listEventsPending = [];
        findSondage();
        // setState(() {
        //   _listEventsPending = [];
        // });
        break;
    }
  }

  void findEventsPending() async {
    setState(() {
      _isEventPendingFinding = true;
    });
    API.findPendingEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
          _listEventsPending = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isEventPendingFinding = false;
      });
    });
  }

  void findEventsPopular() async {
    setState(() {
      _isEventPendingFinding = true;
    });
    API.findAllEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }

        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
          _listEventsPending = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isEventPendingFinding = false;
      });
    });
  }

  void findEventsTermine() async {
    setState(() {
      _isEventPendingFinding = true;
    });
    API.findEndedEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
          _listEventsPending = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isEventPendingFinding = false;
      });
    });
  }

  void findSondage() async {
    setState(() {
      _isEventPendingFinding = true;
    });
    API.findSondages().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findSondage ${responseEvents.statusCode}|${responseEvents.data}");
        List<SondageModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(SondageModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
          _listSondages = list;
        });
      } else {
        print("${TAG}:findSondage no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findSondage errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isEventPendingFinding = false;
      });
    });
  }
}

class SingleEventsWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  EvenementModel evenementModel;
  bool hasLike;
  bool hasFavoris;
  String idUser;
  String image;
  String date;
  String month;
  String title;
  String subject;
  String time;
  @required
  double width;
  SingleEventsWidget(this.customAppTheme, this.evenementModel, this.idUser,
      this.hasLike, this.hasFavoris,
      {required this.image,
      required this.date,
      required this.month,
      required this.title,
      required this.subject,
      required this.time,
      required this.width,
      required this.analytics,
      required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  SingleEventsWidgetState createState() => SingleEventsWidgetState();
}

class SingleEventsWidgetState extends State<SingleEventsWidget> {
  static const String TAG = 'SingleEventsWidgetState';

  late ThemeData themeData;

  bool _isEventLiking = false;
  bool _isEventFavoring = false;
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

  bool isFreeEvent = false;

  void checkFreeEvent() async {
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
          if (int.parse(packageModelgetMdl.price!) > 0) {
            return;
          }
        }
        setState(() {
          isFreeEvent = true;
        });
      } else {
        print("findEventPackages no data ${responsePackage.toString()}");
        /*setState(() {
          isFreeEvent = false;
        });*/
      }
    }).catchError((errWalletAddr) {
      print("findEventPackages errorinfo ${errWalletAddr.toString()}");
      /*setState(() {
          isFreeEvent = false;
        });*/
    });
  }

  @override
  void initState() {
    super.initState();
    getPositionInfo();
    checkFreeEvent();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EvenDetailsActivity(
                      widget.evenementModel,
                      analytics: widget.analytics,
                      observer: widget.observer,
                    )));
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: widget.customAppTheme.bgLayer1,
            border:
                Border.all(color: widget.customAppTheme.bgLayer3, width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(MySize.size8),
                        topRight: Radius.circular(MySize.size8)),
                    child: widget.image.contains('assets') ? Image(
                      image: NetworkImage(widget.image),
                      fit: BoxFit.cover,
                      width: widget.width,
                      height: widget.width * 0.5,
                    ) : Image(
                      image: AssetImage(widget.image),
                      fit: BoxFit.cover,
                      width: widget.width,
                      height: widget.width * 0.5,
                    ),
                  ),
                  Positioned(
                    bottom: -MySize.size16,
                    left: MySize.size16,
                    child: Container(
                      padding: Spacing.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                          color: widget.customAppTheme.bgLayer1,
                          border: Border.all(
                              color: widget.customAppTheme.bgLayer3,
                              width: 0.5),
                          boxShadow: [
                            BoxShadow(
                                color: widget.customAppTheme.shadowColor
                                    .withAlpha(150),
                                blurRadius: 1,
                                offset: Offset(0, 1))
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size8))),
                      child: Column(
                        children: [
                          Text(
                            widget.date,
                            style: themeData.textTheme.bodyMedium?.copyWith(
                              color: DikoubaColors.blue['pri']!,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.month,
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: DikoubaColors.blue['pri'],
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -MySize.size16,
                    right: MySize.size16,
                    child: Container(
                      //padding: Spacing.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                          color: widget.customAppTheme.bgLayer1,
                          border: Border.all(
                              color: widget.customAppTheme.bgLayer3,
                              width: 0.5),
                          boxShadow: [
                            BoxShadow(
                                color: widget.customAppTheme.shadowColor
                                    .withAlpha(150),
                                blurRadius: 1,
                                offset: Offset(0, 1))
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size8))),
                      child: InkWell(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size8)),
                          child: Image(
                            image:
                                AssetImage('./assets/logo/user_template.webp'),
                            fit: BoxFit.cover,
                            width: MySize.size40,
                            height: MySize.size40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: Spacing.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Row(children: [
                    Expanded(
                        child: Text(
                      widget.title,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodyMedium?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    Container(
                        child: Text(
                      isFreeEvent ? "Gratuit" : "",
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ])),
                  Container(
                    margin: Spacing.top(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  _eventLocationAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: themeData.textTheme.bodySmall?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                  // AppTheme.getTextStyle(
                                  //     themeData.textTheme.caption,
                                  //     fontSize: 10,
                                  //     color: themeData.colorScheme.onBackground,
                                  //     fontWeight: 500,
                                  //     xMuted: true),
                                ),
                              ),
                              Container(
                                margin: Spacing.top(0.5),
                                child: Text(
                                  widget.time,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: themeData.textTheme.bodySmall?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                  // AppTheme.getTextStyle(
                                  //     themeData.textTheme.caption,
                                  //     fontSize: 10,
                                  //     color: themeData.colorScheme.onBackground,
                                  //     fontWeight: 500,
                                  //     xMuted: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: _isEventFavoring
                              ? Icon(
                                  MdiIcons.bookmark,
                                  color: Colors.black12,
                                )
                              : InkWell(
                                  onTap: () {
                                    print(
                                        "hello singleEvent like ${widget.evenementModel.id_evenements}");

                                    if (widget.hasFavoris) {
                                      unFavorisEvent(
                                          widget.evenementModel.id_evenements!);
                                    } else {
                                      favorisEvent(
                                          widget.evenementModel.id_evenements!);
                                    }
                                  },
                                  child: widget.hasFavoris
                                      ? Icon(
                                          MdiIcons.bookmark,
                                          color: Colors.yellow,
                                        )
                                      : Icon(
                                          MdiIcons.bookmarkOutline,
                                          color: DikoubaColors.blue['pri'],
                                        ),
                                ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              print("hello singleEvent heartOutline");
                              /*Navigator.push(
                                  context, MaterialPageRoute(builder: (buildContext) => EvenNewSessionActivity(widget.evenementModel,
                                analytics: widget.analytics,
                                observer: widget.observer,
                              )));*/
                            },
                            child: Icon(
                              MdiIcons.shareVariant,
                              color: DikoubaColors.blue['pri'],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: _isEventLiking
                              ? Icon(
                                  MdiIcons.heart,
                                  color: Colors.black12,
                                )
                              : InkWell(
                                  onTap: () {
                                    print(
                                        "hello singleEvent favoris ${widget.evenementModel.id_evenements}");

                                    if (widget.hasLike) {
                                      unLikeEvent(
                                          widget.evenementModel.id_evenements!);
                                    } else {
                                      likeEvent(
                                          widget.evenementModel.id_evenements!);
                                    }
                                  },
                                  child: widget.hasLike
                                      ? Icon(
                                          MdiIcons.heart,
                                          color: Colors.redAccent,
                                        )
                                      : Icon(
                                          MdiIcons.heartOutline,
                                          color: DikoubaColors.blue['pri'],
                                        ),
                                ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void likeEvent(String idEvent) async {
    MyApp.likeEvent.start();
    print("${TAG}:likeEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventLiking = true;
    });
    API.eventAddLike(widget.idUser, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:likeEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementLikeModel likeMdl =
            EvenementLikeModel.fromJson(responseEvents.data);

        widget.hasLike = true;

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
    MyApp.likeEvent.stop();
  }

  void unLikeEvent(String idEvent) async {
    MyApp.unLikeEvent.start();
    print("${TAG}:likeEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventLiking = true;
    });
    API.eventDeleteLike(widget.idUser, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:unLikeEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementLikeModel likeMdl =
            EvenementLikeModel.fromJson(responseEvents.data);

        widget.hasLike = false;
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
    MyApp.unLikeEvent.stop();
  }

  void favorisEvent(String idEvent) async {
    MyApp.favorisEvent.start();
    print("${TAG}:favorisEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventFavoring = true;
    });
    API.eventAddFavoris(widget.idUser, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:favorisEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementFavorisModel favMdl =
            EvenementFavorisModel.fromJson(responseEvents.data);

        widget.hasFavoris = true;

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
    MyApp.favorisEvent.stop();
  }

  void unFavorisEvent(String idEvent) async {
    MyApp.unFavorisEvent.start();
    print("${TAG}:favorisEvent no data idEvent=${idEvent}");
    setState(() {
      _isEventFavoring = true;
    });
    API.eventDeleteFavoris(widget.idUser, idEvent).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:favorisEvent ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementFavorisModel favMdl =
            EvenementFavorisModel.fromJson(responseEvents.data);

        widget.hasFavoris = false;

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
    MyApp.unFavorisEvent.stop();
  }
}
