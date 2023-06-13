import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/benchmark_selector/benchmark_selector_for_large.dart';
import 'package:qfinr/pages/benchmark_selector/benchmark_selector_for_samll.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('BenchmarkSelector');

class BenchmarkSelector extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  final Map selectedPortfolioMasterIDs;

  BenchmarkSelector(this.model,
      {this.analytics,
      this.observer,
      this.action = "",
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _BenchmarkSelectorState();
  }
}

class _BenchmarkSelectorState extends State<BenchmarkSelector>
    with SingleTickerProviderStateMixin {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isMobile) {
        return BenchmarkSelectorSmall(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      } else if (sizingInformation.isTablet) {
        return BenchmarkSelectorLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      } else {
        return BenchmarkSelectorLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            action: widget.action,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs);
      }
    });
  }
}
