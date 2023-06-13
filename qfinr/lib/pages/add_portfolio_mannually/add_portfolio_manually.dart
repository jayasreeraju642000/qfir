import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio_mannually/add_portfolio_mannually_small.dart';
import 'package:qfinr/pages/add_portfolio_mannually/add_portfolio_manually_large.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('AddPortfolioManuallyPage');

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

// shariyath
class AddPortfolioManuallyPage extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer; //

  String pageType;
  String action;

  int portfolioIndex;

  String portfolioMasterID;
  String portfolioDepositID;
  bool viewDeposit = false;
  Map selectedPortfolioMasterIDs;
  Map arguments;

  AddPortfolioManuallyPage(this.model,
      {this.analytics,
      this.observer,
      this.pageType = "add_portfolio",
      this.action = "newPortfolio",
      this.portfolioIndex = null,
      this.portfolioMasterID,
      this.viewDeposit,
      this.portfolioDepositID,
      this.selectedPortfolioMasterIDs,
      this.arguments});

  @override
  State<StatefulWidget> createState() {
    return _AddPortfolioManuallyPageState();
  }
}

class _AddPortfolioManuallyPageState extends State<AddPortfolioManuallyPage> {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isDesktop) {
          return AddPortfolioManuallyLarge(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            pageType: widget.pageType,
            action: widget.action,
            portfolioIndex: widget.portfolioIndex,
            portfolioMasterID: widget.portfolioMasterID,
            viewDeposit: widget.viewDeposit,
            portfolioDepositID: widget.portfolioDepositID,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            arguments: widget.arguments,
          );
        } else if (sizingInformation.isTablet) {
          return AddPortfolioManuallyLarge(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            pageType: widget.pageType,
            action: widget.action,
            portfolioIndex: widget.portfolioIndex,
            portfolioMasterID: widget.portfolioMasterID,
            viewDeposit: widget.viewDeposit,
            portfolioDepositID: widget.portfolioDepositID,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            arguments: widget.arguments,
          );
        } else {
          return AddPortfolioManuallySmallPage(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            pageType: widget.pageType,
            action: widget.action,
            portfolioIndex: widget.portfolioIndex,
            portfolioMasterID: widget.portfolioMasterID,
            viewDeposit: widget.viewDeposit,
            portfolioDepositID: widget.portfolioDepositID,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            arguments: widget.arguments,
          );
        }
      },
    );
  }
}
