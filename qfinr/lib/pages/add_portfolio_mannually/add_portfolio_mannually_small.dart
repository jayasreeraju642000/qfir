import 'dart:async';
import 'dart:collection';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:intl/intl.dart';
import 'package:qfinr/pages/add_portfolio_mannually/serach_and_filter_options.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/helpers/portfolio_helper.dart';
import 'package:qfinr/widgets/helpers/search_bank.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/widgets/widget_common.dart';
//import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

final log = getLogger('AddPortfolioManuallyPage');

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

class AddPortfolioManuallySmallPage extends StatefulWidget {
  final MainModel model;

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

  // pageType = [add_portfolio, add_instrument]
  //
  AddPortfolioManuallySmallPage(this.model,
      {this.analytics,
      this.observer,
      this.pageType = "add_portfolio",
      this.action = "newPortfolio",
      this.portfolioIndex = null,
      this.portfolioMasterID,
      this.viewDeposit,
      this.portfolioDepositID,
      this.selectedPortfolioMasterIDs,
      this.arguments}); // add_portfolio // add_instrument_new_portfolio
  // for split portfolio action pass portfoliMasterID
  // for merge portfolio action pass selectedPortfolioMasterIDs
  // for add instrument page type, action newInstrument,  pass portfoliMasterID

  @override
  State<StatefulWidget> createState() {
    return _AddPortfolioManuallySmallPageState();
  }
}

