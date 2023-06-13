import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:qfinr/main.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio/add_portfolio_styles.dart';
import 'package:qfinr/pages/add_portfolio_mannually/serach_and_filter_options.dart';
import 'package:qfinr/pages/manage_portfolio/large_portfolio_chart.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_portfolio_helper.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_widget_common.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/add_deposit_large.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('ManagePortfolio');

class LargeManagePortfolio extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  bool managePortfolio;
  bool reloadData;

  bool newPortfolio;
  String portfolioName;

  String portfolioMasterID;

  bool viewPortfolio;
  bool readOnly;

  LargeManagePortfolio(this.model,
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
    return _LargeManagePortfolioState();
  }
}

class _LargeManagePortfolioState extends State<LargeManagePortfolio> {
  String currencyValues;
  var currentTabIndex = 0;
  String sortType;
  String sortOrder = "asc";
  final GlobalKey<ScaffoldState> _largeScaffoldKey = GlobalKey<ScaffoldState>();
  String sortByText = "";

  RangeValues _currentRangeValues;
  final controller = ScrollController();

  Map portfolioMasterData = {};

  bool _ricSelected = false;

//------------------------------------------------------------------------------------------
  RICs selectedRICs;
  TextEditingController _popupSearchFieldController = TextEditingController();
  List<RICs> searchList = [];
  Map filterOptions = SerachAndFilterOptions.filterOptions;
  Map filterOptionSelection = SerachAndFilterOptions.filterOptionSelection;
  String activeFilterOption = 'sortby';
  Map filterOptionSelectionReset;
  List fundList;
  Map categoryOptions = SerachAndFilterOptions.categoryOptions;

//------------------------------------------------------------------------------------------

  String pathPDF = "";

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

  StateSetter _setState;

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

    filterOptionSelectionReset = Map.from(filterOptionSelection);

    if (widget.portfolioMasterID == '0') {
      widget.model.defaultPortfolioSelectorKey = widget.portfolioMasterID;
      widget.model.defaultPortfolioSelectorValue = widget.model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
          ['portfolio_name'];
    } else {
      portfolioMasterData =
          widget.model.userPortfoliosData[widget.portfolioMasterID];
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
    setState(() {});
  }

