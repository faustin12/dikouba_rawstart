import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/model/category_model.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/firebaselocation_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/firestorage_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
//import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EventCreateSession extends StatefulWidget {
  EvenementModel evenementModel;
  UserModel userModel;
  EventCreateSession(this.userModel, this.evenementModel,{required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventCreateSessionState createState() => _EventCreateSessionState();
}

class _EventCreateSessionState extends State<EventCreateSession> {
  static final String TAG = '_EventCreateSessionState';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late GlobalKey<FormState> _formEventKey;

  late TextEditingController libelleCtrler;
  late TextEditingController descriptionCtrler;

  final picker = ImagePicker();

  bool _isCategoryFinding = false;
  bool _isEventCreating = false;
  late List<CategoryModel> _listCategory;
  List<PackageModel> _listPackages = [];
  late CategoryModel _selectedCategoryModel;
  late FirebaseLocationModel _selectedLocation;
  late DateTime _startDate;
  late DateTime _endDate;
  late PickedFile _eventbanner;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventCreateSession",
      screenClassOverride: "EventCreateSession",
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

  void onPop(value) {
    setState(() {
      _selectedLocation = value;
    });
    //DikoubaUtils.toast_infos(context, "Pop");
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
    _formEventKey = GlobalKey<FormState>();
    libelleCtrler = new TextEditingController();
    descriptionCtrler = new TextEditingController();

    findAllCategories();
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
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      MdiIcons.chevronLeft,
                      size: MySize.size36,
                      color: Colors.white,
                    ),),
                  backgroundColor: DikoubaColors.blue['pri'],
                  title: Text("Ajouter session",
                      style: themeData.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                body: Container(
                    color: customAppTheme.bgLayer2,
                    child: Column(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formEventKey,
                              child: ListView(
                                padding: Spacing.vertical(16),
                                children: [
                                  Container(
                                    margin: Spacing.fromLTRB(24, 24, 24, 0),
                                    child: Text(
                                      "Nouvelle session pour ${widget.evenementModel.title}",
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData
                                              .colorScheme.onBackground,
                                          fontWeight: 600),
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 8, 24, 0),
                                    child: TextFormField(
                                      controller: libelleCtrler,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Veuillez saisir le titre';
                                        }
                                        return null;
                                      },
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.headline5,
                                          color: themeData.colorScheme.onBackground,
                                          letterSpacing: -0.4,
                                          fontWeight: 800),
                                      decoration: InputDecoration(
                                        fillColor: themeData.colorScheme.background,
                                        hintStyle: AppTheme.getTextStyle(
                                            themeData.textTheme.headline5,
                                            color:
                                            themeData.colorScheme.onBackground,
                                            letterSpacing: -0.4,
                                            fontWeight: 800),
                                        filled: false,
                                        hintText: "Titre de l'évènement",
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      autocorrect: false,
                                      autovalidate: false,
                                      textCapitalization:
                                      TextCapitalization.sentences,
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 0, 24, 0),
                                    child: TextFormField(
                                      controller: descriptionCtrler,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Veuillez saisir la desription';
                                        }
                                        return null;
                                      },
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: 500,
                                          letterSpacing: 0,
                                          muted: true),
                                      decoration: InputDecoration(
                                        hintText: "Description",
                                        hintStyle: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText2,
                                            color:
                                            themeData.colorScheme.onBackground,
                                            fontWeight: 600,
                                            letterSpacing: 0,
                                            xMuted: true),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(50)),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.4,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(50)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(50)),
                                        ),
                                      ),
                                      maxLines: 3,
                                      minLines: 1,
                                      autofocus: false,
                                      textCapitalization:
                                      TextCapitalization.sentences,
                                    ),
                                  ),
                                  selectCategoryWidget(),
                                  selectLocationWidget(),
                                  selectDateRangeWidget(),
                                  packagesAddWidget(),
                                  eventBannerWidget(),
                                ],
                              )),
                        ),
                        Container(
                          color: customAppTheme.bgLayer1,
                          padding: Spacing.fromLTRB(24, 16, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isEventCreating
                              ? Container(
                                width: MySize.size32,
                                height: MySize.size32,
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),),)
                              : InkWell(
                                onTap: () {
                                  checkEventForm(context);
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
                                          " Créer la session ".toUpperCase(),
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
                                          MdiIcons.chevronRight,
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

  void setSelectedCategory() async {

    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            _SelectCategoryDialog()));
    print("updateSelectedLocation: ${resAddPackage}");

    if(resAddPackage != null) {
      CategoryModel itemCateg = CategoryModel.fromJson(json.decode(resAddPackage));
      updateSelectedCategory(itemCateg);
    }
  }
  Widget selectCategoryWidget() {
    return InkWell(
      onTap: () {
        setSelectedCategory();
      },
      child: Container(
        margin: Spacing.fromLTRB(24, 24, 24, 0),
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            border: Border.all(color: customAppTheme.bgLayer3, width: 1),

            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categorie",
                      style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground),
                    ),
                    Container(
                      margin: Spacing.top(2),
                      child: Text(
                        _selectedCategoryModel == null ? "Aucune catégorie selectionnée" : "${_selectedCategoryModel.title}",
                        style: AppTheme.getTextStyle(themeData.textTheme.caption,
                            fontSize: 12,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground,
                            xMuted: true),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: IconButton(icon: Icon(
                MdiIcons.chevronDown,
                color: DikoubaColors.blue['pri'],
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget selectLocationWidget() {
    return InkWell(
      onTap: () {
        updateSelectedLocation2();
      },
      child: Container(
        margin: Spacing.fromLTRB(24, 24, 24, 0),
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            border: Border.all(color: customAppTheme.bgLayer3, width: 1),

            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lieu",
                      style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground),
                    ),
                    Container(
                      margin: Spacing.top(2),
                      child: Text(
                        _selectedLocation == null ? "Aucun lieu selectionné" : "${_selectedLocation.address}",
                        style: AppTheme.getTextStyle(themeData.textTheme.caption,
                            fontSize: 12,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground,
                            xMuted: true),
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(icon: Icon(
              MdiIcons.mapMarker,
              color: DikoubaColors.blue['pri'],
            )),
          ],
        ),
      ),
    );
  }

  Widget selectDateRangeWidget() {
    return InkWell(
      onTap: (){
        updateSelectedDateRange();
      },
      child: Container(
        margin: Spacing.fromLTRB(24, 24, 24, 0),
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            border: Border.all(color: customAppTheme.bgLayer3, width: 1),

            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date",
                      style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground),
                    ),
                    Container(
                      margin: Spacing.top(2),
                      child: Text(
                        _startDate == null
                            ? "Aucune date selectionnée"
                            : "Du ${DateFormat('dd MMM yyyy HH:mm').format(_startDate)}\nAu ${DateFormat('dd MMM yyyy HH:mm').format(_endDate)}",
                        style: AppTheme.getTextStyle(themeData.textTheme.caption,
                            fontSize: 12,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground,
                            xMuted: true),
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(icon: Icon(
              MdiIcons.timer,
              color: DikoubaColors.blue['pri'],
            )),
          ],
        ),
      ),
    );
  }

  Widget packagesAddWidget() {
    return Container(
      margin: Spacing.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer3, width: 1),

          borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: Spacing.left(16),
              child: Row(
                children: [
                  Expanded(child: Text(
                    "Packages",
                    style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                        fontWeight: 600,
                        color: themeData.colorScheme.onBackground),
                  )),
                  IconButton(icon: Icon(
                    MdiIcons.plusCircle,
                    color: DikoubaColors.blue['pri'],
                  ), onPressed: () {
                    addEventPackage();
                  })
                ],
              ),
            ),
            (_listPackages == null || _listPackages.length == 0)
                ? Container(
              margin: Spacing.symmetric(vertical: 2, horizontal: 16),
              child: Text("Aucun package ajoutée",
                style: AppTheme.getTextStyle(themeData.textTheme.caption,
                    fontSize: 12,
                    fontWeight: 600,
                    color: themeData.colorScheme.onBackground,
                    xMuted: true),
              ),)
                : Container(
              margin: Spacing.vertical(4),
              height: MySize.size76,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: _listPackages.length,
                itemBuilder: (BuildContext buildcontext, int indexPack){
                  PackageModel item = _listPackages[indexPack];

                  return Container(
                    margin: Spacing.horizontal(8),
                    padding: EdgeInsets.symmetric(horizontal: MySize.size6, vertical: MySize.size6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: customAppTheme.bgLayer2
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text("${item.name}",
                            textAlign: TextAlign.left,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontSize: 14,
                                letterSpacing: 0.7,
                                color:
                                themeData.colorScheme.primary,))),
                        Text("${item.price} ${DikoubaUtils.CURRENCY}",
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontSize: 14,
                                letterSpacing: 0.7,
                                color: Colors.redAccent,
                                fontWeight: 600))
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      )
    );
  }

  Widget eventBannerWidget() {
    return Container(
      margin: Spacing.fromLTRB(24, 24, 24, 0),
        height: MySize.screenWidth*0.7,
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer3, width: 1),

          borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
      child: Container(
        height: MySize.size80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: Spacing.left(16),
              child: Row(
                children: [
                  Expanded(child: Text(
                    "Bannière",
                    style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                        fontWeight: 600,
                        color: themeData.colorScheme.onBackground),
                  )),
                  IconButton(icon: Icon(
                    MdiIcons.fileEdit,
                    color: themeData.colorScheme.onBackground,
                  ), onPressed: () {
                    _showBottomSheetPickImage(context);
                  })
                ],
              ),
            ),
            Expanded(
                child: (_eventbanner == null)
                ? Container(
              margin: Spacing.symmetric(vertical: 2, horizontal: 16),
              alignment: Alignment.center,
              child: Text("Aucune image selectionnée",
                style: AppTheme.getTextStyle(themeData.textTheme.caption,
                    fontSize: 12,
                    fontWeight: 600,
                    color: themeData.colorScheme.onBackground,
                    xMuted: true),
              ),)
                : Container(
              margin: Spacing.top(4),
              width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(new File(_eventbanner.path)),fit: BoxFit.fill
                    ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(MySize.size8), bottomRight: Radius.circular(MySize.size8))),
            ))
          ],
        ),
      )
    );
  }

  void _showBottomSheetPickImage(BuildContext buildContext) async {
    var resultAction = await showModalBottomSheet(
        context: buildContext,
        builder: (BuildContext buildContext) {
          return Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: themeData.backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(MySize.size16),
                      topRight: Radius.circular(MySize.size16))),
              child: Padding(
                padding: EdgeInsets.all(MySize.size16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: MySize.size12, bottom: MySize.size8),
                        child: Text(
                          "Choisir a partir de",
                          style: themeData.textTheme.caption.merge(TextStyle(
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(200),
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w700)),
                        )),
                    ListTile(
                      dense: true,
                      onTap: (){
                        Navigator.of(buildContext).pop('camera');
                      },
                      leading: Icon(MdiIcons.camera,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(220)),
                      title: Text(
                        "Caméra",
                        style: themeData.textTheme.bodyText1.merge(TextStyle(
                            color: themeData.colorScheme.onBackground,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500)),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: (){
                        Navigator.of(buildContext).pop('gallerie');
                      },
                      leading: Icon(MdiIcons.imageAlbum,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(220)),
                      title: Text(
                        "Gallerie",
                        style: themeData.textTheme.bodyText1.merge(TextStyle(
                            color: themeData.colorScheme.onBackground,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    print("$TAG:showBottomSheetPickImage $resultAction");
    if(resultAction == 'camera') {
      PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        _eventbanner = pickedFile;
      });
    } else if(resultAction == 'gallerie') {
      PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _eventbanner = pickedFile;
      });
    }
  }

  void updateSelectedCategory(CategoryModel itemSelected) {
    setState(() {
      _selectedCategoryModel = itemSelected;
    });
  }

  void updateSelectedDateRange() async {

    DateTime today = DateTime.now();
    print('confirm today=$today');
    var startDatetime = await DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        maxTime: today.add(new Duration(days: 3650)),
        minTime: today,
        currentTime: DateTime.now(), locale: LocaleType.fr);
    print('confirm startDatetime=${startDatetime.toString()}');
    if(startDatetime != null) {
      DateTime todayEnd = DateFormat("yyyy-MM-dd HH:mm").parse('${startDatetime.toString()}');
      print('confirm todayEnd=${todayEnd.toString()}');
      var endDatetime = await DatePicker.showDateTimePicker(context,
          showTitleActions: true,
          maxTime: todayEnd.add(new Duration(days: 3650)),
          minTime: todayEnd.add(new Duration(minutes: 15)),
          currentTime: todayEnd.add(new Duration(minutes: 15)), locale: LocaleType.fr);
      print('confirm endDatetime=$endDatetime');
      if(endDatetime != null) {
        setState(() {
          _startDate = startDatetime;
          _endDate = endDatetime;
        });
      }
    }

    /*DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        maxTime: today.add(new Duration(days: 3650)),
        minTime: today,
        onConfirm: (startDatetime) {
          print('confirm startDatetime=$startDatetime');
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              maxTime: today.add(new Duration(days: 3650)),
              minTime: today.add(new Duration(minutes: 15)),
              onConfirm: (endDatetime) {
                print('confirm endDatetime=$endDatetime');
                setState(() {
                  _startDate = startDatetime;
                  _endDate = endDatetime;
                });
              }, currentTime: DateTime.now(), locale: LocaleType.fr);
        }, currentTime: DateTime.now(), locale: LocaleType.fr);*/
  }

  void addEventPackage() async {

    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            _AddEventPackageDialog()));
    print("updateSelectedLocation: ${resAddPackage}");

    if(resAddPackage != null) {
      PackageModel itemPackage = PackageModel.fromJson(json.decode(resAddPackage));
      setState(() {
        _listPackages.add(itemPackage);
      });
    }
  }

  void updateSelectedLocation2() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => _SelectLocation(callback: onPop,)
    ));
  }

  void updateSelectedLocation() async {
    LocationResult locationResult =
        await showLocationPicker(context, DikoubaUtils.MapApiKey,
          myLocationButtonEnabled: true,
          layersButtonEnabled: true,
            appBarColor: DikoubaColors.blue['pri'],language: 'fr',searchBarBoxDecoration: BoxDecoration(
              color: DikoubaColors.blue['lig'],

            ),resultCardDecoration: BoxDecoration(
              color: Colors.white,),
            hintText: 'Rechercher un lieu',
            resultCardConfirmIcon: Icon(MdiIcons.check));
    print("updateSelectedLocation: ${locationResult.address} ${locationResult.latLng.latitude}|${locationResult.latLng.longitude}");
    if(locationResult == null) return;

    FirebaseLocationModel locationModel = new FirebaseLocationModel('${locationResult.latLng.latitude}', '${locationResult.latLng.longitude}');
    locationModel.address = locationResult.address;

    setState(() {
      _selectedLocation = locationModel;
    });
  }

  void checkEventForm(BuildContext buildContext) {
    if(_formEventKey.currentState.validate()) {
      if(_selectedCategoryModel == null) {
        DikoubaUtils.toast_error(buildContext, "Veuillez selectionner la catégorie");
        return;
      }
      if(_selectedLocation == null) {
        DikoubaUtils.toast_error(buildContext, "Veuillez selectionner le lieu");
        return;
      }
      if(_startDate == null || _endDate == null) {
        DikoubaUtils.toast_error(buildContext, "Veuillez selectionner la date de début et de fin");
        return;
      }
      if(_eventbanner == null) {
        DikoubaUtils.toast_error(buildContext, "Veuillez selectionner la bannière");
        return;
      }

      print("$TAG:checkEventForm all is OK");
      saveEvent(buildContext);
    }
  }

  void saveEvent(BuildContext buildContext) async {
    setState(() {
      _isEventCreating = true;
    });
    // Enregistrement de la banniere dans Fire Storage
    var downloadLink = await FireStorageProvider.fireUploadFileToRef(FireStorageProvider.FIRESTORAGE_REF_EVENEMENT, _eventbanner.path, DateFormat('ddMMMyyyyHHmm').format(DateTime.now()));
    print("$TAG:saveEvent downloadLink=$downloadLink");

    EvenementModel evenementModel = new EvenementModel();
    evenementModel.banner_path = downloadLink;
    evenementModel.title = libelleCtrler.text;
    evenementModel.id_categories = _selectedCategoryModel.id_categories;
    evenementModel.id_annoncers = widget.userModel.id_annoncers;
    evenementModel.parent_id = widget.evenementModel.id_evenements;
    evenementModel.description = descriptionCtrler.text;
    evenementModel.longitude = _selectedLocation.longitude;
    evenementModel.latitude = _selectedLocation.latitude;
    evenementModel.start_date_tmp = "${DateFormat('dd MMM yyyy HH:mm').format(_startDate)}";
    evenementModel.end_date_tmp = "${DateFormat('dd MMM yyyy HH:mm').format(_endDate)}";

    API.createEventSession(evenementModel)
        .then((responseEvent) async {
      print("${TAG}:saveEvent:createEvent responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        EvenementModel eventCreated = new EvenementModel.fromJson(responseEvent.data);

        // enregistrement des packages
        for (PackageModel itemPack in _listPackages) {
          itemPack.id_evenements = eventCreated.id_evenements;

          print("Event received: ${itemPack.id_evenements}");
          var resultAddPackage = await API.createEventPackage(itemPack);

          print("Event received: createEventPackage ${resultAddPackage}\n${resultAddPackage.statusCode}");
        }

        setState(() {
          _isEventCreating = false;
        });

        DikoubaUtils.toast_success(
            buildContext, "Evènement crée avec succés");

        Navigator.of(context).pop("${eventCreated.toRYString()}");
        return;
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible de créer l'évènement");
        setState(() {
          _isEventCreating = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isEventCreating = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      print("${TAG}:createAnnoncer catchError ${errorLogin}");
      print("${TAG}:createAnnoncer catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }

  void findAllCategories() async {
    setState(() {
      _isCategoryFinding = true;
    });
    API.findAllCategories().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findAllCategories ${responseEvents.statusCode}|${responseEvents.data}");
        List<CategoryModel> list = new List();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(CategoryModel.fromJson(responseEvents.data[i]));
        }
        setState(() {
          _isCategoryFinding = false;
          _listCategory = list;
        });
      } else {
        print("${TAG}:findAllCategories no data ${responseEvents.toString()}");
        setState(() {
          _isCategoryFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findAllCategories errorinfo ${errWalletAddr}");
      // print("${TAG}:findAllCategories errorinfo ${errWalletAddr.response.data}");
      setState(() {
        _isCategoryFinding = false;
      });
    });
  }
}


class _SelectLocation extends StatefulWidget {
  final Function callback;
  _SelectLocation({this.callback});
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<_SelectLocation> {
  static final String TAG = '_selectLocationState';

  static LatLng _currentPosition;
  FirebaseLocationModel _inSelectedLocation;
  bool _showAddressSearchBar = true;
  double _selectedLat;
  double _selectedLng;
  String _selectedAddress;
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(4.061536, 9.786072),
    zoom: 16,
  );
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController searchAddressController = new TextEditingController();

  void moveToEventPosition(double lat, double lng) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            lat,
            lng
        ),
        zoom: 17.0)));
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      print('${_currentPosition}');
    });
    if(_currentPosition!=null) moveToEventPosition(_currentPosition.latitude, _currentPosition.longitude);
  }

  Future<void> getPickedInfo(dynamic _pickSuggestion) async {
    var responsePicked = await API.googleAddressInfo(_pickSuggestion['place_id']);
    if (responsePicked.statusCode == 200) {
      print(
          "${TAG}:googleSearchByAddress ${responsePicked
              .statusCode}|${responsePicked.data}");
      var pickedData = responsePicked.data['result'];
      setState(() {
        _selectedLat = pickedData['geometry']['location']['lat'];
        _selectedLng = pickedData['geometry']['location']['lng'];
        _selectedAddress = pickedData['formatted_address'].toString();
      });
      //DikoubaUtils.toast_infos(context, " " + _selectedAddress);

      moveToEventPosition(_selectedLat,_selectedLng);
    }
  }

  void validateLocation(double lat, double lng, String name){
    FirebaseLocationModel locationModel = new FirebaseLocationModel('${lat}', '${lng}');
    locationModel.address = name;

    setState(() {
      _inSelectedLocation = locationModel;
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
  }

  ThemeData themeData;
  CustomAppTheme customAppTheme;

  Future<void> getPositionInfo(CameraPosition position) async {
    /*var responsePicked = await API.googleCoordinateInfo(position.target.latitude, position.target.longitude);
    if (responsePicked.statusCode == 200) {
      var pickedData = responsePicked.data['results'];
      DikoubaUtils.toast_infos(context, " " + pickedData.toString());
      setState(() {
        _selectedLat = pickedData['geometry']['location']['lat'];
        _selectedLng = pickedData['geometry']['location']['lng'];
        _selectedAddress = pickedData['formatted_address'].toString();
      });
      DikoubaUtils.toast_infos(context, " " + _selectedAddress);
    }*/
    final coordinates = new Coordinates(position.target.latitude, position.target.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    print("getPositionInfo "+"${first.featureName} : ${first.addressLine}");

    setState(() {
      _selectedLat = position.target.latitude;
      _selectedLng = position.target.longitude;
      _selectedAddress = first.addressLine;
    });
  }

  void onCameraIdle(){
    getPositionInfo(_cameraPosition);
  }
  void onCameraMove(CameraPosition position){
    _cameraPosition = position;
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget child) {
          customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home:
            Scaffold(
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
                        onCameraMove: onCameraMove,
                        onCameraIdle: onCameraIdle,
                        initialCameraPosition: _cameraPosition,
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
                            SizedBox(height: MySize.size6,),
                            SizedBox(height: MySize.size6,),
                            SizedBox(height: MySize.size6,),
                            Row(
                              children: [
                                ClipOval(
                                  child: Material(
                                    color: DikoubaColors.blue['pri'],
                                    borderRadius: BorderRadius.circular(6),
                                    child: InkWell(
                                      splashColor: DikoubaColors.blue['lig'],
                                      // inkwell color
                                      child: SizedBox(width: MySize.size48,
                                          height: MySize.size48,
                                          child: Icon(MdiIcons.check, color: Colors.white,
                                            size: MySize.size24,)),
                                      onTap: () async {
                                        if(_selectedLat!=null){
                                          validateLocation(_selectedLat, _selectedLng, _selectedAddress);
                                        }
                                        widget.callback(_inSelectedLocation);
                                        Navigator.pop(context, {"selectedLocation":_inSelectedLocation});
                                        /*DikoubaUtils.toast_infos(context, "CLick " +_showAddressSearchBar.toString());
                                    setState(() {
                                      _showAddressSearchBar =
                                      !_showAddressSearchBar;
                                    });*/
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
                                              color: customAppTheme.bgLayer3,
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(MySize.size8))),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: Spacing.left(12),
                                              child: TypeAheadField(
                                                noItemsFoundBuilder: (
                                                    buildContext) {
                                                  return Container(
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: MySize.size12),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Aucun lieu trouvé",
                                                      style: AppTheme
                                                          .getTextStyle(
                                                          themeData.textTheme
                                                              .bodyText2,
                                                          fontSize: MySize.size18,
                                                          color: themeData
                                                              .colorScheme
                                                              .onBackground,
                                                          fontWeight: 500),),
                                                  );
                                                },
                                                loadingBuilder: (buildContext) {
                                                  return Container(
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: MySize.size12),
                                                    alignment: Alignment.center,
                                                    child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<
                                                          Color>(DikoubaColors
                                                          .blue['pri']),),);
                                                },
                                                textFieldConfiguration: TextFieldConfiguration(
                                                    autofocus: false,
                                                    style: AppTheme.getTextStyle(
                                                        themeData.textTheme
                                                            .bodyText2,
                                                        fontSize: MySize.size18,
                                                        color: themeData
                                                            .colorScheme
                                                            .onBackground,
                                                        fontWeight: 500),
                                                    textCapitalization: TextCapitalization
                                                        .sentences,
                                                    decoration: InputDecoration(
                                                      fillColor: customAppTheme
                                                          .bgLayer1,
                                                      hintStyle: AppTheme
                                                          .getTextStyle(
                                                          themeData.textTheme
                                                              .bodyText2,
                                                          fontSize: MySize.size18,
                                                          color: themeData
                                                              .colorScheme
                                                              .onBackground,
                                                          muted: true,
                                                          fontWeight: 500),
                                                      hintText: "Rechercher un lieu...",
                                                      border: InputBorder.none,
                                                      enabledBorder: InputBorder
                                                          .none,
                                                      focusedBorder: InputBorder
                                                          .none,
                                                      isDense: true,
                                                    )
                                                ),
                                                suggestionsCallback: (
                                                    pattern) async {
                                                  print(
                                                      "suggestionsCallback pattern=$pattern");
                                                  var response = await googleSearchByAddress(
                                                      pattern.toString());
                                                  print(
                                                      "suggestionsCallback response=$response");
                                                  return response;
                                                },
                                                itemBuilder: (context,
                                                    suggestion) {
                                                  return Container(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: MySize.size12),
                                                    color: Colors.white,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: MySize.size8,),
                                                        Icon(Icons.location_pin,
                                                          size: MySize.size24,
                                                          color: DikoubaColors.blue['pri'],),
                                                        SizedBox(
                                                          width: MySize.size8,),
                                                        Expanded(child: Text(
                                                          suggestion['description'],
                                                          style: AppTheme
                                                              .getTextStyle(
                                                              themeData.textTheme
                                                                  .bodyText2,
                                                              fontSize: MySize
                                                                  .size18,
                                                              color: themeData
                                                                  .colorScheme
                                                                  .onBackground,
                                                              fontWeight: 500),))
                                                      ],
                                                    ),
                                                  );
                                                },
                                                onSuggestionSelected: (
                                                    suggestion) {
                                                  print(
                                                      "onSuggestionSelected suggestion=$suggestion");
                                                  getPickedInfo(suggestion);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
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
                                color: DikoubaColors.blue['pri'],borderRadius: BorderRadius.circular(6),
                                child: InkWell(
                                  splashColor: DikoubaColors.blue['lig'], // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(Icons.my_location, color: Colors.white, size: MySize.size24,)),
                                  onTap: () async {
                                    if(_currentPosition != null) moveToEventPosition(_currentPosition.latitude, _currentPosition.longitude);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: MySize.size6,),
                            ClipOval(
                              child: Material(
                                color: DikoubaColors.blue['pri'],borderRadius: BorderRadius.circular(6),
                                child: InkWell(
                                  splashColor: DikoubaColors.blue['lig'], // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(MdiIcons.plus, color: Colors.white, size: MySize.size24,)),
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
                                color: DikoubaColors.blue['pri'], // button color
                                child: InkWell(
                                  splashColor: DikoubaColors.blue['lig'],  // inkwell color
                                  child: SizedBox(width: MySize.size48, height: MySize.size48, child: Icon(Icons.remove, color: Colors.white, size: MySize.size24)),
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
                      top: (MySize.screenHeight - MySize.size50)/ 2,
                      right: (MySize.screenWidth - MySize.size50)/ 2,
                      child: Icon(Icons.person_pin_circle, size: MySize.size50),
                    ),
                    Positioned(
                        top: MySize.screenHeight-MySize.size40*2,
                        left: 0,
                        child: Container(
                            width: MySize.screenWidth,
                            height: MySize.size30,
                            color: Colors.black12,
                            child: Text(_selectedAddress!=null?_selectedAddress:"Nothing found",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),)
                        )
                    ),
                  ],
                )),
          );
        });
  }
}


