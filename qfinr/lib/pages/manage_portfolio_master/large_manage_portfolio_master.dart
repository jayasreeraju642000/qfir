import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/main.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_portfolio_helper.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'dart:async';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

final log = getLogger('ManagePortfolioMaster');

class LargeManagePortfolioMaster extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final bool viewOnly;

  LargeManagePortfolioMaster(this.model,
      {this.analytics, this.observer, this.viewOnly = false});

  @override
  _LargeManagePortfolioMasterState createState() =>
      _LargeManagePortfolioMasterState();
}

class _LargeManagePortfolioMasterState
    extends State<LargeManagePortfolioMaster> {
  double deviceWidth, deviceHeight;
  final controller = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  final portfolioNameFocusNode = new FocusNode();
  String _portfolioName = null;
  TextEditingController _portfolioNameTxt = new TextEditingController();
  String sortType = "date";
  String sortOrder = "asc";
  String currencyValues;

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n analyticsCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'manage',
      screenClassOverride: 'manage',
    );
  }

  Future<Null> _analyticsAddNewPortfolioEvent() async {
    widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "manage",
      'item_name': "manage_new_portfolio",
      'content_type': "click_add_new_portfolio_button",
    });
  }

  refreshParent() => setState(() {});

  @override
  void initState() {
    super.initState();
    _analyticsCurrentScreen();
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
        );
      },
    );
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
    } else {
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
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          body: _buildBody(),
        );
      }),
    );
  }

  Widget _buildBody() {
    return _buildBodyForWeb();
  }

  Widget _buildBodyForWeb() {
    return _buildBodyForPlatforms();
  }

  Widget _buildBodyForPlatforms() {
    return _largeScreenBody();
  }

  Widget _largeScreenBody() => Column(
        children: [
          _buildTopBar(),
          _bodyContents(),
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

  Widget _buildBodyContent() {
    if (widget.model.isLoading || _loading) {
      return preLoader();
    } else {
      return Container(
        height: MediaQuery.of(context).size.height,
        color: Color(0xfff5f6fa),
        child: (widget.model.userPortfoliosData == null ||
                widget.model.userPortfoliosData.isEmpty)
            ? _noPortfolio()
            : _buildPortFoliosForWeb(),
      );
    }
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

  Widget _buildPortFoliosForWeb() {
    currencyValues = widget.model.userSettings['currency'] != null
        ? widget.model.userSettings['currency']
        : null;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "My Portfolios",
                  style: TextStyle(
                    color: Color(0xff282828),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 33,
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: colorBlue, width: 1.25),
                            color: Colors.white),
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              dropdownColor: Colors.white,
                              hint: Text(
                                (widget.model.userSettings['currency'] != null
                                        ? widget.model.userSettings['currency']
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
                              items: widget.model.currencies.map((Map item) {
                                var textColor =
                                    (currencyValues.contains(item['key']))
                                        ? Colors.white
                                        : MyApp.commonPrimaryColor;
                                return DropdownMenuItem<String>(
                                  value: item['key'],
                                  child: Text(
                                    item['value'],
                                    style: heading_alert_view_all.copyWith(
                                        color: textColor),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                setState(() {
                                  currencyValues = value;
                                });
                                _currencySelectionForWeb(currencyValues);
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
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
                                    "ADD NEW PORTFOLIO",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await _analyticsAddNewPortfolioEvent();
                                return Navigator.pushNamed(
                                        context, '/add_portfolio')
                                    .then((_) => refreshParent());
                              },
                            )),
                      ),
                    ],
                  ),
                )
              ],
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
                    //  height: 90,
                    child: Padding(
                      //  padding: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _portfolioValues()),
                        ],
                      ),
                    )),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "All Portfolios",
                                style: TextStyle(
                                  color: Color(0xff383838),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              (widget.model.userPortfoliosData.length > 1)
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "SORT BY",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'roboto',
                                                        letterSpacing: 0.25,
                                                        color:
                                                            Color(0xffa5a5a5)),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        Navigator.pop(context),
                                                    child: Icon(Icons.close,
                                                        color:
                                                            Color(0xffcccccc),
                                                        size: 18),
                                                  )
                                                ],
                                              ),
                                              content: Container(
                                                color: Colors.white,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height *
                                                //     0.5,
                                                //height: 300,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(height: 6),
                                                      _sortOptionSection(
                                                          title:
                                                              "Portfolio Name",
                                                          options: [
                                                            {
                                                              "title": "A - Z",
                                                              "type":
                                                                  "portfolio_name",
                                                              "order": "asc"
                                                            },
                                                            {
                                                              "title": "Z - A",
                                                              "type":
                                                                  "portfolio_name",
                                                              "order": "desc"
                                                            }
                                                          ]),
                                                      Divider(
                                                        color:
                                                            Color(0x251e1e1e),
                                                      ),
                                                      _sortOptionSection(
                                                          title:
                                                              "Portfolio Value",
                                                          options: [
                                                            {
                                                              "title":
                                                                  "Highest to Lowest",
                                                              "type":
                                                                  "valueBase",
                                                              "order": "desc"
                                                            },
                                                            {
                                                              "title":
                                                                  "Lowest to Highest",
                                                              "type":
                                                                  "valueBase",
                                                              "order": "asc"
                                                            }
                                                          ]),
                                                      Divider(
                                                        color:
                                                            Color(0x251e1e1e),
                                                      ),
                                                      _sortOptionSection(
                                                          title: "Daily Return",
                                                          options: [
                                                            {
                                                              "title":
                                                                  "Highest to Lowest",
                                                              "type": "change",
                                                              "order": "desc"
                                                            },
                                                            {
                                                              "title":
                                                                  "Lowest to Highest",
                                                              "type": "change",
                                                              "order": "asc"
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
                                      child: Container(
                                        height: 33,
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color: colorBlue, width: 1.25),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Sort By",
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
                                    )
                                  : Container(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Container(
                              height: 1.25,
                              width: MediaQuery.of(context).size.width,
                              color: Color(0xffeaeaea),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: listPortfoliosForWeb(),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listPortfoliosForWeb() {
    List<Widget> _listPortfoliosForWeb = [];
    widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
      if (portfolioMasterID != '0')
        _listPortfoliosForWeb.add(portfolioItem(portfolio));
    });
    return Column(
      children: [
        widget.model.userPortfoliosData.length < 1
            ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "No Portfolios",
                  style: portfolioBoxName,
                ),
              )
            : Container(),
        ListView(
          shrinkWrap: true,
          controller: controller,
          physics: AlwaysScrollableScrollPhysics(),
          children: _listPortfoliosForWeb,
        ),
      ],
    );
  }

  Widget portfolioItem(Map portfolio) {
    return portfolioMasterBoxForLarge(context, portfolio,
        refreshParent: refreshParent);
  }

  Widget _sortOptionSection({String title, List options}) {
    List<Widget> _children = [];
    options.forEach((element) {
      _children.add(_sortOptionRow(element));
    });
    return Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'nunito',
                    letterSpacing: 0.25,
                    color: Color(0xff383838))),
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
          sort(optionRow['type']);
          Navigator.of(context).pop();
        })
      },
      child: Container(
        padding: EdgeInsets.only(top: 12),
        child: Text(optionRow['title'],
            style: PlatformCheck.isSmallScreen(context)
                ? sortType == optionRow['type'] &&
                        sortOrder == optionRow['order']
                    ? sortbyOptionActive.copyWith(color: colorBlue)
                    : sortbyOption
                : sortType == optionRow['type'] &&
                        sortOrder == optionRow['order']
                    ? TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'nunito',
                        letterSpacing: 0.20,
                        color: colorBlue)
                    : TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'nunito',
                        letterSpacing: 0.20,
                        color: Color(0xff383838))),
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

  _currencySelectionForWeb(String currencyValues) async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> responseData =
        await widget.model.changeCurrency(currencyValues);
    if (responseData['status'] == true) {
      await widget.model.fetchOtherData();
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _portfolioValues() {
    List<Widget> _children = [];
    if (widget.model.portfolioTotalSummary != null) {
      widget.model.portfolioTotalSummary.forEach((zone, value) {
        _children.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: _portfolioSummaryBox(zone, value),
        ));
      });
    }

    return Container(
        // height: (90 * rowCount),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 0.25,
              color: Color(0x251e1e1e),
            ),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Wrap(direction: Axis.horizontal, children: _children));
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
    return Container(
      width: 300,
      height: 65,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xffe9e9e9),
          width: 1.25,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(zoneString.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'nunito',
                  letterSpacing: 0.8,
                  color: Color(0xff272727))),
          Text(removeDecimal(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'nunito',
                  letterSpacing: 0.32,
                  color: Color(0xff8a8a8a))),
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
