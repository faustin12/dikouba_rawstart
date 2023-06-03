import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dikouba/AppTheme.dart';
import 'package:dikouba/AppThemeNotifier.dart';
import 'package:dikouba/activity/event/eventdetails_activity.dart';
import 'package:dikouba/fragment/EventHomeScreen.dart';
import 'package:dikouba/fragment/PaypalPayment_v2.dart';
import 'package:dikouba/model/evenement_model.dart';
import 'package:dikouba/model/package_model.dart';
import 'package:dikouba/model/sondagereponse_model.dart';
import 'package:dikouba/model/ticket_model.dart';
import 'package:dikouba/model/user_model.dart';
import 'package:dikouba/provider/api_provider.dart';
import 'package:dikouba/provider/paypal_service_v2.dart';
import 'package:dikouba/utils/DikoubaColors.dart';
import 'package:dikouba/utils/DikoubaUtils.dart';
import 'package:dikouba/utils/Generator.dart';
import 'package:dikouba/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:dikouba/utils/DashedDivider.dart';

import 'package:geocoder/geocoder.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
//import 'package:qrscan/qrscan.dart' as scanner;

class EventMesTicketsScreen extends StatefulWidget {
  UserModel userModel;
  EventMesTicketsScreen(this.userModel, {this.analytics, this.observer});
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _EventMesTicketsScreenState createState() => _EventMesTicketsScreenState();
}

