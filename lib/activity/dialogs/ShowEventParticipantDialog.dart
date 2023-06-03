import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/activity/user/useriteminfo_activity.dart';
import 'package:dikouba/model/participant_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShowEventParticipantDialog extends StatefulWidget {
  List<ParticipantModel> listParticipant;
  ThemeData themeData;
  UserModel userModel;

  ShowEventParticipantDialog(
      this.listParticipant, this.userModel, this.themeData,
      {this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _ShowEventParticipantDialogState createState() =>
      _ShowEventParticipantDialogState();
}

class _ShowEventParticipantDialogState
    extends State<ShowEventParticipantDialog> {
  bool _isFinding = false;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "_ShowEventParticipantDialog",
      screenClassOverride: "_ShowEventParticipantDialog",
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
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Liste des participants",
            style: themeData.appBarTheme.textTheme.headline6),
        /*actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Material(
                child: InkWell(
                    onTap: () {
                      saveForm(context);
                    },
                    child: Icon(MdiIcons.check))),
          )
        ],*/
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 6, right: 6),
        child: ListView.builder(
          padding: EdgeInsets.only(top: MySize.size24),
          itemCount: widget.listParticipant.length,
          itemBuilder: (context, index) {
            ParticipantModel itemPant = widget.listParticipant[index];
            DateTime _createdDate = DateTime.fromMillisecondsSinceEpoch(
                int.parse(itemPant.created_at.seconds) * 1000);
            return singleParticipant(itemPant.users,
                name: "${itemPant.users.name}",
                image: "${itemPant.users.photo_url}",
                status:
                    "${DateFormat('dd MMM yyyy, HH:mm').format(_createdDate)}");
          },
        ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    Navigator.of(buildContext).pop();
  }

  void gotoUserItemProfile(UserModel userModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserItemInfoActivity(
                  widget.userModel,
                  userModel,
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
  }

  Widget singleParticipant(UserModel userModel,
      {String image, String name, String status}) {
    return InkWell(
      onTap: () {
        gotoUserItemProfile(userModel);
      },
      child: Container(
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child: Image(
                  image: (image == "" || image == "null")
                      ? AssetImage('./assets/logo/user_transparent.webp')
                      : NetworkImage(image),
                  fit: BoxFit.cover,
                  width: MySize.size40,
                  height: MySize.size40,
                )),
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$name",
                      style: AppTheme.getTextStyle(
                          widget.themeData.textTheme.bodyText2,
                          color: widget.themeData.colorScheme.onBackground,
                          fontWeight: 600),
                    ),
                    Text(
                      "$status",
                      style: AppTheme.getTextStyle(
                          widget.themeData.textTheme.caption,
                          color: widget.themeData.colorScheme.onBackground,
                          fontWeight: 500,
                          muted: true),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: Spacing.fromLTRB(8, 8, 8, 8),
              decoration: BoxDecoration(
                color: DikoubaColors.blue['pri'].withAlpha(40),
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
              ),
              child: Icon(
                MdiIcons.chevronRight,
                size: MySize.size24,
                color: DikoubaColors.blue['pri'],
              ),
            )
          ],
        ),
      ),
    );
  }
}
