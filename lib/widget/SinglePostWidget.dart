import 'dart:typed_data';
import 'dart:ui';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/dialogs/ShowPostCommentsDialog.dart';
import 'package:dikouba_rawstart/activity/dialogs/ShowPostFavouritesDialog.dart';
import 'package:dikouba_rawstart/model/post_model.dart';
import 'package:dikouba_rawstart/model/postcomment_model.dart';
import 'package:dikouba_rawstart/model/postfavourite_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';

import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flick_video_player/flick_video_player.dart';

class SinglePostWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  PostModel postModel;
  String userId;
  Function() onItemChangeListener;
  SinglePostWidget(this.customAppTheme, this.postModel, this.userId,
      {Key? key, required this.analytics, required this.observer, required this.onItemChangeListener});

  @required
  final FirebaseAnalytics analytics;
  @required
  final FirebaseAnalyticsObserver observer;

  @override
  SinglePostWidgetState createState() => SinglePostWidgetState();
}

class SinglePostWidgetState extends State<SinglePostWidget> {
  static final String TAG = 'SingleEventsWidgetState';

  late ThemeData themeData;

  bool _isEventFavoring = false;
  bool _isDeleting = false;
  late Uint8List _thumbNail;

  bool isFreeEvent = false;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "SinglePostWidget",
      screenClassOverride: "SinglePostWidget",
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

