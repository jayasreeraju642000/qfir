import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/set_passcode/set_passcode_for_small.dart';
import 'package:qfinr/pages/set_passcode/set_passcode_for_large.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';

final log = getLogger('SetPasscodePage');

class SetPasscodePage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;
  final bool registrationFlag;

  final bool isBiometric;

  SetPasscodePage(this.model, this.setPasscode, this.isBiometric,
      {this.analytics, this.observer, this.registrationFlag = false});

  @override
  State<StatefulWidget> createState() {
    return _SetPasscodePageState();
  }
}

class _SetPasscodePageState extends State<SetPasscodePage> {
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
    return SetPasscodePageLarge(
      widget.model,
      widget.setPasscode,
      widget.isBiometric,
      analytics: widget.analytics,
      observer: widget.observer,
      registrationFlag: widget.registrationFlag,
    );
  }

  Widget _forMediumSizedScreen() {
    return SetPasscodePageLarge(
      widget.model,
      widget.setPasscode,
      widget.isBiometric,
      analytics: widget.analytics,
      observer: widget.observer,
      registrationFlag: widget.registrationFlag,
    );
  }

  Widget _forSmallSizedScreen() {
    return SetPasscodePageSmall(
      widget.model,
      widget.setPasscode,
      widget.isBiometric,
      analytics: widget.analytics,
      observer: widget.observer,
      registrationFlag: widget.registrationFlag,
    );
  }
}
