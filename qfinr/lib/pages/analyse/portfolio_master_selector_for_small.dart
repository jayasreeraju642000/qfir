import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('PortfolioMasterSelector');

class PortfolioMasterSelectorSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  final String layout;

  final String portfolioMasterID;
  final String isSideMenuHeadingSelected;
  final String isSideMenuSelected;

  PortfolioMasterSelectorSmall(this.model,
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
    extends State<PortfolioMasterSelectorSmall> {
  final controller = ScrollController();
  Map _selectedPortfolios = {};

  Future<Null> _analyticsChangeSelectionEvent() async {
    await widget.analytics.logEvent(name: "select_content", parameters: {
      'item_id': "view_details",
      'item_name': "view_details_change_selection",
      'content_type': "change_selection_click",
    });
  }

  void initState() {
    super.initState();
/*
		if(widget.action == "analyzer"){
			Navigator.pushNamed(context, '/riskProfiler');
		} */
  }

  Widget _submitButton() {
    bool flagCheck = false;
    bool isOnlyDepositSelected = true;
    int count = 0;
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
        count++;
      }
    });
    if (widget.action == 'merge') {
      isOnlyDepositSelected = false;
    }
    return gradientButton(
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
            if (count == 0) {
              customAlertBox(
                type: "error",
                context: context,
                title: "No portfolios are selected",
                description:
                    "You must select atleast one portfolio for analyzing",
              );
            } else {
              customAlertBox(
                type: "error",
                context: context,
                title: "Deposit portfolios cannot be analyzed",
                description:
                    "Deposit portfolios are not expected to have market risks, therefore a comparison with other market-linked benchmarks is not feasible",
              );
            }
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

    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    changeStatusBarColor(Colors.white);
    return Scaffold(
        appBar: commonScrollAppBar(
            controller: controller,
            bgColor: Colors.white,
            actions: [
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, widget.model.redirectBase),
                child: AppbarHomeButton(),
              )
            ]),
        body: widget.model.isLoading
            ? preLoader()
            : mainContainer(
                containerColor: Colors.white,
                context: context,
                paddingLeft: getScaledValue(16),
                paddingRight: getScaledValue(16),
                child: _buildBody()));
  }

  Widget _buildBody() {
    List<Widget> _children = [];

    _children.add(
      Container(
          margin: EdgeInsets.only(
              left: getScaledValue(10.0),
              right: getScaledValue(10.0),
              top: getScaledValue(5.0),
              bottom: getScaledValue(25.0)),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Portfolios', style: headline1),
              SizedBox(height: getScaledValue(5)),
              Text(
                  widget.action == "default"
                      ? 'Select portfolios that you want to view and compare with benchmarks frequently. You will see the combined performance of all selected portfolios everyday on the homepage.'
                      : widget.action == "analyzer"
                          ? 'Select one or more portfolios to build a single combined portfolio. Get an in-depth assessment of risks and rewards of this combination in isolation, and in comparison with a suitable benchmark'
                          : widget.action == "stress"
                              ? 'Select one or more portfolios to build a single combined portfolio. Compare the performance of the combination against multiple benchmarks during high-stress periods in history.\n\nWe drop any of your portfolio holdings that were not in existence during the historical period.'
                              : widget.action == "merge"
                                  ? 'Select one or more portfolios that you want to merge with your selected portfolio and make a new combined portfolio'
                                  : widget.action == "dividend"
                                      ? 'Select one or more portfolios to build a single combined portfolio. Get a breakdown of forecasted dividends over the next two quarters for this combination'
                                      : " ",
                  style: bodyText1)
            ],
          )),
    );

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
                _children.add(_portfolioMasterBoxContainer(portfolio));
              }
            } else {
              if (portfolio['portfolios']['Deposit'] == null) {
                _children.add(_portfolioMasterBoxContainer(portfolio));
              }
            }
          }
        } else {
          _children.add(_portfolioMasterBoxContainer(portfolio));
        }

        if (widget.layout == "checkbox") {
          var mainPortfolio =
              widget.model.userPortfoliosData[widget.portfolioMasterID];
          if (mainPortfolio != null) {
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
                    margin:
                        EdgeInsets.symmetric(horizontal: getScaledValue(15)),
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
                    margin:
                        EdgeInsets.symmetric(horizontal: getScaledValue(15)),
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
      }
    });

    return Container(
      color: Colors.white,
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            child: ListView(
              physics: ClampingScrollPhysics(),
              children: _children,
            ),
          ),
          SizedBox(
            height: getScaledValue(15),
          ),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _portfolioMasterBoxContainer(Map portfolioData) {
    if (widget.layout == "checkbox") {
      return Container(
        margin: EdgeInsets.symmetric(
            vertical: getScaledValue(10), horizontal: getScaledValue(10)),
        child: _portfolioMasterBox(portfolioData),
      );
    } else if (widget.layout == "border") {
      return GestureDetector(
        onTap: () {
          updateValue(portfolioData, !_selectedPortfolios[portfolioData['id']]);
        },
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: getScaledValue(10), horizontal: getScaledValue(10)),
          padding: EdgeInsets.all(getScaledValue(16)),
          decoration: BoxDecoration(
            border: Border.all(
                color: (_selectedPortfolios[portfolioData['id']] == true
                    ? colorBlue
                    : Color(0xffe8e8e8)),
                width: 1),
            borderRadius: BorderRadius.circular(getScaledValue(4)),
          ),
          child: _portfolioMasterBox(portfolioData),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _portfolioMasterBox(Map portfolioData) {
    List zones = portfolioData['portfolio_zone'].split('_');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.layout == "checkbox"
            ? Container(
                height: getScaledValue(20),
                width: getScaledValue(20),
                margin: EdgeInsets.only(
                    right: getScaledValue(10), top: getScaledValue(5)),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff0033cc), width: 1),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Checkbox(
                    activeColor: Color(0xffcedfff),
                    checkColor: Color(0xff034bd9),
                    value: _selectedPortfolios[portfolioData['id']],
                    onChanged: (newValue) =>
                        updateValue(portfolioData, newValue),
                  ),
                ),
              )
            : emptyWidget,
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(portfolioData['portfolio_name'], style: portfolioBoxName),
            SizedBox(height: getScaledValue(6)),
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
                SizedBox(width: getScaledValue(7)),
                Row(
                    children: zones
                        .map((item) => Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: widgetZoneFlag(item)))
                        .toList()),

                // fund count
              ],
            ),
            SizedBox(height: getScaledValue(10)),
            _fundCount(portfolioData)
          ],
        )),
        SizedBox(width: getScaledValue(20)),
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
    );
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

    return Text(limitChar(fundCount, length: 20),
        style: portfolioBoxStockCountType);
  }
}
