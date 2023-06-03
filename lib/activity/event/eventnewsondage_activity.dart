import 'dart:convert';
import 'dart:io';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/eventnewsessions_activity.dart';
import 'package:dikouba_rawstart/model/category_model.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/sondagereponse_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/provider/firestorage_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class EvenNewSondageActivity extends StatefulWidget {
  @required
  EvenementModel evenementModel;

  EvenNewSondageActivity(this.evenementModel,
      {Key? key, required this.analytics, required this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  EvenNewSondageActivityState createState() => EvenNewSondageActivityState();
}

class EvenNewSondageActivityState extends State<EvenNewSondageActivity> {
  static final String TAG = 'EvenNewSondageActivityState';

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late UserModel _userModel;

  late Future<List<Widget>> widgetsView;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  late GlobalKey<FormState> _formEventKey;

  late TextEditingController libelleCtrler;
  late TextEditingController descriptionCtrler;

  final picker = ImagePicker();

  bool _isEventCreating = false;
  List<SondageReponseModel> _listReponsesSdge = [];
  late DateTime _startDate;
  late DateTime _endDate;
  late XFile _eventbanner;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    setState(() {
      _userModel = UserModel.fromJsonDb(userRows[0]);
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EvenNewSondageActivity",
      screenClassOverride: "EvenNewSondageActivity",
    );
  }

  Future<void> _setUserId(String uid) async {
    await widget.analytics.setUserId(id : uid);
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
    queryUser();

    _formEventKey = GlobalKey<FormState>();
    libelleCtrler = new TextEditingController();
    descriptionCtrler = new TextEditingController();
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
                                  SizedBox(
                                    height: MySize.size26,
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(24, 24, 24, 0),
                                    child: Text(
                                      "Nouveau sondage dans ${widget.evenementModel.title}",
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
                                        fillColor:
                                            themeData.colorScheme.background,
                                        hintStyle: themeData.textTheme.headlineSmall?.copyWith(
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                        filled: false,
                                        hintText: "Titre du sondage",
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
                                        letterSpacing: 0
                                      ),/* AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          color: themeData
                                              .colorScheme.onBackground,
                                          fontWeight: 500,
                                          letterSpacing: 0,
                                          muted: true), */
                                      decoration: InputDecoration(
                                        hintText: "Description",
                                        hintStyle: themeData.textTheme.bodyMedium?.copyWith(
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0
                                        ),/* AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText2,
                                            color: themeData
                                                .colorScheme.onBackground,
                                            fontWeight: 600,
                                            letterSpacing: 0,
                                            xMuted: true), */
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
                                  selectDateRangeWidget(),
                                  reponseSondageAddWidget(),
                                  eventBannerWidget(),
                                ],
                              )),
                        ),
                        Container(
                          color: customAppTheme.bgLayer1,
                          padding: Spacing.fromLTRB(24, 16, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: Spacing.fromLTRB(8, 8, 8, 8),
                                  decoration: BoxDecoration(
                                      color: DikoubaColors.red['pri'],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40))),
                                  child: Container(
                                    margin: Spacing.left(12),
                                    child: Text(
                                      "Annuler".toUpperCase(),
                                      style: themeData.textTheme.bodySmall?.copyWith(
                                        color: themeData.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 0.7
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _isEventCreating
                                  ? Container(
                                      width: MySize.size32,
                                      height: MySize.size32,
                                      alignment: Alignment.center,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                DikoubaColors.blue['pri']!),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        checkEventForm(context);
                                      },
                                      child: Container(
                                        padding: Spacing.fromLTRB(8, 8, 8, 8),
                                        decoration: BoxDecoration(
                                            color: DikoubaColors.blue['pri'],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    MySize.size40))),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: Spacing.left(12),
                                              child: Text(
                                                "Créer sondage".toUpperCase(),
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
                                                  color: themeData
                                                      .colorScheme.onPrimary,
                                                  shape: BoxShape.circle),
                                              child: Icon(
                                                MdiIcons.chevronRight,
                                                size: MySize.size20,
                                                color: themeData
                                                    .colorScheme.primary,
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

  Widget selectDateRangeWidget() {
    return InkWell(
      onTap: () {
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
                        ),/* AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            fontSize: 12,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground,
                            xMuted: true), */
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
                icon: Icon(
              MdiIcons.timer,
              color: DikoubaColors.blue['pri'],
            ), onPressed: () {  },),
          ],
        ),
      ),
    );
  }

  Widget reponseSondageAddWidget() {
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
                    Expanded(
                        child: Text(
                      "Reponses",
                      style: themeData.textTheme.titleSmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    IconButton(
                        icon: Icon(
                          MdiIcons.plusCircle,
                          color: DikoubaColors.blue['pri'],
                        ),
                        onPressed: () {
                          addSondageReponse();
                        })
                  ],
                ),
              ),
              (_listReponsesSdge == null || _listReponsesSdge.length == 0)
                  ? Container(
                      margin: Spacing.symmetric(vertical: 2, horizontal: 16),
                      child: Text(
                        "Aucune réponse ajoutée",
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: themeData.colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 12
                        ),/* AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            fontSize: 12,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground,
                            xMuted: true), */
                      ),
                    )
                  : Container(
                      margin: Spacing.vertical(4),
                      height: MySize.size76,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _listReponsesSdge.length,
                        itemBuilder:
                            (BuildContext buildcontext, int indexPack) {
                          SondageReponseModel item =
                              _listReponsesSdge[indexPack];

                          return Container(
                            margin: Spacing.horizontal(8),
                            padding: EdgeInsets.symmetric(
                                horizontal: MySize.size6,
                                vertical: MySize.size6),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: customAppTheme.bgLayer2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text("${item.valeur}",
                                        style: themeData.textTheme.bodySmall?.copyWith(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14, 
                                          letterSpacing: 0.7
                                        ),)),
                                Text("${item.description}",
                                    textAlign: TextAlign.left,
                                    style: themeData.textTheme.bodySmall?.copyWith(
                                      color: themeData.colorScheme.primary,
                                      fontSize: 14,
                                      letterSpacing: 0.7,
                                    ),)
                              ],
                            ),
                          );
                        },
                      ),
                    )
            ],
          ),
        ));
  }

  Widget eventBannerWidget() {
    return Container(
        margin: Spacing.fromLTRB(24, 24, 24, 0),
        height: MySize.screenWidth * 0.7,
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
                    Expanded(
                        child: Text(
                      "Bannière",
                      style: themeData.textTheme.titleSmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    IconButton(
                        icon: Icon(
                          MdiIcons.fileEdit,
                          color: DikoubaColors.blue['pri'],
                        ),
                        onPressed: () {
                          _showBottomSheetPickImage(context);
                        })
                  ],
                ),
              ),
              Expanded(
                  child: (_eventbanner == null)
                      ? Container(
                          margin:
                              Spacing.symmetric(vertical: 2, horizontal: 16),
                          alignment: Alignment.center,
                          child: Text(
                            "Aucune image selectionnée",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),/* AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontSize: 12,
                                fontWeight: 600,
                                color: themeData.colorScheme.onBackground,
                                xMuted: true), */
                          ),
                        )
                      : Container(
                          margin: Spacing.top(4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: FileImage(new File(_eventbanner.path)),
                                  fit: BoxFit.fill),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(MySize.size8),
                                  bottomRight: Radius.circular(MySize.size8))),
                        ))
            ],
          ),
        ));
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
                        margin: EdgeInsets.only(
                            left: MySize.size12, bottom: MySize.size8),
                        child: Text(
                          "Choisir a partir de",
                          style: themeData.textTheme.bodySmall!.merge(TextStyle(
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(200),
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w700)),
                        )),
                    ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.of(buildContext).pop('camera');
                      },
                      leading: Icon(MdiIcons.camera,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(220)),
                      title: Text(
                        "Caméra",
                        style: themeData.textTheme.bodyLarge!.merge(TextStyle(
                            color: themeData.colorScheme.onBackground,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500)),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.of(buildContext).pop('gallerie');
                      },
                      leading: Icon(MdiIcons.imageAlbum,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(220)),
                      title: Text(
                        "Gallerie",
                        style: themeData.textTheme.bodyLarge!.merge(TextStyle(
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
    if (resultAction == 'camera') {
      XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        _eventbanner = pickedFile!;
      });
    } else if (resultAction == 'gallerie') {
      XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _eventbanner = pickedFile!;
      });
    }
  }

  void updateSelectedDateRange() async {
    DateTime today = DateTime.now();
    print('confirm today=$today');
    var startDatetime = await DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        maxTime: today.add(new Duration(days: 3650)),
        minTime: today,
        currentTime: DateTime.now(),
        locale: LocaleType.fr);
    print('confirm startDatetime=${startDatetime.toString()}');
    if (startDatetime != null) {
      DateTime todayEnd =
          DateFormat("yyyy-MM-dd HH:mm").parse('${startDatetime.toString()}');
      print('confirm todayEnd=${todayEnd.toString()}');
      var endDatetime = await DatePicker.showDateTimePicker(context,
          showTitleActions: true,
          maxTime: todayEnd.add(new Duration(days: 3650)),
          minTime: todayEnd.add(new Duration(minutes: 15)),
          currentTime: todayEnd.add(new Duration(minutes: 15)),
          locale: LocaleType.fr);
      print('confirm endDatetime=$endDatetime');
      if (endDatetime != null) {
        setState(() {
          _startDate = startDatetime;
          _endDate = endDatetime;
        });
      }
    }
  }

  void addSondageReponse() async {
    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            _AddSondageReponseDialog()));
    print("addSondageReponse: ${resAddPackage}");

    if (resAddPackage != null) {
      SondageReponseModel itemPackage =
          SondageReponseModel.fromJson(json.decode(resAddPackage));
      setState(() {
        _listReponsesSdge.add(itemPackage);
      });
    }
  }

  void setSelectedCategory() async {
    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => SelectCategoryDialog()));
    print("updateSelectedLocation: ${resAddPackage}");

    if (resAddPackage != null) {
      CategoryModel itemCateg =
          CategoryModel.fromJson(json.decode(resAddPackage));
    }
  }

  void checkEventForm(BuildContext buildContext) {
    if (_formEventKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        DikoubaUtils.toast_error(
            buildContext, "Veuillez selectionner la date de début et de fin");
        return;
      }
      if (_eventbanner == null) {
        DikoubaUtils.toast_error(
            buildContext, "Veuillez selectionner la bannière");
        return;
      }

      print("$TAG:checkEventForm all is OK");
      _saveSondage(buildContext);
    }
  }

  void _saveSondage(BuildContext buildContext) async {
    setState(() {
      _isEventCreating = true;
    });
    // Enregistrement de la banniere dans Fire Storage
    var downloadLink = await FireStorageProvider.fireUploadFileToRef(
        FireStorageProvider.FIRESTORAGE_REF_SONDAGE,
        _eventbanner.path,
        DateFormat('ddMMMyyyyHHmm').format(DateTime.now()));
    print("$TAG:_saveSondage downloadLink=$downloadLink");

    SondageModel sondageModel = SondageModel(evenements: EvenementModel(banner_path: ''), id_sondages: '', reponses: [], reponsesusers: []);
    sondageModel.banner_path = downloadLink;
    sondageModel.title = libelleCtrler.text;
    sondageModel.id_annoncers = _userModel.id_annoncers;
    sondageModel.id_evenements = widget.evenementModel.id_evenements;
    sondageModel.description = descriptionCtrler.text;
    sondageModel.reponses = _listReponsesSdge;
    sondageModel.start_date_tmp =
        "${DateFormat('MM-dd-yyyy HH:mm').format(_startDate)}";
    sondageModel.end_date_tmp =
        "${DateFormat('MM-dd-yyyy HH:mm').format(_endDate)}";

    API.createSondage(sondageModel).then((responseEvent) async {
      print(
          "${TAG}:_saveSondage:createEvent responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        SondageModel sondageMdl = new SondageModel.fromJson(responseEvent.data);

        setState(() {
          _isEventCreating = false;
        });
        Navigator.of(context).pop('reload');
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible de créer le sondage");
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
      print(
          "${TAG}:createAnnoncer catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }

  void gotoAddSession(
      BuildContext buildContext, EvenementModel eventCreated) async {
    var resAddSession = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (buildContext) => EvenNewSessionActivity(
                  eventCreated,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));

    print("$TAG:gotoAddSession ${resAddSession}");
    if (resAddSession == null) return;
    if (resAddSession == 'quit') {
      Navigator.of(buildContext).pop();
    }
  }
}

class _AddSondageReponseDialog extends StatefulWidget {
  @override
  _AddSondageReponseDialogState createState() =>
      _AddSondageReponseDialogState();
}

class _AddSondageReponseDialogState extends State<_AddSondageReponseDialog> {
  late GlobalKey<FormState> _formKey;

  late TextEditingController descriptionCtrler;
  late TextEditingController valeurCtrler;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();
    descriptionCtrler = new TextEditingController();
    valeurCtrler = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Ajouter réponse',
            style: themeData.appBarTheme.textTheme?.headline6),
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
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
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
                            child: Icon(
                              MdiIcons.dolly,
                              color: themeData.colorScheme.onBackground,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: valeurCtrler,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Veuillez saisir la réponse';
                                    }
                                    return null;
                                  },
                                  style: themeData.textTheme.titleSmall!.merge(
                                      TextStyle(
                                          color: themeData
                                              .colorScheme.onBackground)),
                                  decoration: InputDecoration(
                                    hintStyle: themeData.textTheme.titleSmall!
                                        .merge(TextStyle(
                                            color: themeData
                                                .colorScheme.onBackground)),
                                    hintText: "Réponse",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData.inputDecorationTheme
                                              .border!.borderSide.color),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData.inputDecorationTheme
                                              .enabledBorder!.borderSide.color),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData.inputDecorationTheme
                                              .focusedBorder!.borderSide.color),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
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
                            child: Icon(
                              MdiIcons.label,
                              color: themeData.colorScheme.onBackground,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: descriptionCtrler,
                                  style: themeData.textTheme.titleSmall!.merge(
                                      TextStyle(
                                          color: themeData
                                              .colorScheme.onBackground)),
                                  validator: (value) {
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: themeData.textTheme.titleSmall!
                                        .merge(TextStyle(
                                            color: themeData
                                                .colorScheme.onBackground)),
                                    hintText: "Description",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData.inputDecorationTheme
                                              .border!.borderSide.color),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData.inputDecorationTheme
                                              .enabledBorder!.borderSide.color),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeData.inputDecorationTheme
                                              .focusedBorder!.borderSide.color),
                                    ),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                    margin: EdgeInsets.only(top: 16),
                    width: double.infinity,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 48),
                          /* color: themeData.colorScheme.primary,
                          splashColor: Colors.white.withAlpha(150),
                          highlightColor: themeData.colorScheme.primary, */
                        ),
                        onPressed: () {
                          saveForm(context);
                        },
                        child: Text(
                          "Valider".toUpperCase(),
                          style: themeData.textTheme.labelLarge!.merge(TextStyle(
                              color: themeData.colorScheme.onPrimary,
                              letterSpacing: 0.3)),
                        )),
                  )
                ],
              )),
        ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    if (_formKey.currentState!.validate()) {
      SondageReponseModel packageModel = new SondageReponseModel(
          description: descriptionCtrler.text, valeur: valeurCtrler.text, id_annoncers: '', id_evenements: '', id_reponses: '', id_sondages: '', id_users: '', nombre_vote: '');
      Navigator.of(_formKey.currentContext!).pop('${packageModel.toRYString()}');
    }
  }
}