class _AddPortfolioManuallySmallPageState
    extends State<AddPortfolioManuallySmallPage> {
  final controller = ScrollController();
  final GlobalKey<FormState> _addPortfolioForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _addDepositForm = GlobalKey<FormState>();
  RangeValues _currentRangeValues;
  String pageType = "add_portfolio";

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

  num portfolioAmount = 0;

  Map<String, FocusNode> focusNodesUnits = {};
  Map<String, TextEditingController> _controllerUnits = {};

  bool displaySearchBox = false;

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

  Future<Null> _analyticsNewAssetCurrentScreen() async {
    // log.d("\n analyticsNewAssetCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'add_new_asset',
      screenClassOverride: 'add_new_asset',
    );
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

  Future<Null> _analyticsCreatePortfolioEvent(String portfolioName) async {
    // log.d("\n analyticsNewAssetCurrentScreen called \n");
    await widget.analytics.logEvent(name: 'select_item', parameters: {
      'item_id': "add_manually",
      'item_name': "new_portfolio_creation",
      'content_type': "click_create_portfolio",
      'item_list_name': portfolioName
    });
  }

  String _selectedTypeAcc;
  String _selectedDeposit;
  String _selectedCurrency;
  String _selectedFrequency;
  String ricUpdateValue;

  String page = "main"; //"add_instrument_new_portfolio"; // "main";
  List fundList;

  StateSetter _setState;

  // Map filterOptions= {
  //   'sortby': {
  //     'title': 'Sort By',
  //     'type': 'sort',
  //     'optionType': 'radio',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'key': 'scores',
  //         'group_title': 'Scores',
  //         'options': {
  //           'overall_rating': 'Overall Score',
  //           'tr_rating': 'Return Score',
  //           'alpha_rating': 'Alpha Score',
  //           'srri': 'Risk Score',
  //           'tracking_rating': 'Tracking Score'
  //         }
  //       },
  //       {
  //         'key': 'key_stats',
  //         'group_title': 'Key Stats',
  //         'options': {
  //           'cagr': '3 Year Return',
  //           'stddev': '3 Year Risks',
  //           'sharpe': 'Sharpe Ratio',
  //           'Bench_alpha': 'Alpha',
  //           'Bench_beta': 'Beta',
  //           'successratio': 'Success Rate',
  //           'inforatio': 'Information Ratio',
  //           'tna': 'AUM'
  //         }
  //       },
  //       {
  //         'key': 'name',
  //         'group_title': 'Name',
  //         'options': {'name': 'Name'}
  //       }
  //     ]
  //   },
  //   'zone': {
  //     'title': 'Country',
  //     'type': 'filter',
  //     'optionType': 'checkbox',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {'group_title': '', 'options': {}},
  //     ]
  //   },
  //   'type': {
  //     'title': 'Type',
  //     'type': 'filter',
  //     'optionType': 'radio',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'group_title': '',
  //         'options': {
  //           'funds': 'Mutual Fund',
  //           'etf': 'ETF',
  //           'stocks': 'Stocks',
  //           'bonds': 'Bonds',
  //           'commodity': 'Commodity'
  //         }
  //       }, //
  //     ]
  //   },
  //   'share_class': {
  //     'title': 'Investment Share\nClass',
  //     'type': 'filter',
  //     'optionType': 'radio',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'group_title': '',
  //         'options': {'direct': 'Direct', 'regular': 'Regular'}
  //       },
  //     ]
  //   },
  //   'category': {
  //     'title': 'Category',
  //     'type': 'filter',
  //     'optionType': 'checkbox',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'group_title': '',
  //         'options': {
  //           'Balanced': 'Balanced',
  //           'MMF': 'MMF',
  //           'Mid Cap Equity': 'Mid Cap Equity',
  //           'Long Duration Debt': 'Long Duration Debt',
  //           'Large Cap Equity': 'Large Cap Equity',
  //           'Short Duration Debt': 'Short Duration Debt',
  //           'US Equity': 'US Equity',
  //           'Thematic': 'Thematic',
  //           'Small Cap Equity': 'Small Cap Equity'
  //         }
  //       },
  //     ]
  //   },
  //   'industry': {
  //     'title': 'Industry',
  //     'type': 'filter',
  //     'optionType': 'checkbox',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'group_title': '',
  //         'options': {
  //           'Industrials': 'Industrials',
  //           'Basic Materials': 'Basic Materials',
  //           'Utilities': 'Utilities',
  //           'Consumer Cyclicals': 'Consumer Cyclicals',
  //           'Financials': 'Financials',
  //           'Healthcare': 'Healthcare',
  //           'Consumer Non-Cyclicals': 'Consumer Non-Cyclicals',
  //           'Technology': 'Technology',
  //           'Energy': 'Energy',
  //           'Real Estate': 'Real Estate'
  //         }
  //       },
  //     ]
  //   },
  //   'overall_rating': {
  //     'title': 'Overall Score',
  //     'type': 'filter',
  //     'optionType': 'range_slider',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'key': 'overall_rating',
  //         'group_title': ' ',
  //         'options': {
  //           'range': {'title': 'Select Range', 'min': '1', 'max': '5'}
  //         }
  //       },
  //     ]
  //   },
  //   'key_stats': {
  //     'title': 'Key Stats',
  //     'type': 'filter',
  //     'optionType': 'range_slider',
  //     'selectedOption': [null],
  //     'optionGroups': [
  //       {
  //         'key': 'cagr',
  //         'group_title': ' ',
  //         'options': {
  //           'range': {'title': '3 Year Return', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       {
  //         'key': 'stddev',
  //         'group_title': '',
  //         'options': {
  //           'range': {'title': '3 Year Risks', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       {
  //         'key': 'sharpe',
  //         'group_title': '',
  //         'options': {
  //           'range': {'title': 'Sharpe Ratio', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       {
  //         'key': 'Bench_alpha',
  //         'group_title': '',
  //         'options': {
  //           'range': {'title': 'Alpha', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       {
  //         'key': 'Bench_beta',
  //         'group_title': '',
  //         'options': {
  //           'range': {'title': 'Beta', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       {
  //         'key': 'successratio',
  //         'group_title': '',
  //         'options': {
  //           'range': {'title': 'Success Rate', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       {
  //         'key': 'inforatio',
  //         'group_title': '',
  //         'options': {
  //           'range': {'title': 'Information Ratio', 'min': '1', 'max': '5'}
  //         }
  //       },
  //       //{'key': '', 'group_title': '', 'options': {'range': {'min': '1', 'max': '5'}}},
  //     ]
  //   },
  //   /* 'aum_size':	{'title': 'AUM Size', 'type': 'filter', 'optionType': 'radio', 'selectedOption': [null],
  // 		'optionGroups': [
  // 			{'group_title': '', 'options': {'all': 'All', 't10': 'Top 10%', 't25': 'Top 25%', 't50': 'Top 50%', 'b25': 'Bottom 25%'}},
  // 		]
  // 	}, */
  // };

  Map categoryOptions = {
    'funds': {
      'Balanced': 'Balanced',
      'Cash/MMF': 'Cash/MMF',
      'Commodities': 'Commodities',
      'Debt DM': 'Debt DM',
      'Debt EM': 'Debt EM',
      'Debt Global': 'Debt Global',
      'Debt HY': 'Debt HY',
      'EM Equity': 'EM Equity',
      'Equity DM': 'Equity DM',
      'Equity EM': 'Equity EM',
      'Equity Global': 'Equity Global',
      'Equity SG': 'Equity SG',
      'Equity US': 'Equity US',
      'Europe Equity': 'Europe Equity',
      'Global Equity': 'Global Equity',
      'Large Cap Equity': 'Large Cap Equity',
      'Long Duration Debt': 'Long Duration Debt',
      'Mid Cap Equity': 'Mid Cap Equity',
      'MMF': 'MMF',
      'Short Duration Debt': 'Short Duration Debt',
      'Small Cap Equity': 'Small Cap Equity',
      'Thematic': 'Thematic',
      'US Equity': 'US Equity'
    },
    /* {'Balanced': 'Balanced', 'MMF': 'MMF', 'Mid Cap Equity': 'Mid Cap Equity', 'Long Duration Debt': 'Long Duration Debt', 'Large Cap Equity': 'Large Cap Equity', 'Short Duration Debt': 'Short Duration Debt', 'US Equity': 'US Equity', 'Thematic': 'Thematic', 'Small Cap Equity': 'Small Cap Equity'}, */
    'etf': {
      'Banking': 'Banking',
      'Cash/MMF': 'Cash/MMF',
      'Commodities': 'Commodities',
      'Debt DM': 'Debt DM',
      'Debt EM': 'Debt EM',
      'Debt Global': 'Debt Global',
      'Equity DM': 'Equity DM',
      'Equity EM': 'Equity EM',
      'Equity Global': 'Equity Global',
      'Global EM Equity': 'Global EM Equity',
      'Global Equity': 'Global Equity',
      'IT': 'IT',
      'Large Cap Equity': 'Large Cap Equity',
      'Mid Cap Equity': 'Mid Cap Equity',
      'MMF': 'MMF',
      'SG Equity': 'SG Equity',
      'Thematic': 'Thematic',
      'US Equity': 'US Equity'
    },
    /* {'Mid Cap Equity': 'Mid Cap Equity', 'Commodities': 'Commodities', 'Large Cap Equity': 'Large Cap Equity', 'MMF': 'MMF', 'Banking': 'Banking', 'Thematic': 'Thematic', 'IT': 'IT', 'US Equity': 'US Equity'}, */
    'stocks': {
      'Commercial REIT': 'Commercial REIT',
      'Equity EM': 'Equity EM',
      'Europe Equity': 'Europe Equity',
      'Large Cap Equity': 'Large Cap Equity',
      'Mid Cap Equity': 'Mid Cap Equity',
      'REIT': 'REIT',
      'SG Equity': 'SG Equity',
      'US Equity': 'US Equity'
    },
    /* {'Large Cap Equity': 'Large Cap Equity', 'Mid Cap Equity': 'Mid Cap Equity', 'REIT': 'REIT', 'Commercial REIT': 'Commercial REIT'}, */
    'bonds': {'Govt': 'Govt'},
  };

// Calling common data
  Map filterOptionSelection = SerachAndFilterOptions.filterOptionSelection;
  Map filterOptions = SerachAndFilterOptions.filterOptions;

  // Map filterOptionSelection = {
  //   'sort_order': 'asc',
  //   'sortby': 'name',
  //   'type': 'funds',
  // };
  Map filterOptionSelectionReset;

  String activeFilterOption = 'sortby';

  String unitOption = "custom";

  //ignore:todo
  //Todo: static arrays :shariyath

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

//
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

  DateTime currentDate = DateTime.now();
  FocusNode focusNode;

  //final format_currentDate = DateFormat("dd-MM-yyyy");
  DateTime _depositStartDate = DateTime.now();
  DateTime _depositEndDate;

  final date_format = DateFormat("yyyy-MM-dd");
  String auto_renew = "0";
  String bank_id = "0";
  bool value_auto_renew = false;
  bool depositPortfolio = false;

  Map<dynamic, dynamic> _banksData;

  String selectedValue;

  List bank_items = [];
  List bank_filter_items = [];
  List<Map<String, String>> markets = [];
  String search_key = "";

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

  final format = DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    super.initState();
    pageType = widget.pageType;
    if (widget.action == 'newPortfolio') {
      _analyticsAddManuallyCurrentScreen();
    }
    _addEvent();
    getBanks(search_key);

    filterOptionSelectionReset = Map.from(filterOptionSelection);
    // zones as per user allowed //
    widget.model.userSettings['allowed_zones'].forEach((zone) {
      filterOptions['zone']['optionGroups'][0]['options'][zone] =
          zone.toUpperCase();

      if (zone == "in") {
        filterOptionSelection['zone'] = ['in'];
      }
    });
    updateKeyStatsRange();

    Map PortfolioData = {};
    List PortfolioDepositData;

    if (widget.portfolioDepositID != null) {
      PortfolioData = new Map.from(
          widget.model.userPortfoliosData[widget.portfolioMasterID]);

      PortfolioDepositData = PortfolioData['portfolios']['Deposit'];

      for (int i = 0; i < PortfolioDepositData.length; i++) {
        if (PortfolioDepositData[i]['portfolio_id'] ==
            widget.portfolioDepositID) {
          setState(() {
            if (PortfolioDepositData[i]['depositData'] != null) {
              deposit_type_Map.forEach((element) {
                if (element['value'] ==
                    PortfolioDepositData[i]['depositData']['payout']) {
                  _selectedDeposit = element['deposit_type'];
                }
              });

              frequency_Map.forEach((element) {
                if (element['value'] ==
                    PortfolioDepositData[i]['depositData']['frequency']) {
                  _selectedFrequency = element['frequency'];
                }
              });

              type_of_acc_Map.forEach((element) {
                if (element['value'] == PortfolioDepositData[i]['ticker']) {
                  _selectedTypeAcc = element['type_acc'];
                  ricUpdateValue = PortfolioDepositData[i]['ric'];
                }
              });

              widget.model.currencies.forEach((element) {
                if (element['key'] ==
                    PortfolioDepositData[i]['depositData']['currency']) {
                  _selectedCurrency = element['key'].toString();
                }
              }); //

              _controller['display_name'].text =
                  PortfolioDepositData[i]['depositData']['display_name'];
              _controller['bank_name'].text =
                  PortfolioDepositData[i]['depositData']['bank_name'];

              var amount = PortfolioDepositData[i]['depositData']['amount'];
              amount = amount.replaceAll(",", "");
              amount = amount.substring(1);
              _controller['amount'].text = amount;

              _controller['interest'].text =
                  PortfolioDepositData[i]['depositData']['rate'];
              _controller['start_date'].text =
                  PortfolioDepositData[i]['depositData']['start_date'];
              _controller['end_date'].text =
                  PortfolioDepositData[i]['depositData']['maturity_date'];

              bank_id = PortfolioDepositData[i]['depositData']['bank_id'];
              ;
              auto_renew = PortfolioDepositData[i]['depositData']['auto_renew'];
              if (auto_renew == "1") {
                value_auto_renew = true;
              } else {
                value_auto_renew = false;
              }
            }
          });
        }
      }
    }

    Future.delayed(Duration.zero).then((value) {
      widget.viewDeposit ?? false ? _depositFormBottomSheet(context) : false;
    });
  }

  @override
  void dispose() {
    super.dispose();
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
      customAlertBox(
          context: context,
          type: "error",
          title: "Error!",
          description: "Portfolio with same name already exists",
          buttons: null);
      return;
    }

    if (widget.action == "split") {
      //
      Map newPortfolioData = new Map.from(
          widget.model.userPortfoliosData[widget.portfolioMasterID]);

      bool isDepositPortfolio = false;

      var portfolio = widget.model.userPortfoliosData[widget.portfolioMasterID];

      if (portfolio != null &&
          portfolio['portfolios'] != null &&
          portfolio['portfolios']['Deposit'] != null) {
        isDepositPortfolio = true;
      }
      newPortfolioData['portfolio_name'] = _controller['portfolio_name'].text;

      setState(() {
        widget.model.setLoader(true);
      });
      Map<String, dynamic> responseData =
          await widget.model.updateCustomerPortfolioData(
        portfolios: newPortfolioData['portfolios'],
        zone: newPortfolioData['portfolio_zone'],
        riskProfile: widget.model.newUserRiskProfile,
        portfolioMasterID: '0',
        portfolioName: _controller['portfolio_name'].text,
        depositPortfolio: isDepositPortfolio,
      );

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
        pageType = "add_instrument_new_portfolio";
        page = "add_instrument_new_portfolio";
      });
    }
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
          pageType = "add_instrument_new_portfolio";

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

  addInstrumentAction(RICs selectedRIC, {Map ricMap}) {
    if (selectedRIC == null) {
      selectedRIC = RICs(
          name: ricMap['name'],
          zone: ricMap['zone'],
          ric: ricMap['ric'],
          fundType: ricMap['type'],
          latestPriceBase: ricMap['latestPriceBase'],
          latestPriceString: ricMap['latestPriceString'],
          latestCurrencyPriceString: ricMap['latestCurrencyPriceString'],
          currency: ricMap['cf_curr']);
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
          customAlertBox(
              context: context,
              type: "error",
              title: "Error!",
              description: "Instrument already exists in portfolio",
              buttons: null);
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
          'latestCurrencyPriceString': selectedRIC.latestCurrencyPriceString,
          'currency': selectedRIC.currency,
        });
      });

      if (errorCode == 0) {
        if (widget.action == "newPortfolio") {
          bool popFlag = true;
          if (page == "fundList") popFlag = false;
          setState(() {
            page = 'add_instrument_new_portfolio';
            pageType = 'add_instrument_new_portfolio';
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

          updateUnitOption(value: unitOption);

          if (popFlag) Navigator.pop(context);
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
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildBodyPortfolio() {
    // return Container(
    //     child: Flex(direction: Axis.vertical,

    //         //shrinkWrap: true,
    //         children: <Widget>[
    //       Expanded(
    //           child: ListView(
    //         children: <Widget>[TextFormField()],
    //       )),
    //     ]));

    // return SingleChildScrollView(
    //   child: Container(
    //     child: Column(
    //       children: [
    //         Text(
    //           widget.action == "rename"
    //               ? "Portfolio Name"
    //               : "Add new portfolio",
    //           style: importPortfolioHeading,
    //         ),
    //         SizedBox(height: getScaledValue(3)),
    //         Text("Keep the name as something personal, or your goal....",
    //             style: bodyText1),
    //         SizedBox(height: getScaledValue(45)),
    //         TextFormField()
    //       ],
    //     ),
    //   ),
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.action == "rename"
                    ? "Portfolio Name"
                    : "Add new portfolio",
                style: importPortfolioHeading,
              ),
              SizedBox(height: getScaledValue(3)),
              Text("Keep the name as something personal, or your goal....",
                  style: bodyText1),
              SizedBox(height: getScaledValue(45)),
              Form(
                key: _addPortfolioForm,
                child: Expanded(
                    child: TextFormField(
                        focusNode: focusNodes['portfolio_name'],
                        controller: _controller['portfolio_name'],
                        validator: (value) {
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: 'Name your portfolio',
                            labelStyle: focusNodes['portfolio_name'].hasFocus
                                ? inputLabelFocusStyle
                                : inputLabelStyle),
                        keyboardType: TextInputType.text,
                        onChanged: (String value) {
                          setState(() {
                            widget.model.addPortfolioData['portfolio_name'] =
                                value;
                          });
                        },
                        style: inputFieldStyle)),
              ),
            ],
          ),
        )),
        //Text('Add/edit all transaction details right here', style: importPortfolioBody),
        SizedBox(height: getScaledValue(25)),
        gradientButton(
            context: context,
            caption: "Next",
            onPressFunction: () {
              if (widget.model.addPortfolioData['portfolio_name'] != null &&
                  widget.model.addPortfolioData['portfolio_name'] != "") {
                _analyticsNextButtonEvent();
                //     FocusScope.of(context).requestFocus(new FocusNode());
                addPortfolioAction();
              }
            })
      ],
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

  Widget _buildFundList() {
    return Container(
      child: ListView(
        children: [
          Text("Search Results", style: keyStatsBodyText4),
          Text(
              fundList.length.toString() +
                  " " +
                  fundTypeCaption(filterOptionSelection['type']) +
                  " shortlisted",
              style: keyStatsBodyText6),
          SizedBox(height: getScaledValue(10)),
          ...fundList
              .map((element) => fundBox(context, element,
                  onTap: () => addInstrumentAction(null, ricMap: element),
                  sortCaption: sortByCaption(),
                  sortWidget: filterOptionSelection.containsKey('sortby') &&
                          [
                            'overall_rating',
                            'tr_rating',
                            'alpha_rating',
                            'srri',
                            'tracking_rating'
                          ].contains(filterOptionSelection['sortby'])
                      ? svgImage("assets/icon/star_filled.svg")
                      : (filterOptionSelection['sortby'] == "tna"
                          ? Text('M')
                          : null)))
              .toList()
        ],
      ),
    );
  }

  Widget toolShortcut(String imgPath, String title, String description,
      {Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: widgetCard(
        leftMargin: 0,
        rightMargin: 0,
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
                Text(title, style: appBodyH3),
                Text(description,
                    style: appBodyText1.copyWith(color: Color(0xff707070)))
              ],
            )),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  searchPopup() {
    setState(() {
      page = "search";
    });
  }

  resetFilter() {
    _setState(() {
      filterOptionSelection = Map.from(filterOptionSelectionReset);
    });
  }

  applyFilter() async {
    Navigator.of(context).pop();
    setState(() {
      widget.model.setLoader(true);
    });
    // log.d(json.encode(filterOptionSelection));
    await _analyticsSortByEvent(filterOptionSelection.toString());
    Map responseData = await widget.model.fundScreener(filterOptionSelection);
    setState(() {
      if (responseData.isNotEmpty) {
        fundList = responseData['response'];
        page = "fundList";
      }

      widget.model.setLoader(false);
    });
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

  Widget sortRow(String caption, String orderby) {
    return GestureDetector(
      onTap: () {
        _setState(() {
          filterOptionSelection['sort_order'] = orderby;
        });
      },
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                  (orderby == "asc"
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  size: getScaledValue(20),
                  color: filterOptionSelection['sort_order'] == orderby
                      ? colorBlue
                      : colorDarkGrey),
              Text(caption,
                  style: bodyText1.copyWith(
                      fontSize: getScaledValue(11),
                      color: filterOptionSelection['sort_order'] == orderby
                          ? colorBlue
                          : colorDarkGrey))
            ],
          )
        ],
      ),
    );
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

  Widget filterOptionGroup(var optionGroup) {
    if (optionGroup['key'] == 'scores' &&
        ['stocks', 'bonds', 'commodity']
            .contains(filterOptionSelection['type'])) {
      return emptyWidget;
    }
    var start = 0.0;
    var end = 0.0;

    return Container(
        padding: EdgeInsets.only(bottom: getScaledValue(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            optionGroup['group_title'] != ""
                ? Text(optionGroup['group_title'].toUpperCase(),
                    style: tabLabel)
                : emptyWidget,
            optionGroup['group_title'] != ""
                ? SizedBox(height: getScaledValue(12))
                : emptyWidget,
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

                _currentRangeValues =
                    RangeValues(start.toDouble(), end.toDouble());
              }

              return Container(
                  //padding: EdgeInsets.only(bottom: getScaledValue(18)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    filterOptions[activeFilterOption]['optionType'] == "radio"
                        ? ListTileTheme(
                            contentPadding: EdgeInsets.all(0),
                            child: RadioListTile(
                              groupValue:
                                  filterOptionSelection[activeFilterOption],
                              title: filterOptionTextRow(entry.value),
                              value: entry.key,
                              onChanged: (value) =>
                                  filterOptionValueUpdate(value: entry.key),
                              activeColor: colorBlue,
                              dense: true,
                            ),
                          )
                        : filterOptions[activeFilterOption]['optionType'] ==
                                "checkbox"
                            ? ListTileTheme(
                                contentPadding: EdgeInsets.all(0),
                                child: CheckboxListTile(
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: filterOptionTextRow(entry.value),
                                  value: filterOptionSelection.containsKey(
                                              activeFilterOption) &&
                                          filterOptionSelection[
                                                  activeFilterOption]
                                              .contains(entry.key)
                                      ? true
                                      : false,
                                  // check from
                                  onChanged: (bool value) =>
                                      filterOptionValueUpdate(value: entry.key),
                                  activeColor: colorBlue,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.value['title'],
                                      style: bodyText1.copyWith(
                                          color: colorDarkGrey)),

                                  RangeSlider(
                                    values: _currentRangeValues,
                                    min: double.parse(entry.value['min']),
                                    max: double.parse(entry.value['max']),
                                    divisions: double.parse(entry.value['max'])
                                            .toInt() -
                                        double.parse(entry.value['min'])
                                            .toInt(),
                                    labels: RangeLabels(
                                      _currentRangeValues.start
                                          .round()
                                          .toString(),
                                      _currentRangeValues.end
                                          .round()
                                          .toString(),
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
                                  //   lowerValue: double.parse(
                                  //       filterOptionSelection
                                  //               .containsKey(optionGroup['key'])
                                  //           ? filterOptionSelection[
                                  //               optionGroup['key']]['min']
                                  //           : entry.value['min']),
                                  //   upperValue: double.parse(
                                  //       filterOptionSelection
                                  //               .containsKey(optionGroup['key'])
                                  //           ? filterOptionSelection[
                                  //               optionGroup['key']]['max']
                                  //           : entry.value['max']),
                                  //   divisions: double.parse(entry.value['max'])
                                  //           .toInt() -
                                  //       double.parse(entry.value['min'])
                                  //           .toInt(),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          filterOptionSelection.containsKey(
                                                  optionGroup['key'])
                                              ? filterOptionSelection[
                                                  optionGroup['key']]['min']
                                              : entry.value['min'],
                                          style: appBenchmarkReturnType2),
                                      Text(
                                          filterOptionSelection.containsKey(
                                                  optionGroup['key'])
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
        ));
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        sortRow('Low to High', 'asc'),
                        sortRow('High to Low', 'desc'),
                      ],
                    ),
                  )
                : emptyWidget,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...filterOptions[activeFilterOption]['optionGroups']
                  .map((optionGroup) => filterOptionGroup(optionGroup))
                  .toList()
            ])
          ],
        ));
  }

  filterPopup() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getScaledValue(14)),
          topRight: Radius.circular(getScaledValue(14)),
        )
            //
            ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return Container(
                color: Colors.white,
                width: double.infinity,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    200,
                margin: const EdgeInsets.only(bottom: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(16),
                          vertical: getScaledValue(16)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sort & Filter'.toUpperCase(),
                                style: appBodyH4),
                            GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child:
                                    Icon(Icons.close, color: Color(0xffa5a5a5)))
                          ]),
                    ),
                    divider(),
                    Expanded(
                        flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: filterOptions.entries
                                    .map((entry) => filterOptionWidget(entry))
                                    .toList(),
                              ),
                            ),
                            Expanded(child: filterOptionContainer()),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(13),
                          vertical: getScaledValue(13)),
                      child: Row(
                        children: [
                          Expanded(
                              child: flatButtonText('Reset',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: () => resetFilter())),
                          SizedBox(width: getScaledValue(10)),
                          Expanded(
                              child: gradientButton(
                                  context: context,
                                  caption: 'Apply',
                                  onPressFunction: () => applyFilter())),
                        ],
                      ),
                    )
                  ],
                ));
          });
        });
  }

  Future<List<RICs>> _getALlPosts(String search) async {
    List funds = await widget.model.getFundName(search, 'all');
    //await Future.delayed(Duration(seconds: 2));
    await _analyticsSearchAssetEvent(search);
    return List.generate(funds.length, (int index) {
      return RICs(
          ric: funds[index]['ric'],
          name: funds[index]['name'],
          zone: funds[index]['zone'],
          fundType: funds[index]['type'],
          latestPriceBase: funds[index]['latestPriceBase'],
          latestPriceString: funds[index]['latestPrice'],
          latestCurrencyPriceString: funds[index]['latestCurrencyPrice'],
          currency: funds[index]['cf_curr']);
    });
  }

  Widget _searchBox() {
    return SearchBar<RICs>(
      searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
      headerPadding: EdgeInsets.symmetric(horizontal: 10),
      listPadding: EdgeInsets.symmetric(horizontal: 10),
      minimumChars: 3,
      onSearch: _getALlPosts,
      //searchBarController: _searchBarController,
      /* placeHolder: Text("placeholder"),
			cancellationWidget: Text("Cancel"), */
      emptyWidget: Container(
          alignment: Alignment.center,
          child: Text('No record found',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: Color(0xff3c4257)))),

      onCancelled: () {
        log.i("Cancelled triggered");
      },
      shrinkWrap: true,
      mainAxisSpacing: 5,
      //crossAxisSpacing: 5, //
      crossAxisCount: 1,
      onItemFound: (RICs ric, int index) {
        Map element = {
          'ric': ric.ric,
          'name': ric.name,
          'type': ric.fundType,
          'zone': ric.zone,
          'latestPriceBase': ric.latestPriceBase,
          'latestPriceString': ric.latestPriceString,
          'latestCurrencyPriceString': ric.latestCurrencyPriceString,
          'currency': ric.currency
        };
        return fundBox(context, element, onTap: () async {
          // FocusScope.of(context).requestFocus(new FocusNode());
          addInstrumentAction(ric);
        });
      },
    );
  }

  Widget _smartSearchContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "To search for any asset, you can either type the name in full (for ex: Reliance Industries), or use our Smart Search feature. Smart Search makes it faster and more efficient for you to access your favorite stocks, ETFs, or mutual funds\n"),
        Text(
            "To use Smart Search, before you type the name that you are looking to search, just type in one of the letters shown below followed by a space:\n"),
        Text("'s' - to search for stocks (ex: 's nippon')"),
        Text("'e' - to search for ETFs (ex: 'e nippon')"),
        Text("'f' - to search for Mutual Funds (ex: 'f nippon')"),
      ],
    );
  }

  Widget _buildBodySearch() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
            child: Row(children: [
              Text("Enter Fund name", style: keyStatsBodyText4),
              SizedBox(width: getScaledValue(5)),
              InkWell(
                onTap: () => bottomAlertBox(
                    context: context,
                    title: "Smart Search",
                    childContent: _smartSearchContainer()),
                child: svgImage('assets/icon/information.svg',
                    width: getScaledValue(14)),
              )
            ])),
        Expanded(child: _searchBox()),
      ],
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return Column(
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.only(
                      top: getScaledValue(25), right: getScaledValue(10)),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close),
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
                  child: Row(children: [
                    Text("Enter Instrument name", style: keyStatsBodyText4),
                    SizedBox(width: getScaledValue(5)),
                    InkWell(
                      onTap: () => bottomAlertBox(
                          context: context,
                          title: "Smart Search",
                          childContent: _smartSearchContainer()),
                      child: svgImage('assets/icon/information.svg',
                          width: getScaledValue(14)),
                    )
                  ])),
              SizedBox(height: 20),
              Expanded(child: _searchBox()),
            ],
          );
        });
  }

  void _depositFormBottomSheet(context) {
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
          _setState = setState;
          return depositFormWidget(
              portfolioMasterId: widget.portfolioDepositID);
        });
      },
    );
  }

  int portfolioCount({portfolioMasterID = "0", bool checkWeight = false}) {
    if (widget.model.userPortfoliosData == null ||
        widget.model.userPortfoliosData[portfolioMasterID] == null ||
        widget.model.userPortfoliosData[portfolioMasterID]['portfolios'] ==
            null) {
      return 0;
    }
    int count = 0;
    bool returnCount = true;
    if (widget
            .model.userPortfoliosData[portfolioMasterID]['portfolios'].length >
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

    return Container(
      margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xffe8e8e8),
          width: getScaledValue(1),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(
        getScaledValue(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bankName, style: body_text2_dashboardPerfomer),
                  Text(display_name, style: portfolioBoxName),
                ],
              ),
              PopupMenuButton(
                onSelected: (value) async {
                  // log.d(index);

                  // var zone = "";

                  for (var i = 0;
                      i < depositPortfolioList['Deposit'].length;
                      i++) {
                    if (index == i) {
                      // zone = depositPortfolioList['Deposit'][i]['zone'];
                      deposit_arrays.removeAt(i);
                      // depositPortfolioList['Deposit']
                      //     .removeWhere((item) => item['zone'] == zone);
                    }
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text("Delete"),
                      value: "Delete",
                    )
                  ];
                },
              ),
            ],
          ), //
          SizedBox(height: 16),
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

          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount", style: transactionBoxLabel),
                  SizedBox(height: 2),
                  Text(portfolio_dep_amount, style: transactionBoxDetail),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Annual Interest Rate", style: transactionBoxLabel),
                  SizedBox(height: 2),
                  Text('$portfolio_dep_rate%($portfolio_dep_freq)',
                      style: transactionBoxDetail),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Maturity", style: transactionBoxLabel),
                  SizedBox(height: 2),
                  Text(maturity_date, style: transactionBoxDetail),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget portfolioFundBox(Map portfolio, int index) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border.all(color: Color(0xffe8e8e8), width: getScaledValue(1)),
            borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(getScaledValue(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(limitChar(portfolio['name'], length: 25),
                      style: portfolioBoxName),
                  SizedBox(height: getScaledValue(5)),
                  Row(
                    children: <Widget>[
                      widgetBubble(
                          title: portfolio['type'] != null
                              ? portfolio['type'].toUpperCase()
                              : "",
                          leftMargin: 0,
                          textColor: Color(0xffa7a7a7)),
                      SizedBox(width: getScaledValue(7)),
                      widgetZoneFlag(portfolio['zone']),
                    ],
                  ),
                  SizedBox(height: getScaledValue(8)),
                  GestureDetector(
                    onTap: () => setState(() {
                      widget
                          .model
                          .userPortfoliosData['0']['portfolios']
                              [portfolio['type']]
                          .removeAt(index);
                      updateUnitOption(value: unitOption);
                      /* if(widget.model.userPortfoliosData['0']['portfolios'][portfolio['type']].length == 0){
											widget.model.userPortfoliosData['0']['portfolios'].removeAt(portfolio['type']);
										} */
                    }),
                    child: Text("remove", style: textLink1),
                  ),
                ],
              ),
            ),
            SizedBox(height: getScaledValue(15)),
            SizedBox(
              width: getScaledValue(70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      portfolio['type'].toLowerCase() == "commodity"
                          ? "grams"
                          : "units",
                      style: bodyText4),
                  SizedBox(height: getScaledValue(3)),
                  TextField(
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(0),
                          labelStyle: focusNodesUnits[portfolio['ric']].hasFocus
                              ? inputLabelFocusStyle.copyWith(
                                  color: Color(0xff8e8e8e))
                              : inputLabelStyle.copyWith(
                                  color: Color(0xff8e8e8e))),
                      focusNode: focusNodesUnits[portfolio['ric']],
                      controller: _controllerUnits[portfolio['ric']],
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (String value) {
                        if (value.trim() == "" || value.trim() == ".") {
                          value = "0";
                        }
                        setState(() {
                          widget.model.userPortfoliosData['0']['portfolios']
                              [portfolio['type']][index]['weightage'] = value;
                          widget.model.userPortfoliosData['0']['portfolios']
                              [portfolio['type']][index]['transactions'][0] = {
                            "ric": portfolio['ric'],
                            "holding": value,
                            "type": "buy",
                            "price": "",
                            "date": ""
                          };
                        });
                      },
                      style: inputFieldStyle),
                  SizedBox(height: getScaledValue(10)),
                  Text(portfolio['latestCurrencyPriceString'] ?? "",
                      style: bodyText4),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _portfolioList() {
    if (widget.model.userPortfoliosData == null ||
        widget.model.userPortfoliosData['0'] == null ||
        widget.model.userPortfoliosData['0']['portfolios'] == null) {
      return Container();
    }
    List<Widget> _children = [];
    _children.add(emptyWidget);

    if (depositPortfolio) {
      if (depositPortfolioList.length > 0) {
        for (var i = 0; i < depositPortfolioList['Deposit'].length; i++) {
          var items = depositPortfolioList['Deposit'];
          // var display_name = display_arrays[i];
          _children.add(
              depositPortfolio ? portfolioDepositHoldingBox(items, i) : null);
        }
      }
    } else {
      if (widget.model.userPortfoliosData['0']['portfolios'].length > 0) {
        widget.model.userPortfoliosData['0']['portfolios']
            .forEach((fundType, portfolios) {
          portfolios.asMap().forEach((index, portfolio) =>
              _children.add(portfolioFundBox(portfolio, index)));
        });
      }
    }
    return Column(
      children: _children,
    );
  }

  Widget _buildNewPortfolio() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Text("New Portfolio", style: headline2),
                Text(_controller['portfolio_name'].text, style: headline1),
                SizedBox(height: getScaledValue(16)),
                portfolioCount() > 0
                    ? emptyWidget
                    : Text(
                        "Add one or more holdings under this portfolio from a selection of stocks, bonds, mutual funds and ETFs, or add one or more deposits that you have  ",
                        style: bodyText4),
                SizedBox(height: getScaledValue(10)),
                depositPortfolio
                    ? Container(
                        height: 40,
                        child: TextButton(
                          child: Text('+ Add a new deposit'),
                          style: TextButton.styleFrom(
                            primary: Color(0xff034bd9),
                            onSurface: Colors.white,
                            side:
                                BorderSide(color: Color(0xff034bd9), width: 1),
                          ),
                          onPressed: () => _depositFormBottomSheet(context),
                        ))
                    : InkWell(
                        onTap: () {
                          setState(() {
                            page = "add_instrument";
                          });
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                                prefixIcon:
                                    Icon(Icons.search, color: colorBlue),
                                labelText: 'Search assets or add deposits',
                                labelStyle:
                                    inputLabelStyle.copyWith(color: colorBlue),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: colorBlue),
                                ),
                                border: new UnderlineInputBorder(
                                  borderSide: BorderSide(color: colorBlue),
                                ),
                              ),
                              style: inputFieldStyle),
                        ),
                      ),
                depositPortfolio
                    ? emptyWidget
                    : SizedBox(
                        height: getScaledValue(40),
                      ),
                depositPortfolio ? emptyWidget : _unitOptions(),
                SizedBox(height: getScaledValue(10)),
                _portfolioList()
              ],
            ),
          ),
          SizedBox(height: getScaledValue(10)),
          depositPortfolio
              ? emptyWidget
              : portfolioCount() > 0
                  ? (portfolioCount(checkWeight: true) == 0
                      ? Text(
                          "Holdings cannot have 0 units",
                          style: inputError2,
                          textAlign: TextAlign.center,
                        )
                      : emptyWidget)
                  : emptyWidget,
          SizedBox(height: getScaledValue(5)),
          gradientButton(
            context: context,
            caption: "Create Portfolio",
            buttonDisabled: depositPortfolio
                ? false
                : portfolioCount(checkWeight: true) == 0
                    ? true
                    : false,
            onPressFunction: () async {
              setState(() {
                widget.model.setLoader(true);
              });
              Map<String, dynamic> responseData =
                  await widget.model.updateCustomerPortfolioData(
                portfolios: widget.model.userPortfoliosData['0']['portfolios'],
                portfolioMasterID: '0',
                portfolioName: widget.model.userPortfoliosData['0']
                    ['portfolio_name'],
                depositPortfolio: depositPortfolio,
              );

              if (responseData['status'] == true) {
                await _analyticsCreatePortfolioEvent(
                    widget.model.userPortfoliosData['0']['portfolio_name']);
                Navigator.pushReplacementNamed(
                  context,
                  '/success_page',
                  arguments: {
                    'type': 'newPortfolio',
                    'portfolio_name': widget.model.userPortfoliosData['0']
                        ['portfolio_name'],
                    'portfolioMasterID': responseData['portfolioMasterID'],
                    'action': 'newPortfolio'
                  },
                );
              }
              setState(() {
                widget.model.setLoader(false);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _unitOptions() {
    if (portfolioCount() < 2) {
      return emptyWidget;
    }
    return Container(
        child: Column(
      children: [
        Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Row(
              children: [
                Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: unitOption,
                      value: "equal_weights",
                      onChanged: (value) => updateUnitOption(value: value),
                      activeColor: colorBlue,
                    ),
                    Text("Equal Weights",
                        style: bodyText4.copyWith(
                            color: unitOption == "equal_weights"
                                ? colorBlue
                                : null))
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: unitOption,
                      value: "equal_units",
                      onChanged: (value) => updateUnitOption(value: value),
                      activeColor: colorBlue,
                    ),
                    Text("Equal Units",
                        style: bodyText4.copyWith(
                            color:
                                unitOption == "equal_units" ? colorBlue : null))
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: unitOption,
                      value: "custom",
                      onChanged: (value) => updateUnitOption(value: value),
                      activeColor: colorBlue,
                    ),
                    Text("Custom",
                        style: bodyText4.copyWith(
                            color: unitOption == "custom" ? colorBlue : null))
                  ],
                ),
              ],
            )),
            InkWell(
              onTap: () {
                bottomAlertBox(
                  context: context,
                  title: 'Allocation preference',
                  description:
                      'Equal Weights: Allocate an equal amount to each asset in the portfolio. The units will be calculated for each asset, such that the amount remains the same. \n\nEqual Units: Allocate equal number of units to each asset in the portfolio.\n\nCustom: Define your own unit allocation across assets',
                );
              },
              child: svgImage(
                "assets/icon/information.svg",
                width: getScaledValue(12),
              ),
            ),
          ],
        ),
        ['equal_units', 'equal_weights'].contains(unitOption)
            ? Form(
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
                        labelText: 'Portfolio Amount (in ' +
                            (widget.model.userSettings['currency'] != null
                                    ? widget.model.userSettings['currency']
                                    : "inr")
                                .toUpperCase() +
                            ')',
                        labelStyle: focusNodes['portfolio_amount'].hasFocus
                            ? inputLabelFocusStyle
                            : inputLabelStyle),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (String value) {
                      setState(() {
                        portfolioAmount = num.parse(value);
                      });
                      updateUnitOption(value: unitOption);
                    },
                    style: inputFieldStyle),
              )
            : emptyWidget
      ],
    ));
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

