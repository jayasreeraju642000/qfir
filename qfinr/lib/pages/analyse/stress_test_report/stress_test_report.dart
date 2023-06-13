import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:qfinr/pages/analyse/stress_test_report/stress_test_report_for_large.dart';
import 'package:qfinr/pages/analyse/stress_test_report/stress_test_report_for_small.dart';

import 'package:responsive_builder/responsive_builder.dart';

import '../../../models/main_model.dart';

class StressTestReport extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Map<String, dynamic> responseData;

  Map selectedPortfolioMasterIDs;

  StressTestReport(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _StressTestReportState();
  }
}

class _StressTestReportState extends State<StressTestReport> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return StressTestReportSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      } else if (sizingInformation.isTablet) {
        return StressTestReportLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      } else {
        return StressTestReportLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      }
    });
  }
}
