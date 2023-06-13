import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/main.dart';
import 'package:qfinr/pages/analyse/widget_common_analyse.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('PortfolioMasterSelector');

class PortfolioMasterSelectorLarge extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  final String layout;

  String portfolioMasterID;
  final String isSideMenuHeadingSelected;
  final String isSideMenuSelected;

  PortfolioMasterSelectorLarge(this.model,
      {this.analytics,
      this.observer,
      this.action,
      this.portfolioMasterID = "",
      this.layout = "checkbox",
      this.isSideMenuHeadingSelected,
      this.isSideMenuSelected});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioMasterSelectorState();
  }
}

class _PortfolioMasterSelectorState
    extends State<PortfolioMasterSelectorLarge> {
  final controller = ScrollController();
  Map _selectedPortfolios = {};
  bool benchMarkAnalyzeLoader = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _analyticsChangeSelectionEvent() async {
    await widget.analytics.logEvent(name: "select_content", parameters: {
      'item_id': "view_details",
      'item_name': "view_details_change_selection",
      'content_type': "change_selection_click",
    });
  }

  Future<Null> _analyticsAnalyseEvent() async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "analyse_portfolio",
      'item_name': "analyse_portfolio_benchmark_next_button",
      'content_type': "click_next_button",
    });
  }

  Future<Null> _analyticsBenchmarkSelectorEvent(String benchmarkValue) async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "analyse_portfolio",
      'item_name': "analyse_portfolio_select_benchmark",
      'content_type': "select_benchmark_icon_click",
      'item_list_name': benchmarkValue
    });
  }

  Future<Null> _analyticsZoneFlagSelectorEvent(String zone) async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "analyse_portfolio",
      'item_name': "analyse_portfolio_select_country_flag",
      'content_type': "select_country_flag_click",
      'item_list_name': zone
    });
  }

  String _selectedBenchmarks = "";
  Map benchmarks = {};
  Map benchmarks1 = {};
  String _selectedZone = "in";

  Map zoneBenchmarks = {};
  Map zoneBenchmarks_old = {
    "in": {
      'NIFTY50': {
        'value': 'NIFTY 50',
        'zone': 'in',
        'description':
            'An Index of top 50 companies listed on NSE, based on their free-float market-caps'
      },
      'NIFTY100': {
        'value': 'NIFTY 100',
        'zone': 'in',
        'description':
            'An Index of top 100 companies listed on NSE, based on their full market-caps'
      },
      'BSE200': {
        'value': 'BSE 200',
        'zone': 'in',
        'description':
            'An Index of top 200 companies listed on BSE, based on their free-float market-caps'
      },
      'NIFTY500': {
        'value': 'NIFTY 500',
        'zone': 'in',
        'description':
            'An Index of top 500 companies listed on NSE, based on their full market-caps'
      },
    },
    "us": {
      'GSPC': {
        'value': 'S&P 500 PR',
        'zone': 'us',
        'description':
            'An Index of top 500 companies listed on NASDAQ, based on their full market-caps'
      },
      'NASDAQ': {
        'value': 'NASDAQ 100 PR',
        'zone': 'us',
        'description':
            'An Index of top 100, most actively traded, non-financial companies listed on NASDAQ'
      },
    },
    "sg": {
      'STI': {
        'value': 'Straits Times Index TR',
        'zone': 'sg',
        'description':
            'An Index of top 30 companies by market cap, listed on the Singapore Exchange'
      },
    }
  };

  List<String> zone_list = [];

  void getBenchmarkSelectors() async {
    setState(() {
      widget.model.setLoader(true);
    });
    final response = await widget.model.getBenchmarkSelectors();

    int i = 0;
    if (response['status'] == true) {
      zoneBenchmarks = response['response'];

      zoneBenchmarks[zone_list[0]].forEach((key, value) {
        i++;
        benchmarks[key] = value;
        if (i == 1) {
          _selectedBenchmarks = key;
        }
      });

      _selectedZone = zone_list[0].toString();
    }

    setState(() {
      widget.model.setLoader(false);
    });
  }

  void initState() {
    if (widget.action == "analyzer") {
      if (!zone_list.isEmpty) {
        zone_list.clear();
      }
      zone_list.add("in");
      zone_list.add("gl");
      getBenchmarkSelectors();
    }

    // _selectedBenchmarks = 'NIFTY50';

    // widget.model.userSettings['allowed_zones'].forEach((zone) {
    //   if (zoneBenchmarks.containsKey(zone)) {
    //     log.d("Testing zoneBenchmarks");
    //     log.d(zoneBenchmarks);

    //     zone_list.add(zone);

    //     zoneBenchmarks[zone].forEach((key, value) {
    //       benchmarks[key] = value;
    //     });
    //   }
    // });

    //_selectedZone = zone_list[0].toString();

    super.initState();
  }

  // @override
  // void setState(fn) {
  //   if (mounted) {
  //     super.setState(fn);
  //   }
  // }

  Widget _submitButton() {
    bool flagCheck = false;
    bool isOnlyDepositSelected = true;
    _selectedPortfolios.forEach((key, value) {
      if (value == true) {
        flagCheck = true;
        if (widget.model.userPortfoliosData.containsKey(key)) {
          var portfolio = widget.model.userPortfoliosData[key];
          if (portfolio['portfolios'] == null ||
              portfolio['portfolios']['Deposit'] == null) {
            isOnlyDepositSelected = false;
          }
        }
      }
    });
    if (widget.action == 'merge') {
      isOnlyDepositSelected = false;
    }
    return gradientButtonLarge(
        context: context,
        caption:
            ["analyzer", "merge", "dividend", "stress"].contains(widget.action)
                ? "next"
                : "save",
        onPressFunction: () {
          if (flagCheck &&
              (!isOnlyDepositSelected ||
                  (isOnlyDepositSelected && widget.action != "analyzer"))) {
            formResponse();
          } else {
            customAlertBox(
              type: "error",
              context: context,
              title: "Deposit portfolios cannot be analyzed",
              description:
                  "Deposit portfolios are not expected to have market risks, therefore a comparison with other market-linked benchmarks is not feasible",
            );
          }
        });
  }

  void formResponse() async {
    List selectedPortfolios = [];
    _selectedPortfolios.forEach((key, value) {
      if (value == true) {
        selectedPortfolios.add(key);
      }
    });
    if (widget.action == "default") {
      await widget.model.setDefaultPortfolios(portfolios: selectedPortfolios);
      Navigator.pop(context);
    } else if (widget.action == "merge") {
      Navigator.pushNamed(context, '/merge_portfolio_portfolio_name',
          arguments: {'selectedPortfolioMasterIDs': _selectedPortfolios});
    } else if (widget.action == "analyzer") {
      Navigator.pushNamed(context, '/benchmark_selector',
          arguments: {'selectedPortfolioMasterIDs': _selectedPortfolios});
    } else if (widget.action == "stress") {
      setState(() {
        widget.model.setLoader(true);
      });
      Map<String, dynamic> responseData =
          await widget.model.portfolioStressTest(_selectedPortfolios);
      responseData;
      changeStatusBarColor(Color(0xffefd82b));
      Navigator.pushNamed(context, '/stressTestReport',
          arguments: {'responseData': responseData});
      setState(() {
        widget.model.setLoader(false);
      });
      changeStatusBarColor(Color(0xffefd82b));
    } else if (widget.action == "dividend") {
      setState(() {
        widget.model.setLoader(true);
      });
      Map<String, dynamic> responseData =
          await widget.model.dividendPortfolio(_selectedPortfolios);
      changeStatusBarColor(Color(0xffefd82b));
      Navigator.pushNamed(context, '/portfolioDividendReport',
          arguments: {'responseData': responseData});
      setState(() {
        widget.model.setLoader(false);
      });
    }

    //Map<String, dynamic> responseData = await model.verifyPasscode(context, widget.model.userData.emailID, _passcode, _fcmToken);
    //formResponseHandler(responseData);
    await _analyticsChangeSelectionEvent();
  }

  void formResponseAnalyseReport() async {
    setState(() {
      widget.model.setLoader(true);
    });

    Map<String, dynamic> responseData = await widget.model.analyzerPortfolio(
        {'benchmark': _selectedBenchmarks, 'risk_profile': 'moderate'},
        _selectedPortfolios);

    if (responseData['status'] == true) {
      // Navigator.pushReplacementNamed(context, '/home_new');
      Navigator.pushNamed(context, '/portfolioAnalyzerReport', arguments: {
        'responseData': responseData,
        'selectedPortfolioMasterIDs': _selectedPortfolios,
        'benchmark': _selectedBenchmarks
      }).then((value) => {});
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
      // customAlertBox(
      //     context: context,
      //     type: "error",
      //     title: "Error!",
      //     description: responseData['response'],
      //     buttons: null);
    }

    setState(() {
      widget.model.setLoader(false);
    });
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
//
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
          body: _buildBodyNvaigationLeftBar()),
    );
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
                isSideMenuHeadingSelected:
                    int.parse(widget.isSideMenuHeadingSelected),
                isSideMenuSelected: int.parse(widget.isSideMenuSelected)),
        Expanded(
            child: widget.model.isLoading
                ? preLoader()
                : benchMarkAnalyzeLoader
                    ? _preLoaderLarge()
                    : _buildBodyContentLarge()),
      ],
    );
  }

  Widget _buildBodyContentLarge() {
    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(left: 27.0, top: 55.0, right: 60.0, bottom: 87),
      color: Color(0xfff5f6fa),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _analyseHeader(),
          SizedBox(
            height: getScaledValue(16),
          ),
          _selectProtfoliHeader(),
          SizedBox(
            height: getScaledValue(1),
          ),
          _portfolioMasterBoxList(),
          SizedBox(
            height: getScaledValue(24),
          ),
          widget.action == "analyzer" ? _buildSelectBenchMark() : emptyWidget,
          widget.action == "analyzer"
              ? emptyWidget
              : SizedBox(height: getScaledValue(24)),
          widget.action == "analyzer" ? emptyWidget : _submitButton(),
        ],
      ),
    ));
  }

  _analyseHeader() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      widget.action == "default"
                          ? 'Select portfolios that you want to view and compare with benchmarks frequently. You will see the combined performance of all selected portfolios everyday on the homepage.'
                          : widget.action == "analyzer"
                              ? 'Analyse Your Portfolios'
                              : widget.action == "stress"
                                  ? 'Stress Test'
                                  : widget.action == "merge"
                                      ? "Merge Portfolio" //'Select one or more portfolios that you want to merge with your selected portfolio and make a new combined portfolio'
                                      : widget.action == "dividend"
                                          ? 'Cashflow Forecast'
                                          : " ",
                      style: headline1_analyse),

                  // Text("Analyse Your Portfolios", style: headline1_analyse),
                  SizedBox(
                    height: 12,
                  ),

                  Text(
                      widget.action == "default"
                          ? 'Select portfolios that you want to view and compare with benchmarks frequently. You will see the combined performance of all selected portfolios everyday on the homepage.'
                          : widget.action == "analyzer"
                              ? 'Deep dive into your portfolios.Compare against benchmarks. UnderStand their suitability and lots more...'
                              : widget.action == "stress"
                                  ? 'Compare the historical performance of your portofolio during periods of high stress in the markets'
                                  : widget.action == "merge"
                                      ? 'Select one or more portfolios that you want to merge with your selected portfolio and make a new combined portfolio'
                                      : widget.action == "dividend"
                                          ? 'Get a breakdown of forecasted cash flows over the next 6 months for dividends from equity, interest and principal flows from bonds and deposits'
                                          : " ",
                      style: headline2_analyse),
                  // Text("Deep dive into your portfolios.Compare against benchmarks. UnderStand their suitability and lots more...", style: headline2_analyse),
                ])),
          ),
          Image.asset(
            "assets/icon/group_ic.png",
          ),
        ],
      ),
    );
  }

