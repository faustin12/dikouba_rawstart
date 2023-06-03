import 'dart:async';

import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/event/eventdetails_activity.dart';
import 'package:dikouba/library/Page_Transformer_Card/page_transformer.dart';
import 'package:dikouba/main.dart';
import 'package:dikouba/model/evenement_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;


class EventMapScreen extends StatefulWidget {
  EventMapScreen({this.analytics, this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventMapScreenState createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  static final String TAG = '_EventMapScreenState';
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  int selectedCategory = 0;

  bool _isEventFinding = false;
  bool _showSearchBar = false;
  bool _showAddressSearchBar = false;
  List<double> listDistances = [1, 10, 100, 1000];
  double _lowerValue = 0.0;
  double _upperValue = 300.0;
  double _lowerValueFormatter = 20.0;
  double _upperValueFormatter = 20.0;
  double _selectedradius = 300000;
  List<EvenementModel> _listEvents = new List();
  List<EvenementModel> _listEventsStatic = new List();

  Completer<GoogleMapController> _controller = Completer();
  TextEditingController searchController = new TextEditingController();
  TextEditingController searchAddressController = new TextEditingController();

  static LatLng _currentPosition;
  static LatLng _pickedPosition;

  dynamic _pickSuggestion;

  CameraPosition _kGooglePlex;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventMapScreen",
      screenClassOverride: "EventMapScreen",
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
    super.initState();
    _setCurrentScreen();
    _kGooglePlex = CameraPosition(
      target: LatLng(4.061536, 9.786072),
      zoom: 16,
    );
    _getUserLocation();

    //findEventsAll();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            navigatorKey: MyApp.MapNavigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    SizedBox(
                      height: MySize.screenHeight,
                      width: MySize.screenWidth,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: true,
                        compassEnabled: true,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        initialCameraPosition: _kGooglePlex,
                        markers: Set<Marker>.of(_markers.values),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
                    ),
                    Positioned(
                        top: MySize.size12,
                        left: MySize.size8,
                        right: MySize.size8,
                        bottom: MySize.size16,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child: Material(
                                    color: DikoubaColors.blue['pri'],borderRadius: BorderRadius.circular(6),
                                    child: InkWell(
                                      splashColor: DikoubaColors.blue['lig'], // inkwell color
                                      child: SizedBox(width: MySize.size48, height: MySize.size48,
                                          child: _showAddressSearchBar
                                              ? Icon(MdiIcons.chevronLeft, size: MySize.size24,)
                                              : Icon(MdiIcons.magnify, size: MySize.size24,)),
                                      onTap: () async {
                                        setState(() {
                                          _showAddressSearchBar = !_showAddressSearchBar;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: MySize.size6,),
                                Expanded(
                                    child: !_showAddressSearchBar
                                        ? Container()
                                        : Container(
                                      width: MySize.screenWidth,
                                      padding: Spacing.vertical(4),
                                      decoration: BoxDecoration(
                                          color: customAppTheme.bgLayer1,
                                          border: Border.all(
                                              color: customAppTheme.bgLayer3, width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(MySize.size8))),
                                      child: Row(
                                        children: [
                                          // Container(
                                          //   margin: Spacing.left(12),
                                          //   child: Icon(
                                          //     MdiIcons.magnify,
                                          //     color: themeData.colorScheme.onBackground
                                          //         .withAlpha(200),
                                          //     size: MySize.size24,
                                          //   ),
                                          // ),
                                          Expanded(
                                            child: Container(
                                              margin: Spacing.left(12),
                                              child: TypeAheadField(
                                                noItemsFoundBuilder: (buildContext) {
                                                  return Container(
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    padding: EdgeInsets.symmetric(vertical: MySize.size12),
                                                    alignment: Alignment.center,
                                                    child: Text("Aucun lieu trouvé",
                                                      style: AppTheme.getTextStyle(
                                                          themeData.textTheme.bodyText2,
                                                          fontSize: MySize.size18,
                                                          color: themeData
                                                              .colorScheme.onBackground,
                                                          fontWeight: 500),),
                                                  );
                                                },
                                                loadingBuilder: (buildContext) {
                                                  return Container(
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    padding: EdgeInsets.symmetric(vertical: MySize.size12),
                                                    alignment: Alignment.center,
                                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),),);
                                                },
                                                textFieldConfiguration: TextFieldConfiguration(
                                                    autofocus: true,
                                                    style: AppTheme.getTextStyle(
                                                        themeData.textTheme.bodyText2,
                                                        fontSize: MySize.size18,
                                                        color: themeData
                                                            .colorScheme.onBackground,
                                                        fontWeight: 500),
                                                    textCapitalization: TextCapitalization.sentences,
                                                    decoration: InputDecoration(
                                                      fillColor: customAppTheme.bgLayer1,
                                                      hintStyle: AppTheme.getTextStyle(
                                                          themeData.textTheme.bodyText2,
                                                          fontSize: MySize.size18,
                                                          color: themeData
                                                              .colorScheme.onBackground,
                                                          muted: true,
                                                          fontWeight: 500),
                                                      hintText: "Rechercher un lieu...",
                                                      border: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      isDense: true,
                                                    )
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  print("suggestionsCallback pattern=$pattern");
                                                  var response = await googleSearchByAddress(pattern.toString());
                                                  print("suggestionsCallback response=$response");
                                                  return response;
                                                },
                                                itemBuilder: (context, suggestion) {
                                                  return Container(
                                                    padding: EdgeInsets.symmetric(vertical: MySize.size12),
                                                    color: Colors.white,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: MySize.size8,),
                                                        Icon(Icons.location_pin, size: MySize.size24,color: Colors.black54,),
                                                        SizedBox(width: MySize.size8,),
                                                        Expanded(child: Text(suggestion['description'],
                                                          style: AppTheme.getTextStyle(
                                                              themeData.textTheme.bodyText2,
                                                              fontSize: MySize.size18,
                                                              color: themeData
                                                                  .colorScheme.onBackground,
                                                              fontWeight: 500),))
                                                      ],
                                                    ),
                                                  );
                                                },
                                                onSuggestionSelected: (suggestion) {
                                                  print("onSuggestionSelected suggestion=$suggestion");
                                                  _pickSuggestion = suggestion;
                                                  findEventsNearPosition(context);
                                                },
                                              ),
                                            ),
                                          ),
                                          /*
                                          TextFormField(
                                                controller: searchAddressController,
                                                style: AppTheme.getTextStyle(
                                                    themeData.textTheme.bodyText2,
                                                    fontSize: MySize.size18,
                                                    color: themeData
                                                        .colorScheme.onBackground,
                                                    fontWeight: 500),
                                                decoration: InputDecoration(
                                                  fillColor: customAppTheme.bgLayer1,
                                                  hintStyle: AppTheme.getTextStyle(
                                                      themeData.textTheme.bodyText2,
                                                      fontSize: MySize.size18,
                                                      color: themeData
                                                          .colorScheme.onBackground,
                                                      muted: true,
                                                      fontWeight: 500),
                                                  hintText: "Rechercher un lieu...",
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  isDense: true,
                                                ),
                                                onChanged: (newInputStr) {
                                                  print("searchController $newInputStr");
                                                },
                                                onEditingComplete: () {
                                                  print("onEditingComplete ${searchController.text}");
                                                  FocusScope.of(context).unfocus();
                                                  searchEvent();
                                                },
                                                textCapitalization:
                                                TextCapitalization.sentences,
                                              )
                                           */
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            SizedBox(height: MySize.size6,),
                            /*Row(
                              children: [
                                ClipOval(
                                  child: Material(
                                    color: DikoubaColors.blue['pri'],borderRadius: BorderRadius.circular(6),
                                    child: InkWell(
                                      splashColor: DikoubaColors.blue['lig'], // inkwell color
                                      child: SizedBox(width: MySize.size48, height: MySize.size48,
                                          child: _showSearchBar
                                              ? Icon(MdiIcons.chevronLeft, size: MySize.size24,)
                                              : Icon(MdiIcons.magnify, size: MySize.size24,)),
                                      onTap: () async {
                                        setState(() {
                                          _showSearchBar = !_showSearchBar;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: MySize.size6,),
                                /*Expanded(
                                    child: !_showSearchBar
                                        ? Container()
                                        : Container(
                                      width: MySize.screenWidth,
                                      padding: Spacing.vertical(4),
                                      decoration: BoxDecoration(
                                          color: customAppTheme.bgLayer1,
                                          border: Border.all(
                                              color: customAppTheme.bgLayer3, width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(MySize.size8))),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: Spacing.left(12),
                                            child: Icon(
                                              MdiIcons.magnify,
                                              color: themeData.colorScheme.onBackground
                                                  .withAlpha(200),
                                              size: MySize.size24,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: Spacing.left(12),
                                              child: TextFormField(
                                                controller: searchController,
                                                style: AppTheme.getTextStyle(
                                                    themeData.textTheme.bodyText2,
                                                    fontSize: MySize.size18,
                                                    color: themeData
                                                        .colorScheme.onBackground,
                                                    fontWeight: 500),
                                                decoration: InputDecoration(
                                                  fillColor: customAppTheme.bgLayer1,
                                                  hintStyle: AppTheme.getTextStyle(
                                                      themeData.textTheme.bodyText2,
                                                      fontSize: MySize.size18,
                                                      color: themeData
                                                          .colorScheme.onBackground,
                                                      muted: true,
                                                      fontWeight: 500),
                                                  hintText: "Rechercher un énement...",
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  isDense: true,
                                                ),
                                                onChanged: (newInputStr) {
                                                  print("searchController $newInputStr");
                                                },
                                                onEditingComplete: () {
                                                  print("onEditingComplete ${searchController.text}");
                                                  FocusScope.of(context).unfocus();
                                                  searchEvent();
                                                },
                                                textCapitalization:
                                                TextCapitalization.sentences,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),*/
                              ],
                            ),*/
                            SizedBox(height: MySize.size6,),
                            /*SizedBox(height: MySize.size6,),
                            ClipOval(
                              child: Material(
                                color: DikoubaColors.blue['pri'],borderRadius: BorderRadius.circular(6),
                                child: InkWell(
                                  splashColor: DikoubaColors.blue['lig'], // inkwell color
                                  child: SizedBox(width: MySize.size42, height: MySize.size42,
                                      child: Icon(MdiIcons.mapMarkerCheck, size: MySize.size24,)),
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlacePicker(
                                          apiKey: DikoubaUtils.MapApiKey,   // Put YOUR OWN KEY here.
                                          onPlacePicked: (result) {
                                            print("$TAG:PlacePicker ${result.geometry.location.lat} ! ${result.geometry.location.lng}");
                                            _pickSuggestion = result;
                                            Navigator.of(context).pop();
                                            findEventsNearPosition(context);
                                          },
                                          // initialPosition: HomePage.kInitialPosition,
                                          useCurrentLocation: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),*/
                            SizedBox(height: MySize.size6,),
                            /*ClipOval(
                              child: Material(
                                color: Colors.black, // button color
                                child: InkWell(
                                  splashColor: Colors.black12, // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(Icons.edit_road, size: MySize.size28)),
                                  onTap: () {
                                    //setDistance(context);
                                  },
                                ),
                              ),
                            ),*/
                            frs.RangeSlider(
                              min: 0.0,
                              max: 600.0,
                              lowerValue: _lowerValue,
                              upperValue: _upperValue,
                              divisions: 60,
                              showValueIndicator: true,
                              //valueIndicatorMaxDecimals: 1,
                              valueIndicatorFormatter: (int index, double value) {
                                String twoDecimals = value.toStringAsFixed(0);
                                return '$twoDecimals km';
                              },
                              onChanged: (double newLowerValue, double newUpperValue) {
                                setState(() {
                                  _lowerValue = newLowerValue;
                                  _upperValue = newUpperValue;
                                });
                              },
                              onChangeStart:
                                  (double startLowerValue, double startUpperValue) {
                                print(
                                    'Started with values: $startLowerValue and $startUpperValue');
                              },
                              onChangeEnd: (double newLowerValue, double newUpperValue) {
                                print(
                                    'Ended with values: $newLowerValue and $newUpperValue');
                                setState(() {
                                  _selectedradius = newUpperValue*1000;
                                });
                                if(_pickedPosition != null) {
                                  findEventsNearPositionLatLong(_pickedPosition.latitude, _pickedPosition.longitude);}
                              },
                            ),
                          ],
                        )),
                    Positioned(
                        top: MySize.size12,
                        right: MySize.size8,
                        bottom: MySize.size16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Material(
                                color: Colors.purple,borderRadius: BorderRadius.circular(6),
                                child: InkWell(
                                  splashColor: Colors.purple.shade100, // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(Icons.my_location, size: MySize.size24,)),
                                  onTap: () async {
                                    if(_currentPosition != null) {
                                      _pickedPosition = _currentPosition;
                                      moveToEventPosition(_currentPosition.latitude, _currentPosition.longitude, DikoubaUtils.CODE_CURR_POSITION);
                                      findEventsNearPositionLatLong(_currentPosition.latitude, _currentPosition.longitude);}
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: MySize.size6,),
                            ClipOval(
                              child: Material(
                                color: Colors.purple,borderRadius: BorderRadius.circular(6),
                                child: InkWell(
                                  splashColor: Colors.purple.shade100, // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(MdiIcons.plus, size: MySize.size24,)),
                                  onTap: () async {
                                    GoogleMapController googleMapController = await _controller.future;
                                    googleMapController.animateCamera(CameraUpdate.zoomIn());
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: MySize.size6,),
                            ClipOval(
                              child: Material(
                                color: Colors.purple, // button color
                                child: InkWell(
                                  splashColor: Colors.purple.shade100,  // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(Icons.remove, size: MySize.size24)),
                                  onTap: () async {
                                    GoogleMapController googleMapController = await _controller.future;
                                    googleMapController.animateCamera(CameraUpdate.zoomOut());
                                  },
                                ),
                              ),
                            )
                          ],
                        )),
                    Positioned(
                        top: MySize.screenHeight-220,
                        bottom: MySize.size8,
                        left: 0,
                        // right: MySize.size68,
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.bottomCenter,
                          height: MySize.size120,
                          width: MySize.screenWidth,
                          child: _isEventFinding
                              ? PageTransformer(
                            pageViewBuilder: (context, visibilityResolver) {
                              return PageView.builder(
                                controller: PageController(viewportFraction: 0.87),
                                itemCount: 5,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return cardHeaderLoading(context);
                                },
                              );
                            },)
                              : (_listEvents == null || _listEvents.length == 0)
                              ? Container(
                            margin: Spacing.fromLTRB(24, 16, 24, 0),
                            padding: Spacing.symmetric(horizontal: MySize.size8, vertical: MySize.size6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                            ),
                            child: Text("Aucun évènement trouvé",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  fontSize: 12,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500,
                                  xMuted: true),),)
                              : ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: Spacing.zero,
                            itemCount: _listEvents.length,
                            itemBuilder: (BuildContext buildcontext, int indexCateg){
                              EvenementModel item = _listEvents[indexCateg];

                              DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(int.parse(item.start_date.seconds) * 1000);

                              return singleEvent(item,
                                  image: '${item.banner_path}',
                                  time: "${DateFormat('HH:mm').format(_startDate)}",
                                  date: "${DateFormat('dd MMM yyyy').format(_startDate)}",
                                  name: "${item.title}");
                            },
                          ),
                        )),
                  ],
                )));
      },
    );
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      print('${_currentPosition}');
      _pickedPosition = _currentPosition;
      moveToEventPosition(_currentPosition.latitude, _currentPosition.longitude, DikoubaUtils.CODE_CURR_POSITION);
      findEventsNearPositionLatLong(position.latitude, position.longitude);
    });
  }

  void _addMarker(EvenementModel evenementModel) {
    DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(int.parse(evenementModel.start_date.seconds) * 1000);
    var markerIdVal = evenementModel.id_evenements;
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        double.parse(evenementModel.location.latitude),
          double.parse(evenementModel.location.longitude)
      ),
      infoWindow: InfoWindow(title: evenementModel.title, snippet: '${DateFormat('dd MMM, HH:mm').format(_startDate)}'),
      onTap: () {
        print("$TAG:_onMarkerTapped ${evenementModel.title}");
        // _onMarkerTapped(markerId);
      },
    );

    setState(() {
      // adding a new marker to map
      _markers[markerId] = marker;
    });
  }
  void _addMarkerAddress(dynamic addresPicked) {
    final MarkerId markerId = MarkerId(addresPicked['place_id']);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(
          addresPicked['geometry']['location']['lat'],
          addresPicked['geometry']['location']['lng']
      ),
      infoWindow: InfoWindow(title: addresPicked['formatted_address'], snippet: 'Résultat recherche'),
    );

    setState(() {
      // adding a new marker to map
      _markers[markerId] = marker;
    });
  }

  void _addMarkerCurrPosition() {
    final MarkerId markerId = MarkerId(DikoubaUtils.CODE_CURR_POSITION);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: LatLng(
          _currentPosition.latitude,
          _currentPosition.longitude
      ),
      infoWindow: InfoWindow(title: "Ma position actuelle"),
    );

    setState(() {
      // adding a new marker to map
      _markers[markerId] = marker;
    });
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
          baseColor: Colors.grey[400],
          highlightColor: Colors.white,
          child: Container(
            margin: Spacing.symmetric(horizontal: MySize.size8),
            padding: Spacing.symmetric(horizontal: MySize.size8, vertical: MySize.size6),
            width: MySize.screenWidth*0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                  child: Container(
                    width: MySize.getScaledSizeHeight(80),
                    color: Colors.white,
                    height: MySize.size72,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: MySize.size14,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        ),
                        SizedBox(height: MySize.size12,),
                        Container(
                          width: double.infinity,
                          height: MySize.size12,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void moveToEventPosition(double lat, double lng, String markerId) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            lat,
            lng
        ),
        zoom: 17.0)));
    googleMapController.showMarkerInfoWindow(MarkerId(markerId));
  }

  Widget singleEvent(EvenementModel evenementModel, {String image, String name, String date, String time}) {
    return Container(
      margin: Spacing.symmetric(horizontal: MySize.size8),
      padding: Spacing.symmetric(horizontal: MySize.size8, vertical: MySize.size6),
      width: MySize.screenWidth*0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
      ),
      child: InkWell(
        onTap: () {
          moveToEventPosition(double.parse(evenementModel.location.latitude), double.parse(evenementModel.location.longitude), evenementModel.id_evenements);
        },
        onDoubleTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => EvenDetailsActivity(evenementModel,
            analytics: widget.analytics,
            observer: widget.observer,
          )));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle2,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 600),
                    ),
                    Container(
                      margin: Spacing.top(8),
                      child: Text(
                        "$date, $time",
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color:
                            themeData.colorScheme.onBackground),
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

  void setDistance(BuildContext buildContext) async {
    var resDistance = await showDialog(
        context: buildContext,
        builder: (BuildContext buildContext2) {
          return AlertDialog(
            title: Text('Choisir la distance',
                style: AppTheme.getTextStyle(
                    themeData.textTheme.subtitle2,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 300)),
            content: Container(// Change as per your requirement
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listDistances.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(buildContext2).pop("${listDistances[index]}");
                    },
                    leading: _selectedradius == listDistances[index]
                    ? Icon(MdiIcons.circle, color: DikoubaColors.blue['pri'],)
                    : Icon(MdiIcons.circleOutline, color: DikoubaColors.blue['pri'],),
                    title: Text('${listDistances[index]} km',
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.subtitle2,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 600)),
                  );
                },
              ),
            ),
          );
        });
    print("setDistance: $resDistance");
    if(resDistance != null) {
      setState(() {
        _selectedradius = double.parse(resDistance);
      });
    }
  }

  void searchEvent() {
    setState(() {
      _isEventFinding = true;
    });
    String searchStr = searchController.text;
    List<EvenementModel> list = new List();
    for(int i=0; i < _listEventsStatic.length; i++) {
      if(_listEventsStatic[i].title.contains(searchStr)) list.add(_listEventsStatic[i]);
    }

    setState(() {
      _isEventFinding = false;
      _listEvents = list;
    });
  }

  void findEventsAll() async {
    setState(() {
      _isEventFinding = true;
    });
    API.findAllEvents().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:requestCustomerAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementModel> list = new List();
        _markers.clear();
        for (int i = 0; i < responseEvents.data.length; i++) {
          EvenementModel evenementModel = EvenementModel.fromJson(responseEvents.data[i]);
          list.add(evenementModel);
          _addMarker(evenementModel);
        }
        _addMarkerCurrPosition();
        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
          _listEvents = list;
          _listEventsStatic = list;
          // if(list.length > 0) moveToEventPosition(double.parse(list[0].location.latitude), double.parse(list[0].location.longitude), list[0].id_evenements);
          if(_currentPosition != null) {
            moveToEventPosition(_currentPosition.latitude, _currentPosition.longitude, DikoubaUtils.CODE_CURR_POSITION);
          } else{
            moveToEventPosition(double.parse(list[0].location.latitude), double.parse(list[0].location.longitude), list[0].id_evenements);
          }
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isEventFinding = false;
      });
    });
  }

  void findEventsNearPosition(BuildContext buildContext) async {
    setState(() {
      _isEventFinding = true;
    });

    var responsePicked = await API.googleAddressInfo(_pickSuggestion['place_id']);
    if (responsePicked.statusCode == 200) {
      print(
          "${TAG}:googleSearchByAddress ${responsePicked.statusCode}|${responsePicked.data}");
      var pickedData = responsePicked.data['result'];

      if (!mounted) return null;

      print("${TAG}:googleSearchPickedData ${pickedData}|${pickedData['geometry']['location']['lat']}|${pickedData['geometry']['location']['lng']}|${_selectedradius}");

      API.findEventsNearPosition(pickedData['geometry']['location']['lat'], pickedData['geometry']['location']['lng'], _selectedradius+100000*0).then((responseEvents) {
        if (responseEvents.statusCode == 200) {
          print(
              "${TAG}:findEventsNearPosition ${responseEvents.statusCode}|${responseEvents.data}");
          List<EvenementModel> list = new List();
          _markers.clear();
          for (int i = 0; i < responseEvents.data.length; i++) {
            EvenementModel evenementModel = EvenementModel.fromJson(responseEvents.data[i]);
            list.add(evenementModel);
            _addMarker(evenementModel);
          }
          _addMarkerAddress(pickedData);
          _addMarkerCurrPosition();
          if (!mounted) return;
          setState(() {
            _isEventFinding = false;
            _listEvents = list;
            _listEventsStatic = list;
            _pickedPosition = LatLng(pickedData['geometry']['location']['lat'], pickedData['geometry']['location']['lng']);
            moveToEventPosition(pickedData['geometry']['location']['lat'], pickedData['geometry']['location']['lng'], pickedData['place_id']);
            // if(list.length > 0) moveToEventPosition(list[0]);
          });
          return;
        } else {
          print("${TAG}:findOperations no data ${responseEvents.toString()}");

          if (!mounted) return;
          setState(() {
            _isEventFinding = false;
          });
          return;
        }
      }).catchError((errWalletAddr) {
        print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
        return;
      });
    } else {
      print(
          "${TAG}:googleSearchByAddress ${responsePicked.statusCode}|${responsePicked.data}");

      DikoubaUtils.toast_error(buildContext, "Impossible de recupérer les informations du lieu");
      setState(() {
        _isEventFinding = true;
      });
    }

  }

  void findEventsNearPositionLatLong(double lat, long) async {
    setState(() {
      _isEventFinding = true;
    });

    print("${TAG}:findEventsNearPositionLatLong ${lat}|${long}|${_selectedradius}");

    API.findEventsNearPosition(lat, long, _selectedradius).then((responseEvents) {
        if (responseEvents.statusCode == 200) {
          print(
              "${TAG}:findEventsNearPosition ${responseEvents.statusCode}|${responseEvents.data}");
          List<EvenementModel> list = new List();
          _markers.clear();
          for (int i = 0; i < responseEvents.data.length; i++) {
            EvenementModel evenementModel = EvenementModel.fromJson(responseEvents.data[i]);
            list.add(evenementModel);
            _addMarker(evenementModel);
          }
          if (!mounted) return;
          setState(() {
            _isEventFinding = false;
            _listEvents = list;
            _listEventsStatic = list;
            //moveToEventPosition(double.parse(list[0].location.latitude), double.parse(list[0].location.longitude), list[0].id_evenements);
            // if(list.length > 0) moveToEventPosition(list[0]);
          });
          return;
        } else {
          print("${TAG}:findOperations no data ${responseEvents.toString()}");

          if (!mounted) return;
          setState(() {
            _isEventFinding = false;
          });
          return;
        }
      }).catchError((errWalletAddr) {
        print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
        return;
      });

  }

  Future<List<dynamic>> googleSearchByAddress(String searchAddress) async {
    var responseSearchAdr = await API.googleSearchAddress(searchAddress);
    if (responseSearchAdr.statusCode == 200) {
      print(
          "${TAG}:googleSearchByAddress ${responseSearchAdr.statusCode}|${responseSearchAdr.data['predictions']}");
      List<dynamic> list = new List();

      for (int i = 0; i < responseSearchAdr.data['predictions'].length; i++) {
        list.add(responseSearchAdr.data['predictions'][i]);
      }

      if (!mounted) return null;
      return list;
    }
    return null;
    /*API.googleSearchAddress(searchAddress).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:googleSearchByAddress ${responseEvents.statusCode}|${responseEvents.data}");
        List<dynamic> list = new List();
        _markers.clear();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(responseEvents.data[i]);
        }

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
          _listEvents = list;
          _listEventsStatic = list;
          if(list.length > 0) moveToEventPosition(list[0]);
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isEventFinding = false;
      });
    });*/
  }


}
