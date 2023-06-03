import 'package:dikouba_rawstart/activity/user/useriteminfo_activity.dart';
import 'package:dikouba_rawstart/model/post_model.dart';
import 'package:dikouba_rawstart/model/postfavourite_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShowPostFavouritesDialog extends StatefulWidget {
  ThemeData themeData;
  PostModel postModel;
  String userId;

  ShowPostFavouritesDialog(this.postModel, this.themeData, this.userId,
      {required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _ShowPostFavouritesDialogState createState() =>
      _ShowPostFavouritesDialogState();
}

class _ShowPostFavouritesDialogState extends State<ShowPostFavouritesDialog> {
  static final String TAG = 'ShowPostFavouritesDialogState';
  List<PostFavouriteModel> listFavourites = [];
  bool _isFinding = false;

  bool _isAddLike = false;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "ShowPostFavouritesDialogState",
      screenClassOverride: "ShowPostFavouritesDialogState",
    );
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await widget.analytics.logEvent(
      name: name,
      parameters: <String, dynamic>{},
    );
  }

  @override
  void initState() {
    super.initState();

    _setCurrentScreen();
    findPostFavourites();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      /*appBar: new AppBar(
        title: Text("Likes du post",
            style: themeData.appBarTheme.textTheme.headline6),
      ),*/
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sendAnalyticsEvent("PressPostAddFavourite");
          saveLike(context);
        },
        backgroundColor: _isAddLike
            ? themeData.colorScheme.onBackground
            : DikoubaColors.blue['pri'],
        child: Icon(
          MdiIcons.heart,
          size: MySize.size32,
          color: Colors.white,
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        child: _isFinding
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),
                ),
              )
            : (listFavourites == null || listFavourites.length == 0)
                ? Container(
                    margin: Spacing.fromLTRB(24, 16, 24, 0),
                    child: Text(
                      "Aucun like trouvé",
                      style: themeData.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: FontWeight.w500, ),//xMuted: true),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: MySize.size24),
                    itemCount: listFavourites.length,
                    itemBuilder: (context, index) {
                      PostFavouriteModel itemFavourite = listFavourites[index];
                      DateTime _createdDate =
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(itemFavourite.created_at!.seconds) *
                                  1000);
                      return singleFavourite(itemFavourite,
                          createdAt:
                              "${DateFormat('dd MMM yyyy, HH:mm').format(_createdDate)}");
                    },
                  ),
      ),
    );
  }

  void saveLike(BuildContext buildContext) async {
    setState(() {
      _isAddLike = true;
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
          _isAddLike = false;
        });
        //
        DikoubaUtils.toast_success(buildContext, "Post liké");
        findPostFavourites();
      } else {
        DikoubaUtils.toast_error(buildContext, "Impossible de liker le post");
        setState(() {
          _isAddLike = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isAddLike = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      debugPrint("${TAG}:saveLike catchError ${errorLogin}");
      debugPrint(
          "${TAG}:saveLike catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }

  void gotoUserItemProfile(UserModel userModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserItemInfoActivity(
                  userModel,
                  userModel,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
  }

  Widget singleFavourite(PostFavouriteModel favouriteModel,
      {required String createdAt}) {
    String image = favouriteModel.users!.photo_url!;
    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              gotoUserItemProfile(favouriteModel.users!);
            },
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child: (image == "" || image == "null")
                    ? Image(
                  image: AssetImage('./assets/logo/user_transparent.webp'),
                  fit: BoxFit.cover,
                  width: MySize.size40,
                  height: MySize.size40,
                ):Image(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  width: MySize.size40,
                  height: MySize.size40,
                )),
          ),
          Expanded(
            child: Container(
              margin: Spacing.left(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${favouriteModel.users!.name}",
                    style: widget.themeData.textTheme.bodyMedium?.copyWith(
                        color: widget.themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "$createdAt",
                    style: widget.themeData.textTheme.bodySmall?.copyWith(
                        color: widget.themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w500, ),//muted: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void findPostFavourites() async {
    setState(() {
      _isFinding = true;
    });
    API
        .findPostFavouritesEvent(
            widget.postModel.id_evenements!, widget.postModel.id_posts!)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findPostComents ${responseEvents.statusCode}|${responseEvents.data}");
        List<PostFavouriteModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(PostFavouriteModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isFinding = false;
          listFavourites = list;
        });
      } else {
        print("$TAG:findSondage no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("$TAG:findSondage errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isFinding = false;
      });
    });
  }
}