  // void filterPopup() {
  //   customAlertBox(
  //     context: context,
  //     childContent: StatefulBuilder(
  //       builder: (BuildContext context, StateSetter setState) {
  //         _setState = setState;
  //         return Container(
  //           width: double.maxFinite,
  //           height: double.maxFinite < getScaledValue(365)
  //               ? double.maxFinite
  //               : null, // double.maxFinite,
  //           child: Form(
  //               child: ListView(
  //             shrinkWrap: true,
  //             children: <Widget>[
  //               Row(
  //                 children: <Widget>[
  //                   Expanded(
  //                       child: DropdownButton<String>(
  //                     hint: Text('Currency'),
  //                     isExpanded: true,
  //                     value: _selectedCurrency,
  //                     items: widget.model.currencies.map((Map item) {
  //                       return DropdownMenuItem<String>(
  //                         value: item['key'],
  //                         child: Text(item['value'] ?? ''),
  //                       );
  //                     }).toList(),
  //                     onChanged: (value) {
  //                       _setState(() {
  //                         _selectedCurrency = value;
  //                       });
  //                       _setSaveButtonColorChangeState(() {});
  //                     },
  //                   )),
  //                 ],
  //               ),
  //             ],
  //           )),
  //         );
  //       },
  //     ),
  //     buttons: <Widget>[
  //       TextButton(
  //         child: Text("Cancel", style: dialogBoxActionInactive),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //       TextButton(
  //         child: StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setState) {
  //           _setSaveButtonColorChangeState = setState;
  //           return Text("Save",
  //               style: _selectedCurrency != null
  //                   ? dialogBoxActionActive
  //                   : dialogBoxActionInactive);
  //         }),
  //         onPressed: () async {
  //           if (_selectedCurrency != null) {
  //             widget.model.setLoader(true);
  //             Map<String, dynamic> responseData =
  //                 await widget.model.changeCurrency(_selectedCurrency);
  //             if (responseData['status'] == true) {
  //               Navigator.of(context).pop();
  //               await widget.model.fetchOtherData();
  //               widget.model.setLoader(false);
  //               refreshParent();
  //             }
  //           }
  //         },
  //       )
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
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
    // ScreenUtil.init(context,
    //     designSize: Size(360, 640), allowFontScaling: true);
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
    return PageWrapper(
      child: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          key: _largeScaffoldKey,
          //key: myGlobals.scaffoldKey,
          drawer: WidgetDrawer(),
          body: _buildBody(popupMenu),
        );
      }),
    );
  }

  Widget _buildBody(List popupMenu) {
    return _buildBodyForWeb(popupMenu);
  }

  _showAddDepositBottonsheet() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: AddDepositLarge(
              widget.model,
              widget.portfolioMasterID,
              null,
            ),
          );
        });
      },
    ).then((value) {
      Future.delayed(Duration(seconds: 1)).then((value) => refreshParent());
    });
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

  confirmDeleteForWeb() {
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
                      "This will delete the entire portfolio. Are you sure you want to proceed?",
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
                                  // Navigator.of(context).pop(true);
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  widget.model.setLoader(true);
                                  Map<String, dynamic> responseData =
                                      await widget.model.removePortfolioMaster(
                                          widget.portfolioMasterID);
                                  widget.model.setLoader(false);
                                  if (responseData['status'] == true) {
                                    Navigator.pushReplacementNamed(context,
                                            '/manage_portfolio_master_view')
                                        .then((_) => refreshParent());
                                  }
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

  // confirmDelete() {
  //   return customAlertBox(
  //     context: context,
  //     title: "Confirm Delete!",
  //     description:
  //         "This will delete the entire portfolio. Are you sure you want to proceed?",
  //     buttons: [
  //       flatButtonText("No",
  //           borderColor: colorBlue,
  //           onPressFunction: () => Navigator.of(context).pop(false)),
  //       gradientButton(
  //         context: context,
  //         caption: "Yes",
  //         onPressFunction: () async {
  //           Navigator.of(context).pop(true);
  //           widget.model.setLoader(true);
  //           Map<String, dynamic> responseData = await widget.model
  //               .removePortfolioMaster(widget.portfolioMasterID);

  //           if (responseData['status'] == true) {
  //             Navigator.pushReplacementNamed(
  //                     context, '/manage_portfolio_master_view')
  //                 .then((_) => refreshParent());
  //           }
  //           widget.model.setLoader(false);
  //         },
  //       ),
  //     ],
  //   );
  // }

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
          sortByText = optionRow['title'];
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

  ///////////////////////////////////////

  Widget _buildBodyForWeb(List popupMenu) {
    return _buildBodyForPlatforms(popupMenu);
  }

  Widget _buildBodyForPlatforms(List popupMenu) {
    return _largeScreenBody(popupMenu);
  }

  Widget _largeScreenBody(List popupMenu) => Column(
        children: [
          _buildTopBar(),
          _bodyContents(popupMenu), // left side
        ],
      );

  Widget _buildTopBar() => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        child: NavigationTobBar(
          widget.model,
          openDrawer: () => _largeScaffoldKey.currentState.openDrawer(),
        ),
      );

  Widget _bodyContents(List popupMenu) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          deviceType == DeviceScreenType.tablet
              ? SizedBox()
              : NavigationLeftBar(
                  isSideMenuHeadingSelected: 1, isSideMenuSelected: 1),
          Expanded(child: _buildBodyContentForWeb(popupMenu)),
        ],
      ),
    );
  }

  Widget _buildBodyContentForWeb(List popupMenu) {
    if (widget.model.isLoading) {
      return preLoader();
    } else {
      currencyValues = widget.model.userSettings['currency'] != null
          ? widget.model.userSettings['currency']
          : null;
      List zones = portfolioMasterData['portfolio_zone'].split('_');
      return Container(
        height: MediaQuery.of(context).size.height,
        color: Color(0xfff5f6fa),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              //
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          "Portfolio > ${portfolioMasterData['portfolio_name']}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'nunito',
                            letterSpacing: 0.40,
                            color: Color(0xff8e8e8e),
                          )),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      // width: MediaQuery.of(context).size.width * 0.15,
                      width: MediaQuery.of(context).size.width * 0.20,
                      // color: Colors.yellow,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 6.0, right: 6.0, bottom: 6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(portfolioMasterData['portfolio_name'],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'nunito',
                                    letterSpacing: 0.29,
                                    color: Color(0xff181818))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  portfolioMasterData['type'] == '1'
                                      ? widgetBubbleForWeb(
                                          title: 'LIVE',
                                          includeBorder: false,
                                          leftMargin: 0,
                                          bgColor: Color(0xffe9f4ff),
                                          textColor: Color(0xff708bc1))
                                      : widgetBubbleForWeb(
                                          title: 'WATCHLIST',
                                          includeBorder: false,
                                          leftMargin: 0,
                                          bgColor: Color(0xffffece3),
                                          textColor: Color(0xffbc9f91)),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Container(
                                      color: Color(0xffeaeaea),
                                      width: 2,
                                      height: 15,
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                          children: zones
                                              .map((item) => Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10.0, left: 10.0),
                                                  child: widgetZoneFlagForWeb(
                                                      item)))
                                              .toList())),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          (portfolioMasterData != null &&
                                  portfolioMasterData['portfolios'] != null &&
                                  portfolioMasterData['portfolios']
                                          ['Deposit'] ==
                                      null)
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                      width: 175,
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        padding: EdgeInsets.all(0.0),
                                        child: Ink(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 33,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xff0941cc),
                                                  Color(0xff0055fe)
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Container(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                minHeight: 50),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "ANALYZE",
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
                                          Navigator.pushNamed(
                                              context, '/benchmark_selector',
                                              arguments: {
                                                'selectedPortfolioMasterIDs': {
                                                  widget.portfolioMasterID: true
                                                }
                                              });
                                        },
                                      )),
                                )
                              : Container(),
                          _moreOptions(popupMenu),
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.only(left: 10.0, right: 10.0),
                          //   child: GestureDetector(
                          //     behavior: HitTestBehavior.opaque,
                          //     onTap: () {
                          //       showDialog(
                          //         context: context,
                          //         builder: (BuildContext context) {
                          //           return AlertDialog(
                          //             shape: RoundedRectangleBorder(
                          //               borderRadius:
                          //                   BorderRadius.circular(10.0),
                          //             ),
                          //             title: Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.end,
                          //               children: [
                          //                 GestureDetector(
                          //                   onTap: () => Navigator.pop(context),
                          //                   child: Icon(Icons.close,
                          //                       color: Color(0xffcccccc),
                          //                       size: 18),
                          //                 )
                          //               ],
                          //             ),
                          //             content: Container(
                          //               color: Colors.white,
                          //               height:
                          //                   MediaQuery.of(context).size.height *
                          //                       0.4,
                          //               child: SingleChildScrollView(
                          //                 child: Column(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.center,
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.start,
                          //                   children: [
                          //                     GestureDetector(
                          //                         onTap: () {
                          //                           Navigator.of(context).pop();
                          //                           togglePortfolioType();
                          //                         },
                          //                         child: Text(
                          //                             'Mark as ' +
                          //                                 (portfolioMasterData[
                          //                                             'type'] ==
                          //                                         "1"
                          //                                     ? "Watchlist"
                          //                                     : "Live"),
                          //                             style:
                          //                                 sortbyOptionHeading)),
                          //                     Divider(
                          //                       color: Color(0x251e1e1e),
                          //                       thickness: 1,
                          //                     ),
                          //                     SizedBox(
                          //                         height: getScaledValue(20)),
                          //                     GestureDetector(
                          //                         onTap: () {
                          //                           Navigator.pushNamed(context,
                          //                               '/split_portfolio_portfolio_name/split',
                          //                               arguments: {
                          //                                 'portfolioMasterID':
                          //                                     widget
                          //                                         .portfolioMasterID
                          //                               }).then(
                          //                               (_) => refreshParent());
                          //                         },
                          //                         child: Text(
                          //                             'Duplicate Portfolio',
                          //                             style:
                          //                                 sortbyOptionHeading)),
                          //                     Divider(
                          //                       color: Color(0x251e1e1e),
                          //                       thickness: 1,
                          //                     ),
                          //                     SizedBox(
                          //                         height: getScaledValue(20)),
                          //                     GestureDetector(
                          //                         onTap: () {
                          //                           Navigator.pushNamed(context,
                          //                               '/portfolio_master_selectors/merge',
                          //                               arguments: {
                          //                                 'portfolioMasterID':
                          //                                     widget
                          //                                         .portfolioMasterID,
                          //                                 'isSideMenuHeadingSelected':
                          //                                     "1",
                          //                                 'isSideMenuSelected':
                          //                                     "1"
                          //                               }).then(
                          //                               (_) => refreshParent());
                          //                         },
                          //                         child: Text('Merge Portfolio',
                          //                             style:
                          //                                 sortbyOptionHeading)),
                          //                     Divider(
                          //                       color: Color(0x251e1e1e),
                          //                       thickness: 1,
                          //                     ),
                          //                     SizedBox(
                          //                         height: getScaledValue(20)),
                          //                     GestureDetector(
                          //                         onTap: () {
                          //                           Navigator.of(context).pop();
                          //                           confirmDeleteForWeb();
                          //                         },
                          //                         child: Text(
                          //                             'Delete Portfolio',
                          //                             style:
                          //                                 sortbyOptionHeading)),
                          //                     Divider(
                          //                       color: Color(0x251e1e1e),
                          //                       thickness: 1,
                          //                     ),
                          //                     SizedBox(
                          //                         height: getScaledValue(20)),
                          //                     GestureDetector(
                          //                         onTap: () {
                          //                           Navigator.pushNamed(context,
                          //                               '/rename_portfolio',
                          //                               arguments: {
                          //                                 'portfolioMasterID':
                          //                                     widget
                          //                                         .portfolioMasterID
                          //                               }).then(
                          //                               (_) => refreshParent());
                          //                         },
                          //                         child: Text(
                          //                             'Rename Portfolio',
                          //                             style:
                          //                                 sortbyOptionHeading)),
                          //                     Divider(
                          //                       color: Color(0x251e1e1e),
                          //                       thickness: 1,
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             ),
                          //             actions: <Widget>[],
                          //           );
                          //         },
                          //       );
                          //     },
                          //     child: Container(
                          //       height: 33,
                          //       padding: const EdgeInsets.only(
                          //           left: 10.0, right: 10.0),
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(5.0),
                          //         border:
                          //             Border.all(color: colorBlue, width: 1.25),
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           Text(
                          //             "More",
                          //             style: TextStyle(
                          //               fontWeight: FontWeight.w500,
                          //               fontSize: 12,
                          //               color: colorBlue,
                          //               letterSpacing: 1.0,
                          //             ),
                          //           ),
                          //           Icon(
                          //             Icons.arrow_drop_down,
                          //             color: colorBlue,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Container(
                            height: 33,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                              border: Border.all(color: colorBlue, width: 1.25),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    hint: Text(
                                      (widget.model.userSettings['currency'] !=
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
                                    items:
                                        widget.model.currencies.map((Map item) {
                                      var textColor =
                                          (currencyValues.contains(item['key']))
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
                                    onChanged: (value) {
                                      setState(() {
                                        currencyValues = value;
                                      });
                                      _currencySelectionForWeb(currencyValues);
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              height: 350,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xffe9e9e9),
                                  width: 1.25,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Your Portfolio Today",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'nunito',
                                                  letterSpacing: 0.19,
                                                  color: Color(0xff383838))),
                                          Text(portfolioMasterData['value'],
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
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Text(Contants.oneDayReturns,
                                                      style: TextStyle(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: 'nunito',
                                                          letterSpacing: 0.16,
                                                          color: Color(
                                                              0xff818181))),
                                                  SizedBox(
                                                      width: getScaledValue(5)),
                                                  (portfolioMasterData[
                                                                  'change_sign'] ==
                                                              "up" ||
                                                          portfolioMasterData[
                                                                  'change_sign'] ==
                                                              "down"
                                                      ? Text(
                                                          portfolioMasterData[
                                                                      'change']
                                                                  .toString() +
                                                              "%",
                                                          style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'nunito',
                                                                  letterSpacing:
                                                                      0.17,
                                                                  color: Color(
                                                                      0xff474747))
                                                              .copyWith(
                                                                  color: portfolioMasterData[
                                                                              'change_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                      : emptyWidget),
                                                ],
                                              ),
                                              Text(
                                                  portfolioMasterData[
                                                          'change_amount']
                                                      .toString(),
                                                  style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: 'nunito',
                                                          letterSpacing: 0.17,
                                                          color:
                                                              Color(0xff474747))
                                                      .copyWith(
                                                          color: portfolioMasterData[
                                                                      'change_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Text(Contants.monthToDate,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: 'nunito',
                                                          letterSpacing: 0.16,
                                                          color: Color(
                                                              0xff818181))),
                                                  SizedBox(
                                                      width: getScaledValue(5)),
                                                  (portfolioMasterData[
                                                                  'changeMonth_sign'] ==
                                                              "up" ||
                                                          portfolioMasterData[
                                                                  'changeMonth_sign'] ==
                                                              "down"
                                                      ? Text(
                                                          portfolioMasterData[
                                                                      'changeMonth']
                                                                  .toString() +
                                                              "%",
                                                          style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'nunito',
                                                                  letterSpacing:
                                                                      0.17,
                                                                  color: Color(
                                                                      0xff474747))
                                                              .copyWith(
                                                                  color: portfolioMasterData[
                                                                              'changeMonth_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                      : emptyWidget),
                                                ],
                                              ),
                                              Text(
                                                  portfolioMasterData[
                                                          'changeMonth_amount']
                                                      .toString(),
                                                  style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: 'nunito',
                                                          letterSpacing: 0.17,
                                                          color:
                                                              Color(0xff474747))
                                                      .copyWith(
                                                          color: portfolioMasterData[
                                                                      'changeMonth_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Text(Contants.yearToDate,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: 'nunito',
                                                          letterSpacing: 0.16,
                                                          color: Color(
                                                              0xff818181))),
                                                  SizedBox(
                                                      width: getScaledValue(5)),
                                                  (portfolioMasterData[
                                                                  'changeYear_sign'] ==
                                                              "up" ||
                                                          portfolioMasterData[
                                                                  'changeYear_sign'] ==
                                                              "down"
                                                      ? Text(
                                                          portfolioMasterData[
                                                                      'changeYear']
                                                                  .toString() +
                                                              "%",
                                                          style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'nunito',
                                                                  letterSpacing:
                                                                      0.17,
                                                                  color: Color(
                                                                      0xff474747))
                                                              .copyWith(
                                                                  color: portfolioMasterData[
                                                                              'changeYear_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                      : emptyWidget),
                                                ],
                                              ),
                                              Text(
                                                  portfolioMasterData[
                                                          'changeYear_amount']
                                                      .toString(),
                                                  style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: 'nunito',
                                                          letterSpacing: 0.17,
                                                          color:
                                                              Color(0xff474747))
                                                      .copyWith(
                                                          color: portfolioMasterData[
                                                                      'changeYear_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child:
                                          fundCountForWeb2(portfolioMasterData),
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
                                top: 15.0, right: 15.0, bottom: 15.0),
                            child: Container(
                              height: 350,
                              //   decoration: BoxDecoration(
                              //   border: Border.all(color: Color(0xffe9e9e9), width: 1.25,),
                              //   borderRadius: BorderRadius.circular(0),
                              // ),
                              child: LargePortfolioChart(
                                widget.model,
                                analytics: widget.analytics,
                                observer: widget.observer,
                                portfolioMasterID: portfolioMasterData['id'],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Material(
                    elevation: 2.0,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      currentTabIndex = 0;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Text("CURRENT HOLDINGS",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.86,
                                              color: currentTabIndex == 0
                                                  ? Color(0xff034bd9)
                                                  : Color(0xffa5a5a5))),
                                      Container(
                                        color: currentTabIndex == 0
                                            ? Color(0xff034bd9)
                                            : Colors.white,
                                        width: 150,
                                        height: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        currentTabIndex = 1;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Text("PAST HOLDINGS",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.86,
                                              color: currentTabIndex == 1
                                                  ? Color(0xff034bd9)
                                                  : Color(0xffa5a5a5),
                                            )),
                                        Container(
                                          color: currentTabIndex == 1
                                              ? Color(0xff034bd9)
                                              : Colors.white,
                                          width: 120,
                                          height: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      getPortfolioFundTypeCount() > 1 &&
                                              currentTabIndex == 0
                                          ? GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "SORT BY",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'roboto',
                                                                letterSpacing:
                                                                    0.25,
                                                                color: Color(
                                                                    0xffa5a5a5)),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: Icon(
                                                                Icons.close,
                                                                color: Color(
                                                                    0xffcccccc),
                                                                size: 18),
                                                          )
                                                        ],
                                                      ),
                                                      content: Container(
                                                        color: Colors.white,
                                                        // height: MediaQuery.of(
                                                        //             context)
                                                        //         .size
                                                        //         .height *
                                                        //     0.5,
                                                        height: 300,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                  height:
                                                                      getScaledValue(
                                                                          6)),
                                                              _sortOptionSection(
                                                                  title: "Name",
                                                                  options: [
                                                                    {
                                                                      "title":
                                                                          "A - Z",
                                                                      "type":
                                                                          "name",
                                                                      "order":
                                                                          "asc"
                                                                    },
                                                                    {
                                                                      "title":
                                                                          "Z - A",
                                                                      "type":
                                                                          "name",
                                                                      "order":
                                                                          "desc"
                                                                    }
                                                                  ]),
                                                              Divider(
                                                                color: Color(
                                                                    0x251e1e1e),
                                                              ),
                                                              _sortOptionSection(
                                                                  title:
                                                                      "Value",
                                                                  options: [
                                                                    {
                                                                      "title":
                                                                          "Highest to Lowest",
                                                                      "type":
                                                                          "valueBase",
                                                                      "order":
                                                                          "desc"
                                                                    },
                                                                    {
                                                                      "title":
                                                                          "Lowest to Highest",
                                                                      "type":
                                                                          "valueBase",
                                                                      "order":
                                                                          "asc"
                                                                    }
                                                                  ]),
                                                              Divider(
                                                                color: Color(
                                                                    0x251e1e1e),
                                                              ),
                                                              _sortOptionSection(
                                                                  title:
                                                                      "Units",
                                                                  options: [
                                                                    {
                                                                      "title":
                                                                          "Highest to Lowest",
                                                                      "type":
                                                                          "weightage",
                                                                      "order":
                                                                          "desc"
                                                                    },
                                                                    {
                                                                      "title":
                                                                          "Lowest to Highest",
                                                                      "type":
                                                                          "weightage",
                                                                      "order":
                                                                          "asc"
                                                                    }
                                                                  ]),
                                                              Divider(
                                                                color: Color(
                                                                    0x251e1e1e),
                                                              ),
                                                              _sortOptionSection(
                                                                  title:
                                                                      "Daily Return",
                                                                  options: [
                                                                    {
                                                                      "title":
                                                                          "Highest to Lowest",
                                                                      "type":
                                                                          "change",
                                                                      "order":
                                                                          "desc"
                                                                    },
                                                                    {
                                                                      "title":
                                                                          "Lowest to Highest",
                                                                      "type":
                                                                          "change",
                                                                      "order":
                                                                          "asc"
                                                                    }
                                                                  ]),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      actions: <Widget>[],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Sort By:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Color(0xffa5a5a5),
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  sortByText.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
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
                                            )
                                          : Container(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            currentTabIndex == 0
                                ? portfolioListBoxForLarge(context, "current",
                                    portfolioMasterData['portfolios'],
                                    portfolioMasterID: widget.portfolioMasterID,
                                    model: widget.model,
                                    callBackForDelete: confirmDeletePopUp,
                                    refreshParentState: () {
                                    Future.delayed(Duration(milliseconds: 100))
                                        .then((value) => refreshParent());
                                  },
                                    readOnly: widget.readOnly,
                                    sortOrder: sortOrder,
                                    sortType: sortType,
                                    sortWidget: emptyWidget)
                                : currentTabIndex == 1
                                    ? portfolioListBoxForLarge(context, "past",
                                        portfolioMasterData['portfolios'],
                                        portfolioMasterID:
                                            widget.portfolioMasterID,
                                        model: widget.model,
                                        callBackForDelete: confirmDeletePopUp,
                                        refreshParentState: () {
                                        Future.delayed(
                                                Duration(milliseconds: 100))
                                            .then((value) => refreshParent());
                                      },
                                        readOnly: widget.readOnly,
                                        sortOrder: sortOrder,
                                        sortType: sortType,
                                        sortWidget: emptyWidget)
                                    : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            width: 175,
                            child: ElevatedButton(
                              style: qfButtonStyle(
                                  ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
                              child: Ink(
                                width: MediaQuery.of(context).size.width,
                                height: 33,
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
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                      minHeight: 50),
                                  alignment: Alignment.center,
                                  child: Text(
                                    portfolioMasterData != null &&
                                            portfolioMasterData['portfolios'] !=
                                                null &&
                                            portfolioMasterData['portfolios']
                                                    ['Deposit'] !=
                                                null
                                        // portfolioMasterData['portfolios']
                                        //             ['Deposit'] !=
                                        //         null
                                        ? "ADD DEPOSITS"
                                        : "ADD INVESTMENTS",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (portfolioMasterData['portfolios']
                                        ['Deposit'] !=
                                    null) {
                                  _showAddDepositBottonsheet();
                                } else {
                                  _searchOrSortAndFilterPopUp();
                                }
                                // Navigator.pushReplacementNamed(context, '/add_instrument', arguments: {'portfolioMasterID': widget.portfolioMasterData['id']}).then( (_) => widget.refreshParent());
                              },
                            )),
                        _moreOptions(popupMenu),
                        // GestureDetector(
                        //   behavior: HitTestBehavior.opaque,
                        //   onTap: () {
                        //     showDialog(
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return AlertDialog(
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //           ),
                        //           title: Row(
                        //             mainAxisAlignment: MainAxisAlignment.end,
                        //             children: [
                        //               GestureDetector(
                        //                 onTap: () => Navigator.pop(context),
                        //                 child: Icon(Icons.close,
                        //                     color: Color(0xffcccccc), size: 18),
                        //               )
                        //             ],
                        //           ),
                        //           content: Container(
                        //             color: Colors.white,
                        //             height: MediaQuery.of(context).size.height *
                        //                 0.4,
                        //             child: SingleChildScrollView(
                        //               child: Column(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.center,
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   GestureDetector(
                        //                       onTap: () {
                        //                         Navigator.of(context).pop();
                        //                         togglePortfolioType();
                        //                       },
                        //                       child: Text(
                        //                           'Mark as ' +
                        //                               (portfolioMasterData[
                        //                                           'type'] ==
                        //                                       "1"
                        //                                   ? "Watchlist"
                        //                                   : "Live"),
                        //                           style: sortbyOptionHeading)),
                        //                   Divider(
                        //                     color: Color(0x251e1e1e),
                        //                     thickness: 1,
                        //                   ),
                        //                   SizedBox(height: getScaledValue(20)),
                        //                   GestureDetector(
                        //                       onTap: () {
                        //                         Navigator.pushNamed(context,
                        //                             '/split_portfolio_portfolio_name/split',
                        //                             arguments: {
                        //                               'portfolioMasterID':
                        //                                   widget
                        //                                       .portfolioMasterID
                        //                             }).then(
                        //                             (_) => refreshParent());
                        //                       },
                        //                       child: Text('Duplicate Portfolio',
                        //                           style: sortbyOptionHeading)),
                        //                   Divider(
                        //                     color: Color(0x251e1e1e),
                        //                     thickness: 1,
                        //                   ),
                        //                   SizedBox(height: getScaledValue(20)),
                        //                   GestureDetector(
                        //                       onTap: () {
                        //                         Navigator.pushNamed(context,
                        //                             '/portfolio_master_selectors/merge',
                        //                             arguments: {
                        //                               'portfolioMasterID': widget
                        //                                   .portfolioMasterID,
                        //                               'isSideMenuHeadingSelected':
                        //                                   "1",
                        //                               'isSideMenuSelected': "1"
                        //                             }).then(
                        //                             (_) => refreshParent());
                        //                       },
                        //                       child: Text('Merge Portfolio',
                        //                           style: sortbyOptionHeading)),
                        //                   Divider(
                        //                     color: Color(0x251e1e1e),
                        //                     thickness: 1,
                        //                   ),
                        //                   SizedBox(height: getScaledValue(20)),
                        //                   GestureDetector(
                        //                       onTap: () {
                        //                         Navigator.of(context).pop();
                        //                         confirmDeleteForWeb();
                        //                       },
                        //                       child: Text('Delete Portfolio',
                        //                           style: sortbyOptionHeading)),
                        //                   Divider(
                        //                     color: Color(0x251e1e1e),
                        //                     thickness: 1,
                        //                   ),
                        //                   SizedBox(height: getScaledValue(20)),
                        //                   GestureDetector(
                        //                       onTap: () {
                        //                         Navigator.pushNamed(context,
                        //                             '/rename_portfolio',
                        //                             arguments: {
                        //                               'portfolioMasterID':
                        //                                   widget
                        //                                       .portfolioMasterID
                        //                             }).then(
                        //                             (_) => refreshParent());
                        //                       },
                        //                       child: Text('Rename Portfolio',
                        //                           style: sortbyOptionHeading)),
                        //                   Divider(
                        //                     color: Color(0x251e1e1e),
                        //                     thickness: 1,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //           actions: <Widget>[],
                        //         );
                        //       },
                        //     );
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(left: 10.0),
                        //     child: Container(
                        //       height: 33,
                        //       padding: const EdgeInsets.only(
                        //           left: 10.0, right: 10.0),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(5.0),
                        //         border:
                        //             Border.all(color: colorBlue, width: 1.25),
                        //       ),
                        //       child: Row(
                        //         children: [
                        //           Text(
                        //             "More",
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.w500,
                        //               fontSize: 12,
                        //               color: colorBlue,
                        //               letterSpacing: 1.0,
                        //             ),
                        //           ),
                        //           Icon(
                        //             Icons.arrow_drop_down,
                        //             color: colorBlue,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      );
    }
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

  _searchOrSortAndFilterPopUp() => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: Text("Add A New Asset",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'nunito',
                            letterSpacing: 0.29,
                            color: Color(0xff181818))),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Color(0xffcccccc), size: 14),
                )
              ],
            ),
            content: Container(
              color: Colors.white,
              //  height: MediaQuery.of(context).size.height * 0.3,
              //  width: MediaQuery.of(context).size.height * 0.3,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getScaledValue(0)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pop(context);
                        searchPopupWeb();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff0941cc), Color(0xff0055fe)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_outlined,
                                color: Colors.white,
                                size: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Search",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pop(context);
                        filterPopupWeb();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 30, right: 30),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff0941cc), Color(0xff0055fe)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icon/sort_filter_icon.png',
                                height: 13.0,
                                width: 13.0,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Sort & Filter",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: getScaledValue(0)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[],
          );
        },
      );

  //-----------------------------------------------------------------------------

  // search popup
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

  Widget _smartSearchContainer() {
    return Container(
      width: 160,
      color: Color(0xfffafafa),
      padding: EdgeInsets.all(5),
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

  _searchBody() {
    return Expanded(
      child: Container(
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
            onSubmitted: (value) {
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
        padding: EdgeInsets.all(getScaledValue(0)),
        width: 166,
        height: 40,
        decoration: new BoxDecoration(
            color: bgColor,
            border: Border.all(width: 1.0, color: borderColor),
            borderRadius: BorderRadius.circular(getScaledValue(5))),
        child: Text(title,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(fontSize),
                fontWeight: fontWeight,
                fontFamily: 'nunito',
                letterSpacing: 0,
                color: textColor)),
      ),
    );
  }

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
      // if (widget.action == "newPortfolio" || widget.action == "newInstrument") {
      //   if (widget.action == "newPortfolio") {
      //     _portfolioMasterID = '0';
      //   } else {
      _portfolioMasterID = widget.portfolioMasterID;
      // }

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
        // if (widget.action == "newPortfolio") {
        // bool popFlag = true;
        // if (page == "fundList") popFlag = false;
        //   setState(() {
        //     page = 'add_instrument_new_portfolio';
        //   });
        //   focusNodesUnits[selectedRIC.ric] = FocusNode();
        //   _controllerUnits[selectedRIC.ric] =
        //       TextEditingController(text: '1.00');

        //   var portfolioIndex = widget
        //           .model
        //           .userPortfoliosData[_portfolioMasterID]['portfolios']
        //               [selectedRIC.fundType]
        //           .length -
        //       1;

        //   setState(() {
        //     widget.model.userPortfoliosData[_portfolioMasterID]['portfolios']
        //         [selectedRIC.fundType][portfolioIndex]['weightage'] = "1.00";
        //     widget
        //         .model
        //         .userPortfoliosData[_portfolioMasterID]['portfolios']
        //             [selectedRIC.fundType][portfolioIndex]['transactions']
        //         .add({
        //       "ric": selectedRIC.ric,
        //       "holding": "1.00",
        //       "type": "buy",
        //       "price": "",
        //       "date": ""
        //     });
        //   });

        //   _setStockPortfolio();

        //   updateUnitOption(value: unitOption);

        //   Navigator.pop(context);
        // } else {
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
          'action': "newInstrument",
        };
        Navigator.pushReplacementNamed(context, '/add_transactions',
            arguments: arguments);
        // }
      }
      // }
    } catch (e) {
      log.d(e);
    }
  }

  // filter popup
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
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: getScaledValue(13),
                        vertical: getScaledValue(13)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        resetButton('Reset',
                            borderColor: colorBlue,
                            textColor: colorBlue,
                            onPressFunction: () => resetFilter()),
                        SizedBox(width: getScaledValue(10)),
                        Container(
                            width: 166,
                            child: gradientButton(
                                context: context,
                                caption: 'Apply',
                                onPressFunction: () => applyFilter(),
                                miniButton: true)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
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
    // log.d(json.encode(filterOptionSelection));
    Map responseData = await widget.model.fundScreener(filterOptionSelection);
    _setState(() {
      if (responseData.isNotEmpty) {
        fundList = responseData['response'];
        // log.d(fundList.toString());
        // page = "fundList";
      }

      // widget.model.setLoader(false);
    });
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

  filterOptionValueUpdate({String value, String value2, String optionKey}) {
    _setState(() {
      if (filterOptions[activeFilterOption]['optionType'] == "radio") {
        log.d(value.toString());
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

  _moreOptions(List popupMenu) {
    return PopupMenuButton(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          height: 33,
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            border: Border.all(color: colorBlue, width: 1.25),
          ),
          child: Row(
            children: [
              Text(
                "More",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: colorBlue,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: colorBlue,
              ),
            ],
          ),
        ),
      ),
      // icon: Icon(Icons.add),
      onSelected: (value) async {
        if (value == "split") {
          Navigator.pushNamed(context, '/split_portfolio_portfolio_name/split',
                  arguments: {'portfolioMasterID': widget.portfolioMasterID})
              .then((_) => refreshParent());
        } else if (value == "merge") {
          Navigator.pushNamed(context, '/portfolio_master_selectors/merge',
              arguments: {
                'portfolioMasterID': widget.portfolioMasterID,
                'isSideMenuHeadingSelected': "1",
                'isSideMenuSelected': "1"
              }).then((_) => refreshParent());
        } else if (value == "toggle") {
          togglePortfolioType();
        } else if (value == "delete") {
          confirmDeleteForWeb();
        } else if (value == "rename") {
          Navigator.pushNamed(context, '/rename_portfolio',
                  arguments: {'portfolioMasterID': widget.portfolioMasterID})
              .then((_) => refreshParent());
        }
      },
      itemBuilder: (BuildContext context) {
        return popupMenu.map((menu) {
          return PopupMenuItem(
              value: menu['action'], child: Text(menu['text'] ?? ''));
        }).toList();
      },
    );
  }

  //-----------------------------------------------------------------------------

  confirmDeletePopUp({int ricIndex, Map<String, dynamic> selectedSuggestion}) {
    int portfolioCount = 0;
    widget.model.userPortfoliosData[widget.portfolioMasterID]['portfolios']
        .forEach((key, portfolios) {
      portfolios.forEach((element) {
        if (double.parse(element['weightage']) > 0) {
          portfolioCount++;
        }
      });
    });
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
                          : portfolioMasterData != null &&
                                  portfolioMasterData['portfolios'] != null &&
                                  portfolioMasterData['portfolios']
                                          ['Deposit'] !=
                                      null
                              // portfolioMasterData['portfolios']['Deposit'] != null
                              ? "Are you sure you want to delete this deposit?"
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
                                  deleteAlert(ricIndex, selectedSuggestion,
                                      portfolioCount);
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

  deleteAlert(int ricIndex, Map<String, dynamic> selectedSuggestion,
      int portfolioCount) async {
    Navigator.of(context).pop(true);
    // Navigator.of(context)
    //     .popUntil((route) => route.isFirst);
    setState(() {
      widget.model.setLoader(true);
    });

    Map<String, dynamic> responseData;

    if (portfolioCount == 1) {
      responseData =
          await widget.model.removePortfolioMaster(widget.portfolioMasterID);
    } else {
      widget
          .model
          .userPortfoliosData[widget.portfolioMasterID]['portfolios']
              [selectedSuggestion['type']]
          .removeAt(ricIndex);
      responseData = await widget.model.updateCustomerPortfolioData(
          portfolios: widget.model.userPortfoliosData[widget.portfolioMasterID]
              ['portfolios'],
          portfolioMasterID: widget.portfolioMasterID,
          portfolioName: widget.model
              .userPortfoliosData[widget.portfolioMasterID]['portfolio_name']);
    }

    if (responseData['status'] == true) {
      if (portfolioMasterData != null &&
          portfolioMasterData['portfolios'] != null &&
          portfolioMasterData['portfolios']['Deposit'] != null) {
        // if (portfolioMasterData['portfolios']['Deposit'] != null) {
        if (portfolioCount == 1) {
          Navigator.pushReplacementNamed(
              context, '/manage_portfolio_master_view');
        }
      } else {
        if (portfolioCount == 1) {
          Navigator.pushReplacementNamed(
              context, '/manage_portfolio_master_view');
        }
      }
    }
    setState(() {
      widget.model.setLoader(false);
    });
  }

  _currencySelectionForWeb(String currencyValues) async {
    widget.model.setLoader(true);
    Map<String, dynamic> responseData =
        await widget.model.changeCurrency(currencyValues);
    if (responseData['status'] == true) {
      await widget.model.fetchOtherData();
      widget.model.setLoader(false);
      refreshParent();
    }
  }

  Widget _sortPortfolios() {
    //
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
}

MyGlobals myGlobals = new MyGlobals();

class MyGlobals {
  GlobalKey _scaffoldKey;

  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }

  GlobalKey get scaffoldKey => _scaffoldKey;
}
