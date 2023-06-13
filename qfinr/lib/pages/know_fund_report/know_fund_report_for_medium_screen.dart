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
import 'package:qfinr/pages/analyse/details/common_widgets_analyse_details.dart';
import 'package:qfinr/pages/know_fund_detail/know_fund_detail_for_medium_screen.dart';
import 'package:qfinr/pages/know_fund_report/components/know_fund_report_components.dart';
import 'package:qfinr/pages/manage_portfolio/large_controller_switch.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/main_model.dart';
import '../../utils/text_with_drop_down_button.dart';
import '../../widgets/widget_common.dart';

final key = new GlobalKey<_SelectionCallbackState>();
final log = getLogger('KnowFundReportForLargeScreen');

class KnowFundReportForMediumScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Map<String, dynamic> responseData;

  KnowFundReportForMediumScreen(this.model,
      {this.analytics, this.observer, this.responseData});

  @override
  State<StatefulWidget> createState() {
    return _KnowFundReportForMediumScreenState();
  }
}

class _KnowFundReportForMediumScreenState
    extends State<KnowFundReportForMediumScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final controller = ScrollController();

  bool _loading = false;
  bool widgetExpanded = false;
  bool widgetExpandedRating = false;

  Map fundData;

  String _selectedMarket;
  String _performanceTenure = "3year";
  List<Map<String, String>> markets = [];
  Map<String, String> _selectedMarketOption;

  String chartType = "chart";
  TabController _tabController;

  int tabIndex = 0;

  List<Map<String, String>> ricInfoList = [];
  Map<String, dynamic> ricInfo = {};

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

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 1, vsync: this, initialIndex: tabIndex);
    fundData = widget.responseData['response']['portfolioData'][0];

    var graphData = widget
        .responseData['response']['navGraphData']['graphData'].entries
        .toList();
    _selectedMarket = graphData[0].key;

    widget.responseData['response']['navGraphData']['markets']
        .forEach((key, value) {
      markets.add({"value": key, "title": value});
    });

    if (widget.responseData['response']['ricInfo']['about'] != null &&
        widget.responseData['response']['ricInfo']['about'] != "") {
      ricInfo = widget.responseData['response']['ricInfo']['about'];

      ricInfo.forEach((key, value) {
        ricInfoList.add({"key": key.toString(), "value": value.toString()});
      });
    }

    _currentScreen();
    _addEvent();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return PageWrapper(
        child: Scaffold(
          key: _scaffoldKey,
          // backgroundColor: KnowFundReportStyles.backgroundColor,
          drawer: WidgetDrawer(),
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      );
    });
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
      child: NavigationTobBar(
        widget.model,
        openDrawer: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  Widget _buildBody() {
    return PageWrapper(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftMenu(),
          _buildBodyChild(),
        ],
      ),
    );
  }

  _buildLeftMenu() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return deviceType == DeviceScreenType.tablet
        ? SizedBox()
        : NavigationLeftBar(
            isSideMenuHeadingSelected: 3,
            isSideMenuSelected: 7,
          );
  }

  Widget _buildBodyChild() {
    return Expanded(
      child: _loading ? preLoader() : _buidChildView(),
    );
  }

  SingleChildScrollView _buidChildView() {
    return SingleChildScrollView(
      child: Container(
        color: Color(0xfff5f6fa),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
            left: 27.0,
            right: 60.0,
            bottom: 20.0,
          ),
          child: _buildFundReportContent(),
        ),
      ),
    );
  }

  Widget _buildFundReportContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fundInfo(),
        SizedBox(height: 10),
        _buildScoreAndGraph(),
        SizedBox(height: 15.0),
        _buildDescription(),
        SizedBox(height: 15.0),
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
          child: _buildBodyContent(),
        ),
        _buildTabs(),
      ],
    );
  }

  Widget _buildScoreAndGraph() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisScore(),
          SizedBox(height: 30),
          _buildGraphNav(),
        ],
      ),
    );
  }

  Widget _fundInfo() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: (widget.responseData['response']['ric_type'] == "Funds"
                          ? "Fund"
                          : widget.responseData['response']['ric_type']) +
                      " Analysis",
                  style: headline1,
                ),
                TextSpan(
                  text: " of " + fundData['name'],
                  style: keyStatsBodyText7,
                ),
              ],
            ),
          ),
          Text(
            widget.responseData['response']['benchmark_name'] != ""
                ? ("against " +
                    widget.responseData['response']['benchmark_name'] +
                    " Index")
                : "No benchmark available",
            style: keyStatsBodyText7,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisScore() {
    List<Widget> ratingChildren = [
      Container(
        padding: EdgeInsets.only(
          top: getScaledValue(15),
          right: getScaledValue(12),
        ),
        alignment: Alignment.centerRight,
        child: Text(
          "1 - Low  |  5 - High ",
          style: bodyText9,
        ),
      ),
    ];

    if (widget.responseData['response']['type'] == "fund") {
      ratingChildren.add(
        widgetRatingLarge(
          context: context,
          title: 'Return Rating',
          description:
              "We rate the fund within its category on the quality of its returns",
          score: fundData['tr_rating'],
        ),
      );
      ratingChildren.add(
        widgetRatingLarge(
          context: context,
          title: 'Expense Rating',
          description:
              "We compare the fund’s expenses against other funds in the same category to arrive at this rating",
          score: fundData['ter_rating'],
        ),
      );
      ratingChildren.add(
        widgetRatingLarge(
          context: context,
          title: 'Alpha Rating',
          description:
              "We look for statistical evidence of alpha generation against the fund’s benchmark, where available, and equivalent market exposures. We run a series of regressions using 3 years data and aggregate the information into this score",
          score: fundData['alpha_rating'],
        ),
      );
      ratingChildren.add(SizedBox(
        height: getScaledValue(24),
      ));
      ratingChildren.add(
        widgetRiskRatingLarge(
          context: context,
          title: 'Risk Rating',
          description:
              "This is a synthetic risk return indicator based on the realized volatility of the fund. We use 3 year information to categorize the risk of the fund into 7 categories, with 7 being the most volatile and 1 the least volatile",
          score: fundData['srri_rating'],
        ),
      );
    } else {
      ratingChildren.add(
        widgetRatingLarge(
          context: context,
          title: 'Tracking Error',
          description:
              "This is a measure of the closeness of movements between the ETF/Index fund and its corresponding benchmark. Higher the rating, the closer the two",
          score: fundData['tracking_rating'],
        ),
      );
      ratingChildren.add(
        widgetRatingLarge(
          context: context,
          title: 'Expense Rating',
          description:
              "This is a measure of how cheap an ETF/Index fund is compared to all other ETFs and Index Funds that track the same benchmark. The higher the rating, the cheaper is the ETF/Index fund",
          score: fundData['ter_rating'],
        ),
      );
      ratingChildren.add(
        widgetRatingLarge(
          context: context,
          title: 'Trading Rating',
          description:
              "This is a measure of how easily and cheaply one can buy or sell an ETF/Index fund. Higher the rating, the more the ability to execute a transaction",
          score: fundData['tradability_rating'],
        ),
      );
      ratingChildren.add(SizedBox(
        height: getScaledValue(24),
      ));
      ratingChildren.add(
        widgetRiskRatingLarge(
          context: context,
          title: 'Risk Rating',
          description:
              "This is a synthetic risk return indicator based on the realized volatility of the fund. We use 3 year information to categorize the risk of the fund into 7 categories, with 7 being the most volatile and 1 the least volatile",
          score: fundData['srri_rating'],
        ),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 1.0,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color(0xffe9e9e9),
                width: getScaledValue(1),
              ),
              borderRadius: BorderRadius.circular(
                getScaledValue(4),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getScaledValue(16),
                    vertical: getScaledValue(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Overall Score",
                            style: headline7_analyse,
                          ),
                          SizedBox(width: getScaledValue(5)),
                          Tooltip(
                            padding: EdgeInsets.all(10),
                            textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                            message: widget.responseData['response']['type'] ==
                                    "fund"
                                ? "Overall Rating\nWe rate your portfolio on a proprietary 5 point scale using 3 year historical data across 3 areas: suitability compared to your risk profile, portfolio performance compared to your chosen benchmark and key statistical measures like information ratio and success ratio"
                                : "Overall Rating\nWe rate ETFs and Index funds on a proprietary 5 point scale using information across three areas: how closely the ETFs/Index funds track the underlying benchmark, how well traded they are, and how cheap they are compared to others",
                            child: InkWell(
                              onTap: () => bottomAlertBoxLargeAnalyse(
                                  context: context,
                                  title: "Overall Rating",
                                  description: widget.responseData['response']
                                              ['type'] ==
                                          "fund"
                                      ? "We rate your portfolio on a proprietary 5 point scale using 3 year historical data across 3 areas: suitability compared to your risk profile, portfolio performance compared to your chosen benchmark and key statistical measures like information ratio and success ratio"
                                      : "We rate ETFs and Index funds on a proprietary 5 point scale using information across three areas: how closely the ETFs/Index funds track the underlying benchmark, how well traded they are, and how cheap they are compared to others"),
                              child: svgImage(
                                'assets/icon/information.svg',
                                width: getScaledValue(9),
                              ),
                            ),
                          )
                        ],
                      ),
                      fundData['data'].containsKey('latest_date') &&
                              fundData['data']['latest_date'] != null
                          ? Text("As on " + fundData['data']['latest_date'],
                              style: bodyText8)
                          : emptyWidget
                    ],
                  ),
                ),
                SizedBox(height: getScaledValue(2)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: starScore(score: fundData['overall_rating']),
                ),
                SizedBox(height: 10),
                Divider(height: getScaledValue(5)),
                SizedBox(
                  child: Column(
                    children: ratingChildren,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildGraphNav() {
    List<charts.Series<TimeSeriesSales, DateTime>> chartData = chartDataList();

    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xffe9e9e9),
          width: getScaledValue(1),
        ),
        borderRadius: BorderRadius.circular(
          getScaledValue(4),
        ),
      ),
      padding: EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              chartType == "chart"
                  ? TextWithDropDown(
                      "PERFORMANCE VS ",
                      widget.responseData['response']['navGraphData']['markets']
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
                  //       style: appGraphTitle,
                  //       text: ("PERFORMANCE VS "),
                  //       children: [
                  //         markets.length > 1
                  //             ? TextSpan(
                  //                 text: widget.responseData['response']
                  //                         ['navGraphData']['markets']
                  //                     [_selectedMarket],
                  //                 style: appGraphTitle.copyWith(
                  //                     color: colorBlue),
                  //                 recognizer: TapGestureRecognizer()
                  //                   ..onTap = () => buildSelectBoxCustom(
                  //                         context: context,
                  //                         value: _selectedMarket,
                  //                         title: 'Select benchmark',
                  //                         options: markets,
                  //                         onChangeFunction:
                  //                             marketSelectChange,
                  //                       ),
                  //               )
                  //             : TextSpan(
                  //                 text: widget.responseData['response']
                  //                         ['navGraphData']['markets']
                  //                     [_selectedMarket],
                  //                 style: appGraphTitle,
                  //               ),
                  //         markets.length > 1
                  //             ? WidgetSpan(
                  //                 child: Icon(
                  //                   Icons.keyboard_arrow_down,
                  //                   color: colorBlue,
                  //                   size: 14,
                  //                 ),
                  //               )
                  //             : WidgetSpan(child: emptyWidget),
                  //       ],
                  //     ),
                  //   )
                  : Text(
                      "Value over time".toUpperCase(),
                      style: appGraphTitle,
                    ),
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
                },
              ),
            ],
          ),
          SizedBox(height: getScaledValue(25.0)),
          SelectionCallbackExample(chartData, key: key),
          SizedBox(height: getScaledValue(25.0)),
          _basketPerformanceBtns(context),
        ],
      ),
    );
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
      minWidth: getScaledValue(80),
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
                  width: getScaledValue(2),
                  color: Color(0xff034bd9),
                )
              : BorderSide(
                  width: getScaledValue(1),
                  color: Color(0xffe9e9e9),
                ),
          top: BorderSide(
            width: getScaledValue(1),
            color: Color(0xffe9e9e9),
          ),
          left: BorderSide(
            width: index == "3year" ? getScaledValue(1) : getScaledValue(0),
            color: Color(0xffe9e9e9),
          ),
          right: BorderSide(
            width: getScaledValue(1),
            color: Color(0xffe9e9e9),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    List<Widget> _doPointers = [];
    List<Widget> _dontPointers = [];

    for (int i = 0; i <= 5; i++) {
      if (fundData['data'].isNotEmpty &&
          fundData['data']['w' + i.toString()] != "" &&
          fundData['data']['w' + i.toString()] != null &&
          fundData['data']['w' + i.toString()] != "nan")
        _doPointers.add(
          KnowFundReportComponents.bulletPointer(
            fundData['data']['w' + i.toString()],
            bulletColor: colorBlue,
          ),
        );

      if (fundData['data'].isNotEmpty &&
          fundData['data']['nw' + i.toString()] != "" &&
          fundData['data']['nw' + i.toString()] != null &&
          fundData['data']['nw' + i.toString()] != "nan")
        _dontPointers.add(
          KnowFundReportComponents.bulletPointer(
            fundData['data']['nw' + i.toString()],
            bulletColor: colorBlue,
          ),
        );
    }

    return _doPointers.isNotEmpty && _dontPointers.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(top: getScaledValue(8)),
            padding: EdgeInsets.symmetric(
              horizontal: getScaledValue(16),
              vertical: getScaledValue(24),
            ),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _doPointers.isNotEmpty
                    ? _buildDoDescription(_doPointers)
                    : emptyWidget,
                _dontPointers.isNotEmpty
                    ? _buildDontDscription(_dontPointers)
                    : emptyWidget,
              ],
            ),
          )
        : emptyWidget;
  }

  Expanded _buildDoDescription(List<Widget> _doPointers) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("What works", style: appBodyH3),
          SizedBox(height: getScaledValue(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _doPointers,
          ),
        ],
      ),
    );
  }

  Expanded _buildDontDscription(List<Widget> _dontPointers) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "What does not work",
            style: appBodyH3,
          ),
          SizedBox(height: getScaledValue(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _dontPointers,
          ),
        ],
      ),
    );
  }

