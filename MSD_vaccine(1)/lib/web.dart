import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 25,
            ),
            Expanded(
                child: InAppWebView(
              initialUrl: 'http://installpay.strat-staging.com/',
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
            )
                // WebView(
                //   initialUrl: 'http://installpay.strat-staging.com/',
                //   javascriptMode: JavascriptMode.unrestricted,
                // ),
                )
          ],
        ),
      ),
    );
  }

  Future<bool> _onBack() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack(); // perform webview back operation
      return false;
    } else {
      // Webpage in home page
      return true; // Close App
    }
  }
}
