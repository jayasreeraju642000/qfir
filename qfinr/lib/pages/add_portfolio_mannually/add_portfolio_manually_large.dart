import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio_mannually/serach_and_filter_options.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/helpers/search_bank.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

final log = getLogger('AddPortfolioManuallyPage');

//
class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class AddPortfolioManuallyLarge extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer; //

  String pageType;
  String action;

  int portfolioIndex;

  String portfolioMasterID;
  String portfolioDepositID;
  bool viewDeposit = false;
  Map selectedPortfolioMasterIDs;
  Map arguments;

  AddPortfolioManuallyLarge(this.model,
      {this.analytics,
      this.observer,
      this.pageType = "add_portfolio",
      this.action = "newPortfolio",
      this.portfolioIndex = null,
      this.portfolioMasterID,
      this.viewDeposit,
      this.portfolioDepositID,
      this.selectedPortfolioMasterIDs,
      this.arguments});

  @override
  _AddPortfolioManuallyLargeState createState() =>
      _AddPortfolioManuallyLargeState();
}

class _AddPortfolioManuallyLargeState extends State<AddPortfolioManuallyLarge> {
  final GlobalKey<FormState> _addPortfolioForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _addDepositForm = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RangeValues _currentRangeValues;
  List<String> _sourceList = ["equal_weights", "equal_units", "custom"];
  String sourceValues = "custom";
  StateSetter _setState;
  Map filterOptionSelectionReset;
  List fundList;
  String page = "main"; //"add_instrument_new_portfolio"; // "main";
  String activeFilterOption = 'sortby';
  RICs selectedRICs;
  final controller = ScrollController();
  String portfolioNameErrorMsg = '';

  Map<String, FocusNode> focusNodesUnits = {};
  Map<String, TextEditingController> _controllerUnits = {};

  String unitOption = "custom";
  TextEditingController _popupSearchFieldController = TextEditingController();

  num portfolioAmount = 0;
  List<RICs> searchList = [];

  Map filterOptionSelection = SerachAndFilterOptions.filterOptionSelection;
  Map filterOptions = SerachAndFilterOptions.filterOptions;

  Map<String, TextEditingController> _controller = {
    'portfolio_name': new TextEditingController(),
    'ric': new TextEditingController(),
    'portfolio_amount': new TextEditingController(),
    'display_name': new TextEditingController(),
    'bank_name': new TextEditingController(),
    'amount': new TextEditingController(),
    'interest': new TextEditingController(),
    'start_date': new TextEditingController(),
    'end_date': new TextEditingController()
  };

  Map<String, FocusNode> focusNodes = {
    'portfolio_name': new FocusNode(),
    'ric': new FocusNode(),
    'portfolio_amount': new FocusNode(),
    'display_name': new FocusNode(),
    'bank_name': new FocusNode(),
    'amount': new FocusNode(),
    'interest': new FocusNode(),
    'start_date': new FocusNode(),
    'end_date': new FocusNode(),
    'type_of_deposit_acc': new FocusNode(),
    'deposit_type': new FocusNode(),
    'currency': new FocusNode(),
    'frequency': new FocusNode(),
  };

  Map categoryOptions = SerachAndFilterOptions.categoryOptions;

  String _selectedTypeAcc;
  String _selectedDeposit;
  String _selectedCurrency;
  String _selectedFrequency;
  String ricUpdateValue;

  DateTime _depositStartDate = DateTime.now();
  DateTime _depositEndDate;

  final date_format = DateFormat("yyyy-MM-dd");
  String auto_renew = "0";
  String bank_id = "0";
  bool value_auto_renew = false;
  bool depositPortfolio = false;
  bool stockPortfolio = false;

  bool asserts_added_visible = true;
  bool asserts_set_visible = true;
  bool create_button_visible = true;
  bool next_button_visible = false;

  List<Map> type_of_acc_Map = [
    {"type_acc": "Fixed Deposit", "value": "FDEP"},
    {"type_acc": "Recurring Deposit", "value": "RDEP"},
    {"type_acc": "Savings Account", "value": "SDEP"},
    {"type_acc": "Current Account", "value": "CDEP"}
  ];
  Map accTypeDepositMap = {
    "Fixed Deposit": {"value": "1", "ric": "FDEP"},
    "Recurring Deposit": {"value": "2", "ric": "RDEP"},
    "Savings Account": {"value": "3", "ric": "SDEP"},
    "Current Account": {"value": "4", "ric": "CDEP"}
  };
  Map deposite_acc_value = {
    "FDEP": {"value": "Fixed Deposit"},
    "RDEP": {"value": "Recurring Deposit"},
    "SDEP": {"value": "Savings Account"},
    "CDEP": {"value": "Current Account"}
  };

  List<Map> deposit_type_Map = [
    {"deposit_type": "Cumulative", "value": "C"},
    {"deposit_type": "Non cumulative", "value": "NC"},
  ];
  Map depositTypeMap = {
    "Cumulative": {"value": "C"},
    "Non cumulative": {"value": "NC"},
  };

  List<Map> frequency_Map = [
    {"frequency": "Monthly", "value": "M"},
    {"frequency": "Quarterly", "value": "Q"},
    {"frequency": "Half Yearly", "value": "H"},
    {"frequency": "Yearly", "value": "Y"},
  ];
  Map frequencyMap = {
    "Monthly": {"value": "M"},
    "Quarterly": {"value": "Q"},
    "Half Yearly": {"value": "H"},
    "Yearly": {"value": "Y"},
  };

  Map depositPortfolioData;

  Map display_name_list = {
    "display_name": "",
  };

  Map depositPortfolioList = {
    "Deposit": "",
  };

  Map deposite_json_value = {
    "currency": "",
    "zone": "gl",
    "ric": "",
    "weightage": "",
    "type": "Deposit",
    "deposit": "",
  };

  List deposit_arrays = [];
  List display_arrays = [];
  List bank_items = [];

  String search_key = "";

  Map<dynamic, dynamic> _banksData;

  void getBanks(key) async {
    _banksData = await widget.model.getBanks(key);

    if (!bank_items.isEmpty) {
      bank_items.clear();
    }

    for (var item in _banksData['response']) {
      HashMap<String, dynamic> banks_dataMap = new HashMap();
      banks_dataMap['zone'] = item['zone'];
      banks_dataMap['bank_name'] = item['bank_name'];
      banks_dataMap['bank_id'] = item['bank_id'];

      bank_items.add(banks_dataMap);
    }
  }