//
  _selectProtfoliHeader() {
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
                height: 16,
              ),
              Text("Select a Portfolio", style: headline3_analyse),
              SizedBox(
                height: 6,
              ),

              Text(
                  widget.action == "analyzer"
                      ? 'Select one or more portfolios to build a single combined portfolio. Get an in-depth assessment of risks and rewards of this combination in isolation, and in comparison with a suitable benchmark'
                      : widget.action == "stress"
                          ? 'Select one or more portfolios to build a single combined portfolio. Compare the performance of the combination against multiple benchmarks during high-stress periods in history.\nWe drop any of your portfolio holdings that were not in existence during the historical period.'
                          : widget.action == "dividend"
                              ? 'Select one or more portfolios to build a single combined portfolio. Get a breakdown of forecasted dividends over the next two quarters for this combination'
                              : " ",
                  style: headline4_analyse),
              //  Text("Select one or more potfolios to build a single combined portfolio.Get an in-depth assessment of risks,rewards and suitability of this combination.",
              //  style: headline4_analyse),
              SizedBox(
                height: 15.5,
              ),
            ]));
  }

  Widget _portfolioMasterBoxList() {
    List<Widget> _children = [];

    widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
      if (portfolioMasterID != '0') {
        if (!_selectedPortfolios.containsKey(portfolioMasterID)) {
          if (widget.action == "merge") {
            if (portfolio['portfolios'] != null &&
                portfolio['id'] == widget.portfolioMasterID) {
              _selectedPortfolios[portfolioMasterID] = true;
            } else {
              _selectedPortfolios[portfolioMasterID] = false;
            }
          } else {
            _selectedPortfolios[portfolioMasterID] =
                (portfolio['default'] == '1' ? true : false);
          }
        }

        if (widget.action == 'merge') {
          if (widget.model.userPortfoliosData
              .containsKey(widget.portfolioMasterID)) {
            var mainPortfolio =
                widget.model.userPortfoliosData[widget.portfolioMasterID];
            bool isDeposit = false;
            if (mainPortfolio['portfolios']['Deposit'] != null) {
              isDeposit = true;
            } else {
              isDeposit = false;
            }
            if (isDeposit) {
              if (portfolio['portfolios']['Deposit'] != null) {
                _children.add(_portfolioMasterBoxContainerLarge(portfolio));
              }
            } else {
              if (portfolio['portfolios']['Deposit'] == null) {
                _children.add(_portfolioMasterBoxContainerLarge(portfolio));
              }
            }
          }
        } else {
          _children.add(_portfolioMasterBoxContainerLarge(portfolio));
        }

        // widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
        //   if (portfolioMasterID != '0') {
        //     if (!_selectedPortfolios.containsKey(portfolioMasterID)) {
        //       if (widget.action == "merge") {
        //         if (portfolio['portfolios'] != null &&
        //             portfolio['id'] == widget.portfolioMasterID) {
        //           _selectedPortfolios[portfolioMasterID] = true;
        //         } else {
        //           _selectedPortfolios[portfolioMasterID] = false;
        //         }
        //       } else {
        //         _selectedPortfolios[portfolioMasterID] =
        //             (portfolio['default'] == '1' ? true : false);
        //       }
        //     }

        //    _children.add(_portfolioMasterBoxContainerLarge(portfolio));

        // if (widget.layout == "checkbox")
        //   _children.add(Container(
        //       margin: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
        //       child: Divider(
        //         height: 2,
        //         color: Color(0xffdadada),
        //       )));

        if (widget.layout == "checkbox") {
          var mainPortfolio =
              widget.model.userPortfoliosData[widget.portfolioMasterID];
          bool isDeposit = false;
          if (mainPortfolio['portfolios']['Deposit'] != null) {
            isDeposit = true;
          } else {
            isDeposit = false;
          }
          if (isDeposit) {
            if (portfolio['portfolios']['Deposit'] != null) {
              _children.add(
                Container(
                  margin: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Divider(
                    height: 2,
                    color: Color(0xffdadada),
                  ),
                ),
              );
            }
          } else {
            if (portfolio['portfolios']['Deposit'] == null) {
              _children.add(
                Container(
                  margin: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Divider(
                    height: 2,
                    color: Color(0xffdadada),
                  ),
                ),
              );
            }
          }
        }
      }
    });

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      width: MediaQuery.of(context).size.width * 1.0,
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          ListView(
            shrinkWrap: true,
            controller: controller,
            physics: ClampingScrollPhysics(),
            children: _children,
          ),
        ],
      ),
    );
  }

  Widget _portfolioMasterBoxContainerLarge(Map portfolioData) {
    if (widget.layout == "checkbox") {
      return Container(
        margin: EdgeInsets.symmetric(
            vertical: getScaledValue(10), horizontal: getScaledValue(10)),
        child: _portfolioMasterBoxLarge(portfolioData),
      );
    } else if (widget.layout == "border") {
      return GestureDetector(
        onTap: () => {},
        // updateValue(
        //    portfolioData, !_selectedPortfolios[portfolioData['id']]),
        child: Container(
          color: _selectedPortfolios[portfolioData['id']] == true
              ? colorBlue
              : Color(0xffecf1fa),
          //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),
          //padding: EdgeInsets.all(getScaledValue(16)),
          // decoration: BoxDecoration(
          // 	border: Border.all(color: (_selectedPortfolios[portfolioData['id']] == true ? colorBlue : Color(0xffe8e8e8)), width: 1),
          // 	borderRadius: BorderRadius.circular(getScaledValue(4)),
          // ),
          child: _portfolioMasterBoxLarge(portfolioData),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _portfolioMasterBoxLarge(Map portfolioData) {
    List zones = portfolioData['portfolio_zone'].split('_');

    return Container(
        color: _selectedPortfolios[portfolioData['id']] == true
            ? Color(0xffecf1fa)
            : Colors.white,
        width: MediaQuery.of(context).size.width * 1.0,
        padding:
            EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0, bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      activeColor: Color(0xffcedfff),
                      checkColor: Color(0xff034bd9),
                      value: _selectedPortfolios[portfolioData['id']] == true
                          ? true
                          : false,
                      onChanged: (bool newValue) {
                        setState(() {
                          updateValue(portfolioData,
                              !_selectedPortfolios[portfolioData['id']]);
                        });
                      },
                    ),
                    SizedBox(
                      width: getScaledValue(16),
                    ),
                    Container(
                        width: getScaledValue(250),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(portfolioData['portfolio_name'],
                                style: bodyText0_analyse),
                            Row(
                                children: zones
                                    .map((item) => Padding(
                                        padding: EdgeInsets.only(right: 4.0),
                                        child: widgetZoneFlag(item)))
                                    .toList()),
                          ],
                        )),
                    Container(
                      width: getScaledValue(100),
                      child: Row(
                        children: [
                          Container(
                            child: portfolioData['type'] == '1'
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
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                _fundCountLarge(portfolioData),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(removeDecimal(portfolioData['value']),
                        style: portfolioBoxValue),
                    Row(
                      children: <Widget>[
                        (portfolioData['change_sign'] == "up"
                            ? Icon(
                                Icons.trending_up,
                                color: Colors.green,
                                size: getScaledValue(16.0),
                              )
                            : portfolioData['change_sign'] == "down"
                                ? Icon(
                                    Icons.trending_down,
                                    color: colorRed,
                                    size: getScaledValue(16.0),
                                  )
                                : emptyWidget),
                        SizedBox(width: getScaledValue(5)),
                        (portfolioData['change_sign'] == "up" ||
                                portfolioData['change_sign'] == "down"
                            ? Text(portfolioData['change'].toString() + "%",
                                style: portfolioBoxReturn)
                            : emptyWidget),
                      ],
                    )
                  ],
                )
              ],
            ),
          ],
        ));
  }

  Widget _fundCountLarge(Map portfolioData) {
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

    return Text(fundCount, style: portfolioBoxStockCountType);

    // return Wrap(
    // 	//crossAxisAlignment: CrossAxisAlignment.end,

    // 	children: _children textAlign: TextAlign.start
    // );
  }

  Function updateValue(portfolioData, newValue) {
    try {
      if (portfolioData['portfolios'] != null) {
        if (widget.action == "merge" &&
            portfolioData['id'] == widget.portfolioMasterID) {
          return null;
        }
        setState(() {
          _selectedPortfolios[portfolioData['id']] = newValue;
        });
      } else {
        return null;
      }
    } catch (e) {
      log.e(e);
      return null;
    }
    return null;
  }

  // Widget _portfolioBenchMarkList() {
  //   return PreferredSize(
  //       preferredSize: Size(MediaQuery.of(context).size.width,
  //           MediaQuery.of(context).size.height),
  //       child: BenchmarkSelector(widget.model,
  //           analytics: widget.analytics,
  //           observer: widget.observer,
  //           action: "",
  //           selectedPortfolioMasterIDs: _selectedPortfolios,
  //           refreshParent: refreshParent));
  // }

  refreshParent(bool isloading) {
    setState(() {
      // benchMarkAnalyzeLoader = isloading;
      widget.model.setLoader(isloading);
    });
  }

  // Widget _submitButtonAnalyseReport() {
  //   return gradientButtonLarge(
  //       context: context,
  //       caption: "analyse",
  //       onPressFunction: () => formResponseAnalyseReport());
  // }

  Widget _submitButtonAnalyseReport() {
    bool flagCheck = false;
    bool isOnlyDepositSelected = true;
    _selectedPortfolios.forEach((key, value) {
      if (value == true) {
        flagCheck = true;
        if (widget.model.userPortfoliosData.containsKey(key)) {
          var portfolio = widget.model.userPortfoliosData[key];
          if (portfolio['portfolios'] == null ||
              portfolio['portfolios']['Deposit'] == null) {
            isOnlyDepositSelected = false;
          }
        }
      }
    });
    if (widget.action == 'merge') {
      isOnlyDepositSelected = false;
    }
    return gradientButtonLarge(
        context: context,
        caption: "analyse",
        onPressFunction: () {
          if (flagCheck &&
              (!isOnlyDepositSelected ||
                  (isOnlyDepositSelected && widget.action != "analyzer"))) {
            _analyticsAnalyseEvent();
            formResponseAnalyseReport();
          } else {
            customAlertBoxLargeAnalyse(
              type: "error",
              context: context,
              title: "Deposit portfolios cannot be analyzed",
              description:
                  "Deposit portfolios are not expected to have market risks, therefore a comparison with other market-linked benchmarks is not feasible",
            );
          }
        });
  }

