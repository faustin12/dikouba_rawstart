import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/activity/event/eventupdatesondage_activity.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/sondagereponse_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:dikouba_rawstart/widget/SingleSondageWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EventSondagesScreen extends StatefulWidget {
  UserModel userModel;
  EventSondagesScreen(this.userModel, {required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventSondagesScreenState createState() => _EventSondagesScreenState();
}

class _EventSondagesScreenState extends State<EventSondagesScreen> {
  static final String TAG = '_EventSondagesScreenState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  int selectedCategory = 0;

  bool _isEventFinding = false;
  late List<SondageReponseModel> _listSondagesrep;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventSondagesScreen",
      screenClassOverride: "EventSondagesScreen",
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
    super.initState();
    _setCurrentScreen();
    findEventsPending();
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
              child: _isEventFinding
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            DikoubaColors.blue['pri']!),
                      ),
                    )
                  : (_listSondagesrep == null || _listSondagesrep.length == 0)
                      ? Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: Text(
                            "Aucun sondage trouvé",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 12
                            ),/*AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontSize: 12,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500,
                                xMuted: true),*/
                          ),
                        )
                      : ListView.separated(
                          padding: Spacing.vertical(24),
                          itemCount: _listSondagesrep.length,
                          separatorBuilder: (context, index) {
                            return Container(
                              margin: Spacing.vertical(4),
                            );
                          },
                          itemBuilder:
                              (BuildContext buildcontext, int indexCateg) {
                            return Container(
                              margin: Spacing.horizontal(24),
                              height: 240,
                              child: SingleSondageWidget(
                                customAppTheme,
                                _listSondagesrep[indexCateg].sondages!,
                                widget.userModel,
                                MySize.safeWidth,
                                onUpdateClickListener: () {
                                  gotoUpdateSondage(
                                      _listSondagesrep[indexCateg].sondages!,
                                      _listSondagesrep[indexCateg]
                                          .id_evenements);
                                },
                              ),
                            );
                          },
                        ),
            )));
      },
    );
  }

  Widget singleEvent(EvenementModel evenementModel,
      {required String image, required String name, required String date, required String time}) {
    return Container(
      margin: Spacing.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EvenDetailsActivity(
                        evenementModel,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      )));
        },
        child: Row(
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child: image.contains('assets')
                    ? Image(
                  image: AssetImage(image),
                  width: MySize.getScaledSizeHeight(80),
                  height: MySize.size72,
                  fit: BoxFit.cover,
                ):Image(
                  image: NetworkImage(image),
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
                      margin: Spacing.top(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0
                                ),/*AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    fontSize: 12,
                                    color: themeData.colorScheme.onBackground,
                                    xMuted: true),*/
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  date,
                                  style: themeData.textTheme.bodyMedium?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Heure",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0
                                ),/*AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: 12,
                                    xMuted: true),*/
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  time,
                                  style: themeData.textTheme.bodyMedium?.copyWith(
                                    color: themeData.colorScheme.onBackground,
                                  ),
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

  Future<void> gotoUpdateSondage(
      SondageModel sondageModel, String idEvenement) async {
    var resData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EvenUpdateSondageActivity(
                  sondageModel: sondageModel,
                  idEvenement: idEvenement,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
    print("$TAG:gotoUpdateEvent resData=$resData");
    if (resData != null && resData.toString() == "refresh") {
      findEventsPending();
    }
  }

  void findEventsPending() async {
    setState(() {
      _isEventFinding = true;
    });
    API.findSondageUsers(widget.userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<SondageReponseModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(SondageReponseModel.fromJson(responseEvents.data[i]));
        }

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
          _listSondagesrep = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isEventFinding = false;
      });
    });
  }
}
