import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/know_fund_detail/know_fund_detai_for_small_screenl.dart';
import 'package:qfinr/pages/know_fund_detail/know_fund_detail_for_large_screen.dart';
import 'package:qfinr/pages/know_fund_detail/know_fund_detail_for_medium_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class KnowFundDetail extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Map<String, dynamic> responseData;

  final int tabIndex;

  KnowFundDetail(this.model,
      {this.analytics, this.observer, this.responseData, this.tabIndex});

  @override
  _KnowFundDetailState createState() => _KnowFundDetailState();
}

class _KnowFundDetailState extends State<KnowFundDetail> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isDesktop) {
          return KnowFundDetailForLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
          );
        } else if (sizingInformation.isTablet) {
          return KnowFundDetailForMediumScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
          );
        } else {
          return KnowFundDetailForSmallScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            tabIndex: widget.tabIndex,
          );
        }
      },
    );
  }
}
