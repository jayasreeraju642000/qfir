import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:qfinr/main.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/discover/discover_graph_view.dart';
import 'package:qfinr/pages/discover/discover_styles.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/utils/text_with_drop_down_button.dart';
import 'package:qfinr/widgets/disclaimer_alert.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final key = new GlobalKey<_SelectionCallbackState>();

final log = getLogger('LoginPage');

class DashBoard extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final basketIndex = "1";

  DashBoard(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _DashBoardState();
  }
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  final controller = ScrollController();

  BasketResponse basketResponse;
  IndicesPerformance indicesResponse;

  List<String> myList = [];

  _DashBoardState();

  List<Map<String, String>> markets = [];
  Map<String, String> _selectedMarketOption;

  String _performanceTenure = "3year";

  Map<String, dynamic> _benchmarkPerformance;
  Map _selectedPortfolios = {};
  String _selectedMarket = "";

  StateSetter _setState;

  String _selectedCurrency;

  bool isLoading = false;
  TabController _tabController, _tabController_market_today;
  Map fundTypeCounts;
  List<FlSpot> flSpotList = [];
  dynamic notifications;
  PageIndicatorController pageViewController;
  bool _showGraph = true;
  int counter = 1;
  bool _setDefaultPortfoliosLoad = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Benchmark Performance',
        screenClassOverride: 'BenchmarkPerformance');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Benchmark Performance page",
    });
  }

  Future<Null> _analyticsRefreshEvent() async {
    widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_refresh",
      'content_type': "refresh_button",
    });
  }

  Future<Null> _anlyticsAlertEvent() async {
    // log.d("\n anlyticsAlertEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_alerts",
      'content_type': "click_alert",
    });
  }

  Future<Null> _analyticsPerformerCardEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_top_bottom_performer_card",
      'content_type': "performer_card_click",
    });
  }

  Future<Null> _analyticsDurationFilterEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_toggle_duration",
      'content_type': "duration_toggle_button",
    });
  }

  Future<Null> _analyticsChangeBenchmarkEvent() async {
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_benchmark_drop_down",
      'content_type': "select_benchmark_drop_down",
    });
  }

  Future<Null> _analyticsChangeSelectionEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "view_details",
      'item_name': "view_details_change_selection",
      'content_type': "change_selection_click",
    });
  }

  List<bool> _activeList = [];
  String _selectedTabText = '';
  String graphSelectedZone = '';
  int graphDataPosition = 0;

  Map<dynamic, dynamic> response_ip_v;

  void _initalizeDummyListActive() {
    for (int i = 0; i < myList?.length; i++) {
      _activeList.add(false);
    }
    if (!widget.model.isLoading) {
      _activeList[0] = true;
      _selectedTabText = myList[0];

      for (var i = 0; i < basketResponse.response.length; i++) {
        var selected_zone = basketResponse.response[i].zone;
        if (_selectedTabText.toLowerCase() == selected_zone) {
          graphSelectedZone = basketResponse.response[i].zone;
          graphDataPosition = i;

          break;
        }
      }
    }
  }

  void getIpAddress() async {
    final ipv4 = await Ipify.ipv4();

    validateIP(ipv4);
  }

  void initState() {
    super.initState();

    getIpAddress();

    setState(() {
      fundTypeCounts = portfoliosFundTypeCount(
        portfolios: widget.model.userPortfoliosData,
        checkLive: true,
      );
    });

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    _tabController_market_today =
        TabController(length: 3, vsync: this, initialIndex: 0);

    int maxCount = 15;
    int counter = 1;
    widget.model.portfolioGraphData.forEach((element) {
      if (counter < maxCount) {
        flSpotList.add(FlSpot(double.parse(element[0].toString()),
            double.parse(element[1].toString())));
        counter++;
      }
    });

    getCustomerNotifications();
    widget.model.getCustomerSettings();

    getModels();

    // setState(() {
    //widget.model.setLoader(false);
    // widget.model.redirectBase = "/home_new";
    // });

    _currentScreen();
    _addEvent();

    getBenchmarkPerformance();

    widget.model.getZoneBenchmarks();

    //widget.model.fetchOtherData();
  }

  refreshParent() => setState(() {});

  getModels() async {
    widget.model.setLoader(true);

    // notifications = await widget.model.getLocalNotification(makeRead: true);

    // setState(() {
    //   notifications = notifications.values.toList();
    // });

    try {
      if (!kIsWeb) {
        final PackageInfo info = await PackageInfo.fromPlatform();
        var responseData = await widget.model.getAppVersion();

        if (info.version.compareTo(responseData['response']) < 0) {
          loadBottomSheet(
              context: context, content: appUpdatePopup(), dismissable: false);
        }
      }
    } catch (e) {}

    getBasket();

    widget.model.setLoader(false);
  }

  Future getCustomerNotifications() async {
    await widget.model.getCustomerNotifications();
    notifications = await widget.model.getLocalNotification(makeRead: true);
    notifications = notifications.values.toList();
    if (mounted) {
      setState(() {});
    }
  }

  Future getBasket() async {
    widget.model.setLoader(true);
    //basketResponse = await widget.model.getMIBasket();
    basketResponse = await widget.model.getLocalMIBaskets();
    indicesResponse = await widget.model.getIndicesPerformance();
    widget.model.setLoader(false);
    await callTabData();
  }

  Map<String, IndicesPerformanceData> dataMap = {};

  void callTabData() async {
    // log.d("inside callTabData");
    dataMap = indicesResponse.response.indicesPreformanceMap;
    dataMap.forEach((key, value) {
      myList.add(value.zone.toLowerCase());
    });
    myList = myList.toSet().toList();
    _initalizeDummyListActive();
    if (mounted) {
      setState(() {});
    }
  }

  Widget appUpdatePopup() {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(30)),
        child: Column(
          children: [
            Text("We have upgraded".toUpperCase(),
                style: importPortfolioHelpTitle.copyWith(color: colorBlue)),
            SizedBox(height: getScaledValue(16)),
            Text("Download the latest version of the app to continue",
                textAlign: TextAlign.center, style: keyStatsBodyText4),
            SizedBox(height: getScaledValue(24)),
            gradientButton(
                context: context,
                caption: "CLOSE",
                onPressFunction: () =>
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'))
          ],
        ));
  }

  void getBenchmarkPerformance() async {
    widget.model.setLoader(true);
    getBenchmarkPerformanceWithOutLoader();
    widget.model.setLoader(false);
    if (mounted) {
      setState(() {});
    }
  }

  void getBenchmarkPerformanceWithOutLoader() async {
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
  }

  List<LinearGradient> heatGraphGradients() {
    return [
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe16c56), Color(0xffe49d62)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe3905f), Color(0xffe7bd6a), Color(0xffcebf6e)]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe7bd6a), Color(0xff85c077)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffb1c072), Color(0xff85c077)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff85c077), Color(0xffe7bd6a)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffcebf6e), Color(0xffe7bd6a), Color(0xffe3905f)]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe49d62), Color(0xffe16c56)],
          stops: [0.0, 0.9]),
    ];
  }

  String getEquityByCountryCode(String code) {
    //logger.e(code);
    if (code.toLowerCase() == "in") {
      return "India Equities";
    } else {
      return "US Equities";
    }
  }

  int spikeIndex(String basketValue) {
    double value = double.parse(basketValue);
    if (isBetween(value, 0, 9, true)) {
      return 0;
    } else if (isBetween(value, 10, 24, true)) {
      return 1;
    } else if (isBetween(value, 25, 39, true)) {
      return 2;
    } else if (isBetween(value, 40, 59, true)) {
      return 3;
    } else if (isBetween(value, 60, 79, true)) {
      return 4;
    } else if (isBetween(value, 80, 99, true)) {
      return 5;
    } else {
      return 6;
    }
  }

  List<charts.Series<yieldData, DateTime>> fixGraphData() {
    final List<yieldData> yieldDb = [];

    for (int i = 0; i < widget.model.portfolioGraphData.length; i++) {
      yieldDb.add(yieldData(
        DateTime.fromMillisecondsSinceEpoch(
            widget.model.portfolioGraphData[i][0]),
        //widget.model.portfolioGraphData[i][1],
        widget.model.portfolioGraphData[i][1].toDouble(),
        //widget.model.portfolioGraphData[i][1].toString(),
      ));
    }

    return [
      charts.Series<yieldData, DateTime>(
        id: 'Goal Term',
        /* colorFn: (yieldData sales, __) => 
					sales.total < 30 ? red[0] : 
					(sales.total >= 30 && sales.total < 70) ? yellow[0] : 
					(sales.total >= 70 && sales.total < 80) ? lime[0] : 
					(sales.total >= 80 && sales.total < 85) ? blue[0] : 
					(sales.total >= 85 && sales.total < 100) ? green[0] : green[4], */
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xff787878))),
        //green[2],//charts.MaterialPalette.green.shadeDefault,
        domainFn: (yieldData sales, _) => sales.date,
        measureFn: (yieldData sales, _) => sales.total,
        data: yieldDb,
      )
    ];
  }

  validateIP(ipv4) async {
    response_ip_v = await widget.model.validateIP(ipv4);
    // response_ip_v =
    //     await widget.model.validateIP('11.32.204.128'); // singapore ip
    if (response_ip_v['status'] == false) {
      var popuptitle = response_ip_v['popuptitle'];
      var popupbody = response_ip_v['popupbody'];

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var _year = prefs.getInt('Year');
      var _month = prefs.getInt('Month');
      var _date = prefs.getInt('Date');
      if (_year != null) {
        final stored_date = DateTime(_year, _month, _date);
        final currentDate = DateTime.now();

        final diff_dy = currentDate.difference(stored_date).inDays;

        if (diff_dy >= 7) {
          showDialog(
              context: context,
              builder: ((BuildContext context) {
                return DisClaimDialog(popuptitle, popupbody);
              })).then((value) {
            if (value == 'Decline') {
              logout();
            }
          });
        }
      } else {
        showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DisClaimDialog(popuptitle, popupbody);
            })).then((value) {
          if (value == 'Decline') {
            logout();
          }
        });
      }
    }
  }

  void logout() async {
    widget.model.logout();
    Navigator.pushReplacementNamed(context, '/login');
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
          child: NavigationTobBar(widget.model,
              openDrawer: () => _scaffoldKey.currentState.openDrawer(),
              invite_avilable: true),
        ),
        body: _buildBodyLarge(),
      ));
      // }
    });
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

  void marketSelectChange(Map<String, String> value) {
    _analyticsChangeBenchmarkEvent();
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList(
        _benchmarkPerformance['graphData'][value['value']][_performanceTenure],
        value['value']);
    setState(() {
      _selectedMarketOption = value;
      key.currentState._seriesList = chartData;
      _selectedMarket = value['value'];
    });
  }

  Widget _basketPerformance(BuildContext context) {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList(
        _benchmarkPerformance['graphData'][_selectedMarket][_performanceTenure],
        _selectedMarket); //@todo

    return Container(
        color: Colors.white,
        //padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextWithDropDown(
              "PERFORMANCE VS ",
              _benchmarkPerformance['marketNames'][_selectedMarket],
              _selectedMarketOption,
              markets,
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
            //           text: _benchmarkPerformance['marketNames']
            //               [_selectedMarket],
            //           style: appGraphTitle.copyWith(color: colorBlue),
            //           recognizer: TapGestureRecognizer()
            //             ..onTap = () => buildSelectBoxCustomHomePage(
            //                 context: context,
            //                 value: _selectedMarket,
            //                 title: 'Select benchmark',
            //                 options: markets,
            //                 onChangeFunction: marketSelectChange)),
            //       WidgetSpan(
            //         child: Icon(Icons.keyboard_arrow_down,
            //             color: colorBlue, size: 14),
            //       ),
            //     ])),
            SizedBox(height: getScaledValue(25.0)),
            SelectionCallbackExample(chartData, key: key),
            SizedBox(height: getScaledValue(16.0)),
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
        onTap: () {
          Navigator.of(context)
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

    // return Container(
    // 	child: Flex(
    // 	direction: Axis.vertical,
    // 	children: listPortfolios,
    // 	)
    // );

    return ListView(
      //controller: controller,
      physics: ClampingScrollPhysics(),
      children: listPortfolios,
    );
  }

  void filterPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          _setState = setState;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: null,
            content: _filterPopup(),
            actions: <Widget>[
              TextButton(
                style: qfButtonStyle0,
                child: Text("Cancel", style: dialogBoxActionInactive),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: qfButtonStyle0,
                child: Text("Save", style: dialogBoxActionActive),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    //widget.model.setLoader(true);
                  });
                  Map<String, dynamic> responseData =
                      await widget.model.changeCurrency(_selectedCurrency);
                  if (responseData['status'] == true) {
                    await getBenchmarkPerformance();
                    await widget.model.fetchOtherData();
                  }
                  setState(() {
                    //widget.model.setLoader(false);
                  });
                },
              )
            ],
          );
        });
      },
    );
  }

  void filterPopup1() {
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
          style: qfButtonStyle0,
          child: Text("Cancel", style: dialogBoxActionInactive),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: qfButtonStyle0,
          child: Text("Save", style: dialogBoxActionActive),
          onPressed: () async {
            Navigator.of(context).pop();
            setState(() {
              //widget.model.setLoader(true);
            });
            Map<String, dynamic> responseData =
                await widget.model.changeCurrency(_selectedCurrency);
            if (responseData['status'] == true) {
              await getBenchmarkPerformance();
              await widget.model.fetchOtherData();
            }
            setState(() {
              //widget.model.setLoader(false);
            });
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
      width: getScaledValue(360),
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
                },
              )),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildBodyLarge() {
    return _buildBodyNvaigationLeftBar();
  }

  Widget _buildBodyNvaigationLeftBar() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        deviceType == DeviceScreenType.tablet
            ? Container()
            : NavigationLeftBar(
                isSideMenuHeadingSelected: 0,
                isSideMenuSelected: 0,
              ),
        Expanded(
            child: widget.model.isLoading || _benchmarkPerformance == null
                ? preLoader()
                : _buildBodyContentLarge()),
      ],
    );
  }

  Widget performersTab() => _benchmarkPerformance['graphData'] != null &&
          _benchmarkPerformance['graphData'].length != 0
      ? Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              children: <Widget>[_basketPerformance(context)])),
                    ),
                    SizedBox(
                      width: getScaledValue(16),
                    ),
                    Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                            //color: Colors.white,
                            color: Color(0xffe9e9e9),
                            border: Border.all(
                                color: Color(0xffe9e9e9),
                                width: getScaledValue(1)),
                            borderRadius:
                                BorderRadius.circular(getScaledValue(4)),
                          ),
                          width: MediaQuery.of(context).size.width * 1.0 / 2,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      color: Colors.white,
                                      width: MediaQuery.of(context).size.width *
                                          1.0 /
                                          2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            child: Text("TOP PERFORMERS",
                                                style: dashboardPerfomer),
                                          ),

                                          Divider(height: getScaledValue(5)),

                                          _benchmarkPerformance['graphData']
                                                              [_selectedMarket]
                                                          [_performanceTenure]
                                                      ['top'] !=
                                                  null
                                              ? Container(
                                                  child: _portfolioListLarge(
                                                      _benchmarkPerformance[
                                                                      'graphData']
                                                                  [
                                                                  _selectedMarket]
                                                              [
                                                              _performanceTenure]
                                                          ['top'],
                                                      "Top Performers"
                                                          .toUpperCase()))
                                              : emptyWidget,
                                          //Divider(height: getScaledValue(5)),
                                        ],
                                      )),
                                ),

                                SizedBox(
                                  width: getScaledValue(1),
                                ),

                                Expanded(
                                    child: Container(
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.0 /
                                                2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(15),
                                              child: Text("BOTTOM PERFORMERS",
                                                  style: dashboardPerfomer),
                                            ),
                                            Divider(height: getScaledValue(5)),
                                            _benchmarkPerformance['graphData'][
                                                                _selectedMarket]
                                                            [_performanceTenure]
                                                        ['last'] !=
                                                    null
                                                ? Container(
                                                    child: _portfolioListLarge(
                                                        _benchmarkPerformance[
                                                                        'graphData']
                                                                    [
                                                                    _selectedMarket]
                                                                [
                                                                _performanceTenure]
                                                            ['last'],
                                                        "Bottom Performers"
                                                            .toUpperCase()))
                                                : emptyWidget,
                                          ],
                                        )))

                                //_graphPortfolioLarge()
                              ])),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      : Padding(
          padding: const EdgeInsets.all(30.0),
          child: Text('No Data Available', style: headline7),
        );

