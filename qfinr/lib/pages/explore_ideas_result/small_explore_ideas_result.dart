import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/explore_ideas/small_explore_ideas.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('ExploreIdeasResultScreen');

class SmallExploreIdeasResultScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final List<Filter> selectedFilter;

  SmallExploreIdeasResultScreen(this.model,
      {this.analytics, this.observer, this.selectedFilter});

  @override
  _SmallExploreIdeasResultScreenState createState() =>
      _SmallExploreIdeasResultScreenState();
}

class _SmallExploreIdeasResultScreenState
    extends State<SmallExploreIdeasResultScreen> {
  String _performanceTenure = "all";
  List<Filter> selectedFilters;
  List<String> selectedFilterText;
  bool isLoading;
  StockIdeaResponse stockIdeaResponse;
  YearOption selectedYearOption;
  GraphData selectedGraphData;

  var stocks = ["HDFC Insurance Company", "SBI", "ICICI"];

  Future<Null> _analyticsAddtoWatchListEvent() async {
    await widget.analytics.logEvent(name: 'add_to_wishlist', parameters: {
      'item_id': "explore_ideas",
      'item_name': "explore_ideas_add_to_watchlist",
      'content_type': "add_to_watchlist_button",
    });
  }

  Future<Null> _analyticsDurationFilterEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "explore_ideas",
      'item_name': "explore_ideas_duration_filter",
      'content_type': "duration_filter_button",
    });
  }

  Future<Null> _analyticsSelectBenchMarkEvent() async {
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "explore_ideas",
      'item_name': "explore_ideas_benchmark",
      'content_type': "select_benchmark_drop_down",
    });
  }

  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'idea_at_glance', screenClassOverride: 'idea_at_glance');
  }

  @override
  void initState() {
    super.initState();
    selectedFilters = widget.selectedFilter;
    buildRequest();
    _analyticsCurrentScreen();
  }

  Future buildRequest() async {
    setState(() {
      widget.model.setLoader(false);
    });
    List<String> selectedCategories = selectedFilters[1]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.apiKey)
        .toList();

    List<String> selectedVals = selectedFilters[7]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.apiKey)
        .toList();

    selectedFilterText = selectedFilters[0]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.name)
        .toList();
    selectedFilterText.addAll(selectedFilters[1]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.name)
        .toList());

    selectedFilterText.addAll(selectedFilters[2]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.name + " Holdings")
        .toList());

    selectedFilterText.addAll(selectedFilters[3]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.name)
        .toList());

    selectedFilterText.addAll(selectedFilters[4]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.name)
        .toList());

    selectedFilterText.addAll(selectedFilters[5]
        .option
        .where((element) => element.isSelected)
        .map((e) => e.name)
        .toList());

    var postData = {
      "TYPE": selectedFilters[0]
          .option
          .firstWhere((element) => element.isSelected)
          .apiKey,
      "category": jsonEncode(selectedCategories),
      "holdings": selectedFilters[2]
          .option
          .firstWhere((element) => element.isSelected)
          .apiKey,
      "WT": selectedFilters[3]
          .option
          .firstWhere((element) => element.isSelected)
          .apiKey,
      "FRQ": selectedFilters[4]
          .option
          .firstWhere((element) => element.isSelected)
          .apiKey,
      "SCREEN": selectedFilters[5]
          .option
          .firstWhere((element) => element.isSelected)
          .apiKey,
      "MOM_MTHS": selectedFilters[6]
          .option
          .firstWhere((element) => element.isSelected)
          .apiKey,
      "VAL": jsonEncode(selectedVals),
    };

    StockIdeaResponse networkResponse = await widget.model.discover(postData);
    if (networkResponse != null) {
      setState(() {
        stockIdeaResponse = networkResponse;
        selectedGraphData = stockIdeaResponse.response.graphData[0];
      });
    }
    setState(() {
      widget.model.setLoader(false);
    });
    logger.e(stockIdeaResponse);
  }

  Widget _bwReturn({String title, var value, double leftPadding = 0}) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(left: leftPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: bodyText7,
          ),
          Text(
            "${(value * 100).toStringAsPrecision(3)}%",
            style: bodyText6.apply(
                color: (value > 0 ? colorGreenReturn : colorRedReturn)),
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _bubbleChildren = selectedFilterText
        .map((e) => Padding(
              padding: EdgeInsets.only(
                  left: selectedFilterText.indexOf(e) == 0 ? 16 : 0,
                  right: selectedFilterText.indexOf(e) ==
                          selectedFilterText.length - 1
                      ? 16
                      : 4),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColor.statusContainer,
                    borderRadius: BorderRadius.circular(4)),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      e.toUpperCase(),
                      style: widgetBubbleTextStyle.apply(
                          color: AppColor.statusTextColor),
                    ),
                  ),
                ),
              ),
            ))
        .toList();
    //_bubbleChildren.add();
    return Scaffold(
      backgroundColor: Colors.white,
      body: !widget.model.isLoading && stockIdeaResponse != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBar(
                          leading: BackButton(
                            color: Colors.black,
                          ),
                          elevation: 0,
                          backgroundColor: Colors.white,
                          actions: [
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, widget.model.redirectBase),
                              child: AppbarHomeButton(),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16) +
                              EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Text(
                                      Contants.SCREENER_SUMMARY,
                                      style: headline1,
                                    )),
                              ),
                              /* svgImage("assets/icon/filter.svg", height: 20, width: 20, ) */
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Container(
                            height: 26,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _bubbleChildren,
                            ),
                          ),
                        )
                      ]),
                  cornerRadius: 0,
                ),
                Expanded(
                    child: ListView(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CURRENT HOLDINGS".toUpperCase(),
                              style: bodyText1.apply(
                                  color: Color(0xffa5a5a5),
                                  fontWeightDelta: 2,
                                  letterSpacingDelta: 2),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 8, top: 8),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xffbcbcbc),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            Container(
                              color: AppColor.fillGrey6,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Name",
                                      style: bodyText7,
                                    ),
                                    Text(
                                      "Weightage",
                                      style: bodyText7,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: stockIdeaResponse
                                    .response.portfolios.stockData
                                    .map((e) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16) +
                                            EdgeInsets.only(
                                                top:
                                                    stockIdeaResponse
                                                                .response
                                                                .portfolios
                                                                .stockData
                                                                .indexOf(e) ==
                                                            0
                                                        ? 16
                                                        : 0,
                                                bottom: stockIdeaResponse
                                                            .response
                                                            .portfolios
                                                            .stockData
                                                            .indexOf(e) ==
                                                        stockIdeaResponse
                                                                .response
                                                                .portfolios
                                                                .stockData
                                                                .length -
                                                            1
                                                    ? 16
                                                    : 0),
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                e.name,
                                                style: bodyText6,
                                              )),
                                              Text(
                                                "${roundDouble(e.weightage)}%",
                                                style: bodyText3.apply(
                                                  color: Color(0xff818181),
                                                  fontWeightDelta: 2,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12.0,
                                                          vertical: 4),
                                                      child: Text(
                                                        "Stocks".toUpperCase(),
                                                        style: bodyText7,
                                                      ),
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xffbcbcbc),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 12),
                                                    child:
                                                        widgetZoneFlag(e.zone))
                                              ],
                                            ),
                                          ),
                                          stockIdeaResponse.response.portfolios
                                                      .stockData
                                                      .indexOf(e) !=
                                                  stockIdeaResponse
                                                          .response
                                                          .portfolios
                                                          .stockData
                                                          .length -
                                                      1
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 16, bottom: 16),
                                                  child: divider(),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList())
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16) +
                            EdgeInsets.only(bottom: 24),
                        child: Text(
                          "Next rebalance date on ${DateFormat('dd-MMM-yyyy').format(stockIdeaResponse.response.latestPortfolioDate)}",
                          style: bodyText3.apply(
                              color: Color(0xff8b8b8b), letterSpacingDelta: -1),
                        )),
                    divider(
                        dividerColor: AppColor.bottomBarBGActive,
                        dividerHeight: 8),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 30),
                              child: RichText(
                                  text: TextSpan(
                                      style: appGraphTitle,
                                      text: ("PERFORMANCE VS "),
                                      children: [
                                    TextSpan(
                                        text: selectedGraphData.marketName,
                                        style: appGraphTitle.copyWith(
                                            color: AppColor.colorBlue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _analyticsSelectBenchMarkEvent();
                                            buildSelectBoxCustom(
                                                context: context,
                                                onChangeFunction: (option) {
                                                  marketSelectChange(option);
                                                },
                                                options: stockIdeaResponse
                                                    .response.graphData,
                                                value: selectedGraphData
                                                    .marketName,
                                                title: 'Select benchmark');
                                          }),
                                    WidgetSpan(
                                      child: Icon(Icons.keyboard_arrow_down,
                                          color: AppColor.colorBlue, size: 14),
                                    ),
                                  ])),
                            ),
                            Container(
                                height: 200,
                                child: SelectionCallbackExample(
                                    sampleChartData(selectedGraphData),
                                    key: key)),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        color: Color((0xffff7005))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 16),
                                    child: Text(
                                      "Portfolio",
                                      style: bodyText7.copyWith(
                                          color: Color(0xff474747),
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration:
                                        BoxDecoration(color: Color(0xffc0c0c0)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 16),
                                    child: Text(
                                      selectedGraphData.marketName,
                                      style: bodyText7.copyWith(
                                          color: Color(0xff474747),
                                          fontWeight: FontWeight.w800),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _basketPerformanceBtns(context),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    divider(
                        dividerColor: AppColor.bottomBarBGActive,
                        dividerHeight: 8),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16, top: 24, right: 16, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Past Performance Analysis".toUpperCase(),
                              style: bodyText1.apply(
                                  color: Color(0xffa5a5a5),
                                  fontWeightDelta: 2,
                                  letterSpacingDelta: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                "Time Period".toUpperCase(),
                                style: bodyText7,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, bottom: 12),
                              child: Text(
                                "${DateFormat('dd MMM, yyyy').format(stockIdeaResponse.response.stats.start)} - ${DateFormat('dd MMM, yyyy').format(stockIdeaResponse.response.stats.end)}",
                                style: bodyText5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xffbcbcbc),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            Container(
                              color: AppColor.fillGrey6,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Best".toUpperCase(),
                                        style: bodyText7,
                                      ),
                                    ),
                                    Expanded(
                                        child: Container(
                                      padding: EdgeInsets.only(
                                          left: getScaledValue(35)),
                                      child: Text(
                                        "Worst".toUpperCase(),
                                        style: bodyText7,
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                            ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Container(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Row(
                                            children: [
                                              _bwReturn(
                                                  title: "1 Day Return",
                                                  value: stockIdeaResponse
                                                      .response.stats.bestDay),
                                              _bwReturn(
                                                  title: "1 Day Return",
                                                  value: stockIdeaResponse
                                                      .response.stats.worstDay,
                                                  leftPadding:
                                                      getScaledValue(35))
                                            ],
                                          ),
                                        ),
                                        divider(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Row(
                                            children: [
                                              _bwReturn(
                                                  title: "1 Month Return",
                                                  value: stockIdeaResponse
                                                      .response
                                                      .stats
                                                      .bestMonth),
                                              _bwReturn(
                                                  title: "1 Month Return",
                                                  value: stockIdeaResponse
                                                      .response
                                                      .stats
                                                      .worstMonth,
                                                  leftPadding:
                                                      getScaledValue(35)),
                                            ],
                                          ),
                                        ),
                                        divider(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Row(
                                            children: [
                                              _bwReturn(
                                                  title: "1 Year Return",
                                                  value: stockIdeaResponse
                                                      .response.stats.bestYear),
                                              _bwReturn(
                                                  title: "1 Year Return",
                                                  value: stockIdeaResponse
                                                      .response.stats.worstYear,
                                                  leftPadding:
                                                      getScaledValue(35)),
                                            ],
                                          ),
                                        ),
                                        divider(),
                                      ],
                                    ),
                                  ))
                                ])
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: getScaledValue(8)),
                      child: Column(children: [
                        statsRow(
                            title: 'Total Returns',
                            description: 'since inception',
                            value1:
                                "${(stockIdeaResponse.response.stats.totalReturn * 100).toStringAsPrecision(3)}%"),
                        statsRow(
                            title: 'Annual Returns',
                            description: 'CAGR',
                            value1:
                                "${(stockIdeaResponse.response.stats.cagr * 100).toStringAsPrecision(2)}%"),
                        statsRow(
                            title: 'Risks',
                            description: 'Volatility',
                            value1:
                                "${(stockIdeaResponse.response.stats.yearlyVol * 100).toStringAsPrecision(2)}%"),
                      ]),
                    ),
                    sectionSeparator(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: getScaledValue(8)),
                      child: Column(
                        children: [
                          statsRow(
                              title: 'Return per unit risk',
                              description: 'Sharpe Ratio',
                              value1:
                                  "${(stockIdeaResponse.response.stats.dailySharpe).toStringAsPrecision(2)}"),
                          statsRow(
                              title: 'Maximum Loss',
                              description: 'Max Drawdown',
                              value1:
                                  "${(stockIdeaResponse.response.stats.maxDrawdown * 100).toStringAsPrecision(2)}%"),
                          statsRow(
                              title: 'Recovery Period',
                              description: 'Avg Drawdown Days',
                              value1: roundDouble(
                                  stockIdeaResponse
                                      .response.stats.avgDrawdownDays,
                                  decimalLength: 0)),
                        ],
                      ),
                    ),
                  ],
                )),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getScaledValue(10),
                      vertical: getScaledValue(10)),
                  child: gradientButton(
                      context: context,
                      caption: "Add to watchlist",
                      onPressFunction: () {
                        _analyticsAddtoWatchListEvent();
                        Navigator.pushNamed(context, '/add_portfolio_discover',
                            arguments: {
                              'portfolios': stockIdeaResponse
                                  .response.portfolios.stockData,
                              'latestRebalanceDate':
                                  stockIdeaResponse.response.latestPortfolioDate
                            });
                      }),
                )
              ],
            )
          : preLoader(
              title:
                  'Crunching data for your request\nThis will take a couple of minutes. Please remain patient...'),
    );
  }

  void marketSelectChange(value) {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData =
        sampleChartData(value); // @todo
    setState(() {
      key.currentState._seriesList = chartData;
      selectedGraphData = value;
    });
  }

  Widget _basketPerformanceBtns(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _performanceButton(context, 'All', 'all'),
        _performanceButton(context, '5Y', '5year'),
        _performanceButton(context, '3Y', '3year'),
        _performanceButton(context, '1Y', '1year'),
        _performanceButton(context, '6M', '6months'),
        _performanceButton(context, '1M', '1month'),
        /* 		_performanceButton(context, '1W', 'week'), */
      ],
    );
  }

  List<charts.Series<TimeSeriesSales, DateTime>> sampleChartData(
      GraphData selectedGraphData) {
    final List<TimeSeriesSales> portfolioData = [];
    final List<TimeSeriesSales> benchmarkData = [];

    var benchMark = selectedGraphData.stockData.yearOption
        .firstWhere((element) => element.key == _performanceTenure)
        .data
        .benchmarkData;
    var portfolio = selectedGraphData.stockData.yearOption
        .firstWhere((element) => element.key == _performanceTenure)
        .data
        .portfolioData;
    for (var i = 0; i < benchMark.length; i++) {
      DateTime dateNAV =
          DateTime.fromMillisecondsSinceEpoch(benchMark[i][0].toInt());
      double navValue = portfolio[i][1];
      portfolioData.add(new TimeSeriesSales(dateNAV, navValue));

      double hurdleValue = benchMark[i][1].toDouble();
      benchmarkData.add(new TimeSeriesSales(dateNAV, hurdleValue));
    }

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Portfolio',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: (selectedGraphData.marketName),
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: benchmarkData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffc0c0c0))),
    ));

    return chartDataList;
  }

  Widget _performanceButton(BuildContext context, String title, String index) {
    return ButtonTheme(
        minWidth: getScaledValue(55),
        child: RaisedButton(
          elevation: 0,
          padding: EdgeInsets.all(0.0),
          color: _performanceTenure == index ? Color(0xffe2ecff) : Colors.white,
          child: Text(title,
              style: _performanceTenure == index
                  ? appGraphOptBtn.copyWith(color: AppColor.colorBlue)
                  : appGraphOptBtn),
          onPressed: () {
            _analyticsDurationFilterEvent();
            setState(() {
              _performanceTenure = index;
              List<charts.Series<TimeSeriesSales, DateTime>> chartData =
                  sampleChartData(selectedGraphData); // @todo
              key.currentState._seriesList = chartData;
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
                  width: index == "all" ? getScaledValue(1) : getScaledValue(0),
                  color: Color(0xffe9e9e9)),
              right: BorderSide(
                  width: getScaledValue(1),
                  color: Color(
                      0xffe9e9e9))), //RoundedRectangleBorder(side: BorderSide(color: Colors.black)),
        ));
  }

  buildSelectBoxCustom(
      {BuildContext context,
      String title,
      String value,
      List<GraphData> options,
      Function onChangeFunction,
      String modelType = "bottomSheet"}) {
    List<Widget> _childrenOption = [];

    options.forEach((option) {
      _childrenOption.add(GestureDetector(
        onTap: () {
          onChangeFunction(option);
          Navigator.pop(context);
        },
        child: Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              value: option.marketName,
            ),
            Text(option.marketName,
                style: value == option.marketName
                    ? selectBoxOptionActive
                    : selectBoxOption),
          ],
        ),
      ));
    });

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: getScaledValue(15),
                      vertical: getScaledValue(10)),
                  margin: const EdgeInsets.only(bottom: 6.0),
                  //Same as `blurRadius` i guess
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  child: Text(title, style: selectBoxTitle)),
              Container(
                color: Colors.grey[50],
                padding: EdgeInsets.symmetric(
                    horizontal: getScaledValue(10),
                    vertical: getScaledValue(5)),
                margin: EdgeInsets.only(bottom: getScaledValue(10)),
                child: Column(
                  children: _childrenOption,
                ),
              ),
            ],
          );
        });
  }
}

