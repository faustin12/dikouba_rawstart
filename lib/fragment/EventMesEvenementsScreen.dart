import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/activity/event/eventupdate_activity.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/model/annoncer_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:geocoder/geocoder.dart';

class EventMyEventScreen extends StatefulWidget {
  UserModel userModel;
  EventMyEventScreen(this.userModel, {required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventMyEventScreenState createState() => _EventMyEventScreenState();
}

class _EventMyEventScreenState extends State<EventMyEventScreen> {
  static final String TAG = 'EventMyEventScreen';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  int selectedCategory = 0;

  bool _isEventFinding = false;
  List<EvenementModel> _listEvents = [];

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventUpcomingScreen",
      screenClassOverride: "EventUpcomingScreen",
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
    findMyEvents();
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
                  : (_listEvents == null || _listEvents.length == 0)
                      ? Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: Text(
                            "Aucun évènement trouvé",
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
                          padding: Spacing.zero,
                          itemCount: _listEvents.length,
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
                            return _singleEvent(_listEvents[indexCateg]);
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
                    ?Image(
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
                              fontWeight: FontWeight.w600
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

  Widget _singleEvent(EvenementModel evenementModel) {
    return Container(
        margin: Spacing.symmetric(horizontal: 2, vertical: 2), //24 & 6
        child: SingleEventsWidget(customAppTheme, evenementModel,
            width: MySize.safeWidth - MySize.size48,
            onUpdateClickListener: gotoUpdateEvent, analytics: widget.analytics, observer: widget.observer,));
  }

  Future<void> gotoUpdateEvent(EvenementModel evenementItem) async {
    var resData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventUpdateActivity(
                  evenementModel: evenementItem,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
    print("$TAG:gotoUpdateEvent resData=$resData");
    if (resData != null && resData.toString() == "refresh") {
      findMyEvents();
    }
  }

  void findMyEvents() async {
    setState(() {
      _isEventFinding = true;
    });

    AnnoncerModel annoncerModel = AnnoncerModel.fromJson({
      "id_annoncers": widget.userModel.id_annoncers,
      "id_users": widget.userModel.id_users,
      "compagny": widget.userModel.annoncer_compagny,
      "created_at": widget.userModel.annoncer_created_at,
      "updated_at": widget.userModel.annoncer_updated_at,
      "picture_path": widget.userModel.annoncer_picture_path,
      "cover_picture_path": widget.userModel.annoncer_cover_picture_path,
      "checkout_phone_number": widget.userModel.annoncer_checkout_phone_number
    });

    API.createAnnoncer(annoncerModel).then((responseAnnoncer) {
      if (responseAnnoncer.statusCode == 200) {
        print(
            "${TAG}:findAnnoncer ${responseAnnoncer.statusCode}|${responseAnnoncer.data}");
        List<String> listIDevent = [];
        for (int i = 0;
            i < responseAnnoncer.data["arr_evenements"].length;
            i++) {
          listIDevent
              .add(responseAnnoncer.data["arr_evenements"][i].toString());
        }
        ;

        API.findAllSession(listIDevent).then((responseEvents) {
          if (responseEvents.statusCode == 200) {
            print(
                "${TAG}:findMyevent ${responseEvents.statusCode}|${responseEvents.data}");
            List<EvenementModel> list = [];
            for (int i = 0; i < responseEvents.data.length; i++) {
              list.add(EvenementModel.fromJson(responseEvents.data[i]));
            }

            if (!mounted) return;
            setState(() {
              _isEventFinding = false;
              _listEvents = list;
            });
          } else {
            print("${TAG}:findMyevent no data ${responseEvents.toString()}");

            if (!mounted) return;
            setState(() {
              _isEventFinding = false;
            });
          }
        }).catchError((errWalletAddr) {
          print("${TAG}:findMyevent errorinfo ${errWalletAddr.toString()}");

          if (!mounted) return;
          setState(() {
            _isEventFinding = false;
          });
        });
        if (!mounted) return;
      } else {
        print("${TAG}:findAnnoncer no data ${responseAnnoncer.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findAnnoncer errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isEventFinding = false;
      });
    });
  }
}

class SingleEventsWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  EvenementModel evenementModel;
  Function onUpdateClickListener;
  @required double width;
  SingleEventsWidget(this.customAppTheme, this.evenementModel,
      {required this.width,
      required this.analytics,
      required this.observer,
      required this.onUpdateClickListener});

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
        margin: Spacing.symmetric(
            horizontal: MySize.size12, vertical: MySize.size8), //12 & 8
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 0.0), //20 instead of 2
          child: InkWell(
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
                                  image: NetworkImage(
                                      widget.evenementModel.banner_path),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, right: 10.0),
                              child: InkWell(
                                onTap: () {
                                  widget.onUpdateClickListener(
                                      widget.evenementModel);
                                },
                                child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.edit,
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
                                      color: Colors.black38,
                                      size: 17.0,
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
                                            DateFormat('dd MMM yy HH:mm')
                                                .format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(widget
                                                                .evenementModel
                                                                .start_date!
                                                                .seconds) *
                                                            1000)),
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
                ),
              )),
        ));
  }
}
