import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/know_fund_report/know_fund_report_for_large_screen.dart';
import 'package:qfinr/pages/know_fund_report/know_fund_report_for_medium_screen.dart';
import 'package:qfinr/pages/know_fund_report/know_fund_report_for_small_screen.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('FundInfo');

class KnowFundReport extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Map<String, dynamic> responseData;

  const KnowFundReport(
    this.model, {
    Key key,
    this.analytics,
    this.observer,
    this.responseData,
  }) : super(key: key);

  @override
  _KnowFundReportState createState() => _KnowFundReportState();
}

class _KnowFundReportState extends State<KnowFundReport> {
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
          return KnowFundReportForLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
          );
        } else if (sizingInformation.isTablet) {
          return KnowFundReportForMediumScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
          );
        } else {
          return KnowFundReportForSmallScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
          );
        }
      },
    );
  }
}
