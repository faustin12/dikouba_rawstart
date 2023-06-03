import 'dart:async';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/activity/event/eventdetails_activity.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:intl/intl.dart';
import 'package:dikouba_rawstart/library/Page_Transformer_Card/page_transformer.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class LiveItemFragment extends StatefulWidget {
  CustomAppTheme customAppTheme;
  LiveItemFragment(this.customAppTheme,{required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  _LiveItemFragmentState createState() => _LiveItemFragmentState();
}

class _LiveItemFragmentState extends State<LiveItemFragment> {
  static final String TAG = "CategoriseItemFragmentState";

  static const int INDEX_ENCOURS = 0;
  static const int INDEX_AVENIR = 1;
  static const int INDEX_TERMINE = 2;
  static const int INDEX_ALL = 3;

  int selectedCategory = INDEX_TERMINE;

  late ThemeData themeData;

  ///
  /// check the condition is right or wrong for image loaded or no
  ///
  bool loadImage = false; //true;
  late Stream<List<EvenementModel>> _streamListEventMdl;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "CategoriseItemFragment",
      screenClassOverride: "CategoriseItemFragment",
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
    /*Timer(Duration(seconds: 3), () {
      setState(() {
        loadImage = false;
      });
    });*/
    // TODO: implement initState
    super.initState();
    _setCurrentScreen();
    _streamListEventMdl = findEventsTermine().asStream();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        margin: Spacing.left(12),
                        child: singleCategory(
                            title: "Terminé",
                            iconData: MdiIcons.chatOutline,
                            index: INDEX_TERMINE),
                      ),
                      singleCategory(
                          title: "En cours",
                          iconData: MdiIcons.progressCheck,
                          index: INDEX_ENCOURS),
                      singleCategory(
                          title: "A venir",
                          iconData: MdiIcons.partyPopper,
                          index: INDEX_AVENIR),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 0.0),
                    child: StreamBuilder(
                      stream: _streamListEventMdl,
                      builder: (BuildContext ctx,
                          AsyncSnapshot<List<EvenementModel>> snapshot) {
                        if (loadImage) {
                          return _loadingDataHeader(ctx);
                        } else {
                          if (!snapshot.hasData) {
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Aucun évènement",
                                style: themeData.textTheme.bodyMedium?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                ),
                              ),
                            );
                            //_loadingDataHeader(ctx);
                          } else {
                            return snapshot.data!.length > 0 ? new dataFirestore(
                              list: snapshot.data!,
                              dataUser: 'user', analytics: widget.analytics, observer: widget.observer,
                            ) : Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Aucun évènement",
                                style: themeData.textTheme.bodyMedium?.copyWith(
                                  color: themeData.colorScheme.onBackground,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget singleCategory({required IconData iconData, required String title, required int index}) {
    bool isSelected = (selectedCategory == index);
    return InkWell(
        onTap: () {
          if (!isSelected) {
            setState(() {
              selectedCategory = index;
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
                  color: widget.customAppTheme.bgLayer3, width: isSelected ? 0 : 0.8),
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
                  title,
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? themeData.colorScheme.onPrimary
                        : themeData.colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  )
                ),
              )
            ],
          ),
        ));
  }

  Future<List<EvenementModel>> initWidgetListview() async {
    setState(() {
      loadImage = true;
    });
    var responseEvents = await API.findAllEvents();
    print(
        "${TAG}:initWidgetListview ${responseEvents.statusCode}|${responseEvents.data}");
    if(responseEvents.statusCode == 200) {
      List<EvenementModel> list = [];
      for (int i = 0; i < responseEvents.data.length; i++) {
        EvenementModel item = EvenementModel.fromJson(responseEvents.data[i]);

        list.add(item);
      }
      setState(() {
        loadImage = false;
      });
      return Future.value(list);
    }
    setState(() {
      loadImage = false;
    });
    return Future.value(null);
  }

  void updateEventList() async {
    print("$TAG:updateEventList selectedCategory=$selectedCategory");

    switch(selectedCategory) {
      case INDEX_ENCOURS:
        _streamListEventMdl = findEventsPending().asStream();
        break;
      case INDEX_AVENIR:
        _streamListEventMdl = findEventsSoon().asStream();
        break;
      case INDEX_TERMINE:
        _streamListEventMdl = findEventsTermine().asStream();
        break;
      /*case INDEX_ALL:
        _streamListEventMdl = initWidgetListview().asStream();
        break;*/
    }
  }

  Future<List<EvenementModel>> findEventsPending() async {
    setState(() {
      loadImage = true;
    });
    var responseEvents = await API.findPendingEvents();
    print(
        "${TAG}:findEventsPending ${responseEvents.statusCode}|${responseEvents.data}");
    if(responseEvents.statusCode == 200) {
      List<EvenementModel> list = [];
      for (int i = 0; i < responseEvents.data.length; i++) {
        EvenementModel item = EvenementModel.fromJson(responseEvents.data[i]);

        list.add(item);
      }
      setState(() {
        loadImage = false;
      });
      return Future.value(list);
    }
    setState(() {
      loadImage = false;
    });
    return Future.value(null);
    /*API.findPendingEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = new List();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }
        return Future.value(list);
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        return Future.value(null);
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      return Future.value(null);
    });*/
  }

  Future<List<EvenementModel>> findEventsSoon() async {
    setState(() {
      loadImage = true;
    });
    var responseEvents = await API.findSoonEvents();
    print(
        "${TAG}:findEventsSoon ${responseEvents.statusCode}|${responseEvents.data}");
    if(responseEvents.statusCode == 200) {
      List<EvenementModel> list = [];
      for (int i = 0; i < responseEvents.data.length; i++) {
        EvenementModel item = EvenementModel.fromJson(responseEvents.data[i]);

        list.add(item);
      }
      setState(() {
        loadImage = false;
      });
      return Future.value(list);
    }
    setState(() {
      loadImage = false;
    });
    return Future.value(null);
    /*API.findSoonEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = new List();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }
        return Future.value(list);
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        return Future.value(null);
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      return Future.value(null);
    });*/
  }

  Future<List<EvenementModel>> findEventsTermine() async {
    setState(() {
      loadImage = true;
    });
    var responseEvents = await API.findEndedEvents();
    print(
        "${TAG}:findEventsTermine ${responseEvents.statusCode}|${responseEvents.data}");
    if(responseEvents.statusCode == 200) {
      List<EvenementModel> list = [];
      for (int i = 0; i < responseEvents.data.length; i++) {
        EvenementModel item = EvenementModel.fromJson(responseEvents.data[i]);

        list.add(item);
      }
      setState(() {
        loadImage = false;
      });
      return Future.value(list);
    }
    setState(() {
      loadImage = false;
    });
    return Future.value(null);
    /*API.findEndedEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = new List();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(EvenementModel.fromJson(responseEvents.data[i]));
        }
        return Future.value(list);
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        return Future.value(null);
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      return Future.value(null);
    });*/
  }
}

