import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:dikouba_rawstart/provider/paypal_service_v2.dart';


import 'package:url_launcher/url_launcher.dart';

class PaypalPaymentV2 extends StatefulWidget {
  final Function onFinish;
  //final EvenementModel evenementModel;
  final PackageModel packageModel;

  PaypalPaymentV2(//this.evenementModel,
      this.packageModel, {required this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentV2State();
  }
}

class PaypalPaymentV2State extends State<PaypalPaymentV2> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String checkoutUrl;
  late String executeUrl;
  late String approvalUrl;
  late String accessToken;
  PaypalServicesV2 services = PaypalServicesV2();

  // you can change default currency according to your need
  Map<dynamic,dynamic> defaultCurrency = {"symbol": "EUR ", "decimalDigits": 2, "symbolBeforeTheNumber": true, "currency": "EUR"};

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = "https://www.dikouba.com/";
  String cancelURL= "cancel.example.com";


  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // ···
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); print('android_platform ' + WebView.platform.toString());

    Future.delayed(Duration.zero, () async {
      final transactions = getOrderParams();
      try {
        accessToken = (await services.getAccessToken())!;


        final res =
        await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"]!;
            executeUrl = res["executeUrl"]!;
            approvalUrl = res["approvalUrl"]!;
            print('url_for_web_view ' +checkoutUrl);
          });
        }
      } catch (e) {
        print('exception_paypal: '+e.toString() + transactions.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  // item name, price and quantity
  int quantity = 1;
  String _amountToPay = "100";

  Map<String, dynamic> getOrderParams() {
    // checkout invoice details
    String totalAmount = ((double.parse(widget.packageModel.price!)/655.95).round()*quantity).toString();

    Map<String, dynamic> temp = {
      "intent": "CAPTURE",
      "purchase_units" : [
        {
          "amount":{
            "currency_code" : defaultCurrency["currency"],
            "value" : totalAmount,
          /*  "breakdown" : {"item_total": {
                            "currency_code" : defaultCurrency["currency"],
                            "value" : subTotalAmount,}}*/
          },
          //"items": items
        }
      ],
      "application_context" : {
        "brand_name" : "Dikouba_Prod",
        "redirect_urls": {
          "return_url": returnURL,
          "cancel_url": cancelURL
        },
        "landing_page" : "BILLING",
        "payment_method":{"payee_preferred": "UNRESTRICTED"}, //"IMMEDIATE_PAYMENT_REQUIRED"},
      }
    };
    return temp;
  }

  late WebViewController _controller = WebViewController()
    ..loadRequest(Uri.parse(checkoutUrl))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36")
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
            print('webview_request' + request.toString());
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              final orderID = uri.queryParameters['id'];
              widget.onFinish(orderID);
              Navigator.of(context).pop();
              if (payerID != null) {
                /*services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                  widget.onFinish(id);
                  Navigator.of(context).pop();
                });*/
              } else {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
      )
    );

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        body: WebViewWidget(controller: _controller),
      );
    }
  }
}