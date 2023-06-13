import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/invite_friends/invitations/invite_ref_code_for_large.dart';
import 'package:qfinr/pages/invite_friends/invitations/invite_ref_code_for_samll.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../models/main_model.dart';

class InvitationRefCode extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

//
  InvitationRefCode(
    this.model, {
    this.analytics,
    this.observer,
  });

  @override
  State<StatefulWidget> createState() {
    return InvitationRefCodeState();
  }
}

class InvitationRefCodeState extends State<InvitationRefCode> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return InvitationRefCodeSmall(widget.model,
            analytics: widget.analytics, observer: widget.observer);
      } else if (sizingInformation.isTablet) {
        return InvitationRefCodeLarge(
          widget.model,
          analytics: widget.analytics,
          observer: widget.observer,
        );
      } else {
        return InvitationRefCodeLarge(
          widget.model,
          analytics: widget.analytics,
          observer: widget.observer,
        );
      }
    });
  }
}