// NEW ONE

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

  Widget _buildBodyContent() {
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
          //           width: MediaQuery.of(context).size.width * 0.15,
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
        
          // SizedBox(height: 6,),
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
                          width: MediaQuery.of(context).size.width * 0.15,
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

  PreferredSize _buildTabs() {
    return PreferredSize(
      preferredSize: Size(
        MediaQuery.of(context).size.width,
        500,
      ),
      child: KnowFundDetailForMediumScreen(
        widget.model,
        analytics: widget.analytics,
        observer: widget.observer,
        responseData: widget.responseData,
        tabIndex: 0,
      ),
    );
  }

  Widget listPortfolios() {
    List<Widget> _children = [];

    double containerHeight = 220;
    if (widgetExpandedRating) containerHeight += 260;

    _children.add(Container(
      height: getScaledValue(containerHeight),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
              height: getScaledValue(widgetExpanded ? 185 : 135.0),
              padding: EdgeInsets.symmetric(
                  horizontal: getScaledValue(16),
                  vertical: getScaledValue(10.0)),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (widget.responseData['response']['ric_type'] == "Funds"
                            ? "Fund"
                            : widget.responseData['response']['ric_type']) +
                        " Analysis",
                    style: headline1,
                  ),
                  Text("of " + fundData['name'], style: keyStatsBodyText7),
                  Text(
                    widget.responseData['response']['benchmark_name'] != ""
                        ? ("against " +
                            widget.responseData['response']['benchmark_name'] +
                            " Index")
                        : "No benchmark available",
                    style: keyStatsBodyText7,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: 105,
              left: getScaledValue(15.0),
              width: getScaledValue(330.0),
              height: getScaledValue(widgetExpandedRating ? 400 : 115.0),
              child: _buildAnalysisScore()),
        ],
      ),
    ));

    _children.add(sectionSeparator());
    _children.add(_buildGraphNav());
    _children.add(sectionSeparator());

    _children.add(_buildDescription());
    _children.add(sectionSeparator());
    _children.add(tools());
    _children.add(sectionSeparator());

    return ListView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      children: _children,
    );
  }

  Widget graph() {
    return Container(
        padding: EdgeInsets.only(
            left: getScaledValue(16.0),
            right: getScaledValue(16.0),
            bottom: getScaledValue(20.0)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Past scores', style: appBodyH3),
                GestureDetector(
                  onTap: () => {},
                  child: Text('How is it calculated?', style: appBenchmarkLink),
                )
              ],
            ),
            SizedBox(height: getScaledValue(10)),
            SimpleLineChart(fixGraphData()),
          ],
        ));
  }

  List<charts.Series<yieldData, DateTime>> fixGraphData() {
    final List<yieldData> yieldDb = [
      yieldData(DateTime.parse('2020-05-24'),
          double.parse(fundData['overall_rating']) * 2),
      yieldData(DateTime.parse('2020-06-24'),
          double.parse(fundData['overall_rating']) * 2),
      yieldData(DateTime.parse('2020-07-24'),
          double.parse(fundData['overall_rating']) * 2),
      yieldData(DateTime.parse('2020-08-24'),
          double.parse(fundData['overall_rating']) * 2),
      yieldData(DateTime.parse('2020-09-24'),
          double.parse(fundData['overall_rating']) * 2),
    ];

    return [
      charts.Series<yieldData, DateTime>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xff787878))),
        domainFn: (yieldData sales, _) => sales.date,
        measureFn: (yieldData sales, _) => sales.total,
        data: yieldDb,
      )
    ];
  }

  Widget tools() {
    return Container(
        margin: EdgeInsets.only(top: getScaledValue(8)),
        padding: EdgeInsets.symmetric(vertical: getScaledValue(24)),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            toolShortcut("assets/icon/icon_analyzer_summary.svg", "Summary",
                "Fund top 10 holdings; breakdown by Sector, Asset Type, and Currency; and last 6 months total net assets",
                navigation: "/knowFundDetail/0"),
            toolShortcut(
                "assets/icon/icon_analyzer_stats.svg",
                "Key Statistics",
                "Returns, risks, success rates, draw-downs, sensitivities, and more....",
                navigation: "/knowFundDetail/1"),
            toolShortcut(
                "assets/icon/icon_analyzer_performance.svg",
                "Performance Comparison",
                "Rolling returns and risk-reward comparison with benchmarks and most popular ETFs....",
                navigation: "/knowFundDetail/2"),
            toolShortcut(
                "assets/icon/icon_analyzer_suitability.svg",
                "Risk Tracker",
                "Maximum exposure to this portfolio suitable for you, based on your specific risk tolerance limits....",
                navigation: "/knowFundDetail/3"),
            toolShortcut("assets/icon/icon_stress_test.svg", "Stress Test",
                "Compare the performance of the fund against multiple benchmarks during high-stress periods in history",
                navigation: "/knowFundDetail/4"),
          ],
        ));
  }

  Widget toolShortcut(String imgPath, String title, String description,
      {String navigation = "", bool alertType = false}) {
    return GestureDetector(
        onTap: () {
          if (navigation != "") {
            Navigator.pushNamed(context, navigation,
                    arguments: {'responseData': widget.responseData})
                .then((_) => changeStatusBarColor(Colors.white));
          }
        },
        child: widgetCard(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Container(
                child: svgImage(
                  imgPath,
                  width: getScaledValue(19),
                ),
              ),
              SizedBox(width: getScaledValue(15)),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: alertType
                          ? appBodyText1.copyWith(color: Color(0xff707070))
                          : appBodyH3),
                  alertType
                      ? Divider(
                          height: 20,
                          color: Color(0xffededed),
                        )
                      : emptyWidget,
                  Text(description,
                      style: appBodyText1.copyWith(color: Color(0xff707070)))
                ],
              )),
              Icon(Icons.chevron_right),
            ])));
  }

  Widget actionButtons() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: getScaledValue(17), horizontal: getScaledValue(15)),
      child: Row(
        children: <Widget>[
          Expanded(child: flatButtonText("RETAKE", borderColor: colorBlue)),
          SizedBox(width: getScaledValue(20)),
          Expanded(
              child: gradientButton(
                  context: context, caption: "mail", onPressFunction: () => {}))
        ],
      ),
    );
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
      id: 'Fund',
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
      id: 'Fund',
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: portfolioData,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xffff7005))),
    ));

    return chartDataList;
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

                  if (model.selectedDatum[0].series.id == "Fund") {
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