  Future<Null> _analyticsAddManuallyCurrentScreen() async {
    // log.d("\n analyticsAddManuallyCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'add_manually',
      screenClassOverride: 'add_manually',
    );
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Add Portfolio Page",
    });
  }

  Future<Null> _analyticsNextButtonEvent() async {
    // log.d("\n analyticsNextButtonEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "add_manually",
      'item_name': "add_manually_name_portfolio",
      'content_type': "click_next_button",
    });
  }

  Future<Null> _analyticsCreatePortfolioEvent(String portfolioName) async {
    // log.d("\n analyticsNewAssetCurrentScreen called \n");
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "add_manually",
      'item_name': "new_portfolio_creation",
      'content_type': "click_create_portfolio",
      'item_list_name': portfolioName
    });
  }

  Future<Null> _analyticsSearchAssetEvent(String searchTerm) async {
    // log.d(
    // "\n analyticsSearchAssetEvent called with value search term:- $searchTerm \n");
    await widget.analytics.logEvent(name: 'search', parameters: {
      'search_term': searchTerm,
      'item_id': "add_manually",
      'item_name': "add_new_asset_search",
      'content_type': "click_search_box",
    });
  }

  Future<Null> _analyticsSortByEvent(String sortTerm) async {
    // log.d("\n analyticsSortByEvent called with value sort term:- $sortTerm \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "add_manually",
      'item_name': "add_new_asset_sort",
      'content_type': "click_sort_box",
      'content': sortTerm,
    });
  }

  @override
  void initState() {
    _addEvent();
    _analyticsAddManuallyCurrentScreen();
    super.initState();

    filterOptionSelectionReset = Map.from(filterOptionSelection);

    // zones as per user allowed
    widget.model.userSettings['allowed_zones'].forEach((zone) {
      filterOptions['zone']['optionGroups'][0]['options'][zone] =
          zone.toUpperCase();

      if (zone == "in") {
        filterOptionSelection['zone'] = ['in'];
      }
    });
    updateKeyStatsRange();
    _setUserPortfoliosData();
    getBanks(search_key);

    if (widget.action == "split") {
      asserts_added_visible = false;
      asserts_set_visible = false;
      create_button_visible = false;
      next_button_visible = true;
    } else if (widget.action == "merge") {
      asserts_added_visible = false;
      asserts_set_visible = false;
      create_button_visible = false;
      next_button_visible = true;
    } else if (widget.action == "rename") {
      asserts_added_visible = false;
      asserts_set_visible = false;
      create_button_visible = false;
      next_button_visible = true;
    } else if (widget.action == "discover") {
      asserts_added_visible = false;
      asserts_set_visible = false;
      create_button_visible = false;
      next_button_visible = true;
    }
  }

  addPortfolioAction() async {
    // validate portfolio name

    bool sameName = false;

    widget.model.userPortfoliosData.forEach((key, value) {
      if (value['portfolio_name'] == _controller['portfolio_name'].text &&
          key != '0') {
        sameName = true;
        return false;
      }
    });

    if (sameName) {
      showAlertDialogBox(
          context, 'Error!', "Portfolio with same name already exists");
      // customAlertBoxLarge(
      //     context: context,
      //     type: "error",
      //     title: "Error!",
      //     description: "Portfolio with same name already exists",
      //     buttons: null);
      return;
    }

    // setState(() {
    //   if (sameName) {
    //     // customAlertBox(context: context, type: "error", title: "Error!", description: "Portfolio with same name already exists", buttons: null);
    //     portfolioNameErrorMsg = "Portfolio with same name already exists";
    //     return;
    //   } else {
    //     portfolioNameErrorMsg = '';
    //   }
    // });

    if (widget.action == "split") {
      //
      Map newPortfolioData = new Map.from(
          widget.model.userPortfoliosData[widget.portfolioMasterID]);
      newPortfolioData['portfolio_name'] = _controller['portfolio_name'].text;

      setState(() {
        widget.model.setLoader(true);
      });
      Map<String, dynamic> responseData = await widget.model
          .updateCustomerPortfolioData(
              portfolios: newPortfolioData['portfolios'],
              zone: newPortfolioData['portfolio_zone'],
              riskProfile: widget.model.newUserRiskProfile,
              portfolioMasterID: '0',
              portfolioName: _controller['portfolio_name'].text);

      if (responseData['status'] == true) {
        Navigator.pushReplacementNamed(
            context, '/manage_portfolio_master_view');
      }

      setState(() {
        widget.model.setLoader(false);
      });
    } else if (widget.action == "merge") {
      List selectedPortfoliosList = [];

      widget.selectedPortfolioMasterIDs.forEach((key, value) {
        if (value == true) {
          selectedPortfoliosList.add(key);
        }
      });

      setState(() {
        widget.model.setLoader(true);
      });
      await widget.model.mergePortfolios(
          portfolios: selectedPortfoliosList,
          portfolioName: _controller['portfolio_name'].text);
      Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');
      setState(() {
        widget.model.setLoader(false);
      });
    } else if (widget.action == "discover") {
      setState(() {
        widget.model.setLoader(true);
      });
      await widget.model.insertPortfolioIdeas(
          portfolios: widget.arguments['portfolios'],
          portfolioName: _controller['portfolio_name'].text,
          rebalanceDate: widget.arguments['latestRebalanceDate']);
      Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');
      setState(() {
        widget.model.setLoader(false);
      });
    } else if (widget.action == "rename") {
      Map newPortfolioData = new Map.from(
          widget.model.userPortfoliosData[widget.portfolioMasterID]);
      setState(() {
        widget.model.setLoader(true);
      });
      Map<String, dynamic> responseData = await widget.model
          .updateCustomerPortfolioData(
              portfolios: newPortfolioData['portfolios'],
              zone: newPortfolioData['portfolio_zone'],
              portfolioMasterID: widget.portfolioMasterID,
              portfolioName: _controller['portfolio_name'].text);

      if (responseData['status'] == true) {
        Navigator.pushReplacementNamed(
            context, '/manage_portfolio_master_view');
      }

      setState(() {
        widget.model.setLoader(false);
      });
    } else {
      setState(() {
        widget.model.userPortfoliosData.remove('0');

        widget.model.userPortfoliosData['0'] = {
          'portfolio_name': _controller['portfolio_name'].text,
          'portfolios': {}
        };
        //widget.model.userPortfoliosData.addEntries('new': ['portfolio_name': _controller['portfolio_name'].Text]);
        widget.pageType = "add_instrument_new_portfolio";
        page = "add_instrument_new_portfolio";
      });
    }
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

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      // if (widget.model.isLoading || _benchmarkPerformance == null) {
      //   return preLoader();
      // } else {
      return PageWrapper(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          appBar: _buildAppBar(),
          body: _bodyContainer(),
        ),
      );
      // }
    });
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
      child: NavigationTobBar(
        widget.model,
        openDrawer: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  Widget _bodyContainer() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            deviceType == DeviceScreenType.tablet
                ? SizedBox()
                : NavigationLeftBar(
                    isSideMenuHeadingSelected: 1,
                    isSideMenuSelected: 2,
                  ),
            widget.model.isLoading
                ? Expanded(child: preLoader())
                : _webBuildBody(),
          ],
        )),
      ],
    );
  }

  Widget _webBuildBody() => Expanded(
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  left: getScaledValue(16),
                  right: getScaledValue(16),
                  top: getScaledValue(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/manage_portfolio_master_view');
                      //  Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_left,
                          color: colorBlue,
                        ),
                        Text(
                          "Back to Portfolios",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'nunito',
                            letterSpacing: 0.4,
                            color: colorBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getScaledValue(9)),
                  Text(
                    widget.action == "split"
                        ? "Duplicate Portfolio"
                        : widget.action == "merge"
                            ? "Merge Portfolio"
                            : widget.action == "rename"
                                ? "Rename Portfolio"
                                : "Add New Portfolio",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(25),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'nunito',
                      letterSpacing: 0.26,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            _portfolioNameContainer(),
            Visibility(
                visible: asserts_set_visible, child: _addAssetContainer()),
            Visibility(
                visible: asserts_added_visible, child: _assetAddedContainer()),
            Visibility(
              visible: create_button_visible,
              child: Container(
                margin: EdgeInsets.only(
                    left: getScaledValue(16),
                    right: getScaledValue(16),
                    top: getScaledValue(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getScaledValue(9)),
                    Wrap(
                      children: [
                        _webCreatePortfolioButton(
                            textValue: "CREATE PORTFOLIO",
                            buttonDisabled: depositPortfolio
                                ? false
                                : portfolioCount(checkWeight: true) == 0
                                    ? true
                                    : false,
                            onPressFunction: portfolioCount(
                                        checkWeight: true) ==
                                    0
                                ? null
                                : () async {
                                    setState(() {
                                      widget.model.setLoader(true);
                                    });
                                    Map<String, dynamic> responseData =
                                        await widget.model
                                            .updateCustomerPortfolioData(
                                      portfolios:
                                          widget.model.userPortfoliosData['0']
                                              ['portfolios'],
                                      portfolioMasterID: '0',
                                      portfolioName:
                                          _controller['portfolio_name']
                                              .text
                                              .trim(),
                                      depositPortfolio: depositPortfolio,
                                    );

                                    if (responseData['status'] == true) {
                                      _analyticsCreatePortfolioEvent(
                                          _controller['portfolio_name']
                                              .text
                                              .trim());
                                      Navigator.pushReplacementNamed(
                                          context, '/success_page',
                                          arguments: {
                                            'type': 'newPortfolio',
                                            'portfolio_name':
                                                _controller['portfolio_name']
                                                    .text
                                                    .trim(),
                                            'portfolioMasterID': responseData[
                                                'portfolioMasterID'],
                                            'action': 'newPortfolio'
                                          });
                                    }

                                    setState(() {
                                      widget.model.setLoader(false);
                                    });
                                  }),
                        SizedBox(
                          width: getScaledValue(20),
                          height: getScaledValue(20),
                        ),
                        portfolioCount() > 0
                            ? (portfolioCount(checkWeight: true) == 0
                                ? Text(
                                    "Holdings cannot have 0 units",
                                    style: inputError2,
                                    textAlign: TextAlign.center,
                                  )
                                : emptyWidget)
                            : emptyWidget,
                      ],
                    ),
                    SizedBox(height: getScaledValue(9)),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: next_button_visible,
              child: Container(
                margin: EdgeInsets.only(
                    left: getScaledValue(16),
                    right: getScaledValue(16),
                    top: getScaledValue(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getScaledValue(9)),
                    Wrap(
                      children: [
                        _webCreatePortfolioButton(
                            textValue: "NEXT",
                            buttonDisabled:
                                _controller['portfolio_name'].text != ""
                                    ? false
                                    : true,
                            onPressFunction: () {
                              if (widget.model
                                          .addPortfolioData['portfolio_name'] !=
                                      null &&
                                  widget.model
                                          .addPortfolioData['portfolio_name'] !=
                                      "") {
                                _analyticsNextButtonEvent();
                                addPortfolioAction();
                              }

                              // _controller['portfolio_name'].text != ""
                              //     ? setState(() {
                              //         // next_button_visible = false;
                              //         // asserts_set_visible = true;
                              //         // asserts_added_visible = true;
                              //         // create_button_visible = true;

                              //          addPortfolioAction();
                              //       })
                              //     : "";
                            })
                      ],
                    ),
                    SizedBox(height: getScaledValue(9)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _portfolioNameContainer() => widgetCard(
          // boxShadow: false,
          child: Container(
        padding: EdgeInsets.all(getScaledValue(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name Your Portfolio",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(16),
                fontWeight: FontWeight.w800,
                fontFamily: 'nunito',
                letterSpacing: 0.26,
                color: Colors.black,
              ),
            ),
            SizedBox(height: getScaledValue(9)),
            Text("Keep the name as something personal, or your goal....",
                style: bodyText1),
            SizedBox(height: getScaledValue(8)),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 35,
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 8, bottom: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Color(0xffeeeeee), width: 1.25),
                  ),
                  child: Form(
                    key: _addPortfolioForm,
                    child: TextField(
                      focusNode: focusNodes['portfolio_name'],
                      controller: _controller['portfolio_name'],
                      keyboardType: TextInputType.text,
                      onChanged: (String value) {
                        setState(() {
                          widget.model.addPortfolioData['portfolio_name'] =
                              value;
                        });
                      },
                      // onSubmitted: (value) {
                      //   addPortfolioAction();
                      // },
                      style: inputFieldStyle,
                      decoration: new InputDecoration(
                        hintText: "Portfolio name",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(14),
                          color: Color(0xff9f9f9f),
                          letterSpacing: 1.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getScaledValue(8)),
                Text(
                  portfolioNameErrorMsg,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(13.0),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'nunito',
                    letterSpacing: 0.24,
                    color: colorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ));

  Widget _addAssetContainer() => widgetCard(
          // boxShadow: false,
          child: Container(
        padding: EdgeInsets.all(getScaledValue(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Assets to Your Portfolio",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(16),
                fontWeight: FontWeight.w800,
                fontFamily: 'nunito',
                letterSpacing: 0.26,
                color: Colors.black,
              ),
            ),
            SizedBox(height: getScaledValue(9)),
            Row(
              children: [
                depositPortfolio ? emptyWidget : _stockAddOptions(),
                !depositPortfolio && !stockPortfolio
                    ? _addDeposit()
                    : stockPortfolio
                        ? emptyWidget
                        : _addDeposit(),
              ],
            ),
          ],
        ),
      ));

  Widget _stockAddOptions() => Expanded(
        child: Row(
          children: [
            _searchAndSort(),
            SizedBox(width: getScaledValue(20)),
            stockPortfolio ? emptyWidget : _or(),
            SizedBox(width: getScaledValue(20)),
          ],
        ),
      );

  Widget _or() => Column(
        children: [
          Container(
            height: getScaledValue(30),
            width: .5,
            color: Color(0xff9c9c9c),
          ),
          Container(
            width: getScaledValue(24),
            height: getScaledValue(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              // border: Border.all(color: colorBlue,width: 1.25),
              color: Color(0xffeeeeee),
            ),
            child: Center(
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(12.0),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'nunito',
                  letterSpacing: 0,
                  color: Color(0xff818181),
                ),
              ),
            ),
          ),
          Container(
            height: getScaledValue(30),
            width: .5,
            color: Color(0xff9c9c9c),
          ),
        ],
      );

  Widget _searchAndSort() => Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              portfolioCount() > 0
                  ? "Add stocks, bonds, mutual funds, Etf, gold"
                  : "Add stocks, bonds, mutual funds, ETFs or commodities for the countries you have access to",
              style: bodyText4),
          SizedBox(height: getScaledValue(9)),
          Wrap(
            runSpacing: getScaledValue(9),
            spacing: getScaledValue(9),
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: searchPopupWeb,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.135,
                  height: 31,
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: colorBlue, width: 1.25),
                    color: Color(0xffe2edff),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: ScreenUtil().setSp(13),
                        color: colorBlue,
                      ),
                      SizedBox(width: getScaledValue(3)),
                      Text("Search", style: textLink1),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: getScaledValue(9),
                height: getScaledValue(9),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: filterPopupWeb,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.135,
                  height: 31,
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Color(0xffeeeeee), width: 1.25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/icon/sort_filter_icon.png",
                          width: getScaledValue(13)),
                      SizedBox(width: getScaledValue(3)),
                      Text(
                        "Sort & Filter",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12.0),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'nunito',
                          letterSpacing: 0,
                          color: Color(0xff979797),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ));

  Widget _addDeposit() => Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              // portfolioCount() > 0
              //     ? "You Can deposit lorem ipsum dolor sit amet"
              //     :
              "Add fixed deposits that you have in your bank, post office or other financial institutions",
              style: bodyText4),
          SizedBox(height: getScaledValue(9)),
          Wrap(
            runSpacing: getScaledValue(9),
            spacing: getScaledValue(9),
            children: [
              TextButton(
                onPressed: () {
                  _depositePopUp(context);
                },
                child: ResponsiveBuilder(
                  builder: (context, sizingInformation) {
                    if (sizingInformation.deviceScreenType ==
                        DeviceScreenType.desktop) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.135,
                        height: 31,
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 8, bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border:
                              Border.all(color: Color(0xffeeeeee), width: 1.25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: ScreenUtil().setSp(16),
                              color: Color(0xff9c9c9c),
                            ),
                            SizedBox(width: getScaledValue(3)),
                            Text("Add Deposit",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(12.0),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0,
                                  color: Color(0xff979797),
                                )),
                          ],
                        ),
                      );
                    }
                    if (sizingInformation.deviceScreenType ==
                        DeviceScreenType.tablet) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.145,
                        height: 31,
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 8, bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border:
                              Border.all(color: Color(0xffeeeeee), width: 1.25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: ScreenUtil().setSp(16),
                              color: Color(0xff9c9c9c),
                            ),
                            SizedBox(width: getScaledValue(3)),
                            Text("Add Deposit",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(12.0),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0,
                                  color: Color(0xff979797),
                                )),
                          ],
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ],
      ));

