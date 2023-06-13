import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/helpers/portfolio_helper.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

final log = getLogger('ManagePortfolioMaster');

class SmallManagePortfolioMaster extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool viewOnly;

  SmallManagePortfolioMaster(this.model,
      {this.analytics, this.observer, this.viewOnly = false});

  @override
  State<StatefulWidget> createState() {
    return _SmallManagePortfolioMasterState();
  }
}

class _SmallManagePortfolioMasterState
    extends State<SmallManagePortfolioMaster> {
  final controller = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  final portfolioNameFocusNode = new FocusNode();
  String _portfolioName = null;
  TextEditingController _portfolioNameTxt = new TextEditingController();

  String sortType = "date";
  String sortOrder = "asc";

  StateSetter _setState, _setSaveButtonColorChangeState;
  String _selectedCurrency;

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n analyticsCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'manage',
      screenClassOverride: 'manage',
    );
  }

  Future<Null> _analyticsAddButtonEvent() async {
    // log.d("\n analyticsAddButtonEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "manage",
      'item_name': "manage_new_portfolio",
      'content_type': "click_add_new_portfolio_button",
    });
  }

  refreshParent() => setState(() {});

  @override
  void initState() {
    super.initState();

    // log.d("Checking_manage_portfolio");

    _analyticsCurrentScreen();
    // _addEvent();

    // setState(() {
    // 	widget.model.redirectBase = "/manage_portfolio_master_view";
    // });

    // loadFormData();
  }

  // Future loadFormData() async {
  //   if (widget.model.isUserAuthenticated) {
  //     setState(() {
  //       _loading = true;
  //     });
  //     await widget.model.getCustomerPortfolio();
  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  //
  //   widget.model.userPortfoliosData.forEach((key, value) {
  //     if (widget.model.defaultPortfolioSelectorValue == "" ||
  //         value['default'] == '1') {
  //       widget.model.defaultPortfolioSelectorKey = key;
  //       widget.model.defaultPortfolioSelectorValue = value['portfolio_name'];
  //       setState(() {});
  //     }
  //   });
  // }

  Future<void> addPortfolioMenu() async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
                child: Text(
                  'Import from Excel',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop("Discard");

                  functionSendPortfolioImportSample();
                }),
            CupertinoActionSheetAction(
                child: Text(
                  'Add Manually',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                  addNewPortfolio(context);
                }),
          ],
          /* cancelButton: CupertinoActionSheetAction(
					isDefaultAction: true,
					child: Text('Cancel'),
					onPressed: () { /** */ },
				), */
        );
      },
    );
  }

  functionSendPortfolioImportSample() async {
    setState(() {
      _loading = true;
    });
    await widget.model.generateSample();
    showAlertDialogBox(context, '',
        'An email will be sent to your verified email address with the steps to upload the excel');
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Color(0xff0445e4));
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: WidgetDrawer(),
        appBar: kIsWeb
            ? AppBar(
                backgroundColor: colorBlue,
                elevation: 0.0,
                title: Text(""),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Container(
                      margin: EdgeInsets.only(right: getScaledValue(15)),
                      child: flatButtonText("+ New portfolio",
                          onPressFunction: () {
                        _analyticsAddButtonEvent();
                        Navigator.pushNamed(context, '/add_portfolio')
                            .then((_) => refreshParent());
                      }, textColor: Colors.white, bgColor: null),
                    ),
                  ),
                ],
              )
            : commonScrollAppBar(
                controller: controller,
                leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _scaffoldKey.currentState.openDrawer(),
                    child: Container(
                      padding: EdgeInsets.all(
                          getScaledValue(Platform.isAndroid ? 17 : 12)),
                      height: getScaledValue(5),
                      child: svgImage('assets/icon/icon_menu.svg'),
                    )),
                actions: [
                    Container(
                      margin: MediaQuery.of(context).size.shortestSide > 600
                          ? EdgeInsets.only(
                              right: getScaledValue(15), top: getScaledValue(0))
                          : EdgeInsets.only(
                              top: getScaledValue(10),
                              right: getScaledValue(15)),
                      child: flatButtonText("+ New portfolio",
                          onPressFunction: () {
                        _analyticsAddButtonEvent();
                        Navigator.pushNamed(context, '/add_portfolio')
                            .then((_) => refreshParent());
                      }, textColor: Colors.white, bgColor: null),
                    ),
                  ]),
        bottomNavigationBar: widgetBottomNavBar(context, 1),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      return mainContainer(
          context: context,
          paddingBottom: 0,
          containerColor: Colors.white,
          child:
              _buildBodyContent()); //_autocompleteTextField(); //_buildBodyContent();

    }
  }

  Widget _buildBodyContent() {
    return (widget.model.userPortfoliosData == null ||
            widget.model.userPortfoliosData == null)
        ? _noPortfolio()
        : listPortfolios();
  }

  Widget listPortfolios() {
    List<Widget> _listPortfolios = [];

    /* _listPortfolios.add(
			Container(
				margin: EdgeInsets.only(bottom: 10.0),
				child: Row(
					children: <Widget>[
						Expanded(child: Text("Portfolio(s)", style: Theme.of(context).textTheme.subtitle1,))
					],
				)
			)
		); */

    // double portfolioTotalSummary = 0.0;
    // int portfolioTotalSummaryLength = 0;
    //
    // if(widget.model.portfolioTotalSummary != null){
    // 	try {
    // 		portfolioTotalSummary = double.parse(widget.model.portfolioTotalSummary);
    // 		portfolioTotalSummaryLength = widget.model.portfolioTotalSummary.length;
    // 	} catch (e) {
    //
    // 	}
    // }
    //
    // log.d("portfolioTotalSummaryLength");
    // log.d(portfolioTotalSummaryLength);

    _listPortfolios.add(Container(
      height: getScaledValue(
        135.0 +
            (78.0 *
                (widget.model.portfolioTotalSummary == null
                    ? 0.0
                    : widget.model.portfolioTotalSummary.length)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
                height: getScaledValue(155.0),
                padding: EdgeInsets.symmetric(
                    horizontal: getScaledValue(15),
                    vertical: getScaledValue(10.0)),
                //margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff0445e4), Color(0xff1181ff)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(height: getScaledValue(35)),
                    GestureDetector(
                      onTap: () => filterPopup(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("All Portfolios", style: appBodyText2),
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                    text: "in ",
                                    style: currencyConvert,
                                    children: [
                                      TextSpan(
                                          text: (widget.model.userSettings[
                                                          'currency'] !=
                                                      null
                                                  ? widget.model
                                                      .userSettings['currency']
                                                  : "inr")
                                              .toUpperCase(),
                                          style: currencyConvertActive)
                                    ]),
                              ),
                              Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xff7ca8ff)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )),
          ),
          Positioned(
              top: (MediaQuery.of(context).size.height * .15),
              left: getScaledValue(15.0),
              width: getScaledValue(330.0),
              height: getScaledValue(
                78.0 *
                    (widget.model.portfolioTotalSummary == null
                        ? 0.0
                        : widget.model.portfolioTotalSummary.length),
              ),
              child: _portfolioValues())
        ],
      ),
    ));

    if (widget.model.userPortfoliosData.length > 1)
      _listPortfolios.add(_sortPortfolios());

    widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
      if (portfolioMasterID != '0')
        _listPortfolios.add(portfolioItem(portfolio));
    });
    return ListView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      children: _listPortfolios,
    );
  }

  Widget _portfolioValues() {
    try {
      List<Widget> _children = [];
      if (widget.model.portfolioTotalSummary != null) {
        int flagCount = 1;
        if (widget.model.portfolioTotalSummary.length == 0) {
        } else {
          widget.model.portfolioTotalSummary.forEach((zone, value) {
            _children.add(_portfolioSummaryBox(zone, value));
            if (flagCount < widget.model.portfolioTotalSummary.length) {
              _children.add(Divider(color: Color(0xffd2d2d2)));
              flagCount++;
            }
          });
        }
      }
      return Container(
        padding: EdgeInsets.symmetric(vertical: getScaledValue(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe9e9e9), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
          boxShadow: [
            BoxShadow(
              color: Color(0x25808080),
              blurRadius: 30.0, // soften the shadow
              spreadRadius: 0.0, //extend the shadow
              offset: Offset(
                2, // Move to right 10  horizontally
                13, // Move to bottom 10 Vertically
              ),
            )
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: _children),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget _portfolioSummaryBox(String zone, String value) {
    String zoneString = "";
    if (zone == "in") {
      zoneString = "india";
    } else if (zone == "us") {
      zoneString = "USA";
    } else if (zone == "sg") {
      zoneString = "Singapore";
    } else if (zone == "gl") {
      zoneString = "Global";
    } else {
      zoneString = zone;
    }
    return Expanded(
        child: Container(
      padding: EdgeInsets.symmetric(
          vertical: getScaledValue(8), horizontal: getScaledValue(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child:
                  Text(zoneString.toUpperCase(), style: portfolioSummaryZone)),
          Expanded(
              child: Text(removeDecimal(value),
                  style: portfolioSummaryValue.copyWith(
                      fontSize: ScreenUtil().setSp(15.0)))),
        ],
      ),
    ));
  }

  Widget _sortPortfolios() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: getScaledValue(16), vertical: getScaledValue(0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("YOUR PORTFOLIOS", style: appBodyH4),
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
          _sortOptionSection(title: "Portfolio Name", options: [
            {"title": "A - Z", "type": "portfolio_name", "order": "asc"},
            {"title": "Z - A", "type": "portfolio_name", "order": "desc"}
          ]),
          Divider(
            color: Color(0x251e1e1e),
          ),
          _sortOptionSection(title: "Portfolio Value", options: [
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
          sort(optionRow['type']);

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
    setState(() {
      _loading = true;
    });
    await widget.model.setPortfolioMasterDefault(portfolioID, type);
    setState(() {
      _loading = false;
    });
  }

  Widget portfolioItem(Map portfolio) {
    return Container(
        margin: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(8)),
        child: portfolioMasterBox(context, portfolio,
            refreshParent: refreshParent));
  }

  Widget _noPortfolio() {
    return Container(
        margin: EdgeInsets.only(top: 20.0),
        alignment: Alignment.center,
        child: widget.model.isUserAuthenticated
            ? Text(
                "You haven\'t added your portfolio",
                style: Theme.of(context).textTheme.subtitle1,
              )
            : requireLogin(context));
  }

  confirmDelete(String portfolioMasterID) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete!'),
            content: Text('Are you sure you want to delete portfolio?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  setState(() {
                    _loading = true;
                  });

                  await widget.model.removePortfolioMaster(portfolioMasterID);

                  setState(() {
                    _loading = false;
                  });
                },
                child: Text('Yes'),
              ),
            ],
          );
        });
  }

  addPortfolio(BuildContext dialogContex,
      {bool copyExisting = false,
      String existingPortfolioMasterID = ""}) async {
    setState(() {
      widget.model.userPortfoliosData["0"] = {
        'id': "0",
        'default': '0',
        'portfolio_name': _portfolioName,
        'portfolio_zone': widget.model.userSettings['default_zone'],
        'portfolios': {}
      };
      // log.d('debug 582');
      // log.d(widget.model.userPortfoliosData["0"]);
      _loading = true;
    });

    Navigator.of(dialogContex).pop();
    if (copyExisting) {
      await widget.model.updateCustomerPortfolioData(
          portfolios: copyExisting
              ? widget.model.userPortfoliosData[existingPortfolioMasterID]
                  ['portfolios']
              : widget.model.userPortfoliosData['0']['portfolios'],
          riskProfile: widget.model.newUserRiskProfile,
          portfolioMasterID: '0',
          portfolioName: _portfolioName);
      // log.d(responseData);
    } else {
      // log.d('debug 589');
      // log.d(_portfolioName);

      Navigator.pushNamed(context, '/portfolio_edit_new/0/' + _portfolioName)
          .then((_) => refreshParent());
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _portfolioNameBox() {
    return Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Portfolio Name",
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 10.0),
          TextField(
            focusNode: portfolioNameFocusNode,
            controller: _portfolioNameTxt,
            decoration: InputDecoration(
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.grey[600]),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0)),
            textAlign: TextAlign.left,
            keyboardType: TextInputType.text,
            onChanged: (String value) {
              setState(() {
                _portfolioName = value;
              });
            },
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.grey[600]),
          )
        ]);
  }

  void addNewPortfolio(BuildContext context,
      {bool copyExisting = false, String existingPortfolioMasterID = ""}) {
    _portfolioNameTxt.clear();
    showModalBottomSheet(
        isScrollControlled: true,
        context: myGlobals.scaffoldKey.currentContext,
        builder: (BuildContext context) {
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
                    _portfolioNameBox(),
                    SizedBox(height: 30.0),
                    Center(
                        child: RaisedButton(
                            child: Text(
                              "Add Portfolio",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => addPortfolio(context,
                                copyExisting: copyExisting,
                                existingPortfolioMasterID:
                                    existingPortfolioMasterID)))
                  ]));
        });
  }

  void filterPopup() {
    customAlertBox(
      context: context,
      childContent: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return _filterPopup();
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
                  style: _selectedCurrency == null
                      ? dialogBoxActionInactive
                      : dialogBoxActionActive);
            },
          ),
          onPressed: () async {
            if (_selectedCurrency != null) {
              setState(() {
                _loading = true;
              });
              Map<String, dynamic> responseData =
                  await widget.model.changeCurrency(_selectedCurrency);
              if (responseData['status'] == true) {
                Navigator.of(context).pop();
                await widget.model.fetchOtherData();
                setState(() {
                  _loading = false;
                });
              }
            }
          },
        )
      ],
    );

    // flutter defined function
    /* showDialog(
			context: context,
			builder: (BuildContext context) {
				// return object of type Dialog
				return AlertDialog(
						content:  StatefulBuilder(
      						builder: (BuildContext context, StateSetter setState) {
								_setState = setState;
								return _filterPopup();
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
								onPressed: () async{
									setState((){
										_loading = true;
									});
									Map<String, dynamic> responseData = await widget.model.changeCurrency(_selectedCurrency);
									if(responseData['status'] == true){
										Navigator.of(context).pop();
										await widget.model.fetchOtherData();
										setState((){
											_loading = false;
										});
									}
								},
							)
						],
					);

			},
		); */
  }

  Widget _filterPopup() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite < getScaledValue(365) ? double.maxFinite : null,
      // double.maxFinite,
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
                    child: Text(item['value']),
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
