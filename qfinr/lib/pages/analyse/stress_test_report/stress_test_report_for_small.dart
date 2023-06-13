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
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/main_model.dart';
import '../../../widgets/styles.dart';
import '../../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('StressTestReport');

class StressTestReportSmall extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Map<String, dynamic> responseData;

  Map selectedPortfolioMasterIDs;

  StressTestReportSmall(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _StressTestReportState();
  }
}

class _StressTestReportState extends State<StressTestReportSmall> {
  final controller = ScrollController();

  Map statsData = {};

  Map stressTestData = {};
  Map stressTestSort = {};
  List<Map<String, String>> stressTestPeriods = [];
  String stressTestPeriodSelected;
  String stressTestPeriodSelectedString;
  List<Map<String, String>> stressTestGraphBenchmarks = [];
  String stressTestGraphBenchmarkSelected;
  Map performanceData = {};
  Map chartsData;
  bool gradientDisplay = true;

  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Stress Test Report',
        screenClassOverride: 'StressTestReport');
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Stress Test Report",
    });
  }

  Future<Null> _analyticsStressParamChanged() async {
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "stress_test",
      'item_name': "stress_test_parameter_change",
      'content_type': "click_dropdown_icon",
    });
  }

  @override
  void initState() {
    super.initState();
    _analyticsCurrentScreen();
    _analyticsAddEvent();

    try {
      stressTestData = widget.responseData['response']['stressTestData'];
      stressTestSort = widget.responseData['response']['stressTestSort'];
    } catch (e) {
      log.e('Datatype mismatch: ' + e.toString());
    }

    var sortedMap = stressTestSort.entries.toList()
      ..sort((e1, e2) {
        var diff = e1.value.compareTo(e2.value);
        if (diff == 0) diff = e1.key.compareTo(e2.key);
        return diff;
      });

    stressTestSort
      ..clear()
      ..addEntries(sortedMap);

    stressTestSort.forEach((sortedKey, sortedValue) {
      if (stressTestPeriodSelected == null) {
        stressTestPeriodSelected = sortedKey;

        stressTestData[sortedKey]['stats'].forEach((key1, value1) {
          if (key1 != 'NAV') {
            if (stressTestGraphBenchmarkSelected == null) {
              stressTestGraphBenchmarkSelected = key1;
            }
            stressTestGraphBenchmarks.add({
              'value': key1,
              'title': widget.responseData['response']['stressTestBenchmarks']
                  [key1]
            });
          }
        });
      }
      stressTestPeriods.add({
        'value': sortedKey,
        'title': stressTestData[sortedKey]['title'] +
            "(" +
            dateString(stressTestData[sortedKey]['start_date'],
                format: 'dd MMM yyyy') +
            '-' +
            dateString(stressTestData[sortedKey]['end_date'],
                format: 'dd MMM yyyy' + ")")
      });
    });
    changeStatusBarColor(Color(0xffefd82b));
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Color(0xffefd82b));
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        //drawer: WidgetDrawer(),
        appBar: commonAppBar(
          /* controller: controller,  */
          bgColor: Color(0xffefd82b),
          brightness: Brightness.light,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                  context, widget.model.redirectBase),
              child: AppbarHomeButton(),
            )
          ],
        ),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    return mainContainer(
        context: context,
        paddingBottom: 0,
        containerColor: Colors.white,
        child: _buildBodyContent());
  }

  Widget _buildBodyContent() {
    return stressTestData.isEmpty
        ? emptyWidget
        : ListView(
            children: [
              Container(
                height: getScaledValue(200), // 110
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      right: 0,
                      // width: getScaledValue(360.0),
                      child: Container(
                        height: getScaledValue(135.0), // 185
                        padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(16),
                          vertical: getScaledValue(10.0),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffefd82b), Color(0xfffdbf27)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Text(
                          "Portfolio Stress Test",
                          style: headline1,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 90, // 170
                        left: getScaledValue(15.0),
                        right: getScaledValue(15.0),
                        // width: getScaledValue(330.0),
                        height: getScaledValue(105.0),
                        child: Container(
                          //alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: getScaledValue(16),
                              vertical: getScaledValue(25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Color(0xffe9e9e9),
                                width: getScaledValue(1)),
                            borderRadius:
                                BorderRadius.circular(getScaledValue(4)),
                          ),
                          child: Text(
                            "Performance of your portfolio during historical periods of high-stress in markets. We define periods to cover the fall and partial recovery.",
                            style: keyStatsBodyText7,
                          ),
                        )),
                  ],
                ),
              ),
              timePeriodSelector(),
              graphNav(),
              _stressKeyStatsBox(
                  title: 'Returns',
                  subtitle: 'Total Returns',
                  statsData: [
                    {
                      'title': 'Portfolio',
                      'value': stressTestData[stressTestPeriodSelected]['stats']
                          ['NAV']['total_return']
                    },
                    {
                      'title': 'Benchmark ' +
                          widget.responseData['response']
                                  ['stressTestBenchmarks']
                              [stressTestGraphBenchmarkSelected],
                      'value': stressTestData[stressTestPeriodSelected]['stats']
                          [stressTestGraphBenchmarkSelected]['total_return']
                    },
                  ]),
              sectionSeparator(),
              _stressKeyStatsBox(
                  title: 'Maximum Loss',
                  subtitle: 'Max Drawdown',
                  statsData: [
                    {
                      'title': 'Portfolio',
                      'value': stressTestData[stressTestPeriodSelected]['stats']
                          ['NAV']['max_drawdown']
                    },
                    {
                      'title': 'Benchmark ' +
                          widget.responseData['response']
                                  ['stressTestBenchmarks']
                              [stressTestGraphBenchmarkSelected],
                      'value': stressTestData[stressTestPeriodSelected]['stats']
                          [stressTestGraphBenchmarkSelected]['max_drawdown']
                    },
                  ]),
              sectionSeparator(),
              _stressKeyStatsBox(
                  title: 'RISKS',
                  subtitle: 'Ann. Volatility',
                  statsData: [
                    {
                      'title': 'Portfolio',
                      'value': stressTestData[stressTestPeriodSelected]['stats']
                          ['NAV']['daily_vol']
                    },
                    {
                      'title': 'Benchmark ' +
                          widget.responseData['response']
                                  ['stressTestBenchmarks']
                              [stressTestGraphBenchmarkSelected],
                      'value': stressTestData[stressTestPeriodSelected]['stats']
                          [stressTestGraphBenchmarkSelected]['daily_vol']
                    },
                  ]),
            ],
          );
  }

  Widget timePeriodSelector() {
    return GestureDetector(
      onTap: () {
        buildSelectBoxCustom(
            context: context,
            value: stressTestPeriodSelected,
            title: 'Select a stress period',
            options: stressTestPeriods,
            onChangeFunction: timePeriodChange);
      },
      child: Container(
          padding: EdgeInsets.all(getScaledValue(12)),
          margin: EdgeInsets.all(getScaledValue(16)),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xffe9e9e9)),
              borderRadius: BorderRadius.circular(getScaledValue(4))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Stress Period", style: keyStatsBodyText5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(stressTestData[stressTestPeriodSelected]['title'],
                          style: keyStatsBodyText3),
                      Text(
                          " (" +
                              dateString(
                                  stressTestData[stressTestPeriodSelected]
                                      ['start_date'],
                                  format: 'dd MMM yyyy') +
                              '-' +
                              dateString(
                                  stressTestData[stressTestPeriodSelected]
                                      ['end_date'],
                                  format: 'dd MMM yyyy') +
                              ")",
                          style: keyStatsBodyText5)
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              )
            ],
          )),
    );
  }

  void timePeriodChange(value) {
    setState(() {
      stressTestPeriodSelected = value;
      key.currentState._seriesList = chartDataList();
      _analyticsStressParamChanged();
    });
  }

  Widget graphNav() {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList();

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
                      text: widget.responseData['response']
                              ['stressTestBenchmarks']
                          [stressTestGraphBenchmarkSelected],
                      style: appGraphTitle.copyWith(color: colorBlue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => buildSelectBoxCustom(
                            context: context,
                            value: stressTestGraphBenchmarkSelected,
                            title: 'Select benchmark',
                            options: stressTestGraphBenchmarks,
                            onChangeFunction: marketSelectChange)),
                  WidgetSpan(
                    child: Icon(Icons.keyboard_arrow_down,
                        color: colorBlue, size: 14),
                  ),
                ])),
            SizedBox(height: getScaledValue(25.0)),
            SelectionCallbackExample(chartData, key: key),
          ],
        ));
  }

  void marketSelectChange(value) {
    setState(() {
      stressTestGraphBenchmarkSelected = value;
      key.currentState._seriesList = chartDataList();
    });
  }

  List<charts.Series<TimeSeriesSales, DateTime>> chartDataList() {
    final List<TimeSeriesSales> portfolioData = [];
    final List<TimeSeriesSales> benchmarkData = [];

    stressTestData[stressTestPeriodSelected]['portfolioNAVRaw']
        .forEach((key, value) {
      if (stressTestData[stressTestPeriodSelected]['benchmarkNAVRaw']
              [stressTestGraphBenchmarkSelected]
          .containsKey(key)) {
        DateTime dateNAV = DateTime.parse(key);
        double navValue = stressTestData[stressTestPeriodSelected]
                ['portfolioNAVRaw'][key]
            .toDouble();
        double hurdleValue = stressTestData[stressTestPeriodSelected]
                ['benchmarkNAVRaw'][stressTestGraphBenchmarkSelected][key]
            .toDouble();
        portfolioData.add(new TimeSeriesSales(dateNAV, navValue));
        benchmarkData.add(new TimeSeriesSales(dateNAV, hurdleValue));
      }
    });
    /* for (var i = 0; i < stressTestData[stressTestPeriodSelected]['portfolioNAV'].length; i++) {
			DateTime dateNAV = DateTime.fromMillisecondsSinceEpoch(stressTestData[stressTestPeriodSelected]['portfolioNAV'][i][0]);
			double navValue = stressTestData[stressTestPeriodSelected]['portfolioNAV'][i][1].toDouble();
			portfolioData.add(new TimeSeriesSales(dateNAV, navValue));

			double hurdleValue = stressTestData[stressTestPeriodSelected]['benchmarkNAV'][stressTestGraphBenchmarkSelected][i][1].toDouble();
			benchmarkData.add(new TimeSeriesSales(dateNAV, hurdleValue));

		} */

    List<charts.Series<TimeSeriesSales, DateTime>> chartDataList = [];

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: 'Portfolio',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    chartDataList.add(new charts.Series<TimeSeriesSales, DateTime>(
      id: (widget.responseData['response']['stressTestBenchmarks']
          [stressTestGraphBenchmarkSelected]),
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: benchmarkData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffc0c0c0))),
    ));

    return chartDataList;
  }

  Widget _stressKeyStatsBox({
    String title,
    String subtitle,
    List statsData,
  }) {
    List<Widget> _children = [];
    int counter = 1;
    _children.add(
      Container(
        padding: EdgeInsets.symmetric(horizontal: getScaledValue(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title.toUpperCase(), style: keyStatsBodyHeading),
            Text(subtitle, style: keyStatsBodyText2),
          ],
        ),
      ),
    );

    statsData.forEach((element) {
      _children.add(
        statsRow(
            title: element['title'],
            description: element['description'],
            value1: roundDouble(element['value'] * 100, postFix: "%"),
            includeBottomBorder: counter != statsData.length),
      );
      counter++;
    });
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(10), vertical: getScaledValue(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }
}

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
    );
  }

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
                  symbolRenderer: CustomCircleSymbolRenderer2()),
              charts.SeriesLegend(
                showMeasures: false,
                position: charts.BehaviorPosition.bottom,
                outsideJustification:
                    charts.OutsideJustification.middleDrawArea,
                horizontalFirst: true,
                desiredMaxRows: 2,
                cellPadding:
                    new EdgeInsets.only(right: 16.0, bottom: 4.0, top: 20.0),
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

    return new Column(
      children: children,
    );
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

    if (bounds.left + bounds.width + 120 > 300) {
      positionBox = 120;
      positionText = -110;
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
