import 'dart:async';
import 'dart:convert';

import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/fragment/PaypalPayment_v2.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/ticket_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/api_provider.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/provider/paypal_service_v2.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paypal_sdk_flutter/paypal_sdk_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:url_launcher/url_launcher.dart';


class ProceedPaymentPackageDialog extends StatefulWidget {
  PackageModel package;
  EvenementModel evenement;
  ThemeData themeData;

  ProceedPaymentPackageDialog(this.package, this.evenement, this.themeData,
      {this.analytics, this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _ProceedPaymentPackageDialogState createState() =>
      _ProceedPaymentPackageDialogState();
}

class _ProceedPaymentPackageDialogState
    extends State<ProceedPaymentPackageDialog> {
  static final String tag = 'EvenNewEventActivityState';

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

  Timer timer;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void queryUser() async {
    final userRows = await dbHelper.query_user();
    setState(() {
      _userModel = UserModel.fromJsonDb(userRows[0]);
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics?.setCurrentScreen(
      screenName: "ShowEventPaymentPackageDialog",
      screenClassOverride: "ShowEventPaymentPackageDialog",
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
    queryUser();
    _setCurrentScreen();
    phoneCtrler = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      /*: new AppBar(
        title: Text("Paiement package",
            style: themeData.appBarTheme.textTheme.headline6),
      ),*/
      body: Container(
        padding: EdgeInsets.only(
            top: MySize.size8,
            bottom: MySize.size8,
            left: MySize.size16,
            right: MySize.size16),
        child: (int.parse(widget.package.price ?? 0) == 0)
            ? ListView(
                children: [
                  SizedBox(
                    height: MySize.size12,
                  ),
                  Text('Evenement',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 400)),
                  Text(widget.evenement.title,
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 600)),
                  SizedBox(
                    height: MySize.size8,
                  ),
                  Text('Package',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 400)),
                  Text(widget.package.name,
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 600)),
                  SizedBox(
                    height: MySize.size8,
                  ),
                  Text('Montant',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 400)),
                  Text(
                      DikoubaUtils.formatCurrencyWithDevise(
                          widget.package.price),
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 600)),
                  SizedBox(
                    height: MySize.size12,
                  ),
                  _isPaying
                      ? Container(
                          width: MySize.size24,
                          height: MySize.size24,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                DikoubaColors.blue['pri']),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            _sendAnalyticsEvent("PressBuyFreeTicket");
                            handlePayFreeTicket(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: Spacing.fromLTRB(8, 8, 8, 8),
                            decoration: BoxDecoration(
                                color: DikoubaColors.blue['pri'],
                                borderRadius: BorderRadius.all(
                                    Radius.circular(MySize.size40))),
                            child: Container(
                              margin: Spacing.left(12),
                              child: Text(
                                "Valider",
                                style: AppTheme.getTextStyle(
                                    widget.themeData.textTheme.bodyText2,
                                    fontSize: MySize.size22,
                                    letterSpacing: 0.7,
                                    color:
                                        widget.themeData.colorScheme.onPrimary,
                                    fontWeight: 600),
                              ),
                            ),
                          ),
                        ),
                ],
              )
            : ListView(
                children: [
                  SizedBox(
                    height: MySize.size12,
                  ),
                  Text('Evenement',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 400)),
                  Text(widget.evenement.title,
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 600)),
                  SizedBox(
                    height: MySize.size8,
                  ),
                  Text('Package',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 400)),
                  Text(widget.package.name,
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 600)),
                  SizedBox(
                    height: MySize.size8,
                  ),
                  Text('Montant',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 400)),
                  Text(
                      DikoubaUtils.formatCurrencyWithDevise(
                          widget.package.price) +
                          ' / ' + ((double.parse(widget.package.price)/655.95).round()).toString() + ' EUR',
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.bodyText1,
                          fontWeight: 600)),
                  SizedBox(
                    height: MySize.size10,
                  ),
                  Text('Moyen de paiement',
                      style: themeData.appBarTheme.textTheme.bodyText1),
                  ListTile(
                    title: const Text(""),
                    leading: Row(
                      //spacing: 12, // space between two icons
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Radio<String>(
                          value: _status[0],
                          groupValue: _paymentMethod,
                          onChanged: (value) => setState(() {
                            _paymentMethod = value;
                          }),
                        ),
                        Image.asset(_buttonOMImageAsset[2]),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text(""),
                    leading: Row(
                      //spacing: 12, // space between two icons
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Radio<String>(
                          value: _status[1],
                          groupValue: _paymentMethod,
                          onChanged: (value) => setState(() {
                            _paymentMethod = value;
                          }),
                        ),
                        Image.asset(_buttonOMImageAsset[3]),
                      ],
                    ),
                  ),
                  /*RadioGroup<String>.builder(
                    groupValue: _paymentMethod,
                    onChanged: (value) => setState(() {
                      _paymentMethod = value;
                    }),
                    items: _status,
                    textStyle: themeData.appBarTheme.textTheme.bodyText1,
                    itemBuilder: (item) => RadioButtonBuilder(
                      item,
                    ),
                  ),*/
                  SizedBox(
                    height: MySize.size14,
                  ),
                  if (_paymentMethod == _status[0]) Text('Informations du compte',
                      style: themeData.appBarTheme.textTheme.bodyText1),
                  if (_paymentMethod == _status[0]) TextFormField(
                    controller: phoneCtrler,
                    onChanged: (text) {
                      setState(() {
                        if(prefixMOMO.any((element) => phoneCtrler.text.contains(element))) _buttonOMImageIndex=0;
                        else if(prefixOM.any((element) => phoneCtrler.text.contains(element))) _buttonOMImageIndex=1;
                        else _buttonOMImageIndex=2;
                      });
                      print("phone_changed " + text + " " + _buttonOMImageAsset[_buttonOMImageIndex]);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Veuillez saisir le titre';
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
                  ),
                  SizedBox(
                    height: MySize.size14,
                  ),
                  _isPaying
                      ? Container(
                          width: MySize.size24,
                          height: MySize.size24,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                DikoubaColors.blue['pri']),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            _sendAnalyticsEvent("PressBuyTicket");
                            handlePayTicket(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: Spacing.fromLTRB(8, 8, 8, 8),
                            decoration: BoxDecoration(
                              color: DikoubaColors.blue['pri'],
                              borderRadius: BorderRadius.all(
                              Radius.circular(MySize.size40)),
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.dstATop),
                                alignment: Alignment.centerLeft,
                                image: _paymentMethod == _status[1] ? AssetImage(_buttonOMImageAsset[3]) :
                                      AssetImage(_buttonOMImageAsset[_buttonOMImageIndex]),
                              ),),
                            child: Container(
                                  margin: Spacing.left(12),
                                  child: Text(
                                    "Payer",
                                    style: AppTheme.getTextStyle(
                                        widget.themeData.textTheme.bodyText2,
                                        fontSize: MySize.size22,
                                        letterSpacing: 0.7,
                                        color:
                                            widget.themeData.colorScheme.onPrimary,
                                        fontWeight: 600),
                                  ),
                                ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  handlePayFreeTicket(BuildContext buildContext) {
    proceedAddTicket(buildContext);
  }

  handlePayTicket(BuildContext buildContext) {
    if (_paymentMethod.isEmpty) {
      DikoubaUtils.toast_error(
          buildContext, "Veuillez choisir un moyen de paiement");
      return;
    }

    if (_paymentMethod == _status[1]) {
      _proceedPaymentPaypal(buildContext, widget.evenement, widget.package);
    } else {
      if (phoneCtrler.text.isEmpty) {
        DikoubaUtils.toast_error(
            buildContext, "Veuillez entrer le numéro de téléphone");
        return;
      }
      proceedPayment(buildContext);
    }
  }

  void saveForm(BuildContext buildContext) {
    Navigator.of(buildContext).pop();
  }

  void proceedAddTicket(BuildContext buildContext) async {
    setState(() {
      _isPaying = true;
    });

    API
        .addTicket(
      idEvenement: widget.evenement.id_evenements,
      idUser: _userModel.id_users,
      idPackage: widget.package.id_packages,
    )
        .then((responseEvent) async {
      print(
          "$tag:proceedAddTicket responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        TicketModel ticketCreated =
            new TicketModel.fromJson(responseEvent.data);

        setState(() {
          _isPaying = false;
        });
        DikoubaUtils.toast_success(
            buildContext, "Ticket enregistré avec succés");
      } else {
        DikoubaUtils.toast_error(
            buildContext, "Impossible d'enregistrer le ticket");
        setState(() {
          _isPaying = false;
        });
      }
      return;
    }).catchError((errorLogin) {
      setState(() {
        _isPaying = false;
      });
      DikoubaUtils.toast_error(
          buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      // print("$tag:proceedAddTicket catchError ${errorLogin}");
      // print(
      //     "$tag:proceedAddTicket catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });
  }

  void proceedPaymentPaypal(BuildContext buildContext) async {
    setState(() {
      _isPaying = true;
    });
    String result;
    try {
      PaypalSdkFlutter sdk = PaypalSdkFlutter(
        environment: Environment.sandbox,
        merchantName: "Dikouba",
        clientId:
            "AU-QgOX5VEnQY6MmRlveMWznE1MSLjEQ0YuHfLbCYEFvwPNPQ_VivNDcqnma9RjSOrErE7giyh-F_nee",
      );
      var resPaypal = await sdk.payWithPayPal(
          amount: double.parse(widget.package.price ?? 0),
          description: "DIKOUBA, achat ticket évènement");
      print("Withing example $result");
      print(
          "$tag:proceedPaymentPaypal resPaypal = ${resPaypal.runtimeType}|$resPaypal");

      if (!mounted) return;

      setState(() {
        _isPaying = false;
      });
    } catch (exception) {
      print(
          "$tag:proceedPaymentPaypal exception = ${exception.runtimeType}|$exception");
      result = 'Failed to get payPal result.';

      if (!mounted) return;

      setState(() {
        _isPaying = false;
      });
    }

    /*if (resPaypal != "" && resPaypal != null) {
      List<String> list = resPaypal;
      var status = list[0];
      var transactionId = list[1];
      if (status == "success" && transactionId != "") {
        DikoubaUtils.toast_success(
            buildContext, "Paiement Paypal initié avec succes");
        // showAlert(
        //     "Successfully transaction completed. TransactionId:" +
        //         transactionId,
        //     scaffoldKey);
      } else if (status == "cancel") {
        DikoubaUtils.toast_success(
            buildContext, "Paiement Paypal annulé");
      }
    }*/
  }

  void _proceedPaymentPaypal(BuildContext buildContext, EvenementModel evenementModel, PackageModel packageModel) async {
    setState(() {
      _isPaying = true;
    });

    API
        .addTicket(
        idEvenement: widget.evenement.id_evenements,
        idUser: _userModel.id_users,
        idPackage: widget.package.id_packages)
        .then((responseEvent) async {
      print(
          "$tag:addTicke responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        TicketModel ticketCreated =
        new TicketModel.fromJson(responseEvent.data);
        //
        DikoubaUtils.toast_success(
            buildContext, "Ticket créé avec succés");

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => //Webview()
            PaypalPaymentV2(//evenementModel,
              packageModel,
              onFinish: (number) async {

                // payment done
                print('order_id: '+number);
                //Check paypal pay

                timer = Timer.periodic(
                    Duration(seconds: 3),
                        (Timer t) =>
                        proceedCheckPapalPayment(buildContext, ticketCreated, number.toString()));

              },
            ),
          ),
        );
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
      print("$tag:createAnnoncer catchError ${errorLogin}");
      print(
          "$tag:createAnnoncer catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
    });

  }

  void proceedPayment(BuildContext buildContext) async {
    setState(() {
      _isPaying = true;
    });

    API
        .addTicketMobilePay(
            idEvenement: widget.evenement.id_evenements,
            idUser: _userModel.id_users,
            idPackage: widget.package.id_packages,
            phoneNumber: phoneCtrler.text)
        .then((responseEvent) async {
      print(
          "$tag:addTicketMobilePay responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        TicketModel ticketCreated =
            new TicketModel.fromJson(responseEvent.data);
        //
        DikoubaUtils.toast_success(
            buildContext, "Paiement ticket initié avec succés");

        timer = Timer.periodic(
            Duration(seconds: 3),
            (Timer t) =>
                proceedCheckStatusPayment(buildContext, ticketCreated));
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
      print("$tag:createAnnoncer catchError ${errorLogin}");
      print(
          "$tag:createAnnoncer catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      return;
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

  void proceedCheckStatusPayment(BuildContext buildContext, TicketModel ticketCreated) async {
    setState(() {
      _isPaying = true;
    });

    API
        .checkTicketMobilePay(
            idTickets: ticketCreated.id_tickets, idUser: ticketCreated.id_users)
        .then((responseEvent) async {
      print(
          "$tag:proceedCheckStatusPayment responseCreated = ${responseEvent.statusCode}|${responseEvent.data}");

      if (responseEvent.statusCode == 200) {
        TicketModel ticketChecked =
            new TicketModel.fromJson(responseEvent.data);

        if (ticketChecked.statut == "REQUEST_ACCEPTED") {
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

      // setState(() {
      //   _isPaying = false;
      // });
      // DikoubaUtils.toast_error(
      //     buildContext, "Erreur réseau. Veuillez réessayer plus tard");
      // print("$tag:proceedCheckStatusPayment catchError ${errorLogin}");
      // print(
      //     "$tag:proceedCheckStatusPayment catchError ${errorLogin.response.statusCode}|${errorLogin.response.data}");
      // return;
    });
  }
}

/*
class Webview extends StatefulWidget {
  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  WebViewController _con;
  /*
  *
  * Webview
  * */

  String setHTML(String email, String phone, String name) {
    return ('''
    <html>
      <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
      </head>
      
        <body style="background-color:#fff;height:100vh ">

          <div style="width: 50%; margin: 0 auto;margin-top: 200px">
            <table class="table table-striped">
              <tbody>
                <tr>
                  <th>Name</th>
                  <th>$name</th>
                </tr>
                <tr>
                  <th>Email</th>
                  <td>$email</td>
                </tr>
                <tr>
                  <th>Phone</th>
                  <th>$phone</th>
                </tr>
              </tbody>
            </table>
            <a type="button" class="btn btn-success" style="width: 210px" href="https://connelevalsam.github.io/connelblaze/">
              Submit
            </a>
          </div>
        </body>
      </html>
      

    ''');
  }

  String setHTML_P(String email, String phone, String name) {
    return ('''
    <html> 
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1"> <!-- Ensures optimal rendering on mobile devices. -->
          <meta http-equiv="X-UA-Compatible" content="IE=edge" /> <!-- Optimal Internet Explorer compatibility -->
        </head>
        
        <body>
          <script
            src="https://www.paypal.com/sdk/js?client-id=AU-QgOX5VEnQY6MmRlveMWznE1MSLjEQ0YuHfLbCYEFvwPNPQ_VivNDcqnma9RjSOrErE7giyh-F_nee"> // Required. Replace YOUR_CLIENT_ID with your sandbox client ID.
          </script>
          
          <div id="paypal-button-container"></div>
        
          <script>
            paypal.Buttons({
            createOrder: function(data, actions) {
              // This function sets up the details of the transaction, including the amount and line item details.
              return actions.order.create({
                purchase_units: [{
                  amount: {
                    value: '0.01'
                  }
                }]
              });
            },
            onApprove: function(data, actions) {
              // This function captures the funds from the transaction.
              /*return actions.order.capture().then(function(details) {
                // This function shows a transaction success message to your buyer.
                alert('Transaction completed with id ' + data.orderID);
              }).*/
            return actions.order.capture().then(function(details) {
            console.log(data.orderID);
            fetch('http://localhost:8080', {
              // Adding method type
              mode: 'no-cors',
              method: "POST",
              headers: {
                'content-type': 'application/json'
              },
              body: JSON.stringify({
                orderID: data.orderID
              })
            });
            }).then(function(res) {
            return res.json();
            }).then(function(details) {
                // This function shows a transaction success message to your buyer.
                alert('Transaction completed by ' + details.payer.name.given_name);
              });
            }
          }).render('#paypal-button-container');
          //This function displays Smart Payment Buttons on your web page.
          </script>
          
        </body>
      </html>
      

    ''');
  }

  _loadHTML() async {
    _con.loadUrl(Uri.dataFromString(
        setHTML_P(
            "connelblaze@gmil.com",
            "+2347034857296",
            "Connel Asikong"
        ),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webview'),
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: 'https://flutter.dev',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            // _controller.complete(webViewController);
            _con = webViewController;
            _loadHTML();
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }

}*/
