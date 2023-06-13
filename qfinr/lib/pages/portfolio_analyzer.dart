import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('PortfolioAnalyzer');

class PortfolioAnalyzer extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool viewOnly;

  PortfolioAnalyzer(this.model,
      {this.analytics, this.observer, this.viewOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerState();
  }
}

class _PortfolioAnalyzerState extends State<PortfolioAnalyzer> {
  final controller = ScrollController();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  final portfolioNameFocusNode = new FocusNode();

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Analyzer',
        screenClassOverride: 'PortfolioAnalyzer');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Analyzer",
    });
  }

  @override
  void initState() {
    super.initState();

    _currentScreen();
    _addEvent();

    setState(() {
      widget.model.redirectBase = "/portfolioAnalyzer";
    });
  }

  @override
  Widget build(BuildContext context) {
    //changeStatusBarColor(Color(0xffefd82b));
    changeStatusBarColor(Color(0xff0445e4));
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: WidgetDrawer(),
        bottomNavigationBar: widgetBottomNavBar(context, 2),
        body: _buildBody(),
      );
    });
  }

  PreferredSizeWidget _appbarMenuIconWeb() {
    return AppBar(
      backgroundColor: Color(0xff0445e4),
      elevation: 0.0,
      title: Text(""),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      return mainContainer(
        context: context,
        paddingBottom: 0,
        containerColor: Colors.white,
        child: _buildBodyContent(),
      );
    }
  }

  Widget _buildBodyContent() {
    List<Widget> _children = [];
    _children.add(!kIsWeb
        ? commonScrollAppBar(
            controller: controller,
            leading: GestureDetector(
              onTap: () => _scaffoldKey.currentState.openDrawer(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(
                    getScaledValue(Platform.isAndroid ? 17 : 12)),
                height: getScaledValue(5),
                child: svgImage('assets/icon/icon_menu.svg'),
              ),
            ),
          )
        : _appbarMenuIconWeb());
    _children.add(Container(
      height: 315,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 200,
              padding: EdgeInsets.all(getScaledValue(16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0445e4),
                    Color(0xff1181ff)
                  ] /* [Color(0xffefd82b), Color(0xfffdbf27)] */,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Analyse Portfolios", style: appBodyText2),
                  Text(
                    "Select multiple portfolios for an in-depth review. Compare risks and returns against benchmarks and most popular ETFs. Identify and evaluate multiple factors that drive portfolio performance and contribute to risks. Measure their resilience during periods of high stress, and more....",
                    style: bodyText1.copyWith(
                      color: Color(0xffcee1ff),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 165,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                toolShortcut(
                  "assets/icon/icon_analyse.svg",
                  "Summary",
                  "Summary statistics and correlation at the Portfolio and Instrument level",
                  linkCaption: "Start Now",
                  navigation: '/analyse_summary',
                ),
              ],
            ),
          ),
        ],
      ),
    ));

    _children.add(
      toolShortcut(
        "assets/icon/icon_analyse.svg",
        "Portfolio Analyzer",
        "Deep dive into your portfolios. Compare against benchmarks. Understand their suitability and lots more...",
        linkCaption: "Start Now",
        navigation: riskProfileSamplePortfolio(
            model: widget.model,
            desiredPath: 'portfolio_master_selectors/analyzer/mobile',
            riskProfilerPath: 'riskProfilerAlert/analyzer/mobile'),
        navigationArguments: {
          'portfolioMasterID': '',
          'layout': 'border',
        },
      ),
    );

    _children.add(
      toolShortcut(
        "assets/icon/icon_compare_portfolios.svg",
        "Cashflow Forecasts",
        "Get a breakdown of forecasted cash flows over the next 6 months for dividends from equity, interest and principal flows from bonds and deposits",
        linkCaption: "Start Now",
        navigation: (widget.model.userRiskProfile != null
            ? "/portfolio_master_selectors/dividend"
            : "/riskProfilerAlert/dividend/mobile"),
        navigationArguments: {
          'portfolioMasterID': '',
          'layout': 'border',
        },
      ),
    );

    _children.add(
      toolShortcut(
        "assets/icon/icon_stress_test.svg",
        "Stress Test",
        "Compare the historical performance of your portfolio during periods of high stress in the markets",
        linkCaption: "Start Now",
        navigation: (widget.model.userRiskProfile != null
            ? "/portfolio_master_selectors/stress"
            : "/riskProfilerAlert/dividend/mobile"),
        navigationArguments: {
          'portfolioMasterID': '',
          'layout': 'border',
        },
      ),
    );

    return ListView(
      physics: ClampingScrollPhysics(),
      children: _children,
    );
  }

  Widget toolShortcut(String imgPath, String title, String description,
      {String navigation = "",
      var navigationArguments,
      bool alertType = false,
      String linkCaption}) {
    return widgetCard(
        boxShadow: false,
        child: GestureDetector(
            onTap: () {
              if (navigation != "") {
                Navigator.pushNamed(context, navigation,
                        arguments: navigationArguments)
                    .then((_) => changeStatusBarColor(appBarBGColor));
              }
            },
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: svgImage(
                      imgPath,
                      width: getScaledValue(33),
                    ),
                  ),
                  SizedBox(width: getScaledValue(15)),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title,
                          style: alertType
                              ? appBodyText1.copyWith(color: Color(0xff707070))
                              : appBodyH3),
                      alertType
                          ? Divider(
                              height: 20,
                              color: Color(0xffededed),
                            )
                          : emptyWidget,
                      Text(description,
                          style:
                              appBodyText1.copyWith(color: Color(0xff707070))),
                      SizedBox(height: getScaledValue(16)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(linkCaption, style: textLink),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: colorBlue,
                            size: getScaledValue(15),
                          )
                        ],
                      )
                    ],
                  )),
                ])));
  }
}
