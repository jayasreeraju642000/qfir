import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('BenchmarkPerformance');

class BenchmarkPerformance extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final basketIndex = "1";

  BenchmarkPerformance(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _BenchmarkPerformanceState();
  }
}

class _BenchmarkPerformanceState extends State<BenchmarkPerformance> {
  final controller = ScrollController();

  _BenchmarkPerformanceState();

  List<Map<String, String>> markets = [];
  String _performanceTenure = "3year";

  Map<String, dynamic> _benchmarkPerformance;
  String _selectedMarket = "";

  StateSetter _setState, _setSaveButtonColorChangeState;

  String _selectedCurrency;

  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Benchmark Performance',
        screenClassOverride: 'BenchmarkPerformance');
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Benchmark Performance page",
    });
  }

  Future<Null> _analyticsChangeBenchmarkEvent() async {
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_benchmark_drop_down",
      'content_type': "select_benchmark_drop_down",
    });
  }

  Future<Null> _analyticsDurationFilterEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_toggle_duration",
      'content_type': "duration_toggle_button",
    });
  }

  Future<Null> _analyticsNameCardEvent() async {
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_portfolio_name_card",
      'content_type': "name_card_click",
    });
  }

  Future<Null> _analyticsPerformerCardEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_top_bottom_performer_card",
      'content_type': "performer_card_click",
    });
  }

  void initState() {
    super.initState();
    _analyticsCurrentScreen();

    getBenchmarkPerformance();

    // log.d('debug 82');
    // log.d(widget.model.userSettings);
  }

  refreshParent() => setState(() {});

  void getBenchmarkPerformance() async {
    widget.model.setLoader(true);
    _benchmarkPerformance = await widget.model.getBenchmarkPerformance();

    markets = [];
    _benchmarkPerformance['marketNames'].forEach((key, value) {
      markets.add({
        "value": key,
        "title": value,
      });
    });
    var benchmarks = _benchmarkPerformance['marketNames'].entries.toList();
    _selectedMarket = benchmarks[0].key;
    widget.model.setLoader(false);
  }

  @override
  Widget build(BuildContext context) {
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    changeStatusBarColor(Color(0xff0445e4));
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      _analyticsAddEvent();
      if (widget.model.isLoading) {
        return preLoader();
      } else {
        return Scaffold(
          appBar: commonScrollAppBar(controller: controller, actions: [
            Container(
              margin: EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                  onTap: () => filterPopup(),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                            text: "in ",
                            style: currencyConvert,
                            children: [
                              TextSpan(
                                  text:
                                      (widget.model.userSettings['currency'] !=
                                                  null
                                              ? widget.model
                                                  .userSettings['currency']
                                              : 'inr')
                                          .toUpperCase(),
                                  style: currencyConvertActive)
                            ]),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Color(0xff7ca8ff)),
                    ],
                  )
                  /* Image.asset('assets/icon/icon_filter.png', height: getScaledValue(16), width: getScaledValue(20)) */
                  ),
            )
          ]),
          body: _buildBody(),
        );
      }
    });
  }

  Widget _buildBody() {
    return mainContainer(
        context: context,
        containerColor: Color(0xffecf1fa),
        paddingBottom: 0,
        child: _basketInfo(context));
  }

  Widget _basketInfo(BuildContext context) {
    return Snap(
      controller: controller.appBar,
      child: ListView(
        physics: ClampingScrollPhysics(),
        controller: controller,
        children: <Widget>[
          Container(
            color: Colors.white,
            height: getScaledValue(210),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: Container(
                      height: getScaledValue(150.0),
                      //margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff0445e4), Color(0xff1181ff)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: getScaledValue(16.0)),
                          child: _portfolioValue())),
                ),
                Positioned(
                  top: 125,
                  left: getScaledValue(16.0),
                  right: getScaledValue(16.0),
                  // width: getScaledValue(360.0),
                  height: getScaledValue(75),
                  child: _portfolioMasterValue(),
                )
              ],
            ),
          ),
          _percentageReturn(),
          //Container(padding: EdgeInsets.symmetric(vertical: 10.0) ,alignment: Alignment.center, child: Text("Portfolio Performance", style: Theme.of(context).textTheme.headline6)),
          //_portfolioCount(),
          //performanceReturn(),
          //marketSelector(),
          SizedBox(height: getScaledValue(10)),
          _basketPerformance(context),
          portfolioPerformance(),
        ],
      ),
    );
  }

  Widget _portfolioValue() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Portfolio at a\nglance", style: appBenchmarkTitle),
            SizedBox(height: 55.0)
          ],
        )),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              removeDecimal(
                  widget.model.userPortfolioValue['value'].toString()),
              style: appBenchmarkValue,
            ),
            SizedBox(height: getScaledValue(9)),
            Row(
              children: <Widget>[
                (widget.model.userPortfolioValue['change_sign'] == "up"
                    ? Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: getScaledValue(16.0),
                      )
                    : widget.model.userPortfolioValue['change_sign'] == "down"
                        ? Icon(
                            Icons.trending_down,
                            color: colorRed,
                            size: getScaledValue(16.0),
                          )
                        : emptyWidget),
                SizedBox(width: getScaledValue(5.0)),
                (widget.model.userPortfolioValue['change_sign'] == "up" ||
                        widget.model.userPortfolioValue['change_sign'] == "down"
                    ? Text(widget.model.userPortfolioValue['change'].toString(),
                        style: appBenchmarkReturnPercentage)
                    : emptyWidget),
              ],
            ),
            SizedBox(height: 50.0),
          ],
        )
      ],
    ));
  }

  Widget _portfolioMasterValue() {
    List<Widget> childCarousel = [];

    widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
      if (portfolioMasterID != '0' && portfolio['default'] == '1') {
        childCarousel.add(_portfolioMasterValueContainer(portfolio));
      }
    });

    /* childCarousel.add(_portfolioMasterValueContainer({}));
		childCarousel.add(_portfolioMasterValueContainer({}));
		childCarousel.add(_portfolioMasterValueContainer({}));
		childCarousel.add(_portfolioMasterValueContainer({}));
		childCarousel.add(_portfolioMasterValueContainer({}));
		childCarousel.add(_portfolioMasterValueContainer({})); */

    childCarousel.add(_modifyDefaultPortfolio());

    return ListView(
      scrollDirection: Axis.horizontal,
      children: childCarousel,
    );
  }

  Widget _portfolioMasterValueContainer(Map portfolioMasterData) {
    return GestureDetector(
      onTap: () {
        _analyticsNameCardEvent();
        return Navigator.pushNamed(
            context, '/portfolio_view/' + portfolioMasterData['id'],
            arguments: {'readOnly': true});
      },
      child: Container(
        width: getScaledValue(134),
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(18), vertical: getScaledValue(10)),
        margin: EdgeInsets.only(left: getScaledValue(14.0)),
        decoration: BoxDecoration(
          boxShadow: [
            /* BoxShadow(
		  				color: Color(0x25808080),
		  				blurRadius: 15.0, // soften the shadow
		  				spreadRadius: 1.0, //extend the shadow
		  				offset: Offset(
		  					0.5, // Move to right 10  horizontally
		  					0, // Move to bottom 10 Vertically
		  				),
		  			) */
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: Color(0xfff5f5f5),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(limitChar(portfolioMasterData['portfolio_name'], length: 10),
                style: appBenchmarkPortfolioName),
            SizedBox(height: getScaledValue(9)),
            Text(
                removeDecimal(portfolioMasterData['value']
                    .toString()) /* portfolioMasterData['value'] */,
                style: appBenchmarPortfolioValue),
          ],
        ),
      ),
    );
  }

  Widget _modifyDefaultPortfolio() {
    int selectedPortfoliosCount = 0;
    int totalPortfoliosCount = 0;
    widget.model.userPortfoliosData
        .forEach((portfolioMasterID, portfolioMasterData) {
      if (portfolioMasterData['default'] == '1') {
        selectedPortfoliosCount++;
      }

      if (portfolioMasterID != "0") {
        totalPortfoliosCount++;
      }
    });
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/portfolio_master_selectors/default',
            arguments: {}).then((_) => refreshParent());
      },
      child: Container(
        // width: getScaledValue(180),
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(10), vertical: getScaledValue(10)),
        margin: EdgeInsets.only(left: getScaledValue(14.0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: Color(0xfff5f5f5),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                "Included " +
                    selectedPortfoliosCount.toString() +
                    ' of ' +
                    totalPortfoliosCount.toString() +
                    ' portfolios',
                style: appBenchmarkPortfolioName), //  for your daily briefing
            SizedBox(height: getScaledValue(5)),
            Text('Change selection',
                style: appBenchmarkLink.copyWith(fontSize: getScaledValue(12))),
          ],
        ),
      ),
    );
  }

  Widget _percentageReturn() {
    if (_benchmarkPerformance == null) {
      return Container();
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(28.0), vertical: getScaledValue(20.0)),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      _benchmarkPerformance['graphData'][_selectedMarket]
                                  [_performanceTenure]['cagr']
                              .toString() +
                          "%",
                      style: appBenchmarkReturnValue.copyWith(
                          color: _benchmarkPerformance['graphData']
                                          [_selectedMarket][_performanceTenure]
                                      ['cagr'] <
                                  0
                              ? colorRedReturn
                              : colorGreenReturn)),
                  Text("Time Weighted Return", style: appBenchmarkReturnType),
                  Text("(CAGR)", style: appBenchmarkReturnType2),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      _benchmarkPerformance['graphData'][_selectedMarket]
                                  [_performanceTenure]['xirr']
                              .toString() +
                          "%",
                      style: appBenchmarkReturnValue.copyWith(
                          color: _benchmarkPerformance['graphData']
                                          [_selectedMarket][_performanceTenure]
                                      ['xirr'] <
                                  0
                              ? colorRedReturn
                              : colorGreenReturn)),
                  Text("Money Weighted Return", style: appBenchmarkReturnType),
                  Text("(XIRR)", style: appBenchmarkReturnType2),
                ],
              ),
            ],
          ),
          SizedBox(height: getScaledValue(27.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () => bottomAlertBox(
                    context: context,
                    title: "Time Weighted Return",
                    description:
                        "The annualized rate at which the investment has grown since the day it is being tracked, irrespective of the frequency or the amount of cash that has flown into or out of this investment during this period. This allows an investor to compare multiple investment alternatives with each other and set expectations for the future. This is also commonly known as the Compound Annual Growth Rate (CAGR)",
                    title2: "Money Weighted Return",
                    description2:
                        "The annualized rate of return that takes into account the impact of all fund inflows and outflows on the performance of an investment. This, therefore, represents the true return an investor has achieved on a particular investment over time. This is also commonly known as the Extended Internal Rate of Return (XIRR) \n \n If there are no cash inflows or outflows during the investment period, apart from the initial sum invested, then both XIRR and CAGR should deliver the same results"),
                child: Text("What is this?", style: appBenchmarkLink),
              ),
              widget.model.oldestInvestmentDate != null
                  ? Text(
                      "since " +
                          widget.model.oldestInvestmentDate.toUpperCase(),
                      style: appBenchmarkSince)
                  : emptyWidget,
            ],
          )
        ],
      ),
    );
  }

  Widget widgetBasketCategoryItem(BuildContext context, String category) {
    Color bgColor = Theme.of(context).primaryColor;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        margin: EdgeInsets.only(bottom: 5.0, right: 5.0),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.all(Radius.circular(2.0))),
        child: Text(category,
            style: TextStyle(color: Colors.white, fontSize: 10.0)));
  }

  Widget selectMarket() {
    return buildSelectBox(
      context: context,
      value: _selectedMarket,
      options: markets,
      onChangeFunction: (val) {
        List<charts.Series<TimeSeriesSales, DateTime>> chartData =
            chartDataList(
                _benchmarkPerformance['graphData'][val][_performanceTenure],
                val);
        setState(() {
          key.currentState._seriesList = chartData;
          _selectedMarket = val;
        });
      },
    );
  }

  Widget marketSelector() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Benchmark",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Theme.of(context).focusColor),
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 5.0,
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 10.0),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                      /*  borderRadius: , */
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        items: markets.map((market) {
                          return DropdownMenuItem<String>(
                            value: market.toString(),
                            child: Text(market.toString()),
                          );
                        }).toList(),
                        hint: Text(
                            (_selectedMarket != ""
                                ? _selectedMarket
                                : "Market"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.grey[600])),
                        onChanged: (String value) {
                          List<charts.Series<TimeSeriesSales, DateTime>>
                              chartData = chartDataList(
                                  _benchmarkPerformance['graphData'][value]
                                      [_performanceTenure],
                                  value); // @todo
                          setState(() {
                            key.currentState._seriesList = chartData;
                            _selectedMarket = value;
                          });
                        },
                      ),
                    )),
              ))
            ]));
  }

  void marketSelectChange(value) {
    _analyticsChangeBenchmarkEvent();
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList(
        _benchmarkPerformance['graphData'][value][_performanceTenure],
        value); // @todo
    setState(() {
      key.currentState._seriesList = chartData;
      _selectedMarket = value;
    });
  }

  Widget _basketPerformance(BuildContext context) {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList(
        _benchmarkPerformance['graphData'][_selectedMarket][_performanceTenure],
        _selectedMarket); //@todo

    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
                text: TextSpan(
                    style: appGraphTitle,
                    text: ("PERFORMANCE VS "),
                    children: [
                  TextSpan(
                      text: _benchmarkPerformance['marketNames']
                          [_selectedMarket],
                      style: appGraphTitle.copyWith(color: colorBlue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => buildSelectBoxCustom(
                            context: context,
                            value: _selectedMarket,
                            title: 'Select benchmark',
                            options: markets,
                            onChangeFunction: marketSelectChange)),
                  WidgetSpan(
                    child: Icon(Icons.keyboard_arrow_down,
                        color: colorBlue, size: 14),
                  ),
                ])),
            SizedBox(height: getScaledValue(25.0)),
            SelectionCallbackExample(chartData, key: key),
            SizedBox(height: getScaledValue(25.0)),
            _basketPerformanceBtns(context),
          ],
        ));

    //return SliderLine.withSampleData();
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
        /* _performanceButton(context, '1W', 'week'), */
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
            _analyticsDurationFilterEvent();
            List<charts.Series<TimeSeriesSales, DateTime>> chartData =
                chartDataList(
                    _benchmarkPerformance['graphData'][_selectedMarket][index],
                    _selectedMarket); // @todo

            setState(() {
              key.currentState._seriesList = chartData;
              _performanceTenure = index;
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
                  width: getScaledValue(1),
                  color: Color(
                      0xffe9e9e9))), //RoundedRectangleBorder(side: BorderSide(color: Colors.black)),
        ));
  }

  List<charts.Series<TimeSeriesSales, DateTime>> chartDataList(
      benchmarkPerformanceData, marketName) {
    final List<TimeSeriesSales> portfolioData = [];
    final List<TimeSeriesSales> benchmarkData = [];

    for (var i = 0; i < benchmarkPerformanceData['portfolioData'].length; i++) {
      DateTime dateNAV = DateTime.fromMillisecondsSinceEpoch(
          benchmarkPerformanceData['portfolioData'][i][0]);
      double navValue =
          benchmarkPerformanceData['portfolioData'][i][1].toDouble();
      portfolioData.add(new TimeSeriesSales(dateNAV, navValue));

      if (benchmarkPerformanceData.containsKey('benchmarkData')) {
        double hurdleValue =
            benchmarkPerformanceData['benchmarkData'][i][1].toDouble();
        benchmarkData.add(new TimeSeriesSales(dateNAV, hurdleValue));
      }
    }

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Portfolio',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    if (benchmarkPerformanceData.containsKey('benchmarkData')) {
      chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
        id: (marketName),
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: benchmarkData,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffc0c0c0))),
      ));
    }

    return chartDataList;
  }

  Widget performanceReturn() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _benchmarkPerformance['graphData'][_selectedMarket]
                        [_performanceTenure]['cagr'] !=
                    null
                ? containerCard(
                    context: context,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Expanded(
                            child: Text('Portfolio CAGR',
                                style: Theme.of(context).textTheme.bodyText2,
                                softWrap: true)),
                        Container(
                          padding: EdgeInsets.all(10.0),
                        ),
                        Expanded(
                            flex: 0,
                            child: Text(
                                _benchmarkPerformance['graphData']
                                                [_selectedMarket]
                                            [_performanceTenure]['cagr']
                                        .toString() +
                                    "%",
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        color: ((_benchmarkPerformance[
                                                                'graphData']
                                                            [_selectedMarket]
                                                        [_performanceTenure]
                                                    ['cagr']) <
                                                0
                                            ? Colors.red
                                            : Colors.green)))),
                      ],
                    ),
                  )
                : emptyWidget,
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: _benchmarkPerformance['graphData'][_selectedMarket]
                        [_performanceTenure]['xirr'] !=
                    null
                ? containerCard(
                    context: context,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Expanded(
                            child: Text('Portfolio XIRR',
                                style: Theme.of(context).textTheme.bodyText2,
                                softWrap: true)),
                        Container(
                          padding: EdgeInsets.all(10.0),
                        ),
                        Expanded(
                            flex: 0,
                            child: Text(
                                _benchmarkPerformance['graphData']
                                                [_selectedMarket]
                                            [_performanceTenure]['xirr']
                                        .toString() +
                                    "%",
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        color: ((_benchmarkPerformance[
                                                                'graphData']
                                                            [_selectedMarket]
                                                        [_performanceTenure]
                                                    ['xirr']) <
                                                0
                                            ? Colors.red
                                            : Colors.green)))),
                      ],
                    ),
                  )
                : emptyWidget,
          ),
        ],
      ),
    );
  }

  Widget portfolioPerformance() {
    if (_benchmarkPerformance['graphData'][_selectedMarket][_performanceTenure]
            ['top'] !=
        null) {
      _benchmarkPerformance['graphData'][_selectedMarket][_performanceTenure]
              ['top']
          .forEach((key, value) {});
    }

    return Container(
        padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0, bottom: 15.0),
        margin: EdgeInsets.symmetric(horizontal: getScaledValue(16.0)),
        child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  /* Expanded(child: portfolioList(_benchmarkPerformance['graphData'][_selectedMarket][_performanceTenure]['top'], "Top "+ portfolioNum +"Performing \n Stocks", paddingRight: 10.0)),								 */
                  /* Expanded(child: portfolioList(_benchmarkPerformance['graphData'][_selectedMarket][_performanceTenure]['last'], "Bottom "+ portfolioNum +"performing \n Stocks", paddingRight: 10.0)), */

                  SizedBox(
                    height: 30.0,
                  ),
                  _benchmarkPerformance['graphData'][_selectedMarket]
                              [_performanceTenure]['top'] !=
                          null
                      ? Container(
                          child: portfolioList(
                              _benchmarkPerformance['graphData']
                                  [_selectedMarket][_performanceTenure]['top'],
                              "Top Performers".toUpperCase()))
                      : emptyWidget,
                  SizedBox(
                    height: 30.0,
                  ),
                  _benchmarkPerformance['graphData'][_selectedMarket]
                              [_performanceTenure]['last'] !=
                          null
                      ? Container(
                          child: portfolioList(
                              _benchmarkPerformance['graphData']
                                  [_selectedMarket][_performanceTenure]['last'],
                              "Bottom Performers".toUpperCase()))
                      : emptyWidget,
                ],
              ),

              /* Text(
							_performanceTenure == "3year" ? "** Stock Performance Annualized" : "** Stock Performance Point to Point",
							style: Theme.of(context).textTheme.overline
						) */
            ]));
  }

  Widget portfolioList(portfolioList, String title,
      {double paddingRight: 0.0, double paddingLeft: 0.0}) {
    return Container(
      padding:
          EdgeInsets.only(right: paddingRight, left: paddingLeft, top: 0.0),
      margin: EdgeInsets.only(top: 0.0),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: appGraphTitle),
          SizedBox(height: 10.0),
          ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100.0,
              ),
              child: _portfolioList(portfolioList))
        ],
      ),
    );
  }

  Widget _portfolioList(portfolioList) {
    List<Widget> listPortfolios = [];

    portfolioList.forEach((key, value) {
      listPortfolios.add(GestureDetector(
        onTap: () async {
          _analyticsPerformerCardEvent();
          return Navigator.of(context)
              .pushNamed('/fund_info', arguments: {'ric': key});
        },
        child: containerCard(
          paddingBottom: getScaledValue(16.0),
          paddingLeft: getScaledValue(16.0),
          paddingRight: getScaledValue(16.0),
          paddingTop: getScaledValue(16.0),
          context: context,
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Text(value['name'],
                          style: appBenchmarkPerformerName)),
                  Row(
                    children: <Widget>[
                      (double.parse(value['value']) > 0
                          ? Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: getScaledValue(16.0),
                            )
                          : double.parse(value['value']) < 0
                              ? Icon(
                                  Icons.trending_down,
                                  color: colorRed,
                                  size: getScaledValue(16.0),
                                )
                              : emptyWidget),
                      SizedBox(width: getScaledValue(4)),
                      Text(value['value'].toString() + "%",
                          textAlign: TextAlign.right,
                          style: appBenchmarkPerformerReturn)
                    ],
                  )
                ],
              ),
              SizedBox(height: getScaledValue(8)),
              Row(
                //crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  widgetBubble(
                      title: value['type'].toUpperCase(),
                      leftMargin: 0,
                      rightMargin: 0,
                      fontSize: getScaledValue(7)),
                  SizedBox(width: getScaledValue(9)),
                  widgetZoneFlag(value['zone']),
                ],
              )
              /* Column(
		  								children: <Widget>[
		  									Text(
		  										value['value'].toString() + "%", 
		  										textAlign: TextAlign.right, 
		  										style: Theme.of(context).textTheme.bodyText2.copyWith(color: (double.parse(value['value']) < 0 ? Colors.red : Colors.green) ) 
		  									) 
		  								],
		  							), */
            ],
          ),
        ),
      ));
    });

    return Container(
        child: Flex(
      direction: Axis.vertical,
      children: listPortfolios,
    ));
  }

  void filterPopup() {
    customAlertBox(
      context: context,
      childContent: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return _filterPopup();
        },
      ),
      buttons: <Widget>[
        TextButton(
          child: Text("Cancel", style: dialogBoxActionInactive),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setSaveButtonColorChangeState = setState;
            return Text("Save",
                style: _selectedCurrency != null
                    ? dialogBoxActionActive
                    : dialogBoxActionInactive);
          }),
          onPressed: () async {
            if (_selectedCurrency != null) {
              Navigator.of(context).pop();
              setState(() {
                widget.model.setLoader(true);
              });
              Map<String, dynamic> responseData =
                  await widget.model.changeCurrency(_selectedCurrency);
              if (responseData['status'] == true) {
                await getBenchmarkPerformance();
                await widget.model.fetchOtherData();
              }
              setState(() {
                widget.model.setLoader(false);
              });
            }
          },
        )
      ],
    );

    // flutter defined function
    /* showDialog(
		context: context,
		builder: (BuildContext context) {
			// return object of type Dialog
			return AlertDialog(
			content: StatefulBuilder(
				builder: (BuildContext context, StateSetter setState) {
					_setState = setState;
				return _filterPopup();
				},
			),
			actions: <Widget>[
				FlatButton(
					child: Text("Cancel", style: dialogBoxActionInactive),
					onPressed: () {
						Navigator.of(context).pop();
					},
				),
				FlatButton(
					child: Text("Save", style: dialogBoxActionActive),
					onPressed: () async {
						Navigator.of(context).pop();
						setState(() {
							widget.model.setLoader(true);
						});
						Map<String, dynamic> responseData =
							await widget.model.changeCurrency(_selectedCurrency);
						if (responseData['status'] == true) {
							await getBenchmarkPerformance();
							await widget.model.fetchOtherData();
						}
						setState(() {
							widget.model.setLoader(false);
						});
					},
				)
			],
			);
		},
		); */
  }

  Widget _filterPopup() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite < getScaledValue(365)
          ? double.maxFinite
          : null, // double.maxFinite,
      child: Form(
          child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: DropdownButton<String>(
                hint: Text('Currency'),
                isExpanded: true,
                value: _selectedCurrency,
                items: widget.model.currencies.map((Map item) {
                  return DropdownMenuItem<String>(
                    value: item['key'],
                    child: Text(item['value']),
                  );
                }).toList(),
                onChanged: (value) {
                  _setState(() {
                    _selectedCurrency = value;
                  });
                  _setSaveButtonColorChangeState(() {});
                },
              )),
            ],
          ),
        ],
      )),
    );
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
  bool _animate;

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
                  model.selectedDatum;
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

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}

class ClampingBehaviour extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}
