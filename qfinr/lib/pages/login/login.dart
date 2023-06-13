import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/login/login_for_small_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../models/main_model.dart';
import 'login_for_large_screen.dart';

class LoginPage extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  LoginPage(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
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
    return LoginForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forMediumSizedScreen() {
    return LoginForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forSmallSizedScreen() {
    return LoginForSmallScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }
}
