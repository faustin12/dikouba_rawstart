import 'dart:async';
import 'dart:ui';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/event/eventaddpost_activity.dart';
import 'package:dikouba_rawstart/activity/event/eventnewsondage_activity.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/post_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/widget/SinglePostWidget.dart';
import 'package:dikouba_rawstart/widget/SingleSondageLiveWidget.dart';

import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EvenDetailsLiveActivity extends StatefulWidget {
  EvenementModel evenementModel;

  EvenDetailsLiveActivity(this.evenementModel,
      {Key? key, required this.analytics, required this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EvenDetailsLiveActivityState createState() =>
      _EvenDetailsLiveActivityState();
}

class _EvenDetailsLiveActivityState extends State<EvenDetailsLiveActivity> {
  static final String TAG = 'EvenDetailsActivityState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  static const int INDEX_POST = 0;
  static const int INDEX_SONDAGE = 1;

  bool _isEventPendingFinding = false;
  List<PostModel> _listPosts = [];
  List<SondageModel> _listSondages = [];

  late UserModel _userModel;
  int selectedCategory = INDEX_POST;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    _userModel = UserModel.fromJsonDb(userRows[0]);
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EvenDetailsLiveActivity",
      screenClassOverride: "EvenDetailsLiveActivity",
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
    // _setCurrentScreen();
    queryUser();
    updateEventList();
  }

  Widget getFloatingActionButton() {
    if (_userModel.id_annoncers != widget.evenementModel.id_annoncers) {
      return Container();
    }
    if (selectedCategory == INDEX_POST) {
      return FloatingActionButton(
        onPressed: () {
          _sendAnalyticsEvent("PressCreatePost");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EvenAddPostActivity(
                        evenementModel: widget.evenementModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));
        },
        backgroundColor: DikoubaColors.blue['pri'],
        child: Icon(
          MdiIcons.folderMultiplePlus,
          size: MySize.size32,
          color: Colors.white,
        ),
      );
    }
    return FloatingActionButton(
      onPressed: () {
        _sendAnalyticsEvent("PressCreateSondage");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EvenNewSondageActivity(
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
    );
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
                    floatingActionButton: getFloatingActionButton(),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: Spacing.fromLTRB(8, 8, 8, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: Spacing.all(8),
                                  decoration: BoxDecoration(
                                    color: customAppTheme.bgLayer1,
                                    border: Border.all(
                                        color: customAppTheme.bgLayer4,
                                        width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(MySize.size8)),
                                  ),
                                  child: Icon(MdiIcons.chevronLeft,
                                      color: themeData.colorScheme.onBackground
                                          .withAlpha(220),
                                      size: MySize.size20),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  "Live ~ ${widget.evenementModel.title}",
                                  style: themeData.textTheme.bodyMedium?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: Spacing.left(12),
                                child: singleCategory(
                                    title: "Posts",
                                    iconData: MdiIcons.partyPopper,
                                    index: INDEX_POST),
                              ),
                              Container(
                                margin: Spacing.right(24),
                                child: singleCategory(
                                    title: "Sondages",
                                    iconData: MdiIcons.frequentlyAskedQuestions,
                                    index: INDEX_SONDAGE),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: _isEventPendingFinding
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          DikoubaColors.blue['pri']!),
                                    ),
                                  )
                                : (selectedCategory == INDEX_SONDAGE)
                                    ? (_listSondages == null ||
                                            _listSondages.length == 0)
                                        ? Container(
                                            margin:
                                                Spacing.fromLTRB(24, 16, 24, 0),
                                            child: Text(
                                              "Aucun sondage trouvé",
                                              style: themeData.textTheme.bodySmall?.copyWith(
                                                color: themeData.colorScheme.onBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12
                                              ),/* AppTheme.getTextStyle(
                                                  themeData.textTheme.caption,
                                                  fontSize: 12,
                                                  color: themeData
                                                      .colorScheme.onBackground,
                                                  fontWeight: 500,
                                                  xMuted: true), */
                                            ),
                                          )
                                        : Container(
                                            padding: Spacing.only(
                                                top: 16, bottom: 12),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: _listSondages.length,
                                              itemBuilder:
                                                  (BuildContext buildcontext,
                                                      int idxItem) {
                                                return Container(
                                                  margin:
                                                      Spacing.horizontal(14),
                                                  child:
                                                      SingleSondageLiveWidget(
                                                          customAppTheme,
                                                          _listSondages[
                                                              idxItem],
                                                          _userModel,
                                                          MySize.safeWidth -
                                                              MySize.size48),
                                                );
                                              },
                                            ),
                                          )
                                    : (_listPosts == null ||
                                            _listPosts.length == 0)
                                        ? Container(
                                            margin:
                                                Spacing.fromLTRB(24, 16, 24, 0),
                                            child: Text(
                                              "Aucun post trouvé",
                                              style: themeData.textTheme.bodySmall?.copyWith(
                                                color: themeData.colorScheme.onBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12
                                              ),/* AppTheme.getTextStyle(
                                                  themeData.textTheme.caption,
                                                  fontSize: 12,
                                                  color: themeData
                                                      .colorScheme.onBackground,
                                                  fontWeight: 500,
                                                  xMuted: true), */
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color:  Colors.grey.shade100,),
                                            padding: Spacing.only(
                                                top: 16, bottom: 12),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: _listPosts.length,
                                              itemBuilder:
                                                  (BuildContext buildcontext,
                                                      int idxItem) {
                                                PostModel item =
                                                    _listPosts[idxItem];
                                                DateTime _startDate = DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(item
                                                                .created_at!
                                                                .seconds) *
                                                            1000);

                                                return getPostItemText(
                                                    item, idxItem);
                                              },
                                            ),
                                          )),
                      ],
                    )));
      },
    );
  }

  Widget getPostItemText(PostModel postModel, int idxItem) {
    return SinglePostWidget(
      customAppTheme,
      postModel,
      _userModel.id_users,
      analytics: widget.analytics,
      observer: widget.observer,
      onItemChangeListener: () {
        updateEventList();
      },
    );
  }

  Widget getSondageItemText(PostModel postModel, int idxItem) {
    return SinglePostWidget(
      customAppTheme,
      postModel,
      _userModel.id_users,
      analytics: widget.analytics,
      observer: widget.observer,
      onItemChangeListener: () {
        updateEventList();
      },
    );
  }

  void updateEventList() {
    print(
        "$TAG:updateEventList selectedCategory=$selectedCategory INDEX_SONDAGE=$INDEX_SONDAGE");
    switch (selectedCategory) {
      case INDEX_POST:
        findPosts();
        break;
      case INDEX_SONDAGE:
        _listPosts = [];
        findSondage();
        // setState(() {
        //   _listEventsPending = new List();
        // });
        break;
    }
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
                  : customAppTheme.bgLayer1,
              border: Border.all(
                  color: customAppTheme.bgLayer3, width: isSelected ? 0 : 0.8),
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
                    color: isSelected ? themeData.colorScheme.onPrimary : themeData.colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void findSondage() async {
    setState(() {
      _isEventPendingFinding = true;
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

  void findPosts() async {
    setState(() {
      _isEventPendingFinding = true;
    });
    API
        .findPostsEvent(widget.evenementModel.id_evenements!)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findSondage ${responseEvents.statusCode}|${responseEvents.data}");
        List<PostModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(PostModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isEventPendingFinding = false;
          _listPosts = list;
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
