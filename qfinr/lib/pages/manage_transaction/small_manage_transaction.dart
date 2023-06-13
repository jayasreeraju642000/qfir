import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_transaction/app_bar_home_button_in_white.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('ManageTransactionPage');

class SmallManageTransactionPage extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  String portfolioMasterID;

  String action;

  String mode;
  bool ricSelected;
  String ricType;
  String ricZone;
  String ricName;
  String ricIndex;

  bool readOnly;

  Map portfolioMasterData;

  Map arguments;

  final Function() refreshParentState;

  SmallManageTransactionPage(this.model,
      {this.analytics,
      this.observer,
      this.action = "edit",
      this.portfolioMasterID,
      this.ricSelected,
      this.ricType,
      this.ricZone,
      this.ricName,
      this.ricIndex,
      this.portfolioMasterData,
      this.mode = "edit",
      this.refreshParentState,
      this.arguments,
      this.readOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _SmallManageTransactionPageState();
  }
}

class _SmallManageTransactionPageState
    extends State<SmallManageTransactionPage> {
  final controller = ScrollController();
  GlobalKey _scaffoldKey = GlobalKey();
  Map<String, dynamic> _selectedSuggestion = null;
  TextEditingController _searchTxt = new TextEditingController();
  TextEditingController _quantityTxt = new TextEditingController();
  final qtyFocusNode = new FocusNode();
  final autoCompleteFocusNode = new FocusNode();

  List textHoldingController = [];
  List textPriceController = [];

  final GlobalKey<FormState> _registrationKey = GlobalKey<FormState>();
  bool _registrationAutoValidate = false;

  String sortType = "date";
  String sortOrder = "asc";

  Map<String, FocusNode> focusNodes = {
    'type': new FocusNode(),
    'date': new FocusNode(),
    'holding': new FocusNode(),
    'price': new FocusNode(),
  };

  Map<String, TextEditingController> _controller = {
    'type': new TextEditingController(),
    'date': new TextEditingController(),
    'holding': new TextEditingController(),
    'price': new TextEditingController(),
  };
  Map _transactionData = {
    "date": "",
    'type': 'buy',
    'holding': '1',
    'price': '',
  };

  Map ricData;

  List _transactionDetails = [];
  List _transactionDetailsTmp = [];

  double globalTotalHoldings;

  String ricHolding = "";

  String _transactionTypeValue;
  String _transactionAction;
  int _transactionIndex;

  StateSetter _setState;

  List<Map<String, dynamic>> txnTypes = [
    {'key': 'buy', 'value': 'Buy'},
    {'key': 'sell', 'value': 'Sell'}
  ];

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Add Portfolio Page',
        screenClassOverride: 'AddPortfolioPage');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Add Portfolio Page",
    });
  }

  @override
  void initState() {
    super.initState();
    _currentScreen();
    _addEvent();

    var date = DateTime.now();
    var newDate = DateTime(date.year - 3, date.month, date.day);
    if (newDate.weekday == 7) {
      newDate = DateTime(newDate.year, newDate.month, newDate.day - 2);
    } else if (newDate.weekday == 6) {
      newDate = DateTime(newDate.year, newDate.month, newDate.day - 1);
    }
    _transactionData['date'] = DateFormat('yyyy-MM-dd').format(newDate);

    if (widget.action == "new" &&
        !widget.model.userPortfoliosData.containsKey('0')) {
      widget.model.userPortfoliosData['0'] = widget.portfolioMasterData;
    }

    if (widget.mode == "edit") {
      ricData = widget.model.userPortfoliosData[widget.portfolioMasterID]
          ['portfolios'][widget.ricType][int.parse(widget.ricIndex)];
      ricHolding = ricData['weightage'].toString();
      _selectedSuggestion = {
        "ric": widget.ricName,
        "name": widget.model.userPortfoliosData[widget.portfolioMasterID]
            ['portfolios'][widget.ricType][int.parse(widget.ricIndex)]['name'],
        'zone': widget.ricZone,
        'type': widget.ricType,
      };

      if (_transactionDetails.length < 1) {
        _transactionDetails = widget.model
                .userPortfoliosData[widget.portfolioMasterID]['portfolios']
            [widget.ricType][int.parse(widget.ricIndex)]['transactions'];
      }
    } else {
      _selectedSuggestion = null;
    }

    _searchTxt.clear();
    _quantityTxt.clear();
  }

  void onPageClose() {
    // log.d('debug 178');
    if (widget.arguments['action'] == "newInstrument") {
      widget
          .model
          .userPortfoliosData[widget.portfolioMasterID]['portfolios']
              [widget.ricType]
          .removeAt(int.parse(widget.ricIndex));
    }
    Navigator.pop(context);
  }

  String getTxnType(String key) {
    if (key == null) return null;

    String returnValue = "";
    txnTypes.forEach((Map txnType) {
      if (txnType['key'] == key) {
        returnValue = txnType['value'];
      }
    });
    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    List popupMenu = [
      {'text': 'Delete', 'action': 'delete'},
    ];
    changeStatusBarColor(Colors.white);
    return WillPopScope(onWillPop: () {
      onPageClose();
    }, child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: kIsWeb
            ? AppBar(
                backgroundColor: colorBlue,
                elevation: 0.0,
                title: Text(""),
                actions: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, widget.model.redirectBase),
                    child: AppbarHomeButtonInWhite(),
                  ),
                  widget.action != 'new' && !widget.readOnly
                      ? PopupMenuButton(
                          //icon: Icon(Icons.add),
                          onSelected: (value) async {
                            if (value == "delete") {
                              confirmDelete();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return popupMenu.map((menu) {
                              return PopupMenuItem(
                                  value: menu['action'],
                                  child: Text(menu['text']));
                            }).toList();
                          },
                        )
                      : emptyWidget,
                ],
              )
            : commonScrollAppBar(
                controller: controller,
                bgColor: Colors.white,
                actions: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, widget.model.redirectBase),
                      child: AppbarHomeButton(),
                    ),
                    widget.action != 'new' && !widget.readOnly
                        ? PopupMenuButton(
                            //icon: Icon(Icons.add),
                            onSelected: (value) async {
                              if (value == "delete") {
                                confirmDelete();
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return popupMenu.map((menu) {
                                return PopupMenuItem(
                                    value: menu['action'],
                                    child: Text(menu['text']));
                              }).toList();
                            },
                          )
                        : emptyWidget,
                  ]),
        body: _buildBody(),
      );
    }));
  }

  confirmDelete() {
    int portfolioCount = 0;

    widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios']
        .forEach((key, portfolios) {
      portfolios.forEach((element) {
        if (double.parse(element['weightage']) > 0) {
          portfolioCount++;
        }
      });
    });

    return customAlertBox(
      context: context,
      title: "Confirm Delete!",
      description: (portfolioCount == 1
          ? "This will delete portfolio. Are you sure you want to delete this portfolio?"
          : "Are you sure you want to delete this investment?"),
      buttons: [
        flatButtonText("No",
            borderColor: colorBlue,
            onPressFunction: () => Navigator.of(context).pop(false)),
        gradientButton(
          context: context,
          caption: "Yes",
          onPressFunction: () async {
            Navigator.of(context).pop(true);
            // setState(() {
            //   widget.model.setLoader(true);
            // });
            widget.model.setLoader(true);
            Map<String, dynamic> responseData;

            if (portfolioCount == 1) {
              responseData = await widget.model
                  .removePortfolioMaster(widget.portfolioMasterID);
            } else {
              widget
                  .model
                  .userPortfoliosData[widget.portfolioMasterID]['portfolios']
                      [_selectedSuggestion['type']]
                  .removeAt(int.parse(widget.ricIndex));
              responseData = await widget.model.updateCustomerPortfolioData(
                  portfolios:
                      widget.model.userPortfoliosData[widget.portfolioMasterID]
                          ['portfolios'],
                  portfolioMasterID: widget.portfolioMasterID,
                  portfolioName:
                      widget.model.userPortfoliosData[widget.portfolioMasterID]
                          ['portfolio_name']);
            }

            if (responseData['status'] == true) {
              if (portfolioCount == 1) {
                Navigator.pushReplacementNamed(
                    context, '/manage_portfolio_master_view');
              }
              //   Navigator.pushReplacementNamed(
              //       context, '/manage_portfolio_master_view');
            }
            // setState(() {
            //   widget.model.setLoader(false);
            // });
            widget.model.setLoader(false);
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    try {
      if (widget.action != "new") {
        if (widget.model.userPortfoliosData[widget.portfolioMasterID] == null) {
          // Future.delayed(Duration(milliseconds: 100), () {
          //   Navigator.pop(context);
          // });
          return Container();
        }
        if (widget.model.userPortfoliosData[widget.portfolioMasterID]
                ['portfolios'][widget.ricType] ==
            null) {
          Future.delayed(Duration(milliseconds: 100), () {
            Navigator.pop(context);
          });
          return Container();
        }
        if (widget
                .model
                .userPortfoliosData[widget.portfolioMasterID]['portfolios']
                    [widget.ricType]
                .length <=
            int.parse(widget.ricIndex)) {
          Future.delayed(Duration(milliseconds: 100), () {
            Navigator.pop(context);
          });
          return Container();
        }
        if (widget.model.userPortfoliosData[widget.portfolioMasterID]
                    ['portfolios'][widget.ricType][int.parse(widget.ricIndex)]
                ["ric"] !=
            widget.ricName) {
          Future.delayed(Duration(milliseconds: 100), () {
            Navigator.pop(context);
          });
          return Container();
        }
      }
    } catch (e) {
      log.e(e);
      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.pop(context);
      });
      return Container();
    }
    return mainContainer(
        context: context,
        containerColor: Colors.white,
        child: widget.model.isLoading
            ? preLoader()
            : (widget.ricSelected ? _addRICTransaction() : _selectRic()));
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
            widget.ricSelected = true;

            _searchTxt.text = suggestion['name'];

            if (_searchTxt.text.length > 35) {
              _searchTxt.text = _searchTxt.text.substring(0, 30) + "...";
            }

            //FocusScope.of(context).requestFocus(qtyFocusNode);
            //addPortfolio();
          },
        ));
  }

  Widget _selectRic() {
    return Flex(
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
        ]);
  }

  Widget _addRICTransaction() {
    return Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                left: getScaledValue(16),
                top: getScaledValue(10.0),
                right: getScaledValue(16),
                bottom: getScaledValue(20)),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Color(0xfff5f5f5)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x256b6b6b),
                    offset: Offset(0.0, 2.0), //(x,y)
                    blurRadius: 11.0,
                    spreadRadius: -2,
                  ),
                ]),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(limitChar(ricData['name'], length: 20),
                                style: headline2),
                            SizedBox(width: getScaledValue(7)),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed(
                                  '/fund_info',
                                  arguments: {'ric': ricData['ric']}),
                              child: svgImage('assets/icon/icon_details.svg'),
                            ),
                          ],
                        ),
                        SizedBox(height: getScaledValue(5)),
                        Row(
                          children: <Widget>[
                            Text(
                                ricData['type'].toLowerCase() == "commodity"
                                    ? "Total Grams: "
                                    : "Total Units: ",
                                style: transactionBoxLabel),
                            Text(ricHolding, style: transactionBoxDetail),
                          ],
                        )
                      ],
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        widget.action == "new"
                            ? emptyWidget
                            : SizedBox(height: getScaledValue(7)),
                        widget.action == "new"
                            ? emptyWidget
                            : widgetBubble(
                                title: ricData['type'].toUpperCase(),
                                leftMargin: 0,
                                rightMargin: 0,
                                bgColor: Colors.white,
                                textColor: Color(0xffa7a7a7)),
                        SizedBox(height: getScaledValue(10)),
                        widgetZoneFlag(ricData['zone'])
                      ],
                    )
                  ],
                ),
                widget.action == "new"
                    ? emptyWidget
                    : Divider(
                        height: getScaledValue(18),
                        color: AppColor.veryLightPink,
                      ),
                widget.action == "new"
                    ? emptyWidget
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.55,
                                child: Text(ricData['value'] ?? "",
                                    style: appBodyH3)),
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
                                    Text(Contants.oneDayReturns,
                                        textAlign: TextAlign.end,
                                        style: keyStatsBodyText2),
                                    SizedBox(width: getScaledValue(5)),
                                    (ricData['change_sign'] == "up" ||
                                            ricData['change_sign'] == "down"
                                        ? Text(
                                            ricData['change'].toString() + "%",
                                            style: bodyText12.copyWith(
                                              color: returnColor(
                                                ricData['change'].toString(),
                                              ),
                                            ),
                                          )
                                        : emptyWidget),
                                  ],
                                ),
                                Text(
                                  ricData['changeAmount'],
                                  style: bodyText12.copyWith(
                                    color: returnColor(
                                      ricData['change'].toString(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                widget.action == "new"
                    ? emptyWidget
                    : Divider(
                        height: getScaledValue(18),
                        color: AppColor.veryLightPink,
                      ),
                widget.action == "new"
                    ? emptyWidget
                    : Row(
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
                                      (ricData['changeMonth_sign'] == "up" ||
                                              ricData['changeMonth_sign'] ==
                                                  "down"
                                          ? Text(
                                              ricData['changeMonth']
                                                      .toString() +
                                                  "%",
                                              style: bodyText12.copyWith(
                                                color: returnColor(
                                                  ricData['changeMonth']
                                                      .toString(),
                                                ),
                                              ),
                                            )
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                    ricData['changeAmountMonth'],
                                    style: bodyText12.copyWith(
                                      color: returnColor(
                                        ricData['changeMonth'].toString(),
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
                                    Text(Contants.yearToDate,
                                        textAlign: TextAlign.end,
                                        style: keyStatsBodyText2),
                                    SizedBox(width: getScaledValue(5)),
                                    (ricData['changeYear_sign'] == "up" ||
                                            ricData['changeYear_sign'] == "down"
                                        ? Text(
                                            ricData['changeYear'].toString() +
                                                "%",
                                            style: bodyText12.copyWith(
                                              color: returnColor(
                                                ricData['changeYear']
                                                    .toString(),
                                              ),
                                            ),
                                          )
                                        : emptyWidget),
                                  ],
                                ),
                                Text(
                                  ricData['changeAmountYear'],
                                  style: bodyText12.copyWith(
                                    color: returnColor(
                                      ricData['changeYear'].toString(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
          SizedBox(height: getScaledValue(18)),
          Expanded(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: _listTransactionBox())),
          SizedBox(height: getScaledValue(18)),
          widget.action == "new"
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
                  child: gradientButton(
                      context: context,
                      caption: 'CREATE',
                      buttonDisabled: (widget
                              .model
                              .userPortfoliosData[widget.portfolioMasterID]
                                  ['portfolios'][_selectedSuggestion['type']]
                                  [int.parse(widget.ricIndex)]['transactions']
                              .isEmpty)
                          ? true
                          : false,
                      onPressFunction: () => {
                            !(widget
                                    .model
                                    .userPortfoliosData[
                                        widget.portfolioMasterID]['portfolios']
                                        [_selectedSuggestion['type']]
                                        [int.parse(widget.ricIndex)]
                                        ['transactions']
                                    .isEmpty)
                                ? updateCustomerPortfolioData()
                                : null //
                          }))
              : emptyWidget
        ]);
  }

  Widget _listTransactionBox() {
    List<Widget> _transactionBox = [];

    if (ricData['transactions'] != null && ricData['transactions'].length > 1) {
      _transactionBox.add(GestureDetector(
        onTap: () => sortPopup(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text("Sort By", style: textLink1),
            Icon(Icons.keyboard_arrow_down,
                color: colorBlue, size: getScaledValue(15))
          ],
        ),
      ));
    }

    if (ricData['transactions'] != null) {
      for (var i = 0; i < ricData['transactions'].length; i++) {
        _transactionBox.add(transactionBox(ricData['transactions'][i], i));
      }
    }

    _transactionBox.add(SizedBox(height: getScaledValue(8)));

    if (!widget.readOnly) {
      _transactionBox.add(flatButtonText(
          ricData['transactions'] != null && ricData['transactions'].length > 0
              ? "+ add more"
              : "+ add",
          onPressFunction: () => transactionPopup(),
          bgColor: Color(0xffedf4ff),
          borderColor: colorBlue,
          textColor: colorBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600));
    }

    return ListView(
      shrinkWrap: true,
      children: _transactionBox,
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

  Widget transactionBox(Map transactionDataRow, int index) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: Color(0xffbcbcbc), width: getScaledValue(0.5)),
            borderRadius: BorderRadius.circular(getScaledValue(4))),
        padding: EdgeInsets.all(getScaledValue(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                double.parse(transactionDataRow['holding']).toStringAsFixed(2) +
                    (ricData['type'].toLowerCase() == "commodity"
                        ? " grams"
                        : " units"),
                style: transactionBoxUnits),
            SizedBox(height: getScaledValue(13)),
            Row(
              children: <Widget>[
                Text("Transaction Date    :", style: transactionBoxLabel),
                SizedBox(width: getScaledValue(5)),
                Text(transactionDataRow['date'], style: transactionBoxDetail),
              ],
            ),
            SizedBox(height: getScaledValue(6)),
            Row(
              children: <Widget>[
                Text("Transaction Type    :", style: transactionBoxLabel),
                SizedBox(width: getScaledValue(5)),
                Text(transactionDataRow['type'].toUpperCase(),
                    style: transactionBoxDetail),
              ],
            ),
            SizedBox(height: getScaledValue(6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                        (ricData['type'].toLowerCase() == "commodity"
                            ? "Price per gram        :"
                            : "Price per unit          :"),
                        style: transactionBoxLabel),
                    SizedBox(width: getScaledValue(5)),
                    Text(
                        transactionDataRow['price'] == null ||
                                transactionDataRow['price'] == ""
                            ? '- '
                            : getCurrencySymbol(widget
                                    .model
                                    .userPortfoliosData[
                                        widget.portfolioMasterID]['portfolios']
                                        [widget.ricType]
                                        [int.parse(widget.ricIndex)]['currency']
                                    .toLowerCase()) +
                                transactionDataRow['price'],
                        style: transactionBoxDetail),
                  ],
                ),
                !widget.readOnly
                    ? Row(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () => transactionPopup(
                                  transactionData: transactionDataRow,
                                  index: index),
                              child: Text('edit', style: transactionBoxLink)),
                          SizedBox(width: getScaledValue(20)),
                          GestureDetector(
                              onTap: () => deleteTransaction(index),
                              child: Text('delete', style: transactionBoxLink)),
                        ],
                      )
                    : emptyWidget,
              ],
            )
          ],
        ));
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
          _sortOptionSection(title: "Transaction Date", options: [
            {"title": "Latest to Oldest", "type": "date", "order": "desc"},
            {"title": "Oldest to Latest", "type": "date", "order": "asc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Units", options: [
            {"title": "Highest to Lowest", "type": "holding", "order": "desc"},
            {"title": "Lowest to Highest", "type": "holding", "order": "asc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Transaction Type", options: [
            {"title": "Buy", "type": "type", "order": "desc"},
            {"title": "Sell", "type": "type", "order": "asc"}
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
    return GestureDetector(
      onTap: () => {
        setState(() {
          sortType = optionRow['type'];
          sortOrder = optionRow['order'];

          _transactionDetails.sort(
              (a, b) => a[optionRow['type']].compareTo(b[optionRow['type']]));
          if (sortOrder == "desc") {
            widget.model.userPortfoliosData[widget.portfolioMasterID]
                    ['portfolios'][widget.ricType][int.parse(widget.ricIndex)]
                ['transactions'] = _transactionDetails.reversed.toList();
          }
          Navigator.of(context).pop();
        })
      },
      child: Container(
        padding: EdgeInsets.only(top: getScaledValue(12)),
        child: Text(optionRow['title'],
            style:
                sortType == optionRow['type'] && sortOrder == optionRow['order']
                    ? sortbyOptionActive
                    : sortbyOption),
      ),
    );
  }

  void transactionPopup({Map transactionData, int index}) {
    setTransactionForm(transactionData, index);
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _setState = setState;
              return _transactionForm(index);
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel", style: dialogBoxActionInactive),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Save", style: dialogBoxActionActive),
              onPressed: () {
                saveTransaction();
                //Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _transactionForm(int index) {
    DateTime selectedDate = DateTime.now();
    selectedDate = selectedDate.subtract(Duration(days: 1));

    if (selectedDate.weekday == 6) {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    } else if (selectedDate.weekday == 7) {
      selectedDate = selectedDate.subtract(Duration(days: 2));
    }
    return Container(
      width: double.maxFinite,
      height: double.maxFinite < getScaledValue(365)
          ? double.maxFinite
          : null, // double.maxFinite,
      child: Form(
          key: _registrationKey,
          autovalidate: _registrationAutoValidate,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: getScaledValue(8)),
                      child: Image.asset('assets/icon/icon_date.png',
                          width: getScaledValue(15))),
                  SizedBox(width: getScaledValue(5)),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate:
                                  selectedDate, //_transactionDetails[i]['date'] != "" ? DateTime.parse(_transactionDetails[i]['date']) :
                              firstDate: DateTime(2001),
                              lastDate: selectedDate,
                              //selectableDayPredicate: (DateTime val) =>  val.weekday == 7 || val.weekday == 6 ? false : true,
                            ).then((date) {
                              setState(() {
                                final f = new DateFormat('yyyy-MM-dd');
                                _controller['date'].text = f.format(date);
                              });
                            });
                          },
                          child: IgnorePointer(
                              child: TextFormField(
                                  focusNode: focusNodes['date'],
                                  controller: _controller['date'],
                                  validator: (value) {
                                    /* if ( value.length < 2 || value.isEmpty) {
														return "Invalid First Name";
													} */
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Transaction Date',
                                    labelStyle: focusNodes['date'].hasFocus
                                        ? inputLabelFocusStyle
                                        : inputLabelStyle,
                                    contentPadding: EdgeInsets.only(
                                        left: 0, bottom: 0, top: 0, right: 0),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onChanged: (String value) {
                                    setState(() {
                                      _transactionData['date'] = value;
                                    });
                                  },
                                  style: inputFieldStyle)))),
                ],
              ),
              SizedBox(height: getScaledValue(20.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: getScaledValue(8)),
                      child: Image.asset(
                          'assets/icon/icon_transaction_type.png',
                          width: getScaledValue(15))),
                  SizedBox(width: getScaledValue(5)),
                  Expanded(
                      child: DropdownButton<String>(
                    focusNode: focusNodes['type'],
                    hint: Text('Transaction Type'),
                    isExpanded: true,
                    value: _transactionTypeValue,
                    items: txnTypes.map((Map item) {
                      return DropdownMenuItem<String>(
                        value: item['key'],
                        child: Text(item['value']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _setState(() {
                        _transactionTypeValue = value;
                      });
                    },
                  )

                      /* TextFormField(
									focusNode: focusNodes['type'],
									controller: _controller['type'],
									validator: (value){
										/* if ( value.length < 2 || value.isEmpty) {
											return "Invalid First Name";
										} */
										return null;
									},
									decoration: InputDecoration(labelText: 'Transaction Type', labelStyle: focusNodes['type'].hasFocus ? inputLabelFocusStyle : inputLabelStyle),
									keyboardType: TextInputType.text,
									onChanged: (String value) {
										setState(() {
											_transactionData['type'] = value;
										});
									},
									style: inputFieldStyle
								) */
                      ),
                ],
              ),
              SizedBox(height: getScaledValue(20.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: getScaledValue(8)),
                      child: Image.asset('assets/icon/icon_dollar.png',
                          width: getScaledValue(15))),
                  SizedBox(width: getScaledValue(5)),
                  Expanded(
                      child: TextFormField(
                          focusNode: focusNodes['holding'],
                          controller: _controller['holding'],
                          validator: (value) {
                            /* if ( value.length < 2 || value.isEmpty) {
											return "Invalid First Name";
										} */
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText:
                                ricData['type'].toLowerCase() == "commodity"
                                    ? "'Number of Grams"
                                    : 'Number of Units',
                            labelStyle: focusNodes['holding'].hasFocus
                                ? inputLabelFocusStyle
                                : inputLabelStyle,
                            contentPadding: EdgeInsets.only(
                                left: 0, bottom: 0, top: 0, right: 0),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          onChanged: (String value) {
                            setState(() {
                              _transactionData['holding'] = value;
                            });
                          },
                          style: inputFieldStyle)),
                ],
              ),
              SizedBox(height: getScaledValue(20.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: getScaledValue(5)),
                      child: Image.asset('assets/icon/icon_price.png',
                          width: getScaledValue(15))),
                  SizedBox(width: getScaledValue(5)),
                  Expanded(
                      child: TextFormField(
                          focusNode: focusNodes['price'],
                          controller: _controller['price'],
                          validator: (value) {
                            /* if ( value.length < 2 || value.isEmpty) {
											return "Invalid First Name";
										} */
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText:
                                (ricData['type'].toLowerCase() == "commodity"
                                    ? 'Price per gram'
                                    : 'Price per unit'),
                            labelStyle: focusNodes['price'].hasFocus
                                ? inputLabelFocusStyle
                                : inputLabelStyle,
                            contentPadding: EdgeInsets.only(
                                left: 0, bottom: 0, top: 0, right: 0),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          onChanged: (String value) {
                            setState(() {
                              _transactionData['price'] = value;
                            });
                          },
                          style: inputFieldStyle)),
                ],
              ),
              SizedBox(height: getScaledValue(20.0)),
              Container(
                  padding: EdgeInsets.symmetric(
                      vertical: getScaledValue(6),
                      horizontal: getScaledValue(11)),
                  decoration: BoxDecoration(
                    color: Color(0xfff3f3f3),
                    borderRadius: BorderRadius.circular(getScaledValue(4)),
                  ),
                  child: Text(
                      "Please note: any changes made in this won’t be reflected in any other portfolio",
                      style: textStyleNote))
            ],
          )),
    );
  }

  setTransactionForm(Map transactionData, int index) {
    _transactionAction = "new";
    _transactionIndex = null;
    _controller['date'].text = "";
    _transactionTypeValue = 'buy';
    _controller['holding'].text = "1";
    _controller['price'].text = "";

    if (transactionData != null) {
      _transactionAction = "edit";
      _transactionIndex = index;
      _controller['date'].text = transactionData['date'];
      _transactionTypeValue = transactionData['type'];
      _controller['holding'].text = transactionData['holding'];
      _controller['price'].text = transactionData['price'];
    }
  }

  saveTransaction({String action = "update"}) {
    if (validateTransaction(action: 'update')) {
      saveTransactionFinal(_transactionDetails, globalTotalHoldings);
      Navigator.pop(context, () {});
    }
  }

  deleteTransaction(int index) {
    if (validateTransaction(action: 'delete', index: index)) {
      saveTransactionFinal(_transactionDetails, globalTotalHoldings);
    }
  }

  validateTransaction({String action = "update", int index}) {
    // saveTransactionFinal(_transactionDetailsTmp, totalHoldings);

    int errorFlag = 0;
    _transactionDetailsTmp.clear();

    _transactionDetailsTmp = _transactionDetails.toList();

    if (action == "update") {
      if (_transactionAction == "new") {
        setState(() {
          _transactionDetailsTmp.add({
            'ric': _selectedSuggestion['ric'],
            'holding': _controller['holding'].text,
            'type': _transactionTypeValue,
            'price': _controller['price'].text,
            'date': _controller['date'].text,
          });
        });
      } else if (_transactionAction == "edit") {
        _transactionDetailsTmp[_transactionIndex]['holding'] =
            _controller['holding'].text;
        _transactionDetailsTmp[_transactionIndex]['type'] =
            _transactionTypeValue;
        _transactionDetailsTmp[_transactionIndex]['price'] =
            _controller['price'].text;
        _transactionDetailsTmp[_transactionIndex]['date'] =
            _controller['date'].text;
      }
    } else if (action == "delete") {
      setState(() {
        _transactionDetailsTmp.removeAt(index);
      });
    }

    _transactionDetailsTmp.sort((a, b) {
      var adate = a['date']; //before -> var adate = a.expiry;
      var bdate = b['date']; //before -> var bdate = b.expiry;
      return adate.compareTo(
          bdate); //to get the order other way just switch `adate & bdate`
    });

    bool counterFlag = true;

    double totalHoldings = 0;
    _transactionDetailsTmp.forEach((element) {
      if (counterFlag && element['type'] == "sell") {
        errorFlag = 1;
        //return;
      } else {
        counterFlag = false;
      }
      if (element['type'] == "buy") {
        totalHoldings += double.parse(element['holding']);
      } else if (element['type'] == "sell") {
        totalHoldings -= double.parse(element['holding']);
      }

      if (element['date'] == null || element['date'] == "") {
        //errorFlag = 4;

      }
    });

    if (totalHoldings < 0 && errorFlag == 0) {
      errorFlag = 2;
    }

    /* if(totalHoldings == 0){
			errorFlag = 3;
		} */

    if (errorFlag == 1) {
      customAlertBox(
          context: context,
          type: "error",
          title: "Error!",
          description: "First transaction can't be of type sell!",
          buttons: null);
    } else if (errorFlag == 2) {
      customAlertBox(
          context: context,
          type: "error",
          title: "Error!",
          description: "Current holdings can't be less than 0",
          buttons: null);
    } else if (errorFlag == 3) {
      /* setState(() {
				log.d(widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios']);

				widget.model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]['portfolios'][_selectedSuggestion['type']].removeWhere((item) => item['ric'] == _selectedSuggestion['ric']);
				log.d(widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios']);
			});
			Navigator.pop(context);
			//showAlertDialogBox(context, "Error!", "Current holdings can't be 0"); */
    } else if (errorFlag == 4) {
      showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: new Text(
                "You have not specified a date for one or more transactions. These will be recorded with a default older date of transaction."),
            actions: [
              CupertinoDialogAction(
                  onPressed: () {
                    saveTransactionFinal(_transactionDetailsTmp, totalHoldings);
                    Navigator.pop(context);
                  },
                  child: new Text("Continue")),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text("Cancel"))
            ],
          );
        },
      );
    }

    if (errorFlag == 0) {
      setState(() {
        globalTotalHoldings = totalHoldings;
        _transactionDetails = _transactionDetailsTmp.toList();
      });

      return true;
    } else {
      return false;
    }
  }

  saveTransactionFinal(List _transactionDetailsTmp, double totalHoldings) {
    setState(() {
      if (widget.mode == "edit") {
        ricData['transactions'] = _transactionDetailsTmp;
        _transactionDetails = _transactionDetailsTmp;
        ricHolding = totalHoldings.toString();

        widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios']
                [_selectedSuggestion['type']][int.parse(widget.ricIndex)]
            ['transactions'] = _transactionDetailsTmp;
        widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios']
                [_selectedSuggestion['type']][int.parse(widget.ricIndex)]
            ['weightage'] = totalHoldings.toString();
      } else {
        if (!widget
            .model.userPortfoliosData[widget.portfolioMasterID]['portfolios']
            .containsKey(_selectedSuggestion['type'])) {
          widget.model.userPortfoliosData[widget.portfolioMasterID]
              ['portfolios'][_selectedSuggestion['type']] = [];
        }
        widget
            .model
            .userPortfoliosData[widget.portfolioMasterID]['portfolios']
                [_selectedSuggestion['type']]
            .add({
          'zone': _selectedSuggestion['zone'],
          'ric': _selectedSuggestion['ric'],
          'name': _selectedSuggestion['name'],
          'type': _selectedSuggestion['type'],
          'weightage': totalHoldings.toString(),
          'transactions': _transactionDetailsTmp
        });
      }
    });

    if (widget.action != "new") {
      updateCustomerPortfolioData();
    }
  }

  updateCustomerPortfolioData() async {
    String portfolioName = widget
        .model.userPortfoliosData[widget.portfolioMasterID]['portfolio_name'];

    widget.model.setLoader(true);

    Map<String, dynamic> responseData = await widget.model
        .updateCustomerPortfolioData(
            portfolios: widget.model
                .userPortfoliosData[widget.portfolioMasterID]['portfolios'],
            portfolioMasterID: widget.portfolioMasterID,
            portfolioName:
                widget.model.userPortfoliosData[widget.portfolioMasterID]
                    ['portfolio_name']);

    widget.model.setLoader(false);

    //widget.refreshParentState();

    if (responseData['status'] == true) {
      if (widget.action == "new") {
        Navigator.pushReplacementNamed(context, '/success_page', arguments: {
          'type': 'newPortfolio',
          'portfolio_name':
              portfolioName, //widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolio_name'],
          'portfolioMasterID': responseData['portfolioMasterID'],
          'holdingName': ricData['name'],
          'action': widget.arguments.containsKey('action')
              ? widget.arguments['action']
              : 'newPortfolio'
        });
      } else {}
    }
  }
}