  Future<void> _initThumbNail() async{
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.postModel.media!,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    setState(() {
      _thumbNail = uint8list!;
    });
  }

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    if(widget.postModel.type == "video") _initThumbNail();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    int spentTime = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.postModel.created_at!.seconds) * 1000)).inMinutes;

    return Container(
      margin: Spacing.fromLTRB(16, 4, 16, 4),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          color:  widget.customAppTheme.bgLayer1,
          border:
              Border.all(color: widget.customAppTheme.bgLayer1, width: 0.8),
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
              ),
              CircleAvatar(
                  backgroundColor:
                  Theme.of(context).accentColor,
                  backgroundImage:
                  NetworkImage(widget.postModel.annoncers!.picture_path!),
                ),
              SizedBox(
                width: 16,
              ),
              Text(
                widget.postModel.annoncers!.compagny!,
                style: Theme.of(context)
                    .textTheme
                    .headline6,
              ),
          ]),
          widget.postModel.type == "texte"
              ? Container(
                  padding: Spacing.fromLTRB(16, 4, 16, 4),
                  child: Text(
                    widget.postModel.media!,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.textTheme.bodyLarge?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w600),//AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        //color: themeData.colorScheme.onBackground,
                        //fontWeight: 600),
                  ))
              : InkWell(
                  onTap: () {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        mediaDialog(widget.postModel));
                    },
                  child:widget.postModel.type == "photo" ? Row(
                  children: [
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(MySize.size8),
                                topRight: Radius.circular(MySize.size8)),
                            child: widget.postModel.media!.contains('assets')
                                ? Image(
                              image: AssetImage(widget.postModel.media!),
                              fit: BoxFit.cover,
                              height: screenSize.width * 0.5,
                            ):Image(
                              image: NetworkImage(widget.postModel.media!),
                              fit: BoxFit.cover,
                              height: screenSize.width * 0.5,
                            ),
                          ),
                    ))
                  ],
                ) : Row(
                  children: [
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(MySize.size8),
                                topRight: Radius.circular(MySize.size8)),
                            child: widget.postModel.media!.contains('assets')
                                ? Image(
                              image: AssetImage(widget.postModel.media!), //NetworkImage(widget.postModel.media),
                              fit: BoxFit.cover,
                              height: screenSize.width * 0.5,
                            ):_thumbNail != null ?Image(
                              image: MemoryImage(_thumbNail), //NetworkImage(widget.postModel.media),
                              fit: BoxFit.cover,
                              height: screenSize.width * 0.5,
                            ):Image(
                              image: NetworkImage(""), //NetworkImage(widget.postModel.media),
                              fit: BoxFit.cover,
                              height: screenSize.width * 0.5,
                            ),
                          ),
                        ))
                  ],
          )),
          Container(
            padding: Spacing.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: Spacing.top(2),
                  child: Text(
                    widget.postModel.description!,
                    maxLines: 4,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.textTheme.bodyLarge?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w600),//AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                    //color: themeData.colorScheme.onBackground,
                    //fontWeight: 600),
                    ),
                ),
                SizedBox(height: 16,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          showPostCommentsDialog();
                        },
                        child: Icon(
                          MdiIcons.comment,
                          color: DikoubaColors.blue['pri'],
                        ),
                      ),
                    ),
                    Text(
                      widget.postModel.nbre_comments!,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodyLarge?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w500),//AppTheme.getTextStyle(
                          //themeData.textTheme.bodyText1,
                          //color: themeData.colorScheme.onBackground,
                          //fontWeight: 500,
                          //xMuted: false),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        onTap: () {
                          saveLike(context);
                        },
                        child: Icon(
                          MdiIcons.heartOutline,
                          color: _isEventFavoring
                              ? themeData.colorScheme.onBackground
                              : DikoubaColors.blue['pri'],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showPostFavouritesDialog();
                      },
                      child: Text(
                        widget.postModel.nbre_likes! + " likes",
                        overflow: TextOverflow.ellipsis,
                        style: themeData.textTheme.bodyLarge?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w500),//AppTheme.getTextStyle(
                            //themeData.textTheme.bodyText1,
                            //color: themeData.colorScheme.onBackground,
                            //fontWeight: 500,
                            //xMuted: false),
                      ),
                    ),
                    widget.userId != widget.postModel.annoncers?.id_users
                        ? Container()
                        : Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: InkWell(
                              onTap: () {
                                deletePost(context);
                              },
                              child: Icon(
                                MdiIcons.delete,
                                color: _isDeleting
                                    ? themeData.colorScheme.onBackground
                                    : DikoubaColors.red['pri'],
                              ),
                            ),
                          ),
                    Expanded(child: Container()),
                    InkWell(
                      child: Text(
                        spentTime < 60 ? ("il y a " + (spentTime).toString() + " minutes") :
                        spentTime < 1440 ? ("il y a " + ((spentTime/60).round()).toString() + " heures") :
                        spentTime < 43200 ? ("il y a " + ((spentTime/60/24).round()).toString() + " jours") :
                        ("il y a " + ((spentTime/60/24/30).round()).toString() + " mois"),
                        overflow: TextOverflow.ellipsis,
                        style: themeData.textTheme.bodyLarge?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w500),//AppTheme.getTextStyle(
                            //themeData.textTheme.bodyText1,
                            //color: themeData.colorScheme.onBackground,
                            //fontWeight: 500,
                            //xMuted: false),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showPostCommentsDialog() async {
    await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ShowPostCommentsDialog(
              widget.postModel,
              widget.customAppTheme,
              widget.userId,
              analytics: widget.analytics,
              observer: widget.observer,
            )));
  }

  void showPostFavouritesDialog() async {
    await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ShowPostFavouritesDialog(
              widget.postModel,
              themeData,
              widget.userId,
              analytics: widget.analytics,
              observer: widget.observer,
            )));
  }

  void saveLike(BuildContext buildContext) async {
    setState(() {
      _isEventFavoring = true;
    });

    PostFavouriteModel favouriteModel = new PostFavouriteModel();
    favouriteModel.id_evenements = widget.postModel.id_evenements;
    favouriteModel.id_posts = widget.postModel.id_posts;
    favouriteModel.id_users = widget.userId;

    API.createPostFavourite(favouriteModel).then((responseEvent) async {
      print(
          "${TAG}:saveLike:createPostComment responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        PostModel postCreated = new PostModel.fromJson(responseEvent.data);

        _sendAnalyticsEvent("EventPostAddComent");
        widget.postModel.nbre_likes =
            (int.parse(widget.postModel.nbre_likes!) + 1).toString();
        setState(() {
          _isEventFavoring = false;
        });
        //
        DikoubaUtils.toast_success(buildContext, "Post liké");
      } else {
        DikoubaUtils.toast_error(buildContext, "Impossible de liker le post");
        setState(() {
          _isEventFavoring = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isEventFavoring = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      debugPrint("${TAG}:saveLike catchError ${errorLogin}");
      debugPrint(
          "${TAG}:saveLike catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }

  void deletePost(BuildContext buildContext) async {
    setState(() {
      _isDeleting = true;
    });

    PostModel postModel = new PostModel();
    postModel.id_evenements = widget.postModel.id_evenements;
    postModel.id_posts = widget.postModel.id_posts;

    API.deleteEventPost(postModel).then((responseEvent) async {
      print(
          "${TAG}:deletePost:deleteEventPost responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        setState(() {
          _isDeleting = false;
        });
        //
        DikoubaUtils.toast_success(buildContext, "Post supprimé avec succès");
        widget.onItemChangeListener();
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible de supprimer le post");
        setState(() {
          _isDeleting = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isDeleting = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      debugPrint("${TAG}:saveLike catchError ${errorLogin}");
      debugPrint(
          "${TAG}:saveLike catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }
}

class mediaDialog extends StatefulWidget {
  PostModel postModel;
  //Function(bool) willRefresh;
  mediaDialog(this.postModel);//, this.willRefresh);

  @override
  _mediaDialogState createState() => _mediaDialogState();
}

class _mediaDialogState extends State<mediaDialog> {
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final videoPlayerController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');

  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    if(widget.postModel.type == "video"){
      _controller = VideoPlayerController.network(
        widget.postModel.media!,
        //'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      );
      _initializeVideoPlayerFuture = _controller.initialize();

      flickManager = FlickManager(
        videoPlayerController:
        VideoPlayerController.network(widget.postModel.media!),
      );
    }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    if(widget.postModel.type == "video") {
      _controller.dispose();
      flickManager.dispose();
    }
    super.dispose();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child:  widget.postModel.type == "video" ?
            FlickVideoPlayer(
                flickManager: flickManager
            )
            /*Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the VideoPlayerController has finished initialization, use
                        // the data it provides to limit the aspect ratio of the video.
                        return AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          // Use the VideoPlayer widget to display the video.
                          child: VideoPlayer(_controller),
                        );
                      } else {
                        // If the VideoPlayerController is still initializing, show a
                        // loading spinner.
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      // Wrap the play or pause in a call to `setState`. This ensures the
                      // correct icon is shown.
                      setState(() {
                        // If the video is playing, pause it.
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          // If the video is paused, play it.
                          _controller.play();
                        }
                      });
                    },
                    // Display the correct icon depending on the state of the player.
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                ]
            )  */
                : widget.postModel.media!.contains('assets')
                ?Image(
              image: AssetImage(widget.postModel.media!),
              fit: BoxFit.cover,
            ):Image(
              image: NetworkImage(widget.postModel.media!),
              fit: BoxFit.cover,
            )
        );
      },
    );
  }
}