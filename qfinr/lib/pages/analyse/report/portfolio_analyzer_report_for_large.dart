import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_detail_for_large.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/controller_switch.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/main_model.dart';
import '../../../utils/text_with_drop_down_button.dart';
import '../../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('PortfolioAnalyzerReport');

class PortfolioAnalyzerReportLarge extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final dynamic responseData;

  Map selectedPortfolioMasterIDs;
  String benchmark;

  PortfolioAnalyzerReportLarge(this.model,
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
    extends State<PortfolioAnalyzerReportLarge> {
  final controller = ScrollController();

  bool _loading = false;
  bool widgetExpanded = false;
  bool widgetExpandedRating = false;

  Map fundData;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedMarket;
  String _performanceTenure = "3year";
  List<Map<String, String>> markets = [];
  Map<String, String> _selectedMarketOption;

  String chartType = "chart";

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Analyzer Report',
        screenClassOverride: 'PortfolioAnalyzerReport');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Analyzer Report",
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

  @override
  void initState() {
    super.initState();

    log.d("Shariyath_testing_analyser_reports");

    fundData = widget.responseData['response']['data'];

    log.d("Testing_purpose_fundData$fundData");

    var graphData = widget
        .responseData['response']['navGraphData']['graphData'].entries
        .toList();
    _selectedMarket = graphData[0].key;

    widget.responseData['response']['navGraphData']['markets']
        .forEach((key, value) {
      markets.add({"value": key, "title": value});
    });

    _currentScreen();
    _addEvent();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
    );

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return PageWrapper(
          child: Scaffold(
              key: _scaffoldKey,
              drawer: WidgetDrawer(),
              appBar: PreferredSize(
                // for larger & medium screen sizes
                preferredSize: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
                child: NavigationTobBar(
                  widget.model,
                  openDrawer: () => _scaffoldKey.currentState.openDrawer(),
                ),
              ),
              body: _buildBodyLarge()));
    });
  }

  List<Widget> _selectedPortfolios() {
    List<Widget> _children = [];

    bool firstFlag = false;

//List zones =  widget.model.userPortfoliosData[widget.portfolioMasterID];
    widget.selectedPortfolioMasterIDs.forEach((key, value) {
      if (value == true) {
        List zones =
            widget.model.userPortfoliosData[key]['portfolio_zone'].split('_');

        _children.add(_portfolioValueLarge(
            widget.model.userPortfoliosData[key]['portfolio_name'],
            widget.model.userPortfoliosData[key]['value'],
            widget.model.userPortfoliosData[key]['change_sign'],
            widget.model.userPortfoliosData[key]['change'],
            zones,
            includeLeftBorder: firstFlag));
        firstFlag = true;
      }
    });

    return _children;
  }

  void marketSelectChange(Map<String, String> value) {
    setState(() {
      _selectedMarketOption = value;
      _selectedMarket = value['value'];
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

  Widget _buildBodyLarge() {
    if (_loading) {
      return preLoader();
    } else {
      return _buildBodyNvaigationLeftBar(); //_autocompleteTextField(); //_buildBodyContent();
    }
  }

  Widget _buildBodyNvaigationLeftBar() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        deviceType == DeviceScreenType.tablet
            ? emptyWidget
            : NavigationLeftBar(
                isSideMenuHeadingSelected: 2, isSideMenuSelected: 8),
        Expanded(child: _buildBodyContentLarge()),
      ],
    );
  }

  Widget _buildBodyContentLarge() {
    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(left: 27.0, top: 55.0, right: 60.0, bottom: 87),
        color: Color(0xfff5f6fa),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ouranalyseHeader(),
            SizedBox(
              height: getScaledValue(16),
            ),
            _listPortfoliosLarge(),
            SizedBox(
              height: getScaledValue(24),
            ),
            descriptionLarge(),
            SizedBox(
              height: getScaledValue(24),
            ),
            _portfolioAnalyzerDetails(),
          ],
        ),
      ),
    );
  }

  _ouranalyseHeader() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text("Our Analysis", style: headline1_analyse),

                SizedBox(
                  height: getScaledValue(5),
                ),
                Text("Benchmark: " + widget.benchmark,
                    style: headline2_analyse),
                //Text("Benchmark: By Nifty 500", style: headline2_analyse ),
              ])),
          // Container(
          //     child: Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //       ElevatedButton(
          //         style: qfButtonStyle2,
          //         child: Ink(
          //           width: 130,
          //           height: 48,
          //           decoration: BoxDecoration(
          //               color: Color(0xffffffff),
          //               borderRadius: BorderRadius.circular(5.0)),
          //           child: Container(
          //             constraints: BoxConstraints(
          //                 maxWidth: MediaQuery.of(context).size.width,
          //                 minHeight: 48),
          //             alignment: Alignment.center,
          //             child: Text(
          //               "RETAKE",
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 12,
          //                 color: colorBlue,
          //                 letterSpacing: 1.0,
          //               ),
          //             ),
          //           ),
          //         ),
          //         // textColor: Colors.white,
          //         onPressed: null,
          //       ),
          //       SizedBox(
          //         width: getScaledValue(12),
          //       ),
          //       ElevatedButton(
          //         style: qfButtonStyle(
          //             ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
          //         child: Ink(
          //           width: 130,
          //           height: 48,
          //           decoration: BoxDecoration(
          //               gradient: LinearGradient(
          //                 colors: [Color(0xff0941cc), Color(0xff0055fe)],
          //                 begin: Alignment.centerLeft,
          //                 end: Alignment.centerRight,
          //               ),
          //               borderRadius: BorderRadius.circular(5.0)),
          //           child: Container(
          //             constraints: BoxConstraints(
          //                 maxWidth: MediaQuery.of(context).size.width,
          //                 minHeight: 48),
          //             alignment: Alignment.center,
          //             child: Text(
          //               "MAIL",
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 12,
          //                 color: Colors.white,
          //                 letterSpacing: 1.0,
          //               ),
          //             ),
          //           ),
          //         ),
          //         onPressed: null,
          //       ),
          //     ])),
        ],
      ),
    );
  }

  _listPortfoliosLarge() {
    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 1.0,
        padding:
            EdgeInsets.only(left: 24.0, top: 0.0, right: 24.0, bottom: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
              ),

              Container(
                height: getScaledValue(75),
                width: MediaQuery.of(context).size.width * 1.0,
                alignment: Alignment.topLeft,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: _selectedPortfolios(),
                ),
              ),

              // Text("listing soon", style: headline3_analyse),
              SizedBox(
                height: 24,
              ),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: analysisScoreLarge(),
                    ),

                    SizedBox(
                      width: getScaledValue(16),
                    ),

                    Expanded(
                      child: graphNavLarge(),
                    ),

                    // analysisScoreLarge(),
                    //graphNav_test2()
                  ],
                ),
              ),

              SizedBox(
                height: 16,
              ),
            ]));
  }

  Widget analysisScoreLarge() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 1.0 / 2,
        // height: MediaQuery.of(context).size.height * 1.0/1.75,
        //padding:  EdgeInsets.symmetric(vertical: getScaledValue(30), horizontal: getScaledValue(30)),
        //alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  left: getScaledValue(30),
                  top: 0.0,
                  right: getScaledValue(30),
                  bottom: 0.0),
              //padding:  EdgeInsets.symmetric(vertical: getScaledValue(17), horizontal: getScaledValue(15)),
              child: Column(
                children: [
                  SizedBox(
                    height: getScaledValue(16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Overall Score", style: headline7_analyse),
                              SizedBox(width: getScaledValue(8)),
                              starScore(score: fundData['overall_rating']),
                            ],
                          )
                        ],
                      ),
                      //Text("As on " + fundData['data']['latest_date'], style: bodyText8)
                    ],
                  ),
                  SizedBox(
                    height: getScaledValue(16),
                  ),
                ],
              ),
            ),
            Divider(
              height: getScaledValue(5),
              color: Color(0xfff5f6fa),
            ),
            Container(
              //height: 150,
              //padding: EdgeInsets.only(left: getScaledValue(30),top: 0.0,right: getScaledValue(30),bottom: 0.0),
              child: Column(
                //shrinkWrap: true,
                //scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    height: getScaledValue(14),
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          top: getScaledValue(15), right: getScaledValue(12)),
                      alignment: Alignment.centerRight,
                      child: Text("1 - Low  |  5 - High ", style: bodyText9)),

                  widgetRatingLarge(
                      context: context,
                      title: 'Return Rating',
                      description:
                          "We look at a range of metrics around portfolio returns including information ratio, success ratio and the goodness of fit to the benchmark returns and aggregate these elements into the score",
                      score: fundData['or_score']),

                  //widgetRating(context: context, title: 'Expense Rating', description: "We compare the fund’s expenses against other funds in the same category to arrive at this rating", score: double.parse(fundData['tr_rating'])),

                  widgetRatingLarge(
                      context: context,
                      title: 'Alpha Rating',
                      description:
                          "We look for statistical evidence of alpha generation by your portfolio against the benchmark and markets. We run a series of regressions and aggregate the information into this score",
                      score: fundData['alpha_score']),
                  widgetRatingLarge(
                      context: context,
                      title: 'Portfolio Suitability',
                      description:
                          "We rate the alignment of your portfolio performance to the risk adjusted returns appropriate for your risk profile. We examine both risk and returns over the last 3 years",
                      score: fundData['port_suit_score']),
                  SizedBox(
                    height: getScaledValue(24),
                  ),
                  widgetRiskRatingLarge(
                      context: context,
                      title: 'Risk Rating',
                      description:
                          "This is a synthetic risk return indicator based on the volatility of your portfolio. We use 3 year information to categorize the risk of your portfolio into 7 categories, with 7 being the most volatile and 1 the least volatile",
                      score: fundData['srri']),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 24,
      ),
    ]);
  }

  Widget graphNavLarge() {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList();

    return Container(
        width: MediaQuery.of(context).size.width * 1.0 / 2,
        //height: MediaQuery.of(context).size.height * 1.0/1.75,
        //color: Colors.white,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              chartType == "chart"
                  ? Expanded(
                      child: TextWithDropDown(
                        "PERFORMANCE VS ",
                        widget.responseData['response']['navGraphData']
                            ['markets'][_selectedMarket],
                        _selectedMarketOption,
                        markets,
                        (Map<String, String> value) => value['title'],
                        (Map<String, String> value) {
                          marketSelectChange(value);
                        },
                      ),
                      // RichText(
                      //     text: TextSpan(
                      //         style: appGraphTitleLarge,
                      //         text: ("PERFORMANCE VS "),
                      //         children: [
                      //       markets.length > 1
                      //           ? TextSpan(
                      //               text: widget.responseData['response']
                      //                       ['navGraphData']['markets']
                      //                   [_selectedMarket],
                      //               style: appGraphTitleLarge.copyWith(
                      //                   color: colorBlue),
                      //               recognizer: TapGestureRecognizer()
                      //                 ..onTap = () => buildSelectBoxCustom(
                      //                     context: context,
                      //                     value: _selectedMarket,
                      //                     title: 'Select benchmark',
                      //                     options: markets,
                      //                     onChangeFunction: marketSelectChange))
                      //           : TextSpan(
                      //               text: widget.responseData['response']
                      //                       ['navGraphData']['markets']
                      //                   [_selectedMarket],
                      //               style: appGraphTitleLarge),
                      //       markets.length > 1
                      //           ? WidgetSpan(
                      //               child: Icon(Icons.keyboard_arrow_down,
                      //                   color: colorBlue, size: 14),
                      //             )
                      //           : WidgetSpan(child: emptyWidget),
                      //     ])),
                    )
                  : Expanded(
                      child: Text("Value over time".toUpperCase(),
                          style: appGraphTitleLarge),
                    ),
              ControlledSwitch(
                  trackColor: colorBlue,
                  value: chartType == "price" ? true : false,
                  onChanged: (newValue) async {
                    await _analyticsBenchmarkToggleEvent();
                    setState(() {
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
            _basketPerformanceBtnsLrage(context),
          ],
        ));
  }

  Widget _basketPerformanceBtnsLrage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _performanceButtonLarge(context, '3Y', '3year'),
        _performanceButtonLarge(context, '1Y', '1year'),
        _performanceButtonLarge(context, '6M', '6months'),
        _performanceButtonLarge(context, '3M', '3months'),
        _performanceButtonLarge(context, '1M', 'month'),
      ],
    );
  }

  Widget _performanceButtonLarge(
      BuildContext context, String title, String index) {
    return Expanded(
        child: ButtonTheme(
            minWidth: getScaledValue(80),
            //padding: EdgeInsets.symmetric(horizontal: getScaledValue(6.0)),

            child: RaisedButton(
              elevation: 0,
              padding: EdgeInsets.all(0.0),
              color: _performanceTenure == index
                  ? Color(0xffe2ecff)
                  : Colors.white,
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
                      width: index == "3year"
                          ? getScaledValue(1)
                          : getScaledValue(0),
                      color: Color(0xffe9e9e9)),
                  right: BorderSide(
                      width: getScaledValue(1), color: Color(0xffe9e9e9))),
            )));
  }

  Widget descriptionLarge() {
    List<Widget> _doPointers = [];
    List<Widget> _dontPointers = [];

    for (int i = 0; i <= 5; i++) {
      if (fundData['w' + i.toString()] != "" &&
          fundData['w' + i.toString()] != null)
        _doPointers.add(bulletPointerLarge(fundData['w' + i.toString()],
            bulletColor: colorBlue));

      if (fundData['nw' + i.toString()] != "" &&
          fundData['nw' + i.toString()] != null)
        _dontPointers.add(bulletPointerLarge(fundData['nw' + i.toString()],
            bulletColor: colorBlue));
    }

    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 1.0,
        padding:
            EdgeInsets.only(left: 24.0, top: 0.0, right: 24.0, bottom: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 1.0 / 2,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("What works:", style: headline5_analyse),
                                SizedBox(height: getScaledValue(6)),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: _doPointers),
                              ])),
                    ),
                    SizedBox(
                      width: getScaledValue(16),
                    ),
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 1.0 / 2,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("What does not works:",
                                    style: headline5_analyse),
                                SizedBox(height: getScaledValue(6)),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: _dontPointers),
                              ])),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ]));
  }

  Widget _portfolioValueLarge(String portfolioName, String portfolioValue,
      String change_sign, String change, List portfolio_zone,
      {bool includeLeftBorder = true}) {
    //List zones =  widget.model.userPortfoliosData[widget.portfolioMasterID];
//widget.model.userPortfoliosData['portfolio_zone'].split('_');

    return Container(
        width: getScaledValue(270),
        margin: EdgeInsets.only(right: getScaledValue(10)),
        //	padding: EdgeInsets.only(left: getScaledValue(15),top: getScaledValue(20),right: getScaledValue(15),bottom: getScaledValue(20)),
        padding: EdgeInsets.only(
            left: getScaledValue(15),
            top: getScaledValue(20),
            right: getScaledValue(15),
            bottom: getScaledValue(20)),
        decoration: BoxDecoration(color: Color(0xfff7f7f7)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(portfolioName, style: headline2_analyse),
                portfolio_zone != null
                    ? Row(
                        children: portfolio_zone
                            .map((item) => Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: widgetZoneFlag(item)))
                            .toList())
                    : emptyWidget
              ],
            )),
            SizedBox(
              height: getScaledValue(2),
            ),
            Expanded(
                child: Row(
              children: [
                Text(portfolioValue, style: bodyText0_analyse),
                SizedBox(width: 16),
                (change_sign == "up"
                    ? Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: getScaledValue(16.0),
                      )
                    : change_sign == "down"
                        ? Icon(
                            Icons.trending_down,
                            color: colorRed,
                            size: getScaledValue(16.0),
                          )
                        : emptyWidget),
                SizedBox(width: getScaledValue(5)),
                (change_sign == "up" || change_sign == "down"
                    ? Text(change.toString() + "%", style: portfolioBoxReturn)
                    : emptyWidget),
              ],
            )),
          ],
        ));
  }

  Widget _portfolioAnalyzerDetails() {
    return PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        child: PortfolioAnalyzerDetailLarge(widget.model,
            analytics: widget.analytics,
            observer: widget.observer,
            responseData: widget.responseData,
            selectedPortfolioMasterIDs: widget.selectedPortfolioMasterIDs,
            benchmark: widget.benchmark,
            tabIndex: 0));
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
  final List<charts.Series> seriesList;
  final bool animate = true;
  static String pointerValue;
  //SelectionCallbackExample({ Key key }) : super(key: key);

  SelectionCallbackExample(this.seriesList, {Key key}) : super(key: key);

  factory SelectionCallbackExample.withData(seriesList1) {
    // log.d(seriesList1);

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
