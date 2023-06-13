import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  static int val = 0;
  FlutterWebviewPlugin webviewPlugin;
  Future<bool> onWillPop() async {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - val < Duration(seconds: 2).inMilliseconds) {
      return await showPopUp();
    } else {
      print('\nexit cancel');
      val = currentTime;
      return false;
    }
  }

  Future<bool> showPopUp() async {
    webviewPlugin.close();
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit MSD'),
            content: Text('Do you want to exit?'),
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
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
        body: WebviewScaffold(
          url: widget.url,
          withZoom: false,
          withLocalStorage: true,
        ),
      ),
    );
  }
}
