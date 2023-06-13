import 'dart:async';

import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  static int val = 0;
  WebViewController controller;

  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();

  Future<bool> onWillPop() async {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - val < Duration(seconds: 1).inMilliseconds) {
      return showPopUp();
    } else {
      val = currentTime;
      if (await controller.canGoBack()) {
        controller.goBack();
      }
      return false;
    }
  }

  Future<bool> showPopUp() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit MSD'),
            content: Text('Do you want to exit?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  print('no');
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  print('yes');
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: WebView(
                initialUrl: 'http://installpay.strat-staging.com/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController c) {
                  _controllerCompleter.future
                      .then((value) => controller = value);
                  _controllerCompleter.complete(c);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
