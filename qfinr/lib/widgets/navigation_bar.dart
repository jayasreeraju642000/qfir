import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';
import 'package:qfinr/utils/risk_profile_mapper.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';
import 'styles.dart';

int _themeColor = 0xFF535971;

class NavigationTobBar extends StatefulWidget {
  final MainModel model;
  final Function openDrawer;
  final invite_avilable;

  NavigationTobBar(this.model, {this.openDrawer, this.invite_avilable});

  @override
  State<StatefulWidget> createState() {
    return _NavigationTobBarState();
  }
}

class _NavigationTobBarState extends State<NavigationTobBar> {
  List<RICs> _searchList = [];
  RICs selectedRICs;
  TextEditingController _popupSearchFieldController = TextEditingController();
  StateSetter _setState;

  bool _showSearchLoader = false;

  OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(
      color: Color(0xffeeeeee),
    ),
  );

  Future<Null> _analyticsLogoutEvent() async {
    FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "universal",
      'item_name': "universal_signout",
      'content_type': "signout_button",
    });
  }

  Future<Null> _analyticsRiskToleranceEvent() async {
    FirebaseAnalytics().logEvent(name: 'tutorial_begin', parameters: {
      'item_id': "home",
      'item_name': "home_quick_links",
      'content_type': "discover_your_risk_tolerance_button",
    });
  }

  Future<Null> _analyticFaqEvent() async {
    FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_have_questions",
      'content_type': "query_button",
    });
  }

  var invite_available_count;
  bool envelope_ic = false;

  void getReferralCode() async {
    final response_referal_code = await widget.model.getReferralCode();
    var available;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (response_referal_code['status'] == true) {
      available = response_referal_code['response']['available'];
      await prefs.setInt('invite_available_count', available);
    } else {
      available = 0;
      await prefs.setInt('invite_available_count', available);
    }

    getSharepref_available();
  }

  void getSharepref_available() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      invite_available_count = prefs.getInt('invite_available_count');
      envelope_ic = true;
    });
  }

  @override
  void initState() {
    _popupSearchFieldController.addListener(() {
      if (_popupSearchFieldController.text.length >= 3) {
        _showSearchLoader = true;
      }
    });

    if (widget.invite_avilable == true) {
      getReferralCode();
    } else {
      getSharepref_available();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            deviceType == DeviceScreenType.tablet
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.openDrawer(),
                    child: Container(
                      margin: EdgeInsets.all(
                        12,
                      ),
                      child: svgImage(
                        'assets/icon/icon_menu.svg',
                        color: Colors.black,
                      ),
                    ),
                  )
                : Container(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed("/home_new"),
                child: Container(
                  width: 150,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: svgImage('assets/images/logo_in_white_background.svg'),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _searchPopUp(model),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Color(0xffc2cfe0),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      deviceType == DeviceScreenType.tablet
                          ? emptyWidget
                          : Text(
                              "Global search",
                              style: TextStyle(
                                color: Color(0xff90a0b7),
                                fontSize: ScreenUtil().setSp(14.0),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'nunito',
                              ),
                            ),
                    ],
                  ),
                )
                // deviceType == DeviceScreenType.tablet
                //     ?
                // GestureDetector(onTap: () => _searchPopUp(model) ,child: Icon(Icons.search))
                // : searchBar(model),
                ),
            Expanded(
                child: Container(
              // color: Colors.orange,
              child: Padding(
                padding: const EdgeInsets.only(right: 30.0, left: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: TextButton(
                        onPressed: () async {
                          await _analyticFaqEvent();
                          const url = 'https://www.qfinr.com/faq/';
                          if (await canLaunch(url)) {
                            await launch(url,
                                forceWebView: true, enableJavaScript: true);
                          }
                        },
                        child: Text(
                          "FAQ",
                          style: TextStyle(
                            color: Color(0xff383838),
                            fontSize: ScreenUtil().setSp(14.0),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'nunito',
                          ),
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/inviteFriends',
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                            margin: const EdgeInsets.only(
                              left: 10.0,
                              right: 10.0,
                            ),
                            child: Visibility(
                              visible: envelope_ic,
                              child: Image.asset(
                                invite_available_count != 0
                                    ? "assets/images/envelope_notify_ic.png"
                                    : "assets/images/envelope.png",
                                fit: BoxFit.contain,
                                height: 20,
                                width: 20,
                              ),
                            )),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/notification");
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: Image.asset(
                            "assets/icon/icon_other_notifications.png",
                            fit: BoxFit.contain,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: deviceType == DeviceScreenType.tablet
                              ? getScaledValue(12.0)
                              : 16.0,
                          vertical: deviceType == DeviceScreenType.tablet
                              ? getScaledValue(12.0)
                              : 16.0,
                        ),
                        textStyle: TextStyle(color: colorBlue),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Color(0xffe9e9e9),
                            width: 0.75,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () async {
                        await _analyticsRiskToleranceEvent();
                        Navigator.of(context).pushReplacementNamed(
                            "/riskProfilerFromTopMenuBar");
                      },
                      child: RichText(
                        text: TextSpan(
                          text: model.userRiskProfile != null
                              ? 'Your Risk Tolerance\n'
                              : "",
                          style: TextStyle(
                            fontSize: getScaledValue(10.0),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'nunito',
                            color: Color(0xff161616),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: model.userRiskProfile == null
                                  ? "Take Risk Profile"
                                  : RiskProfileMapper.convertToReadableString(
                                      model.userRiskProfile,
                                    ),
                              style: TextStyle(
                                fontSize: getScaledValue(12.0),
                                fontWeight: FontWeight.w800,
                                fontFamily: 'nunito',
                                color: colorBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: (!model.isUserAuthenticated ||
                              (model.isUserAuthenticated &&
                                  model.userData.displayImage == 'noImage')
                          ? Container(
                              width: 60.0,
                              height: 40.0,
                              child: CircleAvatar(
                                backgroundColor: colorBlue,
                                minRadius: 40.0,
                                child: Text(
                                  model.isUserAuthenticated
                                      ? model.userData.custFirstName
                                              .substring(0, 1)
                                              .toUpperCase() +
                                          model.userData.custLastName
                                              .substring(0, 1)
                                              .toUpperCase()
                                      : "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 60.0,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                      NetworkImage(model.userData.displayImage),
                                ),
                              ),
                            )),
                    ),
                    Container(
                      height: 15,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 15,
                          ),
                          hint: Text(
                            model.isUserAuthenticated
                                ? model.userData.custName
                                : "Guest",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(12.0),
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          items: <String>["Logout"].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(
                                value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(12.0),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (_) async {
                            await _analyticsLogoutEvent();
                            model.logout();
                            Navigator.pushReplacementNamed(context, '/login');
                            changeStatusBarColor(Colors.white);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ]),
        ),
      );
    });
  }

  //-----------------------------------------------------------------------------------------

  void _searchPopUp(MainModel model) {
    setState(() {
      selectedRICs = null;
      _popupSearchFieldController.clear();
      _searchList = [];
      _showSearchLoader = false;
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
                    _searchBody(model),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Qfinr Smart Search\n",
              style: appBenchmarkPortfolioName,
            ),
            Text(
              "To search for any asset, you can either type the name in full (for ex: Reliance Industries), or use our Smart Search feature. Smart Search makes it faster and more efficient for you to access your favorite stocks, ETFs, or mutual funds\n",
              style: bodyText4,
            ),
            Text(
              "To use Smart Search, before you type the name that you are looking to search, just type in one of the letters shown below followed by a space:\n",
              style: bodyText4,
            ),
            Text(
              "'s' - to search for stocks (ex: 's nippon')",
              style: bodyText4,
            ),
            Text(
              "'e' - to search for ETFs (ex: 'e nippon')",
              style: bodyText4,
            ),
            Text(
              "'f' - to search for Mutual Funds (ex: 'f nippon')",
              style: bodyText4,
            ),
          ],
        ),
      ),
    );
  }

  _searchBody(MainModel model) {
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
                'Enter instrument name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'nunito',
                  letterSpacing: 0.26,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: _searchBox(model),
            ),
            divider(),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: resetButton(
                'Cancel',
                borderColor: colorBlue,
                textColor: colorBlue,
                onPressFunction: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox(MainModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _popupsearchfield(model),
          _popupSearchList(model),
        ],
      ),
    );
  }

  Widget _popupsearchfield(MainModel model) {
    return TextField(
      autofocus: true,
      controller: _popupSearchFieldController,
      keyboardType: TextInputType.text,
      onChanged: (String value) {
        _setState(() {
          selectedRICs = null;
        });
        if (value.length >= 3) {
          _getALlPosts(value, model);
        } else {
          _setState(() {
            _searchList = [];
          });
        }
      },
      onSubmitted: (value) {
        if (value.length >= 3) {
          _getALlPosts(value, model);
        } else {
          _setState(() {
            _searchList = [];
          });
        }
      },
      style: inputFieldStyle,
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color(0xff9f9f9f),
          letterSpacing: 1.0,
        ),
        enabledBorder: _border,
        disabledBorder: _border,
        focusedBorder: _border,
        errorBorder: _border,
        prefixIcon: Icon(
          Icons.search,
          color: colorActive,
        ),
      ),
    );
  }

  Widget _popupSearchList(MainModel model) {
    return Expanded(
      child: _showSearchLoader
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _searchList.length == 0
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    'No record found',
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Color(0xff3c4257),
                        ),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchList.length ?? 0,
                  itemBuilder: (context, index) {
                    Map element = {
                      'ric': _searchList[index].ric,
                      'name': _searchList[index].name,
                      'type': _searchList[index].fundType,
                      'zone': _searchList[index].zone,
                    };
                    return fundBoxForFiltration1(
                      context,
                      element,
                      onTap: () {
                        formResponse(
                          model,
                          singleRIC: true,
                          ric: element['ric'],
                          ricType: element['type'],
                        );
                      },
                      isSelected: selectedRICs == null
                          ? false
                          : selectedRICs.ric == _searchList[index].ric
                              ? true
                              : false,
                      isSearch: true,
                    );
                  },
                ),
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
        margin: EdgeInsets.symmetric(vertical: 8),
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
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(limitChar(portfolio['name'], length: 35),
                style: portfolioBoxName),
            SizedBox(height: 10),
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
                      textColor: Color(0xffa7a7a7),
                    ),
                    SizedBox(width: 7),
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

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // Widget searchBar(MainModel model) => Container(
  //   height: 40,
  //   width: 250,
  //   child: TypeAheadFormField(
  //     onSuggestionSelected: (RICs value) {
  //       formResponse(
  //         model,
  //         singleRIC: true,
  //         ric: value.ric,
  //         ricType: value.fundType,
  //       );
  //     },
  //     itemBuilder: (context,itemData){
  //       return ListTile(title: Text(itemData.name));
  //     },
  //     suggestionsCallback: (pattern) {
  //       if (pattern.length >= 3) {
  //         return _getALlPosts(pattern, model);
  //       } else {
  //         return null;
  //       }

  //     },
  //     textFieldConfiguration: TextFieldConfiguration(
  //       // controller: null,
  //       // focusNode: null,
  //       onSubmitted: (value) {},
  //       style: TextStyle(),
  //       decoration: new InputDecoration(
  //         icon: new Icon(Icons.search),
  //         labelText: "Global search",
  //         enabledBorder: const OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(0.0)),
  //           borderSide: const BorderSide(
  //             color: Colors.grey,
  //           ),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(0.0)),
  //           borderSide: BorderSide(color: Colors.grey),
  //         ),
  //       ),
  //     ),

  //   ),
  // );

  _getALlPosts(String search, MainModel model) async {
    List funds = await model.getFundName(search, 'all');
    List<RICs> searchList = List.generate(funds.length, (int index) {
      return RICs(
        ric: funds[index]['ric'],
        name: funds[index]['name'],
        zone: funds[index]['zone'],
        fundType: funds[index]['type'],
      );
    });

    _setState(() {
      _searchList = searchList;
      _showSearchLoader = false;
    });
  }

  //  Future<List<RICs>> _getALlPosts(String search,MainModel model) async {
  //       // MainModel model;
  //   var funds = await model.getFundName(search, 'all');
  //   //await Future.delayed(Duration(seconds: 2));
  //   List<RICs> _searchList = List.generate(funds.length, (int index) {
  //     return RICs(
  //         ric: funds[0]['ric'],
  //         name: funds[index]['name'],
  //         zone: funds[index]['zone'],
  //         fundType: funds[index]['type'],
  //         latestPriceBase: funds[index]['latestPriceBase'],
  //         latestPriceString: funds[index]['latestPrice'],
  //         latestCurrencyPriceString: funds[index]['latestCurrencyPrice']);
  //   });

  //   return _searchList;

  //   // _setState(() {
  //   //   searchList = _searchList;
  //   // });
  //   // log.d("--------------------------------------");
  //   // log.d("search list length ==> ${searchList.length}");
  // }

  void formResponse(MainModel model,
      {bool singleRIC = false, String ric = "", String ricType}) async {
    if (['Funds', 'ETF'].contains(ricType)) {
      Navigator.pop(context);
      _showNavigationLoaderPopUp();
      Map<String, dynamic> responseData;
      if (singleRIC) {
        responseData = await model.knowYourPortfolio({
          ric: {'ric': ric}
        });
      } else {
        responseData = await model.knowYourPortfolio(
            model.userPortfoliosData[model.defaultPortfolioSelectorKey]
                ['portfolios']);
      }

      if (responseData['status']) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/knowFundReport',
            arguments: {'responseData': responseData});
      } else {
        Navigator.pop(context);
        showAlertDialogBox(context, 'Error!', responseData['response']);
      }
    } else {
      Navigator.pop(context);
      Navigator.of(context).pushNamed('/fund_info', arguments: {'ric': ric});
    }
  }

  void _showNavigationLoaderPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            padding: EdgeInsets.all(50),
            width: 560,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      svgImage(
                        'assets/icon/icon_analyzer_loader.svg',
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Fetching your details…',
                        style: preLoaderBodyText1,
                      ),
                    ],
                  ),
                ),
                Text(
                  'HOLD ON TIGHT',
                  style: preLoaderBodyText2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//---------------------------------------------------------------------------------------
}

