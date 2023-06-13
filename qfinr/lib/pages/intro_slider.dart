import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('IntroSliderPage');

class IntroSliderPage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  IntroSliderPage(this.model, {this.analytics, this.observer});

  @override
  _IntroSliderPageState createState() => new _IntroSliderPageState();
}

class _IntroSliderPageState extends State<IntroSliderPage> {
  final int splashSeconds = 1;
  final bool enableNavigate = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: splashSeconds), () async {
      if (enableNavigate) {
        if (widget.model.isUserAuthenticated) {
          var responseData = await widget.model.validateCustomerSession();
          if (responseData['status']) {
            Navigator.of(context)
                .pushReplacementNamed('/verifyPasscodeStartup');
          } else {
            widget.model.logout();
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(360, 640),
    );
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/images/splash_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IntrinsicWidth(
            child: Column(
              children: [
                svgImage(
                  'assets/images/logo.svg',
                  width: deviceType == DeviceScreenType.mobile ? 150 : 100,
                ),
                SizedBox(height: 50),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.black26,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Please wait, app is loading...",
            style: TextStyle(
              fontFamily: "nunito",
              color: Colors.black,
              fontSize: 16,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
