import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/main.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio/add_portfolio_styles.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_widget_common.dart';
import 'package:qfinr/pages/manage_transaction/large_fund_info.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('ManageTransactionPage');

class LargeManageTransactionPage extends StatefulWidget {
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

  LargeManageTransactionPage(this.model,
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
    return _LargeManageTransactionPageState();
  }
}

class _LargeManageTransactionPageState
    extends State<LargeManageTransactionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String sortByText = "";
  String currencyValues;
  Map ricData;
  MainModel model;
  String portfolioMasterID;
  bool ricSelected;
  String action;
  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;
  Map<String, dynamic> responseDatas;
  Map portfolioMasterDatas;
  String ricType;
  String ricIndex;
  bool readOnly;
  //Function refreshParent;
  String ricHolding = "";

  final controller = ScrollController();

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

  List _transactionDetails = [];
  List _transactionDetailsTmp = [];

  double globalTotalHoldings;

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
      fetchFundInformation();
      ricHolding = ricData['weightage'].toString();
      _selectedSuggestion = {
        "ric": widget.ricName,
        "name": widget.model.userPortfoliosData[widget.portfolioMasterID]
            ['portfolios'][widget.ricType][int.parse(widget.ricIndex)]['name'],
        'zone': widget.ricZone,
        'type': widget.ricType,
      };

      if (_transactionDetails != null && _transactionDetails.length < 1) {
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

  refreshParent() => setState(() {
        // log.d('debug 131 refreshParent function');
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
          fetchFundInformation();
          ricHolding = ricData['weightage'].toString();
          _selectedSuggestion = {
            "ric": widget.ricName,
            "name": widget.model.userPortfoliosData[widget.portfolioMasterID]
                    ['portfolios'][widget.ricType][int.parse(widget.ricIndex)]
                ['name'],
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
      });

  fetchFundInformation() async {
    setState(() {
      widget.model.setLoader(true);
    });
    responseDatas = await widget.model.fetchFundInfo(ricData['ric'])
        as Map<String, dynamic>;
    setState(() {
      widget.model.setLoader(false);
    });
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
    changeStatusBarColor(Colors.white);
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
    return WillPopScope(onWillPop: () async {
      onPageClose();
    }, child: PageWrapper(
      child: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          // appBar: commonScrollAppBar(
          //     controller: controller,
          //     bgColor: Colors.white,
          //     actions: [
          //       GestureDetector(
          //         onTap: () => Navigator.pushReplacementNamed(
          //             context, widget.model.redirectBase),
          //         child: AppbarHomeButton(),
          //       ),
          //       widget.action != 'new' && !widget.readOnly
          //           ? PopupMenuButton(
          //         //icon: Icon(Icons.add),
          //         onSelected: (value) async {
          //           if (value == "delete") {
          //             confirmDelete();
          //           }
          //         },
          //         itemBuilder: (BuildContext context) {
          //           return popupMenu.map((menu) {
          //             return PopupMenuItem(
          //                 value: menu['action'], child: Text(menu['text']));
          //           }).toList();
          //         },
          //       )
          //           : emptyWidget,
          //     ]),
          body: _buildBodyForWeb(),
        );
      }),
    ));
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

    if (PlatformCheck.isSmallScreen(context)) {
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
              setState(() {
                widget.model.setLoader(true);
              });

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
                    portfolios: widget
                            .model.userPortfoliosData[widget.portfolioMasterID]
                        ['portfolios'],
                    portfolioMasterID: widget.portfolioMasterID,
                    portfolioName: widget
                            .model.userPortfoliosData[widget.portfolioMasterID]
                        ['portfolio_name']);
              }

              if (responseData['status'] == true) {
                Navigator.pushReplacementNamed(
                    context, '/manage_portfolio_master_view');
              }
              setState(() {
                widget.model.setLoader(false);
              });
            },
          ),
        ],
      );
    } else if (PlatformCheck.isMediumScreen(context) ||
        PlatformCheck.isLargeScreen(context)) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 200,
                  //  color: Colors.orange,
                  child: Text(
                    "Confirm Delete!",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'roboto',
                        letterSpacing: 0.25,
                        color: Color(0xffa5a5a5)),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Color(0xffcccccc), size: 18),
                )
              ],
            ),
            content: Container(
                //  color: Colors.pink,
                width: MediaQuery.of(context).size.width * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (portfolioCount == 1
                            ? "This will delete portfolio. Are you sure you want to delete this portfolio?"
                            : "Are you sure you want to delete this investment?"),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'roboto',
                            letterSpacing: 0.25,
                            color: Color(0xffa5a5a5)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                height: 40,
                                child: flatButtonTextForWeb("NO", context,
                                    borderColor: colorBlue,
                                    onPressFunction: () =>
                                        Navigator.of(context).pop(false))),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                height: 40,
                                width: 120,
                                child: gradientButtonForWeb(
                                  context: context,
                                  caption: "Yes",
                                  onPressFunction: () {
                                    deleteAlert(portfolioCount);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            actions: <Widget>[],
          );
        },
      );
    } else {
      return Container();
    }
  }

  deleteAlert(int portfolioCount) async {
    Navigator.of(context).pop(true);
    // Navigator.of(context)
    //     .popUntil((route) => route.isFirst);

    widget.model.setLoader(true);

    Map<String, dynamic> responseData;

    if (portfolioCount == 1) {
      responseData =
          await widget.model.removePortfolioMaster(widget.portfolioMasterID);
    } else {
      widget
          .model
          .userPortfoliosData[widget.portfolioMasterID]['portfolios']
              [_selectedSuggestion['type']]
          .removeAt(int.parse(widget.ricIndex));
      responseData = await widget.model.updateCustomerPortfolioData(
          portfolios: widget.model.userPortfoliosData[widget.portfolioMasterID]
              ['portfolios'],
          portfolioMasterID: widget.portfolioMasterID,
          portfolioName: widget.model
              .userPortfoliosData[widget.portfolioMasterID]['portfolio_name']);
    }

    if (responseData['status'] == true) {
      portfolioCount != null && portfolioCount == 1
          ? Navigator.pushReplacementNamed(
              context, '/manage_portfolio_master_view')
          : portfolioCount != null && portfolioCount != 1
              ? Navigator.pop(context)
              : () {};
      // Navigator.pushReplacementNamed(context,
      //                             '/portfolio_view/' + widget.portfolioMasterID,
      //                             arguments: {
      //                               "readOnly": false
      //                             }).then((_) => refreshParent()) : (){};
    }
    widget.model.setLoader(false);
  }

  Widget _buildBodyForWeb() {
    try {
      if (widget.action != "new") {
        if (widget.model.userPortfoliosData[widget.portfolioMasterID] == null) {
          // Future.delayed(Duration(milliseconds: 100), () {
          //   Navigator.pop(context);
          // });
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
    return _buildBodyForPlatforms();
  }

  Widget _buildBodyForPlatforms() {
    return _largeScreenBody();
  }

  Widget _largeScreenBody() => Column(
        children: [
          _buildTopBar(),
          _bodyContents(), // left side
        ],
      );

  Widget _buildTopBar() => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        child: NavigationTobBar(
          widget.model,
          openDrawer: () => _scaffoldKey.currentState.openDrawer(),
        ),
      );

  Widget _bodyContents() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          deviceType == DeviceScreenType.tablet
              ? SizedBox()
              : NavigationLeftBar(
                  isSideMenuHeadingSelected: 1, isSideMenuSelected: 1),
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
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
    if (PlatformCheck.isSmallScreen(context)) {
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
              {
                "title": "Highest to Lowest",
                "type": "holding",
                "order": "desc"
              },
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
    } else {
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
                  child: Icon(Icons.close, color: Color(0xffcccccc), size: 18),
                )
              ],
            ),
            content: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getScaledValue(6)),
                    _sortOptionSection(title: "Transaction Date", options: [
                      {
                        "title": "Latest to Oldest",
                        "type": "date",
                        "order": "desc"
                      },
                      {
                        "title": "Oldest to Latest",
                        "type": "date",
                        "order": "asc"
                      }
                    ]),
                    Divider(
                      color: Color(0x251e1e1e),
                    ),
                    _sortOptionSection(title: "Units", options: [
                      {
                        "title": "Highest to Lowest",
                        "type": "holding",
                        "order": "desc"
                      },
                      {
                        "title": "Lowest to Highest",
                        "type": "holding",
                        "order": "asc"
                      }
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
              ),
            ),
            actions: <Widget>[],
          );
        },
      );
    }
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
          sortByText = optionRow['title'];
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
            TextButton(
              style: qfButtonStyle0,
              child: Text("Cancel", style: dialogBoxActionInactive),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformCheck.isSmallScreen(context)
                ? FlatButton(
                    child: Text("Save",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(14.0),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'nunito',
                            letterSpacing: 0,
                            color: colorBlue)),
                    onPressed: () {
                      saveTransaction();
                      //Navigator.of(context).pop();
                    },
                  )
                : Container(
                    height: 33,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff0941cc), Color(0xff0055fe)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: FlatButton(
                      child: Text("Save",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(14.0),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'nunito',
                              letterSpacing: 0,
                              color: Colors.white)),
                      onPressed: () {
                        saveTransaction();
                        //Navigator.of(context).pop();
                      },
                    ),
                  ),
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
      width: PlatformCheck.isSmallScreen(context)
          ? double.maxFinite
          : MediaQuery.of(context).size.width * 0.3,
      height: PlatformCheck.isSmallScreen(context)
          ? double.maxFinite < getScaledValue(365)
              ? double.maxFinite
              : null
          : MediaQuery.of(context).size.width * 0.3, // double.maxFinite,
      child: Form(
          key: _registrationKey,
          autovalidate: _registrationAutoValidate,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              PlatformCheck.isSmallScreen(context)
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        child: Text("ADD A NEW HOLDING",
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'nunito',
                                letterSpacing: 0.29,
                                color: Color(0xff181818))),
                      ),
                    ),
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
      showAlertDialogBox(
          context, 'Error!', "First transaction can't be of type sell!");
      // customAlertBox(
      //     context: context,
      //     type: "error",
      //     title: "Error!",
      //     description: "First transaction can't be of type sell!",
      //     buttons: null);
    } else if (errorFlag == 2) {
      showAlertDialogBox(
          context, 'Error!', "Current holdings can't be less than 0");
      // customAlertBox(
      //     context: context,
      //     type: "error",
      //     title: "Error!",
      //     description: "Current holdings can't be less than 0",
      //     buttons: null);
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

    setState(() {
      widget.model.setLoader(true);
    });

    Map<String, dynamic> responseData = await widget.model
        .updateCustomerPortfolioData(
            portfolios: widget.model
                .userPortfoliosData[widget.portfolioMasterID]['portfolios'],
            portfolioMasterID: widget.portfolioMasterID,
            portfolioName:
                widget.model.userPortfoliosData[widget.portfolioMasterID]
                    ['portfolio_name']);

    setState(() {
      widget.model.setLoader(false);
    });

    //widget.refreshParentState();

    if (responseData['status'] == true) {
      if (widget.action == "new") {
        Navigator.pushReplacementNamed(context, '/success_page', arguments: {
          'type': 'newPortfolio',
          'portfolio_name': portfolioName,
          //widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolio_name'],
          'portfolioMasterID': responseData['portfolioMasterID'],
          'holdingName': ricData['name'],
          'action': widget.arguments.containsKey('action')
              ? widget.arguments['action']
              : 'newPortfolio'
        });
      } else {}
    }
  }

  ////////////////////////////////////

  Widget _buildBodyContent() {
    if (widget.model.isLoading) {
      return preLoader();
    } else {
      currencyValues = widget.model.userSettings['currency'] != null
          ? widget.model.userSettings['currency']
          : null;
      return Container(
          height: MediaQuery.of(context).size.height,
          color: Color(0xfff5f6fa),
          child: SingleChildScrollView(
            child: widget.ricSelected
                ? Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 10.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     children: [
                        //       widget?.portfolioMasterData['portfolio_name'] != null ?
                        //       Text(
                        //           "Portfolio > ${widget?.portfolioMasterData['portfolio_name']} > ${ricData['name']}",
                        //           style: TextStyle(
                        //             fontSize: 11,
                        //             fontWeight: FontWeight.w600,
                        //             fontFamily: 'nunito',
                        //             letterSpacing: 0.40,
                        //             color: Color(0xff8e8e8e),
                        //           )) : Container(),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_left,
                                color: colorBlue,
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.pop(context);
                                  //  Navigator.pop(context);
                                },
                                child: Text(
                                  "Back",
                                  style: AddPortfolioStyles.blueLinkTextBold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ResponsiveBuilder(
                                builder: (context, sizingInformation) {
                                  if (sizingInformation.deviceScreenType ==
                                      DeviceScreenType.desktop) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.40,
                                      // color: Colors.yellow,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 6.0, right: 6.0, bottom: 6.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                responseDatas['response']
                                                        ['details']['ticker'] ??
                                                    "",
                                                style: bodyText4),
                                            Row(
                                              children: [
                                                Text(
                                                    responseDatas['response']
                                                        ['details']['name'],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'nunito',
                                                        letterSpacing: 0.29,
                                                        color:
                                                            Color(0xff181818))),
                                                SizedBox(
                                                    width: getScaledValue(7)),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            '/fund_info',
                                                            arguments: {
                                                          'ric': ricData['ric']
                                                        });
                                                  },
                                                  child: svgImage(
                                                      'assets/icon/icon_details.svg'),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                children: [
                                                  widget.action == "new"
                                                      ? emptyWidget
                                                      : widgetBubble(
                                                          title: ricData['type']
                                                              .toUpperCase()
                                                              .toUpperCase(),
                                                          leftMargin: 0,
                                                          rightMargin: 0,
                                                          bgColor: Colors.white,
                                                          textColor: Color(
                                                              0xffa7a7a7)),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: widgetZoneFlag(
                                                        ricData['zone']),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Container(
                                                      color: Color(0xffeaeaea),
                                                      width: 2,
                                                      height: 15,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                            ricData['type']
                                                                        .toLowerCase() ==
                                                                    "commodity"
                                                                ? "Total Grams: "
                                                                : "Total Units: ",
                                                            style:
                                                                transactionBoxLabel),
                                                        Image.asset(
                                                            "assets/icon/icon_units.png",
                                                            width:
                                                                getScaledValue(
                                                                    14)),
                                                        Text(ricHolding,
                                                            style:
                                                                transactionBoxDetail),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: responseDatas[
                                                                        'response']
                                                                    ['details']
                                                                ['core2'] !=
                                                            null
                                                        ? ricData['transactions'] !=
                                                                    null &&
                                                                ricData['transactions']
                                                                        .length >
                                                                    0
                                                            ? Container()
                                                            : Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "Category: ",
                                                                      style:
                                                                          bodyText4),
                                                                  Container(
                                                                    // color: Colors.green,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.10,
                                                                    child: Text(
                                                                        responseDatas['response']['details']
                                                                            [
                                                                            'core2'],
                                                                        style:
                                                                            bodyText10),
                                                                  )
                                                                ],
                                                              )
                                                        : emptyWidget,
                                                  ),
                                                  PlatformCheck.isLargeScreen(
                                                          context)
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10.0),
                                                          child: responseDatas[
                                                                              'response']
                                                                          [
                                                                          'details']
                                                                      [
                                                                      'sector'] !=
                                                                  null
                                                              ? ricData['transactions'] !=
                                                                          null &&
                                                                      ricData['transactions']
                                                                              .length >
                                                                          0
                                                                  ? Container()
                                                                  : Row(
                                                                      children: [
                                                                        Text(
                                                                            "Sector: ",
                                                                            style:
                                                                                bodyText4),
                                                                        Container(
                                                                          // color: Colors.purple,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.10,
                                                                          child: Text(
                                                                              responseDatas['response']['details']['sector'],
                                                                              style: bodyText10),
                                                                        )
                                                                      ],
                                                                    )
                                                              : emptyWidget,
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                            PlatformCheck.isMediumScreen(
                                                    context)
                                                ? responseDatas['response']
                                                                ['details']
                                                            ['sector'] !=
                                                        null
                                                    ? ricData['transactions'] !=
                                                                null &&
                                                            ricData['transactions']
                                                                    .length >
                                                                0
                                                        ? Container()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        8.0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text("Sector: ",
                                                                    style:
                                                                        bodyText4),
                                                                Container(
                                                                  // color: Colors.purple,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.10,
                                                                  child: Text(
                                                                      responseDatas['response']
                                                                              [
                                                                              'details']
                                                                          [
                                                                          'sector'],
                                                                      style:
                                                                          bodyText10),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                    : emptyWidget
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  if (sizingInformation.deviceScreenType ==
                                      DeviceScreenType.tablet) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.60,
                                      // color: Colors.yellow,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 6.0, right: 6.0, bottom: 6.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                responseDatas['response']
                                                        ['details']['ticker'] ??
                                                    "",
                                                style: bodyText4),
                                            Row(
                                              children: [
                                                Text(
                                                    responseDatas['response']
                                                        ['details']['name'],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'nunito',
                                                        letterSpacing: 0.29,
                                                        color:
                                                            Color(0xff181818))),
                                                SizedBox(
                                                    width: getScaledValue(7)),
                                                GestureDetector(
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/fund_info',
                                                              arguments: {
                                                        'ric': ricData['ric']
                                                      }),
                                                  child: svgImage(
                                                      'assets/icon/icon_details.svg'),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                children: [
                                                  widget.action == "new"
                                                      ? emptyWidget
                                                      : widgetBubble(
                                                          title: ricData['type']
                                                              .toUpperCase()
                                                              .toUpperCase(),
                                                          leftMargin: 0,
                                                          rightMargin: 0,
                                                          bgColor: Colors.white,
                                                          textColor: Color(
                                                              0xffa7a7a7)),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: widgetZoneFlag(
                                                        ricData['zone']),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Container(
                                                      color: Color(0xffeaeaea),
                                                      width: 2,
                                                      height: 15,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                            ricData['type']
                                                                        .toLowerCase() ==
                                                                    "commodity"
                                                                ? "Total Grams: "
                                                                : "Total Units: ",
                                                            style:
                                                                transactionBoxLabel),
                                                        Image.asset(
                                                            "assets/icon/icon_units.png",
                                                            width:
                                                                getScaledValue(
                                                                    14)),
                                                        Text(ricHolding,
                                                            style:
                                                                transactionBoxDetail),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: responseDatas[
                                                                        'response']
                                                                    ['details']
                                                                ['core2'] !=
                                                            null
                                                        ? ricData['transactions'] !=
                                                                    null &&
                                                                ricData['transactions']
                                                                        .length >
                                                                    0
                                                            ? Container()
                                                            : Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "Category: ",
                                                                      style:
                                                                          bodyText4),
                                                                  Container(
                                                                    // color: Colors.green,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.10,
                                                                    child: Text(
                                                                        responseDatas['response']['details']
                                                                            [
                                                                            'core2'],
                                                                        style:
                                                                            bodyText10),
                                                                  )
                                                                ],
                                                              )
                                                        : emptyWidget,
                                                  ),
                                                  PlatformCheck.isLargeScreen(
                                                          context)
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10.0),
                                                          child: responseDatas[
                                                                              'response']
                                                                          [
                                                                          'details']
                                                                      [
                                                                      'sector'] !=
                                                                  null
                                                              ? ricData['transactions'] !=
                                                                          null &&
                                                                      ricData['transactions']
                                                                              .length >
                                                                          0
                                                                  ? Container()
                                                                  : Row(
                                                                      children: [
                                                                        Text(
                                                                            "Sector: ",
                                                                            style:
                                                                                bodyText4),
                                                                        Container(
                                                                          // color: Colors.purple,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.10,
                                                                          child: Text(
                                                                              responseDatas['response']['details']['sector'],
                                                                              style: bodyText10),
                                                                        )
                                                                      ],
                                                                    )
                                                              : emptyWidget,
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                            PlatformCheck.isMediumScreen(
                                                    context)
                                                ? responseDatas['response']
                                                                ['details']
                                                            ['sector'] !=
                                                        null
                                                    ? ricData['transactions'] !=
                                                                null &&
                                                            ricData['transactions']
                                                                    .length >
                                                                0
                                                        ? Container()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        8.0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text("Sector: ",
                                                                    style:
                                                                        bodyText4),
                                                                Container(
                                                                  // color: Colors.purple,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.10,
                                                                  child: Text(
                                                                      responseDatas['response']
                                                                              [
                                                                              'details']
                                                                          [
                                                                          'sector'],
                                                                      style:
                                                                          bodyText10),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                    : emptyWidget
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                widget.action != 'new' && !widget.readOnly
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            confirmDelete();
                                          },
                                          child: Container(
                                            height: 33,
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: colorBlue,
                                                  width: 1.25),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Delete Holding",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: colorBlue,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  height: 33,
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: colorBlue, width: 1.25),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.white,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: Colors.white,
                                        hint: Text(
                                          (widget.model.userSettings[
                                                          'currency'] !=
                                                      null
                                                  ? widget.model
                                                      .userSettings['currency']
                                                  : "inr")
                                              .toUpperCase(),
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
                                        value: currencyValues,
                                        selectedItemBuilder: (context) {
                                          return widget.model.currencies
                                              .map<Widget>((Map item) {
                                            return DropdownMenuItem<String>(
                                              value: item['key'],
                                              child: Text(
                                                item['value'],
                                                style: heading_alert_view_all,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }).toList();
                                        },
                                        items: widget.model.currencies
                                            .map((Map item) {
                                          var textColor = (currencyValues
                                                  .contains(item['key']))
                                              ? Colors.white
                                              : MyApp.commonPrimaryColor;

                                          return DropdownMenuItem<String>(
                                            value: item['key'],
                                            child: Text(
                                              item['value'],
                                              style: heading_alert_view_all
                                                  .copyWith(color: textColor),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }).toList(),

                                        onChanged: ricData['value'] == null
                                            ? null
                                            : (value) {
                                                if (ricData['value'] != null) {
                                                  setState(() {
                                                    currencyValues = value;
                                                  });
                                                  _currencySelectionForWeb(
                                                      currencyValues);
                                                }
                                              },
                                        // onChanged: (value) {
                                        //   if (ricData['value']!=null
                                        //       ) {
                                        //     setState(() {
                                        //       currencyValues = value;
                                        //     });
                                        //     _currencySelectionForWeb(
                                        //         currencyValues);
                                        //   }
                                        // }
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Material(
                          elevation: 2.0,
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: widget.action == 'new'
                                              ? emptyWidget
                                              : Container(
                                                  height: getScaledValue(375),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color(0xffe9e9e9),
                                                      width: 1.25,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child:
                                                        widget.action == 'new'
                                                            ? emptyWidget
                                                            : Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text("Price Today",
                                                                                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, fontFamily: 'nunito', letterSpacing: 0.19, color: Color(0xff383838))),
                                                                            Text("As on " + dateString(responseDatas['response']['value']['latest_date'], format: 'dd MMM, yyyy'),
                                                                                style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w500, fontFamily: 'nunito', letterSpacing: 0.19, color: Color(0xff383838))),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                            ricData[
                                                                                'value'],
                                                                            style: TextStyle(
                                                                                fontSize: 20.0,
                                                                                fontWeight: FontWeight.w800,
                                                                                fontFamily: 'nunito',
                                                                                letterSpacing: 0.19,
                                                                                color: Color(0xff383838))),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            20.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: [
                                                                                Text(Contants.oneDayReturns, style: keyStatsBodyText2),
                                                                                SizedBox(width: getScaledValue(5)),
                                                                                (ricData['change_sign'] == "up" || ricData['change_sign'] == "down" ? Text(ricData['change'].toString() + "%", style: bodyText12.copyWith(color: ricData['change_sign'] == "up" ? colorGreenReturn : colorRedReturn)) : emptyWidget),
                                                                              ],
                                                                            ),
                                                                            Text(ricData['changeAmount'],
                                                                                style: bodyText12.copyWith(color: ricData['change_sign'] == "up" ? colorGreenReturn : colorRedReturn)),
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: [
                                                                                Text(Contants.monthToDate, style: keyStatsBodyText2),
                                                                                SizedBox(width: getScaledValue(5)),
                                                                                (ricData['changeMonth_sign'] == "up" || ricData['changeMonth_sign'] == "down" ? Text(ricData['changeMonth'].toString() + "%", style: bodyText12.copyWith(color: ricData['changeMonth_sign'] == "up" ? colorGreenReturn : colorRedReturn)) : emptyWidget),
                                                                              ],
                                                                            ),
                                                                            Text(ricData['changeAmountMonth'],
                                                                                style: bodyText12.copyWith(color: ricData['changeMonth_sign'] == "up" ? colorGreenReturn : colorRedReturn)),
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: [
                                                                                Text(Contants.yearToDate, style: keyStatsBodyText2),
                                                                                SizedBox(width: getScaledValue(5)),
                                                                                (ricData['changeYear_sign'] == "up" || ricData['changeYear_sign'] == "down" ? Text(ricData['changeYear'].toString() + "%", style: bodyText12.copyWith(color: ricData['changeYear_sign'] == "up" ? colorGreenReturn : colorRedReturn)) : emptyWidget),
                                                                              ],
                                                                            ),
                                                                            Text(ricData['changeAmountYear'],
                                                                                style: bodyText12.copyWith(color: ricData['changeYear_sign'] == "up" ? colorGreenReturn : colorRedReturn)),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15.0,
                                              right: 15.0,
                                              bottom: 15.0),
                                          child: Container(
                                            height: getScaledValue(375),
                                            color: Colors.white,
                                            child: LargeFundInfo(
                                              widget.model,
                                              analytics: widget.analytics,
                                              observer: widget.observer,
                                              ric: ricData['ric'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 15.0,
                                          left: 15.0,
                                          right: 15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFf3f3f3),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(
                                                                      5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("KEY STATS",
                                                            style:
                                                                keyStatsBodyHeading),
                                                        GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                    title: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap: () =>
                                                                              Navigator.pop(context),
                                                                          child: Icon(
                                                                              Icons.close,
                                                                              color: Color(0xffcccccc),
                                                                              size: 18),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    content:
                                                                        Container(
                                                                      color: Colors
                                                                          .white,
                                                                      // height: MediaQuery.of(context)
                                                                      //         .size
                                                                      //         .height *
                                                                      //     0.5,
                                                                      height:
                                                                          300,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.3,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text('Returns',
                                                                                style: sortbyOptionHeading),
                                                                            Text(
                                                                              "The annualized 3 year returns using data as of the end of the preceding month",
                                                                              style: bodyText4,
                                                                            ),
                                                                            Divider(
                                                                              color: Color(0x251e1e1e),
                                                                              thickness: 1,
                                                                            ),
                                                                            SizedBox(height: getScaledValue(20)),
                                                                            Text('Risks',
                                                                                style: sortbyOptionHeading),
                                                                            Text(
                                                                              "The annualized volatility of monthly returns over 3 years as of the end of the preceding month",
                                                                              style: bodyText4,
                                                                            ),
                                                                            Divider(
                                                                              color: Color(0x251e1e1e),
                                                                              thickness: 1,
                                                                            ),
                                                                            SizedBox(height: getScaledValue(20)),
                                                                            Text('Sensitivity',
                                                                                style: sortbyOptionHeading),
                                                                            Text(
                                                                              "The beta computed from the regression of the monthly excess returns of the fund over risk free returns and the excess returns of the fund’s benchmark. We calculate the risk free rate from short term government bills.  It measures the volatility of the fund compared to the systematic risk of the chosen benchmark",
                                                                              style: bodyText4,
                                                                            ),
                                                                            Divider(
                                                                              color: Color(0x251e1e1e),
                                                                              thickness: 1,
                                                                            ),
                                                                            SizedBox(height: getScaledValue(20)),
                                                                            Text('Maximum Loss',
                                                                                style: sortbyOptionHeading),
                                                                            Text(
                                                                              "The maximum observed loss from a peak to a trough, before a new peak is attained over the past 3 years using daily prices. Maximum drawdown is an indicator of downside risk over the time period",
                                                                              style: bodyText4,
                                                                            ),
                                                                            Divider(
                                                                              color: Color(0x251e1e1e),
                                                                              thickness: 1,
                                                                            ),
                                                                            SizedBox(height: getScaledValue(20)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    actions: <
                                                                        Widget>[],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                                'What is this?',
                                                                style:
                                                                    textLink2)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color(0xffe9e9e9),
                                                      width: 1.25,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft: Radius
                                                                .circular(5),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    5)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Return: ${roundDouble(responseDatas['response']['statsData']['cagr'])}%",
                                                              style:
                                                                  keyStatsBodyText1,
                                                            ),
                                                            Text(
                                                              "3 yrs CAGR",
                                                              style:
                                                                  keyStatsBodyText2,
                                                            ),
                                                          ],
                                                        )),
                                                        Expanded(
                                                            child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Risk: ${roundDouble(responseDatas['response']['statsData']['stddev'])}%",
                                                              style:
                                                                  keyStatsBodyText1,
                                                            ),
                                                            Text(
                                                              "Annualised Volatility",
                                                              style:
                                                                  keyStatsBodyText2,
                                                            ),
                                                          ],
                                                        )),
                                                        Expanded(
                                                            child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Sensitivity: ${roundDouble(responseDatas['response']['statsData']['Bench_beta'])}",
                                                              style:
                                                                  keyStatsBodyText1,
                                                            ),
                                                            Text(
                                                              "Beta",
                                                              style:
                                                                  keyStatsBodyText2,
                                                            ),
                                                          ],
                                                        )),
                                                        Expanded(
                                                            child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              "Maximum Loss: ${roundDouble(responseDatas['response']['statsData']['drawdown'])}%",
                                                              style:
                                                                  keyStatsBodyText1,
                                                            ),
                                                            Text(
                                                              "Max Drawdown",
                                                              style:
                                                                  keyStatsBodyText2,
                                                            ),
                                                          ],
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ))
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Material(
                            elevation: 2.0,
                            shape: BeveledRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        )),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(5))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("All Transactions",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'nunito',
                                                        letterSpacing: 0.40,
                                                        color:
                                                            Color(0xff383838),
                                                      )),
                                                  ricData['transactions'] !=
                                                              null &&
                                                          ricData['transactions']
                                                                  .length >
                                                              0
                                                      ? Text(
                                                          " (${ricData['transactions'].length})",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  'nunito',
                                                              letterSpacing:
                                                                  0.16,
                                                              color: Color(
                                                                  0xff818181)))
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        ricData['transactions'] != null &&
                                                ricData['transactions'].length >
                                                    1
                                            ? GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  sortPopup();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 15.0),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Sort By",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xffa5a5a5),
                                                          letterSpacing: 1.0,
                                                        ),
                                                      ),
                                                      sortByText.isNotEmpty
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          5.0),
                                                              child: Text(
                                                                sortByText,
                                                                style: sortbyOptionActive
                                                                    .copyWith(
                                                                        color:
                                                                            colorBlue),
                                                              ),
                                                            )
                                                          : Text(""),
                                                      Icon(
                                                        Icons.arrow_drop_down,
                                                        color: colorBlue,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Color(0xFFf3f3f3),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      // color: Colors.green,
                                                      child: Text(
                                                        "NO OF UNITS",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            keyStatsBodyText2,
                                                      )),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      // color: Colors.green,
                                                      child: Text(
                                                        "TRANSACTION DATE",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            keyStatsBodyText2,
                                                      )),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      // color: Colors.green,
                                                      child: Text(
                                                        "TRANSACTION TYPE",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            keyStatsBodyText2,
                                                      )),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      // color: Colors.green,
                                                      child: Text(
                                                        ricData['type']
                                                                    .toLowerCase() ==
                                                                "commodity"
                                                            ? "PRICE PER GRAM"
                                                            : "PRICE PER UNIT",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            keyStatsBodyText2,
                                                      )),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    // color: Colors.green,
                                                    child: Text(
                                                      "EDIT DELETE",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xFFf3f3f3)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ricData['transactions'] != null
                                      ? ricData['transactions'].length > 0
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5))),
                                              // height: 600,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    ClampingScrollPhysics(),
                                                itemCount: ricData[
                                                            'transactions'] !=
                                                        null
                                                    ? ricData['transactions']
                                                        .length
                                                    : 0,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            right: 15,
                                                            top: 15.0,
                                                            bottom: 15.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              // color: Colors.green,
                                                              child: Text(
                                                                "${double.parse(ricData['transactions'][index]['holding']).toStringAsFixed(2)}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    transactionBoxUnits,
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              // color: Colors.green,
                                                              child: Text(
                                                                "${ricData['transactions'][index]['date']}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    transactionBoxDetail,
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              // color: Colors.green,
                                                              child: Text(
                                                                "${ricData['transactions'][index]['type'].toUpperCase()}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    transactionBoxDetail,
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              // color: Colors.green,
                                                              child: Text(
                                                                ricData['transactions'][index]
                                                                            [
                                                                            'price'] ==
                                                                        null
                                                                    ? '- '
                                                                    : widget.action ==
                                                                            "new"
                                                                        ? getCurrencySymbol(widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios'][widget.ricType][int.parse(widget.ricIndex)]['currency']) +
                                                                            ricData['transactions'][index][
                                                                                'price']
                                                                        : getCurrencySymbol(widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios'][widget.ricType][int.parse(widget.ricIndex)]['currency'].toLowerCase()) +
                                                                            ricData['transactions'][index]['price'],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    transactionBoxDetail,
                                                              )),
                                                        ),
                                                        !widget.readOnly
                                                            ? Expanded(
                                                                child: Container(
                                                                    width: MediaQuery.of(context).size.width * 0.4,
                                                                    // color: Colors.green,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        GestureDetector(
                                                                          behavior:
                                                                              HitTestBehavior.opaque,
                                                                          onTap:
                                                                              () {
                                                                            transactionPopup(
                                                                                transactionData: ricData['transactions'][index],
                                                                                index: index);
                                                                          },
                                                                          child: Text(
                                                                              "EDIT",
                                                                              textAlign: TextAlign.center,
                                                                              style: textLink2),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 8.0),
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                Color(0xFFdddddd),
                                                                            width:
                                                                                1,
                                                                            height:
                                                                                10,
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          behavior:
                                                                              HitTestBehavior.opaque,
                                                                          onTap:
                                                                              () {
                                                                            ricData['transactions'] != null && ricData['transactions'].length == 1
                                                                                ? confirmDelete()
                                                                                : confirmDeleteForTransaction(index);
                                                                          },
                                                                          child: Text(
                                                                              "DELETE",
                                                                              textAlign: TextAlign.center,
                                                                              style: textLink2),
                                                                        ),
                                                                      ],
                                                                    )),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Column(
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/make_payment.png",
                                                              width: 60,
                                                              height: 60,
                                                            ),
                                                            !widget.readOnly
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            15.0),
                                                                    child: Container(
                                                                        width: 175,
                                                                        child: RaisedButton(
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                                                          padding:
                                                                              EdgeInsets.all(0.0),
                                                                          child:
                                                                              Ink(
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                            height:
                                                                                33,
                                                                            decoration: BoxDecoration(
                                                                                gradient: LinearGradient(
                                                                                  colors: [
                                                                                    Color(0xff0941cc),
                                                                                    Color(0xff0055fe)
                                                                                  ],
                                                                                  begin: Alignment.centerLeft,
                                                                                  end: Alignment.centerRight,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(5.0)),
                                                                            child:
                                                                                Container(
                                                                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width, minHeight: 50),
                                                                              alignment: Alignment.center,
                                                                              child: Text(
                                                                                "ADD TRANSACTIONS",
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontSize: 12,
                                                                                  color: Colors.white,
                                                                                  letterSpacing: 1.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          textColor:
                                                                              Colors.white,
                                                                          onPressed: () =>
                                                                              transactionPopup(),
                                                                        )),
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ricData['transactions'] != null
                                ? ricData['transactions'].length > 0
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            !widget.readOnly
                                                ? Container(
                                                    width: 175,
                                                    child: RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      child: Ink(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 33,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                        0xff0941cc),
                                                                    Color(
                                                                        0xff0055fe)
                                                                  ],
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                        child: Container(
                                                          constraints: BoxConstraints(
                                                              maxWidth:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              minHeight: 50),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            "ADD TRANSACTIONS",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white,
                                                              letterSpacing:
                                                                  1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      textColor: Colors.white,
                                                      onPressed: () =>
                                                          transactionPopup(),
                                                    ))
                                                : Container(),
                                          ],
                                        ),
                                      )
                                    : Container()
                                : Container(),
                            widget.action == "new"
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, left: 15.0),
                                    child: Container(
                                        width: 175,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          padding: EdgeInsets.all(0.0),
                                          child: Ink(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 33,
                                            decoration: BoxDecoration(
                                                gradient: (widget
                                                        .model
                                                        .userPortfoliosData[
                                                            widget
                                                                .portfolioMasterID]
                                                            ['portfolios'][
                                                            _selectedSuggestion[
                                                                'type']][
                                                            int.parse(widget.ricIndex)]
                                                            ['transactions']
                                                        .isEmpty)
                                                    ? LinearGradient(
                                                        colors: [
                                                          Colors.grey,
                                                          Colors.grey[400]
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                      )
                                                    : LinearGradient(
                                                        colors: [
                                                          Color(0xff0941cc),
                                                          Color(0xff0055fe)
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                  minHeight: 50),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "CREATE",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          textColor: Colors.white,
                                          onPressed: () {
                                            !(widget
                                                    .model
                                                    .userPortfoliosData[widget
                                                            .portfolioMasterID]
                                                        ['portfolios'][
                                                        _selectedSuggestion[
                                                            'type']][
                                                        int.parse(
                                                            widget.ricIndex)]
                                                        ['transactions']
                                                    .isEmpty)
                                                ? updateCustomerPortfolioData()
                                                : null; //
                                          },
                                        )))
                                : Container(),
                          ],
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 20.0),
                    child: _selectRic(),
                  ),
          ));
    }
  }

  confirmDeleteForTransaction(int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 200,
                //  color: Colors.orange,
                child: Text(
                  "Confirm Delete!",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'roboto',
                      letterSpacing: 0.25,
                      color: Color(0xffa5a5a5)),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: Color(0xffcccccc), size: 18),
              )
            ],
          ),
          content: Container(
              //  color: Colors.pink,
              width: MediaQuery.of(context).size.width * 0.4,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This will delete the transaction. Are you sure you want to proceed?",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'roboto',
                          letterSpacing: 0.25,
                          color: Color(0xffa5a5a5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              height: 40,
                              child: flatButtonTextForWeb("NO", context,
                                  borderColor: colorBlue,
                                  fontSize: 11,
                                  onPressFunction: () =>
                                      Navigator.of(context).pop(false))),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 40,
                              width: 120,
                              child: gradientButtonForWeb(
                                context: context,
                                caption: "Yes",
                                onPressFunction: () async {
                                  Navigator.of(context).pop(true);
                                  // Navigator.of(context)
                                  //     .popUntil((route) => route.isFirst);
                                  deleteTransaction(index);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
          actions: <Widget>[],
        );
      },
    );
  }

  _currencySelectionForWeb(String currencyValues) async {
    Map<String, dynamic> responseData =
        await widget.model.changeCurrency(currencyValues);
    if (responseData['status'] == true) {
      await widget.model.fetchOtherData();
      //widget.refreshParentState();
      refreshParent();
    }
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
