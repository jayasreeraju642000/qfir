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
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_portfolio/large_controller_switch.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/text_with_drop_down_button.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';

final log = getLogger('PortfolioChart');

class LargePortfolioChart extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String portfolioMasterID;

  LargePortfolioChart(this.model,
      {this.analytics, this.observer, this.portfolioMasterID});

  @override
  State<StatefulWidget> createState() {
    return _LargePortfolioChartState();
  }
}

class _LargePortfolioChartState extends State<LargePortfolioChart> {
  final key = new GlobalKey<_SelectionCallbackState>();
  final controller = ScrollController();

  Map<String, dynamic> responseData;
  bool responseDataHavingError = false;
  String _selectedMarket;
  String _performanceTenure = "3year";
  List<Map<String, String>> markets = [];
  Map<String, String>
      _selectedMarketOption; //newly added variable for performance vs [dropdown]
  Map portfolioMasterData = {};
  bool showAnalysisButton = true;

  String chartType = "chart";

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Chart', screenClassOverride: 'PortfolioChart');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Chart",
    });
  }

  @override
  void initState() {
    super.initState();

    _currentScreen();
    _addEvent();
    portfolioMasterData =
        widget.model.userPortfoliosData[widget.portfolioMasterID];
    if (portfolioMasterData != null &&
        portfolioMasterData['portfolios'] != null &&
        portfolioMasterData['portfolios']['Deposit'] != null) {
      showAnalysisButton = false;
    } else {
      showAnalysisButton = true;
    }
    fetchInformation();
  }

  fetchInformation() async {
    // setState(() {
    //   widget.model.setLoader(true);
    // });
    responseData = await widget.model
        .fetchPortfolioChart(widget.portfolioMasterID) as Map<String, dynamic>;
    if (responseData['status'] == true) {
      var graphData = responseData['response']['navGraphData']['graphData']
          .entries
          .toList();
      _selectedMarket = graphData[0].key;

      responseData['response']['navGraphData']['markets'].forEach((key, value) {
        markets.add({"value": key, "title": value});
      });

      // setState(() {
      //   widget.model.setLoader(false);
      // });
    } else if (responseData['status'] == false) {
      // setState(() {
      //   widget.model.setLoader(false);
      // });
      if (mounted) {
        setState(() {
          responseDataHavingError = true;
        });
      } else {
        responseDataHavingError = true;
      }
    }
  }

  analyzePortfolio() async {
    Navigator.pushNamed(context, '/benchmark_selector', arguments: {
      'selectedPortfolioMasterIDs': {widget.portfolioMasterID: true}
    });
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (responseData == null && responseDataHavingError == false) {
      return preLoader();
    } else if (responseData == null && responseDataHavingError == true) {
      return Container();
    } else if (responseData != null && responseData.isEmpty) {
      return emptyWidget;
    } else {
      return mainContainer(
          context: context,
          paddingBottom: 0,
          containerColor: Colors.white,
          child: _buildBodyContent());
    }
  }

  Widget _buildBodyContent() {
    if (responseData['response'] is String) {
      return Center(
        child: Container(
          child: Text(
            responseData['response'],
            style: appBodyH3,
          ),
        ),
      );
    }

    return Column(children: [
      Expanded(
          child: ListView(
              controller: controller,
              physics: ClampingScrollPhysics(),
              children: [
            graphNav(),
          ])),
    ]);
  }

  Widget graphNav() {
    if (responseData['response'] is String) {
      return Container();
    }

    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList();

    return Container(
        color: Colors.white,
        // padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              chartType == "chart"
                  ? TextWithDropDown(
                      "PERFORMANCE VS ",
                      responseData['response']['navGraphData']['markets']
                          [_selectedMarket],
                      _selectedMarketOption,
                      markets,
                      (Map<String, String> value) => value['title'],
                      (Map<String, String> value) {
                        marketSelectChange(value);
                      },
                    )
                  // RichText(
                  //     text: TextSpan(
                  //         style: appGraphTitle,
                  //         text: ("PERFORMANCE VS "),
                  //         children: [
                  //         markets.length > 1
                  //             ? TextSpan(
                  //                 text: responseData['response']['navGraphData']
                  //                     ['markets'][_selectedMarket],
                  //                 style:
                  //                     appGraphTitle.copyWith(color: colorBlue),
                  //                 recognizer: TapGestureRecognizer()
                  //                   ..onTap = () => buildSelectBoxCustom(
                  //                       context: context,
                  //                       value: _selectedMarket,
                  //                       title: 'Select benchmark',
                  //                       options: markets,
                  //                       onChangeFunction: marketSelectChange))
                  //             : TextSpan(
                  //                 text: responseData['response']['navGraphData']
                  //                     ['markets'][_selectedMarket],
                  //                 style: appGraphTitle),
                  //         markets.length > 1
                  //             ? WidgetSpan(
                  //                 child: Icon(Icons.keyboard_arrow_down,
                  //                     color: colorBlue, size: 14),
                  //               )
                  //             : WidgetSpan(child: emptyWidget),
                  //       ]))
                  : Text("Value over time".toUpperCase(), style: appGraphTitle),
              LargeControlledSwitch(
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
            ]),
            // SizedBox(height: getScaledValue(25.0)),
            SizedBox(height: getScaledValue(5.0)),
            SelectionCallbackExample(chartData, key: key),
            // SizedBox(height: getScaledValue(25.0)),
            SizedBox(height: getScaledValue(5.0)),
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
      _selectedMarketOption = value; //Added for performace vs [dropdown]
      _selectedMarket =
          value['value']; //Changed from this _selectedMarket = value;
      key.currentState._seriesList = chartDataList();
    });
  }

  List<charts.Series<TimeSeriesSales, DateTime>> chartDataList() {
    final List<TimeSeriesSales> portfolioData = [];
    final List<TimeSeriesSales> benchmarkData = [];

    responseData['response']['navGraphData']['graphData'][_selectedMarket]
            [_performanceTenure]['portfolioData']
        .forEach((key_date, value) {
      if (responseData['response']['navGraphData']['graphData'][_selectedMarket]
              [_performanceTenure]['benchmarkData']
          .containsKey(key_date)) {
        DateTime dateNAV = DateTime.parse(key_date);
        double navValue = responseData['response']['navGraphData']['graphData']
                [_selectedMarket][_performanceTenure]['portfolioData'][key_date]
            .toDouble();
        double hurdleValue = responseData['response']['navGraphData']
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
      id: (responseData['response']['navGraphData']['markets']
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

    responseData['response']['navGraphData']['priceGraph'][_performanceTenure]
        .forEach((key_date, value) {
      DateTime dateNAV = DateTime.parse(key_date);
      double navValue = responseData['response']['navGraphData']['priceGraph']
              [_performanceTenure][key_date]
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
