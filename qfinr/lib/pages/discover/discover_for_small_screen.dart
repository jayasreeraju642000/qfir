import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import '../../widgets/widget_common.dart';
import '../../models/main_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';

final log = getLogger('DiscoverPageSmall');

class DiscoverForSmallScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final Map responseData;

  DiscoverForSmallScreen(this.model,
      {this.analytics, this.observer, this.responseData});

  @override
  _DiscoverForSmallScreenState createState() => _DiscoverForSmallScreenState();
}

class _DiscoverForSmallScreenState extends State<DiscoverForSmallScreen> {
  final scrollController = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageIndicatorController controller;
  BasketResponse basketResponse;
  bool isLoading;
  bool errorState;

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Discover Page', screenClassOverride: 'Discover');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Discover Page",
    });
  }

  Future getBasket() async {
    setState(() {
      widget.model.setLoader(true);
    });
    //basketResponse = await widget.model.getMIBasket();
    basketResponse = await widget.model.getLocalMIBaskets();

    setState(() {
      widget.model.setLoader(false);
    });
  }

  @override
  void initState() {
    super.initState();

    _currentScreen();
    _addEvent();

    controller = PageIndicatorController();
    getBasket();

    setState(() {
      widget.model.redirectBase = "/discover";
    });
  }

  Future<Null> _analyticsInfoEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "discover",
      'item_name': "discover_information",
      'content_type': "click_info_icon",
    });
  }

  Future<Null> _analyticCalculationInfoEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "discover",
      'item_name': "discover_calculation_logic",
      'content_type': "click_calculation_logic",
    });
  }

  PreferredSizeWidget _appbarMenuIconWeb() {
    return AppBar(
      backgroundColor: Color(0xff0445e4),
      elevation: 0.0,
      title: Text(""),
    );
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Color(0xff0445e4));
    scrollController.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return Scaffold(
        key: _scaffoldKey,
        drawer: WidgetDrawer(),
        appBar: !kIsWeb
            ? commonScrollAppBar(
                controller: scrollController,
                leading: GestureDetector(
                    onTap: () => _scaffoldKey.currentState.openDrawer(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(
                          getScaledValue(Platform.isAndroid ? 17 : 12)),
                      height: getScaledValue(5),
                      child: svgImage('assets/icon/icon_menu.svg'),
                    )),
              )
            : _appbarMenuIconWeb(),
        bottomNavigationBar: widgetBottomNavBar(context, 4),
        body: !widget.model.isLoading && basketResponse != null
            ? Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(color: AppColor.colorBlue),
                  ),
                  ListView(
                    controller: scrollController,
                    physics: ClampingScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Text("Market Insights & Ideas",
                            style: headline1.apply(color: Colors.white)),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: basketResponse.response.length,
                          controller: controller,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 25.0, left: 16, right: 16, bottom: 8),
                              child: FloatingCard(
                                cornerRadius: 4,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: Column(
                                    children: [
                                      topCard(basketResponse.response[index]),
                                      Expanded(
                                          child: Container(
                                              child: Column(
                                        children: [
                                          marketInsightRowItem(
                                              "Momentum",
                                              "Stocks in upside momentum",
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.mPercent ??
                                                  0.0,
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.mMax ??
                                                  0,
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.mTotal ??
                                                  0),
                                          divider(),
                                          marketInsightRowItem(
                                              "Trend",
                                              "Stocks in up-trend",
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.sPercent ??
                                                  0.0,
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.sMax ??
                                                  0,
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.sTotal ??
                                                  0),
                                          divider(),
                                          marketInsightRowItem(
                                              "Volatility",
                                              "Measure of uncertainty",
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.bPercent ??
                                                  0.0,
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.bMax ??
                                                  0,
                                              basketResponse
                                                      .response[index]
                                                      .miBasketDetails
                                                      .weeklyData
                                                      ?.bTotal ??
                                                  0),
                                          divider(),
                                        ],
                                      ))),
                                      bottomAction(index)
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      /* InkPageIndicator(
					gap: 8,
					shape: IndicatorShape.circle(4),
					inactiveColor: AppColor.colorBlue.withAlpha(Alpha.P30),
					activeColor: AppColor.colorBlue,
					inkColor: AppColor.colorBlue.withAlpha(Alpha.P30),
					controller: controller,
					style: InkStyle.normal,
				), */
                      SizedBox(height: getScaledValue(10)),
                      toolShortcut(
                          "assets/icon/icon_home_know_funds.svg",
                          "Know your assets",
                          "Uncover deep insights and analysis on Mutual funds, ETFs, stocks, and bonds across multiple countries",
                          navigation: (widget.model.userRiskProfile != null
                              ? "/sortFilter"
                              : "/riskProfilerAlert/fund")),
                      toolShortcut(
                        "assets/icon/look.svg",
                        "Intelli-Screener",
                        "Screen, backtest and analyse using our sophisticated screener.",
                        navigation: '/exploreIdeas',
                      ),
                    ],
                  ),
                ],
              )
            : widget.model.isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(child: Text("Something is not right!")));
  }

  Widget bottomAction(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "As of " +
                basketResponse.response[index].miBasketDetails.lastUpdated,
            style: keyStatsBodyText6,
          ),
          GestureDetector(
              onTap: () async {
                _analyticCalculationInfoEvent();
                return bottomAlertBox(
                  context: context,
                  title: "Momentum Indicator",
                  description:
                      "Shows the market uptrend momentum as a score from 0 (low momentum) to 100 (high momentum), where 100 implies all stocks in the Nifty500 are showing strong upward momentum",
                  title2: "Trend Indicator",
                  description2:
                      "Shows the trend in the market calculated as the percentage of stocks in the Nifty500 that are trading above their 200 day moving average. The indicator ranges from 0 (weak trend) to 100 (strong trend), where 0 means that all the Nifty500 stocks are trading below their respective 200 day moving average",
                  title3: "Volatility Indicator",
                  description3:
                      "Shows the riskiness in the market. We measure the deviation of the current prices against the respective 20 day moving average. The indicator ranges from 0 (lower risk) to 100 (higher risk), where 100 means that the prices of all stocks in the Nifty500 are more than 2 standard deviations away from their 20 day moving average",
                );
              },
              child: Text(
                "How are these calculated?",
                style: keyStatsBodyText6.apply(
                    color: AppColor.colorBlue, fontWeightDelta: 2),
              ))
        ],
      ),
    );
  }

  Widget topCard(BasketData basketData) {
    return Container(
        decoration: BoxDecoration(color: AppColor.cardShadowTop),
        child: Padding(
          padding: EdgeInsets.only(left: 14.0, top: 18, right: 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(
                  child: Text("Overall Sentiment", style: bodyText4),
                ),
                InkWell(
                    onTap: () async {
                      await _analyticsInfoEvent();
                      return bottomAlertBox(
                        context: context,
                        title: 'Overall Sentiment',
                        description:
                            " A quantitative indicator showing the market sentiment ranging from Bearish to Euphoria. We compute this indicator looking at a number of factors that reflect sentiment\n\nEach numbered bar represents the following sentiment:\n1: Bearish\n2: Negative\n3: Neutral\n4: Bullish\n5: Strongly Bullish\n6. Overheated\n7: Exuberant",
                      );
                    },
                    child: svgImage(
                      "assets/icon/information.svg",
                      color: AppColor.colorBlue,
                      height: getScaledValue(16),
                      width: getScaledValue(12),
                    )),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            Padding(
              padding: EdgeInsets.only(top: getScaledValue(2.0)),
              child: Text(getEquityByCountryCode(basketData.zone),
                  style: portfolioSummaryZone),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      return Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(
                                right: index != 6 ? 8 : 0, top: 30),
                            child: Column(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        gradient: heatGraphGradients()[index]),
                                    height:
                                        spikeIndex(basketData.basketValue) ==
                                                index
                                            ? 14
                                            : 6),
                                SizedBox(height: getScaledValue(2)),
                                Text((index + 1).toString(), style: bodyText7),
                              ],
                            )),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
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
                    padding: const EdgeInsets.only(top: 12.0, bottom: 16),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Current Sentiment:", style: keyStatsBodyText6),
                          Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                              ),
                              child: Text(basketData.miBasketDetails.trend,
                                  style: keyStatsBodyText7)),
                        ]),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }

  List<String> messages() {
    return [
      "Neutral, with positive bias",
      "Neutral, with negative bias",
      "Positive, with positive bias",
      "Negative, with negative bias",
      "Doing good",
      "Doing bad",
      "At a huge risk",
    ];
  }

  Widget marketInsightRowItem(
      String heading, String subheading, num percent, int max, int total) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  heading,
                  style: keyStatsBodyText7.apply(color: Colors.black),
                ),
                Row(
                  children: [
                    Text(((percent / 5).round() * 5).toString(),
                        style: keyStatsBodyText7.apply(color: Colors.black)),
                    Text("/100",
                        style:
                            keyStatsBodyText7.apply(color: Color(0xff8b8b8b)))
                  ],
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            Row(
              children: [
                Text(
                  subheading,
                  style: keyStatsBodyText6,
                ),
                //Text("$total/$max", style: keyStatsBodyText6)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            )
          ],
        ),
      ),
    );
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

  Widget toolShortcut(String imgPath, String title, String description,
      {String navigation = "",
      var navigationArguments,
      bool alertType = false}) {
    return GestureDetector(
        onTap: () {
          if (title == "Know your assets") {}
          if (navigation != "") {
            Navigator.pushNamed(context, navigation,
                    arguments: navigationArguments)
                .then((_) => changeStatusBarColor(Color(0xff0445e4)));
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
                          : headline6),
                  alertType
                      ? Divider(
                          height: 20,
                          color: Color(0xffededed),
                        )
                      : emptyWidget,
                  Text(description, style: bodyText4)
                ],
              )),
              Icon(Icons.chevron_right),
            ])));
  }
}

MyGlobals myGlobals = new MyGlobals();

class MyGlobals {
  GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}
