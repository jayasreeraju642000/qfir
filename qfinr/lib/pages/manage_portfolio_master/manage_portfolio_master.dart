import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_manage_portfolio_master.dart';
import 'package:qfinr/pages/manage_portfolio_master/small_manage_portfolio_master.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../../models/main_model.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('ManagePortfolioMaster');

class ManagePortfolioMaster extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool viewOnly;

  ManagePortfolioMaster(this.model,
      {this.analytics, this.observer, this.viewOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _ManagePortfolioMasterState();
  }
}

class _ManagePortfolioMasterState extends State<ManagePortfolioMaster> {
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
            return LargeManagePortfolioMaster(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                viewOnly: widget.viewOnly);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return LargeManagePortfolioMaster(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                viewOnly: widget.viewOnly);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.watch) {
            return Container();
          }
          return SmallManagePortfolioMaster(widget.model,
              analytics: widget.analytics,
              observer: widget.observer,
              viewOnly: widget.viewOnly);
        },
      );
}
