import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('ExploreScreen');

class SmallExploreScreen extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Map responseData;

  SmallExploreScreen(this.model,
      {this.analytics, this.observer, this.responseData});

  @override
  _SmallExploreScreenState createState() => _SmallExploreScreenState();
}

class _SmallExploreScreenState extends State<SmallExploreScreen> {
  Map contentForInformationIcon = {
    'Size': {
      'title': 'Size',
      'description':
          'Shortlist the stock universe that you want to focus on to build your portfolio. All past and present stocks that have been a part of this universe will be shortlisted for analysis',
    },
    'Sector': {
      'title': 'Sector',
      'description':
          'Shortlist one or more sectors that you want to focus on to build your portfolio. All past and present stocks that have been a part of this universe will be shortlisted for analysis',
    },
    'Number of Holdings': {
      'title': 'Number of Holdings',
      'description':
          'Select the number of holdings that you would like to have in your portfolio at any point of time',
    },
    'Weightage': {
      'title': 'Weightage',
      'description':
          'Select one of the two weighing alternatives:\n\nEqual Weights: All stocks part of the portfolio will be weighted equally\n\nRisk-adjusted-Return Weights: All stocks part of the portfolio will be weighted as per their respective Risk-adjusted-Return values. Higher the value, the higher the weightage',
    },
    'Rebalancing Frequency': {
      'title': 'Rebalancing Frequency',
      'description':
          'Select one of the two rebalancing frequencies:\n\nMonthly: The portfolio will be rebalanced every month\n\nQuarterly: The portfolio will be rebalanced every quarter',
    },
    'Months (for Momentum and Volatility Screens)': {
      'title': 'Months (for Momentum and Volatility Screens)',
      'description':
          'Select one of the two rebalancing frequencies:\n\nMonthly: The portfolio will be rebalanced every month\n\nQuarterly: The portfolio will be rebalanced every quarter',
    },
    'Screener Model': {
      'title': 'Screener Model',
      'description':
          'i. Momentum :  \nScreens stocks based on their period price return. Selects the stocks with highest momentum which meet the selection criteria on every rebalancing date.\n\n ii. Value: \nScreens stocks based on their period value. Value companies are normally perceived as companies with low PE (Price to Earning), low PB (Price to Book), P/CF (Price to Cash Flow) and high DY (Dividend Yield). Selects the stocks with highest value (low PE, PB, PC; high DY) which meet the selection criteria on every rebalancing date.\n\niii. Low Volatility\nScreens stocks based on their average period price return volatility. Selects the stocks with lowest volatility which meet the selection criteria on every rebalancing date.',
    },
    'Value Type': {
      'title': 'Choose from P/B, P/E, P/C, DY',
      'description':
          'Choose the criteria of Value from at least one of PE (Price to Earning), PB (Price to Book), P/CF (Price to Cash Flow) and DY (Dividend Yield)',
    },
  };

  final scrollController = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageIndicatorController controller;
  BasketResponse basketResponse;
  bool isLoading;
  bool errorState;
  bool _showMonths = false;
  bool _showValueType = false;