// ignore: todo
// TODO : portfoliosTab --------------- : shariyath
  Widget portfoliosTab_Test() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          children: <Widget>[_basketPerformance(context)])),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget portfoliosTab() {
    List<Widget> _children = [];

    widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
      if (portfolioMasterID != '0') {
        if (!_selectedPortfolios.containsKey(portfolioMasterID)) {
          _selectedPortfolios[portfolioMasterID] =
              (portfolio['default'] == '1' ? true : false);
        }

        _children.add(_portfolioMasterBoxContainer(portfolio));

        //if(widget.layout == "checkbox")
        // _children.add(Container(
        //     margin: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
        //     child: Divider(
        //       height: 2,
        //       color: Color(0xffdadada),
        //     )));
      }
    });

    if (_setDefaultPortfoliosLoad) {
      return preLoader();
    }

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 340,
            child: ListView(
              shrinkWrap: true,
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
              children: _children,
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [_submitButton()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    bool flagCheck = false;
    _selectedPortfolios.forEach((key, value) {
      if (value == true) {
        flagCheck = true;
      }
    });
    return gradientButtonLarge(
        context: context,
        caption: ["analyzer", "merge", "dividend", "stress"].contains("default")
            ? "next"
            : "save",
        onPressFunction: flagCheck ? () => formResponse() : null);
  }

  void formResponse() async {
    List selectedPortfolios = [];
    _selectedPortfolios.forEach((key, value) {
      if (value == true) {
        selectedPortfolios.add(key);
        _analyticsChangeSelectionEvent();
      }
    });
    setState(() {
      _setDefaultPortfoliosLoad = true;
    });
    await widget.model.setDefaultPortfolios(portfolios: selectedPortfolios);
    await getBenchmarkPerformanceWithOutLoader();
    setState(() {
      _setDefaultPortfoliosLoad = false;
      fundTypeCounts = portfoliosFundTypeCount(
        portfolios: widget.model.userPortfoliosData,
        checkLive: true,
      );
    });
  }

  Widget _portfolioMasterBoxContainer(Map portfolioData) {
    return Container(
      // margin: EdgeInsets.symmetric(
      //     vertical: getScaledValue(10), horizontal: getScaledValue(10)),
      child: _portfolioMasterBox(portfolioData),
    );
  }

  Widget _portfolioMasterBox(Map portfolioData) {
    List zones = portfolioData['portfolio_zone'].split('_');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Text(portfolioData['portfolio_name'],
                  style: body_text0_portfolio),
              SizedBox(height: getScaledValue(13)),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              portfolioData['type'] == '1'
                                  ? widgetBubble(
                                      title: 'LIVE',
                                      includeBorder: false,
                                      leftMargin: 0,
                                      bgColor: Color(0xffe9f4ff),
                                      textColor: Color(0xff708bc1))
                                  : widgetBubble(
                                      title: 'WATCHLIST',
                                      includeBorder: false,
                                      leftMargin: 0,
                                      bgColor: Color(0xffffece3),
                                      textColor: Color(0xffbc9f91)),
                              SizedBox(width: getScaledValue(8)),
                              Row(
                                  children: zones
                                      .map((item) => Padding(
                                          padding: EdgeInsets.only(right: 4.0),
                                          child: widgetZoneFlag(item)))
                                      .toList()),
                            ],
                          ),
                          SizedBox(height: getScaledValue(5)),
                          _fundCount(portfolioData)
                        ],
                      )),
                  Container(
                      //   width: MediaQuery.of(context).size.width * 0.10,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Value",
                        style: body_text1_portfolio,
                      ),
                      SizedBox(height: getScaledValue(5)),
                      Text(portfolioData['value'], style: body_text2_portfolio)
                    ],
                  )),
                  Container(
                      //   width: MediaQuery.of(context).size.width * 0.10,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "One Day Returns",
                        style: body_text1_portfolio,
                      ),
                      SizedBox(height: getScaledValue(5)),
                      Text(portfolioData['change_amount'],
                          style: body_text2_portfolio)
                    ],
                  )),
                  Container(
                      // width: MediaQuery.of(context).size.width * 0.10,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Month to Date",
                            style: body_text1_portfolio,
                          ),
                          SizedBox(width: getScaledValue(4)),
                          Text(
                            portfolioData['changeMonth'],
                            style: portfolioData['changeMonth_sign'] == "up"
                                ? body_textgreen_portfolio
                                : body_textred_portfolio,
                          ),
                        ],
                      ),
                      SizedBox(height: getScaledValue(5)),
                      Text(portfolioData['changeMonth_amount'],
                          style: body_textred_portfolio.copyWith(
                              color: portfolioData['changeMonth_sign'] == "up"
                                  ? colorGreenReturn
                                  : colorRedReturn))
                    ],
                  )),
                  Container(
                      // width: MediaQuery.of(context).size.width * 0.10,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Year to Date",
                            style: body_text1_portfolio,
                          ),
                          SizedBox(width: getScaledValue(4)),
                          Text(
                            portfolioData['changeYear'],
                            style: portfolioData['changeYear_sign'] == "up"
                                ? body_textgreen_portfolio
                                : body_textred_portfolio,
                          ),
                        ],
                      ),
                      SizedBox(height: getScaledValue(5)),
                      Text(portfolioData['changeYear_amount'],
                          style: body_textred_portfolio.copyWith(
                              color: portfolioData['changeYear_sign'] == "up"
                                  ? colorGreenReturn
                                  : colorRedReturn))
                    ],
                  )),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pushNamed(
                              context, '/portfolio_view/' + portfolioData['id'],
                              arguments: {"readOnly": false});
                        },
                        child: Container(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Details', style: body_text3_portfolio),
                          ],
                        )),
                      )),
                  Container(
                    child: Checkbox(
                      activeColor: Color(0xffcedfff),
                      checkColor: Color(0xff034bd9),
                      value: _selectedPortfolios[portfolioData['id']],
                      onChanged: (newValue) =>
                          updateValue(portfolioData, newValue),
                    ),
                  )
                ],
              )),
              SizedBox(height: getScaledValue(24)),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xffeaeaea),
                ),
              ),
            ],
          )),
        )
      ],
    );
  }

  Function updateValue(portfolioData, newValue) {
    if (portfolioData['portfolios'] != null) {
      setState(() {
        _selectedPortfolios[portfolioData['id']] = newValue;
      });
    }
    return null;
  }

  Widget _fundCount(Map portfolioData) {
    List<Widget> _children = [];

    String fundCount = "";
    if (portfolioData['portfolios'] != null) {
      bool firstLoop = true;

      portfolioData['portfolios'].forEach((fundType, portfolio) {
        if (!firstLoop) {
          _children.add(Container(
              margin: EdgeInsets.symmetric(horizontal: getScaledValue(9)),
              child: Text("|", style: TextStyle(color: Color(0xffdddddd)))));
          fundCount += " | ";
        } else {
          firstLoop = false;
        }
        _children.add(RichText(
            text: TextSpan(
                text: portfolio.length.toString(),
                style: portfolioBoxStockCount,
                children: [
              TextSpan(
                  text: " " + fundType.toUpperCase(),
                  style: portfolioBoxStockCountType)
            ])));
        fundCount += portfolio.length.toString() + " " + fundType.toUpperCase();
      });
    }

    // return Text(limitChar(fundCount, length: 20),
    //     style: portfolioBoxStockCountType);

    return Text(fundCount, style: portfolioBoxStockCountType);
  }

  Widget _portfolioListLarge(portfolioList, String title) {
    // log.d("Life_is_racing-----------");

    List<Widget> listPortfolios = [];

    portfolioList.forEach((key, value) {
      listPortfolios.add(GestureDetector(
        onTap: () {
          _analyticsPerformerCardEvent();
        },
        // onTap: () => Navigator.of(context)
        //     .pushNamed('/fund_info', arguments: {'ric': key}),

        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
          // paddingBottom: getScaledValue(16.0),
          // paddingLeft: getScaledValue(16.0),
          // paddingRight: getScaledValue(16.0),
          // paddingTop: getScaledValue(16.0),
          // context: context,
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Text(value['name'], style: bodyText1_analyse)),
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
                          style: body_text2_dashboardPerfomer)
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

    // return Container(
    // 	child: Flex(
    // 	direction: Axis.vertical,
    // 	children: listPortfolios,
    // 	)
    // );

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      height: 320,

      //child: Flex(
      // direction: Axis.vertical,
      // children: <Widget>[

      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        controller: controller,
        physics: AlwaysScrollableScrollPhysics(),
        children: listPortfolios,
      ),

      //	],
      //	),
    );

    // 	return ListView(
    //     shrinkWrap: true,
    // 	  controller: controller,
    //     scrollDirection: Axis.vertical,
    //     physics: const ClampingScrollPhysics(),
    //     //primary: true,
    // 	  children: listPortfolios,
    // );
  }

  Widget _buildBodyContentLarge() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(24),
        color: Color(0xfff5f6fa),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dashboardeHeader(),
            SizedBox(
              height: getScaledValue(16),
            ),
            _buildMenuTabs(),
            SizedBox(
              height: getScaledValue(2),
            ),
            _buildBodyTabBarView(),
            SizedBox(
              height: getScaledValue(30),
            ),
            _buildBodyFooterContainer(),
            SizedBox(
              height: getScaledValue(6),
            ),
          ],
        ),
      ),
    );
  }

  _dashboardeHeader() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text("Dashboard", style: headline1_analyse),
          ),
          SizedBox(
            height: getScaledValue(16),
          ),
        ],
      ),
    );
  }

  Container _buildMenuTabs() {
    _selectedCurrency = widget.model.userSettings['currency'] != null
        ? widget.model.userSettings['currency']
        : null;
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      height: getScaledValue(50),
      // padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              // width: MediaQuery.of(context).size.width * 1.0 / 1.75,
              child: tabbar(),
            ),
          ),
          Expanded(
            child: Container(
              height: getScaledValue(50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync_outlined,
                          color: Color(0xff034bd9),
                          size: 15.0,
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              await _analyticsRefreshEvent();
                              counter++;
                              await widget.model.fetchOtherData();
                              widget.model.setLoader(true);
                              await getBenchmarkPerformance();
                              widget.model.setLoader(false);
                            },
                            child: Text(
                              'Refresh',
                              style: body_text3_portfolio,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: getScaledValue(18),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    padding: EdgeInsets.symmetric(
                      vertical: getScaledValue(4),
                      horizontal: getScaledValue(8),
                    ),
                    //height: getScaledValue(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: colorBlue, width: 1.25),
                    ),
                    alignment: Alignment.center,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: getScaledValue(15),
                        ),
                        hint: Align(
                            alignment: Alignment.center,
                            child: Text(
                              (widget.model.userSettings['currency'] != null
                                      ? widget.model.userSettings['currency']
                                      : 'inr')
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: heading_alert_view_all,
                            )),
                        value: _selectedCurrency,
                        selectedItemBuilder: (context) {
                          return widget.model.currencies
                              .map<Widget>((Map item) {
                            return DropdownMenuItem<String>(
                              value: item['key'],
                              child: Text(
                                item['value'],
                                style: heading_alert_view_all,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList();
                        },
                        items: widget.model.currencies.map((Map item) {
                          var textColor =
                              (_selectedCurrency.contains(item['key']))
                                  ? Colors.white
                                  : MyApp.commonPrimaryColor;

                          return DropdownMenuItem<String>(
                            value: item['key'],
                            child: Text(
                              item['value'],
                              style: heading_alert_view_all.copyWith(
                                  color: textColor),
                              textAlign: TextAlign.left,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedCurrency = value;
                          });
                          Map<String, dynamic> responseData = await widget.model
                              .changeCurrency(_selectedCurrency);
                          if (responseData['status'] == true) {
                            await getBenchmarkPerformance();
                            await widget.model.fetchOtherData();
                          }
                          setState(() {
                            //widget.model.setLoader(false);
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: getScaledValue(16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTabBarView() {
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
                height: 15,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 1.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            height: 400,
                            child: TabBarView(
                              controller: _tabController,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                widget.model.userPortfolioValue != false &&
                                        widget.model.userPortfolioValue != null
                                    ? summaryTab()
                                    : Center(
                                        child: noPortfolio(),
                                      ),
                                widget.model.userPortfolioValue != false &&
                                        widget.model.userPortfolioValue != null
                                    ? performersTab()
                                    : Center(
                                        child: noPortfolio(),
                                      ),
                                widget.model.userPortfolioValue != false &&
                                        widget.model.userPortfolioValue != null
                                    ? portfoliosTab()
                                    : Center(
                                        child: noPortfolio(),
                                      ),
                              ],
                            ))
                      ])),
              SizedBox(
                height: getScaledValue(24),
              ),
            ]));
  }

  Widget noPortfolio() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      height: 280,
      child: _noGraphPortfolio(),
    );
  }

  Widget _noGraphPortfolio() {
    return Container(
      padding: EdgeInsets.only(
        top: getScaledValue(30),
        left: getScaledValue(12),
        right: getScaledValue(12),
        // bottom: getScaledValue(18),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(getScaledValue(7)),
        color: Colors.white,
        border: Border.all(
          color: Color(0xffeeeeee),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          svgImage("assets/icon/icon_no_investment.svg"),
          gradientButtonLarge(
            context: context,
            caption: "Add investments",
            onPressFunction: () =>
                Navigator.pushNamed(context, "/add_portfolio")
                    .then((_) => refreshParent()),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFooterContainer() {
    List notificationList = notifications;
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 1.0 / 2,
              height: getScaledValue(620),
              color: Colors.white,
              // padding: EdgeInsets.only(
              //     left: 24.0, top: 0.0, right: 24.0, bottom: 0.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: getScaledValue(22)),
                    Container(
                      padding: EdgeInsets.only(
                          left: 24.0, top: 0.0, right: 24.0, bottom: 0.0),
                      child: Text('Market Today', style: headline7),
                    ),
                    SizedBox(height: getScaledValue(16)),
                    _buildDicoverMenuTabs(),
                    SizedBox(height: getScaledValue(2)),
                    Expanded(
                      child: _buildBodyMarketTodayTabBarView(),
                    ),
                  ]),
            ),
          ),
          SizedBox(
            width: getScaledValue(16),
          ),
          Expanded(
            child: Container(
                width: MediaQuery.of(context).size.width * 1.0 / 2,
                height: getScaledValue(620),
                color: Colors.white,
                padding: EdgeInsets.only(
                    left: 36.0, top: 36.0, right: 16.0, bottom: 16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alerts', style: headline7),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                await _anlyticsAlertEvent();
                                Navigator.pushNamed(context, "/notification");
                              },
                              child: Text(
                                  notificationList.length > 0
                                      ? 'View all >'
                                      : "",
                                  style: heading_alert_view_all),
                            ),
                          )
                        ],
                      ),

                      Expanded(
                          child: Center(
                        child: notificationContainer(),
                      ))

                      //_graphPortfolioLarge()
                    ])),
          ),
        ],
      ),
    );
  }

  Widget _buildDicoverMenuTabs() => Stack(
        children: [
          SizedBox(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: myList?.length ?? 0,
              itemBuilder: (_, int index) {
                return _buildDicoverTabSelector(
                  myList[index].toUpperCase(),
                  index,
                );
              },
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Color(0xfff5f6fa),
              width: MediaQuery.of(context).size.width,
              height: 1.0,
            ),
          ),
        ],
      );

  Container _buildDicoverTabSelector(String text, int index) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        height: 50.0,
        decoration: BoxDecoration(
          border: Border(
            bottom: _activeList[index]
                ? BorderSide(
                    color: Color(0xff034bd9),
                    width: 2.0,
                  )
                : BorderSide.none,
          ),
        ),
        child: FlatButton(
          onPressed: () => _changeSelectedTab(index),
          child: Text(
            text,
            style: TextStyle(
              color: _activeList[index] ? Color(0xff034bd9) : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  void _changeSelectedTab(int index) {
    setState(() {
      for (int i = 0; i < _activeList?.length; i++) {
        _activeList[i] = false;
      }
      _activeList[index] = true;
      _selectedTabText = myList[index];

      for (var i = 0; i < basketResponse.response.length; i++) {
        var selected_zone = basketResponse.response[i].zone;
        if (_selectedTabText.toLowerCase() == selected_zone) {
          graphSelectedZone = basketResponse.response[i].zone;
          graphDataPosition = i;

          break;
        }
      }
    });
  }

  Widget _buildDataRow() {
    //Map dataMap = indicesResponse.response.toJson();
    return SizedBox(
      width: 100,
      child: ListView.separated(
        padding: EdgeInsets.only(top: 25.0),
        shrinkWrap: true,
        itemCount: dataMap?.length,
        separatorBuilder: (BuildContext context, int pos) {
          String key = dataMap.keys.elementAt(pos);
          return Visibility(
            visible: _selectedTabText.toLowerCase() ==
                    dataMap[key].zone.toString().toLowerCase()
                ? true
                : false,
            child: Divider(
              color: Colors.white,
              height: 40.0,
              thickness: 0.0,
            ),
          );
        },
        itemBuilder: (_, int index) {
          String key = dataMap.keys.elementAt(index);
          return Visibility(
            visible: _selectedTabText.toLowerCase() ==
                    dataMap[key].zone.toString().toLowerCase()
                ? true
                : false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dataMap[key].name.toString()}',
                        style: DiscoverStyles.discoverRowTextDark,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${dataMap[key].data.day.value.toString()} ',
                              style: DiscoverStyles.discoverRowTextLight,
                            ),
                            TextSpan(
                              text:
                                  '(${dataMap[key].data.day.change.toString()})',
                              style: _setValueColor(
                                dataMap[key].data.day.changeSign.toString(),
                                false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle _setValueColor(String value, bool isDark) {
    if (value.toLowerCase() == 'changesign.up') {
      if (isDark) {
        return DiscoverStyles.discoverRowTextGreen;
      }
      return DiscoverStyles.discoverRowTextGreen;
    } else {
      if (isDark) {
        return DiscoverStyles.discoverRowTextRed1;
      }
    }
    return DiscoverStyles.discoverRowTextRed;
  }

  Widget notificationContainer() {
    List notificationList = notifications;
    notificationList.sort((a, b) {
      var firstDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(a['date_added']);
      var secondDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(b['date_added']);
      return firstDate.compareTo(secondDate);
    });
    List notificationListReverse = notificationList.reversed.toList();

    if (notificationListReverse.length > 0) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return notificationRow(notificationListReverse[index],
                bgColor: Colors.white);
          },
          itemCount: notificationListReverse.length,
          separatorBuilder: (BuildContext context, int index) => emptyWidget);
    } else {
      return Container(
        //padding: EdgeInsets.symmetric(horizontal: getScaledValue(10), vertical: getScaledValue(20)),
        //child: Text("You have no new notification", textAlign: TextAlign.center, style: headline6));

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/group_ic.png"),
            SizedBox(height: getScaledValue(10)),
            Text("No alerts currently", style: bodyText5),
          ],
        ),
      );
    }
  }

  Widget notificationRow(Map notificationData, {Color bgColor = Colors.white}) {
    return Container(
        decoration: BoxDecoration(color: bgColor),
        child: Column(
          children: [
            //

            SizedBox(height: getScaledValue(36)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.only(top: getScaledValue(5)),
                    child: Icon(
                      Icons.fiber_manual_record,
                      color: colorBlue,
                      size: getScaledValue(7),
                    )),
                SizedBox(width: getScaledValue(5)),

                //padding: const EdgeInsets.only(left:16.0, right: 16, top: 16, bottom: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //SizedBox(height: getScaledValue(36)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(notificationData['title'],
                                style: body0_alerts),
                          ),
                          Text(
                              notificationData['date_added'] != null
                                  ? displayTimeAgoFromTimestamp(
                                      notificationData['date_added'])
                                  : " ",
                              style: bodyText4),
                        ],
                      ),

                      SizedBox(height: getScaledValue(5)),
                      Text(notificationData['description'],
                          style: body0_alerts),
                      SizedBox(height: getScaledValue(16)),
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget _buildBodyMarketTodayTabBarView() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 16),
            width: getScaledValue(150),
            child: _buildDataRow(),
          ),

          Visibility(
              visible: _selectedTabText.toLowerCase() == graphSelectedZone
                  ? true
                  : false,
              child: Expanded(
                  child: DiscoverGraphView(
                      basketResponse: this.basketResponse,
                      selectedTabText: this._selectedTabText,
                      graphDataPosition: this.graphDataPosition)))

          // Expanded(
          //   child: DiscoverGraphView(
          //     basketResponse: basketResponse,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget summaryTab() {
    if (widget.model.portfolioGraphData.length > 0) {
      _showGraph = true;
    } else {
      _showGraph = false;
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
                width: MediaQuery.of(context).size.width * 1.0 / 2.5,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text('Your portfolio today', style: bodyText0_dashboard),
                      SizedBox(height: getScaledValue(2.0)),
                      Text(
                        // widget.model.
                        removeDecimal(widget.model.userPortfolioValue['value']
                            .toString()),
                        style: headline3_analyse,
                      ),
                      SizedBox(height: getScaledValue(32)),
                      Container(
                        width: MediaQuery.of(context).size.width * 1.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'One Day Returns',
                                                style: TextStyle(
                                                    fontSize: ScreenUtil()
                                                        .setSp(12.0),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'nunito',
                                                    letterSpacing: 0.22,
                                                    color: Color(0xff707070))),
                                            TextSpan(
                                              text:
                                                  ' ${widget.model.userPortfolioValue['day']['change']}',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(12.0),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'nunito',
                                                  letterSpacing: 0.25,
                                                  color: widget.model.userPortfolioValue[
                                                                  'day']
                                                              ['change_sign'] ==
                                                          "up"
                                                      ? Color(0xff30c50c)
                                                      : Color(0xffc42f2f)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: getScaledValue(2)),
                                      Text(
                                        removeDecimal(widget
                                                .model.userPortfolioValue['day']
                                            ['change_difference']),
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(18.0),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'nunito',
                                          letterSpacing: 0.29,
                                          color: widget.model
                                                          .userPortfolioValue[
                                                      'day']['change_sign'] ==
                                                  "up"
                                              ? Color(0xff30c50c)
                                              : Color(0xffc42f2f),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text: 'Month to Date',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(12.0),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'nunito',
                                                  letterSpacing: 0.22,
                                                  color: Color(0xff707070))),
                                          TextSpan(
                                            text:
                                                ' ${widget.model.userPortfolioValue['month']['change']}',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(12.0),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'nunito',
                                                letterSpacing: 0.25,
                                                color:
                                                    widget.model.userPortfolioValue[
                                                                    'month'][
                                                                'change_sign'] ==
                                                            "up"
                                                        ? Color(0xff30c50c)
                                                        : Color(0xffc42f2f)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: getScaledValue(2)),
                                    Text(
                                        removeDecimal(widget.model
                                                .userPortfolioValue['month']
                                            ['change_difference']),
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(18.0),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'nunito',
                                            letterSpacing: 0.29,
                                            color:
                                                widget.model.userPortfolioValue[
                                                                'month']
                                                            ['change_sign'] ==
                                                        "up"
                                                    ? Color(0xff30c50c)
                                                    : Color(0xffc42f2f))),
                                  ],
                                )),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text: 'Year to Date',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(12.0),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'nunito',
                                                  letterSpacing: 0.22,
                                                  color: Color(0xff707070))),
                                          TextSpan(
                                            text:
                                                ' ${widget.model.userPortfolioValue['year']['change']}',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(12.0),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'nunito',
                                                letterSpacing: 0.25,
                                                color:
                                                    widget.model.userPortfolioValue[
                                                                    'year'][
                                                                'change_sign'] ==
                                                            "up"
                                                        ? Color(0xff30c50c)
                                                        : Color(0xffc42f2f)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: getScaledValue(2)),
                                    Text(
                                        removeDecimal(widget.model
                                                .userPortfolioValue['year']
                                            ['change_difference']),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'nunito',
                                            letterSpacing: 0.29,
                                            color:
                                                widget.model.userPortfolioValue[
                                                                'year']
                                                            ['change_sign'] ==
                                                        "up"
                                                    ? Color(0xff30c50c)
                                                    : Color(0xffc42f2f))),
                                  ],
                                )),
                              )
                            ]),
                      ),
                      SizedBox(height: getScaledValue(32)),
                      summaryCount()
                    ])),
          ),
          SizedBox(
            width: getScaledValue(16),
          ),
          Expanded(
            child: Container(
                width: MediaQuery.of(context).size.width * 1.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                        visible: widget.model.userPortfolioValue['date']
                                .toString()
                                .isNotEmpty
                            ? true
                            : false,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            Contants.date +
                                Contants.clone +
                                " " +
                                widget.model.userPortfolioValue['date']
                                    .toString(),
                            textAlign: TextAlign.right,
                            style: body_text3_summary,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: getScaledValue(6),
                      // ),
                      _graphPortfolioLarge()
                    ])),
          ),
        ],
      ),
    );
  }

  String _liveSummaryCount() {
    int count = 0;
    if (widget.model.userPortfoliosData is Map) {
      widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
        if (portfolioMasterID != '0') {
          if (portfolio['type'] == '1') {
            count++;
          }
        }
      });
    }
    return count.toString();
  }

  Widget summaryCount() {
    return Container(
        padding: EdgeInsets.all(getScaledValue(20)),
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: BoxDecoration(
          color: Colors.white,
          //color:Color(0xffe9e9e9),
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Container(
                                child: Text(
                                  "LIVE PORTFOLIOS: ",
                                  style: body_textcount_summary.copyWith(
                                      fontSize: ScreenUtil().setSp(12.0),
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: _liveSummaryCount(),
                              style: bodyText1_analyse,
                            ),
                          ],
                        )),
                        SizedBox(height: getScaledValue(10)),
                        Text.rich(TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Container(
                                child: Text(
                                  "COUNTRIES: ",
                                  style: body_textcount_summary.copyWith(
                                      fontSize: ScreenUtil().setSp(12.0),
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: widget.model.currencies.length.toString(),
                              style: bodyText1_analyse,
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(width: getScaledValue(6)),
                  Container(
                      height: 40,
                      child: VerticalDivider(color: Color(0xffe9e9e9))),
                  SizedBox(width: getScaledValue(6)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Container(
                                      width: getScaledValue(45),
                                      child: Text(
                                        "Stocks: ",
                                        style: body_textcount_summary.copyWith(
                                            fontSize: ScreenUtil().setSp(12.0),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: fundTypeCounts['Stocks'].toString() ==
                                            "null"
                                        ? "0"
                                        : fundTypeCounts['Stocks'].toString(),
                                    style: bodyText1_analyse,
                                  ),
                                ],
                              )),
                              SizedBox(height: getScaledValue(12)),
                              Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Container(
                                      width: getScaledValue(45),
                                      child: Text(
                                        "Bonds: ",
                                        style: body_textcount_summary.copyWith(
                                            fontSize: ScreenUtil().setSp(12.0),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: fundTypeCounts['Bonds'].toString() ==
                                            "null"
                                        ? "0"
                                        : fundTypeCounts['Bonds'].toString(),
                                    style: bodyText1_analyse,
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Container(
                                      width: getScaledValue(58),
                                      child: Text(
                                        "Deposits: ",
                                        style: body_textcount_summary.copyWith(
                                            fontSize: ScreenUtil().setSp(12.0),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: fundTypeCounts['Deposit']
                                                .toString() ==
                                            "null"
                                        ? "0"
                                        : fundTypeCounts['Deposit'].toString(),
                                    style: bodyText1_analyse,
                                  ),
                                ],
                              )),
                              SizedBox(height: getScaledValue(12)),
                              Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Container(
                                      width: getScaledValue(58),
                                      child: Text(
                                        "ETF'S: ",
                                        style: body_textcount_summary.copyWith(
                                            fontSize: ScreenUtil().setSp(12.0),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: fundTypeCounts['ETF'].toString() ==
                                            "null"
                                        ? "0"
                                        : fundTypeCounts['ETF'].toString(),
                                    style: bodyText1_analyse,
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Container(
                                      width: getScaledValue(85),
                                      child: Text(
                                        "Mutual Funds: ",
                                        style: body_textcount_summary.copyWith(
                                            fontSize: ScreenUtil().setSp(12.0),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: fundTypeCounts['Funds'].toString() ==
                                            "null"
                                        ? "0"
                                        : fundTypeCounts['Funds'].toString(),
                                    style: bodyText1_analyse,
                                  ),
                                ],
                              )),
                              SizedBox(height: getScaledValue(12)),
                              Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Container(
                                      width: getScaledValue(85),
                                      child: Text(
                                        "Commodities: ",
                                        style: body_textcount_summary.copyWith(
                                            fontSize: ScreenUtil().setSp(12.0),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: fundTypeCounts['Commodities']
                                                .toString() ==
                                            "null"
                                        ? "0"
                                        : fundTypeCounts['Commodities']
                                            .toString(),
                                    style: bodyText1_analyse,
                                  ),
                                ],
                              )),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: getScaledValue(16),
            ),
            Divider(height: getScaledValue(5)),
            SizedBox(
              height: getScaledValue(16),
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        widget.model.userPortfolioValue['cagr'].toString() +
                            "%",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(16.0),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'nunito',
                            letterSpacing: 0.26,
                            color: widget.model.userPortfolioValue['cagr'] < 0
                                ? colorRedReturn
                                : colorGreenReturn)),
                    SizedBox(
                      height: getScaledValue(2),
                    ),
                    Text("Time Weighted Return", style: body_text3_summary),
                    SizedBox(
                      height: getScaledValue(3),
                    ),
                    Text("(CAGR)", style: body_textcount_summary),
                  ],
                ),
                SizedBox(
                  width: getScaledValue(60),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.model.userPortfolioValue['xirr'].toString() +
                              "%",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16.0),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'nunito',
                              letterSpacing: 0.26,
                              color: widget.model.userPortfolioValue['xirr'] < 0
                                  ? colorRedReturn
                                  : colorGreenReturn)),
                      SizedBox(
                        height: getScaledValue(2),
                      ),
                      Text("Money Weighted Return", style: body_text3_summary),
                      SizedBox(
                        height: getScaledValue(3),
                      ),
                      Text("(XIRR)", style: body_textcount_summary),
                    ],
                  ),
                )
              ],
            )),
            // SizedBox(
            //   height: getScaledValue(3),
            // ),
            // Visibility(
            //   visible: widget.model.userPortfolioValue['date'].toString().isNotEmpty?true:false,
            //   child: Text( Contants.date +
            //                           Contants.clone +
            //                           " " +widget.model.userPortfolioValue['date'].toString(),
            //     style: body_text3_summary))
          ],
        ));
  }

  Widget _graphPortfolioLarge() {
    return Container(
      height: 380,
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxHeight: double.infinity,
            ),
            padding: EdgeInsets.only(
              top: getScaledValue(60),
              bottom: getScaledValue(20),
              left: getScaledValue(25),
              right: getScaledValue(25),
            ),
            child: _showGraph ? (SimpleLineChart(fixGraphData())) : emptyWidget,
            //_showGraph && flSpotList.isNotEmpty ? (flLineGraph()) : emptyWidget,
          ),
          Divider(),
          //	_percentageReturn()
        ],
      ),
    );
  }

  PreferredSizeWidget tabbar() {
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
      tabs: [
        Tab(
          text: "SUMMARY",
        ),
        Tab(text: "PERFORMANCE COMPARISON"),
        Tab(text: "PORTFOLIOS"),
      ],
    );
  }

  PreferredSizeWidget tabbar_MarketToday() {
    return TabBar(
      isScrollable: false,
      controller: _tabController_market_today,
      unselectedLabelColor: Color(0x30000000),
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
      tabs: [
        Tab(
          text: "IND",
        ),
        Tab(text: "UAE"),
        Tab(text: "US"),
      ],
    );
  }

  Widget marketIndicatorLarge() {
    return Container(
      height: getScaledValue(190),
      // MediaQuery.of(context).size.height * (Platform.isAndroid ? (androidMediaHeight(context) == "small" ? 0.30 : 0.26) : 0.25), //getScaledValue(250.0), // 0.26
      //height: getScaledValue(180), //getHeight(context, 175), //getScaledValue(175),
      /* constraints: BoxConstraints(
				minHeight: MediaQuery.of(context).size.height * 0.25, //getScaledValue(198.0),
				maxHeight: MediaQuery.of(context).size.height * 0.29, //getScaledValue(198.0),
			), */
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: basketResponse.response.length,
        controller: pageViewController,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            //padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
            child: widgetCard(
              bgColor: Color(0xfff5f5f5),
              bottomMargin: 0,
              leftMargin: 16,
              rightMargin: 16,
              topMargin: 0,
              child: marketIndicatorCardLarge(basketResponse.response[index]),
            ),
          );
        },
      ),
    );
  }

  Widget marketIndicatorCardLarge(BasketData basketData) {
    return Container(
        decoration: BoxDecoration(color: Color(0xfff5f5f5)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Market Sentiment", style: bodyText4),
                      Padding(
                        padding: EdgeInsets.only(top: getScaledValue(2.0)),
                        child: Text(getEquityByCountryCode(basketData.zone),
                            style: portfolioSummaryZone),
                      ),
                    ],
                  ),
                  // GestureDetector(
                  //     onTap: () => Navigator.pushNamed(context, "/discover")
                  //         .then((_) => refreshParent()),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: <Widget>[
                  //         Text("More", style: graphLink),
                  //         Icon(Icons.keyboard_arrow_right,
                  //             size: getScaledValue(12),
                  //             color: Color(
                  //               0xff034bd9,
                  //             )),
                  //       ],
                  //     )),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: getScaledValue(10.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        return Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  right: getScaledValue(index != 6 ? 8 : 0),
                                  top: getScaledValue(30)),
                              child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          gradient:
                                              heatGraphGradients()[index]),
                                      height:
                                          spikeIndex(basketData.basketValue) ==
                                                  index
                                              ? getScaledValue(14)
                                              : getScaledValue(6)),
                                  SizedBox(height: getScaledValue(2)),
                                  Text((index + 1).toString(),
                                      style: bodyText7),
                                ],
                              )),
                        );
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: getScaledValue(8.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Stay Defensive".toUpperCase(),
                              style: widgetBubbleTextStyle),
                          Text("Stay Alert".toUpperCase(),
                              style: widgetBubbleTextStyle)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: getScaledValue(12.0)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Current Sentiment:",
                                style: keyStatsBodyText6),
                            Padding(
                                padding: EdgeInsets.only(
                                  left: getScaledValue(5.0),
                                ),
                                child: Text(basketData.miBasketDetails.trend,
                                    style: keyStatsBodyText7)),
                          ]),
                    ),
                  ],
                ),
              ),
            ]));
  }
}

