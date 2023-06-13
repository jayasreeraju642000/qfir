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
import 'package:qfinr/pages/analyse/stress_test_report/common_widgtes_stress_report.dart';
import 'package:qfinr/pages/analyse/stress_test_report/stress_test_report_styles.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/main_model.dart';
import '../../../utils/text_with_drop_down_button.dart';
import '../../../widgets/styles.dart';
import '../../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('StressTestReport');

class StressTestReportLarge extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Map<String, dynamic> responseData;

  Map selectedPortfolioMasterIDs;

  StressTestReportLarge(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _StressTestReportState();
  }
}

class _StressTestReportState extends State<StressTestReportLarge> {
  final controller = ScrollController();

  Map statsData = {};

  Map stressTestData = {};
  Map stressTestSort = {};
  List<Map<String, String>> stressTestPeriods = [];
  String stressTestPeriodSelected;
  String stressTestPeriodSelectedString;
  List<Map<String, String>> stressTestGraphBenchmarks = [];
  Map<String, String> stressTestGraphBenchmarksOptionsSelected;
  String stressTestGraphBenchmarkSelected;
  Map performanceData = {};

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      return PageWrapper(
          child: Scaffold(
        key: _scaffoldKey,
        drawer: WidgetDrawer(),
        appBar: PreferredSize(
          // for larger & medium screen sizes
          preferredSize: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          child: NavigationTobBar(widget.model,
            openDrawer: () => _scaffoldKey.currentState.openDrawer(),
          ),
        ),
        body: _buildBodyNvaigationLeftBar(),
      ));
    });
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
                isSideMenuHeadingSelected: 2, isSideMenuSelected: 4),
        Expanded(child: _buildBodyContentLarge())
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
            _stressHeader(),
            SizedBox(
              height: getScaledValue(16),
            ),
            _listStressTest(),
            SizedBox(
              height: getScaledValue(16),
            ),
            Container(
              width: getScaledValue(120),
              height: getScaledValue(40),
              color: Colors.white,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  textStyle: TextStyle(color: Color(0xff034bd9)),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Color(0xff034bd9),
                          width: 1.25,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Go Back',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(12.0),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'nunito',
                      color: Color(0xff034bd9),
                      letterSpacing: 0.0,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  _stressHeader() {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text("Portfolio Stress Test", style: headline1_analyse),
        ]));
  }

  Widget _listStressTest() {
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
              Text(
                  "Performance of your portfolio during historical periods of high-stress in markets. We define periods to cover the fall and partial recovery.",
                  style: keyStatsBodyText7),
              SizedBox(
                height: 24,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: stressReportLeftSide()),
                    SizedBox(
                      width: getScaledValue(16),
                    ),
                    Expanded(
                      child: stressReportRightSide(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ]));
  }

  Widget stressReportLeftSide() {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Container(
              margin: EdgeInsets.symmetric(
                  horizontal: getScaledValue(16), vertical: getScaledValue(6)),
              child: Text("Select Stress Period",
                  style: StressTestReportScreenStyle.stressBodyText1.copyWith(
                    fontWeight: FontWeight.w700,
                  ))),
          timePeriodSelector(),
          graphNav(),
        ]));
  }

  Widget stressReportRightSide() {
    return Container(
        // padding: EdgeInsets.symmetric(
        //     horizontal: getScaledValue(16), vertical: getScaledValue(16)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                      widget.responseData['response']['stressTestBenchmarks']
                          [stressTestGraphBenchmarkSelected],
                  'value': stressTestData[stressTestPeriodSelected]['stats']
                      [stressTestGraphBenchmarkSelected]['total_return']
                },
              ]),
          SizedBox(height: getScaledValue(17)),
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
                      widget.responseData['response']['stressTestBenchmarks']
                          [stressTestGraphBenchmarkSelected],
                  'value': stressTestData[stressTestPeriodSelected]['stats']
                      [stressTestGraphBenchmarkSelected]['max_drawdown']
                },
              ]),
          SizedBox(height: getScaledValue(17)),
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
                      widget.responseData['response']['stressTestBenchmarks']
                          [stressTestGraphBenchmarkSelected],
                  'value': stressTestData[stressTestPeriodSelected]['stats']
                      [stressTestGraphBenchmarkSelected]['daily_vol']
                },
              ]),
        ]));
  }

  Widget timePeriodSelector() {
    return GestureDetector(
      onTap: () {
        buildSelectBoxCustomLargeStress(
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
            TextWithDropDown(
              "PERFORMANCE VS ",
              widget.responseData['response']['stressTestBenchmarks']
                  [stressTestGraphBenchmarkSelected],
              stressTestGraphBenchmarksOptionsSelected,
              stressTestGraphBenchmarks,
              (Map<String, String> value) => value['title'],
              (Map<String, String> value) {
                marketSelectChange(value);
              },
            ),
            // RichText(
            //     text: TextSpan(
            //         style: StressTestReportScreenStyle.stressBodyText3
            //             .copyWith(color: Color(0xffa5a5a5)),
            //         text: ("PERFORMANCE VS "),
            //         children: [
            //       TextSpan(
            //           text: widget.responseData['response']
            //                   ['stressTestBenchmarks']
            //               [stressTestGraphBenchmarkSelected],
            //           style: StressTestReportScreenStyle.stressBodyText3
            //               .copyWith(color: Color(0xff034bd9)),
            //           recognizer: TapGestureRecognizer()
            //             ..onTap = () => buildSelectBoxCustomLargeStress(
            //                 context: context,
            //                 value: stressTestGraphBenchmarkSelected,
            //                 title: 'Select benchmark',
            //                 options: stressTestGraphBenchmarks,
            //                 onChangeFunction: marketSelectChange)),
            //       WidgetSpan(
            //         child: Icon(Icons.keyboard_arrow_down,
            //             color: colorBlue, size: 14),
            //       ),
            //     ])),
            SizedBox(height: getScaledValue(25.0)),
            SelectionCallbackExample(chartData, key: key),
          ],
        ));
  }

  void marketSelectChange(Map<String, String> value) {
    setState(() {
      stressTestGraphBenchmarksOptionsSelected = value;
      stressTestGraphBenchmarkSelected = value['value'];
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
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(16)), //
        color: Color(0xfff7f7f7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title.toUpperCase(),
                style: StressTestReportScreenStyle.stressBodyText3
                    .copyWith(color: Color(0xffa5a5a5))),
            Text(subtitle, style: StressTestReportScreenStyle.stressBodyText4),
          ],
        ),
      ),
    );

    statsData.forEach((element) {
      _children.add(
        statsRowStressLarge(
            title: element['title'],
            description: element['description'],
            value1: roundDouble(element['value'] * 100, postFix: "%"),
            includeBottomBorder: counter != statsData.length),
      );
      counter++;
    });
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),
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
