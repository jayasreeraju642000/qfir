import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/notifications/notification_for_large_screen.dart';
import 'package:qfinr/pages/notifications/notification_for_small_screen.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';

final log = getLogger('NotificationPage');

class NotificationPage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  NotificationPage(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  bool isNotificationOn;
  TabController controller;

  Map notifications = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    //animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return NotificationPageSmall(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      } else if (sizingInformation.isTablet) {
        return NotificationPageLarge(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      } else {
        return NotificationPageLarge(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      }
    });
  }
}
