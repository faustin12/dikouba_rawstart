import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/eventnewsessions_activity.dart';
import 'package:dikouba_rawstart/activity/home_activity.dart';
import 'package:dikouba_rawstart/activity/register_activity.dart';
import 'package:dikouba_rawstart/fragment/EventCreateSession.dart';
import 'package:dikouba_rawstart/model/category_model.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/firebaselocation_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/post_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/provider/firestorage_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:geocoding/geocoding.dart';

class EvenAddPostActivity extends StatefulWidget {
  EvenementModel evenementModel;
  EvenAddPostActivity(
      {Key? key, required this.analytics, required this.observer, required this.evenementModel})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EvenAddPostActivityState createState() => _EvenAddPostActivityState();
}

class _EvenAddPostActivityState extends State<EvenAddPostActivity> {
  static final String TAG = 'EvenAddPostActivityState';

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late UserModel _userModel;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  late GlobalKey<FormState> _formEventKey;

  late TextEditingController libelleCtrler;
  late TextEditingController descriptionCtrler;

  final picker = ImagePicker();

  bool _isEventCreating = false;
  late XFile _eventbanner;
  late Uint8List _thumbNail;
  late List<bool> isSelected;
  late List<String> typePostList;
  late int indexTypePost;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    print(
        '${TAG}:queryUser query all rows:${userRows.length} | ${userRows.toString()}');
    setState(() {
      _userModel = UserModel.fromJsonDb(userRows[0]);
    });
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
  void initState() {
    isSelected = [true, false, false];
    indexTypePost = 0;
    typePostList = ["texte", "photo", "video"];
    super.initState();
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
                                      "Nouveau post - ${widget.evenementModel.title}",
                                      style: themeData.textTheme.bodyMedium?.copyWith(
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    child: ToggleButtons(
                                      fillColor: themeData.colorScheme.primary,
                                      color: Colors.transparent,
                                      borderWidth: 0,
                                      selectedBorderColor:
                                          themeData.colorScheme.primary,
                                      selectedColor:
                                          themeData.colorScheme.primary,
                                      borderColor: Colors.transparent,
                                      borderRadius: BorderRadius.circular(0),
                                      onPressed: (int index) {
                                        setState(() {
                                          for (int i = 0;
                                              i < isSelected.length;
                                              i++) {
                                            isSelected[i] = (i == index);
                                          }
                                          indexTypePost = index;
                                        });
                                      },
                                      isSelected: isSelected,
                                      children: <Widget>[
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Texte',
                                              style: themeData.textTheme.bodyLarge?.copyWith(
                                                color: isSelected[0]
                                                    ? themeData
                                                        .colorScheme.onSecondary
                                                    : themeData.colorScheme
                                                        .onBackground,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Image',
                                              style: themeData.textTheme.bodyLarge?.copyWith(
                                                color: isSelected[1]
                                                    ? themeData
                                                        .colorScheme.onSecondary
                                                    : themeData.colorScheme
                                                        .onBackground,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Video',
                                              style: themeData.textTheme.bodyLarge?.copyWith(
                                                color: isSelected[2]
                                                    ? themeData
                                                        .colorScheme.onSecondary
                                                    : themeData.colorScheme
                                                        .onBackground,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  indexTypePost == 0
                                      ? Container(
                                          margin:
                                              Spacing.fromLTRB(24, 8, 24, 0),
                                          child: TextFormField(
                                            controller: libelleCtrler,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Veuillez saisir le titre du post';
                                              }
                                              return null;
                                            },
                                            style: themeData.textTheme.headlineSmall?.copyWith(
                                              color: themeData.colorScheme.onBackground,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.4,
                                            ),
                                            decoration: InputDecoration(
                                              fillColor: themeData
                                                  .colorScheme.background,
                                              hintStyle: themeData.textTheme.headlineSmall?.copyWith(
                                                color: themeData.colorScheme.onBackground,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.4,
                                              ),
                                              filled: false,
                                              hintText: "Titre du Post",
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                            autocorrect: false,
                                            maxLines: 3,
                                            autovalidateMode: AutovalidateMode.disabled,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                          ),
                                        )
                                      : indexTypePost == 1
                                      ? imagePickerWidget() : videoPickerWidget(),
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
                                      ),
                                      // AppTheme.getTextStyle(
                                      //     themeData.textTheme.bodyText2,
                                      //     color: themeData
                                      //         .colorScheme.onBackground,
                                      //     fontWeight: 500,
                                      //     letterSpacing: 0,
                                      //     muted: true),
                                      decoration: InputDecoration(
                                        hintText: "Description du Post",
                                        hintStyle: themeData.textTheme.bodyMedium?.copyWith(
                                          color: themeData.colorScheme.onBackground,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0,
                                        ),
                                        // AppTheme.getTextStyle(
                                        //     themeData.textTheme.bodyText2,
                                        //     color: themeData
                                        //         .colorScheme.onBackground,
                                        //     fontWeight: 600,
                                        //     letterSpacing: 0,
                                        //     xMuted: true),
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
                                  _sendAnalyticsEvent("PressCancelCreateEvent");
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
                                      "Fermer".toUpperCase(),
                                      style: themeData.textTheme.bodySmall?.copyWith(
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.7,
                                        fontSize: 12,
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
                                                "Ajouter le Post".toUpperCase(),
                                                style: themeData.textTheme.bodySmall?.copyWith(
                                                  color: themeData.colorScheme.onPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.7,
                                                  fontSize: 12,
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

  Widget imagePickerWidget() {
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
                      "Image",
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
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                            // AppTheme.getTextStyle(
                            //     themeData.textTheme.caption,
                            //     fontSize: 12,
                            //     fontWeight: 600,
                            //     color: themeData.colorScheme.onBackground,
                            //     xMuted: true),
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

  Widget videoPickerWidget() {
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
                          "Vidéo",
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
                          _showBottomSheetPickVideo(context);
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
                      "Aucune vidéo selectionnée",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      // AppTheme.getTextStyle(
                      //     themeData.textTheme.caption,
                      //     fontSize: 12,
                      //     fontWeight: 600,
                      //     color: themeData.colorScheme.onBackground,
                      //     xMuted: true),
                    ),
                  )
                      : Container(
                    margin: Spacing.top(4),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(_thumbNail), //FileImage(new File(_eventbanner.path)),
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
    //List<Media> mediaList = [];
    var resultAction = await showModalBottomSheet(
        context: buildContext,
        builder: (BuildContext buildContext) {
          return
            /*MediaPicker(
            mediaList: mediaList,
            onPick: (selectedList) {
              print('Got Media ${selectedList.length}');
              setState(() => mediaList = selectedList);
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
            mediaCount: MediaCount.single,
            mediaType: MediaType.all,
            decoration: PickerDecoration(
              actionBarPosition: ActionBarPosition.top,
              blurStrength: 2,
              completeText: 'Next',
            ),
          );*/
          Container(
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
      XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _eventbanner = pickedFile!;
      });
    }
  }

  void _showBottomSheetPickVideo(BuildContext buildContext) async {
    //List<Media> mediaList = [];
    var resultAction = await showModalBottomSheet(
        context: buildContext,
        builder: (BuildContext buildContext) {
          return
            Container(
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
    print("$TAG:showBottomSheetPickVideo $resultAction");

    if (resultAction == 'camera') {
      XFile? pickedFile = await picker.pickVideo(source: ImageSource.camera);
      final uint8list = await VideoThumbnail.thumbnailData(
        video: pickedFile!.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );
      setState(() {
        _eventbanner = pickedFile;
        _thumbNail = uint8list!;
      });
    } else if (resultAction == 'gallerie') {
      XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      final uint8list = await VideoThumbnail.thumbnailData(
        video: pickedFile!.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );
      setState(() {
        _eventbanner = pickedFile;
        _thumbNail = uint8list!;
      });
    }
  }

  void checkEventForm(BuildContext buildContext) {
    if (_formEventKey.currentState!.validate()) {
      if (_eventbanner == null && indexTypePost != 0) {
        DikoubaUtils.toast_error(
            buildContext, "Veuillez selectionner un fichier");
        return;
      }

      print("$TAG:checkEventForm all is OK");
      savePost(buildContext);
    }
  }

  void savePost(BuildContext buildContext) async {
    setState(() {
      _isEventCreating = true;
    });

    PostModel post = new PostModel();
    if (indexTypePost != 0) {
      // Enregistrement de la banniere dans Fire Storage
      var downloadLink = await FireStorageProvider.fireUploadFileToRef(
          FireStorageProvider.FIRESTORAGE_REF_POST,
          _eventbanner.path,
          DateFormat('ddMMMyyyyHHmm').format(DateTime.now()));
      print("$TAG:saveEvent downloadLink=$downloadLink");
      post.media = downloadLink;
    } else {
      post.media = libelleCtrler.text;
    }

    post.description = descriptionCtrler.text;
    post.id_evenements = widget.evenementModel.id_evenements;
    post.type = typePostList[indexTypePost];

    API.createPost(post).then((responseEvent) async {
      print(
          "${TAG}:savePost:createPost responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        PostModel postCreated = new PostModel.fromJson(responseEvent.data);

        setState(() {
          _isEventCreating = false;
        });
        //
        DikoubaUtils.toast_success(buildContext, "Post crée avec succés");
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
      debugPrint("${TAG}:createAnnoncer catchError ${errorLogin}");
      debugPrint(
          "${TAG}:createAnnoncer catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }
}

