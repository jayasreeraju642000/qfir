import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('RiskProfilerAlert');

class RiskProfilerAlertSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  Map selectedPortfolioMasterIDs;

  RiskProfilerAlertSmall(this.model,
      {this.analytics,
      this.observer,
      this.action = "",
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _RiskProfilerAlertState();
  }
}

class _RiskProfilerAlertState extends State<RiskProfilerAlertSmall> {
  final controller = ScrollController();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
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
    return Scaffold(
        appBar: commonScrollAppBar(
          controller: controller,
          bgColor: Colors.white,
        ),
        body: mainContainer(
            containerColor: Colors.white,
            context: context,
            paddingLeft: getScaledValue(16),
            paddingRight: getScaledValue(16),
            child: _missingRiskProfile()));
  }

  Widget _missingRiskProfile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
              horizontal: getScaledValue(35), vertical: getScaledValue(45)),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xffd4d4d4)),
              borderRadius: BorderRadius.circular(getScaledValue(7))),
          child: Column(
            children: [
              svgImage("assets/icon/icon_riskProfiler.svg",
                  height: getScaledValue(99)),
              SizedBox(height: getScaledValue(34)),
              Text("Looks like you haven’t assessed your risk tolerance",
                  style: headline5, textAlign: TextAlign.center),
              SizedBox(height: getScaledValue(15)),
              Text(
                widget.action == "fund"
                    ? "Sorry, we cannot evaluate a fund till we know more about your risk tolerance limits"
                    : "Sorry, we cannot analyze your portfolio till we know more about your risk tolerance limits",
                style: bodyText5,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: getScaledValue(15)),
        gradientButton(
            context: context,
            caption: "Take Profile Analysis",
            onPressFunction: () =>
                Navigator.pushNamed(context, '/riskProfiler')),
        SizedBox(height: getScaledValue(15)),
        flatButtonText("Go Back",
            textColor: colorBlue,
            fontSize: getScaledValue(12),
            fontWeight: FontWeight.w600,
            onPressFunction: () => Navigator.pop(context)),
      ],
    );
  }
}
