import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/pages/analyse/details/common_widgets_analyse_details.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyse_detail_styles.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_instrument_tab.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_portfolio_tab.dart';
import 'package:qfinr/pages/analyse/simulated_portfolios_instrument_widget/simulated_portfolios_instrument_widget.dart';
import 'package:qfinr/pages/analyse/stress_test_report/common_widgtes_stress_report.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'package:syncfusion_flutter_charts/charts.dart' as boxwhiskerChart;
import '../../../models/main_model.dart';
import '../../../utils/text_with_drop_down_button.dart';
import '../../../widgets/styles.dart';
import '../../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('PortfolioAnalyzerDetail');

//
class PortfolioAnalyzerDetailMedium extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Map<String, dynamic> responseData;

  int tabIndex;

  Map selectedPortfolioMasterIDs;
  String benchmark;

  PortfolioAnalyzerDetailMedium(this.model,
      {this.analytics,
      this.observer,
      this.responseData,
      this.selectedPortfolioMasterIDs,
      this.benchmark,
      this.tabIndex});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerDetailState();
  }
}

class _PortfolioAnalyzerDetailState extends State<PortfolioAnalyzerDetailMedium>
    with SingleTickerProviderStateMixin {
  final controller = ScrollController();
  TabController _tabController;
  int performanceCurrentTabIndex = 0;
  int tabIndex = 0;
  Map statsData;
  Map nIFTY50 = {};
  Map stressTestData;
  List<Map<String, String>> stressTestPeriods = [];
  String stressTestPeriodSelected;
  String stressTestPeriodSelectedString;
  List<Map<String, String>> stressTestGraphBenchmarks = [];
  Map<String, String> stressTestGraphBenchmarksOptionSelected;
  String stressTestGraphBenchmarkSelected;
  Map performanceData = {};
  String _selectedYear = '1';
  List<Map<String, String>> listYears = [
    {'value': '1', 'title': '1 Year'},
    {'value': '3', 'title': '3 Years'},
    {'value': '5', 'title': '5 Years'},
    {'value': '8', 'title': '8 Years'},
    {'value': '10', 'title': '10 Years'},
  ];

  Map<String, Color> colorList = {
    'max_sharpe': Colors.purple,
    'min_volatility': Colors.orange,
    'max_return': Colors.pink,
  };

  dynamic _formResponseData;
  Map chartsData;
  Map chartsDataSort;
  Map simulatedPortfoliosData = {};
  Map assetAllocations = {};
  Map minVol = {};
  Map maxReturn = {};
  Map maxSharpe = {};
  Map sortList;
  bool gradientDisplay = true;
  bool _isPortfolioCorelationAvailable = false;
  bool _isInstrumentCorelationAvailable = false;

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Analyzer Detail',
        screenClassOverride: 'PortfolioAnalyzerDetail');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Analyzer Detail",
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

  Future<Null> _analyticsPerformanceComparisonETFClickEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "analysis_result_details",
      'item_name': "analysis_result_details_performance_comparison_etf",
      'content_type': "click_comparison_etf_tab",
    });
  }

  @override
  void initState() {
    if (widget.responseData['response']['summary'] == null) {
      _isPortfolioCorelationAvailable = false;
      _isInstrumentCorelationAvailable = false;
      _tabController =
          TabController(length: 5, vsync: this, initialIndex: tabIndex);
    } else if (widget.responseData['response']['summary'] is List) {
      _isPortfolioCorelationAvailable = false;
      _isInstrumentCorelationAvailable = false;
      _tabController =
          TabController(length: 5, vsync: this, initialIndex: tabIndex);
    } else {
      int tabCount = 5;
      Map summary = widget.responseData['response']['summary'] as Map;
      summary.forEach((key, value) {
        if (key == "portfolioCorelation") {
          _isPortfolioCorelationAvailable = true;
          tabCount++;
        }
        if (key == "instrumentCorelation") {
          _isInstrumentCorelationAvailable = true;
          tabCount++;
        }
      });
      _tabController =
          TabController(length: tabCount, vsync: this, initialIndex: tabIndex);
    }

    super.initState();
    _currentScreen();
    _addEvent();

    statsData = widget.responseData['response']['data'];
    /*
 Boxwhisker chart data commented
*/
    // if (widget.responseData['response']['whisker_chart'].isNotEmpty) {
    //   nIFTY50 = widget.responseData['response']['whisker_chart'];
    // }

    // if (widget.responseData['response']['navGraphData'].isNotEmpty) {
    //   Map graphData =
    //       widget.responseData['response']['navGraphData']['graphData'];
    //   nIFTY50 = graphData[widget.benchmark];
    // }

    _formResponseData = widget.responseData['response']['riskProfiler'];
    if (widget.responseData['response']['graphData'].isNotEmpty) {
      chartsData = widget.responseData['response']['graphData'];
    }

    if (widget.responseData['response']['graphDataSort'] != null) {
      chartsDataSort = widget.responseData['response']['graphDataSort'];
    }

    if (widget.responseData['response']['simulatedPortfolios'].isNotEmpty) {
      simulatedPortfoliosData =
          widget.responseData['response']['simulatedPortfolios'];

      if (simulatedPortfoliosData.isNotEmpty) {
        if (simulatedPortfoliosData['assetAllocations'] != null &&
            simulatedPortfoliosData['assetAllocations'] != "") {
          assetAllocations = simulatedPortfoliosData['assetAllocations'];
        }

        if (simulatedPortfoliosData['portfolios'] != null &&
            simulatedPortfoliosData['portfolios'] != "") {
          if (simulatedPortfoliosData['portfolios']['Min Vol'] != null &&
              simulatedPortfoliosData['portfolios']['Min Vol'] != "") {
            minVol = simulatedPortfoliosData['portfolios']['Min Vol'];
          }

          if (simulatedPortfoliosData['portfolios']['Max Return'] != null &&
              simulatedPortfoliosData['portfolios']['Max Return'] != "") {
            maxReturn = simulatedPortfoliosData['portfolios']['Max Return'];
          }

          if (simulatedPortfoliosData['portfolios']['Max Sharpe'] != null &&
              simulatedPortfoliosData['portfolios']['Max Sharpe'] != "") {
            maxSharpe = simulatedPortfoliosData['portfolios']['Max Sharpe'];
          }
        }
      }
    }
    // log.d('debug 110');
    // log.d(widget.responseData['response']['scatterPlotData']['dataPoints']);

    if (widget
        .responseData['response']['scatterPlotData']['dataPoints'].isNotEmpty) {
      widget.responseData['response']['scatterPlotData']['dataPoints']
          .forEach((key, value) {
        if (key != "ref_portfolio_3" &&
            key != "ref_portfolio_5" &&
            key != "max_sharpe") {
          performanceData[key] = {
            'caption': key == widget.benchmark.toLowerCase()
                ? statsData['benchmark_name']
                : (key == "etf"
                    ? widget.responseData['response']['etf_name']
                    : value['name']),
            'plotValue': value['range'],
            'display': (key == "etf" || key == widget.benchmark.toLowerCase())
                ? false
                : true,
            'color': key == "your_portfolios"
                ? Color(0xff63a0ff)
                : colorList.containsKey(key)
                    ? colorList[key]
                    : Color(0xfffdbf27),
            'radius': 7,
          };

          // log.d(key);
          // log.d(performanceData[key]);
          // log.d(value);
        }
      });

      performanceData['gradientSpot'] = [
        {
          'plotValue': widget.responseData['response']['scatterPlotData']
              ['circleArea']['center'],
          'color': Color(0xff6cb94f),
          'radius': widget.responseData['response']['scatterPlotData']
              ['circleArea']['radius'],
          'display': gradientDisplay,
        },
        {
          'plotValue': widget.responseData['response']['scatterPlotData']
              ['circleArea']['center'],
          'color': Color(0x996cb94f),
          'radius': 22,
          'display': gradientDisplay,
        },
        {
          'plotValue': widget.responseData['response']['scatterPlotData']
              ['circleArea']['center'],
          'color': Color(0x666cb94f),
          'radius': 32,
          'display': gradientDisplay,
        },
        {
          'plotValue': widget.responseData['response']['scatterPlotData']
              ['circleArea']['center'],
          'color': Color(0x336cb94f),
          'radius': 42,
          'display': gradientDisplay,
        },
      ];
    }
  }

  PreferredSizeWidget tabbar() {
    List<Widget> tabChildren = [];
    tabChildren.add(Tab(text: "Summary"));
    tabChildren.add(Tab(text: "Key Statistics"));
    if (_isPortfolioCorelationAvailable) {
      tabChildren.add(Tab(text: "Portfolio Statistics"));
    }
    if (_isInstrumentCorelationAvailable) {
      tabChildren.add(Tab(text: "Instrument Statistics"));
    }
    tabChildren.add(Tab(text: "Performance Comparison"));
    tabChildren.add(Tab(text: "Risk Tracker"));
    tabChildren.add(Tab(text: "Simulated Portfolios"));
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
            _analyticsSummaryClickEvent();
            break;
          case 1:
            _analyticsKeyStaticsClickEvent();
            break;
          case 2:
            _analyticsPerformanceComparisonClickEvent();
            break;
          case 3:
            _analyticsSuitabilityClickEvent();
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
      return _buildBody();
    });
  }

  Widget _buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xfff5f6fa),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                vertical: getScaledValue(18), horizontal: getScaledValue(30)),
            color: Colors.white,
            child: _buildBodyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    Widget child;
    if (_isPortfolioCorelationAvailable && _isInstrumentCorelationAvailable) {
      if (tabIndex == 0) {
        child = chartContainer();
      } else if (tabIndex == 1) {
        child = keyStats();
      } else if (tabIndex == 2) {
        child = PortfolioAnalyzerPortfolioTab(
            widget.responseData['response']['summary']);
      } else if (tabIndex == 3) {
        child = PortfolioAnalyzerInstrumentTab(
            widget.responseData['response']['summary']);
      } else if (tabIndex == 4) {
        child = performance();
      } else if (tabIndex == 5) {
        child = suitability();
      } else if (tabIndex == 6) {
        child = simulatedPortfolios();
      } else {
        child = emptyWidget;
      }
    } else if (_isPortfolioCorelationAvailable) {
      if (tabIndex == 0) {
        child = chartContainer();
      } else if (tabIndex == 1) {
        child = keyStats();
      } else if (tabIndex == 2) {
        child = PortfolioAnalyzerPortfolioTab(
            widget.responseData['response']['summary']);
      } else if (tabIndex == 3) {
        child = performance();
      } else if (tabIndex == 4) {
        child = suitability();
      } else if (tabIndex == 5) {
        child = simulatedPortfolios();
      } else {
        child = emptyWidget;
      }
    } else if (_isInstrumentCorelationAvailable) {
      if (tabIndex == 0) {
        child = chartContainer();
      } else if (tabIndex == 1) {
        child = keyStats();
      } else if (tabIndex == 2) {
        child = PortfolioAnalyzerInstrumentTab(
            widget.responseData['response']['summary']);
      } else if (tabIndex == 3) {
        child = performance();
      } else if (tabIndex == 4) {
        child = suitability();
      } else if (tabIndex == 5) {
        child = simulatedPortfolios();
      } else {
        child = emptyWidget;
      }
    } else {
      if (tabIndex == 0) {
        child = chartContainer();
      } else if (tabIndex == 1) {
        child = keyStats();
      } else if (tabIndex == 2) {
        child = performance();
      } else if (tabIndex == 3) {
        child = suitability();
      } else if (tabIndex == 4) {
        child = simulatedPortfolios();
      } else {
        child = emptyWidget;
      }
    }
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      child: Column(
        children: [child],
      ),
    );
  }

  Widget keyStats() {
    return Container(
      height: getScaledValue(280),
      width: MediaQuery.of(context).size.width * 1.0,
      child: ListView(
        shrinkWrap: true,
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          _keyStatsBox1(
              title: 'Basic assessment',
              returns: double.parse(statsData['cagr'].toString()),
              risks: double.parse(statsData['stddev'].toString()),
              rpr: double.parse(statsData['sharpe'].toString())),
          SizedBox(width: getScaledValue(30)),
          _keyStatsBox2(
              title: 'Intermediate assessment',
              returns: double.parse(statsData['Bench_alpha'].toString()),
              risks: double.parse(statsData['Bench_beta'].toString()),
              rpr: double.parse(statsData['drawdown'].toString())),
          SizedBox(width: getScaledValue(30)),
          _keyStatsBox3(
              title: 'Advanced assessment',
              returns: double.parse(statsData['Bench_r2'].toString()),
              risks: double.parse(statsData['successratio'].toString()),
              rpr: double.parse(statsData['inforatio'].toString())),
        ],
      ),
    );
  }

  Widget _keyStatsBox1(
      {String title, double returns, double risks, double rpr}) {
    return Container(
      //color: Colors.white,

      width: getScaledValue(350),

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                vertical: getScaledValue(20), horizontal: getScaledValue(18)),
            color: Color(0xfff5f6fa),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(title.toUpperCase(),
                    style: AnalyseDetailScreenStyle.keyStaticBodyText1),
                GestureDetector(
                    onTap: () => bottomAlertBoxLargeAnalyse(
                          context: context,
                          title: "Returns",
                          description:
                              "The annualized 3 year returns using data as of the end of the preceding month",
                          title2: "Risks",
                          description2:
                              "The annualized volatility of monthly returns over 3 years as of the end of the preceding month",
                          title3: "Returns per unit Risk",
                          description3:
                              "The ‘Sharpe Ratio’ calculated using the monthly returns in excess of the risk free rate over 3 years as of the end of the preceding month. We calculate the risk free rate from short term government bills",
                        ),
                    child: Text('What is this?',
                        style: AnalyseDetailScreenStyle.keyStaticBodyText2)),
              ],
            ),
          ),
          statsRowLarge(
              title: 'Returns',
              description: '3 yrs CAGR',
              value1: roundDouble(returns) + "%",
              includeBottomBorder: true),
          statsRowLarge(
              title: 'Risks',
              description: 'Annualised Volatility',
              value1: roundDouble(risks) + "%",
              includeBottomBorder: true),
          statsRowLarge(
              title: 'Returns per unit Risk',
              description: 'Sharpe Ratio',
              value1: roundDouble(rpr),
              includeBottomBorder: false),
        ],
      ),
    );
  }

  Widget _keyStatsBox2(
      {String title, double returns, double risks, double rpr}) {
    return Container(
      width: getScaledValue(350),

      //color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                vertical: getScaledValue(20), horizontal: getScaledValue(18)),
            color: Color(0xfff5f6fa),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(title.toUpperCase(),
                    style: AnalyseDetailScreenStyle.keyStaticBodyText1),
                GestureDetector(
                    onTap: () => bottomAlertBoxLargeAnalyse(
                          context: context,
                          title: "Excess Returns",
                          description:
                              "Jensen’s alpha computed from the regression of the monthly fund excess returns over risk free returns and the excess returns of the fund’s benchmark. We calculate the risk free rate from short term government bills. Alpha is a guageof the excess return over the benchmark",
                          title2: "Sensitivity",
                          description2:
                              "The beta computed from the regression of the monthly excess returns of the fund over risk free returns and the excess returns of the fund’s benchmark. We calculate the risk free rate from short term government bills.  It measures the volatility of the fund compared to the systematic risk of the chosen benchmark",
                          title3: "Maximum Loss",
                          description3:
                              "The maximum observed loss from a peak to a trough, before a new peak is attained over the past 3 years using daily prices. Maximum drawdown is an indicator of downside risk over the time period",
                        ),
                    child: Text('What is this?', style: textLink2)),
              ],
            ),
          ),
          statsRowLarge(
              title: 'Excess Returns',
              description: 'Alpha',
              value1: roundDouble(returns) + "%",
              includeBottomBorder: true),
          statsRowLarge(
              title: 'Sensitivity',
              description: 'Beta',
              value1: roundDouble(risks),
              includeBottomBorder: true),
          statsRowLarge(
              title: 'Maximum Loss',
              description: 'Max Drawdown',
              value1: roundDouble(rpr) + "%",
              includeBottomBorder: false),
        ],
      ),
    );
  }

  Widget _keyStatsBox3(
      {String title, double returns, double risks, double rpr}) {
    return Container(
      width: getScaledValue(350),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                vertical: getScaledValue(20), horizontal: getScaledValue(18)),
            color: Color(0xfff5f6fa),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(title.toUpperCase(),
                    style: AnalyseDetailScreenStyle.keyStaticBodyText1),
                GestureDetector(
                    onTap: () => bottomAlertBoxLargeAnalyse(
                          context: context,
                          title: "Similarity",
                          description:
                              "The ‘R-squared’. It is generally seen as the percentage of a fund’s returns that can be explained by movements in the benchmark. We use excess returns and a 3 year period",
                          title2: "Success Rate",
                          description2:
                              "The percentage of times the fund has outperformed the benchmark if held for a year. We calculate rolling 1 year returns of the two and calculate the success rate. We use 3 years daily prices. The rate is an indication of how successful holding the fund for 1 year is against the benchmark",
                          title3: "Consistency of Success",
                          description3:
                              "The ‘Information Ratio’, measures the fund’s returns in excess of it’s chosen benchmark compared to the volatility of those returns. It is used as a measure of a fund manager's skill and ability to generate excess returns relative to a benchmark and the consistency of the performance",
                        ),
                    child: Text('What is this?', style: textLink2)),
              ],
            ),
          ),
          statsRowLarge(
              title: 'Similarity',
              description: 'R-Square',
              value1: roundDouble(returns),
              includeBottomBorder: true),
          statsRowLarge(
              title: 'Success rate',
              description: 'Win % vs Market',
              value1: roundDouble(risks) + "%",
              includeBottomBorder: true),
          statsRowLarge(
              title: 'Consistency of Success',
              description: 'Information Ratio',
              value1: roundDouble(rpr),
              includeBottomBorder: false),
        ],
      ),
    );
  }

  Widget performance() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: getScaledValue(10)),
        child: ListView(
          shrinkWrap: true,
          controller: controller,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: getScaledValue(16), horizontal: getScaledValue(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: getScaledValue(15)),
                  customTabs(
                    tabs: [
                      "AGAINST " + widget.benchmark.toUpperCase() + " INDEX",
                      "AGAINST " + widget.responseData['response']['etf_name']
                    ],
                    activeIndex: performanceCurrentTabIndex,
                    onTap: (index) {
                      if (index == 1) {
                        _analyticsPerformanceComparisonETFClickEvent();
                      }
                      setState(() {
                        performanceCurrentTabIndex = index;

                        if (index == 0) {
                          performanceData['etf']['display'] = false;
                          performanceData[widget.benchmark.toLowerCase()]
                              ['display'] = true;
                        } else if (index == 1) {
                          performanceData['etf']['display'] = true;
                          performanceData[widget.benchmark.toLowerCase()]
                              ['display'] = false;
                        }
                      });
                    },
                  ),
                  SizedBox(height: getScaledValue(19)),
                  _performanceTabBarViewContent(performanceCurrentTabIndex)
                ],
              ),
            ),
            // sectionSeparator(),
            _performanceReturnsComparison(),
            // sectionSeparator(),
            SizedBox(
              height: 30,
            ),

            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  performanceData.isNotEmpty
                      ? _performanceRiskRewardReturns()
                      : emptyWidget,
                  performanceData.isNotEmpty
                      ? SizedBox(
                          height: 27,
                        )
                      : emptyWidget,
                  Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Color(0xffe9e9e9), width: getScaledValue(1)),
                        borderRadius: BorderRadius.circular(getScaledValue(4)),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(30),
                          vertical: getScaledValue(30)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _performanceRemarks(
                                title: "Similarity",
                                subtitle: "(R - Square)",
                                value: roundDouble(
                                    performanceCurrentTabIndex == 0
                                        ? statsData['Bench_r2']
                                        : statsData['ETF_r2']),
                                description:
                                    "The ‘R-squared’. It is generally seen as the percentage of a fund’s returns that can be explained by movements in the Index/ETF. We use a 3 year period. A high similarity implies that the low cost ETF would be a credible alternative to the fund"),
                            SizedBox(height: getScaledValue(34)),
                            _performanceRemarks(
                                title: "Consistency",
                                subtitle: "(Information Ratio)",
                                value: roundDouble(
                                    performanceCurrentTabIndex == 0
                                        ? statsData['inforatio']
                                        : statsData['Einforatio']),
                                description:
                                    "The ‘Information Ratio’, measures the fund’s returns in excess of the index/ETF. compared to the volatility of those returns. It is used as a measure of a fund manager's skill and ability to generate excess returns relative to a benchmark and the consistency of the performance"),
                            SizedBox(height: getScaledValue(34)),
                            _performanceRemarks(
                                title: "Closeness",
                                subtitle: "(Tracking Error)",
                                value: roundDouble(
                                        performanceCurrentTabIndex == 0
                                            ? statsData['trackerr']
                                            : statsData['Etrackerr']) +
                                    "%",
                                description:
                                    "It is the difference in actual performance between the fund and the ETF and can be viewed as an indicator of how actively a fund is managed"),
                          ])),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )

            // sectionSeparator(),
          ],
        ));
  }

  Widget _performanceTabBarViewContent(int currentTabIndex) {
    Widget content = null;

    if (currentTabIndex == 0) {
      content = Text(
          "Comparison of rolling returns and risk vs reward between the selected portfolios/funds and the benchmark",
          style: keyStatsBodyText5);
    } else {
      content = Text(
          "Comparison of rolling returns and risks reward between the selected portfolios/funds and the most active and largest ETF: the " +
              widget.responseData['response']['etf_name'],
          style: keyStatsBodyText5);
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: getScaledValue(8)),
        child: content);
  }

  Widget _performanceReturnsComparison() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),
      // padding: EdgeInsets.symmetric(
      //     horizontal: getScaledValue(16), vertical: getScaledValue(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 1.0,
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(30), vertical: getScaledValue(20)),
            color: Color(0xfff3f3f3),
            child: Text("Returns Comparison",
                style: AnalyseDetailScreenStyle.perfomanceBodyText0),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(30), vertical: getScaledValue(30)),
            child: Column(
              children: [
                SizedBox(height: getScaledValue(5)),
                Text(
                    "A comparison of rolling returns between the portfolio or a fund, vs the chosen benchmark. This analysis allows us to eliminate any recency bias that we may have while assessing any portfolio/fund against a benchmark",
                    style: AnalyseDetailScreenStyle.perfomanceBodyText1),
                SizedBox(height: getScaledValue(22)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: Color(0xffe9e9e9), width: getScaledValue(1)),
                    borderRadius: BorderRadius.circular(getScaledValue(4)),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: getScaledValue(16),
                      vertical: getScaledValue(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          svgImage("assets/icon/icon_star.svg",
                              height: 22, width: 24),
                          SizedBox(width: getScaledValue(7)),
                          Text(
                              ("Success Rate: " +
                                      roundDouble(
                                          performanceCurrentTabIndex == 0
                                              ? statsData['successratio']
                                              : statsData['Esuccessratio']) +
                                      "%")
                                  .toUpperCase(),
                              style: AnalyseDetailScreenStyle
                                  .perfomanceBodyText0
                                  .copyWith(
                                color: Color(0xff30c50c),
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                      SizedBox(height: getScaledValue(7)),
                      Text(
                          "The percentage of times the fund has outperformed the chosen Index/ETF if held for a year. We calculate rolling 1 year returns of the two and calculate the success rate. We use 3 years daily prices. The rate is an indication of how successful holding the fund for 1 year is against the Index/ETF",
                          style: AnalyseDetailScreenStyle.perfomanceBodyText1
                              .copyWith(color: Color(0xff8e8e8e))),
                    ],
                  ),
                ),
                SizedBox(height: getScaledValue(24)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: Color(0xffe9e9e9), width: getScaledValue(1)),
                    borderRadius: BorderRadius.circular(getScaledValue(4)),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: getScaledValue(30),
                      vertical: getScaledValue(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Returns Profile".toUpperCase(),
                          style: AnalyseDetailScreenStyle.perfomanceBodyText3),
                      SizedBox(height: getScaledValue(5)),
                      Text(
                          "This shows the distribution of returns for a fund held for a period of 1 year within different ranges. This breakdown indicates the range with most common returns for a fund when held for a year. A similar breakdown for the Index/ETF is also shown which allows comparison of the two distributions. We use 3 years daily prices for this analysis",
                          style: AnalyseDetailScreenStyle.perfomanceBodyText2),
                      SizedBox(height: getScaledValue(15)),
                      /*
 Boxwhisker chart data commented
*/
                      // nIFTY50.isNotEmpty
                      //     ? Container(
                      //         height: getScaledValue(300),
                      //         child: boxwhiskerChart.SfCartesianChart(
                      //           legend: boxwhiskerChart.Legend(
                      //               isVisible: true,
                      //               position:
                      //                   boxwhiskerChart.LegendPosition.bottom,
                      //               overflowMode: boxwhiskerChart
                      //                   .LegendItemOverflowMode.wrap,
                      //               toggleSeriesVisibility: true),
                      //           primaryYAxis: boxwhiskerChart.NumericAxis(
                      //             plotBands: <boxwhiskerChart.PlotBand>[
                      //               boxwhiskerChart.PlotBand(
                      //                 textAngle: 0,
                      //                 start: 0,
                      //                 end: 0,
                      //                 borderColor: AppColors.boxWhiskerLine,
                      //                 borderWidth: 1,
                      //               )
                      //             ],
                      //             title: boxwhiskerChart.AxisTitle(
                      //               text:
                      //                   '% : Annualized Rolling Return Period',
                      //               textStyle: TextStyle(
                      //                 color: Colors.black,
                      //                 fontSize: 12,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),

                      //             //Aligns the y-axis labels
                      //             labelAlignment:
                      //                 boxwhiskerChart.LabelAlignment.center,
                      //             labelFormat: '{value}%',
                      //           ),
                      //           primaryXAxis: boxwhiskerChart.CategoryAxis(
                      //             title: boxwhiskerChart.AxisTitle(
                      //               text: 'Time Period for Rolling Returns',
                      //               textStyle: TextStyle(
                      //                 color: Colors.black,
                      //                 fontSize: 12,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),
                      //           ),
                      //           series: <
                      //               boxwhiskerChart.BoxAndWhiskerSeries<
                      //                   BoxWhiskerChartData, String>>[
                      //             boxwhiskerChart.BoxAndWhiskerSeries<
                      //                 BoxWhiskerChartData, String>(
                      //               color: AppColors.boxWhiskerPortfolio,
                      //               legendItemText: 'Portfolio',
                      //               dataSource:
                      //                   getSalesTypeList('portfolio', nIFTY50),
                      //               boxPlotMode:
                      //                   boxwhiskerChart.BoxPlotMode.inclusive,
                      //               xValueMapper:
                      //                   (BoxWhiskerChartData sales, _) {
                      //                 return sales.type;
                      //               },
                      //               yValueMapper:
                      //                   (BoxWhiskerChartData sales, _) {
                      //                 List<double> list = [];
                      //                 sales.list.forEach((element) {
                      //                   list.add(double.parse(element.returns) *
                      //                       100);
                      //                 });
                      //                 return list;
                      //               },
                      //               showMean: false,
                      //               width: 0.7,
                      //               spacing: 0.2,
                      //               markerSettings:
                      //                   boxwhiskerChart.MarkerSettings(
                      //                 shape:
                      //                     boxwhiskerChart.DataMarkerType.none,
                      //               ),
                      //             ),
                      //             boxwhiskerChart.BoxAndWhiskerSeries<
                      //                 BoxWhiskerChartData, String>(
                      //               color: AppColors.boxWhiskerBenchMark,
                      //               legendItemText: widget.benchmark,
                      //               dataSource: getSalesTypeList(
                      //                   'benchmark', nIFTY50), // portfolioData
                      //               //  getSalesTypeList("Top EU Monthly Growth Momentum"),
                      //               boxPlotMode:
                      //                   boxwhiskerChart.BoxPlotMode.inclusive,
                      //               xValueMapper:
                      //                   (BoxWhiskerChartData sales, _) {
                      //                 return sales.type;
                      //               },
                      //               yValueMapper:
                      //                   (BoxWhiskerChartData sales, _) {
                      //                 List<double> list = [];
                      //                 sales.list.forEach((element) {
                      //                   list.add(double.parse(element.returns) *
                      //                       100);
                      //                 });
                      //                 return list;
                      //               },
                      //               showMean: false,
                      //               width: 0.7,
                      //               spacing: 0.2,
                      //               markerSettings:
                      //                   boxwhiskerChart.MarkerSettings(
                      //                 shape:
                      //                     boxwhiskerChart.DataMarkerType.none,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       )
                      //     : emptyWidget,

                      Container(
                          height: getScaledValue(190),
                          child: HorizontalBarChart(
                              performanceCurrentTabIndex == 0
                                  ? _horizontalBarGraphDataBenchmark()
                                  : _horizontalBarGraphDataETF())),
                      SizedBox(height: getScaledValue(21)),
                      Container(
                          child: Text("Rolling 1 year portfolio returns",
                              style: AnalyseDetailScreenStyle
                                  .perfomanceBodyText6)),
                      SizedBox(height: getScaledValue(10)),
                      Text(
                          "We calculate 1 year rolling returns using 3 years of daily prices and show the minimum, maximum and average returns. It is an indicator of the range of return outcomes when holding the investment for a year",
                          style: AnalyseDetailScreenStyle.perfomanceBodyText6),
                      SizedBox(height: getScaledValue(10)),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: getScaledValue(6)),
                          decoration: BoxDecoration(
                            color: Color(0xfff6f6f6),
                            borderRadius:
                                BorderRadius.circular(getScaledValue(4)),
                          ),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: _returnComparisionValues("Minimum",
                                    roundDouble(statsData['rollretmin']) + "%",
                                    includeLeftBorder: false)),
                            Expanded(
                                child: _returnComparisionValues(
                              "Maximum",
                              roundDouble(statsData['rollretmax']) + "%",
                            )),
                            Expanded(
                                child: _returnComparisionValues(
                              "Average",
                              roundDouble(statsData['rollretmean']) + "%",
                            )),
                          ]))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  List<charts.Series<BarData, String>> _horizontalBarGraphDataBenchmark() {
    final portfolio = [
      BarData(
          'Above 15%', roundDouble(statsData['Over15'], returnType: 'double')),
      BarData('10-15%', roundDouble(statsData['15'], returnType: 'double')),
      BarData('5-10%', roundDouble(statsData['10'], returnType: 'double')),
      BarData('0-5%', roundDouble(statsData['05'], returnType: 'double')),
      BarData('Less Than 0%',
          roundDouble(statsData['0andUnder'], returnType: 'double')),
    ];

    final benchmark = [
      BarData(
          'Above 15%', roundDouble(statsData['BOver15'], returnType: 'double')),
      BarData('10-15%', roundDouble(statsData['B15'], returnType: 'double')),
      BarData('5-10%', roundDouble(statsData['B10'], returnType: 'double')),
      BarData('0-5%', roundDouble(statsData['B05'], returnType: 'double')),
      BarData('Less Than 0%',
          roundDouble(statsData['B0andUnder'], returnType: 'double')),
    ];

    return [
      new charts.Series<BarData, String>(
          id: 'Portfolio',
          domainFn: (BarData barData, _) => barData.percentage,
          measureFn: (BarData barData, _) => barData.value,
          data: portfolio,
          colorFn: (_, __) =>
              charts.ColorUtil.fromDartColor(Color((0xffe2edff))),
          labelAccessorFn: (BarData barData, _) =>
              roundDouble(barData.value, decimalLength: 0) + "%"),
      new charts.Series<BarData, String>(
          id: widget.benchmark.toUpperCase(),
          domainFn: (BarData barData, _) => barData.percentage,
          measureFn: (BarData barData, _) => barData.value,
          data: benchmark,
          colorFn: (_, __) =>
              charts.ColorUtil.fromDartColor(Color((0xfffde9bf))),
          labelAccessorFn: (BarData barData, _) =>
              roundDouble(barData.value, decimalLength: 0) + "%")
    ];
  }

  List<charts.Series<BarData, String>> _horizontalBarGraphDataETF() {
    final portfolio = [
      BarData(
          'Above 15%', roundDouble(statsData['Over15'], returnType: 'double')),
      BarData('10-15%', roundDouble(statsData['15'], returnType: 'double')),
      BarData('5-10%', roundDouble(statsData['10'], returnType: 'double')),
      BarData('0-5%', roundDouble(statsData['05'], returnType: 'double')),
      BarData('Less Than 0%',
          roundDouble(statsData['0andUnder'], returnType: 'double')),
    ];

    final benchmark = [
      BarData(
          'Above 15%', roundDouble(statsData['EOver15'], returnType: 'double')),
      BarData('10-15%', roundDouble(statsData['E15'], returnType: 'double')),
      BarData('5-10%', roundDouble(statsData['E10'], returnType: 'double')),
      BarData('0-5%', roundDouble(statsData['E05'], returnType: 'double')),
      BarData('Less Than 0%',
          roundDouble(statsData['E0andUnder'], returnType: 'double')),
    ];

    return [
      new charts.Series<BarData, String>(
          id: 'Portfolio',
          domainFn: (BarData barData, _) => barData.percentage,
          measureFn: (BarData barData, _) => barData.value,
          data: portfolio,
          colorFn: (_, __) =>
              charts.ColorUtil.fromDartColor(Color((0xffe2edff))),
          labelAccessorFn: (BarData barData, _) =>
              roundDouble(barData.value, decimalLength: 0) + "%"),
      new charts.Series<BarData, String>(
          id: widget.responseData['response']['etf_name'], //'NIFTY50 ETF',
          domainFn: (BarData barData, _) => barData.percentage,
          measureFn: (BarData barData, _) => barData.value,
          data: benchmark,
          colorFn: (_, __) =>
              charts.ColorUtil.fromDartColor(Color((0xfffde9bf))),
          labelAccessorFn: (BarData barData, _) =>
              roundDouble(barData.value, decimalLength: 0) + "%")
    ];
  }

  Widget _returnComparisionValues(String type, String value,
      {bool includeLeftBorder = true}) {
    return Container(
      decoration: BoxDecoration(
          border: includeLeftBorder
              ? Border(
                  left: BorderSide(
                    color: Color(0xffe9e9e9),
                    width: 1.0,
                  ),
                )
              : null),
      padding: EdgeInsets.symmetric(vertical: getScaledValue(8)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(type, style: keyStatsBodyText6),
            Text(value, style: keyStatsBodyText7)
          ]),
    );
  }

  Widget _performanceRiskRewardReturns() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xfff3f3f3),
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(30), vertical: getScaledValue(30)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Return v/s Risk Comparison", style: appBodyH3),
                GestureDetector(
                    onTap: () => bottomAlertBoxLargeAnalyse(
                          context: context,
                          title: "Return v/s Risk Comparison",
                          description:
                              "This chart shows the comparison of returns against the risks taken to achieve those returns for the portfolio/fund as well as the selected benchmark. This also shows the desired range for you, the investor, based on risk preference as indicated by you in your risk profile. \n\nPortfolios leaning leftwards compared to their benchmarks have taken lower risks in the past. Similarly, portfolios plotted higher have delivered better returns compared to others.\n\nBest portfolios are the ones that have both these characteristics, and therefore lean towards the top-left on this chart",
                        ),
                    child: Text('What is this?', style: textLink1)),
              ],
            ),
          ),
          SizedBox(height: getScaledValue(5)),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(30), vertical: getScaledValue(30)),
            child: Text(
                "Comparison of past returns vs the risks taken for the portfolios and the chosen benchmark",
                style: keyStatsBodyText5),
          ),
          SizedBox(height: getScaledValue(13)),
          Container(
              padding: EdgeInsets.symmetric(
                  horizontal: getScaledValue(16), vertical: getScaledValue(16)),
              child: Column(
                children: [
                  Container(
                    height: getScaledValue(200),
                    width: MediaQuery.of(context).size.width * 1.0,
                    child: _scatterChart(),
                  ),
                  SizedBox(height: getScaledValue(25)),
                  _scatterChartButtons(),
                ],
              )),
        ],
      ),
    );
  }

  Widget _performanceRemarks(
      {String title, String subtitle, String value, String description}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(title,
                      textAlign: TextAlign.left, style: keyStatsBodyText1),
                  SizedBox(width: getScaledValue(4)),
                  Text(subtitle, style: keyStatsBodyText2),
                ],
              ),
              Text(value, style: keyStatsBodyText1),
            ],
          ),
          SizedBox(height: getScaledValue(5)),
          Text(description, textAlign: TextAlign.left, style: keyStatsBodyText5)
        ],
      ),
    );
  }

  Widget investmentStyle() {
    return Container(
        padding: EdgeInsets.symmetric(
            vertical: getScaledValue(16), horizontal: getScaledValue(16)),
        child: Column(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "This portfolio exhibits a significant orientation towards staying inline and close to the overall market, with a tilt towards investing in large cap companies",
                    style: keyStatsBodyText5),
                SizedBox(height: getScaledValue(26)),
                statsRow2(title: "Tracks overall market", value1: "1.4/5"),
                statsRow2(
                    title: "Focuses on Large-cap firms ", value1: "2.3/5"),
              ],
            )),
          ],
        ));
  }

  Widget suitabilityReports() {
    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                  // height: getScaledValue(400),
                  width: MediaQuery.of(context).size.width * 1.0 / 2,
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: getScaledValue(330),
                          child: infoReport(),
                        ),
                        // Expanded(
                        //     child: Align(
                        //   alignment: Alignment.bottomCenter,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: getScaledValue(16),
                          ),
                          child: suitabilityDescription(),
                        ),
                        //  ))
                      ])),
            ),
            performanceData.isNotEmpty
                ? Expanded(
                    child: Container(
                        //height: getScaledValue(400),
                        // height: MediaQuery.of(context).size.height * 0.90,
                        width: MediaQuery.of(context).size.width * 1.0 / 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Color(0xffe9e9e9),
                              width: getScaledValue(1)),
                          borderRadius:
                              BorderRadius.circular(getScaledValue(4)),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(getScaledValue(16)),
                                  height: getScaledValue(330),
                                  width:
                                      MediaQuery.of(context).size.width * 1.0,
                                  child: Center(
                                    child: graph(),
                                  )),
                              Container(
                                color: statsData['additional_statement'] != null
                                    ? Color(0xfff3f3f3)
                                    : Color(0xffffffff),
                                padding: EdgeInsets.all(getScaledValue(16)),
                                child: statsData['additional_statement'] != null
                                    ? Text(statsData['additional_statement'],
                                        style: AnalyseDetailScreenStyle
                                            .suitabiltyBodyText2
                                            .copyWith(color: Color(0xff8e8e8e)))
                                    : emptyWidget,
                              )
                            ])))
                : emptyWidget
          ],
        ));
  }

  Widget suitability() {
    return ListView(
      shrinkWrap: true,
      controller: controller,
      physics: NeverScrollableScrollPhysics(),
      children: [
        suitabilityReports(),
      ],
    );
  }

  Widget infoReport() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(6), vertical: getScaledValue(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: "Your risk profile is ",
                  style: AnalyseDetailScreenStyle.suitabiltyBodyText0,
                  children: <TextSpan>[
                TextSpan(
                    //'(${dataMap[key]['data']['day']['change'].toString()})
                    text: '\n${_formResponseData['response']}',
                    style: AnalyseDetailScreenStyle.suitabiltyBodyText1),
                TextSpan(
                    text:
                        "\n\nBased on this risk profile generally investors having 5 year investment period have risk (volatility) in the range of " +
                            roundDouble(
                              _formResponseData['stdevData'][2][1],
                              decimalLength: 1,
                            ) +
                            "-" +
                            roundDouble(
                              _formResponseData['stdevData'][4][1],
                              decimalLength: 1,
                            ) +
                            "% with expected annual return in the range " +
                            roundDouble(
                              _formResponseData['yieldData'][2][1],
                              decimalLength: 1,
                            ) +
                            "-" +
                            roundDouble(
                              _formResponseData['yieldData'][4][1],
                              decimalLength: 1,
                            ) +
                            "%.",
                    style: AnalyseDetailScreenStyle.suitabiltyBodyText2)
              ])),
          SizedBox(height: getScaledValue(10)),
          Text(
              "\n\nYour portfolio has risk (volatility) of " +
                  roundDouble(
                    statsData['stddev'],
                    decimalLength: 1,
                  ) +
                  "% and annual expected returns of " +
                  roundDouble(
                    statsData['emean'],
                    decimalLength: 1,
                  ) +
                  "%.",
              style: AnalyseDetailScreenStyle.suitabiltyBodyText2),
        ],
      ),
    );
  }

  String riskProfileDescription(String riskProfileType) {
    switch (riskProfileType) {
      case "Conservative":
        return "You want to take minimum risks while investing. You always prioritize safety, even if it means you earn much less on your investments. Your only exposure to risk while investing is likely to be through products that invest for the very long term";
        break;
      case "Moderate Conservative":
        return "You are a very cautious risk-taker. You take measured risks while investing after high due diligence. High fluctuations in the value of your investments are likely to be stressful for you";
        break;
      case "Moderate":
        return "You maintain a balance between the risks and rewards in your investment decisions. You prefer investment opportunities that can deliver above-average returns and are prepared to take little extra risks to achieve that";
        break;
      case "Moderately Aggressive":
        return "You are open to taking risks while investing and high fluctuations in the value of your investments do not bother you. You, however, refrain from taking extremely high risks such as through leverage, or complex payoff structures";
        break;
      case "Aggressive":
        return "You seek the highest returns possible whenever you invest, even if they involve taking substantial risks. Extreme volatility does not bother you. You also welcome investment opportunities that involve leverage or have complex payoffs";
        break;
      default:
        return " ";
    }
  }

  Widget expectedPerformance() {
    return Container(
      padding: EdgeInsets.all(getScaledValue(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(style: bodyText4, text: ("For a "), children: [
            TextSpan(
                text: _selectedYear + " year",
                style: bodyText4.copyWith(
                    fontWeight: FontWeight.bold, color: colorBlue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => buildSelectBoxCustomLargeStress(
                      context: context,
                      value: _selectedYear,
                      title: 'Select Year',
                      options: listYears,
                      onChangeFunction: (value) => setState(() {
                            _selectedYear = value;
                          }))),
            WidgetSpan(
                child:
                    Icon(Icons.keyboard_arrow_down, color: colorBlue, size: 14),
                alignment: PlaceholderAlignment.middle),
            TextSpan(
              text:
                  " investment horizon, your investments in this portfolio should not be more than ",
            ),
            TextSpan(
              text: roundDouble(_formResponseData['yieldData']
                      [int.parse(_selectedYear) - 1][1]) +
                  "% ",
              style: bodyText4.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            TextSpan(
              text: "of your overall investment value across all types.",
            ),
          ])),
        ],
      ),
    );
  }

  Widget expectedPerformanceStats(
      String title, String subtitle, String value, String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getScaledValue(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: bodyText6),
              Text(value, style: bodyText6),
            ],
          ),
          subtitle != null ? Text(subtitle, style: bodyText7) : emptyWidget,
          SizedBox(height: getScaledValue(10)),
          Text(description, style: bodyText4)
        ],
      ),
    );
  }

  Widget graph() {
    List<int> selectedSpots = [];
    int lastPanStartOnIndex = -1;

    List<ScatterSpot> _scatterSpot = [];

    performanceData.forEach((key, value) {
      if (key == "gradientSpot") {
        value.forEach((element) {
          _scatterSpot.add(ScatterSpot(
            double.parse(element['plotValue'][0].toString()),
            double.parse(element['plotValue'][1].toString()),
            radius: double.parse(element['radius'].toString()),
            color: element['color'],
            show: true,
          ));
        });
      } else if (key == "your_portfolios") {
        _scatterSpot.add(ScatterSpot(
          double.parse(value['plotValue'][0].toString()),
          double.parse(value['plotValue'][1].toString()),
          radius: double.parse(value['radius'].toString()),
          color: value['color'],
          show: true,
        ));
      }
    });

    return Container(
        margin: EdgeInsets.symmetric(
            horizontal: getScaledValue(20), vertical: getScaledValue(20)),
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: _scatterSpot,
            axisTitleData: FlAxisTitleData(
              show: true,
              leftTitle: AxisTitle(
                  showTitle: true,
                  titleText: "Annualised Returns (in%)",
                  textStyle: AnalyseDetailScreenStyle.suitabiltyBodyText3),
              bottomTitle: AxisTitle(
                  showTitle: true,
                  titleText: "Annualised Vols (in%)",
                  textStyle: AnalyseDetailScreenStyle.suitabiltyBodyText3),
            ),
            minX: double.parse(widget.responseData['response']
                    ['scatterPlotData']['min_max']['x']['min']
                .toString()),
            maxX: double.parse(widget.responseData['response']
                    ['scatterPlotData']['min_max']['x']['max']
                .toString()),
            minY: double.parse(widget.responseData['response']
                    ['scatterPlotData']['min_max']['y']['min']
                .toString()),
            maxY: double.parse(widget.responseData['response']
                    ['scatterPlotData']['min_max']['y']['max']
                .toString()),
            borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Color(0xffa7a7a7)),
                  bottom: BorderSide(color: Color(0xffa7a7a7)),
                )),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              checkToShowHorizontalLine: (value) => false,
              //horizontalInterval: double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][0].toString()) / 2,
              /* getDrawingHorizontalLine: (value) {
							if(value == double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][0].toString())){ //
								return FlLine(color: Color(0xffd5d5d5), dashArray: [5,5]);
							}else{
								return FlLine(strokeWidth: 0, color: Colors.white);
							}
						}, */
              drawVerticalLine: true,
              checkToShowVerticalLine: (value) => false,
              //verticalInterval: double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][1].toString()) / 2,
              /* getDrawingVerticalLine: (value) {
							if(value == double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][1].toString())){ //
								return FlLine(color: Color(0xffd5d5d5), dashArray: [5,5]);
							}else{
								return FlLine(strokeWidth: 0, color: Colors.white);
							}
						}, */
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: SideTitles(
                  showTitles: true,
                  interval: (widget.responseData['response']['scatterPlotData']
                              ['min_max']['y']['max'] -
                          widget.responseData['response']['scatterPlotData']
                              ['min_max']['y']['min']) /
                      5),
              bottomTitles: SideTitles(
                  showTitles: true,
                  interval: (widget.responseData['response']['scatterPlotData']
                              ['min_max']['x']['max'] -
                          widget.responseData['response']['scatterPlotData']
                              ['min_max']['x']['min']) /
                      5),
              topTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
            ),
            showingTooltipIndicators: selectedSpots,
            scatterTouchData: ScatterTouchData(
              enabled: true,
              handleBuiltInTouches: false,
              touchTooltipData: ScatterTouchTooltipData(
                tooltipBgColor: Colors.black,
              ),
              touchCallback: (
                FlTouchEvent event,
                ScatterTouchResponse touchResponse,
              ) {
                if (event is FlPanStartEvent) {
                  lastPanStartOnIndex = touchResponse.touchedSpot.spotIndex;
                } else if (event is FlPanEndEvent) {
                  if (event.details.velocity.pixelsPerSecond <=
                      const Offset(4, 4)) {
                    // Tap happened
                    setState(() {
                      if (selectedSpots.contains(lastPanStartOnIndex)) {
                        selectedSpots.remove(lastPanStartOnIndex);
                      } else {
                        selectedSpots.add(lastPanStartOnIndex);
                      }
                    });
                  }
                }
              },
            ),
          ),
        ));
  }

  List<charts.Series<yieldData, int>> fixYieldData() {
    final List<yieldData> yieldDb = [];

    for (int i = 0; i < _formResponseData['yieldData'].length; i++) {
      yieldDb.add(yieldData(_formResponseData['yieldData'][i][0],
          _formResponseData['yieldData'][i][1]));
    }

    return [
      new charts.Series<yieldData, int>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (yieldData sales, _) => sales.goalTerm,
        measureFn: (yieldData sales, _) => sales.percentage,
        data: yieldDb,
      )
    ];
  }

  List<charts.Series<yieldData, int>> fixSTDEVData() {
    final List<yieldData> yieldDb = [];
    for (int i = 0; i < _formResponseData['stdevData'].length; i++) {
      yieldDb.add(yieldData(_formResponseData['stdevData'][i][0],
          _formResponseData['stdevData'][i][1]));
    }

    return [
      new charts.Series<yieldData, int>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (yieldData sales, _) => sales.goalTerm,
        measureFn: (yieldData sales, _) => sales.percentage,
        data: yieldDb,
      )
    ];
  }

  Widget suitabilityDescription() {
    return Container(
        color: Color(0xfffff7d7),
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(15)),
        child: RichText(
            text: TextSpan(
                text: "Note: ",
                style: AnalyseDetailScreenStyle.suitabiltyBodyText2
                    .copyWith(color: Color(0xff8e8e8e)),
                children: <TextSpan>[
              TextSpan(
                  text:
                      "If you are running this analysis for a part of your overall portfolio, do remember that the risk/return characteristics of the combination of two portfolios is not a mathematical average. We recommend that you re-run the analysis with your entire portfolio.",
                  style: AnalyseDetailScreenStyle.suitabiltyBodyText2
                      .copyWith(color: Color(0xff8e8e8e)))
            ])));
  }

  Widget _scatterChart() {
    List<int> selectedSpots = [];
    int lastPanStartOnIndex = -1;

    List<ScatterSpot> _scatterSpot = [];

    performanceData.forEach((key, value) {
      if (key == "gradientSpot") {
        value.forEach((element) {
          _scatterSpot.add(ScatterSpot(
            double.parse(element['plotValue'][0].toString()),
            double.parse(element['plotValue'][1].toString()),
            radius: gradientDisplay
                ? double.parse(element['radius'].toString())
                : 0,
            color: element['color'],
            show: gradientDisplay,
          ));
        });
      } else {
        _scatterSpot.add(ScatterSpot(
          double.parse(value['plotValue'][0].toString()),
          double.parse(value['plotValue'][1].toString()),
          radius: performanceData[key]['display']
              ? double.parse(value['radius'].toString())
              : 0,
          color: value['color'],
          show: performanceData[key]['display'],
        ));
      }
    });

    return ScatterChart(
      ScatterChartData(
        scatterSpots: _scatterSpot,
        axisTitleData: FlAxisTitleData(
          show: true,
          leftTitle: AxisTitle(
              showTitle: true,
              titleText: "Annualised Returns (in%)",
              textStyle: TextStyle(color: Colors.black)),
          bottomTitle: AxisTitle(
              showTitle: true,
              titleText: "Annualised Vols (in%)",
              textStyle: TextStyle(color: Colors.black)),
        ),
        minX: double.parse(widget.responseData['response']['scatterPlotData']
                ['min_max']['x']['min']
            .toString()),
        maxX: double.parse(widget.responseData['response']['scatterPlotData']
                ['min_max']['x']['max']
            .toString()),
        minY: double.parse(widget.responseData['response']['scatterPlotData']
                ['min_max']['y']['min']
            .toString()),
        maxY: double.parse(widget.responseData['response']['scatterPlotData']
                ['min_max']['y']['max']
            .toString()),
        borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Color(0xffa7a7a7)),
              bottom: BorderSide(color: Color(0xffa7a7a7)),
            )),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          checkToShowHorizontalLine: (value) => false,
          //horizontalInterval: double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][0].toString()) / 2,
          /* getDrawingHorizontalLine: (value) {
						if(value == double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][0].toString())){ //
							return FlLine(color: Color(0xffd5d5d5), dashArray: [5,5]);
						}else{
							return FlLine(strokeWidth: 0, color: Colors.white);
						}
					}, */
          drawVerticalLine: true,
          checkToShowVerticalLine: (value) => false,
          //verticalInterval: double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][1].toString()) / 2,
          /* getDrawingVerticalLine: (value) {
						if(value == double.parse(widget.responseData['response']['scatterPlotData']['midPoint'][1].toString())){ //
							return FlLine(color: Color(0xffd5d5d5), dashArray: [5,5]);
						}else{
							return FlLine(strokeWidth: 0, color: Colors.white);
						}
					}, */
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: SideTitles(
              showTitles: true,
              interval: (widget.responseData['response']['scatterPlotData']
                          ['min_max']['y']['max'] -
                      widget.responseData['response']['scatterPlotData']
                          ['min_max']['y']['min']) /
                  5),
          bottomTitles: SideTitles(
              showTitles: true,
              interval: (widget.responseData['response']['scatterPlotData']
                          ['min_max']['x']['max'] -
                      widget.responseData['response']['scatterPlotData']
                          ['min_max']['x']['min']) /
                  5),
          topTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
        ),
        showingTooltipIndicators: selectedSpots,
        scatterTouchData: ScatterTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchTooltipData: ScatterTouchTooltipData(
            tooltipBgColor: Colors.black,
          ),
          touchCallback: (
            FlTouchEvent event,
            ScatterTouchResponse touchResponse,
          ) {
            if (event is FlPanStartEvent) {
              lastPanStartOnIndex = touchResponse.touchedSpot.spotIndex;
            } else if (event is FlPanEndEvent) {
              if (event.details.velocity.pixelsPerSecond <=
                  const Offset(4, 4)) {
                // Tap happened
                setState(() {
                  if (selectedSpots.contains(lastPanStartOnIndex)) {
                    selectedSpots.remove(lastPanStartOnIndex);
                  } else {
                    selectedSpots.add(lastPanStartOnIndex);
                  }
                });
              }
            }
          },
        ),
      ),
    );
  }

  Widget _scatterChartButtons() {
    List<Widget> _children = [];

    performanceData.forEach((key, value) {
      if (key == "gradientSpot") {
        //_children.add(_scatterChartGradientButtonContainer('Desired Range', 'gradient'));
      } else {
        if ((key == "etf" && performanceCurrentTabIndex == 1) ||
            (key == widget.benchmark.toLowerCase() &&
                performanceCurrentTabIndex == 0) ||
            key != widget.benchmark.toLowerCase() && key != "etf") {
          _children.add(_scatterChartButtonContainer(value['caption'], key));
        }

        if (key == widget.benchmark.toLowerCase()) {
          _children.add(_scatterChartGradientButtonContainer(
              'Desired Range', 'gradient'));
        }
      }
    });

    return Container(
        height: getScaledValue(40),
        child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: _children));
  }

  Widget _scatterChartButtonContainer(String caption, String key) {
    return GestureDetector(
        onTap: () => {
              setState(() {
                performanceData[key]['display'] =
                    !performanceData[key]['display'];
              })
            },
        child: performanceData[key]['display']
            ? widgetBubble(
                title: caption,
                icon: Icon(
                  Icons.fiber_manual_record,
                  color: performanceData[key]['color'],
                  size: getScaledValue(10),
                ),
                fontSize: getScaledValue(10),
                horizontalPadding: 16,
                verticalPadding: 7,
                textColor: Color(0xff3878dc),
                bgColor: Color(0xffecf1fa),
                borderColor: colorActive)
            : widgetBubble(
                title: caption,
                icon: Icon(
                  Icons.fiber_manual_record,
                  color: performanceData[key]['color'],
                  size: getScaledValue(10),
                ),
                fontSize: getScaledValue(10),
                horizontalPadding: 16,
                verticalPadding: 7,
                textColor: Color(0xff818181),
                bgColor: Colors.white,
                borderColor: Color(0xffbcbcbc)));
  }

  Widget _scatterChartGradientButtonContainer(String caption, String key) {
    return GestureDetector(
        onTap: () => {
              setState(() {
                gradientDisplay = !gradientDisplay;
              })
            },
        child: gradientDisplay
            ? widgetBubble(
                title: caption,
                icon: Icon(
                  Icons.fiber_manual_record,
                  color: Color(0xff6cb94f),
                  size: getScaledValue(10),
                ),
                fontSize: getScaledValue(10),
                horizontalPadding: 16,
                verticalPadding: 7,
                textColor: Color(0xff3878dc),
                bgColor: Color(0xffecf1fa),
                borderColor: colorActive)
            : widgetBubble(
                title: caption,
                icon: Icon(
                  Icons.fiber_manual_record,
                  color: Color(0xff6cb94f),
                  size: getScaledValue(10),
                ),
                fontSize: getScaledValue(10),
                horizontalPadding: 16,
                verticalPadding: 7,
                textColor: Color(0xff818181),
                bgColor: Colors.white,
                borderColor: Color(0xffbcbcbc)));
  }

  Widget chartContainer() {
    List<Widget> children = [];
    List<Widget> rowChildren = [];

    children.add(SizedBox(height: getScaledValue(20)));

    if (chartsData != null) {
      if (chartsData.containsKey('total_net_assets')) {
        children.add(_chartContainer(
            title: "Total Net Assets",
            height: 200,
            child: SimpleBarChart(_barChartData('total_net_assets'))));
      }
      if (chartsData.containsKey('top_10_holdings')) {
        children.add(_chartContainer(
            title: "Top 10 Holdings",
            description:
                "The top 10 holdings in your portfolio or fund. For your portfolio, we aggregate holdings across all the individual stocks, bonds, ETFs and funds you hold in the portfolio. The information usually lags by a month",
            child: HorizontalBarChart2(
                _horizontalBarChartData('top_10_holdings'))));
      }

      //if(chartsData.containsKey('stockAllocation')){
      //children.add(_chartContainer(title: "Stock Allocation", child: HorizontalBarChart2(_horizontalBarChartData('stockAllocation'))));
      //}

      if (chartsData.containsKey('sectorAllocation')) {
        children.add(_chartContainer(
            title: "Sector Breakdown",
            description:
                "We breakdown the holdings of your portfolio or fund based on the industry sector code. The fund level data is dependent on disclosure by the fund house. For individual bonds, we allocate sectors based on the issuers sector. The information usually lags by a month",
            child: HorizontalBarChart2(
                _horizontalBarChartData('sectorAllocation'))));
      }

      if (chartsData.containsKey('assetAllocation')) {
        rowChildren.add(
          Expanded(
            flex: 1,
            child: _chartContainer(
              title: "Asset Type Breakdown",
              description:
                  "We breakdown assets as equity, fixed income and cash across the funds/ETFs (subject to their disclosure). For your portfolio, we breakdown across all your holdings down to the lowest level we can based on available information. The information usually lags by a month",
              child: PieOutsideLabelChart(
                _pieChartData('assetAllocation'),
              ),
            ),
          ),
        );
      }

      if (chartsData.containsKey('country_allocation')) {
        rowChildren.add(
          Expanded(
            flex: 1,
            child: _chartContainer(
              title: "Country Exposure",
              description:
                  "We breakdown holdings based on the country of domicile for the underlying companies. We aggregate the exposures based on the countries. Fund / ETF information is subject to disclosure. The information usually lags by a month\n",
              child: PieOutsideLabelChart(
                _pieChartData('country_allocation'),
              ),
            ),
          ),
        );
      }

      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren ?? emptyWidget,
        ),
      );

      if (chartsData.containsKey('currency_allocation')) {
        children.add(
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _chartContainer(
                  title: "Currency Exposure",
                  description:
                      "We breakdown the holdings by the underlying currency exposure and aggregate these back by the currency. Fund / ETF holdings information is subject to disclosure. The information usually lags by a month\n",
                  child: PieOutsideLabelChart(
                      _pieChartData('currency_allocation')),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
        );
        children.add(
          SizedBox(height: getScaledValue(20)),
        );
      }
    } else {
      children.add(Container(
        child: Center(child: Text('No Data Available', style: headline7)),
      ));
    }

    return Scrollbar(
        isAlwaysShown: true,
        controller: controller,
        child: ListView(
          controller: controller,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: children,
        ));

    // return ListView(
    //   shrinkWrap: true,
    //   physics: AlwaysScrollableScrollPhysics(),
    //   children: children,
    // );
    //
  }

  Widget _chartContainer({
    Widget child,
    String title,
    String description,
    double height,
  }) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        margin: EdgeInsets.symmetric(
            vertical: getScaledValue(10), horizontal: getScaledValue(10)),
        padding: EdgeInsets.symmetric(
            vertical: getScaledValue(30), horizontal: getScaledValue(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: getScaledValue(10), vertical: getScaledValue(10)),
              child:
                  Text(title, style: AnalyseDetailScreenStyle.summaryBodyText1),
            ),

            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: getScaledValue(10), vertical: getScaledValue(10)),
              child: description != null
                  ? Text(description,
                      style: AnalyseDetailScreenStyle.summaryBodyText2)
                  : emptyWidget,
            ),
            Container(
              height: getScaledValue(height != null ? height : 200),
              margin: EdgeInsets.symmetric(
                  horizontal: getScaledValue(10), vertical: getScaledValue(10)),
              child: child,
            ),
            //includeDivider ? sectionSeparator() : emptyWidget
          ],
        ));
  }

  List<charts.Series<PiechartData, String>> _pieChartData(String type) {
    final List<PiechartData> data = [];
    int colorLoop = 0;
    chartsData[type].forEach((key, value) {
      charts.Color color = getPieChartColor(colorLoop);
      data.add(
          PiechartData(key, roundDouble(value, returnType: 'double'), color));
      colorLoop++;
    });

    return [
      charts.Series<PiechartData, String>(
        id: 'PieChartData',
        domainFn: (PiechartData data, _) => data.type,
        measureFn: (PiechartData data, _) => data.value,
        colorFn: (PiechartData data, _) => data.color,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (PiechartData row, _) =>
            (type == "assetAllocation"
                ? roundDouble(row.value * 100)
                : roundDouble(row.value)) +
            "%", // row.type + " : " +
      )
    ];
  }

  charts.Color getPieChartColor(key) {
    List colorList = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.yellow.shadeDefault,
    ];

    colorList.addAll(charts.MaterialPalette.green.makeShades(5));
    colorList.addAll(charts.MaterialPalette.red.makeShades(5));
    colorList.addAll(charts.MaterialPalette.yellow.makeShades(5));
    colorList.addAll(charts.MaterialPalette.blue.makeShades(5));
    colorList.addAll(charts.MaterialPalette.purple.makeShades(5));
    colorList.addAll(charts.MaterialPalette.teal.makeShades(5));

    return colorList.elementAt(key);
  }

  List<charts.Series<BarData, String>> _horizontalBarChartData(String type) {
    final List<BarData> data = [];

    if (type == "sectorAllocation" || type == "top_10_holdings") {
      sortList = chartsDataSort[type];

      var sortedMap = sortList.entries.toList()
        ..sort((e1, e2) {
          var diff = e1.value.compareTo(e2.value);
          if (diff == 0) diff = e1.key.compareTo(e2.key);
          return diff;
        });

      sortList
        ..clear()
        ..addEntries(sortedMap);

      sortList.forEach((sortedKey, sortedValue) {
        data.add(BarData(limitChar(sortedKey, length: 20),
            roundDouble(chartsData[type][sortedKey], returnType: 'double')));

        // chartsData[type].forEach((value) {
        //   data.add(BarData(limitChar(sortedKey, length: 20),
        //       roundDouble(chartsData[type][sortedKey], returnType: 'double')));
        // });
      });
    } else if (type == "stockAllocation") {
      sortList = chartsDataSort[type];

      var sortedMap = sortList.entries.toList()
        ..sort((e1, e2) {
          var diff = e1.value.compareTo(e2.value);
          if (diff == 0) diff = e1.key.compareTo(e2.key);
          return diff;
        });

      sortList
        ..clear()
        ..addEntries(sortedMap);

      sortList.forEach((sortedKey, sortedValue) {
        data.add(BarData(
            limitChar(chartsData[type][sortedKey]['holding_name'], length: 20),
            roundDouble(chartsData[type][sortedKey]['percentage'],
                returnType: 'double')));
      });

      // chartsData[type].forEach((key, value) {
      //   data.add(BarData(limitChar(value['holding_name'], length: 20),
      //       roundDouble(value['percentage'], returnType: 'double')));
      // });

    }

    return [
      new charts.Series<BarData, String>(
        id: 'Portfolio',
        domainFn: (BarData barData, _) => barData.percentage,
        measureFn: (BarData barData, _) => barData.value,
        data: data,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffe2edff))),
        labelAccessorFn: (BarData barData, _) =>
            roundDouble(barData.value, decimalLength: 0) + "%",
      ),
    ];
  }

  List<charts.Series<BarchartData, String>> _barChartData(String type) {
    final List<BarchartData> data = [];

    if (type == "total_net_assets") {
      chartsData[type].forEach((value) {
        data.add(BarchartData(
            value['date'], double.parse(value['total_net_assets'])));
      });
    }

    return [
      new charts.Series<BarchartData, String>(
        id: 'Portfolio',
        domainFn: (BarchartData barData, _) => barData.year,
        measureFn: (BarchartData barData, _) => barData.value,
        data: data,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffe2edff))),
        //labelAccessorFn: (BarchartData barData, _) => roundDouble(barData.value, decimalLength: 0)
      ),
    ];
  }

  Widget stressTest() {
    return ListView(
      shrinkWrap: true,
      controller: controller,
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: getScaledValue(20), horizontal: getScaledValue(18)),
          child: Text(
              "Select a time period to see how your portfolio or fund would have performed during the periods of stress in history. You can also select different benchmarks you wish to compare with",
              style: bodyText4),
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
                    widget.responseData['response']['stressTestBenchmarks']
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
                    widget.responseData['response']['stressTestBenchmarks']
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
                    ['NAV']['sharpe_ratio']
              },
              {
                'title': 'Benchmark ' +
                    widget.responseData['response']['stressTestBenchmarks']
                        [stressTestGraphBenchmarkSelected],
                'value': stressTestData[stressTestPeriodSelected]['stats']
                    [stressTestGraphBenchmarkSelected]['sharpe_ratio']
              },
            ]),
      ],
    );
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
              stressTestGraphBenchmarksOptionSelected,
              stressTestGraphBenchmarks,
              (Map<String, String> value) => value['title'],
              (Map<String, String> value) {
                marketSelectChange(value);
              },
            ),
            // RichText(
            //     text: TextSpan(
            //         style: appGraphTitle,
            //         text: ("PERFORMANCE VS "),
            //         children: [
            //       TextSpan(
            //           text: widget.responseData['response']
            //                   ['stressTestBenchmarks']
            //               [stressTestGraphBenchmarkSelected],
            //           style: appGraphTitle.copyWith(color: colorBlue),
            //           recognizer: TapGestureRecognizer()
            //             ..onTap = () => buildSelectBoxCustom(
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
      stressTestGraphBenchmarksOptionSelected = value;
      stressTestGraphBenchmarkSelected = value['value'];
      key.currentState._seriesList = chartDataList();
    });
  }

  List<charts.Series<TimeSeriesSales, DateTime>> chartDataList() {
    final List<TimeSeriesSales> portfolioData = [];
    final List<TimeSeriesSales> benchmarkData = [];

    for (var i = 0;
        i < stressTestData[stressTestPeriodSelected]['portfolioNAV'].length;
        i++) {
      DateTime dateNAV = DateTime.fromMillisecondsSinceEpoch(
          stressTestData[stressTestPeriodSelected]['portfolioNAV'][i][0]);
      double navValue = stressTestData[stressTestPeriodSelected]['portfolioNAV']
              [i][1]
          .toDouble();
      portfolioData.add(new TimeSeriesSales(dateNAV, navValue));

      double hurdleValue = stressTestData[stressTestPeriodSelected]
              ['benchmarkNAV'][stressTestGraphBenchmarkSelected][i][1]
          .toDouble();
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

// simulated Portfolios --------------- Widgets

  Widget simulatedPortfolios() {
    List<Widget> children = [];

    if (simulatedPortfoliosData.isNotEmpty) {
      children.add(Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          performanceData.isNotEmpty
              ? Expanded(
                  child: _performanceRiskRewardReturns(),
                )
              : emptyWidget,
          performanceData.isNotEmpty
              ? SizedBox(
                  width: 27,
                )
              : emptyWidget,
          Expanded(
              child: assetAllocations.isNotEmpty ? desiredRange() : emptyWidget)
        ],
      )));

      children.add(SizedBox(height: 16));
      children.add(SimulatedPortfoliosInstrumentsWidget(
          mainHeading1: "Min vol",
          mainHeading2: "Max Return",
          mainHeading3: "Max Sharpe",
          minVol: minVol,
          maxReturn: maxReturn,
          maxSharpe: maxSharpe));
    } else {
      children.add(Container(
        child: Center(child: Text('No Data Available', style: headline7)),
      ));
    }

    return Scrollbar(
        isAlwaysShown: true,
        controller: controller,
        child: ListView(
          controller: controller,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: children,
        ));
  }

  Widget desiredRange() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0 / 2,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(getScaledValue(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xfff3f3f3),
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(16), vertical: getScaledValue(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Desired Range".toUpperCase(),
                    style: AnalyseDetailScreenStyle.keyStaticBodyText1),
                SizedBox(
                  width: 4,
                ),
                InkWell(
                  onTap: () => bottomAlertBoxLargeAnalyse(
                      context: context,
                      title: Contants.DesiredRange,
                      description: Contants.assertAllocation),
                  child: svgImage('assets/icon/information.svg',
                      width: getScaledValue(14)),
                )
              ],
            ),
          ),
          SizedBox(height: getScaledValue(5)),
          Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Assets",
                          style: AnalyseDetailScreenStyle.suitabiltyBodyText2),
                      Text("Allocation Range",
                          style: AnalyseDetailScreenStyle.suitabiltyBodyText2),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  divider(dividerHeight: 1, dividerColor: Color(0xff707070))
                ],
              )),
          _desiredRangeAssets()
        ],
      ),
    );
  }

  Widget _assetRangeContainer({String assets, String range}) {
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(assets, style: AnalyseDetailScreenStyle.keyStaticBodyText3),
            Text(range, style: AnalyseDetailScreenStyle.keyStaticBodyText3),
          ],
        ),
      )
    ]);
  }

  Widget _desiredRangeAssets() {
    List<Widget> children = [];

    assetAllocations.forEach((key, value) {
      if (value.toString().isNotEmpty) {
        children.add(_assetRangeContainer(
          assets: key.toString(),
          range: value.toString(),
        ));
      }
    });

    return Scrollbar(
        isAlwaysShown: true,
        controller: controller,
        child: ListView(
          controller: controller,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          children: children,
        ));
  }
