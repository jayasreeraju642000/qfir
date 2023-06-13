import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/discover/discover_for_large_screen.dart';
import 'package:qfinr/pages/discover/discover_for_small_screen.dart';
import 'package:qfinr/pages/discover/discover_for_medium_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DiscoverPage extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  DiscoverPage(this.model, {this.analytics, this.observer});

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isDesktop) {
          return DiscoverForLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
          );
        } else if (sizingInformation.isTablet) {
          return DiscoverForMediumScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
          );
        } else {
          return DiscoverForSmallScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
          );
        }
      },
    );
  }
}