//.....Deposite Popup starts.........................................

  void _depositePopUp(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(getScaledValue(14)),
            ),
            scrollable: true,
            content: depositFormWidget(
              portfolioMasterId: widget.portfolioDepositID,
            ),
          );
        });
      },
    );
  }

  void onTapFormClose() {
    setState(() {
      _selectedTypeAcc = null;
      _selectedCurrency = null;
      _controller['display_name'].text = "";
      _controller['bank_name'].text = "";
      _controller['amount'].text = "";
      _controller['interest'].text = "";
      _controller['start_date'].text = "";
      _controller['end_date'].text = "";
      _selectedFrequency = null;
      _selectedDeposit = null;

      bank_id = "";
      auto_renew = "";
    });
    Navigator.pop(context);
  }

  Widget depositFormWidget({String portfolioMasterId = null}) {
    return Form(
      key: _addDepositForm,
      child: SizedBox(
        width: 724,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.portfolioDepositID != null
                    ? "Edit Deposit"
                    : "Add new Deposit",
                style: headline1,
              ),
              Divider(),
              SizedBox(height: 10),
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _depositForm_type_of_deposit_acc(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _depositForm_bankNameTextfield(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _depositForm_display_name(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _depositForm_deposit_type(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Other Details",
                style: headline5_analyse,
              ),
              SizedBox(height: 16),
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _depositForm_deposit_amount(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _depositForm_frequency_deposit(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _depositForm_currency_of_deposit(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _depositForm_start_date(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _depositForm_interest_rate(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _depositForm_end_date(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _depositForm_autorenew_checkbox(),
              SizedBox(height: 24),
              _depositeFormButtons(portfolioMasterId: portfolioMasterId),
            ],
          ),
        ),
      ),
    );
  }

  addDepositValue() async {
    final form = _addDepositForm.currentState;
    String portfolioMasterID = widget.portfolioMasterID ?? '0';

    if (form.validate()) {
      form.save();

      Map deposite_data = {
        "type": accTypeDepositMap[_selectedTypeAcc]['value'],
        "display_name": _controller['display_name'].text,
        "currency": _selectedCurrency,
        "amount": _controller['amount'].text,
        "rate": _controller['interest'].text,
        "frequency": frequencyMap[_selectedFrequency]['value'],
        "payout": depositTypeMap[_selectedDeposit]['value'],
        "start_date": _controller['start_date'].text,
        "maturity_date": _controller['end_date'].text,
        "bank_id": bank_id,
        "auto_renew": auto_renew
      };

      Map deposite_json_value = {
        "currency": _selectedCurrency.toUpperCase(),
        "zone": "gl",
        "ric": widget.portfolioDepositID != null
            ? ricUpdateValue
            : accTypeDepositMap[_selectedTypeAcc]['ric'],
        "weightage": "1.00",
        "type": "Deposit",
        "depositData": deposite_data
      };

      //ricUpdateValue
      deposit_arrays.add(deposite_json_value);
      display_arrays.add(_controller['display_name'].text);
      depositPortfolioList['Deposit'] = deposit_arrays;

      Map PortfolioData = {};
      PortfolioData =
          new Map.from(widget.model.userPortfoliosData[portfolioMasterID]);

      if (widget.portfolioDepositID != null) {
        // remove the deposit item if exists
        widget
            .model
            .userPortfoliosData[widget.portfolioMasterID]['portfolios']
                ['Deposit']
            ?.removeWhere((item) => item["ric"] == ricUpdateValue);
      }

      // widget
      //     .model.userPortfoliosData[portfolioMasterID]['portfolios']['Deposit']
      //     .add(deposite_json_value);
      widget.model.userPortfoliosData[portfolioMasterID]['portfolios'] =
          depositPortfolioList;

      if (widget.portfolioMasterID != null) {
        setState(() {
          depositPortfolio = true;
          widget.model.setLoader(true);
        });
        Map<String, dynamic> responseData =
            await widget.model.updateCustomerPortfolioData(
          portfolios: widget.model.userPortfoliosData[widget.portfolioMasterID]
              ['portfolios'],
          portfolioMasterID:
              widget.portfolioMasterID != null ? widget.portfolioMasterID : '0',
          portfolioName: widget.portfolioMasterID != null
              ? PortfolioData['portfolio_name']
              : widget.model.userPortfoliosData['0']['portfolio_name'],
          depositPortfolio: depositPortfolio ? true : false,
        );

        if (responseData['status'] == true) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }

        setState(() {
          widget.model.setLoader(false);
        });
      } else {
        setState(() {
          depositPortfolio = true;
          page = 'add_instrument_new_portfolio';
          widget.pageType = "add_instrument_new_portfolio";

          _selectedTypeAcc = null;
          _selectedCurrency = null;
          _controller['display_name'].text = "";
          _controller['bank_name'].text = "";
          _controller['amount'].text = "";
          _controller['interest'].text = "";
          _controller['start_date'].text = "";
          _controller['end_date'].text = "";
          _selectedFrequency = null;
          _selectedDeposit = null;

          bank_id = "";
          auto_renew = "";

          Navigator.of(context).pop();
        });
      }
    }
  }

  Widget _depositForm_type_of_deposit_acc() {
    return SizedBox(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Type of Deposit',
          labelStyle: inputLabelStyleDep,
        ),
        //focusNode: focusNodes['type_of_deposit_acc'],
        icon: Icon(Icons.keyboard_arrow_down),
        iconSize: 20,
        isExpanded: true,
        items: type_of_acc_Map.map((Map item) {
          return new DropdownMenuItem<String>(
              value: item['type_acc'], //country['code'],//
              child: Text(item['type_acc'],
                  style: TextStyle(color: Colors.black)));
        }).toList(),
        value: _selectedTypeAcc,
        style: inputFieldStyleDep,
        validator: (value) => value == null ? 'Select type of deposit' : null,
        onChanged: (widget.portfolioDepositID != null)
            ? null
            : (value) {
                _selectedTypeAcc = value;
              },
      ),
    );
  }

  Widget _depositForm_display_name() {
    return TextFormField(
      focusNode: focusNodes['display_name'],
      controller: _controller['display_name'],
      validator: (value) {
        if (value.isEmpty) {
          return "Enter the display name";
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Display Name',
          labelStyle: focusNodes['display_name'].hasFocus
              ? inputLabelFocusStyleDep
              : inputLabelStyleDep),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (String value) {},
      onFieldSubmitted: (term) {
        _setState(() {
          _fieldFocusChange(
              context, focusNodes['display_name'], focusNodes['bank_name']);
        });
      },
      style: inputFieldStyleDep,
    );
  }

  Widget _depositForm_deposit_type() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Deposit Type", style: inputLabelStyleDep),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message:
                    "Deposit Type\nA cumulative deposit pays out the entire interest at maturity while a non-cumulative deposit pays out the interest on a monthly, quarterly, half-yearly or a yearly basis. Over interest earned is higher in a cumulative deposit",
                child: InkWell(
                  onTap: () => showPopUp(
                    title: 'Deposit Type',
                    description:
                        "A cumulative deposit pays out the entire interest at maturity while a non-cumulative deposit pays out the interest on a monthly, quarterly, half-yearly or a yearly basis. Over interest earned is higher in a cumulative deposit",
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: svgImage(
                      "assets/icon/information.svg",
                      color: AppColor.colorBlue,
                      height: 16,
                      width: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            //focusNode: focusNodes['deposit_type'],
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 20,
            isExpanded: true,
            items: deposit_type_Map.map((Map deposit_type_Map) {
              return new DropdownMenuItem<String>(
                value: deposit_type_Map['deposit_type'], //country['code'],
                child: Text(deposit_type_Map['deposit_type'],
                    style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            value: _selectedDeposit,
            style: inputFieldStyleDep,
            validator: (value) => value == null ? 'Select deposit type' : null,
            onChanged: (value) {
              _selectedDeposit = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _depositForm_bankNameTextfield() {
    return Container(
      child: InkWell(
        onTap: () {
          _fieldFocusChange(
              context, focusNodes['display_name'], focusNodes['bank']);
          _depositForm_showDialogBankName();
        },
        child: IgnorePointer(
          child: TextFormField(
              focusNode: focusNodes['bank_name'],
              controller: _controller['bank_name'],
              validator: (value) {
                if (value.isEmpty) {
                  return "Select the bank name";
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: 'Bank Name',
                  labelStyle: focusNodes['bank_name'].hasFocus
                      ? inputLabelFocusStyleDep
                      : inputLabelStyleDep),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: (String value) {
                _setState(() {
                  // _userData['bank_name'] = value;
                });
              },
              onFieldSubmitted: (term) {},
              style: inputFieldStyleDep),
        ),
      ),
    );
  }

  _depositForm_showDialogBankName() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SizedBox(
                width: 500,
                child: SearchBankName(widget.model, isLarge: true),
              ),
            );
          });
        }).then((value) => {
          _setState(() {
            for (int i = 0; i < bank_items.length; i++) {
              var bank_v = bank_items[i]['bank_id'];
              if (bank_v == value) {
                _controller['bank_name'].text = bank_items[i]["bank_name"];
                bank_id = value;
                break;
              }
            }
            _fieldFocusChange(
                context, focusNodes['bank_name'], focusNodes['deposit_type']);
          })
        });
  }

  Widget _depositForm_deposit_amount() {
    return TextFormField(
      focusNode: focusNodes['amount'],
      controller: _controller['amount'],
      validator: (value) {
        if (value.isEmpty || value == 0) {
          return "Enter valid amount";
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Amount of Deposit',
          labelStyle: focusNodes['amount'].hasFocus
              ? inputLabelFocusStyleDep
              : inputLabelStyleDep),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (term) {
        _fieldFocusChange(
            context, focusNodes['amount'], focusNodes['currency']);
      },
      onChanged: (String value) {},
      style: inputFieldStyleDep,
    );
  }

  Widget _depositForm_currency_of_deposit() {
    return SizedBox(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Currency of deposit',
          labelStyle: inputLabelStyleDep,
        ),
        icon: Icon(Icons.keyboard_arrow_down),
        iconSize: 20,
        isExpanded: true,
        items: widget.model.currencies.map((Map item) {
          return new DropdownMenuItem<String>(
            value: item['key'],
            child: Text(item['value']),
          );
        }).toList(),
        value: _selectedCurrency,
        style: inputFieldStyleDep,
        validator: (value) =>
            value == null ? 'Select currency of deposit' : null,
        onChanged: (value) {
          _selectedCurrency = value;
        },
      ),
    );
  }

  Widget _depositForm_interest_rate() {
    return TextFormField(
      focusNode: focusNodes['interest'],
      controller: _controller['interest'],
      validator: (value) {
        if (value.isEmpty ||
            double.parse(value) < 0.0 ||
            double.parse(value) > 100.0) {
          return "Enter valid interest";
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Annual rate of interest',
          suffix: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("%"),
          ),
          labelStyle: focusNodes['interest'].hasFocus
              ? inputLabelFocusStyleDep
              : inputLabelStyleDep),
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      textInputAction: TextInputAction.next,
      onChanged: (String value) {},
      style: inputFieldStyleDep,
    );
  }

  Widget _depositForm_frequency_deposit() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text("Interest compounding frequency", style: inputLabelStyleDep),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message:
                    "Interest compounding frequency\nCompounding frequency is the time period when interest will be calculated on top of the original loan amount. It is usually expressed as the number of periods in a year. Higher the frequency, more is the interest accrued",
                child: InkWell(
                    onTap: () => showPopUp(
                          title: 'Interest compounding frequency',
                          description:
                              "Compounding frequency is the time period when interest will be calculated on top of the original loan amount. It is usually expressed as the number of periods in a year. Higher the frequency, more is the interest accrued",
                        ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: svgImage(
                        "assets/icon/information.svg",
                        color: AppColor.colorBlue,
                        height: 16,
                        width: 12,
                      ),
                    )),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 20,
            isExpanded: true,
            items: frequency_Map.map((Map frequency_Map) {
              return new DropdownMenuItem<String>(
                value: frequency_Map['frequency'], //country['code'],
                child: Text(frequency_Map['frequency'],
                    style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            value: _selectedFrequency,
            style: inputFieldStyleDep,
            validator: (value) =>
                value == null ? 'Select interest compounding frequency' : null,
            onChanged: (value) {
              _selectedFrequency = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _depositForm_start_date() {
    return Container(
      child: InkWell(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: _depositStartDate ?? DateTime.now(),
            firstDate: DateTime(2001),
            lastDate: DateTime.now(),
          ).then((date) {
            if (date == null) return;
            setState(() {
              _depositStartDate = date;
              final f = new DateFormat('yyyy-MM-dd');
              _controller['start_date'].text = f.format(date);
              _controller['end_date'].text = '';
            });
          });
        },
        child: IgnorePointer(
          child: TextFormField(
              focusNode: focusNodes['start_date'],
              controller: _controller['start_date'],
              validator: (value) {
                if (value.isEmpty) {
                  return "Select strat date";
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Start Date',
                hintText: "YYYY-MM-DD",
                labelStyle: focusNodes['start_date'].hasFocus
                    ? inputLabelFocusStyleDep
                    : inputLabelStyleDep,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
              ),
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {});
              },
              style: inputFieldStyleDep),
        ),
      ),
    );
  }

  Widget _depositForm_end_date() {
    return Container(
      child: InkWell(
        onTap: () {
          // log.d(_controller['start_date'].text);
          if (_controller['start_date'].text == '') {
            return;
          }
          // log.d(_depositStartDate);
          // log.d(_depositEndDate);
          showDatePicker(
                  context: context,
                  initialDate: _depositEndDate != null
                      ? _depositEndDate
                      : _depositStartDate.add(Duration(days: 365)),
                  firstDate: _depositStartDate ?? DateTime.now(),
                  lastDate: DateTime(2050))
              .then((date) {
            if (date == null) return;
            setState(() {
              final f = new DateFormat('yyyy-MM-dd');
              _controller['end_date'].text = f.format(date);
              _depositEndDate = date;
            });
          });
        },
        child: IgnorePointer(
          child: TextFormField(
              focusNode: focusNodes['end_date'],
              controller: _controller['end_date'],
              validator: (value) {
                if (value.isEmpty) {
                  return "Select end date";
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'End Date',
                hintText: "YYYY-MM-DD",
                labelStyle: focusNodes['end_date'].hasFocus
                    ? inputLabelFocusStyleDep
                    : inputLabelStyleDep,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
              ),
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {});
              },
              style: inputFieldStyleDep),
        ),
      ),
    );
  }

  Widget _depositForm_autorenew_checkbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          activeColor: Color(0xffcedfff),
          checkColor: Color(0xff034bd9),
          value: this.value_auto_renew,
          onChanged: (bool value) {
            setState(() {
              this.value_auto_renew = value;
              if (value == false) {
                auto_renew = "0";
              } else {
                auto_renew = "1";
              }
            });
          },
        ),
        SizedBox(width: 8),
        Text(
          "Auto-renew",
          style: bodyText0_dashboard,
        ),
        Tooltip(
          padding: EdgeInsets.all(10),
          textStyle: TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.normal),
          message:
              "Auto-renew\nThis deposit will be auto-renewed in your portfolio for the same tenor and interest rate on maturity, if this option is selected",
          child: InkWell(
            onTap: () => showPopUp(
              title: 'Auto-renew',
              description:
                  "This deposit will be auto-renewed in your portfolio for the same tenor and interest rate on maturity, if this option is selected",
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: svgImage(
                "assets/icon/information.svg",
                color: AppColor.colorBlue,
                height: 16,
                width: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _depositeFormButtons({String portfolioMasterId = null}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          popUpButton(
            'CANCEL',
            borderColor: colorBlue,
            textColor: colorBlue,
            onPressFunction: onTapFormClose,
          ),
          SizedBox(width: 10),
          popUpButton(
            portfolioMasterId != null ? "SAVE" : "ADD",
            bgColor: Color(0xff0941cc),
            borderColor: Color(0xff0941cc),
            textColor: Colors.white,
            onPressFunction: () => addDepositValue(),
          ),
        ],
      ),
    );
  }

  Widget popUpButton(title,
      {Function onPressFunction,
      Color bgColor: Colors.white,
      Color borderColor = Colors.white,
      Color textColor = Colors.black,
      double fontSize = 10,
      FontWeight fontWeight = FontWeight.w800,
      Alignment alignment = Alignment.center}) {
    return TextButton(
      onPressed: onPressFunction,
      child: Container(
        alignment: alignment,
        padding: EdgeInsets.all(0),
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(width: 1.0, color: borderColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: 'nunito',
            letterSpacing: 0,
            color: textColor,
          ),
        ),
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void showPopUp({String title, String description}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: appBodyH3,
                    ),
                    _buildCloseButton(),
                  ],
                ),
                Divider(
                  height: 5,
                  color: Colors.grey,
                ),
                Text(
                  description,
                  style: bodyText4,
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          scrollable: true,
        );
      },
    );
  }

  GestureDetector _buildCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Icon(
        Icons.close,
        color: Color(0xffcccccc),
        size: 18.0,
      ),
    );
  }

