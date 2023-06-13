import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/portfolio_master_selector_for_large.dart';
import 'package:qfinr/pages/analyse/portfolio_master_selector_for_small.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';

final log = getLogger('PortfolioMasterSelector');

class PortfolioMasterSelector extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  final String layout;

  final String portfolioMasterID;
  final String isSideMenuHeadingSelected;
  final String isSideMenuSelected;

  PortfolioMasterSelector(this.model,
      {this.analytics,
      this.observer,
      this.action,
      this.portfolioMasterID = "",
      this.layout = "checkbox",
      this.isSideMenuHeadingSelected,
      this.isSideMenuSelected});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioMasterSelectorState();
  }
}

class _PortfolioMasterSelectorState extends State<PortfolioMasterSelector> {

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isMobile) {
          return PortfolioMasterSelectorSmall(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            portfolioMasterID: widget.portfolioMasterID,
            layout: widget.layout,
            isSideMenuHeadingSelected: widget.isSideMenuHeadingSelected,
            isSideMenuSelected: widget.isSideMenuSelected,
          );
        } else if (sizingInformation.isTablet) {
          return PortfolioMasterSelectorLarge(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            portfolioMasterID: widget.portfolioMasterID,
            layout: widget.layout,
            isSideMenuHeadingSelected: widget.isSideMenuHeadingSelected,
            isSideMenuSelected: widget.isSideMenuSelected,
          );
        } else {
          return PortfolioMasterSelectorLarge(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            portfolioMasterID: widget.portfolioMasterID,
            layout: widget.layout,
            isSideMenuHeadingSelected: widget.isSideMenuHeadingSelected,
            isSideMenuSelected: widget.isSideMenuSelected,
          );
        }
      },
    );
  }
}