class SelectCategoryDialog extends StatefulWidget {
  @override
  SelectCategoryDialogState createState() => SelectCategoryDialogState();
}

class SelectCategoryDialogState extends State<SelectCategoryDialog> {
  static final String TAG = 'SelectCategoryDialogState';

  bool _isCategoryFinding = false;
  List<CategoryModel> _listCategory = [];

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
        title: Text('Sélectionner la catégorie',
            style: themeData.appBarTheme.textTheme!.headline6),
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
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        child: _isCategoryFinding
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),
                ),
              )
            : ListView.builder(
                itemCount: _listCategory.length,
                itemBuilder: (context, index) {
                  CategoryModel item = _listCategory[0];
                  return InkWell(
                    onTap: () {
                      setSelectdeIndex(index);
                    },
                    child: Container(
                      width: MySize.screenWidth,
                      padding:
                          EdgeInsets.only(top: 8, bottom: 8, left: 6, right: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('${item.title}',
                                  style: themeData.textTheme.bodyLarge?.copyWith(
                                    fontSize: 16,
                                    letterSpacing: 0.7,
                                  ),)),
                          selectedIndex == index
                              ? Icon(
                                  MdiIcons.circle,
                                  size: MySize.size14,
                                  color: DikoubaColors.blue['pri'],
                                )
                              : Icon(
                                  MdiIcons.circleOutline,
                                  size: MySize.size14,
                                  color: DikoubaColors.blue['pri'],
                                )
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
    if (selectedIndex >= 0) {
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
