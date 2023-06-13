import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/discover/discover_styles.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

final log = getLogger('DiscoverGraphView');

class DiscoverGraphView extends StatefulWidget {
  final BasketResponse basketResponse;
  final String selectedTabText;
  final int graphDataPosition;

  const DiscoverGraphView(
      {Key key,
      this.basketResponse,
      this.selectedTabText,
      this.graphDataPosition})
      : super(key: key);

  @override
  _DiscoverGraphViewState createState() => _DiscoverGraphViewState();
}

class _DiscoverGraphViewState extends State<DiscoverGraphView> {
  PageIndicatorController controller;

  @override
  void initState() {
    controller = PageIndicatorController();

    log.d(widget.selectedTabText);

    super.initState();
  }

  Future<Null> _analyticsInfoEvent() async {
    FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "discover",
      'item_name': "discover_information",
      'content_type': "click_info_icon",
    });
  }

  Future<Null> _analyticCalculationInfoEvent() async {
    FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "discover",
      'item_name': "discover_calculation_logic",
      'content_type': "click_calculation_logic",
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildGraphDetailsCardView();
  }

  Widget _buildGraphDetailsCardView() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 25.0,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: FloatingCard(
        cornerRadius: 4,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              topCard(widget.basketResponse.response[widget.graphDataPosition]),
              SizedBox(height: 24.0),
              Expanded(
                child: Column(
                  children: [
                    marketInsightRowItem(
                      "Momentum",
                      "Stocks in upside momentum",
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.mPercent ??
                          0.0,
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.mMax ??
                          0,
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.mTotal ??
                          0,
                    ),
                    divider(),
                    marketInsightRowItem(
                      "Trend",
                      "Stocks in up-trend",
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.sPercent ??
                          0.0,
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.sMax ??
                          0,
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.sTotal ??
                          0,
                    ),
                    divider(),
                    marketInsightRowItem(
                      "Volatility",
                      "Measure of uncertainty",
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.bPercent ??
                          0.0,
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.bMax ??
                          0,
                      widget.basketResponse.response[widget.graphDataPosition]
                              .miBasketDetails.weeklyData?.bTotal ??
                          0,
                    ),
                    divider(),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              bottomAction(widget.graphDataPosition)
            ],
          ),
        ),
      ),
    );
  }

  Widget topCard(BasketData basketData) {
    return Container(
      decoration: BoxDecoration(color: AppColor.cardShadowTop),
      child: Padding(
        padding: EdgeInsets.only(left: 14.0, top: 18, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Overall Sentiment",
                    style: DiscoverStyles.graphTitle,
                  ),
                ),
                Tooltip(
                      padding: EdgeInsets.all(10),
                   textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message: "Overall Sentiment\nA quantitative indicator showing the market sentiment ranging from Bearish to Euphoria. We compute this indicator looking at a number of factors that reflect sentiment\n\nEach numbered bar represents the following sentiment:\n1: Bearish\n2: Negative\n3: Neutral\n4: Bullish\n5: Strongly Bullish\n6. Overheated\n7: Exuberant",
                                  child: InkWell(
                    onTap: () {
                      _analyticsInfoEvent();
                      DiscoverStyles.showPopUp(
                        context,
                        isIconAlert: true,
                      );
                    },
                    child: svgImage(
                      "assets/icon/information.svg",
                      color: AppColor.colorBlue,
                      height: 12.0,
                      width: 13.0,
                    ),
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Text(
                getEquityByCountryCode(basketData.zone),
                style: DiscoverStyles.portfolioSummaryZone,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      7,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: index != 6 ? 8 : 0, top: 30),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      gradient: heatGraphGradients()[index]),
                                  height: spikeIndex(basketData.basketValue) ==
                                          index
                                      ? 14
                                      : 6,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Stay Defensive",
                          style: DiscoverStyles.graphText1,
                        ),
                        Text(
                          "Stay Alert",
                          style: DiscoverStyles.graphText1,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12.0,
                      bottom: 16,
                    ),
                    child: Text(
                      basketData.miBasketDetails.trend,
                      style: DiscoverStyles.trendText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getEquityByCountryCode(String code) {
    if (code.toLowerCase() == "in") {
      return "INDIA EQUITIES";
    } else {
      return "US EQUITIES";
    }
  }

  List<LinearGradient> heatGraphGradients() {
    return [
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xffe16c56),
          Color(0xffe49d62),
        ],
        stops: [0.0, 0.9],
      ),
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xffe3905f),
          Color(0xffe7bd6a),
          Color(0xffcebf6e),
        ],
      ),
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xffe7bd6a),
          Color(0xff85c077),
        ],
        stops: [0.0, 0.9],
      ),
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xffb1c072),
          Color(0xff85c077),
        ],
        stops: [0.0, 0.9],
      ),
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xff85c077),
          Color(0xffe7bd6a),
        ],
        stops: [0.0, 0.9],
      ),
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xffcebf6e),
          Color(0xffe7bd6a),
          Color(0xffe3905f),
        ],
      ),
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xffe49d62),
          Color(0xffe16c56),
        ],
        stops: [0.0, 0.9],
      ),
    ];
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

  Widget marketInsightRowItem(
      String heading, String subheading, num percent, int max, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                heading,
                style: DiscoverStyles.graphDataRowTitle,
              ),
              Row(
                children: [
                  Text(
                    ((percent / 5).round() * 5).toString(),
                    style: DiscoverStyles.graphDataRowValue,
                  ),
                  Text(
                    "/100",
                    style: DiscoverStyles.graphDataRowValue,
                  ),
                ],
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  subheading,
                  style: DiscoverStyles.graphDataRowSubTitle,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          )
        ],
      ),
    );
  }

  Widget bottomAction(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "As of " +
                  widget.basketResponse.response[index].miBasketDetails
                      .lastUpdated,
              style: DiscoverStyles.graphFooterAsOf,
            ),
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              _analyticCalculationInfoEvent();
              DiscoverStyles.showPopUp(
                context,
                isIconAlert: false,
              );
            },
            child: Text(
              "How are these calculated?",
              textAlign: TextAlign.end,
              style: DiscoverStyles.graphHowToCalculate,
            ),
          ))
        ],
      ),
    );
  }
}
