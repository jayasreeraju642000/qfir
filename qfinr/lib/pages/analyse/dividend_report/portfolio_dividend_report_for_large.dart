import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/pages/analyse/dividend_report/dividend_report_styles.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/main_model.dart';
import '../../../widgets/widget_common.dart';

final log = getLogger('PortfolioDividendReport');

class PortfolioDividendReportLarge extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Map responseData;

  PortfolioDividendReportLarge(this.model,
      {this.analytics, this.observer, this.responseData});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioDividendReportState();
  }
}

class _PortfolioDividendReportState extends State<PortfolioDividendReportLarge>
    with SingleTickerProviderStateMixin {
  final controller = ScrollController();
  String _dividendTenure = "";
  String _selectedMonthGraph = "in";
  Map dividendDetails = {};

  TabController _tabController;
  int tabIndex = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String sortType = "nameBase";
  String sortListType = "Name";

  String sortOrder = "asc";
  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Dividend Page',
        screenClassOverride: 'PortfolioDividend');
  }

  List dividendData = [];
  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Dividend Page",
    });
  }

  Future<Null> _analyticsFilterChangeEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "dividend_forcast",
      'item_name': "dividend_forcast_filter",
      'content_type': "click_filter_button",
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: tabIndex);

    _analyticsCurrentScreen();
    _analyticsAddEvent();
    _selectedMonthDividend();
  }

  _selectedMonthDividend() {
    if (tabIndex == 0) {
      if (!_checkIfDataIsEmpty(widget.responseData['response']['cashFlows']
          ['dividends']['graphData'])) {
        dividendDetails = widget.responseData['response']['cashFlows']
            ['dividends']['graphData']['dividendDetails'];

        for (var value in widget.responseData['response']['cashFlows']
            ['dividends']['graphData']['graphValue']) {
          _selectedMonthGraph = value[0];
          _dividendTenure = value[0];

          break;
        }
      }
    } else if (tabIndex == 1) {
      if (!widget
          .responseData['response']['cashFlows']['bonds']['graphData']
              ['graphValue']
          .isEmpty) {
        dividendDetails = widget.responseData['response']['cashFlows']['bonds']
            ['graphData']['dividendDetails'];

        for (var value in widget.responseData['response']['cashFlows']['bonds']
            ['graphData']['graphValue']) {
          _selectedMonthGraph = value[0];
          _dividendTenure = value[0];
          break;
        }
      }
    } else {
      if (!widget
          .responseData['response']['cashFlows']['deposits']['graphData']
              ['graphValue']
          .isEmpty) {
        dividendDetails = widget.responseData['response']['cashFlows']
            ['deposits']['graphData']['dividendDetails'];

        for (var value in widget.responseData['response']['cashFlows']
            ['deposits']['graphData']['graphValue']) {
          _selectedMonthGraph = value[0];
          _dividendTenure = value[0];
          break;
        }
      }
    }
  }

  _checkIfDataIsEmpty(responseData) {
    return responseData != null && responseData.isEmpty;
  }

  PreferredSizeWidget tabbar() {
    List<Widget> tabChildren = [];
    tabChildren.add(Tab(text: "Stocks")); //(dividends)
    tabChildren.add(Tab(text: "Bonds"));
    tabChildren.add(Tab(text: "Deposits"));

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
        log.d(index);
        setState(() {
          tabIndex = index;
          _selectedMonthDividend();
        });
      },
      tabs: tabChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.responseData['response']['graphData'].isEmpty) {
    //   changeStatusBarColor(Colors.white);
    // } else {
    //   changeStatusBarColor(Color(0xffefd82b));
    // }

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
              body: _buildBodyNvaigationLeftBar()));
    });
  }

  Widget _buildBody(BuildContext context, responseData) {
    //
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
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(
              vertical: getScaledValue(18),
              horizontal: getScaledValue(30),
            ),
            color: Colors.white,
            child: _buildBodyContent(context, responseData),
          ))
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, responseData) {
    Widget child;

    if (tabIndex == 0) {
      child = _checkIfDataIsEmpty(
              responseData['response']['cashFlows']['dividends']['graphData'])
          ? _buildBodyEmptyList(context)
          : _buildBodyContentLarge(
              context, 0, responseData['response']['cashFlows']['dividends']);

      // _buildBodyContentLarge(context, responseData);
    } else if (tabIndex == 1) {
      child = responseData['response']['cashFlows']['bonds']['graphData']
                  ['graphValue']
              .isEmpty
          ? _buildBodyEmptyList(context)
          : _buildBodyContentLarge(
              context, 1, responseData['response']['cashFlows']['bonds']);
    } else if (tabIndex == 2) {
      child = responseData['response']['cashFlows']['deposits']['graphData']
                  ['graphValue']
              .isEmpty
          ? _buildBodyEmptyList(context)
          : _buildBodyContentLarge(
              context, 2, responseData['response']['cashFlows']['deposits']);
    } else {
      child = emptyWidget;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      child: Column(
        children: [Expanded(child: child)],
      ),
    );
  }

  Widget _buildBodyNvaigationLeftBar() {
    //
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        deviceType == DeviceScreenType.tablet
            ? emptyWidget
            : NavigationLeftBar(
                isSideMenuHeadingSelected: 2, isSideMenuSelected: 1),
        Expanded(child: _buildBody(context, widget.responseData))
        // : _buildBodyContentLarge(context, widget.responseData)),
      ],
    );
  }

  Widget _buildBodyEmptyList(BuildContext context) {
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Text(
          "No data available",
          style: appBodyH3,
          textAlign: TextAlign.center,
        ));
  }

  Widget _buildBodyContentLarge(BuildContext context, index, responseData) {
    return SingleChildScrollView(
      child: Container(
        // padding:
        //     EdgeInsets.only(left: 27.0, top: 55.0, right: 60.0, bottom: 87),
        //color: Color(0xfff5f6fa),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _dividendHeader(),
            // SizedBox(
            //   height: getScaledValue(16),
            // ),
            _listForecast(context, index, responseData),
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

  // _dividendHeader() {
  //   return Container(
  //       child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //         Text("Forecasted Dividends", style: headline1_analyse),
  //       ]));
  // }

  Widget _listForecast(BuildContext context, index, responseData) {
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
                        child: dividendReportLeftSide(
                            context, index, responseData)),
                    SizedBox(
                      width: getScaledValue(16),
                    ),
                    Expanded(
                      child: dividendReportRightSide(context, responseData),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ]));
  }

  Widget dividendReportLeftSide(BuildContext context, index, responseData) {
    List<charts.Series<OrdinalSales, String>> chartData =
        chartDataList(responseData['graphData']);
    // widget.responseData['response']['cashFlows']
    //       ['dividends']['graphData']
    //     chartDataList(responseData['response']['graphData']); //@todo

    String cashFlowText = "total dividends";

    if (index == 1) {
      cashFlowText = "total cash flow (coupons or principal + coupon)";
    } else if (index == 2) {
      cashFlowText = "total cash flow (principal + interest)";
    }

    return Container(
        width: MediaQuery.of(context).size.width * 1.0,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("You are expected to receive $cashFlowText of ",
                  style: DividendReportScreenStyle.dividendBodyText1),
              SizedBox(height: getScaledValue(6)),
              Text(responseData['totalCashFlow'],
                  style: DividendReportScreenStyle.dividendBodyText2),
              SizedBox(height: getScaledValue(6)),
              Text(
                  " during the months " +
                      responseData['start'] +
                      " and " +
                      responseData['end'] +
                      " from your selected portfolios.\n\nThe month-wise and asset-wise breakdown of the payout is given below",
                  style: DividendReportScreenStyle.dividendBodyText1),
              SizedBox(height: getScaledValue(54)),
              Text("Month-wise breakdown",
                  style: DividendReportScreenStyle.dividendBodyText3),
              SizedBox(height: getScaledValue(10)),
              Container(
                  height: getScaledValue(200),
                  child: SelectionUserManaged(chartData,
                      dividendDetails: responseData['graphData']
                          ['dividendDetails'],
                      currency: widget.responseData['response']['currency'])),
            ]));
  }

  Widget dividendReportRightSide(BuildContext context, responseData) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        width: MediaQuery.of(context).size.width * 1.0,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _basketPerformanceBtns(responseData),
              SizedBox(height: getScaledValue(16)),
              divider(),
              SizedBox(height: getScaledValue(6)),
              _sortCashFlow(),
              SizedBox(height: getScaledValue(6)),
              _dividendTenure != "" ? showDividendDetails() : emptyWidget
            ]));
  }

  List<charts.Series<OrdinalSales, String>> chartDataList(graphData) {
    final List<OrdinalSales> graphDataList = [];

    for (var index = 0; index < graphData['graphValue'].length; index++) {
      String graphDate = graphData['graphValue'][index][0].toString();
      double graphValue = graphData['graphValue'][index][2].toDouble();

      graphDataList.add(new OrdinalSales(graphDate, graphValue));
    }

    List<charts.Series<OrdinalSales, String>> chartDataList = [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorBlue),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: graphDataList,
      )
    ];

    return chartDataList;
  }

  Widget _basketPerformanceBtns(responseData) {
    List<String> list_months = [];

    for (var value in responseData['graphData']['graphValue']) {
      if (_dividendTenure == "") {
        _dividendTenure = value[0];
      }

      list_months.add(value[0]);
      //buttonLists.add(_performanceButton(value[0], value[0]));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Color(0xfff7f7f7), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Month:", style: DividendReportScreenStyle.dividendBodyText4),
          Expanded(
            child: Container(
              height: getScaledValue(33),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    hint: Text(_selectedMonthGraph,
                        style: DividendReportScreenStyle.dividendBodyText4
                            .copyWith(
                                fontWeight: FontWeight.w700,
                                color: Color(0xff034bd9))),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorBlue,
                    ),
                    value: _selectedMonthGraph,
                    items: list_months.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _analyticsFilterChangeEvent();
                      setState(() {
                        _selectedMonthGraph = value;
                        _dividendTenure = value;
                      });
                      //  _currencySelectionForWeb(currencyValues);
                    }),
              ),
            ),
          )
        ],
      ),
    );

    // return Container(
    //     height: getScaledValue(40),
    //     child: ListView(
    //         shrinkWrap: true,
    //         scrollDirection: Axis.horizontal,
    //         children: buttonLists));
  }

  showDividendDetails() {
    //final List dividendData = dividendDetails[_dividendTenure];
    //dividendData = dividendDetails[_dividendTenure];
    List dividendData = dividendDetails[_dividendTenure];

    final children2 = <Widget>[];

    if (sortType == 'nameBase') {
      sortOrder == 'asc'
          ? dividendData
              .sort((a, b) => (a['ric_name']).compareTo(b['ric_name']))
          : dividendData
              .sort((a, b) => (b['ric_name']).compareTo(a['ric_name']));
    } else if (sortType == 'dateBase') {
      if (sortOrder == 'asc') {
        dividendData.sort((a, b) {
          return (DateFormat('dd MMM, yyyy')
                  .parse(b['date'].toString())
                  .millisecondsSinceEpoch)
              .compareTo(DateFormat('dd MMM, yyyy')
                  .parse(a['date'].toString())
                  .millisecondsSinceEpoch);
        });
      } else {
        dividendData.sort((a, b) {
          return (DateFormat('dd MMM, yyyy')
                  .parse(a['date'].toString())
                  .millisecondsSinceEpoch)
              .compareTo(DateFormat('dd MMM, yyyy')
                  .parse(b['date'].toString())
                  .millisecondsSinceEpoch);
        });
      }
    } else if (sortType == 'amountBase') {
      if (sortOrder == 'asc') {
        dividendData.sort((a, b) {
          double firstValue = double.parse(a['total_dividend_raw'].toString());
          double secondValue = double.parse(b['total_dividend_raw'].toString());
          return firstValue.compareTo(secondValue);
        });
      } else {
        dividendData.sort((a, b) {
          double firstValue = double.parse(a['total_dividend_raw'].toString());
          double secondValue = double.parse(b['total_dividend_raw'].toString());
          return secondValue.compareTo(firstValue);
        });
      }
    }

    for (int i = 0; i < dividendData.length; i++) {
      children2.add(_dividendRow(
          ric: dividendData[i]['ric'].toString(),
          title: dividendData[i]['ric_name'].toString(),
          type: dividendData[i]['type'],
          zone: dividendData[i]['zone'],
          value1: dividendData[i]['total_dividend'],
          value2: dividendData[i]['date'].toString()));
    }

    return Container(
        // padding: EdgeInsets.symmetric(
        //     vertical: getScaledValue(10.0), horizontal: getScaledValue(16.0)),
        //color: Color(0xffecf1fa),
        child: Column(
      children: children2,
    ));
  }

  Widget _dividendRow({
    String ric,
    String title,
    String type,
    String zone,
    String value1,
    String value2,
  }) {
    return GestureDetector(
      onTap: () {
        if (type.toString() != 'Deposits') {
          Navigator.of(context)
              .pushNamed('/fund_info', arguments: {'ric': ric});
        }
      },
      child: containerCard(
          paddingBottom: getScaledValue(16.0),
          paddingLeft: getScaledValue(16.0),
          paddingRight: getScaledValue(16.0),
          paddingTop: getScaledValue(16.0),
          context: context,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(limitChar(title, length: 25),
                          style: keyStatsBodyText1),
                      Row(
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          widgetBubble(
                              title: type.toUpperCase(),
                              leftMargin: 0,
                              rightMargin: 0,
                              fontSize: getScaledValue(7)),
                          SizedBox(width: getScaledValue(9)),
                          widgetZoneFlag(zone),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value1, style: keyStatsBodyText1),
                    value2 != null
                        ? SizedBox(width: getScaledValue(22))
                        : emptyWidget,
                    value2 != null
                        ? Text(value2, style: keyStatsBodyText2)
                        : emptyWidget,
                  ],
                )
              ])),
    );
  }

  Widget _sortCashFlow() {
    //
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SORT BY",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'roboto',
                          letterSpacing: 0.25,
                          color: Color(0xffa5a5a5)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child:
                          Icon(Icons.close, color: Color(0xffcccccc), size: 18),
                    )
                  ],
                ),
                content: Container(
                  color: Colors.white,
                  // height: MediaQuery.of(context)
                  //         .size
                  //         .height *
                  //     0.5,
                  //height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        _sortOptionSection(title: "Amount", options: [
                          {
                            "title": "Highest to Lowest",
                            "type": "amountBase",
                            "order": "desc"
                          },
                          {
                            "title": "Lowest to Highest",
                            "type": "amountBase",
                            "order": "asc"
                          }
                        ]),
                        Divider(
                          color: Color(0x251e1e1e),
                        ),
                        _sortOptionSection(title: "Payment Date", options: [
                          {
                            "title": "Newest to Oldest",
                            "type": "dateBase",
                            "order": "asc"
                          },
                          {
                            "title": "Oldest to Newest",
                            "type": "dateBase",
                            "order": "desc"
                          }
                        ]),
                        Divider(
                          color: Color(0x251e1e1e),
                        ),
                        _sortOptionSection(title: "Name", options: [
                          {
                            "title": "A - Z",
                            "type": "nameBase",
                            "order": "asc"
                          },
                          {
                            "title": "Z - A",
                            "type": "nameBase",
                            "order": "desc"
                          }
                        ]),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[],
              );
            },
          );
        },
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 120,
            height: 33,
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: colorBlue, width: 1.25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Sort By",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: colorBlue,
                    letterSpacing: 1.0,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorBlue,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _sortOptionSection({String title, List options}) {
    List<Widget> _children = [];
    options.forEach((element) {
      _children.add(_sortOptionRow(element));
    });
    return Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'nunito',
                    letterSpacing: 0.25,
                    color: Color(0xff383838))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _children,
            ),
          ],
        ));
  }

  Widget _sortOptionRow(Map optionRow) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          sortType = optionRow['type'];
          sortOrder = optionRow['order'];
          sort(optionRow['type']);
          Navigator.of(context).pop();
        })
      },
      child: Container(
        padding: EdgeInsets.only(top: 12),
        child: Text(optionRow['title'],
            style: PlatformCheck.isSmallScreen(context)
                ? sortType == optionRow['type'] &&
                        sortOrder == optionRow['order']
                    ? sortbyOptionActive.copyWith(color: colorBlue)
                    : sortbyOption
                : sortType == optionRow['type'] &&
                        sortOrder == optionRow['order']
                    ? TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'nunito',
                        letterSpacing: 0.20,
                        color: colorBlue)
                    : TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'nunito',
                        letterSpacing: 0.20,
                        color: Color(0xff383838))),
      ),
    );
  }

  void sort(type) {
    setState(() {
      showDividendDetails();
    });
  }
}

