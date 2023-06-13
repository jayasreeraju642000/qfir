import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/profile_risk/risk_profiler_for_small_screen.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../models/main_model.dart';
import 'risk_profiler_for_large_screen.dart';

final log = getLogger('RiskProfiler');

class RiskProfiler extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  RiskProfiler(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _RiskProfiler();
  }
}

class _RiskProfiler extends State<RiskProfiler> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.isMobile) {
          return _forSmallSizedScreen();
        } else if (sizingInformation.isTablet) {
          return _forMediumSizedScreen();
        } else {
          return _forLargeScreen();
        }
      },
    );
  }

  Widget _forLargeScreen() {
    return RiskProfilerForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forMediumSizedScreen() {
    return RiskProfilerForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forSmallSizedScreen() {
    return RiskProfilerForSmallScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }
}
