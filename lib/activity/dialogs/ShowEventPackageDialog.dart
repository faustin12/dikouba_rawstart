import 'package:dikouba_rawstart/activity/dialogs/ProceedPaymentPackageDialog.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

class ShowEventPackageDialog extends StatefulWidget {
  List<PackageModel> listPackage;
  EvenementModel evenement;
  ThemeData themeData;

  ShowEventPackageDialog(this.listPackage, this.evenement, this.themeData,
      {required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  ShowEventPackageDialogState createState() => ShowEventPackageDialogState();
}

class ShowEventPackageDialogState extends State<ShowEventPackageDialog> {
  bool _isFinding = false;

  Future<void> _setCurrentScreen() async {
    await widget.analytics?.setCurrentScreen(
      screenName: "ShowEventPackageDialog",
      screenClassOverride: "ShowEventPackageDialog",
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
      /*appBar: new AppBar(
        title: Text("Liste des Packages ${widget.listPackage.length}",
            style: themeData.appBarTheme.textTheme.headline6),
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
      ),*/
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
            top: MySize.size8,
            bottom: MySize.size8,
            left: MySize.size12,
            right: MySize.size12),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return SizedBox(
              height: MySize.size14,
            );
          },
          padding: EdgeInsets.only(top: MySize.size24),
          itemCount: widget.listPackage.length,
          itemBuilder: (context, index) {
            PackageModel itemPck = widget.listPackage[index];
            return singlePackage(itemPck,
                name: "${itemPck.name}", price: "${itemPck.price}");
          },
        ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    Navigator.of(buildContext).pop();
  }

  Widget singlePackage(PackageModel package, {required String name, required String price}) {
    return Container(
      padding:
          Spacing.symmetric(horizontal: MySize.size16, vertical: MySize.size14),
      decoration: BoxDecoration(
          border: Border.all(
              color:
                  int.parse(price ?? '0') == 0 ? Colors.green : Colors.blueAccent,
              width: 2),
          borderRadius: BorderRadius.all(Radius.circular(MySize.size14))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name",
                  style: widget.themeData.textTheme.titleLarge?.copyWith(
                      color: widget.themeData.colorScheme.secondary,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  DikoubaUtils.formatCurrencyWithDevise(price),
                  style: widget.themeData.textTheme.bodyMedium?.copyWith(
                      color: widget.themeData.colorScheme.error,
                      fontWeight: FontWeight.w500, )//muted: true),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              _sendAnalyticsEvent("PressBuyTicket");
              showPaymentDialog(package);
            },
            child: Container(
              padding: Spacing.fromLTRB(8, 8, 8, 8),
              decoration: BoxDecoration(
                  color: DikoubaColors.blue['pri'],
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size40))),
              child: Container(
                margin: Spacing.left(12),
                child: Text(
                  "Acheter ",
                  style: widget.themeData.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      letterSpacing: 0.7,
                      color: widget.themeData.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showPaymentDialog(PackageModel packageModel) async {
    var resProceedPay = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (BuildContext context, _, __) =>
            ProceedPaymentPackageDialog(
              packageModel,
              widget.evenement,
              widget.themeData,
              analytics: widget.analytics,
              observer: widget.observer,
            )));
    debugPrint("addSondageReponse: ${resProceedPay}");

    // if (resProceedPay != null) {
    // SondageReponseModel itemPackage =
    //     SondageReponseModel.fromJson(json.decode(resAddPackage));
    // setState(() {
    //   _listReponsesSdge.add(itemPackage);
    // });
    // }
  }
}
