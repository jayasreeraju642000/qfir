import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/controller_switch.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

import '../../../models/main_model.dart';
import '../../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('PortfolioAnalyzerReport');

class PortfolioAnalyzerReportSmall extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final dynamic responseData;

  Map selectedPortfolioMasterIDs;
  String benchmark;

  PortfolioAnalyzerReportSmall(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs,
      this.benchmark});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerReportState();
  }
}

class _PortfolioAnalyzerReportState
    extends State<PortfolioAnalyzerReportSmall> {
  final controller = ScrollController();

  bool _loading = false;
  bool widgetExpanded = false;
  bool widgetExpandedRating = false;

  Map fundData;

  String _selectedMarket;
  String _performanceTenure = "3year";
  List<Map<String, String>> markets = [];

  String chartType = "chart";

  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Analyzer Report',
        screenClassOverride: 'PortfolioAnalyzerReport');
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Analyzer Report",
    });
  }

  Future<Null> _analyticsSuitabilityClickEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "analysis_result_details",
      'item_name': "analysis_result_details_suitability",
      'content_type': "click_suitability_tab",
    });
  }

  Future<Null> _analyticsSummaryClickEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "analysis_result_details",
      'item_name': "analysis_result_details_summary",
      'content_type': "click_summary_tab",
    });
  }

  Future<Null> _analyticsKeyStaticsClickEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "analysis_result_details",
      'item_name': "analysis_result_details_key_statistics",
      'content_type': "click_key_statistics",
    });
  }

  Future<Null> _analyticsPerformanceComparisonClickEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "analysis_result_details",
      'item_name': "analysis_result_details_performance_comparison",
      'content_type': "click_comparison_index_tab",
    });
  }

  Future<Null> _analyticsBenchmarkToggleEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "portfolio_analysis_result",
      'item_name': "portfolio_analysis_result_bench_mark",
      'content_type': "bench_mark_toggle_button",
    });
  }

  Future<Null> _analyticsDurationToggleEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "portfolio_analysis_result",
      'item_name': "portfolio_analysis_result_duration",
      'content_type': "duration_toggle_button",
    });
  }

  Future<Null> _analyticMoreButtonEvent() async {
    String portfoliovalues = "";
    widget.selectedPortfolioMasterIDs.forEach((key, value) {
      if (value == true) {
        portfoliovalues +
            "," +
            widget.model.userPortfoliosData[key]['portfolio_name'];
      }
    });
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "portfolio_analysis_result",
      'item_name': "portfolio_analysis_result_view_more",
      'content_type': "click_view_more",
      'portfolio_analysis': portfoliovalues
    });
  }

  @override
  void initState() {
    super.initState();

    fundData = widget.responseData['response']['data'];

    var graphData = widget
        .responseData['response']['navGraphData']['graphData'].entries
        .toList();
    _selectedMarket = graphData[0].key;

    widget.responseData['response']['navGraphData']['markets']
        .forEach((key, value) {
      markets.add({"value": key, "title": value});
    });

    _analyticsCurrentScreen();
    _analyticsAddEvent();
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Color(0xffefd82b));
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        //drawer: WidgetDrawer(),
        appBar: commonScrollAppBar(
            controller: controller,
            bgColor: Color(0xffefd82b),
            brightness: Brightness.light,
            actions: [
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, widget.model.redirectBase),
                child: AppbarHomeButton(),
              )
            ]),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      return mainContainer(
          context: context,
          paddingBottom: 0,
          containerColor: Colors.white,
          child:
              _buildBodyContent()); //_autocompleteTextField(); //_buildBodyContent();

    }
  }

  Widget _buildBodyContent() {
    return listPortfolios();
  }

  Widget listPortfolios() {
    List<Widget> _children = [];

    double containerHeight = 210;
    if (widgetExpanded) containerHeight += 50;
    if (widgetExpandedRating) containerHeight += 260;

    _children.add(Container(
      height: getScaledValue(containerHeight), // 110

      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
                height: getScaledValue(widgetExpanded ? 185.0 : 135.0), // 185
                padding: EdgeInsets.all(10.0),
                //margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffefd82b), Color(0xfffdbf27)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          children: <Widget>[
                            Text("Portfolio Analysis", style: headline1),
                            Text("Benchmark: " + widget.benchmark,
                                style: keyStatsBodyText7),
                          ],
                        )),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widgetExpanded = !widgetExpanded;
                            });
                          },
                          child: Icon(
                            widgetExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: getScaledValue(30),
                          ),
                        )
                      ],
                    ),

                    widgetExpanded
                        ? SizedBox(height: getScaledValue(30))
                        : emptyWidget,

                    ExpandedSection(
                      expand: widgetExpanded,
                      child: SizedBox(
                        height: 45,
                        child: Container(
                          alignment: Alignment.center,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: _selectedPortfolios(),
                            /* <Widget>[
																_portfolioValue("Portfolio XX XXXX", "Rs 14,56,230", includeLeftBorder: false),
																_portfolioValue("Portfolio AAA", "Rs 14,56,230"),
																_portfolioValue("Portfolio CCC", "Rs 14,56,230"),
																_portfolioValue("Portfolio CCC", "Rs 14,56,230"),
																_portfolioValue("Portfolio CCC", "Rs 14,56,230"),
																_portfolioValue("Portfolio CCC", "Rs 14,56,230"),
															], */
                          ),
                        ),
                      ),
                    ),
                    //SizedBox(height: getScaledValue(25),),
                  ],
                )),
          ),
          Positioned(
              top: widgetExpanded ? 160 : 105, // 170
              left: getScaledValue(15.0),
              right: getScaledValue(15.0),
              // width: getScaledValue(330.0),
              height: getScaledValue(widgetExpandedRating ? 375 : 90.0),
              child: analysisScore()),

          /* Positioned(
							top: 110,
							left: getScaledValue(15.0),
							width: getScaledValue(330.0),
							height: getScaledValue(78.0 * widget.model.portfolioTotalSummary.length),
							child: graph()
						) */
        ],
      ),
    ));

    _children.add(sectionSeparator());
    _children.add(graphNav());
    _children.add(sectionSeparator());
    _children.add(description());
    _children.add(sectionSeparator());
    _children.add(tools());
    _children.add(sectionSeparator());
    //_children.add(actionButtons());

    return ListView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      children: _children,
    );
  }

  Widget analysisScore() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: getScaledValue(17), horizontal: getScaledValue(15)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Overall Score",
                              style:
                                  bodyText3.copyWith(color: Color(0xff161616))),
                          SizedBox(width: getScaledValue(5)),
                          InkWell(
                            onTap: () => bottomAlertBox(
                                context: context,
                                title: "Overall Rating",
                                description:
                                    "We rate your portfolio on a proprietary 5 point scale using 3 year historical data across 3 areas: suitability compared to your risk profile, portfolio performance compared to your chosen benchmark and key statistical measures like information ratio and success ratio"),
                            child: svgImage('assets/icon/information.svg',
                                width: getScaledValue(9)),
                          )
                        ],
                      ),
                      //Text("As on " + fundData['data']['latest_date'], style: bodyText8)
                    ],
                  ),
                  SizedBox(height: getScaledValue(6)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        starScore(score: fundData['overall_rating']),
                        GestureDetector(
                            onTap: () {
                              _analyticMoreButtonEvent();
                              setState(() {
                                widgetExpandedRating = !widgetExpandedRating;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                    widgetExpandedRating
                                        ? "view less "
                                        : "view more ",
                                    style: appBenchmarkLink),
                                Icon(
                                  widgetExpandedRating
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: getScaledValue(30),
                                ),
                              ],
                            ))
                      ]),
                ],
              ),
            ),
            widgetExpandedRating
                ? Divider(height: getScaledValue(5))
                : emptyWidget,
            ExpandedSection(
              expand: widgetExpandedRating,
              child: Container(
                //height: 150,
                child: Column(
                  //shrinkWrap: true,
                  //scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                        padding: EdgeInsets.only(
                            top: getScaledValue(15), right: getScaledValue(12)),
                        alignment: Alignment.centerRight,
                        child: Text("1 - Low  |  5 - High ", style: bodyText9)),
                    widgetRating(
                        context: context,
                        title: 'Return Rating',
                        description:
                            "We look at a range of metrics around portfolio returns including information ratio, success ratio and the goodness of fit to the benchmark returns and aggregate these elements into the score",
                        score: fundData['or_score']),
                    //widgetRating(context: context, title: 'Expense Rating', description: "We compare the fund’s expenses against other funds in the same category to arrive at this rating", score: double.parse(fundData['tr_rating'])),
                    widgetRating(
                        context: context,
                        title: 'Alpha Rating',
                        description:
                            "We look for statistical evidence of alpha generation by your portfolio against the benchmark and markets. We run a series of regressions and aggregate the information into this score",
                        score: fundData['alpha_score']),
                    widgetRating(
                        context: context,
                        title: 'Portfolio Suitability',
                        description:
                            "We rate the alignment of your portfolio performance to the risk adjusted returns appropriate for your risk profile. We examine both risk and returns over the last 3 years",
                        score: fundData['port_suit_score']),
                    widgetRiskRating(
                        context: context,
                        title: 'Risk Rating',
                        description:
                            "This is a synthetic risk return indicator based on the volatility of your portfolio. We use 3 year information to categorize the risk of your portfolio into 7 categories, with 7 being the most volatile and 1 the least volatile",
                        score: fundData['srri']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  List<Widget> _selectedPortfolios() {
    List<Widget> _children = [];

    bool firstFlag = false;

    widget.selectedPortfolioMasterIDs.forEach((key, value) {
      if (value == true) {
        _children.add(_portfolioValue(
            widget.model.userPortfoliosData[key]['portfolio_name'],
            widget.model.userPortfoliosData[key]['value'],
            includeLeftBorder: firstFlag));
        firstFlag = true;
      }
    });

    return _children;
  }

  Widget _portfolioValue(String portfolioName, String portfolioValue,
      {bool includeLeftBorder = true}) {
    return Container(
        padding: EdgeInsets.only(
            right: getScaledValue(9),
            left: getScaledValue(includeLeftBorder ? 9 : 0)),
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
          color: Color(0xffdbaa3c),
          width: includeLeftBorder ? 1.0 : 0,
        ))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(portfolioName, style: analysisPortfolioName),
            Text(portfolioValue, style: analysisPortfolioValue),
          ],
        ));
  }

  Widget graph() {
    return Container(
        padding: EdgeInsets.only(
            left: getScaledValue(16.0),
            right: getScaledValue(16.0),
            bottom: getScaledValue(20.0)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Past scores', style: appBodyH3),
                GestureDetector(
                  onTap: () => {},
                  child: Text('How is it calculated?', style: appBenchmarkLink),
                )
              ],
            ),
            SizedBox(height: getScaledValue(10)),
            SimpleLineChart(fixGraphData()),
          ],
        ));
  }

  List<charts.Series<yieldData, DateTime>> fixGraphData() {
    final List<yieldData> yieldDb = [
      yieldData(DateTime.parse('2020-05-24'), 5),
      yieldData(DateTime.parse('2020-06-24'), 5),
      yieldData(DateTime.parse('2020-07-24'), 5),
      yieldData(DateTime.parse('2020-08-24'), 5),
      yieldData(DateTime.parse('2020-09-24'), 5),
    ];

    /* for(int i = 0; i < widget.model.portfolioGraphData.length; i++){
			yieldDb.add(
				yieldData(
					DateTime.parse('2020-09-24'),
					5
					//DateTime.fromMillisecondsSinceEpoch(widget.model.portfolioGraphData[i][0]),
					//widget.model.portfolioGraphData[i][1].toDouble(),
				) 
			);
		} */
    return [
      charts.Series<yieldData, DateTime>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xff787878))),
        domainFn: (yieldData sales, _) => sales.date,
        measureFn: (yieldData sales, _) => sales.total,
        data: yieldDb,
      )
    ];
  }

  Widget description() {
    List<Widget> _doPointers = [];
    List<Widget> _dontPointers = [];

    for (int i = 0; i <= 5; i++) {
      if (fundData['w' + i.toString()] != "" &&
          fundData['w' + i.toString()] != null)
        _doPointers.add(bulletPointer(fundData['w' + i.toString()],
            bulletColor: colorBlue));

      if (fundData['nw' + i.toString()] != "" &&
          fundData['nw' + i.toString()] != null)
        _dontPointers.add(bulletPointer(fundData['nw' + i.toString()],
            bulletColor: colorBlue));
    }

    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: getScaledValue(8)),
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(16), vertical: getScaledValue(24)),
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("What works", style: appBodyH3),
                  SizedBox(height: getScaledValue(10)),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _doPointers),
                ])),
        sectionSeparator(),
        Container(
          margin: EdgeInsets.only(top: getScaledValue(8)),
          padding: EdgeInsets.symmetric(
              horizontal: getScaledValue(16), vertical: getScaledValue(24)),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("What does not work", style: appBodyH3),
              SizedBox(height: getScaledValue(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _dontPointers,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget tools() {
    bool isPortfolioCorelationAvailable = false;
    bool isInstrumentCorelationAvailable = false;
    int tabCount = 0;

    if (widget.responseData['response']['summary'] == null) {
      isPortfolioCorelationAvailable = false;
      isInstrumentCorelationAvailable = false;
    } else if (widget.responseData['response']['summary'] is List) {
      isPortfolioCorelationAvailable = false;
      isInstrumentCorelationAvailable = false;
    } else {
      Map summary = widget.responseData['response']['summary'] as Map;
      summary.forEach((key, value) {
        if (key == "portfolioCorelation") {
          isPortfolioCorelationAvailable = true;
        }
        if (key == "instrumentCorelation") {
          isInstrumentCorelationAvailable = true;
        }
      });
    }
    List<Widget> children = [];
    children.add(
      toolShortcut(
        "assets/icon/icon_analyzer_summary.svg",
        "Summary",
        "Portfolio top 10 holdings; breakdown by Sector, Asset type and Currency....",
        navigation: "/portfolioAnalyzerDetails/$tabCount",
      ),
    );

    children.add(
      toolShortcut(
        "assets/icon/icon_analyzer_stats.svg",
        "Key Statistics",
        "Returns, risks, success rates, draw-downs, sensitivities, and more....",
        navigation: "/portfolioAnalyzerDetails/${++tabCount}",
      ),
    );

    if (isPortfolioCorelationAvailable) {
      children.add(
        toolShortcut(
          "assets/icon/icon_analyzer_summary.svg",
          "Portfolio Statistics",
          "Summary statistics and correlation at the Portfolio level",
          navigation: "/portfolioAnalyzerDetails/${++tabCount}",
        ),
      );
    }

    if (isInstrumentCorelationAvailable) {
      children.add(
        toolShortcut(
          "assets/icon/icon_analyzer_summary.svg",
          "Instrument Statistics",
          "Summary statistics and correlation at the Instrument level",
          navigation: "/portfolioAnalyzerDetails/${++tabCount}",
        ),
      );
    }

    children.add(
      toolShortcut(
        "assets/icon/icon_analyzer_performance.svg",
        "Performance Comparison",
        "Rolling returns and risk-reward comparison with benchmarks and most popular ETFs....",
        navigation: "/portfolioAnalyzerDetails/${++tabCount}",
      ),
    );

    children.add(
      toolShortcut(
        "assets/icon/icon_analyzer_suitability.svg",
        "Risk Tracker",
        "Maximum exposure to this portfolio suitable for you, based on your specific risk tolerance limits....",
        navigation: "/portfolioAnalyzerDetails/${++tabCount}",
      ),
    );

    children.add(
      toolShortcut(
        "assets/icon/icon_analyzer_suitability.svg",
        "Simulated Portfolios",
        "Maximum exposure to this portfolio suitable for you, based on your specific risk tolerance limits....",
        navigation: "/portfolioAnalyzerDetails/${++tabCount}",
      ),
    );

    return Container(
      margin: EdgeInsets.only(top: getScaledValue(8)),
      padding: EdgeInsets.symmetric(vertical: getScaledValue(24)),
      color: Colors.white,
      child: Column(
        children: children,
      ),
    );
  }

  Widget toolShortcut(String imgPath, String title, String description,
      {String navigation = "", bool alertType = false}) {
    return GestureDetector(
        onTap: () {
          switch (title) {
            case "Risk Tracker":
              _analyticsSuitabilityClickEvent();
              break;
            case "Performance Comparison":
              _analyticsPerformanceComparisonClickEvent();
              break;
            case "Key Statistics":
              _analyticsKeyStaticsClickEvent();
              break;
            case "Summary":
              _analyticsSummaryClickEvent();
              break;
          }
          if (navigation != "") {
            Navigator.pushNamed(context, navigation, arguments: {
              'responseData': widget.responseData,
              'selectedPortfolioMasterIDs': widget.selectedPortfolioMasterIDs,
              'benchmark': widget.benchmark
            }).then((_) => changeStatusBarColor(Color(0xffefd82b)));
          }
        },
        child: widgetCard(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Container(
                child: svgImage(
                  imgPath,
                  width: getScaledValue(19),
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
                      style: appBodyText1.copyWith(color: Color(0xff707070)))
                ],
              )),
              Icon(Icons.chevron_right),
            ])));
  }

  Widget actionButtons() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: getScaledValue(17), horizontal: getScaledValue(15)),
      child: Row(
        children: <Widget>[
          Expanded(child: flatButtonText("RETAKE", borderColor: colorBlue)),
          SizedBox(width: getScaledValue(20)),
          Expanded(
              child: gradientButton(
                  context: context, caption: "mail", onPressFunction: () => {}))
        ],
      ),
    );
  }

  Widget graphNav() {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList();

    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              chartType == "chart"
                  ? RichText(
                      text: TextSpan(
                          style: appGraphTitle,
                          text: ("PERFORMANCE VS "),
                          children: [
                          markets.length > 1
                              ? TextSpan(
                                  text: widget.responseData['response']
                                          ['navGraphData']['markets']
                                      [_selectedMarket],
                                  style:
                                      appGraphTitle.copyWith(color: colorBlue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => buildSelectBoxCustom(
                                        context: context,
                                        value: _selectedMarket,
                                        title: 'Select benchmark',
                                        options: markets,
                                        onChangeFunction: marketSelectChange))
                              : TextSpan(
                                  text: widget.responseData['response']
                                          ['navGraphData']['markets']
                                      [_selectedMarket],
                                  style: appGraphTitle),
                          markets.length > 1
                              ? WidgetSpan(
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: colorBlue, size: 14),
                                )
                              : WidgetSpan(child: emptyWidget),
                        ]))
                  : Text("Value over time".toUpperCase(), style: appGraphTitle),
              ControlledSwitch(
                  trackColor: colorBlue,
                  value: chartType == "price" ? true : false,
                  onChanged: (newValue) async {
                    setState(() {
                      _analyticsBenchmarkToggleEvent();
                      if (newValue) {
                        chartType = "price";
                        key.currentState._seriesList = priceChartDataList();
                      } else {
                        chartType = "chart";
                        key.currentState._seriesList = chartDataList();
                      }
                    });
                  }),
            ]),
            SizedBox(height: getScaledValue(25.0)),
            SelectionCallbackExample(chartData, key: key),
            SizedBox(height: getScaledValue(25.0)),
            _basketPerformanceBtns(context),
          ],
        ));
  }

  Widget _basketPerformanceBtns(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _performanceButton(context, '3Y', '3year'),
          _performanceButton(context, '1Y', '1year'),
          _performanceButton(context, '6M', '6months'),
          _performanceButton(context, '3M', '3months'),
          _performanceButton(context, '1M', 'month'),
        ],
      ),
    );
  }

  Widget _performanceButton(BuildContext context, String title, String index) {
    return ButtonTheme(
        minWidth: getScaledValue(60),
        //padding: EdgeInsets.symmetric(horizontal: getScaledValue(6.0)),

        child: RaisedButton(
          elevation: 0,
          padding: EdgeInsets.all(0.0),
          color: _performanceTenure == index ? Color(0xffe2ecff) : Colors.white,
          child: Text(title,
              style: _performanceTenure == index
                  ? appGraphOptBtn.copyWith(color: colorBlue)
                  : appGraphOptBtn),
          onPressed: () {
            _analyticsDurationToggleEvent();
            setState(() {
              _performanceTenure = index;
              if (chartType == "chart") {
                key.currentState._seriesList = chartDataList();
              } else {
                key.currentState._seriesList = priceChartDataList();
              }
            });
          },
          shape: Border(
              bottom: _performanceTenure == index
                  ? BorderSide(
                      width: getScaledValue(2), color: Color(0xff034bd9))
                  : BorderSide(
                      width: getScaledValue(1), color: Color(0xffe9e9e9)),
              top: BorderSide(
                  width: getScaledValue(1), color: Color(0xffe9e9e9)),
              left: BorderSide(
                  width:
                      index == "3year" ? getScaledValue(1) : getScaledValue(0),
                  color: Color(0xffe9e9e9)),
              right: BorderSide(
                  width: getScaledValue(1), color: Color(0xffe9e9e9))),
        ));
  }

  void marketSelectChange(value) {
    setState(() {
      _selectedMarket = value;
      key.currentState._seriesList = chartDataList();
    });
  }

  List<charts.Series<TimeSeriesSales, DateTime>> chartDataList() {
    final List<TimeSeriesSales> portfolioData = [];
    final List<TimeSeriesSales> benchmarkData = [];

    widget.responseData['response']['navGraphData']['graphData']
            [_selectedMarket][_performanceTenure]['portfolioData']
        .forEach((key_date, value) {
      if (widget.responseData['response']['navGraphData']['graphData']
              [_selectedMarket][_performanceTenure]['benchmarkData']
          .containsKey(key_date)) {
        DateTime dateNAV = DateTime.parse(key_date);
        double navValue = widget.responseData['response']['navGraphData']
                ['graphData'][_selectedMarket][_performanceTenure]
                ['portfolioData'][key_date]
            .toDouble();
        double hurdleValue = widget.responseData['response']['navGraphData']
                ['graphData'][_selectedMarket][_performanceTenure]
                ['benchmarkData'][key_date]
            .toDouble();
        portfolioData.add(new TimeSeriesSales(dateNAV, navValue));
        benchmarkData.add(new TimeSeriesSales(dateNAV, hurdleValue));
      }
    });

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Portfolio',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: (widget.responseData['response']['navGraphData']['markets']
          [_selectedMarket]),
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: benchmarkData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffc0c0c0))),
    ));

    return chartDataList;
  }

  List<charts.Series<TimeSeriesSales, DateTime>> priceChartDataList() {
    final List<TimeSeriesSales> portfolioData = [];

    widget.responseData['response']['navGraphData']['priceGraph']
            [_performanceTenure]
        .forEach((key_date, value) {
      DateTime dateNAV = DateTime.parse(key_date);
      double navValue = widget.responseData['response']['navGraphData']
              ['priceGraph'][_performanceTenure][key_date]
          .toDouble();
      portfolioData.add(new TimeSeriesSales(dateNAV, navValue));
    });

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Portfolio',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    return chartDataList;
  }
}

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static String pointerValue;

  SimpleLineChart(this.seriesList, {this.animate});

  String _formatMoney(num value1) {
    int value = value1.toInt();
    return NumberFormat.compact().format(value);
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
        height: 175.0,
        child: ShaderMask(
          child: charts.TimeSeriesChart(
            seriesList,
            animate: animate,
            layoutConfig: charts.LayoutConfig(
              leftMarginSpec: charts.MarginSpec.fixedPixel(0),
              topMarginSpec: charts.MarginSpec.fixedPixel(0),
              rightMarginSpec: charts.MarginSpec.fixedPixel(0),
              bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
            ),
            domainAxis: new charts.DateTimeAxisSpec(
              showAxisLine: false,
            ),
            defaultRenderer: new charts.LineRendererConfig(
              includeArea: false,
              stacked: true,
              includeLine: true,
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              showAxisLine: false,

              tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                zeroBound: false,
                desiredTickCount: 5,
              ),
              tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                _formatMoney,
              ),
              //renderSpec: new charts.NoneRenderSpec()
              renderSpec: new charts.GridlineRendererSpec(
                  labelStyle: new charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.Color.fromHex(code: "#ffffff"),
                  ),
                  lineStyle: new charts.LineStyleSpec(
                      dashPattern: [10, 5],
                      color: charts.Color.fromHex(
                          code: "#dadada") //charts.MaterialPalette.white
                      )),
            ),
            selectionModels: [
              charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                    pointerValue = DateFormat("MMM dd, yyyy").format(
                            DateTime.parse(datumPair.datum.date.toString())) +
                        "\nScore: " +
                        (datumPair.datum.total).round().toString();
                  });
                }
              })
            ],
            behaviors: [
              charts.SelectNearest(
                  eventTrigger: charts.SelectionTrigger.tapAndDrag),
              charts.LinePointHighlighter(
                  showHorizontalFollowLine:
                      charts.LinePointHighlighterFollowLineType.all,
                  showVerticalFollowLine:
                      charts.LinePointHighlighterFollowLineType.all,
                  symbolRenderer: CustomCircleSymbolRenderer())
            ],
          ),
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green, Colors.white],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
        ));
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    int positionBox = 5;
    int positionText = 5;

    if (bounds.left + bounds.width + 120 > 300) {
      positionBox = 120;
      positionText = -110;
    }
    //canvas.drawRRect(bounds)

    canvas.drawRect(
      Rectangle(bounds.left - positionBox, bounds.top - 75, bounds.width + 120,
          bounds.height + 45),
      fill: charts.ColorUtil.fromDartColor(Color((0xff1772ff))),
      //radius: 4,
    );

    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontFamily = 'nunito';
    textStyle.fontSize = 13;

    canvas.drawText(TextElement(SimpleLineChart.pointerValue, style: textStyle),
        (bounds.left + positionText).round(), (bounds.top - 63).round());
  }
}

