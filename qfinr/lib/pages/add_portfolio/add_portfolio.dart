import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio/add_porfolio_large_screen.dart';
import 'package:qfinr/pages/add_portfolio/add_portfolio_small_screen.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('AddPortfolioPage');

class AddPortfolioPage extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  AddPortfolioPage(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _AddPortfolioPageState();
  }
}

class _AddPortfolioPageState extends State<AddPortfolioPage> {
  final controller = ScrollController();

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n _analyticsCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'portfolio',
      screenClassOverride: 'portfolio',
    );
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Add Portfolio Page",
    });
  }

  @override
  void initState() {
    super.initState();

    _analyticsCurrentScreen();
    _addEvent();
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isDesktop) {
          return AddPortfolioLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
          );
        } else if (sizingInformation.isTablet) {
          return AddPortfolioLargeScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
          );
        } else {
          return AddPortfolioForSmallScreen(
            widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
          );
        }
      },
    );
  }

  // Widget _buildBody(){
  // 	return ListView(
  //     physics: ClampingScrollPhysics(),
  // 		children: <Widget>[
  // 			Container(
  // 				margin: EdgeInsets.symmetric(vertical: getScaledValue(30), horizontal: getScaledValue(16)),
  // 				child: Column(
  // 					crossAxisAlignment: CrossAxisAlignment.start,
  // 					children: <Widget>[
  // 						Text("Add new portfolio", style: headline1,),
  // 						SizedBox(height: getScaledValue(3)),
  // 						Text("Create new portfolios of your current holdings across stocks, bonds, mutual funds, ETFs and more", style: bodyText1),
  // 					],
  // 				),
  // 			),
  // 			toolShortcut("assets/icon/icon_import_excel.png", "Import from Excel", "Upload an excel with holdings details from your favourite broker, or via Qfinr template", navigation: '/portfolio_import_excel' ),
  // 			toolShortcut("assets/icon/icon_add_manually.png", "Add Manually", "Add/edit all holdings right here", navigation: "/add_portfolio_manually"),
  // 			toolShortcut("assets/icon/icon_statement.png", "Upload Statements", "Coming soon!"),
  // 		],
  // 	);
  // }

  // Widget toolShortcut(String imgPath, String title, String description, {String navigation = "", bool alertType = false}){
  // 	return GestureDetector(
  // 		onTap: (){
  //       if(navigation=='/portfolio_import_excel') {
  //         _analyticsClickImportFromExelEvent();
  //       } else if(navigation == '/add_portfolio_manually') {
  //         _analyticsClickAddmanuallyEvent();
  //       }
  // 			if(navigation != ""){
  // 				Navigator.pushNamed(context, navigation);
  // 			}
  // 		},
  // 		child: widgetCard(
  // 			boxShadow: false,
  // 			child: Row(
  // 				crossAxisAlignment: CrossAxisAlignment.start,
  // 				mainAxisAlignment: MainAxisAlignment.start,
  // 				children: <Widget>[
  // 					Container(
  // 						child: Image.asset(
  // 							imgPath,
  // 							width: getScaledValue(19),
  // 						),
  // 					),

  // 					SizedBox(width: getScaledValue(15)),

  // 					Expanded(child: Column(
  // 						crossAxisAlignment: CrossAxisAlignment.start,
  // 						children: <Widget>[
  // 							Text(title, style: appBodyH3),
  // 							Text(description, style: appBodyText1.copyWith(color: Color(0xff707070)))
  // 						],
  // 					)),
  // 					navigation != "" ? Icon(Icons.chevron_right, color: Color(0xff959595)) : emptyWidget,

  // 				]
  // 			)
  // 		)
  // 	);
  // }

}
