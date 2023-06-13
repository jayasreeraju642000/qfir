import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/fund_info/fund_info_for_large_screen.dart';
import 'package:qfinr/pages/fund_info/fund_info_for_small_screen.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('FundInfo');

class FundInfo extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String ric;

  FundInfo(this.model, {this.analytics, this.observer, this.ric});
  @override
  _FundInfoState createState() => _FundInfoState();
}

class _FundInfoState extends State<FundInfo> {
  @override
  void initState() {
    log.d("Inside Know Fund Report");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isDesktop) {
          return FundInfoForLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            ric: widget.ric,
          );
        } else if (sizingInformation.isTablet) {
          return FundInfoForLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            ric: widget.ric,
          );
        } else {
          return FundInfoForSmallScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            ric: widget.ric,
          );
        }
      },
    );
  }
}