class _AddEventPackageDialog extends StatefulWidget {
  @override
  _AddEventPackageDialogState createState() => _AddEventPackageDialogState();
}
class _AddEventPackageDialogState extends State<_AddEventPackageDialog> {
  GlobalKey<FormState> _formKey;

  TextEditingController libelleCtrler;
  TextEditingController priceCtrler;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();
    libelleCtrler= new TextEditingController();
    priceCtrler= new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Ajouter package',style: themeData.appBarTheme.textTheme.headline6),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Material(
                child: InkWell(
                    onTap: () {
                      saveForm(context);
                    },
                    child: Icon(MdiIcons.check))),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 64,
                          child: Center(
                            child: Icon(MdiIcons.label,color: themeData.colorScheme.onBackground,),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: libelleCtrler,
                                  style: themeData.textTheme.subtitle2.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Veuillez saisir le libellé';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: themeData.textTheme.subtitle2.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                    hintText: "Libellé",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .border
                                              .borderSide
                                              .color),
                                    ),
                                    enabledBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .enabledBorder
                                              .borderSide
                                              .color),
                                    ),
                                    focusedBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .focusedBorder
                                              .borderSide
                                              .color),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.sentences,
                                  keyboardType: TextInputType.name,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 64,
                          child: Center(
                            child: Icon(MdiIcons.dolly,color: themeData.colorScheme.onBackground,),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: priceCtrler,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Veuillez saisir le prix';
                                    }
                                    return null;
                                  },
                                  style: themeData.textTheme.subtitle2.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                  decoration: InputDecoration(
                                    hintStyle: themeData.textTheme.subtitle2.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                    hintText: "Prix",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .border
                                              .borderSide
                                              .color),
                                    ),
                                    enabledBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .enabledBorder
                                              .borderSide
                                              .color),
                                    ),
                                    focusedBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .focusedBorder
                                              .borderSide
                                              .color),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    width: double.infinity,
                    child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 48),
                        color: themeData.colorScheme.primary,
                        splashColor: Colors.white.withAlpha(150),
                        highlightColor: themeData.colorScheme.primary,
                        onPressed: () {
                          saveForm(context);
                        },
                        child: Text("Valider".toUpperCase(),
                          style: themeData.textTheme.button.merge(TextStyle(color : themeData.colorScheme.onPrimary,letterSpacing: 0.3)),)
                    ),
                  )

                ],
              )),
        ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    if(_formKey.currentState.validate()) {
      PackageModel packageModel = new PackageModel(name: libelleCtrler.text, price: priceCtrler.text);
      Navigator.of(_formKey.currentContext).pop('${packageModel.toRYString()}');
    }
  }
}