class yieldData {
  final DateTime date;
  final double total;
  //final String total;
  //final double nifty;

  yieldData(this.date, this.total);
}

// ***************** chart library ***************
class SelectionCallbackExample extends StatefulWidget {
  List<charts.Series> seriesList;
  final bool animate = true;
  static String pointerValue;
  //SelectionCallbackExample({ Key key }) : super(key: key);

  SelectionCallbackExample(this.seriesList, {Key key}) : super(key: key);

  factory SelectionCallbackExample.withData(seriesList1) {
    log.d(seriesList1);

    return new SelectionCallbackExample(
      _createData(seriesList1),
      // Disable animations for image tests.
    );
  }

  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() =>
      new _SelectionCallbackState(seriesList);

  static List<charts.Series<TimeSeriesSales, DateTime>> _createData(
      seriesList1) {
    return seriesList1;
  }
}

class _SelectionCallbackState extends State<SelectionCallbackExample> {
  DateTime _time;
  Map<String, num> _measures;

  List<charts.Series> _seriesList;

  _SelectionCallbackState(this._seriesList);
  reloadData(List<charts.Series<TimeSeriesSales, DateTime>> newSeriesList) {}

  @override
  Widget build(BuildContext context) {
    // The children consist of a Chart and Text widgets below to hold the info.
    final children = <Widget>[
      new SizedBox(
          height: 250.0,
          child: charts.TimeSeriesChart(
            _seriesList,
            animate: true,
            animationDuration: Duration(milliseconds: 500),
            behaviors: [
              //new charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
              charts.SelectNearest(
                  eventTrigger: charts.SelectionTrigger.tapAndDrag),
              charts.LinePointHighlighter(
                  showHorizontalFollowLine:
                      charts.LinePointHighlighterFollowLineType.all,
                  showVerticalFollowLine:
                      charts.LinePointHighlighterFollowLineType.all,
                  symbolRenderer: CustomCircleSymbolRenderer2()),
              charts.SeriesLegend(
                showMeasures: false,
                position: charts.BehaviorPosition.bottom,
                outsideJustification:
                    charts.OutsideJustification.middleDrawArea,
                horizontalFirst: true,
                desiredMaxRows: 2,
                cellPadding:
                    new EdgeInsets.only(right: 24.0, bottom: 4.0, top: 20.0),
                entryTextStyle: charts.TextStyleSpec(
                  color: charts.ColorUtil.fromDartColor(Color(0xff474747)),
                  fontFamily: 'nunito',
                  fontSize: 12,
                  fontWeight: "600",
                ),
              )
            ],
            primaryMeasureAxis: new charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false, desiredTickCount: 5),
              renderSpec: new charts.GridlineRendererSpec(
                  labelStyle: new charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.Color.fromHex(code: "#000000"),
                  ),
                  lineStyle: new charts.LineStyleSpec(
                      color: charts.Color.fromHex(
                          code: "#ffffff") //charts.MaterialPalette.white
                      )),
            ),
            selectionModels: [
              charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  SelectionCallbackExample.pointerValue =
                      DateFormat("MMM dd, yyyy").format(DateTime.parse(
                          model.selectedDatum.first.datum.time.toString()));

                  if (model.selectedDatum[0].series.id == "Portfolio") {
                    SelectionCallbackExample.pointerValue += "\n" +
                        model.selectedDatum[0].series.displayName +
                        ": " +
                        (model.selectedDatum[0].datum.sales).round().toString();
                    SelectionCallbackExample.pointerValue += "\n" +
                        model.selectedDatum[1].series.displayName +
                        ": " +
                        (model.selectedDatum[1].datum.sales).round().toString();
                  } else {
                    SelectionCallbackExample.pointerValue += "\n" +
                        model.selectedDatum[1].series.displayName +
                        ": " +
                        (model.selectedDatum[1].datum.sales).round().toString();
                    SelectionCallbackExample.pointerValue += "\n" +
                        model.selectedDatum[0].series.displayName +
                        ": " +
                        (model.selectedDatum[0].datum.sales).round().toString();
                  }
                }
              })
            ],
          )),
    ];

    // If there is a selection, then include the details.
    if (_time != null) {
      children.add(new Padding(
          padding: new EdgeInsets.only(top: 5.0),
          //child: new Text(_time.toString())));
          child: new Text(DateFormat.yMMMd().format(_time))));
    }
    _measures?.forEach((String series, num value) {
      children.add(new Text('${series}: ${value}'));
    });

    return new Column(children: children);
  }
}

class CustomCircleSymbolRenderer2 extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    int positionBox = -5;
    int positionText = 5;

    if (bounds.left + bounds.width + 140 > 300) {
      positionBox = 140;
      positionText = -140;
    }
    //canvas.drawRRect(bounds)

    canvas.drawRect(
      //Rectangle(bounds.left - positionBox, bounds.top - 75, bounds.width + 120, bounds.height + 45),
      Rectangle(
          bounds.left - positionBox, 0, bounds.width + 140, bounds.height + 55),
      fill: charts.ColorUtil.fromDartColor(Color((0xff1772ff))),
      //radius: 4,
    );

    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontFamily = 'nunito';
    textStyle.fontSize = 13;

    canvas.drawText(
        TextElement(SelectionCallbackExample.pointerValue, style: textStyle),
        (bounds.left + positionText + 10).round(),
        (10).round());
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
