import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/explore_ideas/large_explore_ideas.dart';
import 'package:qfinr/pages/explore_ideas/small_explore_ideas.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('ExploreScreen');

class ExploreScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final Map responseData;

  ExploreScreen(this.model, {this.analytics, this.observer, this.responseData});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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
            return LargeExploreScreen(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                responseData: widget.responseData);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return LargeExploreScreen(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                responseData: widget.responseData);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.watch) {
            return Container();
          }
          return SmallExploreScreen(widget.model,
              analytics: widget.analytics,
              observer: widget.observer,
              responseData: widget.responseData);
        },
      );
}