//.....Deposite Popup ends.........................................

  Widget _assetAddedContainer() => widgetCard(
          // boxShadow: false,
          child: Container(
        height: getScaledValue(383),
        // padding: EdgeInsets.all(getScaledValue(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Assets Added",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'nunito',
                    letterSpacing: 0.26,
                    color: Colors.black,
                  ),
                ),
                _unitOptions(),
              ],
            ),
            SizedBox(height: getScaledValue(9)),
            Container(
              height: 1,
              color: Color(0xffe9e9e9),
            ),
            portfolioCount() > 0
                ? Expanded(
                    child: ListView(
                    shrinkWrap: true,
                    controller: controller,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: _portfolioList(),
                  ))
                : Expanded(
                    child: Container(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: getScaledValue(20)),
                            Image.asset("assets/icon/symbol_units.png",
                                width: getScaledValue(100)),
                            Text(
                              "Your added \n stocks, funds & bonds will appear here",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(25),
                                fontWeight: FontWeight.w800,
                                fontFamily: 'nunito',
                                letterSpacing: 0.26,
                                color: Color(0xfff5f6fa),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ));

  Widget _webCreatePortfolioButton({
    Function onPressFunction,
    bool buttonDisabled = false,
    String textValue,
  }) {
    return Container(
      width: 312,
      child: ElevatedButton(
        style: qfButtonStyle(ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: buttonDisabled || onPressFunction == null
                  ? [Colors.grey, Colors.grey[400]]
                  : [Color(0xff0941cc), Color(0xff0055fe)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: ScreenUtil().setHeight(40),
            ),
            alignment: Alignment.center,
            child: Text(
              textValue,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(3.0) < 9.0
                    ? 9.0
                    : ScreenUtil().setSp(3.0),
                fontWeight: FontWeight.w600,
                fontFamily: 'nunito',
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        onPressed: onPressFunction,
      ),
    );
  }

  filterPopupWeb() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              width: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort & Filter',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'nunito',
                      letterSpacing: 0.26,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                      "Shortlist assets using one or more criteria. Add those that fit your yardsticks.",
                      style: bodyText4),
                  SizedBox(height: getScaledValue(9)),
                  // Container(
                  //   color: Color(0xffeeeeee),
                  //   height: 1.5,
                  // )
                  divider(),
                  Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: filterOptions.entries
                                .map((entry) => filterOptionWidget(entry))
                                .toList(),
                          ),
                          Expanded(child: filterOptionContainer()),
                        ],
                      )),
                  ResponsiveBuilder(
                    builder: (context, sizingInformation) {
                      if (sizingInformation.deviceScreenType ==
                          DeviceScreenType.desktop) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: getScaledValue(13),
                              vertical: getScaledValue(13)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              resetButton(
                                'Cancel',
                                borderColor: colorBlue,
                                textColor: colorBlue,
                                onPressFunction: () {
                                  resetFilter();
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 10),
                              resetButton('Reset',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: () => resetFilter()),
                              SizedBox(width: getScaledValue(10)),
                              Expanded(
                                  child: Container(
                                      width: 166,
                                      child: gradientButton(
                                          context: context,
                                          caption: 'Apply',
                                          onPressFunction: () => applyFilter(),
                                          miniButton: true))),
                            ],
                          ),
                        );
                      }
                      if (sizingInformation.deviceScreenType ==
                          DeviceScreenType.tablet) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: getScaledValue(8),
                              vertical: getScaledValue(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              resetButton(
                                'Cancel',
                                borderColor: colorBlue,
                                textColor: colorBlue,
                                onPressFunction: () {
                                  resetFilter();
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 5),
                              // SizedBox(width: 10),
                              resetButton('Reset',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: () => resetFilter()),
                              SizedBox(width: 5),
                              // SizedBox(width: getScaledValue(10)),
                              Container(
                                  width: 166,
                                  child: gradientButton(
                                      context: context,
                                      caption: 'Apply',
                                      onPressFunction: () => applyFilter(),
                                      miniButton: true)),
                            ],
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  searchPopupWeb() {
    setState(() {
      selectedRICs = null;
      _popupSearchFieldController.clear();
      searchList = [];
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Container(
                width: 700,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _smartSearchContainer(),
                    _searchBody(),
                  ],
                ),
              ));
        });
      },
    );
  }

  _searchBody() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Search an Asset',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(16),
                  fontWeight: FontWeight.w800,
                  fontFamily: 'nunito',
                  letterSpacing: 0.26,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(child: _searchBox()),
            divider(),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: getScaledValue(13), vertical: getScaledValue(13)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  resetButton('Cancel',
                      borderColor: colorBlue,
                      textColor: colorBlue,
                      onPressFunction: () => Navigator.of(context).pop()),
                  SizedBox(width: getScaledValue(10)),
                  Container(
                      width: 166,
                      child: gradientButton(
                          context: context,
                          caption: 'ADD',
                          onPressFunction: () =>
                              addInstrumentAction(selectedRICs),
                          miniButton: true,
                          buttonDisabled: selectedRICs == null ? true : false)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchBox() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _popupsearchfield(),
            _popupsearchList(),
          ],
        ),
      );

  Widget _popupsearchfield() => Container(
        // width: MediaQuery.of(context).size.width * 0.35,
        height: 40,
        padding: const EdgeInsets.only(right: 10.0, top: 8, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Color(0xffeeeeee), width: 1.25),
        ),
        child: Form(
          // key:  widget.addPortfolioForm,
          child: TextField(
            autofocus: true,
            controller: _popupSearchFieldController,
            keyboardType: TextInputType.text,
            onChanged: (String value) {
              _setState(() {
                selectedRICs = null;
              });
              if (value.length >= 3) {
                _getALlPosts(value);
              } else {
                _setState(() {
                  searchList = [];
                });
              }
            },
            onSubmitted: (value) async {
              await _analyticsSearchAssetEvent(value);
              if (value.length >= 3) {
                _getALlPosts(value);
              } else {
                _setState(() {
                  searchList = [];
                });
              }
            },
            style: inputFieldStyle,
            decoration: new InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: ScreenUtil().setSp(14),
                  color: Color(0xff9f9f9f),
                  letterSpacing: 1.0,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: colorActive,
                )),
          ),
        ),
      );

  Widget _popupsearchList() => Expanded(
        child: searchList.length == 0
            ? Container(
                alignment: Alignment.center,
                child: Text('No record found',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(color: Color(0xff3c4257))))
            : ListView.builder(
                itemCount: searchList.length ?? 0,
                itemBuilder: (context, index) {
                  // return Container(color: Colors.red,height: 100,width: 100,);
                  Map element = {
                    'ric': searchList[index].ric,
                    'name': searchList[index].name,
                    'type': searchList[index].fundType,
                    'zone': searchList[index].zone,
                    'latestPriceBase': searchList[index].latestPriceBase,
                    'latestPriceString': searchList[index].latestPriceString,
                    'latestCurrencyPriceString':
                        searchList[index].latestCurrencyPriceString
                  };
                  return fundBoxForFiltration1(
                    context,
                    element,
                    onTap: () => selectInstrumentAction(searchList[index]),
                    isSelected: selectedRICs == null
                        ? false
                        : selectedRICs.ric == searchList[index].ric
                            ? true
                            : false,
                    isSearch: true,
                  );
                }),
      );

  // Widget _searchBox(){
  // 	return SearchBar<RICs>(
  // 		searchBarPadding: EdgeInsets.symmetric(horizontal: 5),
  // 		headerPadding: EdgeInsets.symmetric(horizontal: 5),
  // 		listPadding: EdgeInsets.symmetric(horizontal: 5),
  // 		minimumChars: 3,
  // 		onSearch: _getALlPosts,
  // 		//searchBarController: _searchBarController,
  // 		/* placeHolder: Text("placeholder"),
  // 		cancellationWidget: Text("Cancel"), */
  // 		emptyWidget: Container(
  // 			alignment: Alignment.center,
  // 			child: Text('No record found', style: Theme.of(context).textTheme.subtitle2.copyWith(color: Color(0xff3c4257)))
  // 		),
  // 		// onCancelled: () {
  // 		// 	log.d("Cancelled triggered");
  // 		// },
  // 		shrinkWrap: true,
  // 		mainAxisSpacing: 5,
  // 		//crossAxisSpacing: 5,
  // 		crossAxisCount: 1,
  // 		onItemFound: (RICs ric, int index) {
  // 			Map element = {'ric': ric.ric, 'name': ric.name, 'type': ric.fundType, 'zone': ric.zone, 'latestPriceBase': ric.latestPriceBase, 'latestPriceString': ric.latestPriceString, 'latestCurrencyPriceString': ric.latestCurrencyPriceString};
  // 			return fundBoxForFiltration1(
  //         context,
  //         element,
  //         onTap: () => selectInstrumentAction(ric),
  //         isSelected: selectedRICs == null ? false : selectedRICs.ric == ric.ric ? true : false,
  //         isSearch: true,
  //       );
  // 		},
  // 	);
  // }

  _getALlPosts(String search) async {
    List funds = await widget.model.getFundName(search, 'all');
    //await Future.delayed(Duration(seconds: 2));
    List<RICs> _searchList = List.generate(funds.length, (int index) {
      return RICs(
          ric: funds[index]['ric'],
          name: funds[index]['name'],
          zone: funds[index]['zone'],
          fundType: funds[index]['type'],
          latestPriceBase: funds[index]['latestPriceBase'],
          latestPriceString: funds[index]['latestPrice'],
          latestCurrencyPriceString: funds[index]['latestCurrencyPrice']);
    });

    _setState(() {
      searchList = _searchList;
    });
    log.d("--------------------------------------");
    log.d("search list length ==> ${searchList.length}");
  }

  Widget resetButton(title,
      {Function onPressFunction,
      Color bgColor: Colors.white,
      Color borderColor = Colors.white,
      Color textColor = Colors.black,
      double fontSize = 10,
      FontWeight fontWeight = FontWeight.w800,
      Alignment alignment = Alignment.center}) {
    return TextButton(
      onPressed: onPressFunction,
      child: Container(
        alignment: alignment,
        padding: EdgeInsets.all(0),
        width: 166,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(width: 1.0, color: borderColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(fontSize),
            fontWeight: fontWeight,
            fontFamily: 'nunito',
            letterSpacing: 0,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget filterOptionWidget(var filterOption) {
    if ((['share_class', 'aum_size'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                !['funds'].contains(filterOptionSelection['type'])) ||
        ['overall_score'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                !['funds', 'etf'].contains(filterOptionSelection['type'])) ||
        ['industry'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                ['funds', 'etf', 'bonds']
                    .contains(filterOptionSelection['type'])) ||
        ['overall_rating'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                ['stocks', 'bonds', 'commodity']
                    .contains(filterOptionSelection['type'])) ||
        ['share_class'].contains(filterOption.key) &&
            (filterOptionSelection.containsKey('zone') &&
                (filterOptionSelection['zone'].length > 1 ||
                    filterOptionSelection['zone'].length == 1 &&
                        !filterOptionSelection['zone'].contains('in'))))) {
      return emptyWidget;
    }
    return GestureDetector(
      onTap: () {
        _setState(() {
          activeFilterOption = filterOption.key;
        });
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: getScaledValue(16)) +
              EdgeInsets.only(
                  left: getScaledValue(16), right: getScaledValue(10)),
          width: getScaledValue(140),
          decoration: BoxDecoration(
              color: activeFilterOption == filterOption.key
                  ? Color(0xffecf4ff)
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                    width: getScaledValue(1), color: Color(0xffeeeeee)),
                right: BorderSide(
                    width: getScaledValue(1), color: Color(0xffeeeeee)),
              )),
          child: Row(
            children: [
              (filterOptionSelection.containsKey(filterOption.key) &&
                          filterOptionSelection[filterOption.key] != null &&
                          filterOptionSelection[filterOption.key].length !=
                              0) ||
                      keyStatsSelected(filterOption.key)
                  ? svgImage('assets/icon/oval.svg')
                  : SizedBox(width: getScaledValue(4)),
              SizedBox(width: getScaledValue(5)),
              Expanded(
                  child: Text(filterOption.value['title'],
                      style: keyStatsBodyText7))
            ],
          )),
    );
  }

  Widget filterOptionContainer() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(getScaledValue(12)),
        child: ListView(
          shrinkWrap: true,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filterOptions[activeFilterOption]['type'] == "sort"
                ? Container(
                    padding: EdgeInsets.only(bottom: getScaledValue(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("SORT BY", style: keyStatsBodyText7),
                        SizedBox(height: getScaledValue(9)),
                        Row(
                          children: [
                            sortRow('Low to High', 'asc'),
                            SizedBox(width: getScaledValue(5)),
                            sortRow('High to Low', 'desc'),
                          ],
                        ),
                      ],
                    ))
                : emptyWidget,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...filterOptions[activeFilterOption]['optionGroups']
                  .map((optionGroup) => filterOptionGroup(optionGroup))
                  .toList()
            ])
          ],
        ));
  }

  Widget _smartSearchContainer() {
    return Container(
      width: 160,
      height: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Qfinr Smart Search\n", style: appBenchmarkPortfolioName),
          Text(
              "To search for any asset, you can either type the name in full (for ex: Reliance Industries), or use our Smart Search feature. Smart Search makes it faster and more efficient for you to access your favorite stocks, ETFs, or mutual funds\n",
              style: bodyText4),
          Text(
              "To use Smart Search, before you type the name that you are looking to search, just type in one of the letters shown below followed by a space:\n",
              style: bodyText4),
          Text("'s' - to search for stocks (ex: 's nippon')", style: bodyText4),
          Text("'e' - to search for ETFs (ex: 'e nippon')", style: bodyText4),
          Text("'f' - to search for Mutual Funds (ex: 'f nippon')",
              style: bodyText4),
        ],
      ),
    );
  }

  Widget sortRow(String caption, String orderby) {
    return GestureDetector(
      onTap: () {
        _analyticsSortByEvent(caption);
        _setState(() {
          filterOptionSelection['sort_order'] = orderby;
        });
      },
      child: boxContainer(caption,
          isActive:
              filterOptionSelection['sort_order'] == orderby ? true : false),
    );
  }

  Widget filterOptionGroup(var optionGroup) {
    if (optionGroup['key'] == 'scores' &&
        ['stocks', 'bonds', 'commodity']
            .contains(filterOptionSelection['type'])) {
      return emptyWidget;
    }
    log.d("object==========> ${optionGroup['group_title']}");
    return Container(
        padding: EdgeInsets.only(bottom: getScaledValue(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            optionGroup['group_title'] != ""
                ? Text(optionGroup['group_title'].toUpperCase(),
                    style: keyStatsBodyText7)
                : emptyWidget,
            optionGroup['group_title'] != ""
                ? SizedBox(height: getScaledValue(9))
                : emptyWidget,
            filterOptions[activeFilterOption]['optionType'] == "radio"
                ? radioBoxOption(optionGroup)
                : otherOptions(optionGroup)
          ],
        ));
  }

  radioBoxOption(var optionGroup) => Wrap(children: [
        ...optionGroup['options'].entries.map((entry) {
          if ((!['funds', 'etf', 'stocks']
                      .contains(filterOptionSelection['type']) &&
                  ['sharpe', 'Bench_alpha', 'successratio', 'inforatio']
                      .contains(entry.key)) ||
              (['stocks', 'bonds', 'commodity']
                      .contains(filterOptionSelection['type']) &&
                  ['tna'].contains(entry.key))) {
            return emptyWidget;
          }
          log.d(
              "--------------------------------> ${filterOptionSelection['sortby'].toString()}");
          return Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 5),
            child: Container(
              width: getScaledValue(125),
              child: GestureDetector(
                onTap: () => filterOptionValueUpdate(value: entry.key),
                child: boxContainer(entry.value,
                    isActive: filterOptionSelection['sortby'] == entry.key ||
                            filterOptionSelection['type'] == entry.key ||
                            filterOptionSelection['share_class'] == entry.key
                        ? true
                        : false),
              ),
            ),
          )
              // ListTileTheme(
              // 	contentPadding: EdgeInsets.all(0),
              // 	child: RadioListTile(
              //   	groupValue: widget.filterOptionSelection[activeFilterOption],
              //   	title: filterOptionTextRow(entry.value),
              //   	value: entry.key,
              //   	onChanged: (value) => filterOptionValueUpdate(value: entry.key),
              //   	activeColor: colorBlue,
              //   	dense: true,
              //   ),
              // )
              ;
        }).toList()
      ]);

  otherOptions(var optionGroup) {
    var start = 0.00;
    var end = 0.00;

    optionGroup['options'].entries.map((entry) {});
    return Column(
      children: [
        ...optionGroup['options'].entries.map((entry) {
          if ((!['funds', 'etf', 'stocks']
                      .contains(filterOptionSelection['type']) &&
                  ['sharpe', 'Bench_alpha', 'successratio', 'inforatio']
                      .contains(entry.key)) ||
              (['stocks', 'bonds', 'commodity']
                      .contains(filterOptionSelection['type']) &&
                  ['tna'].contains(entry.key))) {
            return emptyWidget;
          }

          if (activeFilterOption == "overall_rating" ||
              activeFilterOption == "key_stats") {
            start = double.parse(
                    filterOptionSelection.containsKey(optionGroup['key'])
                        ? filterOptionSelection[optionGroup['key']]['min']
                        : entry.value['min'])
                .toDouble();

            end = double.parse(
                    filterOptionSelection.containsKey(optionGroup['key'])
                        ? filterOptionSelection[optionGroup['key']]['max']
                        : entry.value['max'])
                .toDouble();

            _currentRangeValues = RangeValues(start.toDouble(), end.toDouble());
          }

          return Container(
              //padding: EdgeInsets.only(bottom: getScaledValue(18)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                filterOptions[activeFilterOption]['optionType'] == "checkbox"
                    ? ListTileTheme(
                        contentPadding: EdgeInsets.all(0),
                        child: CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: filterOptionTextRow(entry.value),
                          value: filterOptionSelection
                                      .containsKey(activeFilterOption) &&
                                  filterOptionSelection[activeFilterOption]
                                      .contains(entry.key)
                              ? true
                              : false, // check from
                          onChanged: (bool value) =>
                              filterOptionValueUpdate(value: entry.key),
                          activeColor: colorBlue,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.value['title'],
                              style: bodyText1.copyWith(color: colorDarkGrey)),

                          RangeSlider(
                            values: _currentRangeValues,
                            min: double.parse(entry.value['min']),
                            max: double.parse(entry.value['max']),
                            divisions:
                                double.parse(entry.value['max']).toInt() -
                                    double.parse(entry.value['min']).toInt(),
                            labels: RangeLabels(
                              _currentRangeValues.start.round().toString(),
                              _currentRangeValues.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              // setState(() {
                              //   _currentRangeValues = values;
                              // });

                              filterOptionValueUpdate(
                                  value: values.start.toString(),
                                  value2: values.end.toString(),
                                  optionKey: optionGroup['key']);
                            },
                          ),

                          // frs.RangeSlider(
                          //   min: double.parse(entry.value['min']),
                          //   max: double.parse(entry.value['max']),
                          //   lowerValue: double.parse(filterOptionSelection
                          //           .containsKey(optionGroup['key'])
                          //       ? filterOptionSelection[optionGroup['key']]
                          //           ['min']
                          //       : entry.value['min']),
                          //   upperValue: double.parse(filterOptionSelection
                          //           .containsKey(optionGroup['key'])
                          //       ? filterOptionSelection[optionGroup['key']]
                          //           ['max']
                          //       : entry.value['max']),
                          //   divisions:
                          //       double.parse(entry.value['max']).toInt() -
                          //           double.parse(entry.value['min']).toInt(),
                          //   showValueIndicator: true,
                          //   //valueIndicatorMaxDecimals: 1,
                          //   onChanged: (double newLowerValue,
                          //           double newUpperValue) =>
                          //       filterOptionValueUpdate(
                          //           value: newLowerValue.toString(),
                          //           value2: newUpperValue.toString(),
                          //           optionKey: optionGroup['key']),
                          // ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  filterOptionSelection
                                          .containsKey(optionGroup['key'])
                                      ? filterOptionSelection[
                                          optionGroup['key']]['min']
                                      : entry.value['min'],
                                  style: appBenchmarkReturnType2),
                              Text(
                                  filterOptionSelection
                                          .containsKey(optionGroup['key'])
                                      ? filterOptionSelection[
                                          optionGroup['key']]['max']
                                      : entry.value['max'],
                                  style: appBenchmarkReturnType2),
                            ],
                          ),
                          SizedBox(height: getScaledValue(6))
                        ],
                      )
              ]));
        }).toList(),
      ],
    );
  }

  bool keyStatsSelected(String filterOptionKey) {
    bool found = false;
    if (filterOptionKey == "key_stats") {
      [
        'cagr',
        'stddev',
        'sharpe',
        'Bench_alpha',
        'Bench_beta',
        'successratio',
        'inforatio'
      ].forEach((value) {
        if (filterOptionSelection.containsKey(value)) {
          found = true;
        }
      });
    }
    return found;
  }

  Widget filterOptionTextRow(String title) {
    if (activeFilterOption == "zone") {
      return Row(
        children: [
          widgetZoneFlag(title.toLowerCase()),
          SizedBox(width: getScaledValue(5)),
          Text(title, style: bodyText1.copyWith(color: colorDarkGrey)),
        ],
      );
    } else {
      return Text(title, style: bodyText1.copyWith(color: colorDarkGrey));
    }
  }

  filterOptionValueUpdate({String value, String value2, String optionKey}) {
    _setState(() {
      if (filterOptions[activeFilterOption]['optionType'] == "radio") {
        filterOptionSelection[activeFilterOption] = value;
      } else if (filterOptions[activeFilterOption]['optionType'] ==
          "checkbox") {
        if (filterOptionSelection.containsKey(activeFilterOption)) {
          if (filterOptionSelection[activeFilterOption].contains(value)) {
            filterOptionSelection[activeFilterOption].remove(value);
          } else {
            filterOptionSelection[activeFilterOption].add(value);
          }
        } else {
          filterOptionSelection[activeFilterOption] = [value];
        }
      } else if (filterOptions[activeFilterOption]['optionType'] ==
          "range_slider") {
        filterOptionSelection[optionKey] = {'min': value, 'max': value2};
        filterOptionSelection;
      }

      if (activeFilterOption == "type") {
        filterOptionSelection.remove('category');
        filterOptions['category']['optionGroups'][0]['options'] =
            categoryOptions[value];

        if (['stocks', 'bonds', 'commodity'].contains(value)) {
          filterOptionSelection['sortby'] = 'name';
        }
      }
    });
    return;
  }

  boxContainer(
    String optionName, {
    bool isActive = false,
  }) =>
      Container(
        height: 33,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xffe2edff) : Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
              color: isActive ? colorActive : Color(0xffeeeeee), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              optionName,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(12.0),
                fontWeight: FontWeight.w500,
                fontFamily: 'nunito',
                letterSpacing: 0,
                color: isActive ? colorActive : Color(0xff979797),
              ),
            ),
          ],
        ),
      );

  List<Widget> _portfolioList() {
    // List<Widget> _children = [];
    // _children.add(emptyWidget);
    // widget.model.userPortfoliosData['0']['portfolios'];
    // if (widget.model.userPortfoliosData['0']['portfolios'].length > 0) {
    //   widget.model.userPortfoliosData['0']['portfolios']
    //       .forEach((fundType, portfolios) {
    //     portfolios.asMap().forEach((index, portfolio) =>
    //         _children.add(portfolioFundBox(portfolio, index)));
    //   });
    // }

    // if (widget.model.userPortfoliosData == null ||
    //     widget.model.userPortfoliosData['0'] == null ||
    //     widget.model.userPortfoliosData['0']['portfolios'] == null) {
    //   return Container();
    // }
    List<Widget> _children = [];
    _children.add(emptyWidget);

    if (depositPortfolio) {
      log.d("Inside deposite if");
      if (depositPortfolioList.length > 0) {
        for (var i = 0; i < depositPortfolioList['Deposit'].length; i++) {
          var items = depositPortfolioList['Deposit'];
          _children.add(
              depositPortfolio ? portfolioDepositHoldingBox(items, i) : null);
        }
      }
    } else {
      log.d("Inside deposite else");
      if (widget.model.userPortfoliosData['0']['portfolios'].length > 0) {
        widget.model.userPortfoliosData['0']['portfolios']
            .forEach((fundType, portfolios) {
          portfolios.asMap().forEach((index, portfolio) =>
              _children.add(portfolioFundBox(portfolio, index)));
        });
      }
    }

    return _children;
    // return Expanded(
    //   child: Column(
    //     children: _children,
    //   ),
    // );
  }

  Widget portfolioDepositHoldingBox(List<dynamic> portfolio, int index) {
    String bankName = "";
    String check_bank_id = portfolio[index]['depositData']['bank_id'] ?? '';
    String display_name = portfolio[index]['depositData']['display_name'] ?? '';
    String portfolio_type = portfolio[index]['type'] ?? '';
    String portfolio_ric = portfolio[index]['ric'] ?? '';
    String portfolio_zone = portfolio[index]['zone'] ?? '';
    String portfolio_dep_amount =
        portfolio[index]['depositData']['amount'] ?? '';
    String portfolio_dep_rate = portfolio[index]['depositData']['rate'] ?? '';

    String portfolio_dep_freq =
        portfolio[index]['depositData']['frequency'] ?? '';
    var item = frequency_Map.firstWhere((k) => k['value'] == portfolio_dep_freq,
        orElse: () => {});
    portfolio_dep_freq = item['frequency'] ?? '';

    String maturity_date = "";
    bank_items.forEach((element) {
      String bank_id = element['bank_id'];
      if (check_bank_id == bank_id) {
        bankName = element['bank_name'];
      }
    });
    // log.d(portfolio[index]['depositData']['maturity_date']);
    var parsedDate =
        DateTime.parse(portfolio[index]['depositData']['maturity_date']) ?? '';
    final date_format = DateFormat("MM-yyyy");
    maturity_date = date_format.format(parsedDate).toString();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  // color: Colors.yellow,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 6.0, right: 6.0, bottom: 6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bankName, style: body_text2_dashboardPerfomer),
                        SizedBox(height: getScaledValue(5)),
                        Text(display_name, style: portfolioBoxName),
                        SizedBox(height: getScaledValue(7)),
                        Row(
                          children: <Widget>[
                            widgetBubble(
                                title: portfolio_type.toUpperCase(),
                                leftMargin: 0,
                                textColor: Color(0xffa7a7a7)),
                            SizedBox(width: getScaledValue(7)),
                            widgetBubble(
                                title: portfolio_ric.toUpperCase(),
                                leftMargin: 0,
                                textColor: Color(0xffa7a7a7)),
                            SizedBox(width: getScaledValue(7)),
                            widgetZoneFlag(portfolio_zone),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: getScaledValue(50)),
                Expanded(
                    child: Container(
                  // color: Colors.pink,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8.0, left: 8.0, top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: getScaledValue(100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Amount", style: transactionBoxLabel),
                              SizedBox(height: getScaledValue(5)),
                              Text(portfolio_dep_amount,
                                  style: transactionBoxDetail),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: getScaledValue(100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Annual Interest Rate",
                                  style: transactionBoxLabel),
                              SizedBox(height: getScaledValue(5)),
                              Text('$portfolio_dep_rate%($portfolio_dep_freq)',
                                  style: transactionBoxDetail),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: getScaledValue(100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Maturity", style: transactionBoxLabel),
                              SizedBox(height: getScaledValue(5)),
                              Text(maturity_date, style: transactionBoxDetail),
                            ],
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              for (var i = 0;
                                  i < depositPortfolioList['Deposit'].length;
                                  i++) {
                                if (index == i) {
                                  deposit_arrays.removeAt(i);
                                }
                              }

                              if (portfolioCount(checkWeight: true) == 0) {
                                depositPortfolio = false;
                              }
                            });
                          },
                          child: Text("Delete", style: textLink1),
                        ),
                      ],
                    ),
                  ),
                ))
              ]),
        ),
        divider(),
      ],
    );

    // return Container(
    //   margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     border: Border.all(
    //       color: Color(0xffe8e8e8),
    //       width: getScaledValue(1),
    //     ),
    //     borderRadius: BorderRadius.circular(4),
    //   ),
    //   padding: EdgeInsets.all(
    //     getScaledValue(16),
    //   ),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(bankName, style: body_text2_dashboardPerfomer),
    //               Text(display_name, style: portfolioBoxName),
    //             ],
    //           ),
    //           PopupMenuButton(
    //             onSelected: (value) async {
    //               // log.d(index);

    //               var zone = "";

    //               for (var i = 0;
    //                   i < depositPortfolioList['Deposit'].length;
    //                   i++) {
    //                 if (index == i) {
    //                   zone = depositPortfolioList['Deposit'][i]['zone'];
    //                   deposit_arrays.removeAt(i);
    //                   // depositPortfolioList['Deposit']
    //                   //     .removeWhere((item) => item['zone'] == zone);
    //                 }
    //               }
    //             },
    //             itemBuilder: (context) {
    //               return [
    //                 PopupMenuItem(
    //                   child: Text("Delete"),
    //                   value: "Delete",
    //                 )
    //               ];
    //             },
    //           ),
    //         ],
    //       ), //
    //       SizedBox(height: 16),
    // Row(
    //   children: <Widget>[
    //     widgetBubble(
    //         title: portfolio_type.toUpperCase(),
    //         leftMargin: 0,
    //         textColor: Color(0xffa7a7a7)),
    //     SizedBox(width: getScaledValue(7)),
    //     widgetBubble(
    //         title: portfolio_ric.toUpperCase(),
    //         leftMargin: 0,
    //         textColor: Color(0xffa7a7a7)),
    //     SizedBox(width: getScaledValue(7)),
    //     widgetZoneFlag(portfolio_zone),
    //   ],
    // ),

    //       SizedBox(height: 16),
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text("Amount", style: transactionBoxLabel),
    //               SizedBox(height: 2),
    //               Text(portfolio_dep_amount, style: transactionBoxDetail),
    //             ],
    //           ),
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text("Annual Interest Rate", style: transactionBoxLabel),
    //               SizedBox(height: 2),
    //               Text('$portfolio_dep_rate%($portfolio_dep_freq)',
    //                   style: transactionBoxDetail),
    //             ],
    //           ),
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text("Maturity", style: transactionBoxLabel),
    //               SizedBox(height: 2),
    //               Text(maturity_date, style: transactionBoxDetail),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget portfolioFundBox(Map portfolioData, int index) {
    // List zones = portfolioData['portfolio_zone'].split('_');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              // color: Colors.yellow,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 6.0, right: 6.0, bottom: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolioData['name'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Color(0xff383838),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: getScaledValue(5)),
                    Row(
                      children: <Widget>[
                        widgetBubble(
                            title: portfolioData['type'] != null
                                ? portfolioData['type'].toUpperCase()
                                : "",
                            leftMargin: 0,
                            textColor: Color(0xffa7a7a7)),
                        SizedBox(width: getScaledValue(7)),
                        widgetZoneFlag(portfolioData['zone']),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: getScaledValue(50)),
            Expanded(
                child: Container(
              // color: Colors.pink,
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, left: 8.0, top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        Container(
                            // color: Colors.pink,
                            width: MediaQuery.of(context).size.width * 0.10,
                            child: Text(
                              "Current Price",
                              maxLines: 2,
                              style: portfolioBoxHolding,
                            )),
                        SizedBox(width: getScaledValue(5)),
                        Container(
                          // color: Colors.orange,
                          width: MediaQuery.of(context).size.width * 0.10,
                          child: Text(
                              portfolioData['latestCurrencyPriceString'] ?? "",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0.19,
                                  color: Color(0xff383838))),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: getScaledValue(100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              portfolioData['type'].toLowerCase() == "commodity"
                                  ? "grams"
                                  : "units",
                              style: portfolioBoxHolding),
                          SizedBox(height: getScaledValue(5)),
                          TextField(
                              decoration: InputDecoration(
                                  prefix: Container(
                                    child: Image.asset(
                                      "assets/icon/icon_dollar.png",
                                      width: 18,
                                      height: 14,
                                    ),
                                  ),
                                  suffix: Container(
                                    child: Image.asset(
                                      "assets/icon/edit_icon.png",
                                      width: 13,
                                      height: 13,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(0),
                                  labelStyle:
                                      focusNodesUnits[portfolioData['ric']]
                                              .hasFocus
                                          ? inputLabelFocusStyle.copyWith(
                                              color: Color(0xff8e8e8e))
                                          : inputLabelStyle.copyWith(
                                              color: Color(0xff8e8e8e))),
                              focusNode: focusNodesUnits[portfolioData['ric']],
                              controller:
                                  _controllerUnits[portfolioData['ric']],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              onChanged: (String value) {
                                if (value.trim() == "" || value.trim() == ".") {
                                  value = "0";
                                }
                                setState(() {
                                  widget.model.userPortfoliosData['0']
                                          ['portfolios'][portfolioData['type']]
                                      [index]['weightage'] = value;
                                  widget.model.userPortfoliosData['0']
                                          ['portfolios'][portfolioData['type']]
                                      [index]['transactions'][0] = {
                                    "ric": portfolioData['ric'],
                                    "holding": value,
                                    "type": "buy",
                                    "price": "",
                                    "date": ""
                                  };
                                });
                              },
                              style: inputFieldStyle),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        widget
                            .model
                            .userPortfoliosData['0']['portfolios']
                                [portfolioData['type']]
                            .removeAt(index);
                        updateUnitOption(value: unitOption);
                        /* if(widget.model.userPortfoliosData['0']['portfolios'][portfolio['type']].length == 0){
                              widget.model.userPortfoliosData['0']['portfolios'].removeAt(portfolio['type']);
                            } */
                        _setStockPortfolio();
                      }),
                      child: Text("Delete", style: textLink1),
                    ),
                  ],
                ),
              ),
            ))
          ]),
        ),
        divider(),
      ],
    );
  }

  _setUserPortfoliosData() {
    setState(() {
      widget.model.userPortfoliosData.remove('0');
      widget.model.userPortfoliosData['0'] = {
        'portfolio_name': "",
        'portfolios': {}
      };
    });
  }

  updateKeyStatsRange() async {
    dynamic keyStatsRange = await widget.model.getKeyStatsRange();
    if (keyStatsRange.containsKey('status') &&
        keyStatsRange['status'] == true) {
      filterOptions['key_stats']['optionGroups']
          .asMap()
          .forEach((key, element) {
        if (keyStatsRange['response'].containsKey(element['key'])) {
          setState(() {
            filterOptions['key_stats']['optionGroups'][key]['options']['range']
                    ['min'] =
                keyStatsRange['response'][element['key']]['min'].toString();
            filterOptions['key_stats']['optionGroups'][key]['options']['range']
                    ['max'] =
                keyStatsRange['response'][element['key']]['max'].toString();
          });
        }
      });
    }
  }

  resetFilter() {
    _setState(() {
      filterOptionSelection = Map.from(filterOptionSelectionReset);
    });
  }

  applyFilter() async {
    Navigator.of(context).pop();
    setState(() {
      // widget.model.setLoader(true);
      selectedRICs = null;
      filterResultPopupWeb();
      fundList = [];
    });
    log.d(json.encode(filterOptionSelection));
    Map responseData = await widget.model.fundScreener(filterOptionSelection);
    _setState(() {
      if (responseData.isNotEmpty) {
        fundList = responseData['response'];
        log.d(fundList.toString());
        page = "fundList";
      }

      // widget.model.setLoader(false);
    });
  }

  filterResultPopupWeb() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              width: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Asset',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.w800,
                                fontFamily: 'nunito',
                                letterSpacing: 0.26,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                                fundList.length.toString() +
                                    " " +
                                    fundTypeCaption(
                                        filterOptionSelection['type']) +
                                    " shortlisted",
                                style: bodyText4),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, color: Color(0xffa5a5a5)))
                    ],
                  ),
                  SizedBox(height: getScaledValue(9)),
                  // Container(
                  //   color: Color(0xffeeeeee),
                  //   height: 1.5,
                  // )
                  divider(),
                  fundList.length == 0
                      ? Expanded(child: preLoader(title: ""))
                      : Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: ListView(
                                  children: [
                                    SizedBox(height: getScaledValue(10)),
                                    ...fundList
                                        .map((element) => fundBoxForFiltration1(
                                              context,
                                              element,
                                              onTap: () =>
                                                  selectInstrumentAction(null,
                                                      ricMap: element),
                                              isSelected: selectedRICs == null
                                                  ? false
                                                  : selectedRICs.ric ==
                                                          element['ric']
                                                      ? true
                                                      : false,
                                              sortCaption: sortByCaption(),
                                              sortWidget: filterOptionSelection
                                                          .containsKey(
                                                              'sortby') &&
                                                      [
                                                        'overall_rating',
                                                        'tr_rating',
                                                        'alpha_rating',
                                                        'srri',
                                                        'tracking_rating'
                                                      ].contains(
                                                          filterOptionSelection[
                                                              'sortby'])
                                                  ? svgImage(
                                                      "assets/icon/star_filled.svg")
                                                  : (filterOptionSelection[
                                                              'sortby'] ==
                                                          "tna"
                                                      ? Text('M')
                                                      : null),
                                            ))
                                        .toList()
                                  ],
                                ),
                              ),
                              divider(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: getScaledValue(13),
                                    vertical: getScaledValue(13)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    resetButton('Back to Filter',
                                        borderColor: colorBlue,
                                        textColor: colorBlue,
                                        onPressFunction: () {
                                      Navigator.pop(context);
                                      filterPopupWeb();
                                    }),
                                    SizedBox(width: getScaledValue(10)),
                                    Container(
                                        width: 166,
                                        child: gradientButton(
                                            context: context,
                                            caption: 'ADD',
                                            onPressFunction: () =>
                                                addInstrumentAction(
                                                    selectedRICs),
                                            miniButton: true,
                                            buttonDisabled: selectedRICs == null
                                                ? true
                                                : false)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget fundBoxForFiltration1(BuildContext context, Map portfolio,
      {Function refreshParentState,
      Function onTap,
      Widget sortWidget,
      String sortCaption,
      bool readOnly = false,
      bool isSelected = false,
      bool isSearch = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
        decoration: BoxDecoration(
            color: isSearch
                ? isSelected
                    ? Color(0xffe2edff)
                    : Colors.white
                : Colors.white,
            border: Border.all(
                color: isSearch
                    ? Color(0xffe8e8e8)
                    : isSelected
                        ? colorActive
                        : Color(0xffe8e8e8),
                width: getScaledValue(1)),
            borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(getScaledValue(16)),
        //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(limitChar(portfolio['name'], length: 35),
                style: portfolioBoxName),
            SizedBox(height: getScaledValue(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    widgetBubble(
                        title: portfolio['type'] != null
                            ? portfolio['type'].toUpperCase()
                            : "",
                        leftMargin: 0,
                        bgColor: isSearch
                            ? isSelected
                                ? Color(0xffe2edff)
                                : Colors.white
                            : Colors.white,
                        textColor: Color(0xffa7a7a7)),
                    SizedBox(width: getScaledValue(7)),
                    widgetZoneFlag(portfolio['zone']),
                  ],
                ),
                Row(
                  children: [
                    sortCaption != null ? Text(sortCaption) : emptyWidget,
                    portfolio.containsKey('sortby') &&
                            portfolio['sortby'] != null
                        ? Text(roundDouble(portfolio['sortby'],
                            decimalLength: sortWidget != null ? 0 : 2))
                        : emptyWidget,
                    sortWidget != null ? sortWidget : emptyWidget
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String sortByCaption() {
    String caption;
    if (filterOptionSelection.containsKey('sortby')) {
      if (filterOptionSelection['sortby'] == "name") {
        return null;
      }
      filterOptions['sortby']['optionGroups'].forEach((element) {
        element['options'].forEach((key, value) {
          if (key == filterOptionSelection['sortby']) {
            caption = value + ": ";
          }
        });
      });
    }
    return caption;
  }

  selectInstrumentAction(RICs selectedRIC, {Map ricMap}) {
    _setState(() {
      if (selectedRIC == null) {
        selectedRICs = RICs(
            name: ricMap['name'],
            zone: ricMap['zone'],
            ric: ricMap['ric'],
            fundType: ricMap['type'],
            latestPriceBase: ricMap['latestPriceBase'],
            latestPriceString: ricMap['latestPriceString'],
            latestCurrencyPriceString: ricMap['latestCurrencyPriceString'],
            currency: ricMap['cf_curr']);
      } else {
        selectedRICs = selectedRIC;
      }
    });
  }

  addInstrumentAction(RICs selectedRIC, {Map ricMap}) {
    try {
      if (selectedRIC == null) {
        selectedRIC = RICs(
            name: ricMap['name'],
            zone: ricMap['zone'],
            ric: ricMap['ric'],
            fundType: ricMap['type'],
            latestPriceBase: ricMap['latestPriceBase'],
            latestPriceString: ricMap['latestPriceString'],
            latestCurrencyPriceString: ricMap['latestCurrencyPriceString']);
      }

      String _portfolioMasterID;
      if (widget.action == "newPortfolio" || widget.action == "newInstrument") {
        if (widget.action == "newPortfolio") {
          _portfolioMasterID = '0';
        } else {
          _portfolioMasterID = widget.portfolioMasterID;
        }

        int errorCode = 0;
        // 0 - No error, 1 - Duplicate Ric

        bool sameName = false;
        setState(() {
          if (!widget.model.userPortfoliosData[_portfolioMasterID]['portfolios']
              .containsKey(selectedRIC.fundType)) {
            widget.model.userPortfoliosData[_portfolioMasterID]['portfolios']
                [selectedRIC.fundType] = [];
          } else {
            // check if already exists

            widget
                .model
                .userPortfoliosData[_portfolioMasterID]['portfolios']
                    [selectedRIC.fundType]
                .forEach((portfolio) {
              if (portfolio['ric'] == selectedRIC.ric) {
                errorCode = 1;
                sameName = true;
                return;
              }
            });
          }

          if (sameName) {
            showAlertDialogBox(
                context, 'Error!', "Instrument already exists in portfolio");
            // customAlertBox(
            //     context: context,
            //     type: "error",
            //     title: "Error!",
            //     description: "Instrument already exists in portfolio",
            //     buttons: null);
            return;
          }

          widget
              .model
              .userPortfoliosData[_portfolioMasterID]['portfolios']
                  [selectedRIC.fundType]
              .add({
            "zone": selectedRIC.zone,
            'ric': selectedRIC.ric,
            'name': selectedRIC.name,
            'transactions': [],
            'type': selectedRIC.fundType,
            'weightage': '0',
            'latestPrice': selectedRIC.latestPriceBase,
            'latestPriceString': selectedRIC.latestPriceString,
            'latestCurrencyPriceString': selectedRIC.latestCurrencyPriceString
          });
        });
        if (errorCode == 0) {
          if (widget.action == "newPortfolio") {
            setState(() {
              page = 'add_instrument_new_portfolio';
            });
            focusNodesUnits[selectedRIC.ric] = FocusNode();
            _controllerUnits[selectedRIC.ric] =
                TextEditingController(text: '1.00');

            var portfolioIndex = widget
                    .model
                    .userPortfoliosData[_portfolioMasterID]['portfolios']
                        [selectedRIC.fundType]
                    .length -
                1;

            setState(() {
              widget.model.userPortfoliosData[_portfolioMasterID]['portfolios']
                  [selectedRIC.fundType][portfolioIndex]['weightage'] = "1.00";
              widget
                  .model
                  .userPortfoliosData[_portfolioMasterID]['portfolios']
                      [selectedRIC.fundType][portfolioIndex]['transactions']
                  .add({
                "ric": selectedRIC.ric,
                "holding": "1.00",
                "type": "buy",
                "price": "",
                "date": ""
              });
            });

            _setStockPortfolio();

            updateUnitOption(value: unitOption);

            Navigator.pop(context);
          } else {
            Map arguments = {
              'portfolioMasterID': _portfolioMasterID,
              'ricType': selectedRIC.fundType,
              'ricIndex': (widget
                          .model
                          .userPortfoliosData[_portfolioMasterID]['portfolios']
                              [selectedRIC.fundType]
                          .length -
                      1)
                  .toString(),
              'ricSelected': true,
              'ricZone': selectedRIC.zone,
              'ricName': selectedRIC.ric,
              'portfolioMasterData':
                  widget.model.userPortfoliosData[_portfolioMasterID],
              'action': widget.action,
            };
            Navigator.pushReplacementNamed(context, '/add_transactions',
                arguments: arguments);
          }
        }
      }
    } catch (e) {
      log.d(e);
    }
  }

  _setStockPortfolio() {
    setState(() {
      if (portfolioCount(checkWeight: true) == 0) {
        stockPortfolio = false;
      } else {
        stockPortfolio = true;
      }
    });
  }

  updateUnitOption({value}) {
    setState(() {
      unitOption = value;

      if (value == "custom") {
        var units = "1.00";
        widget.model.userPortfoliosData["0"]['portfolios']
            .forEach((fundType, portfolios) {
          portfolios.asMap().forEach((index, portfolioData) {
            widget.model.userPortfoliosData["0"]['portfolios'][fundType][index]
                ['weightage'] = units;
            widget.model.userPortfoliosData["0"]['portfolios'][fundType][index]
                ['transactions'][0]['holding'] = units;
            _controllerUnits[portfolioData['ric']] =
                TextEditingController(text: '1.00');
          });
        });
      } else if (value == "equal_units") {
        num currentPortfolioSum = 0;
        widget.model.userPortfoliosData["0"]['portfolios']
            .forEach((fundType, portfolios) {
          portfolios.forEach((portfolioData) {
            currentPortfolioSum += portfolioData['latestPrice'];
          });
        });

        var units = (portfolioAmount / currentPortfolioSum).roundToDouble();

        widget.model.userPortfoliosData["0"]['portfolios'];
        widget.model.userPortfoliosData["0"]['portfolios']
            .forEach((fundType, portfolios) {
          portfolios.asMap().forEach((index, portfolioData) {
            widget.model.userPortfoliosData["0"]['portfolios'][fundType][index]
                ['weightage'] = units.toString();
            widget.model.userPortfoliosData["0"]['portfolios'][fundType][index]
                ['transactions'][0]['holding'] = units.toString();
            _controllerUnits[portfolioData['ric']] =
                TextEditingController(text: units.toString());
          });
        });
      } else if (value == "equal_weights") {
        widget.model.userPortfoliosData["0"]['portfolios']
            .forEach((fundType, portfolios) {
          portfolios.asMap().forEach((index, portfolioData) {
            var ricMaxAmount = portfolioAmount / portfolioCount();
            var units =
                (ricMaxAmount / portfolioData['latestPrice']).roundToDouble();
            widget.model.userPortfoliosData["0"]['portfolios'][fundType][index]
                ['weightage'] = units.toString();
            widget.model.userPortfoliosData["0"]['portfolios'][fundType][index]
                ['transactions'][0]['holding'] = units.toString();
            _controllerUnits[portfolioData['ric']] =
                TextEditingController(text: units.toString());
          });
        });
      }
    });
  }

  int portfolioCount({portfolioMasterID = "0", bool checkWeight = false}) {
    int count = 0;
    bool returnCount = true;
    if (widget.model.userPortfoliosData[portfolioMasterID] != null &&
        widget.model.userPortfoliosData[portfolioMasterID]['portfolios'] !=
            null &&
        widget.model.userPortfoliosData[portfolioMasterID]['portfolios']
                .length >
            0) {
      widget.model.userPortfoliosData[portfolioMasterID]['portfolios']
          .forEach((fundType, portfolios) {
        if (checkWeight) {
          portfolios.forEach((portfolio) {
            if (num.parse(portfolio['weightage']) <= 0) {
              returnCount = false;
              ;
              //count += portfolios.length;
            } else {
              count += portfolios.length;
            }
          });
        } else {
          count += portfolios.length;
        }
      });
    }

    if (returnCount) {
      return count;
    } else {
      return 0;
    }
  }

  Widget _unitOptions() {
    if (portfolioCount() < 2) {
      return emptyWidget;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ['equal_units', 'equal_weights'].contains(unitOption)
            ? Container(
                width: 150,
                // height: 35,
                child: Form(
                  child: TextFormField(
                      focusNode: focusNodes['portfolio_amount'],
                      controller: _controller['portfolio_amount'],
                      validator: (value) {
                        /* if ( value.length < 2 || value.isEmpty) {
										return "Invalid First Name";
									} */
                        return null;
                      },
                      decoration: InputDecoration(
                          // hintText: "Enter amount ",
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil().setSp(14.0),
                              fontFamily: 'nunito',
                              letterSpacing: 0.2,
                              color: Color(0xff979797)),
                          labelText: 'Enter amount ',
                          labelStyle: focusNodes['portfolio_amount'].hasFocus
                              ? inputLabelFocusStyle
                              : inputLabelStyle),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (String value) {
                        setState(() {
                          portfolioAmount = num.parse(value);
                          log.d(_controller['portfolio_amount'].text.isEmpty);
                        });
                        updateUnitOption(value: unitOption);
                      },
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(14.0),
                          fontFamily: 'nunito',
                          letterSpacing: 0.2,
                          color: Colors.black)),
                ),
              )
            : emptyWidget,
        SizedBox(width: getScaledValue(5)),
        Text(
          "Units:",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(12.0),
            fontWeight: FontWeight.w600,
            fontFamily: 'nunito',
            letterSpacing: 0,
            color: Color(0xff707070),
          ),
        ),
        SizedBox(width: getScaledValue(5)),
        DropdownButtonHideUnderline(
          child: DropdownButton(
              value: sourceValues,
              style: textLink1,
              hint: Text("Equal Weights", style: textLink1),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colorBlue,
              ),
              items: _sourceList.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value == "equal_weights"
                      ? "Equal Weights"
                      : value == "equal_units"
                          ? "Equal Units"
                          : "Custom"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  sourceValues = value;
                  log.d(sourceValues);
                  updateUnitOption(value: sourceValues);
                });
              }),
        ),
        GestureDetector(
          onTap: () => alertDialogPopup(
            title: "Allocation preference",
            description:
                'Equal Weights: Allocate an equal amount to each asset in the portfolio. The units will be calculated for each asset, such that the amount remains the same. \n\nEqual Units: Allocate equal number of units to each asset in the portfolio.\n\nCustom: Define your own unit allocation across assets',
          ),
          child: Image.asset("assets/icon/information_gray.png",
              width: getScaledValue(10)),
        ),
      ],
    );
  }

  alertDialogPopup({@required String title, @required String description}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Container(
                height: 200,
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(16),
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0.26,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.close, color: Color(0xffa5a5a5)))
                      ],
                    ),
                    SizedBox(height: getScaledValue(9)),
                    // Container(
                    //   color: Color(0xffeeeeee),
                    //   height: 1.5,
                    // )
                    divider(),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: getScaledValue(15)),
                        child: Text(description, style: bodyText4))
                  ],
                ),
              ));
        });
  }

  // }
  // Widget _unitOptionsdulpicate(){
  // 	if(portfolioCount() < 2){
  // 		return emptyWidget;
  // 	}
  // 	return Container(
  // 		child: Column(
  // 			children: [
  // 				Row(
  // 					//crossAxisAlignment: CrossAxisAlignment.start,
  // 					children: [
  // 						Expanded(
  // 							child: Row(
  // 								children: [
  // 									Row(
  // 										children: [
  // 											Radio(
  // 												materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  // 												groupValue: unitOption,
  // 												value: "equal_weights",
  // 												onChanged: (value) => updateUnitOption(value: value),
  // 												activeColor: colorBlue,

  // 											),
  // 											Text("Equal Weights", style: bodyText4.copyWith(color:  unitOption == "equal_weights" ? colorBlue : null))
  // 										],
  // 									),
  // 									Row(
  // 										children: [
  // 											Radio(
  // 												materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  // 												groupValue: unitOption,
  // 												value: "equal_units",
  // 												onChanged: (value) => updateUnitOption(value: value),
  // 												activeColor: colorBlue,
  // 											),
  // 											Text("Equal Units", style: bodyText4.copyWith(color:  unitOption == "equal_units" ? colorBlue : null))
  // 										],
  // 									),
  // 									Row(
  // 										children: [
  // 											Radio(
  // 												materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  // 												groupValue: unitOption,
  // 												value: "custom",
  // 												onChanged: (value) => updateUnitOption(value: value),
  // 												activeColor: colorBlue,
  // 											),
  // 											Text("Custom", style: bodyText4.copyWith(color:  unitOption == "custom" ? colorBlue : null))
  // 										],
  // 									),
  // 								],
  // 							)
  // 						),
  // 						InkWell(
  // 								onTap: () {
  // 									bottomAlertBox(
  // 										context: context,
  // 										title: 'Allocation preference',
  // 										description: 'Equal Weights: Allocate an equal amount to each asset in the portfolio. The units will be calculated for each asset, such that the amount remains the same. \n\nEqual Units: Allocate equal number of units to each asset in the portfolio.\n\nCustom: Define your own unit allocation across assets',
  // 									);
  // 								},
  // 								child: svgImage("assets/icon/information.svg", width: getScaledValue(12),),
  // 							),
  // 					],
  // 				),

  // 				['equal_units', 'equal_weights'].contains(unitOption) ?
  // 					Form(
  // 						child: TextFormField(
  // 							focusNode: widget.focusNodes['portfolio_amount'],
  // 							controller: widget.controller['portfolio_amount'],
  // 							validator: (value){
  // 								/* if ( value.length < 2 || value.isEmpty) {
  // 									return "Invalid First Name";
  // 								} */
  // 								return null;
  // 							},
  // 							decoration: InputDecoration(labelText: 'Portfolio Amount (in ' + (widget.model.userSettings['currency'] != null ? widget.model.userSettings['currency'] : "inr").toUpperCase() + ')', labelStyle: widget.focusNodes['portfolio_amount'].hasFocus ? inputLabelFocusStyle : inputLabelStyle),
  // 							keyboardType: TextInputType.numberWithOptions(decimal: true),
  // 							onChanged: (String value) {
  // 								setState(() {
  // 									portfolioAmount = num.parse(value);
  // 								});
  // 								updateUnitOption(value: unitOption);
  // 							},
  // 							style: inputFieldStyle
  // 						),
  // 					) : emptyWidget
  // 			],
  // 		)
  // 	);
  // }
}