class _SelectCategoryDialog extends StatefulWidget {
  @override
  _SelectCategoryDialogState createState() => _SelectCategoryDialogState();
}
class _SelectCategoryDialogState extends State<_SelectCategoryDialog> {
  static final String TAG = '_SelectCategoryDialogState';

  bool _isCategoryFinding = false;
  List<CategoryModel> _listCategory = new List();

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    findAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Sélectionner la catégorie',style: themeData.appBarTheme.textTheme.headline6),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Material(
                child: InkWell(
                    onTap: () {
                      saveForm(context);
                    },
                    child: Icon(MdiIcons.check))),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),
        child: _isCategoryFinding
            ? Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),),)
            : ListView.builder(
          itemCount: _listCategory.length,
          itemBuilder: (context, index) {
            CategoryModel item = _listCategory[0];
            return InkWell(
              onTap: (){
                setSelectdeIndex(index);
              },
              child: Container(
                width: MySize.screenWidth,
                padding: EdgeInsets.only(top: 8,bottom: 8,left: 6,right: 6),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('${item.title}',
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText1,
                              fontSize: 16,
                              letterSpacing: 0.7,))),
                    selectedIndex == index
                        ? Icon(MdiIcons.circle, size: MySize.size14, color: DikoubaColors.blue['pri'],)
                        : Icon(MdiIcons.circleOutline, size: MySize.size14, color: DikoubaColors.blue['pri'],)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void setSelectdeIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  void saveForm(BuildContext buildContext) {
    print("$TAG:saveForm selectedIndex=$selectedIndex");
    if(selectedIndex >= 0) {
      CategoryModel categoryModel = _listCategory[selectedIndex];
      Navigator.of(buildContext).pop('${categoryModel.toRYString()}');
    }
  }

  void findAllCategories() async {
    setState(() {
      _isCategoryFinding = true;
    });
    API.findAllCategories().then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findAllCategories ${responseEvents.statusCode}|${responseEvents.data}");
        List<CategoryModel> list = new List();
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(CategoryModel.fromJson(responseEvents.data[i]));
        }
        setState(() {
          _isCategoryFinding = false;
          _listCategory = list;
        });
      } else {
        print("${TAG}:findAllCategories no data ${responseEvents.toString()}");
        setState(() {
          _isCategoryFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:findAllCategories errorinfo ${errWalletAddr}");
      // print("${TAG}:findAllCategories errorinfo ${errWalletAddr.response.data}");
      setState(() {
        _isCategoryFinding = false;
      });
    });
  }
}
