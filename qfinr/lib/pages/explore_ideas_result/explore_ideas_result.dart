import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/explore_ideas/small_explore_ideas.dart';
import 'package:qfinr/pages/explore_ideas_result/large_explore_ideas_result.dart';
import 'package:qfinr/pages/explore_ideas_result/small_explore_ideas_result.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('ExploreIdeasResultScreen');

class ExploreIdeasResultScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final List<Filter> selectedFilter;

  ExploreIdeasResultScreen(this.model,
      {this.analytics, this.observer, this.selectedFilter});

  @override
  _ExploreIdeasResultScreenState createState() =>
      _ExploreIdeasResultScreenState();
}

class _ExploreIdeasResultScreenState extends State<ExploreIdeasResultScreen> {
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
            return LargeExploreIdeasResultScreen(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                selectedFilter: widget.selectedFilter);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return LargeExploreIdeasResultScreen(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                selectedFilter: widget.selectedFilter);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.watch) {
            return Container();
          }
          return SmallExploreIdeasResultScreen(widget.model,
              analytics: widget.analytics,
              observer: widget.observer,
              selectedFilter: widget.selectedFilter);
        },
      );
}