class NavigationLeftBar extends StatefulWidget {
  final int isSideMenuHeadingSelected;
  final int isSideMenuSelected;

  //NavigationLeftBar(this.model, {this.isSideMenuHeadingSelected}); // add_portfolio // add_instrument_new_portfolio//
  //
  const NavigationLeftBar(
      {Key key,
      @required this.isSideMenuHeadingSelected,
      @required this.isSideMenuSelected})
      : super(
          key: key,
        );

  @override
  State<StatefulWidget> createState() {
    return _NavigationLeftBarState();
  }
}

class _NavigationLeftBarState extends State<NavigationLeftBar> {
  bool openMyPortfolioInSideMenuBar = false;
  bool openAnalyseInSideMenuBar = false;
  bool openDiscoverInSideMenuBar = false;
  int isSideMenuSelected = 0;
  int isSideMenuHeadingSelected = 0;
  String currencyValues;

  @override
  void initState() {
    super.initState();
    setState(() {
      isSideMenuHeadingSelected = widget.isSideMenuHeadingSelected;
      isSideMenuSelected = widget.isSideMenuSelected;

      if (isSideMenuHeadingSelected == 1) {
        openMyPortfolioInSideMenuBar = true;
      }

      if (isSideMenuHeadingSelected == 2) {
        openAnalyseInSideMenuBar = true;
      }

      if (isSideMenuHeadingSelected == 3) {
        openDiscoverInSideMenuBar = true;
      }
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

    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        color: Colors.white,
        width: 250,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.027,
              ),
              Container(
                  child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      isSideMenuSelected = 0;
                      isSideMenuHeadingSelected = 0;

                      Navigator.pushReplacementNamed(context, '/home_new');
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image.asset(
                          "assets/icon/web_side_menu_bar_home.png",
                          width: 16,
                          height: 16,
                          color: isSideMenuSelected == 0 &&
                                  isSideMenuHeadingSelected == 0
                              ? Color(0xff034bd9)
                              : Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text("Dashboard",
                            style: isSideMenuSelected == 0 &&
                                    isSideMenuHeadingSelected == 0
                                ? header_nav_left_blue
                                : header_nav_left_black),
                      )
                    ],
                  ),
                ),
              )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.027,
              ),
              Container(
                  child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      openMyPortfolioInSideMenuBar
                          ? openMyPortfolioInSideMenuBar = false
                          : openMyPortfolioInSideMenuBar = true;
                      if (openMyPortfolioInSideMenuBar) {
                        isSideMenuHeadingSelected = 1;
                      }
                      // Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image.asset(
                          "assets/icon/web_side_menu_bar_my_portfolio.png",
                          width: 17.5,
                          color: isSideMenuHeadingSelected == 1
                              ? colorBlue
                              : Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "My Portfolio",
                          style: header_nav_left_black,
                        ),
                      ),
                      openMyPortfolioInSideMenuBar
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: RotatedBox(
                                quarterTurns: 2,
                                child: Image.asset(
                                    "assets/icon/web_side_menu_bar_down_arrow.png",
                                    width: 9,
                                    color: Colors.black),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Image.asset(
                                  "assets/icon/web_side_menu_bar_down_arrow.png",
                                  width: 10,
                                  color: Colors.black),
                            ),
                    ],
                  ),
                ),
              )),
              openMyPortfolioInSideMenuBar
                  ? Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        isSideMenuSelected = 1;
                                        Navigator.pushReplacementNamed(context,
                                            '/manage_portfolio_master_view');
                                      });
                                    },
                                    child: Text("Manage",
                                        style: isSideMenuSelected == 1 &&
                                                isSideMenuHeadingSelected == 1
                                            ? sub_header_nav_left_blue
                                            : sub_header_nav_left_black))),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      isSideMenuSelected = 2;
                                      Navigator.pushReplacementNamed(
                                          context, '/add_portfolio');
                                    });
                                  },
                                  child: Text("Add New",
                                      style: isSideMenuSelected == 2 &&
                                              isSideMenuHeadingSelected == 1
                                          ? sub_header_nav_left_blue
                                          : sub_header_nav_left_black),
                                ),
                              )),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.027,
              ),
              Container(
                  child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      openAnalyseInSideMenuBar
                          ? openAnalyseInSideMenuBar = false
                          : openAnalyseInSideMenuBar = true;
                      if (openAnalyseInSideMenuBar) {
                        isSideMenuHeadingSelected = 2;
                        widget.isSideMenuHeadingSelected == 2;
                        //  isSideMenuSelected = 0;
                      } else {
                        isSideMenuHeadingSelected = 2;
                        //  isSideMenuSelected = 0;
                      }
                      // String navigation = riskProfileSamplePortfolio(
                      //     model: model,
                      //     desiredPath:
                      //         'portfolio_master_selectors/analyzer/web',
                      //     riskProfilerPath: 'riskProfilerAlert/analyzer/web');
                      // var navigationArguments = {
                      //   'portfolioMasterID': '',
                      //   'layout': 'border',
                      //   'isSideMenuHeadingSelected':
                      //       isSideMenuHeadingSelected.toString(),
                      //   'isSideMenuSelected': isSideMenuSelected.toString(),
                      //   bool: openAnalyseInSideMenuBar
                      // };

                      // Navigator.pushNamed(context, navigation,
                      //     arguments: navigationArguments);
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image.asset(
                          "assets/icon/web_side_menu_bar_analyse.png",
                          width: 17.5,
                          color: isSideMenuHeadingSelected == 2
                              ? colorBlue
                              : Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text("Analyse", style: header_nav_left_black),
                      ),
                      openAnalyseInSideMenuBar
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: RotatedBox(
                                quarterTurns: 2,
                                child: Image.asset(
                                    "assets/icon/web_side_menu_bar_down_arrow.png",
                                    width: 9,
                                    color: Colors.black),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Image.asset(
                                  "assets/icon/web_side_menu_bar_down_arrow.png",
                                  width: 9,
                                  color: Colors.black),
                            ),
                    ],
                  ),
                ),
              )),
              openAnalyseInSideMenuBar
                  ? Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        isSideMenuSelected = 9;
                                        isSideMenuHeadingSelected = 2;
                                        Navigator.pushReplacementNamed(
                                            context, '/analyse_summary');
                                      });
                                    },
                                    child: Text("Summary",
                                        style: isSideMenuSelected == 9 &&
                                                isSideMenuHeadingSelected == 2
                                            ? sub_header_nav_left_blue
                                            : sub_header_nav_left_black))),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    isSideMenuSelected = 8;
                                    isSideMenuHeadingSelected = 2;

                                    String navigation = riskProfileSamplePortfolio(
                                        model: model,
                                        desiredPath:
                                            'portfolio_master_selectors/analyzer/web',
                                        riskProfilerPath:
                                            'riskProfilerAlert/analyzer/web');
                                    var navigationArguments = {
                                      'portfolioMasterID': '',
                                      'layout': 'border',
                                      'isSideMenuHeadingSelected':
                                          isSideMenuHeadingSelected.toString(),
                                      'isSideMenuSelected':
                                          isSideMenuSelected.toString(),
                                      bool: openAnalyseInSideMenuBar
                                    };

                                    Navigator.pushNamed(context, navigation,
                                        arguments: navigationArguments);
                                  });
                                },
                                child: Text("Portfolio Analyzer",
                                    style: isSideMenuSelected == 8 &&
                                            isSideMenuHeadingSelected == 2
                                        ? sub_header_nav_left_blue
                                        : sub_header_nav_left_black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    isSideMenuSelected = 3;
                                    isSideMenuHeadingSelected = 2;

                                    String navigation = model.userRiskProfile !=
                                            null
                                        ? "/portfolio_master_selectors/dividend"
                                        : "/riskProfilerAlert/dividend/web";
                                    var navigationArguments = {
                                      'portfolioMasterID': '',
                                      'layout': 'border',
                                      'isSideMenuHeadingSelected':
                                          isSideMenuHeadingSelected.toString(),
                                      'isSideMenuSelected':
                                          isSideMenuSelected.toString(),
                                      bool: openAnalyseInSideMenuBar
                                    };
                                    Navigator.pushNamed(context, navigation,
                                        arguments: navigationArguments);
                                  });
                                },
                                child: Text("Cashflow Forecast",
                                    style: isSideMenuSelected == 3 &&
                                            isSideMenuHeadingSelected == 2
                                        ? sub_header_nav_left_blue
                                        : sub_header_nav_left_black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      isSideMenuSelected = 4;
                                      isSideMenuHeadingSelected = 2;

                                      String navigation = model
                                                  .userRiskProfile !=
                                              null
                                          ? "/portfolio_master_selectors/stress"
                                          : "/riskProfilerAlert/dividend/web";
                                      var navigationArguments = {
                                        'portfolioMasterID': '',
                                        'layout': 'border',
                                        'isSideMenuHeadingSelected':
                                            isSideMenuHeadingSelected
                                                .toString(),
                                        'isSideMenuSelected':
                                            isSideMenuSelected.toString(),
                                        bool: openAnalyseInSideMenuBar
                                      };
                                      Navigator.pushNamed(context, navigation,
                                          arguments: navigationArguments);
                                    });
                                  },
                                  child: Text("Stress Test",
                                      style: isSideMenuSelected == 4 &&
                                              isSideMenuHeadingSelected == 2
                                          ? sub_header_nav_left_blue
                                          : sub_header_nav_left_black),
                                )),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.027,
              ),
              Container(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        openDiscoverInSideMenuBar
                            ? openDiscoverInSideMenuBar = false
                            : openDiscoverInSideMenuBar = true;
                        if (openDiscoverInSideMenuBar) {
                          isSideMenuHeadingSelected = 3;
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Image.asset(
                            "assets/icon/web_side_menu_bar_discover.png",
                            width: 17.5,
                            color: isSideMenuHeadingSelected == 3
                                ? colorBlue
                                : Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Discover",
                            style: isSideMenuHeadingSelected == 3
                                ? header_nav_left_blue
                                : header_nav_left_black,
                          ),
                        ),
                        openDiscoverInSideMenuBar
                            ? Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: RotatedBox(
                                  quarterTurns: 2,
                                  child: Image.asset(
                                      "assets/icon/web_side_menu_bar_down_arrow.png",
                                      width: 9,
                                      color: Colors.black),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Image.asset(
                                    "assets/icon/web_side_menu_bar_down_arrow.png",
                                    width: 9,
                                    color: Colors.black),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              openDiscoverInSideMenuBar
                  ? Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    isSideMenuSelected = 5;
                                    Navigator.pushNamed(
                                      context,
                                      '/discoverLarge',
                                    );
                                  });
                                },
                                child: Text(
                                  "Market Insights",
                                  style: isSideMenuSelected == 5 &&
                                          isSideMenuHeadingSelected == 3
                                      ? sub_header_nav_left_blue
                                      : sub_header_nav_left_black,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      isSideMenuSelected = 6;
                                      Navigator.pushReplacementNamed(
                                          context, '/exploreIdeas');
                                    });
                                  },
                                  child: Text("Intelli-Screener",
                                      style: isSideMenuSelected == 6 &&
                                              isSideMenuHeadingSelected == 3
                                          ? sub_header_nav_left_blue
                                          : sub_header_nav_left_black),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      isSideMenuSelected = 7;
                                      Navigator.pushNamed(context,
                                          '/discoverKnowYorAssetLargeScreen');
                                    });
                                  },
                                  child: Text("Know your Assets",
                                      style: isSideMenuSelected == 7 &&
                                              isSideMenuHeadingSelected == 3
                                          ? sub_header_nav_left_blue
                                          : sub_header_nav_left_black),
                                )),
                          )
                        ],
                      ),
                    )
                  : Container(),
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.027,
              // ),
              // Container(
              //   // color: Colors.teal,
              //   child: GestureDetector(
              //     behavior: HitTestBehavior.opaque,
              //     onTap: () {
              //       setState(() {
              //         isSideMenuSelected = 8;
              //         isSideMenuHeadingSelected = 4;
              //       });
              //     },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.only(right: 5.0),
              //           child: Image.asset(
              //             "assets/icon/web_side_menu_bar_my_account.png",
              //             width: 17.5,
              //             color: isSideMenuSelected == 8 &&
              //                     isSideMenuHeadingSelected == 4
              //                 ? colorBlue
              //                 : Colors.grey,
              //           ),
              //         ),
              //         Expanded(
              //           child: Text("My Account",
              //               style: isSideMenuSelected == 8
              //                   ? header_nav_left_blue
              //                   : header_nav_left_black),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.027,
              ),
              kIsWeb
                  ? Container()
                  : Container(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Share.share(
                              'check out this amazing app https://www.qfinr.com/join',
                              subject: 'Look what I found!',
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Icon(
                                  Icons.share,
                                  color: Color(_themeColor),
                                  size: 22.0,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Share",
                                  style: isSideMenuHeadingSelected == 3
                                      ? header_nav_left_blue
                                      : header_nav_left_black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              // ListTile(
              // leading: Icon(
              //   Icons.share,
              //   color: Color(_themeColor),
              //   size: 22.0,
              // ),
              //     title: TextThemeColor("Share"),
              //     onTap: () {
              // Share.share(
              //   'check out this amazing app https://www.qfinr.com/join',
              //   subject: 'Look what I found!',
              // );
              //     },
              //   ),
              // Expanded(
              //   child: kIsWeb
              //       ? Container(
              //           padding: const EdgeInsets.only(bottom: 30.0),
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.end,
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.all(2.0),
              //                 child: Image.asset(
              //                   "assets/images/upgradeToPro.png",
              //                   width: MediaQuery.of(context).size.width * 0.1,
              //                   height:
              //                       MediaQuery.of(context).size.height * 0.1,
              //                 ),
              //               ),
              //               Container(
              //                 padding: const EdgeInsets.only(
              //                   bottom: 20.0,
              //                   top: 20,
              //                   left: 20,
              //                   right: 20,
              //                 ),
              //                 color: Color(0xffF6F9FF),
              //                 child: Column(
              //                   children: [
              //                     Text(
              //                       "Upgrade to Pro",
              //                       style: TextStyle(
              //                           color: Colors.black,
              //                           fontWeight: FontWeight.w400,
              //                           fontSize: 12),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(top: 2.0),
              //                       child: Text(
              //                         "Make the most of your app with premium",
              //                         textAlign: TextAlign.center,
              //                         style: TextStyle(
              //                             color: Colors.grey,
              //                             fontWeight: FontWeight.w600,
              //                             fontSize: 12),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               )
              //             ],
              //           ),
              //         )
              //       : Container(),
              // ),
            ],
          ),
        ),
      );
    });
  }
}

