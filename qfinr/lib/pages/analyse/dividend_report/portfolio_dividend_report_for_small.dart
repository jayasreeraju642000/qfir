import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import '../../../models/main_model.dart';
import '../../../widgets/widget_common.dart';

final log = getLogger('PortfolioDividendReport');

class PortfolioDividendReportSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final Map responseData;

  PortfolioDividendReportSmall(this.model,
      {this.analytics, this.observer, this.responseData});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioDividendReportState();
  }
}

class _PortfolioDividendReportState extends State<PortfolioDividendReportSmall>
    with SingleTickerProviderStateMixin {
  final controller = ScrollController();
  TabController _tabController;
  int tabIndex = 0;
  String sortType = "nameBase";
  String sortOrder = "asc";
  String _dividendTenureStock = "";
  String _dividendTenureBonds = "";
  String _dividendTenureDeposite = "";
  Map dividendDetailsStock;
  int cashFlowIndex = 0;

  Map dividendDetailsBonds;
  Map dividendDetailsDeposite;
  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Dividend Page',
        screenClassOverride: 'PortfolioDividend');
  }

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

  int id = 0;
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
    try {
      if (!_checkIfDataIsEmpty(widget.responseData['response']['cashFlows']
          ['dividends']['graphData'])) {
        dividendDetailsStock = widget.responseData['response']['cashFlows']
            ['dividends']['graphData']['dividendDetails'];

        for (var value in widget.responseData['response']['cashFlows']
            ['dividends']['graphData']['graphValue']) {
          _dividendTenureStock = value[0];
          break;
        }
      }
      if (!widget
          .responseData['response']['cashFlows']['bonds']['graphData']
              ['graphValue']
          .isEmpty) {
        dividendDetailsBonds = widget.responseData['response']['cashFlows']
            ['bonds']['graphData']['dividendDetails'];

        for (var value in widget.responseData['response']['cashFlows']['bonds']
            ['graphData']['graphValue']) {
          _dividendTenureBonds = value[0];
          break;
        }
      }

      if (!widget
          .responseData['response']['cashFlows']['deposits']['graphData']
              ['graphValue']
          .isEmpty) {
        dividendDetailsDeposite = widget.responseData['response']['cashFlows']
            ['deposits']['graphData']['dividendDetails'];

        for (var value in widget.responseData['response']['cashFlows']
            ['deposits']['graphData']['graphValue']) {
          _dividendTenureDeposite = value[0];
          break;
        }
      }

      //     }
    } catch (e) {}
  }

  PreferredSizeWidget tabbar() {
    List<Widget> tabChildren = [];

    tabChildren.add(Tab(text: "Stocks")); //(dividends)
    tabChildren.add(Tab(text: "Bonds"));
    tabChildren.add(Tab(text: "Deposits"));

    return TabBar(
      isScrollable: true,
      controller: _tabController,
      unselectedLabelColor: Color(0x30000000),
      labelColor: Colors.black,
      indicatorWeight: getScaledValue(2),
      indicatorColor: Colors.black,
      unselectedLabelStyle: tabBarInactive,
      labelStyle: tabBarActive,
      tabs: tabChildren,
      onTap: (value) {
        tabIndex = value;
      },
    );
  }

  Widget _buildBodyTabView(BuildContext context, responseData) {
    return mainContainer(
      context: context,
      paddingBottom: 0,
      containerColor: Colors.white,
      child: _buildBodyContent(context, responseData),
    );
  }

  Widget _buildBodyContent(BuildContext context, responseData) {
    List<Widget> children = [];
    children.add(_checkIfDataIsEmpty(widget.responseData['response']
            ['cashFlows']['dividends']['graphData'])
        ? _buildBodyEmptyList(context)
        : _buildBody(context, 0,
            widget.responseData['response']['cashFlows']['dividends']));

    children.add(widget
            .responseData['response']['cashFlows']['bonds']['graphData']
                ['graphValue']
            .isEmpty
        ? _buildBodyEmptyList(context)
        : _buildBody(
            context, 1, responseData['response']['cashFlows']['bonds']));

    children.add(widget
            .responseData['response']['cashFlows']['deposits']['graphData']
                ['graphValue']
            .isEmpty
        ? _buildBodyEmptyList(context)
        : _buildBody(context, 2,
            widget.responseData['response']['cashFlows']['deposits']));

    return TabBarView(
      children: children,
      controller: _tabController,
    );
  }

  _checkIfDataIsEmpty(responseData) {
    return responseData.isEmpty;
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
            bottom: tabbar(),
          ),
          body: _buildBodyTabView(context, widget.responseData));
    });
  }

  Widget _buildBodyEmptyList(
    BuildContext context,
  ) {
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Text(
          "No data available",
          style: appBodyH3,
          textAlign: TextAlign.center,
        ));
  }

  Widget _buildBody(BuildContext context, index, responseData) {
    //if (_dividendTenure == "") {
    // if (index == 0) {
    //   dividendDetails = responseData['graphData']['dividendDetails'];
    //   for (var value in responseData['graphData']['graphValue']) {
    //     _dividendTenure = value[0];
    //     break;
    //   }
    // } else if (index == 1) {
    //   dividendDetails = responseData['graphData']['dividendDetails'];
    //   for (var value in responseData['graphData']['graphValue']) {
    //     _dividendTenure = value[0];
    //     break;
    //   }
    // } else {
    //   dividendDetails = responseData['graphData']['dividendDetails'];
    //   for (var value in responseData['graphData']['graphValue']) {
    //     _dividendTenure = value[0];
    //     break;
    //   }
    // }
    //  }

    List<charts.Series<OrdinalSales, String>> chartData =
        chartDataList(responseData['graphData']); //@todo

    String cashFlowText = "total dividends";

    if (index == 1) {
      cashFlowText = "total cash flow (coupons or principal + coupon)";
    } else if (index == 2) {
      cashFlowText = "total cash flow (principal + interest)";
    }

    cashFlowIndex = index;

    return Container(
        // padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(16), vertical: getScaledValue(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Color(0xffe9e9e9), width: getScaledValue(1)),
              borderRadius: BorderRadius.circular(getScaledValue(4)),
            ),
            child: Text(
                "You are expected to receive $cashFlowText of " +
                    responseData['totalCashFlow'] +
                    " during the months " +
                    responseData['start'] +
                    " and " +
                    responseData['end'] +
                    " from your selected portfolios.\n\nThe month-wise and asset-wise breakdown of the payout is given below",
                style: keyStatsBodyText7),
          ),
        ),
        Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(16), vertical: getScaledValue(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Month-wise breakdown", style: appBodyH3),
                SizedBox(height: getScaledValue(10)),
                Container(
                    height: getScaledValue(200),
                    child: SelectionUserManaged(chartData,
                        dividendDetails: index == 0
                            ? dividendDetailsStock
                            : index == 1
                                ? dividendDetailsBonds
                                : index == 2
                                    ? dividendDetailsDeposite
                                    : "",
                        currency: widget.responseData['response']['currency'])),
                SizedBox(height: getScaledValue(10)),
                _basketPerformanceBtns(responseData, index)
              ],
            )),
        sectionSeparator(),

        Container(
          color: Color(0xffecf1fa),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: GestureDetector(
            onTap: () => sortPopup(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Sort By", style: textLink1),
                Icon(Icons.keyboard_arrow_down,
                    color: colorBlue, size: getScaledValue(15))
              ],
            ),
          ),
        ),

        showDividendDetails(index)
        //_dividendTenure != "" ? showDividendDetails(index) : emptyWidget
      ],
    ));
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

  Widget _basketPerformanceBtns(responseData, index) {
    List<Widget> buttonLists = [];

    for (var value in responseData['graphData']['graphValue']) {
      buttonLists.add(_performanceButton(value[0], value[0], index));
    }

    // if (_dividendTenure == "") {
    //   // _dividendTenure = value[0];
    // }

    return Container(
        height: getScaledValue(40),
        child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: buttonLists));
  }

  Widget _performanceButton(String title, String value, int index) {
    return GestureDetector(
        onTap: () {
          _analyticsFilterChangeEvent();

          setState(() {
            if (index == 0) {
              _dividendTenureStock = value;
            } else if (index == 1) {
              _dividendTenureBonds = value;
            } else if (index == 2) {
              _dividendTenureDeposite = value;
            }
          });
        },
        child: index == 0
            ? _dividendTenureStock == value
                ? widgetBubble(
                    title: title,
                    fontSize: getScaledValue(10),
                    horizontalPadding: 16,
                    verticalPadding: 7,
                    textColor: Color(0xff3878dc),
                    bgColor: Color(0xffecf1fa),
                    borderColor: colorActive)
                : widgetBubble(
                    title: title,
                    fontSize: getScaledValue(10),
                    horizontalPadding: 16,
                    verticalPadding: 7,
                    textColor: Color(0xff818181),
                    bgColor: Colors.white,
                    borderColor: Color(0xffbcbcbc))
            : index == 1
                ? _dividendTenureBonds == value
                    ? widgetBubble(
                        title: title,
                        fontSize: getScaledValue(10),
                        horizontalPadding: 16,
                        verticalPadding: 7,
                        textColor: Color(0xff3878dc),
                        bgColor: Color(0xffecf1fa),
                        borderColor: colorActive)
                    : widgetBubble(
                        title: title,
                        fontSize: getScaledValue(10),
                        horizontalPadding: 16,
                        verticalPadding: 7,
                        textColor: Color(0xff818181),
                        bgColor: Colors.white,
                        borderColor: Color(0xffbcbcbc))
                : index == 2
                    ? _dividendTenureDeposite == value
                        ? widgetBubble(
                            title: title,
                            fontSize: getScaledValue(10),
                            horizontalPadding: 16,
                            verticalPadding: 7,
                            textColor: Color(0xff3878dc),
                            bgColor: Color(0xffecf1fa),
                            borderColor: colorActive)
                        : widgetBubble(
                            title: title,
                            fontSize: getScaledValue(10),
                            horizontalPadding: 16,
                            verticalPadding: 7,
                            textColor: Color(0xff818181),
                            bgColor: Colors.white,
                            borderColor: Color(0xffbcbcbc))
                    : emptyWidget);
  }

  Widget showDividendDetails(index) {
    final children2 = <Widget>[];
    List dividendData;
    if (index == 0) {
      dividendData = dividendDetailsStock[_dividendTenureStock];
    } else if (index == 1) {
      dividendData = dividendDetailsBonds[_dividendTenureBonds];
    } else if (index == 2) {
      dividendData = dividendDetailsDeposite[_dividendTenureDeposite];
    }

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
        padding: EdgeInsets.symmetric(
            vertical: getScaledValue(6.0), horizontal: getScaledValue(16.0)),
        color: Color(0xffecf1fa),
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
                ])));
  }

  void sortPopup({int index}) {
    Widget content = Container(
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(15), vertical: getScaledValue(11)),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SORT BY", style: sortbyTitle),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close,
                    color: Color(0xffcccccc), size: getScaledValue(18)),
              )
            ],
          ),
          SizedBox(height: getScaledValue(6)),
          _sortOptionSection(title: "Amount", options: [
            {
              "title": "Highest to Lowest",
              "type": "amountBase",
              "order": "desc"
            },
            {"title": "Lowest to Highest", "type": "amountBase", "order": "asc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Payment Date", options: [
            {"title": "Newest to Oldest", "type": "dateBase", "order": "asc"},
            {"title": "Oldest to Newest", "type": "dateBase", "order": "desc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Name", options: [
            {"title": "A - Z", "type": "nameBase", "order": "asc"},
            {"title": "Z - A", "type": "nameBase", "order": "desc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
        ],
      ),
    );

    loadBottomSheet(context: context, content: content);
  }

  Widget _sortOptionSection({String title, List options}) {
    List<Widget> _children = [];

    options.forEach((element) {
      _children.add(_sortOptionRow(element));
    });

    return Container(
        padding: EdgeInsets.symmetric(vertical: getScaledValue(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: sortbyOptionHeading),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _children,
            ),
          ],
        ));
  }

  Widget _sortOptionRow(Map optionRow) {
    // title, String type
    return GestureDetector(
      onTap: () => {
        setState(() {
          sortType = optionRow['type'];
          sortOrder = optionRow['order'];

          ///sort(optionRow['type']);

          Navigator.of(context).pop();
        })
      },
      child: Container(
        padding: EdgeInsets.only(top: getScaledValue(12)),
        child: Text(optionRow['title'],
            style:
                sortType == optionRow['type'] && sortOrder == optionRow['order']
                    ? sortbyOptionActive.copyWith(color: colorBlue)
                    : sortbyOption),
      ),
    );
  }

  void sort(type) {
    setState(() {
      showDividendDetails(cashFlowIndex);
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