// simulated Portfolios --------------- Widgets End

}

class HorizontalBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    // For horizontal bar charts, set the [vertical] flag to false.
    return new charts.BarChart(seriesList,
        animate: animate,
        vertical: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
            showAxisLine: false, renderSpec: new charts.NoneRenderSpec()),
        barRendererDecorator: new charts.BarLabelDecorator<String>(
          labelPosition: charts.BarLabelPosition.outside,
        ),
        behaviors: [
          charts.SeriesLegend(
            position: charts.BehaviorPosition.bottom,
            outsideJustification: charts.OutsideJustification.middleDrawArea,
            horizontalFirst: true,
            desiredMaxRows: 2,
            cellPadding: new EdgeInsets.only(right: 24.0, bottom: 4.0),
            entryTextStyle: charts.TextStyleSpec(
                color: charts.Color(r: 127, g: 63, b: 191),
                fontFamily: 'Georgia',
                fontSize: 11),
          )
        ]);
  }
}

class HorizontalBarChart2 extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalBarChart2(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    // For horizontal bar charts, set the [vertical] flag to false.
    return new charts.BarChart(seriesList,
        animate: animate,
        vertical: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
            showAxisLine: false, renderSpec: new charts.NoneRenderSpec()),
        domainAxis: new charts.OrdinalAxisSpec(
            renderSpec: new charts.GridlineRendererSpec(
          // Tick and Label styling here.
          labelStyle: new charts.TextStyleSpec(
              fontSize: 10, // size in Pts.
              color: charts.MaterialPalette.black),
        )),
        barRendererDecorator: new charts.BarLabelDecorator<String>(
          labelPosition: charts.BarLabelPosition.auto,
          insideLabelStyleSpec: charts.TextStyleSpec(
            color: charts.MaterialPalette.black,
            fontSize: 10,
          ),
          outsideLabelStyleSpec: charts.TextStyleSpec(
            color: charts.MaterialPalette.black,
            fontSize: 10,
          ),
        ),
        behaviors: []);
  }
}

