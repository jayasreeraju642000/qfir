import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/portfolio_import_excel/portfolio_import_excel_for_large_screen.dart';
import 'package:qfinr/pages/portfolio_import_excel/portfolio_import_excel_for_small_screen.dart';

import 'package:responsive_builder/responsive_builder.dart';

class PortfolioImportExcel extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  PortfolioImportExcel(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioImportExcelState();
  }
}

class _PortfolioImportExcelState extends State<PortfolioImportExcel> {
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
    return PortfolioImportExcelForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forMediumSizedScreen() {
    return PortfolioImportExcelForLargeScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }

  Widget _forSmallSizedScreen() {
    return PortfolioImportExcelForSmallScreen(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
    );
  }
}
