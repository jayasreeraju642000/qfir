import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_portfolio/large_manage_portfolio.dart';
import 'package:qfinr/pages/manage_portfolio/small_manage_portfolio.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('ManagePortfolio');

class ManagePortfolio extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  bool managePortfolio;
  bool reloadData;

  bool newPortfolio;
  String portfolioName;

  String portfolioMasterID;

  bool viewPortfolio;
  bool readOnly;

  ManagePortfolio(this.model,
      {this.analytics,
      this.observer,
      this.portfolioMasterID,
      this.managePortfolio = true,
      this.reloadData = true,
      this.viewPortfolio = false,
      this.newPortfolio = false,
      this.portfolioName,
      this.readOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _ManagePortfolioState();
  }
}

class _ManagePortfolioState extends State<ManagePortfolio> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        360,
        640,
      ),
    );
    return _buildBody();
  }

  Widget _buildBody() => ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            return LargeManagePortfolio(
              widget.model,
              analytics: widget.analytics,
              observer: widget.observer,
              portfolioMasterID: widget.portfolioMasterID,
              managePortfolio: widget.managePortfolio = true,
              reloadData: widget.reloadData = true,
              viewPortfolio: widget.viewPortfolio = false,
              newPortfolio: widget.newPortfolio = false,
              portfolioName: widget.portfolioName,
              readOnly: widget.readOnly = false,
            );
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return LargeManagePortfolio(
              widget.model,
              analytics: widget.analytics,
              observer: widget.observer,
              portfolioMasterID: widget.portfolioMasterID,
              managePortfolio: widget.managePortfolio = true,
              reloadData: widget.reloadData = true,
              viewPortfolio: widget.viewPortfolio = false,
              newPortfolio: widget.newPortfolio = false,
              portfolioName: widget.portfolioName,
              readOnly: widget.readOnly = false,
            );
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.watch) {
            return Container();
          }
          return SmallManagePortfolio(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            portfolioMasterID: widget.portfolioMasterID,
            managePortfolio: widget.managePortfolio = true,
            reloadData: widget.reloadData = true,
            viewPortfolio: widget.viewPortfolio = false,
            newPortfolio: widget.newPortfolio = false,
            portfolioName: widget.portfolioName,
            readOnly: widget.readOnly = false,
          );
        },
      );
}
