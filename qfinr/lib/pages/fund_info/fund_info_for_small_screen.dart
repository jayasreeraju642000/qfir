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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/controller_switch.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('FundInfo');

class FundInfoForSmallScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String ric;

  FundInfoForSmallScreen(this.model, {this.analytics, this.observer, this.ric});

  @override
  State<StatefulWidget> createState() {
    return _FundInfoForSmallScreenState();
  }
}

class _FundInfoForSmallScreenState extends State<FundInfoForSmallScreen>
    with SingleTickerProviderStateMixin {
  final controller = ScrollController();
  int tabIndex = 0;
  Map<String, dynamic> responseData;
  String _selectedMarket;
  String _performanceTenure = "3year";
  List<Map<String, String>> markets = [];

  String chartType = "chart";

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Fund Information', screenClassOverride: 'FundInfo');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Fund Information",
    });
  }

  List<Map<String, String>> ricInfoList = [];
  Map<String, dynamic> ricInfo = {};
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    log.d("fund_info");
    _tabController =
        TabController(length: 1, vsync: this, initialIndex: tabIndex);

    _currentScreen();
    _addEvent();

    fetchFundInformation();
  }

  fetchFundInformation() async {
    setState(() {
      widget.model.setLoader(true);
    });
    responseData =
        await widget.model.fetchFundInfo(widget.ric) as Map<String, dynamic>;
    if (responseData['status'] == true) {
      var graphData = responseData['response']['graphData'].entries.toList();
      _selectedMarket = graphData[0].key;

      responseData['response']['markets'].forEach((key, value) {
        markets.add({"value": key, "title": value});
      });

      if (responseData['response']['ricInfo']['about'] != null &&
          responseData['response']['ricInfo']['about'] != "") {
        ricInfo = responseData['response']['ricInfo']['about'];

        ricInfo.forEach((key, value) {
          ricInfoList.add({"key": key.toString(), "value": value.toString()});
        });
      }

      setState(() {
        widget.model.setLoader(false);
      });
    } else if (responseData['status'] == false) {
      setState(() {
        widget.model.setLoader(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: commonAppBar(bgColor: Colors.white, actions: [
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
    if (widget.model.isLoading) {
      return preLoader();
    } else {
      return mainContainer(
          context: context,
          paddingBottom: 0,
          containerColor: Colors.white,
          child: _buildBodyContent());
    }
  }

  Widget _buildBodyContent() {
    return ListView(
        controller: controller,
        physics: ClampingScrollPhysics(),
        children: [
          fundInfo(),
          sectionSeparator(),
          graphNav(),
          sectionSeparator(),
          /* Container(
					color: Colors.white,
					padding: EdgeInsets.symmetric(vertical: getScaledValue(20), horizontal: getScaledValue(18)),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									svgImage("assets/icon/icon_star.svg", height: 22, width: 24),
									SizedBox(width: getScaledValue(7)),
									Text(
										("Success Rate: " + roundDouble(responseData['response']['statsData']['successratio']) + "%").toUpperCase(),
										style: keyStatsBodyText3.copyWith(color: colorGreen2)
									),
								],
							),
							SizedBox(height: getScaledValue(5)),
							Text('description', style: keyStatsBodyText5)
						]
					)
				),
				sectionSeparator(), */
          _keyStatsBox1(
              title: 'Key Stats',
              returns: responseData['response']['statsData']['cagr'],
              risks: responseData['response']['statsData']['stddev'],
              value3: responseData['response']['statsData']['Bench_beta'],
              value4: responseData['response']['statsData']['drawdown']),
          /* _performanceRemarks(
					title: "Similarity",
					subtitle: "(R - Square)",
					value: roundDouble(responseData['response']['statsData']['Bench_r2']),
					description: "The ‘R-squared’. It is generally seen as the percentage of a fund’s returns that can be explained by movements in the Index/ETF. We use a 3 year period. A high similarity implies that the low cost ETF would be a credible alternative to the fund"
				), */

          ["Funds", "ETF"].contains(responseData['response']['details']['type'])
              ? Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: getScaledValue(20),
                      horizontal: getScaledValue(18)),
                  child: gradientButton(
                      context: context,
                      caption: "Know More",
                      onPressFunction: () => analyzeFundRIC()))
              : emptyWidget,
          sectionSeparator(),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: getScaledValue(30)),
            color: Colors.white,
            child: tabbar(),
          ),
          SizedBox(
            height: getScaledValue(2),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: getScaledValue(18),
              horizontal: getScaledValue(30),
            ),
            color: Colors.white,
            child: _buildBodyTabContent(),
          ),
        ]);
  }

  PreferredSizeWidget tabbar() {
    List<Widget> tabChildren = [];
    tabChildren.add(Tab(text: "about".toUpperCase()));
    //tabChildren.add(Tab(text: "FUNDAMENTALS"));
    //tabChildren.add(Tab(text: "FINANCIAL"));
    return TabBar(
      isScrollable: true,
      controller: _tabController,
      unselectedLabelColor: Color(0xff979797),
      labelColor: Color(0xff034bd9),
      indicatorWeight: getScaledValue(2),
      indicatorColor: Color(0xff034bd9),
      unselectedLabelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(12.0),
          fontWeight: FontWeight.w800,
          fontFamily: 'nunito',
          letterSpacing: 0.86,
          color: Color(0xff979797)),
      labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(12.0),
          fontWeight: FontWeight.w800,
          fontFamily: 'nunito',
          letterSpacing: 0.86,
          color: Color(0xff034bd9)),
      onTap: (index) {
        switch (index) {
          case 0:
            // _analyticsSummaryClickEvent();
            break;
          case 1:
            // _analyticsKeyStaticsClickEvent();
            break;
          case 2:
            // _analyticsPerformanceComparisonClickEvent();
            break;
        }
        log.d(index);
        setState(() {
          tabIndex = index;
        });
      },
      tabs: tabChildren,
    );
  }

