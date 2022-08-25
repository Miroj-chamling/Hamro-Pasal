import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/providers/orders.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EsewaPaymentScreen extends StatefulWidget {
  const EsewaPaymentScreen({Key? key}) : super(key: key);
  static const routeName = "/esewa-payment-screen";

  @override
  State<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends State<EsewaPaymentScreen> {
  late WebViewController _webViewController;

  Future<void> _loadHtmlAssets() async {
    String file = await rootBundle.loadString("assets/esewa.html");
    _webViewController.loadUrl(Uri.dataFromString(file,
            mimeType: "text/html", encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  double tAmt = 1000;
  double amt = 800;
  double txAmt = 100;
  double psc = 50;
  double pdc = 50;
  String scd = "EPAYTEST";
  String su = "https://github.com/kaledai";
  String fu = "https://refactoring.guru/design-patterns/factory-method";

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
      body: WebView(
        initialUrl: "about:blank",
        javascriptMode: JavascriptMode.unrestricted,
        // javascriptChannels: Set.from([
        //   JavascriptChannel(
        //     name: "message",
        //     onMessageReceived: (message) {},
        //   ),
        // ]),
        onWebViewCreated: (WebViewController) {
          _webViewController = WebViewController;
          _loadHtmlAssets();
        },
        onPageFinished: (data) {
          setState(
            () {
              amt = orderData.totalAmount;
              tAmt = amt + txAmt + psc + pdc;
              String pid = UniqueKey().toString();
              _webViewController.runJavascript(
                  'requestPayment(tAmt = $tAmt, amt = $amt, txAmt = $txAmt, psc = $psc, pdc = $pdc, scd = "$scd", pid = "$pid", su = "$su", fu = "$fu")');
            },
          );
        },
      ),
    );
  }
}