class BarData {
  final String percentage;
  final double value;

  BarData(this.percentage, this.value);
}

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  static String pointerValue;

  SimpleLineChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList,
        animate: animate,
        domainAxis: charts.NumericAxisSpec(
          showAxisLine: true,
          renderSpec: charts.NoneRenderSpec(),
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
          showAxisLine: true,
          renderSpec: charts.NoneRenderSpec(),
        ),
        selectionModels: [
          charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue = roundDouble(datumPair.datum.percentage) +
                    "% in " +
                    datumPair.datum.goalTerm.toString() +
                    (datumPair.datum.goalTerm > 1 ? " yrs" : " yr");
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
              symbolRenderer: CustomCircleSymbolRenderer()),
          new charts.ChartTitle('%',
              behaviorPosition: charts.BehaviorPosition.start,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
              titleOutsideJustification:
                  charts.OutsideJustification.endDrawArea),
          new charts.ChartTitle('Years',
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
              titleOutsideJustification:
                  charts.OutsideJustification.endDrawArea),
        ]);
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
      Rectangle(bounds.left - positionBox, bounds.top - 25, bounds.width + 110,
          bounds.height + 25),
      fill: charts.ColorUtil.fromDartColor(Color((0xff1772ff))),
      //radius: 4,
    );

    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontFamily = 'nunito';
    textStyle.fontSize = 13;

    canvas.drawText(TextElement(SimpleLineChart.pointerValue, style: textStyle),
        (bounds.left + positionText).round(), (bounds.top - 13).round());
  }
}