class _EventMesTicketsScreenState extends State<EventMesTicketsScreen> {
  static final String TAG = '_EventSondagesScreenState';
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  bool _isFinding = false;
  List<TicketModel> _listTickets = [];

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: "EventMesTicketsScreen",
      screenClassOverride: "EventMesTicketsScreen",
    );
  }

  Future<void> _setUserId(String uid) async {
    await FirebaseAnalytics().setUserId(uid);
  }

  Future<void> _sendAnalyticsEvent(String name) async {
    await FirebaseAnalytics().logEvent(
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

  willRefresh(refresh) {
    if(refresh) findMesTickets();
  }

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    findMesTickets();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                body: Container(
              color: customAppTheme.bgLayer1,
              child: Column(
                children: [
                  Container(
                    margin: Spacing.fromLTRB(
                        MySize.size16, MySize.size8, MySize.size18, 0),
                    child: Text(
                      "Nombre de tickets ${_listTickets.length}",
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontSize: MySize.size14,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 500,
                          xMuted: true),
                    ),
                  ),
                  Expanded(
                      child: _isFinding
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DikoubaColors.blue['pri']),
                              ),
                            )
                          : (_listTickets == null || _listTickets.length == 0)
                              ? Container(
                                  margin: Spacing.fromLTRB(MySize.size16,
                                      MySize.size8, MySize.size18, 0),
                                  child: Text(
                                    "Aucun ticket trouvé",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.caption,
                                        fontSize: 12,
                                        color:
                                            themeData.colorScheme.onBackground,
                                        fontWeight: 500,
                                        xMuted: true),
                                  ),
                                )
                              : ListView.separated(
                                  padding: Spacing.vertical(24),
                                  itemCount: _listTickets.length,
                                  separatorBuilder: (context, index) {
                                    return Container(
                                      margin: Spacing.vertical(MySize.size3),
                                    );
                                  },
                                  itemBuilder:
                                      (BuildContext buildcontext, int idx) {
                                    return Container(
                                      margin: Spacing.horizontal(MySize.size10),
                                      child: singleTicket(_listTickets[idx]),
                                    );
                                  },
                                ))
                ],
              ),
            )));
      },
    );
  }

  Widget singleTicket(TicketModel ticketModel) {
    DateTime _startDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(ticketModel.created_at.seconds) * 1000);
    bool _goodTicket = false;
    return Container(
      margin:
          Spacing.symmetric(horizontal: MySize.size12, vertical: MySize.size8),
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  EventTicketDialog(ticketModel, willRefresh));
        },
        child: Row(
          children: [
            Container(
              padding: Spacing.fromLTRB(8, 4, 8, 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  border:
                      Border.all(color: customAppTheme.bgLayer3, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                        color: customAppTheme.shadowColor.withAlpha(150),
                        blurRadius: 1,
                        offset: Offset(0, 1))
                  ],
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size8))),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(_startDate),
                    style: AppTheme.getTextStyle(themeData.textTheme.headline6,
                        color: DikoubaColors.blue['pri'], fontWeight: 600),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('MMM').format(_startDate),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        color: DikoubaColors.blue['pri'], fontWeight: 600),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('HH:mm').format(_startDate),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: DikoubaColors.blue['pri'], fontWeight: 600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: Spacing.left(MySize.size10),
                color: (ticketModel.statut == "SUCCESSFULL" || ticketModel.statut == "COMPLETE" || ticketModel.statut == "COMPLETED")
                    ? Color.fromRGBO(0, 255, 0, 0.25) : Color.fromRGBO(255, 0, 0, 0.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                              ticketModel.evenements.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle2,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        )),
                        if (ticketModel.statut == "SUCCESSFULL" || ticketModel.statut == "COMPLETE" || ticketModel.statut == "COMPLETED")
                        InkWell(
                          onTap: ()async{

                            String scanned_id_users = "";
                            String scanned_id_tickets = "";
                            String scanned_id_evenements = "";
                            String scanned_id_packages = "";

                            //_goodTicket = ! _goodTicket;
                            //String scanResult =  await scanner.scan();

                            /*showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    QRViewExample(ticketModel));*/

                            /*FlutterBarcodeScanner.getBarcodeStreamReceiver("#ff6666", "Cancel", false, ScanMode.DEFAULT)
                                .listen((barcode) {
                              /// barcode to be used
                            });*/

                            //String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                            //    "#ff6666", "Cancel", true, ScanMode.DEFAULT);


                            /*var result = await BarcodeScanner.scan();
                            print("$TAG:checkTicket ${(result.rawContent)}");

                            try {
                              scanned_id_users = jsonDecode(result.rawContent)["id_users"];
                              scanned_id_tickets = jsonDecode(result.rawContent)["id_tickets"];
                              scanned_id_evenements = jsonDecode(result.rawContent)["id_evenements"];
                              scanned_id_packages = jsonDecode(result.rawContent)["id_packages"];
                            } on Exception catch (_) {
                              print('never reached');
                            }*/

                            print("$TAG:checkedId ${scanned_id_users} | ${scanned_id_tickets} | ${scanned_id_evenements} | ${scanned_id_packages}");

                            _goodTicket = (scanned_id_evenements == ticketModel.evenements.id_evenements &&
                                scanned_id_tickets == ticketModel.id_tickets);
                             /*showDialog(
                                 context: context,
                                 builder: (BuildContext context) =>
                                     Dialog(
                                         shape: CircleBorder(),
                                         child: Container(
                                           width: MySize.safeWidth,
                                           child : Expanded(
                                               child: new FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: Column(
                                                    children :[
                                                  Icon(
                                                  _goodTicket
                                                  ? Icons.check
                                                      : Icons.close,
                                                    color: _goodTicket
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),]))))
                                     ));*/
                          },
                          child: Container(
                            padding: Spacing.all(6),
                            child: Icon(
                              MdiIcons.qrcode,
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(200),
                              size: MySize.size20,
                            ),
                          ),
                        ),
                        /*Text(
                          "N/A",
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.button,
                              fontSize: MySize.size12,
                              color:
                              themeData.colorScheme.onBackground),
                          textAlign: TextAlign.center,
                        ),*/
                      ],
                    ),
                    Container(
                      margin: Spacing.top(MySize.size8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Paiement",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    fontSize: MySize.size12,
                                    color: themeData.colorScheme.onBackground,
                                    xMuted: true),
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  ticketModel.payment_method == "null" ? (ticketModel.statut == "WAITING_PAYMENT" ? "PAYPAL" : "Free")
                                      : ticketModel.payment_method,
                                  maxLines: 1,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.button,
                                      fontSize: MySize.size12,
                                      color:
                                          themeData.colorScheme.onBackground),
                                ),
                              )
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Presence",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12,
                                    xMuted: true),
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  ticketModel.evenn_presence,
                                  maxLines: 1,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.button,
                                      fontSize: MySize.size12,
                                      color:
                                          themeData.colorScheme.onBackground),
                                ),
                              )
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Statut",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    color: themeData.colorScheme.onBackground,
                                    fontSize: MySize.size12,
                                    xMuted: true),
                              ),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                  ticketModel.statut,
                                  maxLines: 1,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.button,
                                      fontSize: MySize.size12,
                                      color:
                                          themeData.colorScheme.onBackground),
                                ),
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void findMesTickets() async {
    setState(() {
      _isFinding = true;
    });
    API.findTicketsUsers(widget.userModel.id_users).then((responseEvents) {
      if (responseEvents.statusCode == 200) {
        print(
            "$TAG:findMesTickets ${responseEvents.statusCode}|${responseEvents.data}");
        List<TicketModel> list = [];
        for (int i = 0; i < responseEvents.data.length; i++) {
          list.add(TicketModel.fromJson(responseEvents.data[i]));
        }

        if (!mounted) return;
        setState(() {
          _isFinding = false;
          _listTickets = list;
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
}

class EventTicketDialog extends StatefulWidget {
  TicketModel ticketModel;
  Function(bool) willRefresh;
  EventTicketDialog(this.ticketModel, this.willRefresh);

  @override
  _EventTicketDialogState createState() => _EventTicketDialogState();
}

class _EventTicketDialogState extends State<EventTicketDialog> {
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  int selectedCategory = 0;

  String _eventLocationAddress = "loading";

  String _paymentMethod = "Mobile Money";
  UserModel _userModel;

  List<String> _status = ["Mobile Money", "Paypal"];
  List<String> prefixOM = ["655", "656", "657", "658", "659", "690", "691", "692", "693", "694", "695", "696", "697", "698", "699"];
  List<String> prefixMOMO = ["650", "651", "652", "653", "654", "670", "671", "672", "673", "674", "675", "676", "677", "678", "679", "680", "681"];
  List<String> _buttonOMImageAsset = ['assets/images/momo-1.jpg','assets/images/om-1.jpg','assets/images/momo_om-1.jpg', 'assets/images/paypal-1.webp'];
  int _buttonOMImageIndex = 2;
  TextEditingController phoneCtrler;
  bool _isPaying = false;
  int checkStatusPaymentCount = 0;
  bool _isChecking = false;
  String _phonenumber ="";

  Timer timer;

  void _proceedPaymentPaypal(BuildContext buildContext, PackageModel packageModel) async {
    setState(() {
      _isPaying = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => //Webview()
        PaypalPaymentV2(packageModel,
          onFinish: (number) async {

            // payment done
            print('order_id: '+number);
            timer = Timer.periodic(
                Duration(seconds: 3),
                    (Timer t) =>
                    proceedCheckPapalPayment(buildContext, widget.ticketModel, number.toString()));

          },
        ),
      ),
    );

    setState(() {
      _isPaying = false;
    });

  }

  void proceedPayment(BuildContext buildContext) async {
    setState(() {
      _isPaying = true;
    });

    DikoubaUtils.toast_success(
        buildContext, "Ongoing " + phoneCtrler.text + " " + _userModel.id_users);

    API
        .retryMobilePay(
        idTickets: widget.ticketModel.id_tickets,
        idUser: _userModel.id_users,
        phoneNumber: phoneCtrler.text)
        .then((responseEvent) async {

      if (responseEvent.statusCode == 200) {
        DikoubaUtils.toast_success(
            buildContext, "Paiement ticket initié avec succés");

        timer = Timer.periodic(
            Duration(seconds: 3),
                (Timer t) =>
                proceedCheckStatusPayment(buildContext, widget.ticketModel));
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible d'effectuer le paiement du ticket");
        setState(() {
          _isPaying = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isPaying = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      return;
    });
  }

  void proceedCheckStatusPayment(BuildContext buildContext, TicketModel ticketCreated) async {
        setState(() {
          _isPaying = true;
        });

        API
            .checkTicketMobilePay(
            idTickets: ticketCreated.id_tickets, idUser: ticketCreated.id_users)
            .then((responseEvent) async {

          if (responseEvent.statusCode == 200) {
            TicketModel ticketChecked =
            new TicketModel.fromJson(responseEvent.data);

            if (ticketChecked.statut == "REQUEST_ACCEPTED" || ticketChecked.statut == "SUCCESSFULL") {
              setState(() {
                _isPaying = false;
              });
              DikoubaUtils.toast_success(buildContext, "Ticket payé avec succés");
              timer.cancel();
              return;
            }
            if (["COULD_NOT_PERFORM_TRANSACTION"].contains(ticketChecked.statut)) {
              setState(() {
                _isPaying = false;
              });
              DikoubaUtils.toast_error(buildContext, "Echec paiement du ticket");
              timer.cancel();
              return;
            }
            if (checkStatusPaymentCount > 20) {
              setState(() {
                _isPaying = false;
              });
              DikoubaUtils.toast_error(
                  buildContext, "Impossible de terminer le paiement du ticket");
              timer.cancel();
              return;
            }
          }
          setState(() {
            checkStatusPaymentCount++;
          });
        }).catchError((errorLogin) {
          if (checkStatusPaymentCount > 20) {
            setState(() {
              _isPaying = false;
            });
            DikoubaUtils.toast_error(
                buildContext, "Erreur réseau. Veuillez réessayer plus tard");
            timer.cancel();
            return;
          }
          setState(() {
            checkStatusPaymentCount++;
          });
        });
  }

  void proceedReTryMobilePayment(BuildContext buildContext, TicketModel ticketCreated, String PhoneNbr) async {
    setState(() {
      _isPaying = true;
    });

    API.retryMobilePay(
        idTickets: ticketCreated.id_tickets,
        idUser: ticketCreated.id_users,
        phoneNumber: PhoneNbr)
        .then((responseEvent) async {

      if (responseEvent.statusCode == 200) {
        DikoubaUtils.toast_success(
            buildContext, "Paiement ticket initié avec succés");

        timer = Timer.periodic(
            Duration(seconds: 3),
                (Timer t) =>
                proceedCheckStatusPayment(buildContext, widget.ticketModel));
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible d'effectuer le paiement du ticket");
        setState(() {
          _isPaying = false;
        });
        return;
      }
    }).catchError((errorLogin) {
      setState(() {
        _isPaying = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      return;
    });
  }

  void proceedReCheckStatusPayment(BuildContext buildContext, TicketModel ticketCreated) async {
    setState(() {
      _isChecking = true;
    });

    API
        .checkTicketMobilePay(
        idTickets: ticketCreated.id_tickets, idUser: ticketCreated.id_users)
        .then((responseEvent) async {

      if (responseEvent.statusCode == 200) {
        TicketModel ticketChecked =
        new TicketModel.fromJson(responseEvent.data);

        if (ticketChecked.statut == "REQUEST_ACCEPTED" || ticketChecked.statut == "SUCCESSFULL") {
          setState(() {
            _isChecking = false;
          });
          DikoubaUtils.toast_success(buildContext, "Ticket payé avec succés");
          timer.cancel();
          return;
        }
        if (["COULD_NOT_PERFORM_TRANSACTION"].contains(ticketChecked.statut)) {
          setState(() {
            _isChecking = false;
          });
          DikoubaUtils.toast_error(buildContext, "Echec paiement du ticket");
          timer.cancel();
          return;
        }
        if (checkStatusPaymentCount > 20) {
          setState(() {
            _isChecking = false;
          });
          DikoubaUtils.toast_error(
              buildContext, "Impossible de terminer le paiement du ticket");
          timer.cancel();
          return;
        }
      }
      setState(() {
        checkStatusPaymentCount++;
      });
    }).catchError((errorLogin) {
      if (checkStatusPaymentCount > 20) {
        setState(() {
          _isChecking = false;
        });
        DikoubaUtils.toast_error(
            buildContext, "Erreur réseau. Veuillez réessayer plus tard");
        timer.cancel();
        return;
      }
      setState(() {
        checkStatusPaymentCount++;
      });
    });
  }

  void deleteTicket(BuildContext buildContext, TicketModel ticketModel) async {
    setState(() {
      _isPaying = true;
      _isChecking = true;
    });

    API
        .deleteTicket(
        idTickets: ticketModel.id_tickets, idUser: ticketModel.id_users)
        .then((responseEvent) async {

      if (responseEvent.statusCode == 200) {
          DikoubaUtils.toast_success(buildContext, "Ticket supprimé avec succés");
          Navigator.pop(context);
          widget.willRefresh(true);
        }
    }).catchError((errorLogin) {

    });
  }

  //To be reviewed by FD
  void proceedCheckPapalPayment(BuildContext buildContext, TicketModel ticketCreated, String orderId) async {
    setState(() {
      _isPaying = true;
    });

    API
        .checkTicketPaypalPay(
        idTickets: ticketCreated.id_tickets, idUser: ticketCreated.id_users, orderId: orderId)
        .then((responseEvent) async {

      if (responseEvent.statusCode == 200) {
        TicketModel ticketChecked =
        new TicketModel.fromJson(responseEvent.data);

        if (ticketChecked.statut == "COMPLETED") {
          setState(() {
            _isPaying = false;
          });
          DikoubaUtils.toast_success(buildContext, "Ticket payé avec succés");
          timer.cancel();
          return;
        }
        if (["COULD_NOT_PERFORM_TRANSACTION"].contains(ticketChecked.statut)) {
          setState(() {
            _isPaying = false;
          });
          DikoubaUtils.toast_error(buildContext, "Echec paiement du ticket");
          timer.cancel();
          return;
        }
        if (checkStatusPaymentCount > 20) {
          setState(() {
            _isPaying = false;
          });
          DikoubaUtils.toast_error(
              buildContext, "Impossible de terminer le paiement du ticket");
          timer.cancel();
          return;
        }
      }
      setState(() {
        checkStatusPaymentCount++;
      });
    }).catchError((errorLogin) {
      if (checkStatusPaymentCount > 20) {
        setState(() {
          _isPaying = false;
        });
        DikoubaUtils.toast_error(
            buildContext, "Erreur réseau. Veuillez réessayer plus tard");
        timer.cancel();
        return;
      }
      setState(() {
        checkStatusPaymentCount++;
      });
    });
  }

  Future<void> getPositionInfo() async {
    final coordinates = new Coordinates(
        double.parse(widget.ticketModel.evenements.location.latitude),
        double.parse(widget.ticketModel.evenements.location.longitude));
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _eventLocationAddress = first.addressLine;
    });
  }

  List<PackageModel> _packageList;
  PackageModel _package;
  bool _isFinding = false;

  void findPackage() async {
    setState(() {
      _isFinding=true;
    });
    API
        .findEventPackage(widget.ticketModel.id_evenements)
        .then((responsePackage) {
      if (responsePackage.statusCode == 200) {
        print(
            "findEventPackages ${responsePackage.statusCode}|${responsePackage.data}");
        List<PackageModel> list = new List();
        PackageModel myPackage;
        for (int i = 0; i < responsePackage.data.length; i++) {
          PackageModel packageModelgetMdl =
          PackageModel.fromJson(responsePackage.data[i]);
          if (packageModelgetMdl.id_packages == widget.ticketModel.id_packages) {
            myPackage = packageModelgetMdl;
            return;
          }
        }
        setState(() {
          _package = myPackage;
          _isFinding=false;
        });
      } else {
        print("findEventPackages no data ${responsePackage.toString()}");
        setState(() {
          _isFinding=false;
        });
      }
    }).catchError((errWalletAddr) {
      print("findEventPackages errorinfo ${errWalletAddr.toString()}");
      setState(() {
        _isFinding=false;
        });
    });
  }

  handlePayTicket(BuildContext buildContext) {

    if (_paymentMethod.isEmpty) {
      DikoubaUtils.toast_error(
          buildContext, "Veuillez choisir un moyen de paiement");
      return;
    }

    if (_paymentMethod == _status[1]) {
      _proceedPaymentPaypal(buildContext, _package);
    } else {
      if (_phonenumber.isEmpty) {
        DikoubaUtils.toast_error(
            buildContext, "Veuillez entrer le numéro de téléphone");
        return;
      }
      //proceedPayment(buildContext);
      proceedReTryMobilePayment(buildContext, widget.ticketModel, _phonenumber);

    }
  }

  @override
  void initState() {
    super.initState();
    getPositionInfo();
    //findPackage();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'hero-tag-list-z',
                  child: Material(
                    child: Container(
                      height: 165.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(widget.ticketModel.evenements.banner_path), fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.only(top: 10.0, right: 10.0),
                        child: (!(widget.ticketModel.statut == "SUCCESSFULL") && !(widget.ticketModel.statut == "COMPLETE") && !(widget.ticketModel.statut == "COMPLETED")) ? InkWell(
                          onTap: () {
                            deleteTicket(context, widget.ticketModel);
                          },
                          child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.delete,
                                color: Colors.black38,
                              )),
                        ): null,
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),/*Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(MySize.size8),
                        topRight: Radius.circular(MySize.size8)),
                    child: Image(
                      image: NetworkImage(widget.ticketModel.evenements.banner_path),
                      width: MySize.safeWidth,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),*/
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    widget.ticketModel.evenements.title,
                    style: AppTheme.getTextStyle(
                        themeData.textTheme.bodyText1,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 600),
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  color:
                                  themeData.colorScheme.onBackground,
                                  xMuted: true),
                            ),
                            Text(
                              DateFormat('dd MMMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.ticketModel.created_at.seconds) * 1000)),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color:
                                  themeData.colorScheme.onBackground),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  color:
                                  themeData.colorScheme.onBackground,
                                  xMuted: true),
                            ),
                            Text(
                              DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.ticketModel.created_at.seconds) * 1000)),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color:
                                  themeData.colorScheme.onBackground),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Place",
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            xMuted: true,
                            color: themeData.colorScheme.onBackground),
                      ),
                      Text(
                        _eventLocationAddress,
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText1,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 500),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: Spacing.top(24),
                  child: DashedDivider(
                    height: 1,
                    color:
                    themeData.colorScheme.onBackground.withAlpha(60),
                    dashWidth: 7,
                  ),
                ),
                Container(
                  margin: Spacing.vertical(MySize.size8),
                  child: (widget.ticketModel.statut == "REQUEST_ACCEPTED" || widget.ticketModel.statut == "SUCCESSFULL" || widget.ticketModel.statut == "COMPLETE" || widget.ticketModel.statut == "COMPLETED") ?
                  Center(child: QrImage(
                        data: '{"id_users":"' + widget.ticketModel.id_users +
                                '","id_tickets":"' + widget.ticketModel.id_tickets +
                                '","id_evenements":"' + widget.ticketModel.id_evenements +
                                '","id_packages":"' + widget.ticketModel.id_packages + '"}',
                        version: QrVersions.auto,
                        size: 200.0,
                      ) )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isChecking ?
                            Container(
                              margin: Spacing.fromLTRB(16, 0, 16, 0),
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DikoubaColors.blue['pri']),
                              ),
                            ) : InkWell(
                                  onTap: () {
                                    proceedReCheckStatusPayment(context, widget.ticketModel);
                                  },
                                  child: Container(
                                    margin: Spacing.fromLTRB(20, 0, 20, 0),
                                    alignment: Alignment.center,
                                    padding: Spacing.fromLTRB(8, 8, 8, 8),
                                    decoration: BoxDecoration(
                                      color: DikoubaColors.blue['pri'],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(MySize.size40)),),
                                    child: Container(
                                      margin: Spacing.left(12),
                                      child: Row(children: [Text(
                                        "Re-vérifier le ticket",
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText2,
                                            fontSize: MySize.size22,
                                            letterSpacing: 0.7,
                                            color:
                                            themeData.colorScheme.onPrimary,
                                            fontWeight: 600),
                                      ),
                                      Icon(
                                        Icons.refresh,
                                        color: Colors.white)
                                      ]),
                                    ),
                                  ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  children: <Widget>[
                                    Radio<String>(
                                      value: _status[0],
                                      groupValue: _paymentMethod,
                                      onChanged: (value) => setState(() {
                                        _paymentMethod = value;
                                      }),
                                    ),
                                    Image(image: AssetImage(_buttonOMImageAsset[2]), width: MySize.size100)
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Radio<String>(
                                      value: _status[1],
                                      groupValue: _paymentMethod,
                                      onChanged: (value) => setState(() {
                                        _paymentMethod = value;
                                      }),
                                    ),
                                    Image(image: AssetImage(_buttonOMImageAsset[3]), width: MySize.size100)
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MySize.size8,
                            ),
                            if (_paymentMethod == _status[0]) Container(
                              margin: Spacing.fromLTRB(16, 0, 16, 0),
                              alignment: Alignment.center,
                              child:TextFormField(
                              controller: phoneCtrler,
                              onChanged: (text) {
                                setState(() {
                                  _phonenumber = text;
                                  /*if(prefixMOMO.any((element) => phoneCtrler.text.contains(element))) _buttonOMImageIndex=0;
                                  else if(prefixOM.any((element) => phoneCtrler.text.contains(element))) _buttonOMImageIndex=1;
                                  else _buttonOMImageIndex=2;*/
                                });
                                print("phone_changed " + text + " " + _buttonOMImageAsset[_buttonOMImageIndex]);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Veuillez saisir le numéro de téléphone';
                                }
                                return null;
                              },
                              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                                  color: themeData.colorScheme.onBackground,
                                  letterSpacing: -0.4,
                                  fontWeight: 800),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                fillColor: themeData.colorScheme.background,
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    color: themeData.colorScheme.onBackground,
                                    letterSpacing: -0.4,
                                    fontWeight: 800),
                                filled: false,
                                hintText: "Numéro de téléphone",
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              autocorrect: false,
                            )),
                            SizedBox(
                              height: MySize.size8,
                            ),
                            _isPaying ?
                            Container(
                              margin: Spacing.fromLTRB(16, 0, 16, 0),
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DikoubaColors.blue['pri']),
                              ),
                            ) : InkWell(
                              onTap: () {
                                handlePayTicket(context);
                              },
                              child: Container(
                                margin: Spacing.fromLTRB(20, 0, 20, 0),
                                alignment: Alignment.center,
                                padding: Spacing.fromLTRB(8, 8, 8, 8),
                                decoration: BoxDecoration(
                                  color: DikoubaColors.blue['pri'],
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(MySize.size40)),),
                                child: Container(
                                  margin: Spacing.left(12),
                                  child: Row(children: [Text(
                                    "Reéssayer le paiement",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        fontSize: MySize.size22,
                                        letterSpacing: 0.7,
                                        color:
                                        themeData.colorScheme.onPrimary,
                                        fontWeight: 600),
                                  )
                                  ]),
                                ),
                              ),
                            ),
                        ]),
                )
              ],
            )
        );
      },
    );
  }
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

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
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                  'Barcode Type: ${(result.format)}   Data: ${result.code}')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class QRViewExample extends StatefulWidget {
  TicketModel ticketModel;
  QRViewExample(this.ticketModel);

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}