// benchMark

  Widget _preLoaderLarge() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            svgImage('assets/icon/icon_analyzer_loader.svg',
                height: getScaledValue(125)),
            SizedBox(height: getScaledValue(33)),
            Text('Analyzing your investments…', style: preLoaderBodyText1),
          ],
        ),
        Container(
            alignment: Alignment.bottomCenter,
            child:
                Text('hold on tight'.toUpperCase(), style: preLoaderBodyText2)),
      ],
    );
  }

  Widget _buildSelectBenchMark() {
    return Container(
      color: Color(0xfff5f6fa),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectBenchHeader(),
          SizedBox(
            height: getScaledValue(1),
          ),
          _portfolioBenchMarkList(),
          SizedBox(
            height: getScaledValue(24),
          ),
          _submitButtonAnalyseReport()
        ],
      ),
    );
  }

  _selectBenchHeader() {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      padding: EdgeInsets.only(left: 24.0, top: 0.0, right: 24.0, bottom: 0.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: getScaledValue(24),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select a BenchMark", style: headline5_analyse),
                  Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Country", style: headline2_analyse),
                          SizedBox(
                            width: getScaledValue(14),
                          ),

                          Container(
                            height: getScaledValue(33),
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border:
                                    Border.all(color: colorBlue, width: 1.25),
                                color: Colors.white),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  hint: Text(
                                    _selectedZone.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: colorBlue,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: colorBlue,
                                  ),
                                  value: _selectedZone,
                                  selectedItemBuilder: (context) {
                                    return zone_list.map((String item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item.toUpperCase(),
                                          style: heading_alert_view_all,
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }).toList();
                                  },
                                  items: zone_list.map((String item) {
                                    var textColor =
                                        (_selectedZone.contains(item))
                                            ? Colors.white
                                            : MyApp.commonPrimaryColor;
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item.toUpperCase(),
                                        style: heading_alert_view_all.copyWith(
                                            color: textColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedZone = value;
                                    });
                                    //  _currencySelectionForWeb(currencyValues);
                                  }),
                            ),
                          ),

                          // Container(
                          //   padding: EdgeInsets.only(
                          //       left: 6, top: 2, right: 6, bottom: 2),
                          //   height: getScaledValue(30),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(5.0),
                          //     border: Border.all(color: colorBlue, width: 1.25),
                          //   ),
                          //   alignment: Alignment.center,
                          //   child: GestureDetector(
                          //       onTap: () => filterPopup(),
                          //       child: Row(
                          //         children: [
                          //           Text(
                          //               _selectedZone1.toUpperCase().toString(),
                          //               style: heading_alert_view_all),
                          //           Icon(Icons.keyboard_arrow_down,
                          //               color: Color(0xff034bd9)),
                          //         ],
                          //       )
                          //       /* Image.asset('assets/icon/icon_filter.png', height: getScaledValue(16), width: getScaledValue(20)) */
                          //       ),
                          // ),
                        ]),
                  )
                ]),
            SizedBox(
              height: getScaledValue(2),
            ),
            Text(
                "Select a benchmark for comparison with the portfolio combination that you have made.",
                style: headline6_analyse),
            SizedBox(
              height: getScaledValue(19),
            ),
          ]),
    );
  }

  // void filterPopup() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(builder: (context, StateSetter setState) {
  //         _setState = setState;
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.0),
  //           ),
  //           title: null,
  //           content: _filterPopup(),
  //           actions: <Widget>[
  //             TextButton(
  //               style: qfButtonStyle0,
  //               child: Text("Cancel", style: dialogBoxActionInactive),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             TextButton(
  //               style: qfButtonStyle0,
  //               child: Text("Save", style: dialogBoxActionActive),
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 setState(() {
  //                   _selectedZone1 = _selectedZone;
  //                   //widget.model.setLoader(true);
  //                 });
  //                 // Map<String, dynamic> responseData =
  //                 //     await widget.model.changeCurrency(_selectedCurrency);
  //                 // if (responseData['status'] == true) {
  //                 //   await getBenchmarkPerformance();
  //                 //   await widget.model.fetchOtherData();
  //                 // }
  //                 setState(() {
  //                   //widget.model.setLoader(false);
  //                 });
  //               },
  //             )
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  // Widget _filterPopup() {
  //   return Container(
  //     width: getScaledValue(360),
  //     height: double.maxFinite < getScaledValue(365)
  //         ? double.maxFinite
  //         : null, // double.maxFinite,
  //     child: Form(
  //         child: ListView(
  //       shrinkWrap: true,
  //       children: <Widget>[
  //         Row(
  //           children: <Widget>[
  //             Expanded(
  //                 child: DropdownButton<String>(
  //               hint: Text('Currency'),
  //               isExpanded: true,
  //               value: _selectedZone,
  //               items: zone_list.map((String item) {
  //                 return DropdownMenuItem<String>(
  //                   value: item,
  //                   child: Text(item),
  //                 );
  //               }).toList(),
  //               onChanged: (value) {
  //                 _setState(() {
  //                   _selectedZone = value;
  //                 });
  //               },
  //             )),
  //           ],
  //         ),
  //       ],
  //     )),
  //   );
  // }

  Widget _portfolioBenchMarkList() {
    List<Widget> _children_benchmark = [];

    // zoneBenchmarks.forEach((zone, benchmarks) {
    //   if (widget.model.userSettings['allowed_zones'].toString().contains(_selectedZone)) {
    //     _children.add(_benchmarkList(benchmarks));
    //   }
    // });
    //

    benchmarks.clear();

    if (_selectedZone == 'gl') {
      zoneBenchmarks.forEach((key, value) {
        if (key != 'in') {
          zoneBenchmarks[key].forEach((key, value) {
            benchmarks[key] = value;
          });
        }
      });
    } else {
      zoneBenchmarks[_selectedZone].forEach((key, value) {
        benchmarks[key] = value;
      });
    }

    benchmarks.forEach((benchmark, benchmarkData) {
      _children_benchmark.add(_benchmarkBoxLarge(benchmark, benchmarkData));
    });

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: MediaQuery.of(context).size.width *
                1.0 /
                MediaQuery.of(context).size.height *
                1.25,
            shrinkWrap: true,
            controller: controller,
            physics: ClampingScrollPhysics(),
            children: _children_benchmark,
          ),

          // ListView(
          //   shrinkWrap: true,
          // 	controller: controller,
          // 	physics: ClampingScrollPhysics(),
          // 	children: _children_benchmark,
          // ),
        ],
      ),
    );
  }

  Widget _benchmarkBoxLarge(String key, Map benchmarkData) {
    return GestureDetector(
        onTap: () async {
          _analyticsBenchmarkSelectorEvent(benchmarkData['value']);
          _analyticsZoneFlagSelectorEvent(benchmarkData['zone']);
          setState(() {
            _selectedBenchmarks = key;
          });
        },
        child: Container(
            margin: EdgeInsets.symmetric(
                vertical: getScaledValue(10), horizontal: getScaledValue(10)),
            padding: EdgeInsets.symmetric(
                vertical: getScaledValue(16), horizontal: getScaledValue(16)),
            decoration: BoxDecoration(
              border: Border.all(
                  color: (_selectedBenchmarks == key
                      ? colorBlue
                      : Color(0xffe8e8e8)),
                  width: 1),
              borderRadius: BorderRadius.circular(getScaledValue(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: getScaledValue(6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(benchmarkData['value'] ?? "", style: portfolioBoxName),
                    widgetZoneFlag(benchmarkData['zone'])
                  ],
                ),
                SizedBox(height: getScaledValue(10)),
                Text(benchmarkData['description'] ?? ""),
              ],
            )));
  }
}
