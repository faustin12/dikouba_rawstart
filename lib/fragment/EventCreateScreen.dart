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

class EventCreateScreen extends StatefulWidget {
  UserModel userModel;
  EventCreateScreen(this.userModel,{required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventCreateScreenState createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  static final String TAG = '_EventCreateScreenState';
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
      screenName: "EventCreateScreen",
      screenClassOverride: "EventCreateScreen",
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
                                      "Nouvel évènement",
                                      style: themeData.textTheme.bodyMedium?.copyWith(
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 8, 24, 0),
                                    child: TextFormField(
                                      controller: libelleCtrler,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Veuillez saisir le titre';
                                        }
                                        return null;
                                      },
                                      style: themeData.textTheme.headlineSmall?.copyWith(
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                      ),
                                      decoration: InputDecoration(
                                        fillColor: themeData.colorScheme.background,
                                        hintStyle: themeData.textTheme.headlineSmall?.copyWith(
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                        filled: false,
                                        hintText: "Titre de l'évènement",
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      autocorrect: false,
                                      autovalidateMode: AutovalidateMode.disabled,
                                      textCapitalization:
                                      TextCapitalization.sentences,
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 0, 24, 0),
                                    child: TextFormField(
                                      controller: descriptionCtrler,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Veuillez saisir la desription';
                                        }
                                        return null;
                                      },
                                      style: themeData.textTheme.bodyMedium?.copyWith(
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0,
                                      ),/*AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: 500,
                                          letterSpacing: 0,
                                          muted: true),*/
                                      decoration: InputDecoration(
                                        hintText: "Description",
                                        hintStyle: themeData.textTheme.bodyMedium?.copyWith(
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0,
                                        ),/*AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText2,
                                            color:
                                            themeData.colorScheme.onBackground,
                                            fontWeight: 600,
                                            letterSpacing: 0,
                                            xMuted: true),*/
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
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),),)
                              : InkWell(
                                onTap: () {
                                  checkEventForm(context);
                                },
                                child: Container(
                                  padding: Spacing.fromLTRB(8, 8, 8, 8),
                                  decoration: BoxDecoration(
                                      color: themeData.colorScheme.primary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40))),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: Spacing.left(12),
                                        child: Text(
                                          "Créer l'évènement".toUpperCase(),
                                          style: themeData.textTheme.bodySmall?.copyWith(
                                            color: themeData.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            letterSpacing: 0.7,
                                          ),
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

  Widget selectCategoryWidget() {
    return Container(
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
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: Spacing.top(2),
                    child: Text(
                      _selectedCategoryModel == null ? "Aucune catégorie selectionnée" : "${_selectedCategoryModel.title}",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontSize: 12,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground,
                          xMuted: true),*/
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            child: _isCategoryFinding
                ? Container(
              width: MySize.size16,
              height: MySize.size16,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),),)
                : PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return _listCategory.map((CategoryModel itemCategory) {
                  return PopupMenuItem(
                    height: 36,
                    value: itemCategory,
                    child: Text("${itemCategory.title}",
                        style: themeData.textTheme.bodyMedium?.copyWith(
                          color: themeData.colorScheme.onBackground,
                        ),
                    ),
                  );
                }).toList();
              },
              onSelected: (CategoryModel itemSelected) {
                print("PopupMenuButton: itemSelected=${itemSelected.title}");
                updateSelectedCategory(itemSelected);
              },
              color: customAppTheme.bgLayer1,
              icon: Icon(
                MdiIcons.chevronDown,
                color: themeData.colorScheme.onBackground,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget selectLocationWidget() {
    return Container(
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
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: Spacing.top(2),
                    child: Text(
                      _selectedLocation == null ? "Aucun lieu selectionné" : "${_selectedLocation.address}",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 12
                      ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontSize: 12,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground,
                          xMuted: true),*/
                    ),
                  )
                ],
              ),
            ),
          ),
          IconButton(icon: Icon(
            MdiIcons.mapMarker,
            color: themeData.colorScheme.onBackground,
          ), onPressed: () {
            updateSelectedLocation();
          }),
        ],
      ),
    );
  }

  Widget selectDateRangeWidget() {
    return Container(
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
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: Spacing.top(2),
                    child: Text(
                      _startDate == null
                          ? "Aucune date selectionnée"
                          : "Du ${DateFormat('dd MMM yyyy HH:mm').format(_startDate)}\nAu ${DateFormat('dd MMM yyyy HH:mm').format(_endDate)}",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 12
                      ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontSize: 12,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground,
                          xMuted: true),*/
                    ),
                  )
                ],
              ),
            ),
          ),
          IconButton(icon: Icon(
            MdiIcons.timer,
            color: themeData.colorScheme.onBackground,
          ), onPressed: () {
            updateSelectedDateRange();
          }),
        ],
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
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  IconButton(icon: Icon(
                    MdiIcons.plusCircle,
                    color: themeData.colorScheme.onBackground,
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
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                    fontSize: 12,
                    fontWeight: 600,
                    color: themeData.colorScheme.onBackground,
                    xMuted: true),*/
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
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: themeData.colorScheme.primary,
                              fontSize: 14,
                              letterSpacing: 0.7
                            ),
                          )
                        ),
                        Text("${item.price} ${DikoubaUtils.CURRENCY}",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.7,
                            ),
                        )
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
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: themeData.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
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
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),/*AppTheme.getTextStyle(themeData.textTheme.caption,
                    fontSize: 12,
                    fontWeight: 600,
                    color: themeData.colorScheme.onBackground,
                    xMuted: true),*/
              ))
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
                          style: themeData.textTheme.bodySmall?.merge(TextStyle(
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
                        style: themeData.textTheme.bodyLarge?.merge(TextStyle(
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
                        style: themeData.textTheme.bodyLarge?.merge(TextStyle(
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
      PickedFile? pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        _eventbanner = pickedFile!;
      });
    } else if(resultAction == 'gallerie') {
      PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _eventbanner = pickedFile!;
      });
    }
  }

  void updateSelectedCategory(CategoryModel itemSelected) {
    setState(() {
      _selectedCategoryModel = itemSelected;
    });
  }

  void updateSelectedDateRange() {

    DateTime today = DateTime.now();
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        maxTime: today.add(new Duration(days: 3650)),
        minTime: today,
        onConfirm: (startDatetime) {
          print('confirm startDatetime=$startDatetime');
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              maxTime: today.add(new Duration(days: 3650)),
              minTime: startDatetime,
              onConfirm: (endDatetime) {
                print('confirm endDatetime=$endDatetime');
                setState(() {
                  _startDate = startDatetime;
                  _endDate = endDatetime;
                });
              }, currentTime: DateTime.now(), locale: LocaleType.fr);
        }, currentTime: DateTime.now(), locale: LocaleType.fr);
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

  bool _showAddressSearchBar = false;
  late CameraPosition _kGooglePlex;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _controller = Completer();

  void updateSelectedLocation2() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>MaterialApp(
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
                                  color: DikoubaColors.blue['pri'],
                                  borderRadius: BorderRadius.circular(6),
                                  child: InkWell(
                                    splashColor: DikoubaColors.blue['lig'],
                                    // inkwell color
                                    child: SizedBox(width: MySize.size48,
                                        height: MySize.size48,
                                        child: _showAddressSearchBar
                                            ? Icon(MdiIcons.chevronLeft,
                                          size: MySize.size24,)
                                            : Icon(MdiIcons.mapMarkerDistance,
                                          size: MySize.size24,)),
                                    onTap: () async {
                                      setState(() {
                                        _showAddressSearchBar =
                                        !_showAddressSearchBar;
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
                                                    style: themeData.textTheme.bodyMedium?.copyWith(
                                                      color: themeData.colorScheme.onBackground,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: MySize.size18,

                                                    ),),
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
                                                        .blue['pri']!),),);
                                              },
                                              textFieldConfiguration: TextFieldConfiguration(
                                                  autofocus: true,
                                                  style: themeData.textTheme.bodyMedium?.copyWith(
                                                    color: themeData.colorScheme.onBackground,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: MySize.size18,
                                                  ),
                                                  textCapitalization: TextCapitalization
                                                      .sentences,
                                                  decoration: InputDecoration(
                                                    fillColor: customAppTheme
                                                        .bgLayer1,
                                                    hintStyle: themeData.textTheme.bodyMedium?.copyWith(
                                                      color: themeData.colorScheme.onBackground,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: MySize.size18,
                                                    ),/*AppTheme
                                                        .getTextStyle(
                                                        themeData.textTheme
                                                            .bodyText2,
                                                        fontSize: MySize.size18,
                                                        color: themeData
                                                            .colorScheme
                                                            .onBackground,
                                                        muted: true,
                                                        fontWeight: 500),*/
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
                                                return response!;
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
                                                        color: Colors.black54,),
                                                      SizedBox(
                                                        width: MySize.size8,),
                                                      Expanded(child: Text(
                                                        suggestion['description'],
                                                        style: themeData.textTheme.bodyMedium?.copyWith(
                                                          color: themeData.colorScheme.onBackground,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: MySize.size18,
                                                        ),))
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
                          SizedBox(height: MySize.size6,),
                        ],
                      )),
                ],
              )
          )
    )));
  }

  Future<void> getPickedInfo(dynamic _pickSuggestion) async {
    var responsePicked = await API.googleAddressInfo(_pickSuggestion['place_id']);
    if (responsePicked.statusCode == 200) {
      print(
          "${TAG}:googleSearchByAddress ${responsePicked
              .statusCode}|${responsePicked.data}");
      var pickedData = responsePicked.data['result'];
      DikoubaUtils.toast_infos(context, "Route " + pickedData.toString());
    }
  }

  Future<List<dynamic>?> googleSearchByAddress(String searchAddress) async {
    var responseSearchAdr = await API.googleSearchAddress(searchAddress);
    if (responseSearchAdr.statusCode == 200) {
      print(
          "${TAG}:googleSearchByAddress ${responseSearchAdr.statusCode}|${responseSearchAdr.data['predictions']}");
      List<dynamic> list = [];

      for (int i = 0; i < responseSearchAdr.data['predictions'].length; i++) {
        list.add(responseSearchAdr.data['predictions'][i]);
      }

      if (!mounted) return null;
      return list;
    }
    return null;
  }

  void updateSelectedLocation() async {
    /*LocationResult locationResult =
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
    });*/
  }

  void checkEventForm(BuildContext buildContext) {
    if(_formEventKey.currentState!.validate()) {
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

    EvenementModel evenementModel = new EvenementModel(banner_path: '');
    evenementModel.banner_path = downloadLink;
    evenementModel.title = libelleCtrler.text;
    evenementModel.id_categories = _selectedCategoryModel.id_categories;
    evenementModel.id_annoncers = widget.userModel.id_annoncers;
    evenementModel.description = descriptionCtrler.text;
    evenementModel.longitude = _selectedLocation.longitude;
    evenementModel.latitude = _selectedLocation.latitude;
    evenementModel.start_date_tmp = "${DateFormat('MM-dd-yyyy HH:mm').format(_startDate)}";
    evenementModel.end_date_tmp = "${DateFormat('MM-dd-yyyy HH:mm').format(_endDate)}";

    API.createEvent(evenementModel)
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
        List<CategoryModel> list = [];
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


class _AddEventPackageDialog extends StatefulWidget {
  @override
  _AddEventPackageDialogState createState() => _AddEventPackageDialogState();
}
class _AddEventPackageDialogState extends State<_AddEventPackageDialog> {
  late GlobalKey<FormState> _formKey;

  late TextEditingController libelleCtrler;
  late TextEditingController priceCtrler;

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
        title: Text('Ajouter package',style: themeData.appBarTheme.textTheme?.titleLarge),
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
                                  style: themeData.textTheme.titleSmall?.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Veuillez saisir le libellé';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: themeData.textTheme.titleSmall?.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                    hintText: "Libellé",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .border!
                                              .borderSide
                                              .color),
                                    ),
                                    enabledBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .enabledBorder!
                                              .borderSide
                                              .color),
                                    ),
                                    focusedBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .focusedBorder!
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
                                    if (value!.isEmpty) {
                                      return 'Veuillez saisir le prix';
                                    }
                                    return null;
                                  },
                                  style: themeData.textTheme.titleSmall?.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                  decoration: InputDecoration(
                                    hintStyle: themeData.textTheme.titleSmall?.merge(TextStyle(color: themeData.colorScheme.onBackground)),
                                    hintText: "Prix",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .border!
                                              .borderSide
                                              .color),
                                    ),
                                    enabledBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .enabledBorder!
                                              .borderSide
                                              .color),
                                    ),
                                    focusedBorder:  UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData
                                              .inputDecorationTheme
                                              .focusedBorder!
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
                    child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 48),
                          //color: themeData.colorScheme.primary,
                          //splashColor: Colors.white.withAlpha(150),
                          //highlightColor: themeData.colorScheme.primary,
                        ),
                        onPressed: () {
                          saveForm(context);
                        },
                        child: Text("Valider".toUpperCase(),
                          style: themeData.textTheme.labelLarge?.merge(TextStyle(color : themeData.colorScheme.onPrimary,letterSpacing: 0.3)),)
                    ),
                  )

                ],
              )),
        ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    if(_formKey.currentState!.validate()) {
      PackageModel packageModel = new PackageModel(name: libelleCtrler.text, price: priceCtrler.text);
      Navigator.of(_formKey.currentContext!).pop('${packageModel.toRYString()}');
    }
  }
}