// ***************** chart library ***************
// ***************** chart library ***************
class SelectionCallbackExample extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate = true;
  static String pointerValue;

  //SelectionCallbackExample({ Key key }) : super(key: key);

  SelectionCallbackExample(this.seriesList, {Key key}) : super(key: key);

  factory SelectionCallbackExample.withData(seriesList1) {
    //log.d(seriesList1);

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

class yieldData {
  final DateTime date;
  final double total;

  //final String total;
  //final double nifty;

  yieldData(this.date, this.total);
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

  Future<Null> _analyticsGraphInteractionEvent() async {
    // log.d("\n analyticsGraphInteractionEvent called \n");
    await FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_chart_scenario_clicking",
      'content_type': "click_chart",
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: PlatformCheck.isSmallScreen(context) ? 155.0 : 280,
        child: !kIsWeb
            ? ShaderMask(
                child: simpleLineChartChild(),
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green,
                      Colors.white,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
              )
            : simpleLineChartChild());
  }

  Widget simpleLineChartChild() {
    _analyticsGraphInteractionEvent();
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      layoutConfig: charts.LayoutConfig(
        leftMarginSpec: charts.MarginSpec.fixedPixel(0),
        topMarginSpec: charts.MarginSpec.fixedPixel(0),
        rightMarginSpec: charts.MarginSpec.fixedPixel(0),
        bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
      ),

      /* domainAxis: new charts.NumericAxisSpec(

						// Make sure that we draw the domain axis line.
						showAxisLine: true,
						// But don't draw anything else.
						renderSpec: new charts.SmallTickRendererSpec(
								labelStyle: new charts.TextStyleSpec(
								fontSize: 18, // size in Pts.
								color: charts.MaterialPalette.black),
						)), */

      domainAxis: new charts.DateTimeAxisSpec(
        showAxisLine: false,
        //renderSpec: new charts.NoneRenderSpec(),
        renderSpec: charts.GridlineRendererSpec(
          /* axisLineStyle: charts.LineStyleSpec(
							color: charts.MaterialPalette.black, // this also doesn't change the Y axis labels
						), */
          labelStyle: new charts.TextStyleSpec(
              fontSize: 10,
              color: charts.ColorUtil.fromDartColor(Color((0xffa5a5a5)))),
          /* lineStyle: charts.LineStyleSpec(
							thickness: 0,
							color: charts.Color.fromHex(code: "#0F52BA")
						) */
          lineStyle: new charts.LineStyleSpec(
              color: charts.Color.fromHex(code: "#ffffff")),
        ),
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
              fontSize: 10,
              color: charts.ColorUtil.fromDartColor(
                  Color((0xffa5a5a5))), // .fromHex(code: "#ffffff"),
            ),
            lineStyle: new charts.LineStyleSpec(
                dashPattern: [10, 5],
                color: charts.Color.fromHex(
                    code: "#ffffff") //charts.MaterialPalette.white // #dadada
                )),
      ),

      /* selectionModels: [
							new charts.SelectionModelConfig(
								type: charts.SelectionModelType.info,
								changedListener: _infoSelectionModelUpdated)
						], */
      selectionModels: [
        charts.SelectionModelConfig(
          changedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue = DateFormat("MMM dd, yyyy").format(
                        DateTime.parse(datumPair.datum.date.toString())) +
                    "\nValue: " +
                    _formatMoney(datumPair.datum.total.round());
              });
            }
          },
          updatedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue = DateFormat("MMM dd, yyyy").format(
                        DateTime.parse(datumPair.datum.date.toString())) +
                    "\nValue: " +
                    _formatMoney(datumPair.datum.total.round());
              });
            }
          },
        ),
      ],
      behaviors: [
        charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tapAndDrag),
        charts.LinePointHighlighter(
          showHorizontalFollowLine:
              charts.LinePointHighlighterFollowLineType.all,
          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.all,
          symbolRenderer: CustomCircleSymbolRenderer(),
        ),
        charts.InitialSelection(
          selectedDataConfig: [
            new charts.SeriesDatumConfig<DateTime>(
              'Goal Term',
              (seriesList.last.data.last as yieldData).date,
            )
          ],
          shouldPreserveSelectionOnDraw: true,
        ),
      ],
    );
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

class ClampingBehaviour extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}