//
  Widget _buildBodyMain() {
    _analyticsNewAssetCurrentScreen();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add new assets", style: headline1),
          SizedBox(height: getScaledValue(4)),
          Text(
              "Add stocks, bonds, funds or ETFs for the country you have access to, or add fixed/recurring deposits that you have",
              style: bodyText4),
          SizedBox(height: getScaledValue(21)),
          toolShortcut("assets/icon/search.svg", "Search",
              "Search across Mutual funds, ETFs, stocks, and bonds across multiple countries. Use our smart search feature to make it fast",
              onTap: () => _settingModalBottomSheet(context)),
          toolShortcut("assets/icon/filter.svg", "Sort & Filter",
              "Shortlist assets using one or more criteria. Add those that fit your yardstick",
              onTap: filterPopup),
          widget.viewDeposit != null
              ? widget.viewDeposit
                  ? emptyWidget
                  : emptyWidget
              : toolShortcutDesposit(
                  "assets/icon/deposit.svg",
                  "Add new Deposits",
                  "Add fixed or recurring deposits that you have in your bank, post office, or any other financial institution",
                  onTap: () => _depositFormBottomSheet(context))
        ],
      ),
    );
  }

  Widget mainContainerChild() {
    if (widget.model.isLoading) {
      return preLoader();
    } else if (pageType == "add_portfolio") {
      return _buildBodyPortfolio();
    } else if (page == "add_instrument_new_portfolio" &&
        pageType == "add_instrument_new_portfolio") {
      return _buildNewPortfolio();
    } else if (page == "search") {
      return _buildBodySearch();
    } else if (page == "fundList") {
      return _buildFundList();
    } else {
      // add_instrument
      return _buildBodyMain();
    }
  }

  Widget toolShortcutDesposit(String imgPath, String title, String description,
      {Function onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: widgetCard(
            leftMargin: 0,
            rightMargin: 0,
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
                      Text(title, style: appBodyH3),
                      Text(description,
                          style:
                              appBodyText1.copyWith(color: Color(0xff707070)))
                    ],
                  )),
                  Icon(Icons.chevron_right),
                ])));
  }

  // Widget _buildBodyDeposit() {
  //   return Form(
  //       key: _addDepositForm,
  //       child: Container(
  //           child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           SizedBox(height: getScaledValue(40)),

  //           Container(
  //             padding: EdgeInsets.only(right: 16),
  //             child: Align(
  //               alignment: Alignment.bottomRight,
  //               child: GestureDetector(
  //                   onTap: () => {
  //                         _setState(() {
  //                           _selectedTypeAcc = null;
  //                           _selectedCurrency = null;
  //                           _controller['display_name'].text = "";
  //                           _controller['bank_name'].text = "";
  //                           _controller['amount'].text = "";
  //                           _controller['interest'].text = "";
  //                           _controller['start_date'].text = "";
  //                           _controller['end_date'].text = "";
  //                           _selectedFrequency = null;
  //                           _selectedDeposit = null;

  //                           bank_id = "";
  //                           auto_renew = "";
  //                         }),
  //                         Navigator.pop(context),
  //                         Navigator.pop(context),
  //                       },
  //                   child: Icon(Icons.close, color: Color(0xffa5a5a5))),
  //             ),
  //           ),

  //           SizedBox(height: getScaledValue(16)),

  //           Expanded(
  //               child: SingleChildScrollView(
  //             child: Container(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     padding:
  //                         EdgeInsets.symmetric(horizontal: getScaledValue(16)),
  //                     child: Text(
  //                       widget.portfolioDepositID != null
  //                           ? "Edit Deposit"
  //                           : "Add new Deposit",
  //                       style: headline1,
  //                     ),
  //                   ),
  //                   SizedBox(height: 30),
  //                   _depositForm(),
  //                   SizedBox(
  //                     height: getScaledValue(8),
  //                     child: Container(
  //                       color: Color(0xffecf1fa),
  //                     ),
  //                   ),
  //                   SizedBox(height: getScaledValue(24)),
  //                   Container(
  //                     padding:
  //                         EdgeInsets.symmetric(horizontal: getScaledValue(16)),
  //                     child: Text(
  //                       "Other Details",
  //                       style: headline5_analyse,
  //                     ),
  //                   ),
  //                   SizedBox(height: getScaledValue(26)),
  //                   _depositForm_depositOtherDetails(),
  //                   SizedBox(height: getScaledValue(24)),
  //                   Container(
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Checkbox(
  //                           activeColor: Color(0xffcedfff),
  //                           checkColor: Color(0xff034bd9),
  //                           value: this.value_auto_renew,
  //                           onChanged: (bool value) {
  //                             _setState(() {
  //                               this.value_auto_renew = value;
  //                               if (value == false) {
  //                                 auto_renew = "0";
  //                               } else {
  //                                 auto_renew = "1";
  //                               }
  //                               // log.d("auto_renew$auto_renew");
  //                             });
  //                           },
  //                         ),
  //                         SizedBox(width: getScaledValue(8)),
  //                         Container(
  //                             child: Row(
  //                           children: [
  //                             Text(
  //                               "Auto-renew",
  //                               style: bodyText0_dashboard,
  //                             ),
  //                             GestureDetector(
  //                                 onTap: () => bottomAlertBox(
  //                                       context: context,
  //                                       title: 'Auto-renew',
  //                                       description:
  //                                           "This deposit will be auto renewed in your portfolio for the same tenor and interest rate on maturity, if this option is selected",
  //                                     ),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.only(left: 6.0),
  //                                   child: svgImage(
  //                                     "assets/icon/information.svg",
  //                                     color: AppColor.colorBlue,
  //                                     height: 16,
  //                                     width: 12,
  //                                   ),
  //                                 )),
  //                           ],
  //                         )),
  //                       ],
  //                     ),
  //                   ),
  //                   SizedBox(height: getScaledValue(24)),
  //                   Container(
  //                       padding: EdgeInsets.symmetric(
  //                           horizontal: getScaledValue(16)),
  //                       child: gradientButton(
  //                           context: context,
  //                           caption: widget.portfolioDepositID != null
  //                               ? "Save"
  //                               : "Add",
  //                           onPressFunction: () => addDepositValue())),
  //                   SizedBox(height: getScaledValue(24)),
  //                 ],
  //               ),
  //             ),
  //           )),
  //           // _registerCountryForm(),
  //           //	Expanded(child: _searchBox()),
  //         ],
  //       )));
  // }

  // Widget _depositForm() {
  //   return Container(
  //       padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
  //       //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
  //       child: Column(
  //           // direction: Axis.vertical,//
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             _depositForm_type_of_deposit_acc(),
  //             SizedBox(height: getScaledValue(4)),
  //             TextFormField(
  //                 focusNode: focusNodes['display_name'],
  //                 controller: _controller['display_name'],
  //                 validator: (value) {
  //                   if (value.isEmpty) {
  //                     return "Enter the display name";
  //                   }
  //                   return null;
  //                 },
  //                 decoration: InputDecoration(
  //                     labelText: 'Display Name',
  //                     labelStyle: focusNodes['display_name'].hasFocus
  //                         ? inputLabelFocusStyleDep
  //                         : inputLabelStyleDep),
  //                 keyboardType: TextInputType.text,
  //                 textInputAction: TextInputAction.next,
  //                 onChanged: (String value) {},
  //                 onFieldSubmitted: (term) {
  //                   _setState(() {
  //                     _fieldFocusChange(context, focusNodes['display_name'],
  //                         focusNodes['bank_name']);
  //                   });
  //                 },
  //                 style: inputFieldStyleDep),
  //             SizedBox(height: getScaledValue(14)),
  //             _depositForm_bankNameTextfield(),
  //             SizedBox(height: getScaledValue(26)),
  //             _depositForm_deposit_type(),
  //             SizedBox(height: getScaledValue(14)),
  //           ]));
  // }

  Widget depositFormWidget({String portfolioMasterId = null}) {
    // Map PortfolioData = {};
    // if (portfolioMasterId != null) {
    //   PortfolioData =
    //       new Map.from(widget.model.userPortfoliosData[portfolioMasterId]);
    // }
    var onTapFormClose = () => {
          _setState(() {
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
          }),
          Navigator.pop(context),
        };
    return Form(
      key: _addDepositForm,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: getScaledValue(40)),
            Container(
              padding: EdgeInsets.only(right: 16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                    onTap: onTapFormClose,
                    child: Icon(Icons.close, color: Color(0xffa5a5a5))),
              ),
            ),
            SizedBox(height: getScaledValue(16)),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: getScaledValue(16)),
                        child: Text(
                          portfolioMasterId != null
                              ? "Edit Deposit"
                              : "Add new Deposit",
                          style: headline1,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: getScaledValue(16)),
                        //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                        child: Column(
                          // direction: Axis.vertical,//
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _depositForm_type_of_deposit_acc(),
                            SizedBox(height: getScaledValue(4)),
                            _depositForm_display_name(),
                            SizedBox(height: getScaledValue(14)),
                            _depositForm_bankNameTextfield(),
                            SizedBox(height: getScaledValue(26)),
                            _depositForm_deposit_type(),
                            SizedBox(height: getScaledValue(14)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: getScaledValue(8),
                        child: Container(
                          color: Color(0xffecf1fa),
                        ),
                      ),
                      SizedBox(height: getScaledValue(24)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(16),
                        ),
                        child: Text(
                          "Other Details",
                          style: headline5_analyse,
                        ),
                      ),
                      SizedBox(height: getScaledValue(26)),
                      _depositForm_depositOtherDetails(),
                      SizedBox(height: getScaledValue(24)),
                      _depositForm_autorenew_checkbox(),
                      SizedBox(height: getScaledValue(24)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(16),
                        ),
                        child: gradientButton(
                          context: context,
                          caption: portfolioMasterId != null ? "Save" : "Add",
                          onPressFunction: () => addDepositValue(),
                        ),
                      ),
                      SizedBox(height: getScaledValue(24)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _depositForm_type_of_deposit_acc() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Type of Deposit", style: inputLabelStyleDep),
          DropdownButtonFormField<String>(
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
            validator: (value) =>
                value == null ? 'Select type of deposit' : null,
            onChanged: (widget.portfolioDepositID != null)
                ? null
                : (value) {
                    _selectedTypeAcc = value;
                  },
          ),
        ],
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
              InkWell(
                  onTap: () => bottomAlertBox(
                        context: context,
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
                  )),
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
              FocusScope.of(context).requestFocus(FocusNode());
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
                  borderRadius: BorderRadius.circular(4.0)),
              child: SearchBankName(widget.model),
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

  Widget _depositForm_depositOtherDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
      //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Column(
        //direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _depositForm_deposit_amount(),
          SizedBox(height: getScaledValue(26)),
          _depositForm_currency_of_deposit(),
          SizedBox(height: getScaledValue(4)),
          _depositForm_interest_rate(),
          SizedBox(height: getScaledValue(26)),
          _depositForm_frequency_deposit(),
          SizedBox(height: getScaledValue(14)),
          _depositForm_start_date(),
          SizedBox(height: getScaledValue(14)),
          _depositForm_end_date()
        ],
      ),
    );
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
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Currency of deposit", style: inputLabelStyleDep),
          DropdownButtonFormField<String>(
            //focusNode: focusNodes['interest'],
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
              FocusScope.of(context).requestFocus(FocusNode());
              _selectedCurrency = value;
            },
          ),
        ],
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Interest compounding frequency", style: inputLabelStyleDep),
              InkWell(
                  onTap: () => bottomAlertBox(
                        context: context,
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
            ],
          ),
          DropdownButtonFormField<String>(
            //focusNode: focusNodes['frequency'],
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
              FocusScope.of(context).requestFocus(FocusNode());
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
            FocusScope.of(context).requestFocus(FocusNode());
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
            FocusScope.of(context).requestFocus(FocusNode());
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
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            activeColor: Color(0xffcedfff),
            checkColor: Color(0xff034bd9),
            value: this.value_auto_renew,
            onChanged: (bool value) {
              _setState(() {
                this.value_auto_renew = value;
                if (value == false) {
                  auto_renew = "0";
                } else {
                  auto_renew = "1";
                }
                // log.d("auto_renew$auto_renew");
              });
            },
          ),
          SizedBox(width: getScaledValue(8)),
          Container(
              child: Row(
            children: [
              Text(
                "Auto-renew",
                style: bodyText0_dashboard,
              ),
              InkWell(
                  onTap: () => bottomAlertBox(
                        context: context,
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
                  )),
            ],
          )),
        ],
      ),
    );
  }

  // ignore: todo
