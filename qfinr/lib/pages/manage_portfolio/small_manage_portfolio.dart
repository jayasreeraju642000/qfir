import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/add_deposit.dart';
import 'package:qfinr/widgets/helpers/portfolio_helper.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('ManagePortfolio');

class SmallManagePortfolio extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  bool managePortfolio;
  bool reloadData;

  bool newPortfolio;
  String portfolioName;

  String portfolioMasterID;

  bool viewPortfolio;
  bool readOnly;

  SmallManagePortfolio(this.model,
      {this.analytics,
      this.observer,
      this.portfolioMasterID,
      this.managePortfolio = true,
      this.reloadData = true,
      this.viewPortfolio = false,
      this.newPortfolio = false,
      this.portfolioName,
      this.readOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _SmallManagePortfolioState();
  }
}

class _SmallManagePortfolioState extends State<SmallManagePortfolio> {
  final controller = ScrollController();
  var currentTabIndex = 0;

  Map portfolioMasterData = {};

  bool _ricSelected = false;

  String pathPDF = "";
  String sortType;
  String sortOrder = "asc";
  List<Map<String, dynamic>> riskProfiles = [
    {'key': 'conservative', 'value': 'Conservative'},
    {'key': 'm_conservative', 'value': 'Moderate Conservative'},
    {'key': 'moderate', 'value': 'Moderate'},
    {'key': 's_aggressive', 'value': 'Moderate Aggressive'},
    {'key': 'aggressive', 'value': 'Aggressive'},
  ];

  String getRiskProfile(String key) {
    String returnValue = "";
    riskProfiles.forEach((Map riskProfile) {
      if (riskProfile['key'] == key) {
        returnValue = riskProfile['value'];
      }
    });
    return returnValue;
  }

  Map<String, dynamic> _selectedSuggestion = null;
  String _quantity = null;
  TextEditingController _searchTxt = new TextEditingController();
  TextEditingController _quantityTxt = new TextEditingController();
  final qtyFocusNode = new FocusNode();
  final autoCompleteFocusNode = new FocusNode();

  StateSetter _setState, _setSaveButtonColorChangeState;
  String _selectedCurrency;

  List _transactionDetails = [];

