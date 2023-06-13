import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/report/portfolio_analyzer_report_for_large.dart';
import 'package:qfinr/pages/analyse/report/portfolio_analyzer_report_for_medium.dart';
import 'package:qfinr/pages/analyse/report/portfolio_analyzer_report_for_small.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../models/main_model.dart';

class PortfolioAnalyzerReport extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final dynamic responseData;

  Map selectedPortfolioMasterIDs;
  String benchmark;

  PortfolioAnalyzerReport(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs,
      this.benchmark});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerReportState();
  }
}

class _PortfolioAnalyzerReportState extends State<PortfolioAnalyzerReport> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return PortfolioAnalyzerReportSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark);
      } else if (sizingInformation.isTablet) {
        return PortfolioAnalyzerReportMedium(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark);
      } else {
        return PortfolioAnalyzerReportLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark);
      }
    });
  }
}