class yieldData {
  final int goalTerm;
  final double percentage;

  yieldData(this.goalTerm, this.percentage);
}

class PieOutsideLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PieOutsideLabelChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      // Add an [ArcLabelDecorator] configured to render labels outside of the
      // arc with a leader line.
      //
      // Text style for inside / outside can be controlled independently by
      // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
      //
      // Example configuring different styles for inside/outside:
      //       new charts.ArcLabelDecorator(
      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
      /* defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
			new charts.ArcLabelDecorator(
				labelPosition: charts.ArcLabelPosition.outside)
			]) */
      defaultRenderer:
          new charts.ArcRendererConfig(arcWidth: 120, arcRendererDecorators: [
        // <-- add this to the code
        charts.ArcLabelDecorator(
            outsideLabelStyleSpec: new charts.TextStyleSpec(
                fontSize: 10)) // <-- and this of course
      ]),
      behaviors: [
        new charts.DatumLegend(
          position: charts.BehaviorPosition.end,
        )
      ],
    );
  }
}

class PiechartData {
  final String type;
  final double value;
  final charts.Color color;

  PiechartData(this.type, this.value, this.color);
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getScaledValue(200),
      child: charts.BarChart(
        seriesList,
        animate: animate,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          showAxisLine: false,
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            _formatMoney,
          ),
        ),
      ),
    );
  }
}

/// Sample ordinal data type.
class BarchartData {
  final String year;
  final double value;

  BarchartData(this.year, this.value);
}

String _formatMoney(num value1) {
  int value = value1.toInt();
  return NumberFormat.compact().format(value);
}

// ***************** chart library ***************
class SelectionCallbackExample extends StatefulWidget {
  List<charts.Series> seriesList;
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
