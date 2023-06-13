import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_detail_for_large.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_detail_for_small.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../models/main_model.dart';

//
class PortfolioAnalyzerDetail extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Map<String, dynamic> responseData;

  final int tabIndex;

  Map selectedPortfolioMasterIDs;
  String benchmark;

  PortfolioAnalyzerDetail(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs,
      this.benchmark,
      this.tabIndex});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerDetailState();
  }
}

class _PortfolioAnalyzerDetailState extends State<PortfolioAnalyzerDetail>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return PortfolioAnalyzerDetailSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark,
            tabIndex: widget.tabIndex);
      } else if (sizingInformation.isTablet) {
        return PortfolioAnalyzerDetailSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark,
            tabIndex: widget.tabIndex);
      } else {
        return PortfolioAnalyzerDetailLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark,
            tabIndex: widget.tabIndex);
      }
    });
  }
}
