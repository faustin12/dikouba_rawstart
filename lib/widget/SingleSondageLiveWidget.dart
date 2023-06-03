import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/sondagereponse_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SingleSondageLiveWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  SondageModel sondageModel;
  UserModel userModel;

  @required
  double width;
  SingleSondageLiveWidget(
      this.customAppTheme, this.sondageModel, this.userModel, this.width);

  @override
  SingleSondageLiveWidgetState createState() => SingleSondageLiveWidgetState();
}

class SingleSondageLiveWidgetState extends State<SingleSondageLiveWidget> {
  static final String TAG = 'SingleSondageWidgetState';

  late ThemeData themeData;

  bool _isDetailsFinding = false;
  bool _isVoting = false;
  bool _hasVote = false;
  late String _idReponseVotre;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();

    findDetailSondage();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => EvenDetailsActivity(widget.evenementModel)));
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: widget.customAppTheme.bgLayer1,
            border:
                Border.all(color: widget.customAppTheme.bgLayer3, width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MySize.size8, vertical: MySize.size6),
                  color: themeData.primaryColor,
                  child: Text(
                    "${widget.sondageModel.evenements.title == null ? '' : widget.sondageModel.evenements.title}",
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.cardColor, fontWeight: FontWeight.w600),//AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        //color: themeData.cardColor, fontWeight: 600),
                  ),
                ))
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MySize.size8, vertical: MySize.size6),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                      child: (widget.sondageModel.evenements.banner_path == "" || widget.sondageModel.evenements.banner_path == null)
                          ?
                      Image(image: AssetImage('./assets/logo/noimage.webp'),
                        fit: BoxFit.cover,
                        width: MySize.size40,
                        height: MySize.size40,
                      ) :
                      Image(image: NetworkImage(widget.sondageModel.evenements.banner_path),
                        fit: BoxFit.cover,
                        width: MySize.size40,
                        height: MySize.size40,
                      )),
                  Expanded(
                      child: Container(
                    margin: Spacing.left(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.sondageModel.title}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w600),//AppTheme.getTextStyle(
                              //themeData.textTheme.bodyText2,
                              //color: themeData.colorScheme.onBackground,
                              //fontWeight: 600),
                        ),
                        Text(
                          "Par ${widget.sondageModel.annoncers?.compagny == null ? '' : widget.sondageModel.annoncers?.compagny}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w500),//AppTheme.getTextStyle(
                              //themeData.textTheme.caption,
                              //color: themeData.colorScheme.onBackground,
                              //fontWeight: 500,
                              //muted: true),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MySize.size8, vertical: MySize.size6),
              child: Text(
                "${widget.sondageModel.description}",
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onBackground, fontWeight: FontWeight.w600),//AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    //color: themeData.colorScheme.onBackground, fontWeight: 600),
              ),
            ),
            Container(
                child: _isDetailsFinding
                    ? Center(
                        child: Container(
                        width: MySize.size32,
                        height: MySize.size32,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              DikoubaColors.blue['pri']!),
                        ),
                      ))
                    : widget.sondageModel.reponses == null
                        ? Container()
                        : _hasVote ||
                                widget.userModel.id_annoncers ==
                                    widget.sondageModel.id_annoncers
                            ? ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Container(
                                    color: widget.customAppTheme.bgLayer1,
                                    height: 2,
                                  );
                                },
                                itemCount: widget.sondageModel.reponses.length,
                                itemBuilder: (context, index) {
                                  double percent = _total == 0 ? 0 : double.parse(widget.sondageModel.reponses[index].nombre_vote) / _total;
                                  return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MySize.size8,
                                          vertical: MySize.size6),
                                      child: LinearPercentIndicator(
                                        animation: true,
                                        lineHeight: 20.0,
                                        animationDuration: 2000,
                                        percent: percent,
                                        backgroundColor: Colors.black12,
                                        center: Text(
                                            "${index + 1}. ${widget.sondageModel.reponses[index].description} - ${(percent * 100).toStringAsFixed(2)}%",
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: themeData.textTheme.bodyMedium?.
                                                copyWith(color: Colors.black87, fontWeight: widget.sondageModel.reponses[index].id_reponses == _idReponseVotre ? FontWeight.w600 : FontWeight.w400),//AppTheme.getTextStyle(
                                                //themeData.textTheme.bodyText2,
                                                //color: Colors.black87,
                                                //fontWeight: widget
                                                //            .sondageModel
                                                //            .reponses[index]
                                                //            .id_reponses ==
                                                //        _idReponseVotre
                                                //    ? 600
                                                //    : 400)
                                        ),
                                        linearStrokeCap:
                                            LinearStrokeCap.roundAll,
                                        progressColor:
                                            DikoubaColors.blue['pri'],
                                      ));
                                },
                              )
                            : SingleChildScrollView(
                                child: GridView.count(
                                  physics: ScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                      MySize.size8, 0, MySize.size8, 0),
                                  primary: false,
                                  childAspectRatio: 3,
                                  shrinkWrap: true,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  crossAxisCount: 2,
                                  // mainAxisCount:2,
                                  //scrollDirection: Axis.horizontal,
                                  children: List.generate(
                                      widget.sondageModel.reponses.length,
                                      (index) {
                                    return GestureDetector(
                                        onTap: () {
                                          if (_isVoting) return;
                                          addLigneSondage(widget
                                              .sondageModel.reponses[index]);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: widget
                                                  .customAppTheme.bgLayer1,
                                              border: Border.all(
                                                  color: widget
                                                      .customAppTheme.bgLayer3,
                                                  width: 0.8),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      MySize.size8))),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${index + 1}. ${widget.sondageModel.reponses[index].description}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: _isVoting
                                                  ? Colors.black54
                                                  : themeData.primaryColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ));
                                  }),
                                ),
                              )),
            SizedBox(
              height: MySize.size12,
            )
          ],
        ),
      ),
    );
  }

  void findDetailSondage() async {
    print("${TAG}:findDetailSondage");
    setState(() {
      _isDetailsFinding = true;
    });
    API.findSondageItem(widget.sondageModel.id_sondages).then((responseSdage) {
      if (responseSdage.statusCode == 200) {
        print(
            "${TAG}:findDetailSondage ${responseSdage.statusCode}|${responseSdage.data}");
        SondageModel sondageModel = SondageModel.fromJson(responseSdage.data);

        double total = 0;
        for (int i = 0; i < sondageModel.reponses.length; i++) {
          total += double.parse(sondageModel.reponses[i].nombre_vote);
          // print("${TAG}:findDetailSondage ${sondageModel.reponses.length} totalVoteValeur = ${sondageModel.reponses[i].nombre_vote}");
        }
        print(
            "${TAG}:findDetailSondage ${sondageModel.reponses.length} totalVote = $total");

        if (!mounted) return;
        setState(() {
          _isDetailsFinding = false;
          _total = total;
          widget.sondageModel = sondageModel;
          checkHasVote();
        });
      } else {
        print("${TAG}:findDetailSondage no data ${responseSdage.toString()}");
        setState(() {
          _isDetailsFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      setState(() {
        _isDetailsFinding = false;
      });
      print("${TAG}:findDetailSondage errorinfo ${errWalletAddr.toString()}");
    });
  }

  void checkHasVote() {
    bool hasVote = false;
    String? idReponseVotre;
    for (int i = 0; i < widget.sondageModel.reponsesusers!.length; i++) {
      if (widget.sondageModel.reponsesusers![i].id_users ==
          widget.userModel.id_users) {
        hasVote = true;
        idReponseVotre = widget.sondageModel.reponsesusers![i].id_reponses;
        break;
      }
    }

    setState(() {
      _hasVote = hasVote;
      _idReponseVotre = idReponseVotre!;
    });
  }

  void addLigneSondage(SondageReponseModel sondageReponseModel) async {
    setState(() {
      _isVoting = true;
    });
    API
        .addLigneSondage(
            sondageReponseModel.id_evenements,
            widget.userModel.id_users,
            sondageReponseModel.id_sondages,
            sondageReponseModel.id_reponses,
            sondageReponseModel.valeur)
        .then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "${TAG}:addLigneSondage ${responseEvents.statusCode}|${responseEvents.data}");

        if (!mounted) return;
        setState(() {
          _isVoting = false;
        });
        findDetailSondage();
      } else {
        print("${TAG}:addLigneSondage no data ${responseEvents.toString()}");
        if (!mounted) return;
        setState(() {
          _isVoting = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("${TAG}:addLigneSondage errorinfo ${errWalletAddr.toString()}");
      if (!mounted) return;
      setState(() {
        _isVoting = false;
      });
    });
  }
}