class SelectionUserManaged extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final dividendDetails;
  final currency;

  SelectionUserManaged(this.seriesList,
      {this.animate, this.dividendDetails, this.currency = "Rs"});

  @override
  SelectionUserManagedState createState() {
    return new SelectionUserManagedState();
  }
}

class SelectionUserManagedState extends State<SelectionUserManaged> {
  String dataString = "";

  @override
  Widget build(BuildContext context) {
    final chart = new charts.BarChart(widget.seriesList,
        animate: true, //widget.animate,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          showAxisLine: true,
          //renderSpec: charts.NoneRenderSpec(),
          tickProviderSpec: new charts.BasicNumericTickProviderSpec(
            //zeroBound: true,
            desiredTickCount: 5,
          ),
          /* tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
					_formatMoney,
				), */
        ),
        /* selectionModels: [
				new charts.SelectionModelConfig(
					type: charts.SelectionModelType.info,
					updatedListener: _infoSelectionModelUpdated)
			], */
        //userManagedState: _myState,
        behaviors: [
          new charts.ChartTitle(
              'Dividend (' + getCurrencySymbol(widget.currency) + ')',
              behaviorPosition: charts.BehaviorPosition.start,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
              titleOutsideJustification: charts.OutsideJustification.middle),
        ]);

    return chart;
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final double sales;

  OrdinalSales(this.year, this.sales);
}
