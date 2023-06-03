import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/model/evenement_model.dart';
import 'package:dikouba/model/participant_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/Generator.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import './ShowEventParticipantDialog.dart';

class ShowEventParticipantWidget extends StatefulWidget {
  EvenementModel evenementModel;
  CustomAppTheme customAppTheme;
  UserModel userModel;

  ShowEventParticipantWidget(
      this.evenementModel, this.userModel, this.customAppTheme,
      {this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  ShowEventParticipantWidgetState createState() =>
      ShowEventParticipantWidgetState();
}

class ShowEventParticipantWidgetState
    extends State<ShowEventParticipantWidget> {
  final int MAXPROFILE = 5;

  bool _isParticipantFinding = false;
  List<ParticipantModel> _listParticipant = [];
  List<String> _listParticipantProfile = [];
  ThemeData themeData;

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "ShowEventParticipantWidget",
      screenClassOverride: "ShowEventParticipantWidget",
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
    findEventsParticiapnts();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Container(
      margin: Spacing.fromLTRB(0, 16, 0, 0),
      child: _isParticipantFinding
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']),
              ),
            )
          : InkWell(
              onTap: () {
                showEventParticipantDialog();
              },
              child: Row(
                children: [
                  Generator.buildOverlaysProfile(
                      images: _listParticipantProfile,
                      size: MySize.size36,
                      leftFraction: 0.7,
                      overlayBorderThickness: 2.5,
                      enabledOverlayBorder: true,
                      overlayBorderColor: widget.customAppTheme.bgLayer1),
                  Container(
                    child: Text(
                      "+${_listParticipant.length - _listParticipantProfile.length} participants",
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          color: themeData.colorScheme.primary,
                          fontWeight: 500),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void findEventsParticiapnts() async {
    setState(() {
      _isParticipantFinding = true;
    });
    API
        .findEventParticipant(widget.evenementModel.id_evenements)
        .then((responseParticipant) {
      if (responseParticipant.statusCode == 200) {
        print(
            "findEventsParticiapnts ${responseParticipant.statusCode}|${responseParticipant.data}");
        List<ParticipantModel> list = [];
        List<String> listProfil = [];
        for (int i = 0; i < responseParticipant.data.length; i++) {
          ParticipantModel papantMdl =
              ParticipantModel.fromJson(responseParticipant.data[i]);
          list.add(papantMdl);
          if (i < MAXPROFILE) {
            if (papantMdl.users.photo_url == null ||
                papantMdl.users.photo_url == '') {
              listProfil.add('./assets/logo/user_transparent.webp');
            } else {
              listProfil.add(papantMdl.users.photo_url);
            }
          }
        }

        if (!mounted) return;
        setState(() {
          _isParticipantFinding = false;
          _listParticipant = list;
          _listParticipantProfile = listProfil;
        });
      } else {
        print(
            "findEventsParticiapnts no data ${responseParticipant.toString()}");
        if (!mounted) return;
        setState(() {
          _isParticipantFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("findEventsParticiapnts errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isParticipantFinding = false;
      });
    });
  }

  void showEventParticipantDialog() async {
    var resAddPackage = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            ShowEventParticipantDialog(
              _listParticipant,
              widget.userModel,
              themeData,
              analytics: widget.analytics,
              observer: widget.observer,
            )));
    print("showEventParticipantDialog: ${resAddPackage}");
  }
}
