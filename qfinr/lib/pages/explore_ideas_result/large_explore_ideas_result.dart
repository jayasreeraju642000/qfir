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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio/add_portfolio_styles.dart';
import 'package:qfinr/pages/explore_ideas/small_explore_ideas.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('ExploreIdeasResultScreen');

class LargeExploreIdeasResultScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final List<Filter> selectedFilter;

  LargeExploreIdeasResultScreen(this.model,
      {this.analytics, this.observer, this.selectedFilter});

  @override
  _LargeExploreIdeasResultScreenState createState() =>
      _LargeExploreIdeasResultScreenState();
}

class _LargeExploreIdeasResultScreenState
    extends State<LargeExploreIdeasResultScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _bubbleChildren;
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

  Widget _timePeriodForWeb() => Text(
        "${DateFormat('dd MMM, yyyy').format(stockIdeaResponse.response.stats.start)} - ${DateFormat('dd MMM, yyyy').format(stockIdeaResponse.response.stats.end)}",
        style: PlatformCheck.isSmallScreen(context)
            ? bodyText5
            : bodyText5.copyWith(
                fontSize: ScreenUtil().setSp(12.0),
              ),
      );

  Widget _nextRebalanceTextForWeb() => Text(
        "Next rebalance date on ${DateFormat('dd-MMM-yyyy').format(stockIdeaResponse.response.latestPortfolioDate)}",
        style:
            bodyText3.apply(color: Color(0xff8b8b8b), letterSpacingDelta: -1),
      );

  Widget _performanceGraphWidgetForWeb() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 30),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GraphData>(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                ),
                hint: Container(
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: appGraphTitle,
                      text: ("PERFORMANCE VS "),
                      children: [
                        TextSpan(
                          text: selectedGraphData.marketName,
                          style: appGraphTitle.copyWith(
                            color: AppColor.colorBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                selectedItemBuilder: (context) {
                  return stockIdeaResponse.response.graphData
                      .map<Widget>((GraphData item) {
                    return Container(
                      alignment: Alignment.center,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: appGraphTitle,
                          text: ("PERFORMANCE VS "),
                          children: [
                            TextSpan(
                              text: selectedGraphData.marketName,
                              style: appGraphTitle.copyWith(
                                color: AppColor.colorBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                },
                value: selectedGraphData,
                items:
                    stockIdeaResponse.response.graphData.map((GraphData item) {
                  return DropdownMenuItem<GraphData>(
                    value: item,
                    child: Text(
                      item.marketName,
                      style: appGraphTitle,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  _analyticsSelectBenchMarkEvent();
                  marketSelectChange(value);
                },
              ),
            ),
          ),
          Container(
              height: 200,
              child: SelectionCallbackExample(
                  sampleChartData(selectedGraphData),
                  key: key)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(color: Color((0xffff7005))),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 16),
                  child: Text(
                    "Portfolio",
                    style: bodyText7.copyWith(
                        color: Color(0xff474747), fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(color: Color(0xffc0c0c0)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 16),
                  child: Text(
                    selectedGraphData.marketName,
                    style: bodyText7.copyWith(
                        color: Color(0xff474747), fontWeight: FontWeight.w800),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _basketPerformanceBtns(context),
          )
        ],
      );

  Widget _currentHoldingsWidgetForWeb() => Container(
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
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      PlatformCheck.isSmallScreen(context)
                          ? "Name"
                          : "Name".toUpperCase(),
                      style: bodyText7,
                    ),
                    Text(
                      PlatformCheck.isSmallScreen(context)
                          ? "Weightage"
                          : "Weightage".toUpperCase(),
                      style: bodyText7,
                    )
                  ],
                ),
              ),
            ),
            ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children:
                    stockIdeaResponse.response.portfolios.stockData.map((e) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16) +
                        EdgeInsets.only(
                            top: stockIdeaResponse.response.portfolios.stockData
                                        .indexOf(e) ==
                                    0
                                ? 16
                                : 0,
                            bottom: stockIdeaResponse
                                        .response.portfolios.stockData
                                        .indexOf(e) ==
                                    stockIdeaResponse.response.portfolios
                                            .stockData.length -
                                        1
                                ? 16
                                : 0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                e.name,
                                style: bodyText6,
                              )),
                              Text(
                                "${roundDouble(e.weightage)}%",
                                style: PlatformCheck.isSmallScreen(context)
                                    ? bodyText3.apply(
                                        color: Color(0xff818181),
                                        fontWeightDelta: 2,
                                      )
                                    : bodyText3.copyWith(
                                        color: Color(0xff383838),
                                        fontWeight: FontWeight.w600,
                                        fontSize: ScreenUtil().setSp(14.0),
                                      ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 4),
                                      child: Text(
                                        "Stocks".toUpperCase(),
                                        style: bodyText7,
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Color(0xffbcbcbc),
                                      ),
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: widgetZoneFlag(e.zone))
                              ],
                            ),
                          ),
                          stockIdeaResponse.response.portfolios.stockData
                                      .indexOf(e) !=
                                  stockIdeaResponse.response.portfolios
                                          .stockData.length -
                                      1
                              ? Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
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
      );

  Widget _pastPerformanceAnalysisWidgetForWeb() => Container(
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
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                      padding: EdgeInsets.only(left: getScaledValue(35)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bwReturn(
                                  title: "1 Day Return",
                                  value:
                                      stockIdeaResponse.response.stats.bestDay),
                              _bwReturn(
                                  title: "1 Day Return",
                                  value:
                                      stockIdeaResponse.response.stats.worstDay,
                                  leftPadding: getScaledValue(35))
                            ],
                          ),
                        ),
                        divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bwReturn(
                                  title: "1 Month Return",
                                  value: stockIdeaResponse
                                      .response.stats.bestMonth),
                              _bwReturn(
                                  title: "1 Month Return",
                                  value: stockIdeaResponse
                                      .response.stats.worstMonth,
                                  leftPadding: getScaledValue(35)),
                            ],
                          ),
                        ),
                        divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bwReturn(
                                  title: "1 Year Return",
                                  value: stockIdeaResponse
                                      .response.stats.bestYear),
                              _bwReturn(
                                  title: "1 Year Return",
                                  value: stockIdeaResponse
                                      .response.stats.worstYear,
                                  leftPadding: getScaledValue(35)),
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
      );

  @override
  Widget build(BuildContext context) {
    _bubbleChildren = selectedFilterText
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
                      style: widgetBubbleTextStyle.copyWith(
                        color: AppColor.statusTextColor,
                        fontSize: 9,
                      ),
                      // style: widgetBubbleTextStyle.apply(
                      //     color: AppColor.statusTextColor),
                    ),
                  ),
                ),
              ),
            ))
        .toList();
    //_bubbleChildren.add();
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
    return PageWrapper(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: WidgetDrawer(),
        backgroundColor: Colors.white,
        body: _body(),
      ),
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

  ////////////////////////////////////////////

  Widget _body() {
    return _buildBodyContent();
  }

  Widget _buildBodyContent() {
    return _largeScreenBody();
  }

  Widget _largeScreenBody() => Column(
        children: [
          _buildTopBar(),
          _bodyContents(),
        ],
      );

  Widget _buildTopBar() => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        child: NavigationTobBar(
          widget.model,
          openDrawer: () => _scaffoldKey.currentState.openDrawer(),
        ),
      );

  Widget _bodyContents() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Expanded(
      child: Row(
        children: [
          deviceType == DeviceScreenType.tablet
              ? SizedBox()
              : NavigationLeftBar(
                  isSideMenuHeadingSelected: 3, isSideMenuSelected: 6),
          _buildExploreIdeas2ForWeb(),
        ],
      ),
    );
  }

  Widget _buildExploreIdeas2ForWeb() => Expanded(
      child: !widget.model.isLoading && stockIdeaResponse != null
          ? Container(
              height: MediaQuery.of(context).size.height,
              color: Color(0xfff5f6fa),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_left,
                              color: colorBlue,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.pop(context);
                                //  Navigator.pop(context);
                              },
                              child: Text(
                                "Back",
                                style: AddPortfolioStyles.blueLinkTextBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _headingRow(),
                      _bodyContainer(),
                      _pastPerformanceAnalysisContainer(),
                    ],
                  ),
                ),
              ),
            )
          : preLoader(
              title:
                  'Crunching data for your request\nThis will take a couple of minutes. Please remain patient...'));

  Widget _pastPerformanceAnalysisContainer() => Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Material(
          elevation: 2.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      //  color: Colors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PAST PERFORMANCE ANALYSIS".toUpperCase(),
                            style: appGraphTitle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text("TIME PERIOD",
                                style: keyStatsBodyText1.copyWith(
                                  fontSize: ScreenUtil().setSp(12.0),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: _timePeriodForWeb(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: _pastPerformanceAnalysisWidgetForWeb(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xffbcbcbc),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                topLeft: Radius.circular(4),
                              )),
                          child: Container(
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
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xffbcbcbc),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              )),
                          child: Container(
                            child: Column(children: [
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
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _bodyContainer() => Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Material(
          elevation: 2.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Column(
                children: [
                  _setPreferencesText(),
                  _selectedPreferences(),
                  _divider(),
                  _currentHoldingsAndPerformanceWidget(),
                  _nextRebalanceDateText(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _nextRebalanceDateText() => Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _nextRebalanceTextForWeb(),
          ],
        ),
      );

  Widget _currentHoldingsAndPerformanceWidget() => Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Container(
                height: 350,
                //  color: Colors.orange,
                child: Column(
                  children: [
                    _currentHoldingsText(),
                    Expanded(
                      child: SingleChildScrollView(
                          child: _currentHoldingsWidgetForWeb()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Container(
                height: 350,
                // color: Colors.blue,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                          child: _performanceGraphWidgetForWeb()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Widget _currentHoldingsText() => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "CURRENT HOLDINGS".toUpperCase(),
              style: appGraphTitle,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0),
            //   child: Text(
            //     "23 stocks",
            //     style: keyStatsBodyText1.copyWith(fontSize: ScreenUtil().setSp(12.0),),
            //   ),
            // ),
          ],
        ),
      );

  Widget _setPreferencesText() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text("Selected Preferences".toUpperCase(),
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(16.0),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'nunito',
                    letterSpacing: 0.19,
                    color: Color(0xffa5a5a5))),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 8.0, right: 15.0),
          //   child: Text("Change", style: header_nav_left_blue.copyWith(fontWeight: FontWeight.w600, fontSize: ScreenUtil().setSp(12.0),)),
          // )
        ],
      );

  Widget _divider() => Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: Divider(
          thickness: 1,
          color: Color(0xFFe9e9e9),
        ),
      );

  Widget _selectedPreferences() => Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          height: 26,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _bubbleChildren,
          ),
        ),
      );

  Widget _headingRow() => Row(
        children: [
          _headingText(),
          _addToWatchListButton(),
        ],
      );

  Widget _addToWatchListButton() => Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              width: 175,
              child: ElevatedButton(
                  style: qfButtonStyle(
                      ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
                  child: Ink(
                    width: MediaQuery.of(context).size.width,
                    height: 33,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff0941cc), Color(0xff0055fe)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 50),
                      alignment: Alignment.center,
                      child: Text(
                        "ADD TO WATCHLIST",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _analyticsAddtoWatchListEvent();
                    Navigator.pushNamed(context, '/add_portfolio_discover',
                        arguments: {
                          'portfolios':
                              stockIdeaResponse.response.portfolios.stockData,
                          'latestRebalanceDate':
                              stockIdeaResponse.response.latestPortfolioDate
                        });
                  })),
        ],
      ));

  Widget _headingText() => Text(
        Contants.SCREENER_SUMMARY,
        style: TextStyle(
          color: Color(0xff282828),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
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