// ignore: todo
// TODO : Navigation screen : shariyath
PreferredSizeWidget smallScreenScrollAppBar(
    {ScrollController controller,
    Color iconColor,
    Color bgColor = appBarBGColor,
    Brightness brightness,
    String title = "",
    List<Widget> actions,
    PreferredSizeWidget bottom,
    Widget leading}) {
  return ScrollAppBar(
    controller: controller,
    elevation: 0,
    titleSpacing: 5.0,
    leading: leading,
    backgroundColor: bgColor,
    iconTheme: IconThemeData(
        color: iconColor != null
            ? iconColor
            : bgColor == Colors.white || bgColor == Color(0xffefd82b)
                ? Colors.black
                : Colors.white),
    brightness: brightness != null
        ? brightness
        : (bgColor == Colors.white ? Brightness.light : Brightness.dark),
    actions: actions,
    bottom: bottom,
    title: Text(
      title,
      style: TextStyle(
          color: bgColor == Colors.white || bgColor == Color(0xffefd82b)
              ? Colors.black
              : Colors.white),
    ),
  );
}

class WidgetNavigationDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WidgetNavigationDrawerState();
  }
}

class _WidgetNavigationDrawerState extends State<WidgetNavigationDrawer> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Qfinr',
    packageName: 'Unknown',
    version: '1.0.0',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initPackageInfo();
    }
  }

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 160.0,
                      //padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: DrawerHeader(
                          margin: EdgeInsets.all(0.0),
                          child: Row(
                            children: <Widget>[
                              (!model.isUserAuthenticated ||
                                      (model.isUserAuthenticated &&
                                          model.userData.displayImage ==
                                              'noImage')
                                  ? Container(
                                      width: 60.0,
                                      height: 60.0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        minRadius: 40.0,
                                        child: Text(model.isUserAuthenticated
                                            ? model.userData.custFirstName
                                                    .substring(0, 1)
                                                    .toUpperCase() +
                                                model.userData.custLastName
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                            : "G"),
                                      ),
                                    )
                                  : Container(
                                      width: 60.0,
                                      height: 60.0,
                                      decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(model
                                                  .userData.displayImage))))),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  model.isUserAuthenticated
                                      ? model.userData.custName
                                      : "Guest",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          )),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff0445e4), Color(0xff0033cc)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    /*
							Divider(
								color: Color(_themeColor),
								height: 1.0,
							), */

                    /* ListTile(
								leading: new Icon(
								Icons.text_format,
								color: Color(_themeColor),
								size: 22.0,
								),
								title: TextThemeColor(languageText('text_change_language') ),
								onTap: () {
								Navigator.pushNamed(context, '/languageSelector');
								},
							) ,
							 */
                    /* model.isUserAuthenticated ?
								ListTile(
									leading: new Icon(
									Icons.settings,
									color: Color(_themeColor),
									size: 22.0,
									),
									title: TextThemeColor(languageText('text_settings') ),
									onTap: () {
									Navigator.pushNamed(context, '/settings');
									},
								):
								emptyWidget ,

							ListTile(
								leading: SizedBox(
									height: 22,
									width: 22,
									child: Image.asset("assets/flag/"+ model.userSettings['default_zone'] +".png"),
								),
								title: TextThemeColor('Zone' ),
								onTap: () {
									Navigator.pushNamed(context, '/zoneSelector');
								},
							), */

                    /* IconButton(
								icon: Image.asset("assets/flag/"+ model.userSettings['default_zone'] +".png"),
								iconSize: 48.0, //, color: Color(0xFF0F52BA),),
								onPressed: () {
									Navigator.pushNamed(context, '/zoneSelector');
								},
							), */

                    model.isUserAuthenticated
                        ? ListTile(
                            leading: Icon(
                              Icons.exit_to_app,
                              color: Color(_themeColor),
                              size: 22.0,
                            ),
                            title:
                                TextThemeColor(languageText('text_signout_l')),
                            onTap: () {
                              model.logout();
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/login');
                              changeStatusBarColor(Colors.white);
                            },
                          )
                        : ListTile(
                            leading: new Icon(
                              Icons.lock_outline,
                              color: Color(_themeColor),
                              size: 22.0,
                            ),
                            title: TextThemeColor(
                                languageText('text_signin_l') +
                                    ' / ' +
                                    languageText('text_signup_l')),
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          ),

                    /* model.isUserAuthenticated ?
								ListTile(
								leading: new Icon(
									Icons.account_box,
									color: Color(_themeColor),
									size: 22.0,
								),
								title: TextThemeColor('My Account'),
								onTap: () {
									Navigator.pushReplacementNamed(context, '/home');
								},
								)
								: Container(), */
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 0,
                child: Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  padding: EdgeInsets.all(20.0),
                  alignment: FractionalOffset.bottomCenter,
                  //color: Colors.white,
                  child: widgetAppDetails(context),
                )),
          ],
        ),
      );
    });
  }

  Widget widgetAppDetails(BuildContext context) {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.end,
      direction: Axis.vertical,
      children: <Widget>[
        //Image.asset('assets/images/logo_white.png', fit: BoxFit.fill, height: 20.0,),
        //widgetAppDetailItem('Multiiplyy'), ///_packageInfo.appName),
        //widgetAppDetailItem(' (Elitio Technologies Private Limited) '),
        //widgetAppDetailItem(' SEBI Registered Investment Advisor (#INA100006588)'),
        !kIsWeb
            ? widgetAppDetailItem('App Version: ' + _packageInfo.version)
            : widgetAppDetailItem('App Version: ' + "0.0.0"),
      ],
    );
  }

  Widget widgetAppDetailItem(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white30, fontSize: 12.0),
      textAlign: TextAlign.center,
    );
  }
}
