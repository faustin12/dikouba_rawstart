import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/activity/user/useriteminfo_activity.dart';
import 'package:dikouba/model/evenement_model.dart';
import 'package:dikouba/model/evenementcomment_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShowEventCommentsDialog extends StatefulWidget {
  ThemeData themeData;
  UserModel userModel;
  EvenementModel evenementModel;

  ShowEventCommentsDialog(this.evenementModel, this.userModel, this.themeData);

  @override
  ShowEventCommentsDialogState createState() => ShowEventCommentsDialogState();
}

class ShowEventCommentsDialogState extends State<ShowEventCommentsDialog> {
  static final String TAG = 'ShowEventCommentsDialogState';
  bool _isFinding = false;
  bool _isAdding = false;
  List<EvenementCommentModel> _listComment = [];

  TextEditingController commentCtrler;

  @override
  void initState() {
    super.initState();

    commentCtrler = new TextEditingController();

    findEventsComment();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      /*appBar: new AppBar(
        title: Text("Commentaires",
            style: themeData.appBarTheme.textTheme.headline6),
        leading: IconButton(
          icon: Icon(MdiIcons.arrowLeft),
          onPressed: () {
            saveForm(context);
          },
        ),
      ),*/
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
        child: _isFinding
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),
                ),
              )
            : Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.black12.withOpacity(0.01),
                    child: _listComment.length == 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MdiIcons.networkOff,
                                size: MySize.size68,
                                color: themeData.colorScheme.secondary,
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Text(
                                  "Aucun commentaire disponible ou erreur réseau.",
                                  textAlign: TextAlign.center,
                                  style:
                                      themeData.appBarTheme.textTheme.headline6)
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                vertical: MySize.size14,
                                horizontal: MySize.size14),
                            itemCount: _listComment.length,
                            itemBuilder: (context, index) {
                              EvenementCommentModel item = _listComment[index];

                              return singleComment(item);
                            },
                          ),
                  )),
                  Card(
                    elevation: 8,
                    margin: EdgeInsets.all(0),
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 6, right: 0, top: 6, bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Veuillez saisir le commentaire';
                                }
                                return null;
                              },
                              controller: commentCtrler,
                              keyboardType: TextInputType.multiline,
                              minLines: 2,
                              maxLines: 3,
                              style: TextStyle(
                                  fontFamily: "WorkSofiaSemiBold",
                                  fontSize: 16.0,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                isDense: true,
                                hintText: "Entrer votre commentaire",
                                hintStyle: TextStyle(
                                    fontFamily: "Sofia", fontSize: 16.0),
                              ),
                            ),
                          ),
                          _isAdding
                              ? TextButton.icon(
                                  onPressed: null,
                                  icon: Icon(
                                    MdiIcons.send,
                                  ),
                                  label: Text(''))
                              : TextButton.icon(
                                  onPressed: () {
                                    addEventsComment();
                                  },
                                  icon: Icon(
                                    MdiIcons.send,
                                    color: DikoubaColors.blue['pri'],
                                  ),
                                  label: Text(''))
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    Navigator.of(buildContext).pop(_listComment.length);
  }

  void gotoUserItemProfile(UserModel userModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserItemInfoActivity(widget.userModel, userModel)));
  }

  void findEventsComment() async {
    setState(() {
      _isFinding = true;
    });
    API
        .findEventComments(widget.evenementModel.id_evenements)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findEventComments ${responseEvents.statusCode}|${responseEvents.data}");
        List<EvenementCommentModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          EvenementCommentModel item =
              EvenementCommentModel.fromJson(responseEvents.data[i]);
          print(
              "${TAG}:findEventComments $i => ${item.id_comments}|${item.content}");
          list.add(item);
        }

        if (!mounted) return;
        setState(() {
          _isFinding = false;
          _listComment = list;
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isFinding = false;
      });
    });
  }

  void addEventsComment() async {
    String comment = commentCtrler.text;
    if (comment.isEmpty) return;

    setState(() {
      _isAdding = true;
    });
    API
        .addEventComment(widget.evenementModel.id_evenements,
            widget.userModel.id_users, comment)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:findEventComments ${responseEvents.statusCode}|${responseEvents.data}");
        EvenementCommentModel commentModel =
            EvenementCommentModel.fromJson(responseEvents.data);
        commentModel.users = widget.userModel;

        if (!mounted) return;
        setState(() {
          _isAdding = false;
          commentCtrler.text = '';
          _listComment.insert(0, commentModel);
        });
      } else {
        print("${TAG}:findOperations no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isAdding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:infoCustomerBankAccount errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isAdding = false;
      });
    });
  }

  Widget singleComment(EvenementCommentModel commentModel) {
    DateTime _createdDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(commentModel.created_at.seconds) * 1000);

    return InkWell(
      onTap: () {
        gotoUserItemProfile(commentModel.users);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child: Image(
                  image: (commentModel.users.photo_url == "" ||
                          commentModel.users.photo_url == "null")
                      ? AssetImage('./assets/logo/user_transparent.webp')
                      : NetworkImage(commentModel.users.photo_url),
                  fit: BoxFit.cover,
                  width: MySize.size60,
                  height: MySize.size60,
                )),
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${commentModel.users.name}",
                      style: AppTheme.getTextStyle(
                          widget.themeData.textTheme.bodyText2,
                          color: widget.themeData.colorScheme.onBackground,
                          fontWeight: 600),
                    ),
                    Text(
                      "${DateFormat('dd MMM, HH:mm').format(_createdDate)}",
                      style: AppTheme.getTextStyle(
                          widget.themeData.textTheme.caption,
                          color: widget.themeData.colorScheme.onBackground,
                          fontWeight: 300,
                          muted: true),
                    ),
                    Text(
                      "${commentModel.content}",
                      style: AppTheme.getTextStyle(
                          widget.themeData.textTheme.caption,
                          color: widget.themeData.colorScheme.onBackground,
                          fontSize: 16,
                          fontWeight: 500,
                          muted: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
