import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/dividend_report/portfolio_dividend_report_for_large.dart';
import 'package:qfinr/pages/analyse/dividend_report/portfolio_dividend_report_for_small.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../models/main_model.dart';

final log = getLogger('PortfolioDividendReport');

class PortfolioDividendReport extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Map responseData;

  PortfolioDividendReport(this.model,
      {this.analytics, this.observer, this.responseData});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioDividendReportState();
  }
}

class _PortfolioDividendReportState extends State<PortfolioDividendReport> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return PortfolioDividendReportSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData);
      } else if (sizingInformation.isTablet) {
        return PortfolioDividendReportLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData);
      } else {
        return PortfolioDividendReportLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData);
      }
    });
  }
}