// NEW ONE
  Widget _buildBodyTabContent() {
    Widget child;

    if (tabIndex == 0) {
      child = ricInfoList.isNotEmpty ? _ricContainer() : _buildBodyEmptyList();
    } else if (tabIndex == 1) {
      child = _buildBodyEmptyList();
    } else if (tabIndex == 2) {
      child = _buildBodyEmptyList();
    }

    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      child: Column(
        children: [child],
      ),
    );
  }

  Widget _buildBodyEmptyList() {
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Text(
          "No data available",
          style: appBodyH3,
          textAlign: TextAlign.center,
        ));
  }

  Widget _ricContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Container(
          //   padding: EdgeInsets.symmetric(
          //       vertical: getScaledValue(20), horizontal: getScaledValue(16)),
          //   color: Color(0xfff5f6fa),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Container(
          //           width: MediaQuery.of(context).size.width * 0.30,
          //           child: Row(
          //             children: [
          //               Expanded(
          //                 child: Text("Descriptors".toUpperCase(),
          //                     style: TextStyle(
          //                         fontSize: ScreenUtil().setSp(12.0),
          //                         fontWeight: FontWeight.w800,
          //                         fontFamily: 'nunito',
          //                         letterSpacing: 0.86,
          //                         color: Color(0xffa5a5a5))),
          //               )
          //             ],
          //           )),
          //       SizedBox(
          //         width: 16,
          //       ),
          //       Expanded(
          //           child: Text("Length".toUpperCase(),
          //               style: TextStyle(
          //                   fontSize: ScreenUtil().setSp(12.0),
          //                   fontWeight: FontWeight.w800,
          //                   fontFamily: 'nunito',
          //                   letterSpacing: 0.86,
          //                   color: Color(0xffa5a5a5))))
          //     ],
          //   ),
          // ),

          // SizedBox(
          //   height: 6,
          // ),
          statsRowLarge()
        ],
      ),
    );
  }

  statsRowLarge() {
    return Container(
        padding: EdgeInsets.symmetric(
          vertical: getScaledValue(6),
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Color(0xffdadada),
          width: 1.0,
        ))),
        child: Column(
          children: [
            for (int i = 0; i < ricInfoList.length; i++)
              Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(ricInfoList[i]['key'].toString(),
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(12.0),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'nunito',
                                          letterSpacing: 0.2,
                                          color: Color(0xff383838))))
                            ],
                          )),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: Text(ricInfoList[i]['value'].toString(),
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(12.0),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0.2,
                                  color: Color(0xff979797))))
                    ]),
              )
          ],
        ));
  }

  analyzeFundRIC() async {
    setState(() {
      widget.model.setLoader(true);
    });

    Map<String, dynamic> responseData = await widget.model.knowYourPortfolio({
      widget.ric: {'ric': widget.ric}
    });

    if (responseData['status']) {
      Navigator.pushNamed(context, '/knowFundReport',
          arguments: {'responseData': responseData});
      setState(() {
        widget.model.setLoader(false);
      });
    } else {
      setState(() {
        widget.model.setLoader(false);
      });
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  Widget fundInfo() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
            vertical: getScaledValue(20), horizontal: getScaledValue(18)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          responseData['response']['details']['ticker'] != null
                              ? Text(
                                  responseData['response']['details']
                                          ['ticker'] ??
                                      "",
                                  style: bodyText4)
                              : emptyWidget,
                          Text(responseData['response']['details']['name'],
                              style: headline1),
                        ]),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: getScaledValue(5)),
                      widgetBubble(
                          title: responseData['response']['details']['type']
                              .toUpperCase(),
                          leftMargin: 0,
                          rightMargin: 0,
                          bgColor: Colors.white,
                          textColor: Color(0xffa7a7a7)),
                      SizedBox(height: getScaledValue(10)),
                      widgetZoneFlag(
                          responseData['response']['details']['zone'])
                    ],
                  )
                ],
              ),
              SizedBox(height: getScaledValue(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      Text(
                          responseData['response']['details']['type'] == "Funds"
                              ? "NAV: "
                              : "Price: ",
                          style: bodyText4),
                      Text(responseData['response']['value']['value'],
                          style: bodyText10),
                      (responseData['response']['value']['change_sign'] == "up"
                          ? Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: getScaledValue(16.0),
                            )
                          : responseData['response']['value']['change_sign'] ==
                                  "down"
                              ? Icon(
                                  Icons.trending_down,
                                  color: colorRed,
                                  size: getScaledValue(16.0),
                                )
                              : emptyWidget),
                      (responseData['response']['value']['change_sign'] ==
                                  "up" ||
                              responseData['response']['value']
                                      ['change_sign'] ==
                                  "down"
                          ? Text(
                              responseData['response']['value']['change']
                                  .toString(),
                              style: bodyText4)
                          : emptyWidget),
                    ],
                  )),
                  Text(
                      "As on " +
                          dateString(
                              responseData['response']['value']['latest_date'],
                              format: 'dd MMM, yyyy'),
                      style: bodyText4),
                ],
              ),
              SizedBox(height: getScaledValue(5)),
              responseData['response']['details']['core2'] != null
                  ? Row(
                      children: [
                        Text("Category: ", style: bodyText4),
                        Text(responseData['response']['details']['core2'],
                            style: bodyText10),
                      ],
                    )
                  : emptyWidget,
              SizedBox(height: getScaledValue(5)),
              responseData['response']['details']['sector'] != null
                  ? Row(
                      children: [
                        Text("Sector: ", style: bodyText4),
                        Text(responseData['response']['details']['sector'],
                            style: bodyText10),
                      ],
                    )
                  : emptyWidget
            ],
          )),
        ]));
  }

  Widget _keyStatsBox1(
      {String title, var returns, var risks, var value3, var value4}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: getScaledValue(20), horizontal: getScaledValue(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title.toUpperCase(), style: keyStatsBodyHeading),
              GestureDetector(
                  onTap: () => bottomAlertBox(
                        context: context,
                        title: "Returns",
                        description:
                            "The annualized 3 year returns using data as of the end of the preceding month",
                        title2: "Risks",
                        description2:
                            "The annualized volatility of monthly returns over 3 years as of the end of the preceding month",
                        title3: "Sensitivity",
                        description3:
                            "The beta computed from the regression of the monthly excess returns of the fund over risk free returns and the excess returns of the fund’s benchmark. We calculate the risk free rate from short term government bills.  It measures the volatility of the fund compared to the systematic risk of the chosen benchmark",
                        title4: "Maximum Loss",
                        description4:
                            "The maximum observed loss from a peak to a trough, before a new peak is attained over the past 3 years using daily prices. Maximum drawdown is an indicator of downside risk over the time period",
                      ),
                  child: Text('What is this?', style: textLink2)),
            ],
          ),
          statsRow(
              title: 'Returns',
              description: '3 yrs CAGR',
              value1: roundDouble(returns) + "%",
              includeBottomBorder: true),
          statsRow(
              title: 'Risks',
              description: 'Annualised Volatility',
              value1: roundDouble(risks) + "%",
              includeBottomBorder: true),
          statsRow(
              title: 'Sensitivity',
              description: 'Beta',
              value1: roundDouble(value3),
              includeBottomBorder: true),
          statsRow(
              title: 'Maximum Loss',
              description: 'Max Drawdown',
              value1: roundDouble(value4) + "%",
              includeBottomBorder: false),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                chartType == "chart"
                    ? RichText(
                        text: TextSpan(
                            style: appGraphTitle,
                            text: ("PERFORMANCE VS "),
                            children: [
                            markets.length > 1
                                ? TextSpan(
                                    text: responseData['response']['markets']
                                        [_selectedMarket],
                                    style: appGraphTitle.copyWith(
                                        color: colorBlue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => buildSelectBoxCustom(
                                          context: context,
                                          value: _selectedMarket,
                                          title: 'Select benchmark',
                                          options: markets,
                                          onChangeFunction: marketSelectChange))
                                : TextSpan(
                                    text: responseData['response']['markets']
                                        [_selectedMarket],
                                    style: appGraphTitle),
                            markets.length > 1
                                ? WidgetSpan(
                                    child: Icon(Icons.keyboard_arrow_down,
                                        color: colorBlue, size: 14),
                                  )
                                : WidgetSpan(child: emptyWidget),
                          ]))
                    : Text("Value over time".toUpperCase(),
                        style: appGraphTitle),
                ControlledSwitch(
                    trackColor: colorBlue,
                    value: chartType == "price" ? true : false,
                    onChanged: (newValue) async {
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
              ],
            ),
            SizedBox(height: getScaledValue(25.0)),
            SelectionCallbackExample(chartData, key: key),
            SizedBox(height: getScaledValue(25.0)),
            _basketPerformanceBtns(context),
          ],
        ));
  }

  Widget _basketPerformanceBtns(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _performanceButton(context, '3Y', '3year'),
        _performanceButton(context, '1Y', '1year'),
        _performanceButton(context, '6M', '6months'),
        _performanceButton(context, '3M', '3months'),
        _performanceButton(context, '1M', 'month'),
      ],
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

    responseData['response']['graphData'][_selectedMarket][_performanceTenure]
            ['portfolioData']
        .forEach((key_date, value) {
      if (responseData['response']['graphData'][_selectedMarket]
              [_performanceTenure]['benchmarkData']
          .containsKey(key_date)) {
        DateTime dateNAV = DateTime.parse(key_date);
        double navValue = responseData['response']['graphData'][_selectedMarket]
                [_performanceTenure]['portfolioData'][key_date]
            .toDouble();
        double hurdleValue = responseData['response']['graphData']
                [_selectedMarket][_performanceTenure]['benchmarkData'][key_date]
            .toDouble();
        portfolioData.add(new TimeSeriesSales(dateNAV, navValue));
        benchmarkData.add(new TimeSeriesSales(dateNAV, hurdleValue));
      }
    });

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Holding',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: (responseData['response']['markets'][_selectedMarket]),
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: benchmarkData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffc0c0c0))),
    ));

    return chartDataList;
  }

  List<charts.Series<TimeSeriesSales, DateTime>> priceChartDataList() {
    final List<TimeSeriesSales> portfolioData = [];

    responseData['response']['priceGraph'][_performanceTenure]
        .forEach((key_date, value) {
      DateTime dateNAV = DateTime.parse(key_date);
      double navValue = responseData['response']['priceGraph']
              [_performanceTenure][key_date]
          .toDouble();
      portfolioData.add(new TimeSeriesSales(dateNAV, navValue));
    });

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Holding',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    return chartDataList;
  }
}

// ***************** chart library ***************
class SelectionCallbackExample extends StatefulWidget {
  final List<charts.Series> seriesList;
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

                  if (model.selectedDatum[0].series.id == "Holding") {
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