// ***************** chart library ***************
class SelectionCallbackExample extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate = true;
  static String pointerValue;
  //SelectionCallbackExample({ Key key }) : super(key: key);

  SelectionCallbackExample(this.seriesList, {Key key}) : super(key: key);
  //SelectionCallbackExample(this.seriesList);

  /// Creates a [charts.TimeSeriesChart] with sample data and no transition.
  factory SelectionCallbackExample.withSampleData() {
    return new SelectionCallbackExample(
      _createSampleData(),
      // Disable animations for image tests.
    );
  }

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

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final us_data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5.0),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25.0),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 78.0),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 54.0),
    ];

    final uk_data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 15.0),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 33.0),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 68.0),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 48.0),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'US Sales',
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: us_data,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'UK Sales',
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: uk_data,
      )
    ];
  }
}

class _SelectionCallbackState extends State<SelectionCallbackExample> {
  DateTime _time;
  Map<String, num> _measures;

  List<charts.Series> _seriesList;
  bool _animate;

  _SelectionCallbackState(this._seriesList);
  reloadData(List<charts.Series<TimeSeriesSales, DateTime>> newSeriesList) {}

  @override
  Widget build(BuildContext context) {
    // The children consist of a Chart and Text widgets below to hold the info.
    final children = <Widget>[
      new SizedBox(
          height: 200.0,
          child: charts.TimeSeriesChart(
            _seriesList,
            animate: _animate,
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
                  symbolRenderer: CustomCircleSymbolRenderer()),
              /* charts.SeriesLegend(
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
              ) */
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

                  /* bool first = true;
						model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
							SelectionCallbackExample.pointerValue += "\n" +
								(first ? "Portfolio: " : "Benchmark: ") +
								(datumPair.datum.sales).round().toString();
							if (first) first = false;
						}); */
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

    int positionBox = -5;
    int positionText = 5;

    if (bounds.left + bounds.width + 120 > 300) {
      positionBox = 120;
      positionText = -110;
    }
    //canvas.drawRRect(bounds)

    canvas.drawRect(
      //Rectangle(bounds.left - positionBox, bounds.top - 75, bounds.width + 120, bounds.height + 45),
      Rectangle(
          bounds.left - positionBox, 0, bounds.width + 120, bounds.height + 55),
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

class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}

MyGlobals myGlobals = new MyGlobals();

class MyGlobals {
  GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}
