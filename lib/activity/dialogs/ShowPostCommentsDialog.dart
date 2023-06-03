import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/activity/user/useriteminfo_activity.dart';
import 'package:dikouba_rawstart/model/post_model.dart';
import 'package:dikouba_rawstart/model/postcomment_model.dart';
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

class ShowPostCommentsDialog extends StatefulWidget {
  CustomAppTheme customAppTheme;
  PostModel postModel;
  String userId;

  ShowPostCommentsDialog(this.postModel, this.customAppTheme, this.userId,
      {required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _ShowPostCommentsDialogState createState() => _ShowPostCommentsDialogState();
}

class _ShowPostCommentsDialogState extends State<ShowPostCommentsDialog> {
  static final String TAG = 'ShowPostCommentsDialogState';
  late ThemeData themeData;
  List<PostCommentModel> listCommentaires = [];
  bool _isFinding = false;

  bool _isPostCommenting = false;
  late GlobalKey<FormState> _formEventKey;
  late TextEditingController commentCtrler;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "ShowPostCommentsDialogState",
      screenClassOverride: "ShowPostCommentsDialogState",
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
    _formEventKey = GlobalKey<FormState>();

    commentCtrler = new TextEditingController();

    _setCurrentScreen();
    findPostComents();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
        resizeToAvoidBottomInset: false,
        /*appBar: new AppBar(
          title: Text("Commentaire du post",
              style: themeData.appBarTheme.textTheme.headline6),
        ),*/
        bottomNavigationBar: Container(
          padding: Spacing.fromLTRB(16, 0, 16, 8),
          child: Form(
              key: _formEventKey,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: Spacing.fromLTRB(0, 0, 0, 0),
                      child: TextFormField(
                        controller: commentCtrler,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez saisir votre réaction';
                          }
                          return null;
                        },
                        style: themeData.textTheme.bodyMedium?.copyWith(
                            color: themeData.colorScheme.onBackground,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,),// muted: true),
                        decoration: InputDecoration(
                          hintText: "Entrez votre réaction, question",
                          hintStyle: themeData.textTheme.bodyMedium?.copyWith(
                              color: themeData.colorScheme.onBackground,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0, ),//xMuted: true),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.5,
                                color: themeData.colorScheme.onBackground
                                    .withAlpha(50)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.4,
                                color: DikoubaColors.blue['pri']!.withAlpha(50)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.5,
                                color: themeData.colorScheme.onBackground
                                    .withAlpha(50)),
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        autofocus: false,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        MdiIcons.send,
                        color: _isPostCommenting
                            ? themeData.colorScheme.onBackground
                                .withOpacity(0.3)
                            : themeData.colorScheme.onBackground,
                      ),
                      onPressed: () {
                        if (_isPostCommenting) return;
                        checkCommentForm(context);
                      })
                ],
              )),
        ),
        body: Column(
          children: [
            Container(
              margin: Spacing.fromLTRB(16, 12, 16, 0),
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: widget.customAppTheme.bgLayer1,
                  border: Border.all(
                      color: themeData.colorScheme.onBackground, width: 0.8),
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size8))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.postModel.type == "texte"
                      ? Container(
                          padding: Spacing.fromLTRB(16, 4, 16, 4),
                          child: Text(
                            widget.postModel.media!,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.bodyLarge?.copyWith(
                                color: themeData.colorScheme.onBackground,
                                fontWeight: FontWeight.w600),
                          ))
                      : Row(
                          children: [
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8, bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(MySize.size8),
                                    topRight: Radius.circular(MySize.size8)),
                                child:  widget.postModel.media!
                                    .contains('assets')
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
                        ),
                  Container(
                    padding: Spacing.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: Spacing.top(2),
                          child: Text(
                            widget.postModel.description!,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.bodyLarge?.copyWith(
                                color: themeData.colorScheme.onBackground,
                                fontWeight: FontWeight.w500, ),//xMuted: true),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.only(top: 0, bottom: 8, left: 12, right: 12),
              child: _isFinding
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            DikoubaColors.blue['pri']!),
                      ),
                    )
                  : (listCommentaires == null || listCommentaires.length == 0)
                      ? Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: Text(
                            "Aucun commentaire trouvé",
                            style: themeData.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: FontWeight.w500, ),//xMuted: true),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(top: MySize.size24),
                          itemCount: listCommentaires.length,
                          itemBuilder: (context, index) {
                            PostCommentModel itemComment =
                                listCommentaires[index];
                            DateTime _createdDate =
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(itemComment.created_at!.seconds) *
                                        1000);
                            return singleComment(itemComment,
                                createdAt:
                                    "${DateFormat('dd MMM yyyy, HH:mm').format(_createdDate)}");
                          },
                        ),
            ))
          ],
        ));
  }

  void checkCommentForm(BuildContext buildContext) {
    if (_formEventKey.currentState!.validate()) {
      print("$TAG:checkEventForm all is OK");
      saveComment(buildContext);
    }
  }

  void saveComment(BuildContext buildContext) async {
    setState(() {
      _isPostCommenting = true;
    });

    PostCommentModel comment = new PostCommentModel();
    comment.content = commentCtrler.text;
    comment.id_evenements = widget.postModel.id_evenements;
    comment.id_posts = widget.postModel.id_posts;
    comment.id_users = widget.userId;

    API.createPostComment(comment).then((responseEvent) async {
      print(
          "${TAG}:saveComment:createPostComment responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        PostModel postCreated = new PostModel.fromJson(responseEvent.data);

        _sendAnalyticsEvent("EventPostAddComent");
        setState(() {
          _isPostCommenting = false;
        });
        //
        DikoubaUtils.toast_success(
            buildContext, "Commentaire enregistré avec succés");
        _formEventKey.currentState!.reset();
        commentCtrler.clear();
        // commentCtrler.text = "";
        findPostComents();
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible d'enregistrer le commentaire");
        setState(() {
          _isPostCommenting = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isPostCommenting = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      debugPrint("${TAG}:createAnnoncer catchError ${errorLogin}");
      debugPrint(
          "${TAG}:createAnnoncer catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
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

  Widget singleComment(PostCommentModel commentModel, {required String createdAt}) {
    String image = commentModel.users!.photo_url!;
    return Container(
      margin: EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              gotoUserItemProfile(commentModel.users!);
            },
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child:  (image == "" || image == "null")
                    ? Image(
                  image: AssetImage('./assets/logo/user_transparent.webp'),
                  fit: BoxFit.cover,
                  width: MySize.size52,
                  height: MySize.size52,
                ):
                Image(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  width: MySize.size52,
                  height: MySize.size52,
                )),
          ),
          Expanded(
            child: Container(
              margin: Spacing.left(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${commentModel.users!.name}",
                    style: themeData.textTheme.bodyMedium?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: MySize.size4,
                  ),
                  Text(
                    "${commentModel.content}",
                    style: themeData.textTheme.bodyMedium?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "$createdAt",
                    style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
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

  void findPostComents() async {
    setState(() {
      _isFinding = true;
    });
    API
        .findPostCommentsEvent(
            widget.postModel.id_evenements!, widget.postModel.id_posts!)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findPostComents ${responseEvents.statusCode}|${responseEvents.data}");
        List<PostCommentModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(PostCommentModel.fromJson(responseEvents.data[i]));
        }
        if (!mounted) return;
        setState(() {
          _isFinding = false;
          listCommentaires = list;
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