///
///
/// Calling imageLoading animation for set a grid layout
///
///
Widget _loadingDataHeader(BuildContext context) {
  double _height = MediaQuery.of(context).size.height;
  return SizedBox.fromSize(
    size: Size.fromHeight(_height / 1.3),
    child: PageTransformer(
      pageViewBuilder: (context, visibilityResolver) {
        return PageView.builder(
          controller: PageController(viewportFraction: 0.87),
          itemCount: 5,
          itemBuilder: (context, index) {
            return cardHeaderLoading(context);
          },
        );
      },
    ),
  );
}

Widget cardHeaderLoading(BuildContext context) {
  double _height = MediaQuery.of(context).size.height;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: _height / 1.3,
      width: 275.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.grey[500],
          boxShadow: [
            BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                spreadRadius: 0.2,
                blurRadius: 0.5)
          ]),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[400]!,
        highlightColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 320.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                height: 17.0,
                width: 70.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
              ),
              SizedBox(
                height: 25.0,
              ),
              Container(
                height: 20.0,
                width: 150.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 20.0,
                width: 250.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 20.0,
                width: 150.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
              ),
              SizedBox(
                height: 30.0,
              )
            ],
          ),
        ),
      ),
    ),
  );
}

class dataFirestore extends StatelessWidget {
  String dataUser;
  dataFirestore({required this.list, required this.dataUser,required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final List<EvenementModel> list;
  PageVisibility? pageVisibility;

  Widget _applyTextEffects({
    required double translationFactor,
    required Widget child,
  }) {
    final double xTranslation = pageVisibility!.pagePosition * translationFactor;

    return Opacity(
      opacity: pageVisibility!.visibleFraction,
      child: Transform(
        alignment: FractionalOffset.topLeft,
        transform: Matrix4.translationValues(
          xTranslation,
          0.0,
          0.0,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    var textTheme = Theme.of(context).textTheme;
    var imageOverlayGradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.bottomCenter,
          end: FractionalOffset.topCenter,
          colors: [
            const Color(0xFF000000),
            const Color(0x00000000),
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
          ],
        ),
      ),
    );

    return SizedBox.fromSize(
      size: Size.fromHeight(_height / 1.5),
      child: PageTransformer(
        pageViewBuilder: (context, visibilityResolver) {

          return PageView.builder(
            controller: PageController(viewportFraction: 0.86),
            itemCount: list.length,
            itemBuilder: (context, i) {
              DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(int.parse(list[i].start_date!.seconds) * 1000);

              String title = list[i].title!;
              String category = list[i].categories!.title!;
              String imageUrl = list[i].banner_path;
              String id = list[i].id_evenements!;
              String description = list[i].description!;
              String price = '50';
              String hours = DateFormat('HH:mm').format(_startDate);
              String date = DateFormat('dd MMM yyyy, HH:mm').format(_startDate);
              String location = "[${list[i].location!.latitude}, ${list[i].location!.longitude}]";
              String description2 = list[i].description!;
              String description3 = list[i].description!;

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Hero(
                  tag: 'hero-tag-$id',
                  child: Material(
                    child: Container(
                      width: 275.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          color: Colors.grey[500],
                          image: (imageUrl == "" || imageUrl == "null")
                              ? DecorationImage(
                              image:  AssetImage('./assets/logo/noimage.webp'))
                          :DecorationImage(
                              image: NetworkImage(imageUrl), fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12.withOpacity(0.01),
                                spreadRadius: 0.2,
                                blurRadius: 0.5)
                          ]),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          gradient: LinearGradient(
                            begin: FractionalOffset.bottomCenter,
                            end: FractionalOffset.topCenter,
                            colors: [
                              const Color(0xFF000000),
                              const Color(0x00000000),
                            ],
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EvenDetailsLiveActivity(
                                      list[i],
                                      analytics: analytics,
                                      observer: observer,
                                    )));*/
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => EvenDetailsActivity(list[i],
                              analytics: analytics,
                              observer: observer,
                            )));
                            /*Navigator.of(context).push(
                              PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new newsHeaderListDetail(
                                        category: category,
                                        desc: description,
                                        price: price,
                                        imageUrl: imageUrl,
                                        index: list[i].reference,
                                        time: hours,
                                        date: date,
                                        place: location,
                                        title: title,
                                        id: id,
                                        userId: dataUser,
                                        desc2: description2,
                                        desc3: description3,
                                      ),
                                  transitionDuration:
                                      Duration(milliseconds: 600),
                                  transitionsBuilder: (_,
                                      Animation<double> animation,
                                      __,
                                      Widget child) {
                                    return Opacity(
                                      opacity: animation.value,
                                      child: child,
                                    );
                                  }),
                            );*/
                          },
                          child: Stack(
                            children: <Widget>[
                              // image,
                              imageOverlayGradient,

                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          date,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2.0,
                                            fontSize: 14.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: Text(
                                            title,
                                            style: textTheme.bodyMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