  StocksResponse stocksResponse;
  List<Filter> filterOptions;
  List<StockData> filterStockData;
  int stockCount = 0;
  int filterStockCount = 0;

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Explore Ideas Page', screenClassOverride: 'ExploreIdeas');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Explore Ideas Page",
    });
  }

  Future<Null> _analyticsShowMeAnIdeaEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "explore_ideas",
      'item_name': "explore_ideas_show_idea",
      'content_type': "click_show_idea",
    });
  }

  Future getStockList() async {
    setState(() {
      widget.model.setLoader(true);
    });
    stocksResponse = await widget.model.getStockList();

    List<String> sectors = stocksResponse.response
        .map((e) => e.trbcEconomicSector)
        .toSet()
        .toList();
    List<FilterOption> sectorOptions =
        sectors.map((e) => FilterOption(e, e, isSelected: true)).toList();
    Filter sectorFilter = Filter("Sector", true, sectorOptions);
    filterOption(sectorFilter);
    filterStockCount = stocksResponse.response.length;
    stockCount = filterStockCount;
    filterStockData = stocksResponse.response;

    calculateFilteredStockCount();

    setState(() {
      widget.model.setLoader(false);
    });
  }

  @override
  void initState() {
    super.initState();

    _currentScreen();
    _addEvent();

    getStockList();
  }

  @override
  Widget build(BuildContext context) {
    scrollController.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    changeStatusBarColor(Color(0xff1c1c1c));
    return Scaffold(
      key: _scaffoldKey,
      /* appBar: commonScrollAppBar(
			controller: scrollController, bgColor: Color(0xff1c1c1c),
			actions: [
				GestureDetector(
					onTap: () => Navigator.pushReplacementNamed(context, widget.model.redirectBase),
					child: AppbarHomeButton(),
				),
			]
		), */
      body: !widget.model.isLoading && stocksResponse != null
          ? NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: getScaledValue(200),
                    floating: false,
                    backgroundColor: Color(0xff1c1c1c),
                    pinned: false,
                    actions: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, widget.model.redirectBase),
                        child: AppbarHomeButton(),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: false,
                        background: Stack(
                          children: [
                            Container(
                              color: Color(0xff1c1c1c),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: svgImage("assets/images/bino.svg"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 110.0, left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Contants.SCREENER,
                                    style: passcodeText.apply(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: Text(
                                      "Build, Backtest and Analyze",
                                      style: portfolioBoxValue.apply(
                                          color: Color(0xff8e8e8e),
                                          fontWeightDelta: 0),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                ];
              },
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16) +
                        EdgeInsets.only(top: 32, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Set Preferences".toUpperCase(), style: appBodyH3),
                        Text(filterStockCount.toString() + " stocks selected",
                            style: bodyText10.copyWith(
                                fontWeight: FontWeight.normal))
                        //Text("Need Help", style: tabLabelActive.apply(letterSpacingDelta: 0))
                      ],
                    ),
                  ),
                  Expanded(
                      child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      // ignore: missing_return
                      onNotification: (overscroll) {
                        overscroll.disallowGlow();
                      },
                      child: ListView(
                          children: filterOptions.map((e) {
                        if (e.title ==
                                "Months (for Momentum and Volatility Screens)" &&
                            !_showMonths) {
                          return Container();
                        }
                        if (e.title == "Value Type" && !_showValueType) {
                          return Container();
                        }
                        return preferenceItem(e);
                      }).toList()),
                    ),
                  )),
                  InkWell(
                      onTap: () {
                        _analyticsShowMeAnIdeaEvent();
                        if (filterStockCount > 0 && countValidate()) {
                          final screenModelFilter = filterOptions.singleWhere(
                              (element) => element.title == "Screener Model",
                              orElse: () => null);
                          if (screenModelFilter != null) {
                            bool flag = false;
                            screenModelFilter.option.forEach((element) {
                              if (element.isSelected) {
                                flag = true;
                              }
                            });
                            if (flag) {
                              Navigator.of(context).pushNamed(
                                  '/exploreIdeasResult',
                                  arguments: {'selectedFilter': filterOptions});
                            } else {
                              bottomAlertBox(
                                context: context,
                                title: "Value missing",
                                description:
                                    "Please select a screener model type",
                              );
                            }
                          }
                        } else {
                          _displaySnackBar(
                              "No stock data for this combination!");
                        }
                      },
                      child: gradientButtonWithChild(
                        widget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Run Screener".toUpperCase(),
                              style: bodyText2.apply(
                                  color: Colors.white,
                                  letterSpacingDelta: 2,
                                  fontWeightDelta: 2),
                            ),
                          ],
                        ),
                        buttonDisabled: !countValidate(),
                      ))
                ],
              ))
          : preLoader(title: ''),
    );
  }

  bool countValidate() {
    num selectedHolding = int.parse(filterOptions[2]
        .option
        .firstWhere((element) => element.isSelected)
        .name);

    if ((0.5 * filterStockCount) < selectedHolding ||
        filterOptions[1].option.where((element) => element.isSelected).length ==
            0) {
      return false;
    }
    return true;
  }

  Widget preferenceItem(Filter filter) {
    String title = "";
    String description = "";
    if (filter.title == "Months (for Momentum and Volatility Screens)") {
      Filter filter = filterOptions
          .singleWhere((element) => element.title == "Screener Model");
      if (filter != null) {
        FilterOption filterOption = filter.option.singleWhere(
          (element) => element.isSelected == true,
          orElse: () => null,
        );
        if (filterOption.apiKey == "mom") {
          title = "Change in price over 6,9,12 months";
          description =
              "Choose period over which price return is to be calculated";
        } else {
          title = "Historical volatility (6, 9, 12 months)";
          description =
              "Choose period over which average daily price return volatility  is to be calculated";
        }
      }
    } else {
      title = contentForInformationIcon[filter.title]['title'];
      description = contentForInformationIcon[filter.title]['description'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16, right: 8, top: 8),
                child: Text(
                  filter.title,
                  style: bodyText5.apply(
                      color: Color(0xff383838), fontWeightDelta: 2),
                ),
              ),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message: "${title}\n${description}",
                child: InkWell(
                  onTap: () {
                    loadInformation(title, description);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: svgImage(
                      "assets/icon/information.svg",
                      color: Colors.grey,
                      height: 12,
                      width: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            height: 56,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: filter.option
                  .map((e) => Padding(
                        padding: EdgeInsets.only(
                            left: filter.option.indexOf(e) == 0 ? 16 : 8,
                            right: filter.option.indexOf(e) ==
                                    filter.option.length - 1
                                ? 16
                                : 0),
                        child: optionCard(filter, e),
                      ))
                  .toList(),
            ),
          ),
        ),
        filter.title == "Number of Holdings" && !countValidate()
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
                child: Text(
                    "This combination is not workable. Please select a lower number of holdings or add more sectors for analysis",
                    style: TextStyle(color: colorRed)))
            : emptyWidget
      ],
    );
  }

  void loadInformation(String title, String description) {
    bottomAlertBox(
      context: context,
      title: title,
      description: description,
    );
  }

  void showInfo(String title, String data) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: bodyText5.apply(fontWeightDelta: 2),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                      ))
                ],
              ),
            ),
            Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 72),
                child: Text(
                  data,
                  style: bodyText1,
                ))
          ]);
        });
  }

  Widget optionCard(Filter filter, FilterOption option) {
    return InkWell(
      onTap: () {
        if (filter.isMultiSelect) {
          setState(() {
            option.isSelected = !option.isSelected;
          });
        } else {
          if (filter.title == "Screener Model") {
            if (option.name == "Value") {
              _showValueType = true;
              _showMonths = false;
            } else {
              _showMonths = true;
              _showValueType = false;
            }
          }
          setState(() {
            filter.option.forEach((element) {
              element.isSelected = false;
            });
            option.isSelected = true;
          });
        }
        calculateFilteredStockCount();
      },
      child: ConstrainedBox(
        constraints: new BoxConstraints(
          minWidth: MediaQuery.of(context).size.width / 3,
        ),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: option.isSelected
                      ? AppColor.colorBlue
                      : Colors.grey.withAlpha(Alpha.P40),
                  width: 1),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(option.name,
                  style: bodyText1.apply(
                      color: option.isSelected
                          ? AppColor.colorBlue
                          : Color(0xffbcbcbc))),
            ),
          ),
        ),
      ),
    );
  }

  void calculateFilteredStockCount() {
    Filter sizeFilter = filterOptions[0];
    Filter sectorFilter = filterOptions[1];
    int newCount = 0;

    FilterOption sizeFilterOption =
        sizeFilter.option.firstWhere((element) => element.isSelected);
    var selectedSectors = sectorFilter.option
        .where((element) => element.isSelected)
        .toList()
        .map((e) => e.name);

    if (sizeFilterOption.apiKey != "ALL_CAP") {
      if (selectedSectors.isNotEmpty) {
        setState(() {
          filterStockData = stocksResponse.response
              .where((element) =>
                  element.core2 == sizeFilterOption.name &&
                  selectedSectors.contains(element.trbcEconomicSector))
              .toList();
          newCount = filterStockData.length;
          filterStockCount = newCount;
        });
      } else {
        setState(() {
          filterStockData = stocksResponse.response
              .where((element) => element.core2 == sizeFilterOption.name)
              .toList();
          newCount = 0; //filterStockData.length;
          filterStockCount = 0; //newCount;
        });
      }
    } else {
      if (selectedSectors.isNotEmpty) {
        setState(() {
          filterStockData = stocksResponse.response
              .where((element) =>
                  selectedSectors.contains(element.trbcEconomicSector))
              .toList();
          newCount = filterStockData.length;
          filterStockCount = newCount;
        });
      } else {
        setState(() {
          newCount = stocksResponse.response.length;
          filterStockCount = newCount;
        });
      }
    }
  }

  void filterOption(Filter optionViaNetwork) {
    // var options = [];
    var options = <Filter>[];
    options.add(Filter("Size", false, [
      FilterOption("Large Cap", "LARGE_CAP", isSelected: true),
      FilterOption("Mid Cap", "MID_CAP"),
      FilterOption("Large & Mid Cap", "ALL_CAP"),
    ]));
    options.add(optionViaNetwork);
    options.add(Filter("Number of Holdings", false, [
      FilterOption("4", "4", isSelected: true),
      FilterOption("6", "6"),
      FilterOption("8", "8"),
      FilterOption("10", "10"),
      FilterOption("12", "12"),
      FilterOption("15", "15"),
    ]));
    options.add(Filter("Weightage", false, [
      FilterOption("Equal Weights", "EQ", isSelected: true),
      FilterOption("Risk Adjusted Weights", "MVO"),
    ]));
    options.add(Filter("Rebalancing Frequency", false, [
      FilterOption("Monthly", "M"),
      FilterOption("Quarterly", "Q", isSelected: true),
    ]));
    options.add(Filter("Screener Model", false, [
      FilterOption("Momentum", "mom"),
      FilterOption("Low Volatility", "vol"),
      FilterOption("Value", "val"),
    ]));
    options.add(Filter("Months (for Momentum and Volatility Screens)", false, [
      FilterOption("6 Months", "6", isSelected: true),
      FilterOption("9 Months", "9"),
      FilterOption("12 Months", "12"),
    ]));
    options.add(Filter("Value Type", true, [
      FilterOption("Price to Book", "PTBV", isSelected: true),
      FilterOption("Price to Earnings", "PE"),
      FilterOption("Price to Cash", "PC"),
      FilterOption("Dividend Yield", "DY"),
    ]));
    setState(() {
      filterOptions = options;
    });
  }

  _displaySnackBar(String message) {
    final snackBar = SnackBar(
        content: Text(
      message,
      style: bodyText6.copyWith(color: Colors.white),
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}

class Filter {
  String title;
  bool isMultiSelect;
  List<FilterOption> option;

  Filter(this.title, this.isMultiSelect, this.option);
}

class FilterOption {
  String name;
  String apiKey;
  bool isSelected;

  FilterOption(this.name, this.apiKey, {this.isSelected = false});
}

MyGlobals myGlobals = new MyGlobals();

class MyGlobals {
  GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}
