

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/verify_passcode/verify_passcode_for_large_screen.dart';
import 'package:qfinr/pages/verify_passcode/verify_passcode_for_small_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class VerifyPasscodePage extends StatefulWidget {

  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;

  final bool isBiometric;

  VerifyPasscodePage(this.model, this.setPasscode, this.isBiometric, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPasscodePageState();
  }
}

class _VerifyPasscodePageState extends State<VerifyPasscodePage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.isMobile) {
          return _forSmallSizedScreen();
        } else if (sizingInformation.isTablet) {
          return _forMediumSizedScreen();
        } else {
          return _forLargeScreen();
        }
      },
    );
  }

  Widget _forLargeScreen() {
    return VerifyPasscodeForLargeScreen(
      widget.model,
      widget.setPasscode,
      widget.isBiometric,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forMediumSizedScreen() {
    return VerifyPasscodeForLargeScreen(
      widget.model,
      widget.setPasscode,
      widget.isBiometric,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forSmallSizedScreen() {
    return VerifyPasscodeForSmallScreen(
      widget.model,
      widget.setPasscode,
      widget.isBiometric,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

}