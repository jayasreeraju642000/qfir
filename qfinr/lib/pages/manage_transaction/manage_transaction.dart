import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_transaction/large_manage_transaction.dart';
import 'package:qfinr/pages/manage_transaction/small_manage_transaction.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('ManageTransactionPage');

class ManageTransactionPage extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  String portfolioMasterID;

  String action;

  String mode;
  bool ricSelected;
  String ricType;
  String ricZone;
  String ricName;
  String ricIndex;

  bool readOnly;

  Map portfolioMasterData;

  Map arguments;

  final Function() refreshParentState;

  ManageTransactionPage(this.model,
      {this.analytics,
      this.observer,
      this.action = "edit",
      this.portfolioMasterID,
      this.ricSelected,
      this.ricType,
      this.ricZone,
      this.ricName,
      this.ricIndex,
      this.portfolioMasterData,
      this.mode = "edit",
      this.refreshParentState,
      this.arguments,
      this.readOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _ManageTransactionPageState();
  }
}

class _ManageTransactionPageState extends State<ManageTransactionPage> {
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
            return LargeManageTransactionPage(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                action: widget.action,
                portfolioMasterID: widget.portfolioMasterID,
                ricSelected: widget.ricSelected,
                ricType: widget.ricType,
                ricZone: widget.ricZone,
                ricName: widget.ricName,
                ricIndex: widget.ricIndex,
                portfolioMasterData: widget.portfolioMasterData,
                mode: widget.mode,
                refreshParentState: widget.refreshParentState,
                arguments: widget.arguments,
                readOnly: widget.readOnly);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return LargeManageTransactionPage(widget.model,
                analytics: widget.analytics,
                observer: widget.observer,
                action: widget.action,
                portfolioMasterID: widget.portfolioMasterID,
                ricSelected: widget.ricSelected,
                ricType: widget.ricType,
                ricZone: widget.ricZone,
                ricName: widget.ricName,
                ricIndex: widget.ricIndex,
                portfolioMasterData: widget.portfolioMasterData,
                mode: widget.mode,
                refreshParentState: widget.refreshParentState,
                arguments: widget.arguments,
                readOnly: widget.readOnly);
          }
          if (sizingInformation.deviceScreenType == DeviceScreenType.watch) {
            return Container();
          }
          return SmallManageTransactionPage(widget.model,
              analytics: widget.analytics,
              observer: widget.observer,
              action: widget.action,
              portfolioMasterID: widget.portfolioMasterID,
              ricSelected: widget.ricSelected,
              ricType: widget.ricType,
              ricZone: widget.ricZone,
              ricName: widget.ricName,
              ricIndex: widget.ricIndex,
              portfolioMasterData: widget.portfolioMasterData,
              mode: widget.mode,
              refreshParentState: widget.refreshParentState,
              arguments: widget.arguments,
              readOnly: widget.readOnly);
        },
      );
}