// TODO : End small screen : shariyath

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      //return KeyboardSizeProvider(
      return Scaffold(
          //resizeToAvoidBottomInset: false,
          //key: myGlobals.scaffoldKey,
          /* drawer: WidgetDrawer(), */
          appBar: commonScrollAppBar(
              controller: controller,
              bgColor: Colors.white,
              leading: page == "add_instrument" &&
                      pageType == "add_instrument_new_portfolio"
                  ? emptyWidget
                  : page == "add_instrument_new_portfolio" &&
                          pageType == "add_instrument_new_portfolio"
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              pageType = "add_portfolio";
                              widget.action = "newPortfolio";
                              page = "main";
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.only(),
                              child: Icon(Icons.arrow_back)),
                        )
                      : null,
              actions: [
                page == "add_instrument" &&
                        pageType == "add_instrument_new_portfolio"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            page = "add_instrument_new_portfolio";
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: getScaledValue(16)),
                            child: Icon(Icons.close)),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, widget.model.redirectBase),
                        child: AppbarHomeButton())
              ]),
          body: page == "deposit" //
              ? mainContainer(
                  context: context,
                  containerColor: Colors.white,
                  child: mainContainerChild() //_buildBodyInstrument()
                  )
              : mainContainer(
                  context: context,
                  paddingLeft: getScaledValue(16),
                  paddingRight: getScaledValue(16),
                  containerColor: Colors.white,
                  child: mainContainerChild() //_buildBodyInstrument()
                  ));
    });
  }
}

MyGlobals myGlobals = new MyGlobals();

@override
Widget build(BuildContext context) {
  throw UnimplementedError();
}

class MyGlobals {
  GlobalKey _scaffoldKey;

  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }

  GlobalKey get scaffoldKey => _scaffoldKey;
}