  Map _transactionData = {
    "date": "",
    'type': 'buy',
    'qty': 1,
    'price': '',
  };

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Manage Portfolio Page',
        screenClassOverride: 'ManagePortfolio');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Manage Portfolio Page",
    });
  }

  @override
  void initState() {
    super.initState();
//
    if (widget.portfolioMasterID == '0') {
      widget.model.defaultPortfolioSelectorKey = widget.portfolioMasterID;
      widget.model.defaultPortfolioSelectorValue = widget.model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
          ['portfolio_name'];
    } else {
      portfolioMasterData =
          widget.model.userPortfoliosData[widget.portfolioMasterID];

      // log.d("checking----portfolioMasterData$portfolioMasterData");
      // log.d("=================================================");
      //  log.d(widget.portfolioMasterID);
      // log.d(portfolioMasterData['portfolios']['Deposit']);

    }
    _currentScreen();
    _addEvent();
  }

  refreshParent() => setState(() {
        // log.d('debug 131 refreshParent function');
        portfolioMasterData =
            widget.model.userPortfoliosData[widget.portfolioMasterID];
      });

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void filterPopup() {
    customAlertBox(
      context: context,
      childContent: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return Container(
            width: double.maxFinite,
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
                          child: Text(item['value'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _setState(() {
                          _selectedCurrency = value;
                        });
                        _setSaveButtonColorChangeState(() {});
                      },
                    )),
                  ],
                ),
              ],
            )),
          );
        },
      ),
      buttons: <Widget>[
        TextButton(
          child: Text("Cancel", style: dialogBoxActionInactive),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setSaveButtonColorChangeState = setState;
            return Text("Save",
                style: _selectedCurrency != null
                    ? dialogBoxActionActive
                    : dialogBoxActionInactive);
          }),
          onPressed: () async {
            if (_selectedCurrency != null) {
              widget.model.setLoader(true);
              Map<String, dynamic> responseData =
                  await widget.model.changeCurrency(_selectedCurrency);
              if (responseData['status'] == true) {
                Navigator.of(context).pop();
                await widget.model.fetchOtherData();
                widget.model.setLoader(false);
                refreshParent();
              }
            }
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        360,
        640,
      ),
    );
    if (portfolioMasterData == null || portfolioMasterData['type'] == null) {
      return Container();
    }
    List popupMenu = [
      {
        'text': 'Mark as ' +
            (portfolioMasterData['type'] == "1" ? "Watchlist" : "Live"),
        'action': 'toggle'
      },
      {'text': 'Duplicate Portfolio', 'action': 'split'},
      {'text': 'Merge Portfolio', 'action': 'merge'},
      {'text': 'Delete Portfolio', 'action': 'delete'},
      {'text': 'Rename Portfolio', 'action': 'rename'},
    ];
    changeStatusBarColor(Colors.white);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return DefaultTabController(
        length: 2,
        child: ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
          return Scaffold(
            //key: myGlobals.scaffoldKey,
            /* drawer: WidgetDrawer(), */
            appBar: kIsWeb
                ? AppBar(
                    backgroundColor: colorBlue,
                    elevation: 0.0,
                    title: Text("All Portfolios",
                        style: appBodyText2.copyWith(
                          fontSize: ScreenUtil().setSp(12.0),
                        )),
                    actions: <Widget>[
                      GestureDetector(
                        onTap: () => filterPopup(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                    (widget.model.userSettings['currency'] !=
                                                null
                                            ? widget
                                                .model.userSettings['currency']
                                            : "inr")
                                        .toUpperCase(),
                                    style: currencyConvert2.copyWith(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(8.0),
                                    )),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white),
                              ],
                            )
                          ],
                        ),
                      ),
                      !widget.readOnly
                          ? PopupMenuButton(
                              //icon: Icon(Icons.add),
                              onSelected: (value) async {
                                if (value == "split") {
                                  // navigate to add_portfolio_manually along with portfolioMasterID, ask for portfolio name and save
                                  Navigator.pushNamed(context,
                                      '/split_portfolio_portfolio_name/split',
                                      arguments: {
                                        'portfolioMasterID':
                                            widget.portfolioMasterID
                                      }).then((_) => refreshParent());
                                } else if (value == "merge") {
                                  // list of portfolio selection
                                  Navigator.pushNamed(context,
                                      '/portfolio_master_selectors/merge',
                                      arguments: {
                                        'portfolioMasterID':
                                            widget.portfolioMasterID
                                      }).then((_) => refreshParent());
                                } else if (value == "toggle") {
                                  togglePortfolioType();
                                } else if (value == "delete") {
                                  confirmDelete();
                                } else if (value == "rename") {
                                  Navigator.pushNamed(
                                      context, '/rename_portfolio', arguments: {
                                    'portfolioMasterID':
                                        widget.portfolioMasterID
                                  }).then((_) => refreshParent());
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return popupMenu.map((menu) {
                                  return PopupMenuItem(
                                      value: menu['action'],
                                      child: Text(menu['text'] ?? ''));
                                }).toList();
                              },
                            )
                          : GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/home_new'),
                              child: AppbarHomeButton(),
                            ),
                    ],
                  )
                : commonScrollAppBar(
                    controller: controller,
                    bgColor: Colors.white,
                    actions: [
                        GestureDetector(
                          onTap: () => filterPopup(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("All Portfolios", style: appBodyText2),
                              Row(
                                children: [
                                  Text(
                                      (widget.model.userSettings['currency'] !=
                                                  null
                                              ? widget.model
                                                  .userSettings['currency']
                                              : "inr")
                                          .toUpperCase(),
                                      style: currencyConvert2),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: colorBlue),
                                ],
                              )
                            ],
                          ),
                        ),
                        !widget.readOnly
                            ? PopupMenuButton(
                                //icon: Icon(Icons.add),
                                onSelected: (value) async {
                                  if (value == "split") {
                                    // navigate to add_portfolio_manually along with portfolioMasterID, ask for portfolio name and save
                                    Navigator.pushNamed(context,
                                        '/split_portfolio_portfolio_name/split',
                                        arguments: {
                                          'portfolioMasterID':
                                              widget.portfolioMasterID
                                        }).then((_) => refreshParent());
                                  } else if (value == "merge") {
                                    // list of portfolio selection
                                    Navigator.pushNamed(context,
                                        '/portfolio_master_selectors/merge',
                                        arguments: {
                                          'portfolioMasterID':
                                              widget.portfolioMasterID
                                        }).then((_) => refreshParent());
                                  } else if (value == "toggle") {
                                    togglePortfolioType();
                                  } else if (value == "delete") {
                                    confirmDelete();
                                  } else if (value == "rename") {
                                    Navigator.pushNamed(
                                        context, '/rename_portfolio',
                                        arguments: {
                                          'portfolioMasterID':
                                              widget.portfolioMasterID
                                        }).then((_) => refreshParent());
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return popupMenu.map((menu) {
                                    return PopupMenuItem(
                                        value: menu['action'],
                                        child: Text(menu['text'] ?? ''));
                                  }).toList();
                                },
                              )
                            : GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(
                                    context, '/home_new'),
                                child: AppbarHomeButton(),
                              ),
                      ]),
            body: _buildBody(),
          );
        }));
  }

  Widget _buildBody() {
    if (widget.model.isLoading) {
      return preLoader();
    } else {
      return mainContainer(
          context: context,
          paddingBottom: 0,
          child:
              _buildBodyContent()); //_autocompleteTextField(); //_buildBodyContent();

    }
  }

  Widget _tabBarViewContent(int currentTabIndex) {
    Widget content = null;
    switch (currentTabIndex) {
      case 0:
        content = _portfolioListBox("current");
        break;
      case 1:
        content = _portfolioListBox("past");
        break;
      default:
        content = _portfolioListBox("current");
    }
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(8)),
        color: Color(0xffecf1fa),
        child: content);
  }

  Widget _portfolioListBox(String type) {
    List<Widget> _widgetList = [];

    _widgetList.add(emptyWidget);

    return Column(
      children: <Widget>[
        //(portfolioMasterData['portfolios'].length > 1 && type == "current") ?  _sortPortfolios() : emptyWidget,
        Expanded(
            child: portfolioListBox2(
                context, type, portfolioMasterData['portfolios'], widget.model,
                refreshParentState: () {
          Future.delayed(Duration(milliseconds: 100))
              .then((value) => refreshParent());
        },
                readOnly: widget.readOnly,
                sortOrder: sortOrder,
                sortType: sortType,
                sortWidget: getPortfolioFundTypeCount() > 1 && type == "current"
                    ? _sortPortfolios()
                    : emptyWidget)),
        SizedBox(height: getScaledValue(15)),
        Container(
          //color: Theme.of(context).backgroundColor,
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.33,
                  child: flatButtonText(
                    "View Chart",
                    borderColor: colorBlue,
                    textColor: colorBlue,
                    onPressFunction: () => Navigator.pushNamed(
                        context, '/portfolio_chart', arguments: {
                      'portfolioMasterID': portfolioMasterData['id']
                    }).then((_) => refreshParent()),
                  )),
              SizedBox(width: getScaledValue(10)),
              Expanded(
                  child: gradientButton(
                      context: context,
                      caption:
                          portfolioMasterData['portfolios']['Deposit'] != null
                              ? "Add Deposits"
                              : "Add Investments",
                      onPressFunction: () {
                        if (portfolioMasterData['portfolios']['Deposit'] !=
                            null) {
                          _showAddDepositBottonsheet();
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            '/add_instrument',
                            arguments: {
                              'portfolioMasterID': portfolioMasterData['id'],
                              "viewDeposit": portfolioMasterData['portfolios']
                                          ['Deposit'] !=
                                      null
                                  ? true
                                  : false
                            },
                          ).then((_) => refresh());
                        }
                      })),
            ],
          ),
        )
      ],
    );
  }

  int getPortfolioFundTypeCount() {
    try {
      int count = 0;
      Map fundTypeCounts =
          portfolioFundCount(portfolioMaster: portfolioMasterData);
      fundTypeCounts.forEach((key, value) {
        count += value;
      });
      return count;
    } catch (e) {
      return 0;
    }
  }

  _showAddDepositBottonsheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getScaledValue(14)),
          topRight: Radius.circular(getScaledValue(14)),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AddDeposit(
            widget.model,
            widget.portfolioMasterID,
            null,
          );
        });
      },
    ).then((value) {
      Future.delayed(Duration(seconds: 1)).then((value) => refreshParent());
    });
  }

  Widget _buildBodyContent() {
    List zones = portfolioMasterData['portfolio_zone'].split('_');

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: getScaledValue(16.0)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(portfolioMasterData['portfolio_name'] ?? '',
                      style: headline2),
                  SizedBox(height: getScaledValue(10)),
                  fundCount(portfolioMasterData),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: getScaledValue(7)),
                  Row(
                    children: [
                      Visibility(
                        visible: portfolioMasterData['public'].toString() == "1"
                            ? true
                            : false,
                        child: widgetBubble(
                            title: Contants.publicportfolio,
                            includeBorder: false,
                            leftMargin: 0,
                            bgColor: Color(0xfffffce3),
                            textColor: Color(0xffe6c672)),
                      ),
                      portfolioMasterData['type'] == '1'
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
                    ],
                  ),
                  SizedBox(height: getScaledValue(10)),
                  Row(
                      children: zones
                          .map((item) => Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: widgetZoneFlag(item)))
                          .toList()),
                ],
              )
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: getScaledValue(16.0)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Divider(
                height: getScaledValue(18),
                color: AppColor.veryLightPink,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: SizedBox(
                          // width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(portfolioMasterData['value'] ?? '',
                              style: appBodyH3))),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Contants.oneDayReturns,
                                style: keyStatsBodyText2),
                            SizedBox(width: getScaledValue(5)),
                            (portfolioMasterData['change_sign'] == "up" ||
                                    portfolioMasterData['change_sign'] == "down"
                                ? Text(
                                    portfolioMasterData['change'].toString() +
                                        "%",
                                    style: bodyText12.copyWith(
                                      color: returnColor(
                                        portfolioMasterData['change']
                                            .toString(),
                                      ),
                                    ),
                                  )
                                : emptyWidget),
                          ],
                        ),
                        Text(
                          portfolioMasterData['change_amount'],
                          style: bodyText12.copyWith(
                            color: returnColor(
                              portfolioMasterData['change'].toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                height: getScaledValue(18),
                color: AppColor.veryLightPink,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width * 0.55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(Contants.monthToDate,
                                  style: keyStatsBodyText2),
                              SizedBox(width: getScaledValue(5)),
                              (portfolioMasterData['changeMonth_sign'] ==
                                          "up" ||
                                      portfolioMasterData['changeMonth_sign'] ==
                                          "down"
                                  ? Text(
                                      portfolioMasterData['changeMonth']
                                              .toString() +
                                          "%",
                                      style: bodyText12.copyWith(
                                        color: returnColor(
                                          portfolioMasterData['changeMonth']
                                              .toString(),
                                        ),
                                      ),
                                    )
                                  : emptyWidget),
                            ],
                          ),
                          Text(
                            portfolioMasterData['changeMonth_amount'],
                            style: bodyText12.copyWith(
                              color: returnColor(
                                portfolioMasterData['changeMonth'].toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Contants.yearToDate, style: keyStatsBodyText2),
                            SizedBox(width: getScaledValue(5)),
                            (portfolioMasterData['changeYear_sign'] == "up" ||
                                    portfolioMasterData['changeYear_sign'] ==
                                        "down"
                                ? Text(
                                    portfolioMasterData['changeYear']
                                            .toString() +
                                        "%",
                                    style: bodyText12.copyWith(
                                      color: returnColor(
                                        portfolioMasterData['changeYear']
                                            .toString(),
                                      ),
                                    ),
                                  )
                                : emptyWidget),
                          ],
                        ),
                        Text(
                          portfolioMasterData['changeYear_amount'],
                          style: bodyText12.copyWith(
                            color: returnColor(
                              portfolioMasterData['changeYear'].toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ])),
        SizedBox(height: getScaledValue(15)),
        TabBar(
          unselectedLabelColor: Color(0xffa5a5a5),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Color(0xff034bd9),
          labelStyle: tabLabelActive,
          unselectedLabelStyle: tabLabel,
          indicator: BoxDecoration(
            color: Colors.transparent,
            border:
                Border(bottom: BorderSide(color: Color(0xff034bd9), width: 3)),
          ),
          onTap: (index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          tabs: [
            Tab(text: "CURRENT HOLDINGS"),
            Tab(text: "PAST HOLDINGS"),
          ],
        ),
        Expanded(child: _tabBarViewContent(currentTabIndex))
      ],
    );
  }

  Color returnColor(String number) {
    try {
      double percentage = double.parse(number);
      if (percentage == 0.0) {
        return colorBlackReturn;
      } else if (percentage > 0.0) {
        return colorGreenReturn;
      } else {
        return colorRedReturn;
      }
    } catch (e) {
      return colorBlackReturn;
    }
  }

  fnCheckEmptyPortfolioList() {
    if (widget
        .model
        .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios']
        .isEmpty) {
      return false;
    } else {
      bool found = false;
      widget
          .model
          .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
              ['portfolios']
          .forEach((type, portfolioList) {
        // log.d('debug 196');
        // log.d(type);
        // log.d(portfolioList);
        if (!portfolioList.isEmpty) {
          found = true;
        }
      });
      return found;
    }
  }

  void formResponse() async {
    widget.model.setLoader(true);
    Map<String, dynamic> responseData = await widget.model
        .updateCustomerPortfolioData(
            portfolios: widget.model.userPortfoliosData[
                widget.model.defaultPortfolioSelectorKey]['portfolios'],
            riskProfile: widget.model.newUserRiskProfile,
            portfolioMasterID: widget.model.defaultPortfolioSelectorKey,
            portfolioName: widget.model.userPortfoliosData[
                widget.model.defaultPortfolioSelectorKey]['portfolio_name']);

    if (responseData['status']) {
      widget.model.setLoader(false);
      widget.model.userPortfoliosData.remove('0');
      Navigator.of(context).pop(true);
    } else {
      widget.model.setLoader(false);
      // display error
    }
  }

  Widget _autocompleteTextField(BuildContext context1) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        color: Colors.white,
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              focusNode: autoCompleteFocusNode,
              controller: _searchTxt,
              autofocus: true,
              style: Theme.of(context1)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.grey[600]),
              /*  DefaultTextStyle.of(context).style.copyWith(
						/* fontStyle: FontStyle.italic, */
						fontStyle: FontStyle.normal,
						fontSize: 12.0,
						color: Colors.black,
						height: 0,
					), */
              decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  labelText: 'Stocks / Funds',
                  labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0)
                  /* border: OutlineInputBorder() */
                  )),
          suggestionsCallback: (pattern) async {
            if (pattern.length >= 3) {
              return await widget.model.getFundName(pattern, "all");
            }
          },
          itemBuilder: (context1, suggestion) {
            return ListTile(
              leading: Text(suggestion['type']),
              title: Text(suggestion['name']),
              subtitle: Text(suggestion['core'] +
                  ' - ' +
                  suggestion['zone'].toUpperCase()),
            );
          },
          onSuggestionSelected: (suggestion) async {
            // log.d('debug 258');
            // log.d(suggestion);
            _selectedSuggestion = suggestion;
            _ricSelected = true;

            _searchTxt.text = suggestion['name'];

            if (_searchTxt.text.length > 35) {
              _searchTxt.text = _searchTxt.text.substring(0, 30) + "...";
            }

            //FocusScope.of(context).requestFocus(qtyFocusNode);
            //addPortfolio();
          },
        ));
  }

  addPortfolio(BuildContext dialogContex) {
    /* autoCompleteFocusNode.dispose();
		qtyFocusNode.dispose(); */
    if (_selectedSuggestion != null && _quantity != null) {
      Navigator.of(dialogContex).pop();
      setState(() {
        if (validateRIC(
            _selectedSuggestion['ric'], _selectedSuggestion['type'])) {
          if (!widget
              .model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
                  ['portfolios']
              .containsKey(_selectedSuggestion['type'])) {
            widget.model.userPortfoliosData[
                    widget.model.defaultPortfolioSelectorKey]['portfolios']
                [_selectedSuggestion['type']] = [];
          }
          widget
              .model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
                  ['portfolios'][_selectedSuggestion['type']]
              .add({
            'zone': _selectedSuggestion['zone'],
            'ric': _selectedSuggestion['ric'],
            'name': _selectedSuggestion['name'],
            'asset': _selectedSuggestion['asset'],
            'type': _selectedSuggestion['type'],
            'weightage': _quantity,
          });

          _selectedSuggestion = null;
          _quantity = null;

          _searchTxt.clear();
        } else {
          showAlertDialogBox(dialogContex, 'Already exists!',
              'Stock / Fund already selected!');
        }
      });
    }
  }

  bool validateRIC(String ric, String type) {
    bool found = false;
    if (widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios'] ==
        null) {
      widget.model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
          ['portfolios'] = {};
    }
    if (!widget
        .model
        .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios']
        .containsKey(type)) {
      return true;
    }
    widget
        .model
        .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios'][type]
        .forEach((portfolio) {
      // log.d('Printing portfolio');
      // log.d(portfolio['ric']);
      // log.d(ric);
      if (portfolio['ric'] == ric) {
        // log.d('match found!');
        found = true;
      }
      /* log.d('each portfolio');
			log.d(portfolio); */
    });
    if (found) {
      return false;
    } else {
      return true;
    }
  }

  void addNewPortfolio(BuildContext context) {
    _selectedSuggestion = null;
    _quantity = null;

    _searchTxt.clear();
    _quantityTxt.clear();

    // FocusScope.of(context).requestFocus(autoCompleteFocusNode);

    showModalBottomSheet(
        /* context: context, */
        isScrollControlled: true,
        context: context, //myGlobals.scaffoldKey.currentContext,

        builder: (BuildContext context) {
          //final autoCompleteFocusNode = new FocusNode();
          return _ricSelected ? _addRICTransaction() : _selectRic();
        });
  }

  Widget _selectRic() {
    return mainContainer(
        context: context,
        containerColor: Colors.white,
        paddingTop: 30.0,
        paddingRight: 20.0,
        paddingLeft: 20.0,
        child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                alignment: Alignment.centerRight,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              _autocompleteTextField(context),
              SizedBox(height: 20.0),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /* Expanded(child: _quantityBoxAddPortfolio()),
							SizedBox(width: 10.0), */
                  ElevatedButton(
                      child: Text(
                        "Add to Portfolio ",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => addPortfolio(context))
                ],
              )
            ]));
  }

  Widget _addRICTransaction() {
    // log.d('debug 475');
    // log.d(_selectedSuggestion);

    return mainContainer(
        context: context,
        containerColor: Colors.white,
        paddingTop: 30.0,
        paddingRight: 20.0,
        paddingLeft: 20.0,
        child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    icon: Icon(Icons.close),
                    alignment: Alignment.centerRight,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Text(
                _selectedSuggestion['name'],
                style: Theme.of(context).textTheme.subtitle1,
              ),
              widgetBubble(
                  title: _selectedSuggestion['zone'],
                  bgColor: Color(0xfff6f9fc),
                  textColor: Color(0xff6b7c93)),
              widgetBubble(
                  title: _selectedSuggestion['type'],
                  bgColor: Color(0xfff6f9fc),
                  textColor: Color(0xff6b7c93)),
              RaisedButton(
                  child: Text(
                    "Add Transaction",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => addTransaction()),
              DashSeparator(
                color: Colors.grey,
              ),
              _listTransactionBox(),
            ]));
  }

  Widget _listTransactionBox() {
    List<Widget> _transactionBox = [];

    _transactionDetails.add(_transactionData);
    _transactionBox.add(_transactionGroup(0));

    if (_transactionDetails != null) {
      for (var i = 0; i < _transactionDetails.length; i++) {
        _transactionBox.add(_transactionGroup(i));
      }
    }

    return Column(
      children: _transactionBox,
    );
  }

  addTransaction() {
    // log.d('debug 532');
    // log.d(_transactionData);
    // log.d(_transactionDetails);
    setState(() {
      _transactionDetails.add(_transactionData);
    });
    // log.d(_transactionDetails);
  }

  Widget _transactionGroup(int i) {
    Map transactionDataRow = _transactionDetails[i];
    return Container(
        child: Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Text(transactionDataRow['date'] + i.toString()),
        // date
        // selet buy sell
        // units
        // price
      ],
    ));
  }

  togglePortfolioType() async {
    widget.model.setLoader(true);
    int type = 1;
    if (portfolioMasterData['type'] == '1') {
      type = 0;
    }
    Map<String, dynamic> responseData = await widget.model
        .setPortfolioMasterDefault(widget.portfolioMasterID, type);
    if (responseData['status'] == true) {
      Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view')
          .then((_) => refreshParent());
    }
    widget.model.setLoader(false);
  }

  confirmDelete() {
    return customAlertBox(
      context: context,
      title: "Confirm Delete!",
      description:
          "This will delete the entire portfolio. Are you sure you want to proceed?",
      buttons: [
        flatButtonText("No",
            borderColor: colorBlue,
            onPressFunction: () => Navigator.of(context).pop(false)),
        gradientButton(
          context: context,
          caption: "Yes",
          onPressFunction: () async {
            Navigator.of(context).pop(true);
            widget.model.setLoader(true);
            Map<String, dynamic> responseData = await widget.model
                .removePortfolioMaster(widget.portfolioMasterID);

            if (responseData['status'] == true) {
              Navigator.pushReplacementNamed(
                      context, '/manage_portfolio_master_view')
                  .then((_) => refreshParent());
            }
            widget.model.setLoader(false);
          },
        ),
      ],
    );
  }

  Widget _sortPortfolios() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: getScaledValue(16), vertical: getScaledValue(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () => sortPopup(),
            child: Row(
              children: <Widget>[
                Text("Sort By", style: textLink1),
                Icon(Icons.keyboard_arrow_down,
                    color: colorBlue, size: getScaledValue(15))
              ],
            ),
          )
        ],
      ),
    );
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
          _sortOptionSection(title: "Name", options: [
            {"title": "A - Z", "type": "name", "order": "asc"},
            {"title": "Z - A", "type": "name", "order": "desc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Value", options: [
            {
              "title": "Highest to Lowest",
              "type": "valueBase",
              "order": "desc"
            },
            {"title": "Lowest to Highest", "type": "valueBase", "order": "asc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Units", options: [
            {
              "title": "Highest to Lowest",
              "type": "weightage",
              "order": "desc"
            },
            {"title": "Lowest to Highest", "type": "weightage", "order": "asc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Daily Return", options: [
            {"title": "Highest to Lowest", "type": "change", "order": "desc"},
            {"title": "Lowest to Highest", "type": "change", "order": "asc"}
          ]),
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
    final Map sortedMap = {};
    List sortedList = [];

    widget.model.userPortfoliosData
        .forEach((portfolioMasterID, portfolioMasterData) {
      sortedList.add(portfolioMasterData);
    });

    if (type == "change") {
      sortedList.sort(
          (a, b) => double.parse(a[type]).compareTo(double.parse(b[type])));
    } else {
      sortedList.sort((a, b) => a[type].compareTo(b[type]));
    }

    if (sortOrder == "desc") {
      sortedList = sortedList.reversed.toList();
    }

    sortedList.forEach((element) {
      sortedMap[element['id']] = element;
    });

    setState(() {
      widget.model.userPortfoliosData = sortedMap;
    });
  }

  functionSetPortfolioCore(portfolioID, type) async {
    widget.model.setLoader(true);
    await widget.model.setPortfolioMasterDefault(portfolioID, type);
    widget.model.setLoader(false);
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
