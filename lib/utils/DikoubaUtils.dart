import 'dart:ui';

import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
//import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DikoubaUtils {
  DikoubaUtils._(); // this basically makes it so you can instantiate this class

  static final String kGoogleApiKey = "AIzaSyCxSDn342IXFveMTAcgWi4iFXIYpBm8Xbg";

  // static final String MapApiKey = "AIzaSyBXR9oe3SG-ijYGMKfuhDCuuDZEcvXV9LE";
  static final String MapApiKey = "AIzaSyAAr_SqMefyCPhilOxiMfRfaXA9IqKV7kQ";
  static final String CURRENCY = "FCFA";
  static final String CODE_CURR_POSITION = "ycurrposition";

  static String formatCurrency(String amount) {
    if (amount == null || amount == '') return '';
    return new NumberFormat("#,###", "fr_FR").format(double.parse(amount));
  }

  static String formatCurrencyWithDevise(String amount) {
    return new NumberFormat("#,###", "fr_FR").format(double.parse(amount)) +
        " " +
        CURRENCY;
  }

  static toast_infos(BuildContext buildContext, String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message != null && message.isNotEmpty) {
        /*FlushbarHelper.createInformation(
          message: message,
          title: "Info",
          duration: Duration(seconds: 3),
        )..show(buildContext);*/
      }
    });
    return SizedBox.shrink();
  }

  static toast_success(BuildContext buildContext, String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message != null && message.isNotEmpty) {
        /*FlushbarHelper.createSuccess(
          message: message,
          title: "Succès",
          duration: Duration(seconds: 3),
        )..show(buildContext);*/
      }
    });
    return SizedBox.shrink();
  }

  static List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  static toast_error(BuildContext buildContext, String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message != null && message.isNotEmpty) {
        /*FlushbarHelper.createError(
          message: message,
          title: "Erreur",
          duration: Duration(seconds: 3),
        )..show(buildContext);*/
      }
    });
    return SizedBox.shrink();
  }

  static void showSimpleLoadingDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: ListTile(
                leading: CircularProgressIndicator(),
                title: new Text("${message}")),
          );
        });
  }

  static void alert_success_scan(
      BuildContext buildContext, String magasin, String credit) {
    AlertDialog alert = AlertDialog(
      backgroundColor: DikoubaColors.blue['pri'],
      title: Text("$magasin Fidélité", style: TextStyle(color: Colors.white)),
      content: Text("Votre compte fidélité a été rechargé de $credit pts",
          style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(buildContext).pop();
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future<String> alert_success(BuildContext buildContext, String message, double height) async {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        height: height,
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Icon(
                    CupertinoIcons.check_mark_circled,
                    color: DikoubaColors.blue['pri'],
                    size: 78,
                  ),
                )),
            Expanded(
                flex: 1,
                child: Text("${message}",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'roboto_regular'))),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(buildContext).pop("ok");
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return message;
  }

  static Future<String> alert_error(BuildContext buildContext, String message, double height) async {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        height: height,
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Icon(
                    CupertinoIcons.clear_circled,
                    color: DikoubaColors.red['pri'],
                    size: 78,
                  ),
                )),
            Expanded(
                flex: 1,
                child: Text("${message}",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'roboto_regular'))),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(buildContext).pop("ok");
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return message;
  }

  static void alert_error_scan(BuildContext buildContext, String message) {
    AlertDialog alert = AlertDialog(
      backgroundColor: DikoubaColors.red['pri'],
      title: Text("Carte de Fidélité", style: TextStyle(color: Colors.white)),
      content: Text(
        "$message",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(buildContext).pop();
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void alert_info_scan(BuildContext buildContext, String message) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Carte de Fidélité", style: TextStyle(color: Colors.black)),
      content: Text(
        "$message",
        style: TextStyle(color: Colors.black87),
      ),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(buildContext).pop();
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void alert_success_lot(
      BuildContext buildContext, String magasin, String amount, String caisse) {
    AlertDialog alert = AlertDialog(
      backgroundColor: DikoubaColors.blue['pri'],
      title: Text("$magasin Fidélité", style: TextStyle(color: Colors.white)),
      content: Text.rich(
        TextSpan(
          text:
              'Félicitation cher client, vous disposer d\'un bon d\'achat de ',
          style: TextStyle(
            fontFamily: 'roboto_regular',
            fontSize: 20,
            color: Colors.white,
          ),
          children: <TextSpan>[
            new TextSpan(
              text: " $amount FCFA",
              style: new TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'roboto_regular',
              ),
            ),
            new TextSpan(
              text: "\nCaisse: $caisse",
              style: new TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'roboto_regular',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(buildContext).pop();
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void alert_error_lot(BuildContext buildContext, String message) {
    AlertDialog alert = AlertDialog(
      backgroundColor: DikoubaColors.red['pri'],
      title: Text("Carte de Fidélité", style: TextStyle(color: Colors.white)),
      content: Text(
        "$message",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          child: Text("OK", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(buildContext).pop();
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static String getSexe(String codeSexe) {
    if (codeSexe == 'M')
      return "Masculin";
    else if (codeSexe == 'F') return "Féminin";
    return "";
  }

  static String getNotificationType(String codeNotif) {
    if (codeNotif == 'add_promotion')
      return "Nouvelle promotion";
    else if (codeNotif == 'add_wallet')
      return "Recharge crédit";
    else if (codeNotif == 'remove_wallet')
      return "Retrait crédit";
    else
      return "SPAR Cameroun";
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }
}
