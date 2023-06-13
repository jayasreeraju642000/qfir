import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/home/home_new_for_medium_screen.dart';

import 'package:qfinr/utils/log_printer.dart';

import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';

import 'package:qfinr/pages/home/home_new_for_large_screen.dart';
import 'package:qfinr/pages/home/home_new_for_small_screen.dart';

final log = getLogger('HomePageNew');

class HomePageNew extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String basketIndex = '1';

  HomePageNew(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _HomePageNewState();
  }
}

class _HomePageNewState extends State<HomePageNew> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  refreshParent() => setState(() {});

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return HomePageSmall(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      } else if (sizingInformation.isTablet) {
        return DashBoardTablet(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      } else {
        return DashBoard(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      }
    });
  }
}
