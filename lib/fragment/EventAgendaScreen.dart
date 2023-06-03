import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/calendar/table_calendar.dart';
import 'package:dikouba_rawstart/main.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/evenementfavoris_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EventAgendaScreen extends StatefulWidget {
  UserModel userModel;
  EventAgendaScreen(this.userModel, {required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventAgendaScreenState createState() => _EventAgendaScreenState();
}

class _EventAgendaScreenState extends State<EventAgendaScreen> {
  static final String TAG = '_EventCreateScreenState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  final int selected = 5;
  final TextStyle selectedText = TextStyle(
    color: Colors.deepOrange,
    fontWeight: FontWeight.bold,
  );
  final TextStyle daysText = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade800,
  );

  late DateTime _selectedDay;
  late Map<DateTime, List<EvenementModel>> _allDatedEvents;
  late List<EvenementModel> _allEvents;
  late List<EvenementModel> _selectedEvents;

  late AsyncSnapshot<List<EvenementModel>> eventsp;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  late bool builded;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventAgendaScreen",
      screenClassOverride: "EventAgendaScreen",
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
    _allDatedEvents = Map();
    _selectedEvents = [];
    _selectedDay = DateTime.parse(
        DateTime.now().toString().substring(0, 10) + " 00:00:00.000");
    builded = false;

    findEventSessions();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            navigatorKey: MyApp.AgendaNavigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Container(
                    color: customAppTheme.bgLayer2,
                    child: HeaderWidget(
                        header: Container(
                          child: _buildTableCalendar(),
                        ),
                        body: getEventsList(),
                        backColor: DikoubaColors.blue['pri']!),)));
      },
    );
  }

  Widget getEventsList() {
    print("$TAG:getEventsList constructor");
    if (_selectedEvents == null || _selectedEvents.length == 0)
      return const Center(
        child: Text(
          "Aucun évènement",
          style: TextStyle(fontSize: 30.0, color: Colors.white54),
        ),
      );

    return ListView.builder(
      padding: EdgeInsets.all(2.0),
      primary: false,
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _selectedEvents.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6),
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8, bottom: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            color: Colors.white
          ),
          child: InkWell(
            child: eventItem(_selectedEvents[index]),
            onTap: () {
              print("$TAG:getEventsList");
              _sendAnalyticsEvent("tapOpenEventDetail_Agenda");
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => EvenDetailsActivity(_selectedEvents[index],
                analytics: widget.analytics,
                observer: widget.observer,
              )));
            },
          ),
        );
      },
    );
  }

  Widget eventItem(EvenementModel event) {
    List<Widget> widgets = [];
    List<Widget> sessionWidgets = [];
    widgets.addAll([
      _buildEventItem(event),
      // const Divider(),
    ]);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'fr_FR',
      events: _allDatedEvents == null ? {} : _allDatedEvents,
      initialCalendarFormat: CalendarFormat.twoWeeks,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDay: _selectedDay,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: '2 weeks',
        CalendarFormat.week: 'Week',
      },
      daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.black),
          weekendStyle: TextStyle(color: Colors.black)),
      calendarStyle: CalendarStyle(
        selectedColor: Colors.black,
        todayColor: Colors.grey,
        markersColor: Colors.green,
        todayMarkersColor: Colors.brown,
        outsideMarkersColor: Colors.red,
        markersMaxAmount: 1,
        todayStyle: TextStyle(
            color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
        selectedStyle: TextStyle(
            color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
        weekdayStyle: TextStyle(color: Colors.black),
        weekendStyle: TextStyle(color: Colors.black),
        outsideWeekendStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        outsideStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
      ),
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(MdiIcons.chevronLeft,color: themeData.colorScheme.onPrimary,),
          rightChevronIcon: Icon(null),
          formatButtonVisible: false,
          centerHeaderTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold)),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  void findEventSessions() async {
    API.findEventFavoris(widget.userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findEventSessions ${responseEvents.statusCode}|${responseEvents.data}");

        Map<DateTime, List<EvenementModel>> tmpDatedEvents = _allDatedEvents;

        for (int i = 0; i < responseEvents.data.length; i++) {
          EvenementFavorisModel itemEvent = EvenementFavorisModel.fromJson(responseEvents.data[i]);

          DateTime tmpStartDate = DateTime.fromMillisecondsSinceEpoch(int.parse(itemEvent.evenements!.start_date!.seconds) * 1000);
          DateTime tmpEndDate = DateTime.fromMillisecondsSinceEpoch(int.parse(itemEvent.evenements!.end_date!.seconds) * 1000);

          for (int i = 0; i <= tmpEndDate.difference(tmpStartDate).inDays; i++) {
            DateTime tmpDay = tmpStartDate.add(Duration(days: i));
            tmpDay = DateFormat("dd-MM-yyyy").parse(DateFormat("dd-MM-yyyy").format(tmpDay));
            print("$TAG:findEventSessions ${DateFormat("dd MMMM yyyy HH:mm").format(tmpDay)}");

            if(tmpDatedEvents[tmpDay] == null) tmpDatedEvents[tmpDay] = [];
            tmpDatedEvents[tmpDay]!.add(itemEvent.evenements!);
          }
          // tmpDatedEvents[new DateTime.now()] = list;
        }

        if(!mounted) return;
        setState(() {
          _allDatedEvents = tmpDatedEvents;
          _onDaySelected(_selectedDay, _allDatedEvents[_selectedDay]!);
        });

      } else {
        print("${TAG}:findEventSessions no data ${responseEvents.toString()}");

        if(!mounted) return;
        setState(() {
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findEventSessions errorinfo ${errWalletAddr.toString()}");

      if(!mounted) return;
      setState(() {
      });
    });
  }

  void _onDaySelected(DateTime day, List events) {
    print("$TAG:_onDaySelected Day selected = $day, \n events = $events");
    _sendAnalyticsEvent("tapOnDay_Agenda");
    setState(() {
      _selectedDay = day;
      _selectedEvents = events.cast<EvenementModel>();
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print("first date = $first,\n last date = $last");
  }

  Row _buildEventItem(EvenementModel event) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
            child: Image(
              image: NetworkImage(event.banner_path),
              width: MySize.getScaledSizeHeight(80),
              height: MySize.size72,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: Spacing.left(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: themeData.textTheme.titleSmall?.copyWith(
                    color: themeData.colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  event.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: themeData.textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                  ),/*getTextStyle(
                      themeData.textTheme.caption,
                      fontSize: 12,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500,
                      xMuted: true),*/
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class HeaderWidget extends StatefulWidget {
  final Widget? body;
  final Widget? header;
  final Color headerColor;
  final Color backColor;

  const HeaderWidget(
      {Key? key,
        this.body,
        this.header,
        this.headerColor = Colors.white,
        this.backColor = Colors.blue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HeaderWidgetState();
  }
}
class HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Stack _buildBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          top: 0,
          width: 10,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: widget.backColor,
                borderRadius:
                BorderRadius.only(topLeft: Radius.circular(20.0))),
          ),
        ),
        Positioned(
          right: 0,
          top: 100,
          width: 50,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backColor,
            ),
          ),
        ),
        Column(
          children: <Widget>[
            widget.header != null
                ? Container(
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(20.0)),
                  color: widget.headerColor,
                ),
                child: widget.header)
                : Container(),
            widget.body != null
                ? Expanded(
              child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0))),
                  elevation: 0,
                  color: widget.backColor,
                  child: widget.body),
            )
                : Container(),
          ],
        ),
      ],
    );
  }
}
