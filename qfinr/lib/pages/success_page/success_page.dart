import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/success_page/success_page_for_small_screen.dart';
import 'package:qfinr/pages/success_page/success_page_for_large_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SuccessPage extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  String action;

  Map arguments;

  SuccessPage(
    this.model, {
    this.analytics,
    this.observer,
    this.action = "edit",
    this.arguments,
  });

  @override
  State<StatefulWidget> createState() {
    return _SuccessPageState();
  }
}

class _SuccessPageState extends State<SuccessPage> {
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
    return SuccessPageForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
      action: widget.action,
      arguments: widget.arguments,
    );
  }

  Widget _forMediumSizedScreen() {
    return SuccessPageForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
      action: widget.action,
      arguments: widget.arguments,
    );
  }

  Widget _forSmallSizedScreen() {
    return SuccessPageForSmallScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
      action: widget.action,
      arguments: widget.arguments,
    );
  }
}
