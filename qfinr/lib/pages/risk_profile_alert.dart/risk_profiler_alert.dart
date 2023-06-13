import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/pages/risk_profile_alert.dart/risk_profile_alert_for_large.dart';
import 'package:qfinr/pages/risk_profile_alert.dart/risk_profile_alert_for_small.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';

final log = getLogger('RiskProfilerAlert');

class RiskProfilerAlert extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  Map selectedPortfolioMasterIDs;

  RiskProfilerAlert(this.model,
      {this.analytics,
      this.observer,
      this.action = "",
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _RiskProfilerAlertState();
  }
}

class _RiskProfilerAlertState extends State<RiskProfilerAlert> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
    );
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return RiskProfilerAlertSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      } else if (sizingInformation.isTablet) {
        return RiskProfilerAlertLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      } else {
        return RiskProfilerAlertLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      }
    });
  }
}
