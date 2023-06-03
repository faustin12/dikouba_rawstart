import 'dart:convert';
import 'dart:io';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/model/annoncer_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:geocoder/geocoder.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';


class EventScanTicketScreen extends StatefulWidget {
  UserModel userModel;
  EventScanTicketScreen(this.userModel,{required this.analytics, required this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventScanTicketScreenState createState() => _EventScanTicketScreenState();
}

class _EventScanTicketScreenState extends State<EventScanTicketScreen> {
  static final String TAG = 'EventScanTicketScreen';
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  int selectedCategory = 0;

  bool _isEventFinding = false;
  List<EvenementModel> _listEvents = [];

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventUpcomingScreen",
      screenClassOverride: "EventUpcomingScreen",
    );
  }
  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics.instance.setUserId(id: uid);
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await FirebaseAnalytics.instance.logEvent(
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
    findMyEvents();
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
                body: Container(
                  color: customAppTheme.bgLayer1,
                  child: _isEventFinding
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DikoubaColors.blue['pri']!),),)
                      : (_listEvents == null || _listEvents.length == 0)
                      ? Container(
                    margin: Spacing.fromLTRB(24, 16, 24, 0),
                    child: Text("Aucun évènement trouvé",
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: themeData.colorScheme.onBackground,
                        fontWeight: FontWeight.w500,
                        fontSize: 12
                      ),/*AppTheme.getTextStyle(
                          themeData.textTheme.caption,
                          fontSize: 12,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 500,
                          xMuted: true),*/),)
                      : ListView.separated(
                    padding: Spacing.zero,
                    itemCount: _listEvents.length,
                    separatorBuilder: (context, index) {
                      return Container(
                        margin: Spacing.horizontal(16),
                        child: Divider(
                          height: 4,
                          color:
                          Theme.of(context).hintColor.withOpacity(0.1),
                        ),
                      );
                    },
                    itemBuilder: (BuildContext buildcontext, int indexCateg){
                      return _singleEvent(_listEvents[indexCateg]);
                    },
                  ),
                )));
      },
    );
  }

  Widget _singleEvent(EvenementModel evenementModel){
    return Container(
        margin: Spacing.symmetric(horizontal: 2, vertical: 2), //24 & 6
        child: SingleEventsWidget(
            customAppTheme,
            evenementModel,
            width: MySize.safeWidth - MySize.size48, analytics: widget.analytics, observer: widget.observer,)
    );
  }

  void findMyEvents() async {
    setState(() {
      _isEventFinding = true;
    });

    AnnoncerModel annoncerModel = AnnoncerModel.fromJson({
      "id_annoncers" : widget.userModel.id_annoncers,
      "id_users" : widget.userModel.id_users,
      "compagny" : widget.userModel.annoncer_compagny,
      "created_at" : widget.userModel.annoncer_created_at,
      "updated_at" : widget.userModel.annoncer_updated_at,
      "picture_path" : widget.userModel.annoncer_picture_path,
      "cover_picture_path" : widget.userModel.annoncer_cover_picture_path,
      "checkout_phone_number" : widget.userModel.annoncer_checkout_phone_number});

    API.createAnnoncer(annoncerModel).then((responseAnnoncer) {
      if (responseAnnoncer.statusCode == 200) {
        print(
            "${TAG}:findAnnoncer ${responseAnnoncer
                .statusCode}|${responseAnnoncer.data}");
        List<String> listIDevent = [];
        for (int i = 0; i <
            responseAnnoncer.data["arr_evenements"].length; i++) {
          listIDevent.add(
              responseAnnoncer.data["arr_evenements"][i].toString());
        };

        //find all invitations

        API.findInvitationsUserTagStatut(
            widget.userModel.id_users, "received", "accepted").then((
            responseInvitation) {
          if (responseInvitation.statusCode == 200) {
            print(
                "${TAG}:findInvitation ${responseInvitation
                    .statusCode}|${responseInvitation.data}");
            for (int i = 0; i < responseInvitation.data.length; i++) {
              listIDevent.add(
                  responseInvitation.data[i]["id_evenements"].toString());
            };

            API.findAllSession(listIDevent).then((responseEvents) {
              if (responseEvents.statusCode == 200) {
                print(
                    "${TAG}:findMyevent ${responseEvents
                        .statusCode}|${responseEvents.data}");
                List<EvenementModel> list = [];
                for (int i = 0; i < responseEvents.data.length; i++) {
                  list.add(EvenementModel.fromJson(responseEvents.data[i]));
                }

                if (!mounted) return;
                setState(() {
                  _isEventFinding = false;
                  _listEvents = list;
                });
              } else {
                print(
                    "${TAG}:findMyevent no data ${responseEvents.toString()}");

                if (!mounted) return;
                setState(() {
                  _isEventFinding = false;
                });
              }
            }).catchError((errWalletAddr) {
              print("${TAG}:findMyevent errorinfo ${errWalletAddr.toString()}");

              if (!mounted) return;
              setState(() {
                _isEventFinding = false;
              });
            });
          } else {
            print(
                "${TAG}:findInvitation no data ${responseInvitation.toString()}");

            if (!mounted) return;
            setState(() {
              _isEventFinding = false;
            });
          }
        }).catchError((errWalletAddr) {
          print(
              "${TAG}:findInvitation errorinfo ${errWalletAddr.toString()}");

          if (!mounted) return;
          setState(() {
            _isEventFinding = false;
          });
        });
      }else {
        print(
            "${TAG}:findAnnoncer no data ${responseAnnoncer.toString()}");

        if (!mounted) return;
        setState(() {
          _isEventFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print(
          "${TAG}:findAnnoncer errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isEventFinding = false;
      });
    });
  }

}


class SingleEventsWidget extends StatefulWidget {
  CustomAppTheme customAppTheme;
  EvenementModel evenementModel;
  @required
  double width;
  SingleEventsWidget(this.customAppTheme, this.evenementModel,
      {required this.width,
        required this.analytics,
        required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  SingleEventsWidgetState createState() => SingleEventsWidgetState();
}


class SingleEventsWidgetState extends State<SingleEventsWidget> {
  static final String TAG = 'SingleEventsWidgetState';

  late ThemeData themeData;

  String _eventLocationAddress = "loading";

  Future<void> getPositionInfo() async {
    final coordinates = new Coordinates(
        double.parse(widget.evenementModel.location!.latitude),
        double.parse(widget.evenementModel.location!.longitude));
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _eventLocationAddress = first.addressLine;
    });
  }

  @override
  void initState() {
    super.initState();
    getPositionInfo();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    var _id = widget.evenementModel.id_evenements;

    return Container(
        margin:
        Spacing.symmetric(horizontal: MySize.size0, vertical: MySize.size0), //12 & 8
        child: Padding(
          padding: const EdgeInsets.only(top: 2.0, bottom: 0.0), //20 instead of 2
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    QRViewExample(widget.evenementModel,
                      themeData,
                      widget.customAppTheme,
                    )));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0), //15 each
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12.withOpacity(0.2),
                            spreadRadius: 3.0,
                            blurRadius: 10.0)
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Hero(
                        tag: 'hero-tag-list-$_id',
                        child: Material(
                          child: Container(
                            height: 165.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(widget.evenementModel.banner_path), fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0)),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.only(top: 10.0, right: 10.0),
                              child: InkWell(
                                onTap: () {
                                  //
                                },
                                /*child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.black38,
                                    )),*/
                              ),
                            ),
                            alignment: Alignment.topRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 13.0, top: 7.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            Text(
                              widget.evenementModel.title!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17.0,
                                  fontFamily: "Popins"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Icon(
                                      Icons.place,
                                      color: Colors.black38,
                                      size: 17.0,
                                    ),
                                    Container(
                                        width: 120.0,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              _eventLocationAddress,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: "popins",
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black38),
                                              overflow: TextOverflow.ellipsis,
                                            )))
                                  ]),
                                  Row(children: <Widget>[
                                    Icon(
                                      Icons.timer,
                                      color: Colors.black38,
                                      size: 17.0,
                                    ),
                                    Container(
                                        width: 140.0,
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            DateFormat('dd MMM yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(widget.evenementModel.start_date!.seconds) * 1000)),
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontFamily: "popins",
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black38),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                ,
              )
          )
          ,
        )
    );
  }
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;
  bool _checkingData = false;
  bool _isPackageFinding = false;
  List<PackageModel> _listPackage = [];

  void findEventsPackage() async {
    setState(() {
      _isPackageFinding = true;
    });
    API
        .findEventPackage(widget._evenement.id_evenements!)
        .then((responsePackage) {
      if (responsePackage.statusCode == 200) {
        print(
            "findEventPackages ${responsePackage.statusCode}|${responsePackage.data}");
        List<PackageModel> list = [];
        for (int i = 0; i < responsePackage.data.length; i++) {
          PackageModel packageModelgetMdl =
          PackageModel.fromJson(responsePackage.data[i]);
          list.add(packageModelgetMdl);
        }
        if (!mounted) return;
        setState(() {
          _isPackageFinding = false;
          _listPackage = list;
        });
      } else {
        print("findEventPackages no data ${responsePackage.toString()}");
        if (!mounted) return;
        setState(() {
          _isPackageFinding = false;
        });
      }
    }).catchError((errWalletAddr) {
      print("findEventPackages errorinfo ${errWalletAddr.toString()}");

      if (!mounted) return;
      setState(() {
        _isPackageFinding = false;
      });
    });
  }

  Future<void> _checkResults(Barcode readedBarcode) async{
    _checkingData = true;
    String scanned_id_users = "";
    String scanned_id_tickets = "";
    String scanned_id_evenements = "";
    String scanned_id_packages = "";
    bool _goodTicket = false;
    String _labelValue = "Bad ticket";

    void showDialogResult (bool result, String _label){
      showDialog(
          context: context,
          barrierColor: Color(0x00ffffff),
          builder: (BuildContext context) =>
              Dialog(
                  backgroundColor: Color(0x00ffffff),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          //margin: EdgeInsets.all(100.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: result ? Colors.blueAccent : Colors.redAccent,
                                shape: BoxShape.circle
                            ),
                            child: Expanded(
                              child: new FittedBox(
                                fit: BoxFit.fill,
                                child: new Icon(
                                  result ? Icons.check : Icons.close,
                                  color: Colors.white,
                                ),
                              ),)
                        ),
                        Container(
                          //color: Colors.white,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: Spacing.fromLTRB(MySize.size16, MySize.size8, MySize.size18, 0),
                                    child: Text(
                                      widget._evenement.title!,
                                      maxLines: 1,
                                      style: widget._themeData.textTheme.headlineMedium?.copyWith(
                                        color: result? Colors.blueAccent : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: Spacing.fromLTRB(MySize.size16, MySize.size8, MySize.size18, 0),
                                    child: Text(
                                      _label,
                                      maxLines: 1,
                                      style: widget._themeData.textTheme.headlineMedium?.copyWith(
                                        color: result? Colors.blueAccent : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),]))
                      ]))).then((value) => _checkingData = false);
      //_checkingData = false;
    }

    try {
      scanned_id_users = jsonDecode(readedBarcode.code!)["id_users"];
      scanned_id_tickets = jsonDecode(readedBarcode.code!)["id_tickets"];
      scanned_id_evenements = jsonDecode(readedBarcode.code!)["id_evenements"];
      scanned_id_packages = jsonDecode(readedBarcode.code!)["id_packages"];
    } on Exception catch (_) {
      print('never reached');
    }
    API.scanTicketsUsers(scanned_id_users, scanned_id_tickets)
        .then((responsePackage) {
      if (responsePackage.statusCode == 200) {
        print(
            "scanTicketsUsers ${responsePackage.statusCode}|${responsePackage.data}");

        _goodTicket = (responsePackage.data["id_evenements"] == widget._evenement.id_evenements &&
            ( responsePackage.data["statut"] == "COMPLETE"|| responsePackage.data["statut"] == "COMPLETED"));
        _labelValue = "Check ticket ?";
        for(int idx=0; idx<_listPackage.length; idx++){
          if(_listPackage[idx].id_packages == responsePackage.data["id_packages"]) _labelValue = "Package : " + _listPackage[idx].name!;
        }
        showDialogResult(_goodTicket, _labelValue);
      } else {
        print("scanTicketsUsers no data ${responsePackage.toString()}");
        showDialogResult(false, "Ticket not found");
      }
    }).catchError((errWalletAddr) {
      print("scanTicketsUsers errorinfo ${errWalletAddr.toString()}");
      showDialogResult(false, _labelValue);
    });

  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: DikoubaColors.blue['pri']!,
                borderRadius: 10,
                borderLength: 20,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width*0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    findEventsPackage();
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(!_checkingData) _checkResults(scanData).then((value) => setState(() {
        result = scanData;
      }));
      /*setState(() {
        result = scanData;
      });*/
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class QRViewExample extends StatefulWidget {
  EvenementModel _evenement;
  ThemeData _themeData;
  CustomAppTheme _customAppTheme;
  QRViewExample(this._evenement, this._themeData, this._customAppTheme);

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}



