import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/disclaimer_alert.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

final log = getLogger('HomePageNew');

class HomePageSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String basketIndex = '1';

  HomePageSmall(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _HomePageSmallNewState();
  }
}

class _HomePageSmallNewState extends State<HomePageSmall> {
  final controller = ScrollController();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showGraph = true;
  int counter = 1;

  BasketResponse basketResponse;

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollBottomBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;

  PageIndicatorController pageViewController;
  bool _isLoading = true;

  List<FlSpot> flSpotList = [];

  dynamic notifications;

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n analyticsCurrentScreen called \n");
    await widget.analytics
        .setCurrentScreen(screenName: 'home', screenClassOverride: 'home');
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Home Page",
    });
  }

  Future<Null> _analyticsViewDetailsEvent() async {
    // log.d("\n analyticsViewDetailsEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_top_viewdetails",
      'content_type': "link_button",
    });
  }

  Future<Null> _analyticsRefreshEvent() async {
    // log.d("\n analyticsRefreshEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_refresh",
      'content_type': "refresh_button",
    });
  }

  Future<Null> _analyticsMarketSentimentEvent() async {
    // log.d("\n analyticsMarketSentimentEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_market_sentiment",
      'content_type': "more_button",
    });
  }

  Future<Null> _analyticsDiscoverRiskTolerenceEvent() async {
    // log.d("\n analyticsDiscoverRiskTolerenceEvent called \n");
    await widget.analytics.logEvent(name: 'tutorial_begin', parameters: {
      'item_id': "home",
      'item_name': "home_quick_links",
      'content_type': "discover_your_risk_tolerance_button",
    });
  }

  Future<Null> _analyticsSetYourGoalsEvent() async {
    // log.d("\n _analyticsSetYourGoalsEvent called \n");
    await widget.analytics.logEvent(name: 'tutorial_begin', parameters: {
      'item_id': "home",
      'item_name': "home_quick_links",
      'content_type': "set_your_goals_button",
    });
  }

  Future<Null> _anlyticsAlertEvent() async {
    // log.d("\n anlyticsAlertEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_alerts",
      'content_type': "click_alert",
    });
  }

  Future<Null> _analyticsHaveQns() async {
    // log.d("\n analyticsHaveQns called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_have_questions",
      'content_type': "query_button",
    });
  }

  Map<dynamic, dynamic> response_ip_v;
  var invite_available_count;

  @override
  void initState() {
    apiCalls();
    super.initState();
  }

  Future<void> apiCalls() async {
    setState(() {
      _isLoading = true;
    });
    await getReferralCode();

    await getIpAddress();

    int maxCount = 15;
    int counter = 1;
    widget.model.portfolioGraphData.forEach((element) {
      if (counter < maxCount) {
        flSpotList.add(FlSpot(double.parse(element[0].toString()),
            double.parse(element[1].toString())));
        counter++;
      }
    });

    // setState(() {
    //widget.model.setLoader(false);

    widget.model.redirectBase = "/home_new";
    // });
    _analyticsCurrentScreen();
    _analyticsAddEvent();

    await getModels();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getReferralCode() async {
    final response_referal_code = await widget.model.getReferralCode();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (response_referal_code['status'] == true) {
      invite_available_count = response_referal_code['response']['available'];
      await prefs.setInt('invite_available_count', invite_available_count);
    } else {
      invite_available_count = 0;
      await prefs.setInt('invite_available_count', invite_available_count);
    }
  }

  Future<void> getIpAddress() async {
    final ipv4 = await Ipify.ipv4();
    log.d(ipv4);

    await validateIP(ipv4);
  }

  validateIP(ipv4) async {
    response_ip_v = await widget.model.validateIP(ipv4);
    // response_ip_v =
    //     await widget.model.validateIP('119.73.137.211'); // singapore ip
    if (response_ip_v['status'] == false) {
      var popuptitle = response_ip_v['popuptitle'];
      var popupbody = response_ip_v['popupbody'];

      log.d("Testing ip valid response");
      log.d(popuptitle);
      log.d(popupbody);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var _year = prefs.getInt('Year');
      var _month = prefs.getInt('Month');
      var _date = prefs.getInt('Date');
      if (_year != null) {
        final stored_date = DateTime(_year, _month, _date);
        final currentDate = DateTime.now();

        final diff_dy = currentDate.difference(stored_date).inDays;

        log.d("diff_dy");
        log.d(diff_dy);

        if (diff_dy >= 7) {
          showModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: ((BuildContext context) {
                return DisClaimDialog(popuptitle, popupbody);
              }))
            ..then((value) {
              if (value == 'Decline') {
                logout();
              }
            });
        }
      } else {
        showModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: ((BuildContext context) {
              return DisClaimDialog(popuptitle, popupbody);
            })).then((value) {
          if (value == 'Decline') {
            logout();
          }
        });
      }
    }
  }

  void logout() async {
    widget.model.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> getModels() async {
    notifications = await widget.model.getLocalNotification();

    if (notifications.isNotEmpty) {
    } else {
      await widget.model.getCustomerNotifications();
      notifications = await widget.model.getLocalNotification();
    }

    await widget.model.getCustomerSettings();

    setState(() {
      notifications = notifications.values.toList();
    });

    try {
      if (!kIsWeb) {
        final PackageInfo info = await PackageInfo.fromPlatform();
        var responseData = await widget.model.getAppVersion();

        if (info.version.compareTo(responseData['response']) < 0) {
          loadBottomSheet(
            context: context,
            content: appUpdatePopup(),
            dismissable: false,
          );
        }
      }
    } catch (e) {}

    basketResponse = await widget.model.getLocalMIBaskets();
  }

  Widget appUpdatePopup() {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: getScaledValue(16), vertical: getScaledValue(30)),
        child: Column(
          children: [
            Text("We have upgraded".toUpperCase(),
                style: importPortfolioHelpTitle.copyWith(color: colorBlue)),
            SizedBox(height: getScaledValue(16)),
            Text("Download the latest version of the app to continue",
                textAlign: TextAlign.center, style: keyStatsBodyText4),
            SizedBox(height: getScaledValue(24)),
            gradientButton(
                context: context,
                caption: "CLOSE",
                onPressFunction: () =>
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'))
          ],
        ));
  }

  refreshParent() => setState(() {});

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          setState(() {
            isScrollingDown = true;
            _showAppbar = false;
          });
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          setState(() {
            isScrollingDown = false;
            _showAppbar = true;
          });
        }
      }
    });
  }

  PreferredSizeWidget _appbarMenuIconWeb() {
    return AppBar(
      backgroundColor: Color(0xff0445e4),
      elevation: 0.0,
      title: Text(""),
      // actions: <Widget>[
      //   IconButton(
      //     icon: invite_available_count!=0?const Icon(Icons.mark_email_unread_outlined):const Icon(Icons.email_outlined),
      //     color: Colors.white,
      //     tooltip: 'Invite friends',
      //     onPressed: () {
      //       Navigator.pushNamed(
      //         context,
      //         '/inviteFriends',
      //       ).then((_) => changeStatusBarColor(appBarBGColor));

      //       //  Navigator.pushNamed(context, navigation,
      //       //             arguments: navigationArguments)
      //       //         .then((_) => changeStatusBarColor(appBarBGColor));
      //     },
      //   ),
      // ],
    );
  }

  PreferredSizeWidget _mainAppBar() {
    return ScrollAppBar(
      controller: controller,
      elevation: 0.0,
      /* titleSpacing: 5.0, */
      titleSpacing: 0.0,
      leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _scaffoldKey.currentState.openDrawer(),
          child: Container(
            margin:
                EdgeInsets.all(getScaledValue(Platform.isAndroid ? 17 : 12)),
            height: getScaledValue(5),
            child: svgImage(
              'assets/icon/icon_menu.svg',
            ),
          )),
      backgroundColor: Color(
          0xff0445e4), // Theme.of(context).primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
      iconTheme: IconThemeData(color: Colors.white),

      // actions: <Widget>[
      //   IconButton(
      //      icon: invite_available_count!=0?const Icon(Icons.mark_email_unread_outlined):const Icon(Icons.email_outlined),
      //     color: Colors.white,
      //     tooltip: 'Invite friends',
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/inviteFriends')
      //           .then((_) => changeStatusBarColor(Color(0xff0445e4)));
      //     },
      //   ),
      // ], //Theme.of(context).primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
			statusBarColor: Color(0xff0445e4), //or set color with: Color(0xFF0000FF)
		)); */

    //ScreenUtil.init(context, designSize: Size(360, 740), allowFontScaling: true);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);

    changeStatusBarColor(Color(0xff0445e4));
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (widget.model.isLoading) {
        return preLoader();
      } else {
        return Scaffold(
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          appBar: !kIsWeb
              ? _showAppbar
                  ? _mainAppBar()
                  : _appbarMenuIconWeb()
              : _appbarMenuIconWeb(),
          bottomNavigationBar: widgetBottomNavBar(context, 0),
          body: _isLoading ? preLoader() : _buildBody(),
        );
      }
    });
  }

  Widget _buildBody() {
    if (widget.model.portfolioGraphData.length > 0) {
      _showGraph = true;
    } else {
      _showGraph = false;
    }

    return ListView(
      physics: ClampingScrollPhysics(),
      controller: controller,
      //direction: Axis.vertical,
      children: _buildBodyWidgetList(),
    );
  }

  Widget _portfolioValue() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              'Hello ' +
                  widget.model.userData.custFirstName +
                  ',\nyour portfolio today',
              style: appBodyText1),
          SizedBox(height: getScaledValue(5.0)),
          Text(
            removeDecimal(widget.model.userPortfolioValue['value'].toString()),
            style: appBodyPortfolioPrice,
          ),
          SizedBox(width: getScaledValue(8.0)),
          Row(
            children: <Widget>[
              Text(
                removeDecimal(widget
                    .model.userPortfolioValue['change_difference']
                    .toString()),
                style: appBodyText1,
              ),
              SizedBox(width: getScaledValue(2)),
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      '(',
                      style: appBodyText1,
                    ),
                    (widget.model.userPortfolioValue['change_sign'] == "up"
                        ? Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: getScaledValue(16.0),
                          )
                        : widget.model.userPortfolioValue['change_sign'] ==
                                "down"
                            ? Icon(
                                Icons.trending_down,
                                color: colorRed,
                                size: getScaledValue(16.0),
                              )
                            : emptyWidget),
                    (widget.model.userPortfolioValue['change_sign'] == "up" ||
                            widget.model.userPortfolioValue['change_sign'] ==
                                "down"
                        ? Text(
                            widget.model.userPortfolioValue['change']
                                .toString(),
                            style: appBodyText1)
                        : emptyWidget),
                    Text(
                      ')',
                      style: appBodyText1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noPortfolioValue() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hello ' + widget.model.userData.custFirstName,
              style: appBodyText1),
          SizedBox(height: getScaledValue(5.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    removeDecimal("\$0"),
                    style: appBodyPortfolioPrice.copyWith(
                        color: Colors.white.withOpacity(0.26)),
                  ),
                ],
              )),
              Icon(Icons.arrow_forward_ios,
                  color: Color(0xff6699ff), size: getScaledValue(16.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _graphPortfolio() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(getScaledValue(7)),
        color: Colors.white,
        border: Border.all(
          color: Color(0xffeeeeee),
          width: 1.0,
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
              child: Text(
                Contants.date +
                    Contants.clone +
                    " " +
                    widget.model.userPortfolioValue['date'].toString(),
                textAlign: TextAlign.right,
                style: body_text3_summary.copyWith(
                  fontSize: ScreenUtil().setSp(12.0),
                ),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: double.infinity,
            ),
            padding: EdgeInsets.symmetric(vertical: getScaledValue(20)) +
                EdgeInsets.only(
                    left: getScaledValue(30), right: getScaledValue(25)),
            child: _showGraph
                ? (SimpleLineChart(
                    fixGraphData(),
                  ))
                : emptyWidget,
            //_showGraph && flSpotList.isNotEmpty ? (flLineGraph()) : emptyWidget,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)) +
                EdgeInsets.only(bottom: getScaledValue(10)),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    await _analyticsRefreshEvent();
                    setState(() {
                      widget.model.setLoader(true);
                    });
                    counter++;
                    await widget.model.fetchOtherData();
                    setState(() {
                      widget.model.setLoader(false);
                    });
                  },
                  child: Text("Refresh",
                      style: graphTimestamp.copyWith(
                          decoration: TextDecoration.underline)),
                ),
                _showGraph
                    ? GestureDetector(
                        onTap: () {
                          _analyticsViewDetailsEvent();
                          Navigator.pushNamed(context, "/benchmark_performance")
                              .then((_) => refreshParent());
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text("View Details", style: graphLink),
                            Icon(Icons.keyboard_arrow_right,
                                size: getScaledValue(12),
                                color: Color(
                                  0xff034bd9,
                                )),
                          ],
                        ))
                    : emptyWidget,
              ],
            ),
          ),
          Divider(),
          _percentageReturn()
        ],
      ),
    );
  }

  Widget _noGraphPortfolio() {
    return Container(
      padding: EdgeInsets.only(
        top: getScaledValue(30),
        left: getScaledValue(12),
        right: getScaledValue(12),
        // bottom: getScaledValue(18),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(getScaledValue(7)),
        color: Colors.white,
        border: Border.all(
          color: Color(0xffeeeeee),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          svgImage("assets/icon/icon_no_investment.svg"),
          gradientButton(
            context: context,
            caption: "Add investments",
            onPressFunction: () =>
                Navigator.pushNamed(context, "/add_portfolio")
                    .then((_) => refreshParent()),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBodyWidgetList() {
    List<Widget> widgetBodyList = [];

    if (widget.model.isUserAuthenticated) {
      if (widget.model.userPortfolioValue != false &&
          widget.model.userPortfolioValue != null) {
        widgetBodyList.add(
          Container(
            /* constraints: BoxConstraints(
							minHeight: getScaledValue(350),
							maxHeight: getScaledValue(500),
						), */
            height: getScaledValue(480),
            //height: getScaledValue(MediaQuery.of(context).size.height * (Platform.isAndroid ? getScaledValue(0.36) : 0.36)), // 0.44 // (androidMediaHeight(context) == "small" ? 0.54 : 0.44)
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: Container(
                      height: getScaledValue(190.0),
                      padding: EdgeInsets.all(getScaledValue(10.0)),
                      //margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff0445e4), Color(0xff1181ff)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: _portfolioValue()),
                ),
                Positioned(
                    top: getScaledValue(115),
                    left: getScaledValue(15.0),
                    right: getScaledValue(15.0),
                    // width: getScaledValue(330.0),
                    //height: getScaledValue(MediaQuery.of(context).size.height * (Platform.isAndroid ? (androidMediaHeight(context) == "small" ? 0.35 : 0.28) : 0.23)), //setHeight(600.0), // 0.28
                    child: _graphPortfolio())
              ],
            ),
          ),
        );
        //widgetBodyListTop.add(LineChartSample2());
      } else {
        widgetBodyList.add(
          Container(
            height: getScaledValue(332),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: Container(
                      height: getScaledValue(190.0),
                      padding: EdgeInsets.all(10.0),
                      //margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff0445e4), Color(0xff1181ff)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: GestureDetector(
                          onTap: () =>
                              null, //Navigator.pushNamed(context, "/benchmark_performance"),
                          child: _noPortfolioValue())),
                ),
                Positioned(
                    top: 100,
                    left: getScaledValue(15.0),
                    width: getScaledValue(330.0),
                    height: 262,
                    child: _noGraphPortfolio())
              ],
            ),
          ),
        );
      }
    }

    //widgetBodyList.add(Expanded(child: _tools()));
    widgetBodyList.add(SizedBox(height: getScaledValue(15)));
    //widgetBodyList.add(Container(margin: EdgeInsets.symmetric(horizontal: getScaledValue(15.0)), child: Text("ALERTS", style: appBodyH4)));
    //widgetBodyList.add(setupProfile("assets/icon/icon_user.png", "Set up your profile"));

    //if(notifications != null && notifications.length > 0){
    widgetBodyList.add(GestureDetector(
        onTap: () => Navigator.pushNamed(context, "/notification").then((_) {
              changeStatusBarColor(Color(0xff0445e4));
              refreshParent();
              getModels();
              _anlyticsAlertEvent();
            }),
        child: widgetCard(
            bgColor: notifications.isNotEmpty
                ? notifications.where((i) => i['unread'] == true).length > 0
                    ? Color(0xfffff6df)
                    : Colors.white
                : Colors.white,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  notifications.isNotEmpty
                      ? notifications.where((i) => i['unread'] == true).length >
                              0
                          ? Container(
                              width: 24.0,
                              height: 24.0,
                              child: CircleAvatar(
                                backgroundColor: Color(0xffffc946),
                                minRadius: 11.0,
                                child: Text(
                                    notifications
                                        .where((i) => i['unread'] == true)
                                        .length
                                        .toString(),
                                    style: bodyText11),
                              ),
                            )
                          : emptyWidget
                      : emptyWidget,
                  notifications.isNotEmpty
                      ? notifications.where((i) => i['unread'] == true).length >
                              0
                          ? SizedBox(width: getScaledValue(6))
                          : emptyWidget
                      : emptyWidget,
                  Expanded(
                    child: Text(
                        notifications.isNotEmpty
                            ? notifications
                                        .where((i) => i['unread'] == true)
                                        .length >
                                    0
                                ? "New Alerts"
                                : "Alerts"
                            : "Alerts",
                        style: appBenchmarkPerformerName),
                  ),
                  Icon(Icons.chevron_right),
                ]))));
    //}

    widgetBodyList.add(SizedBox(height: 16.0));

    if (basketResponse != null && basketResponse.response != null)
      widgetBodyList.add(marketIndicator());
    widgetBodyList.add(SizedBox(height: 32.0));

    widgetBodyList.add(Container(
        padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
        child: Text("Quick Links".toUpperCase(), style: appGraphTitle)));
    widgetBodyList.add(SizedBox(height: 10.0));

    if (widget.model.userRiskProfile == null) {
      widgetBodyList.add(toolShortcut(
          "assets/icon/icon_home_risk.svg",
          "Discover your risk tolerance",
          "Understand your endurance towards risks and set the appropriate returns expectations",
          navigation: "/riskProfiler"));
    }

    widgetBodyList.add(toolShortcut(
        "assets/icon/icon_home_goals.svg",
        "Set your goals",
        "Plan ahead for your short term or long term financial needs. Coming soon!",
        navigation:
            "/comingSoon")); // /goalPlanner/goal // goalPlanner/retirement // comingSoon

    if (widget.model.userRiskProfile != null) {
      widgetBodyList.add(toolShortcut(
          "assets/icon/icon_home_risk.svg",
          "Discover your risk tolerance",
          "Understand your endurance towards risks and set the appropriate returns expectations",
          navigation: "/riskProfiler"));
    }

    widgetBodyList.add(GestureDetector(
      onTap: () {
        _analyticsHaveQns();
      },
      child: Container(
          margin: EdgeInsets.all(getScaledValue(15.0)),
          child: stillHaveQuestions(
              context: context,
              title: "Have Questions?",
              subtitle: "click through to FAQs")),
    ));

    return widgetBodyList;
  }

  Widget marketIndicator() {
    return Container(
      height: getScaledValue(200),
      // MediaQuery.of(context).size.height * (Platform.isAndroid ? (androidMediaHeight(context) == "small" ? 0.30 : 0.26) : 0.25), //getScaledValue(250.0), // 0.26
      //height: getScaledValue(180), //getHeight(context, 175), //getScaledValue(175),
      /* constraints: BoxConstraints(
				minHeight: MediaQuery.of(context).size.height * 0.25, //getScaledValue(198.0),
				maxHeight: MediaQuery.of(context).size.height * 0.29, //getScaledValue(198.0),
			), */
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: basketResponse.response.length,
        controller: pageViewController,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            //padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
            child: widgetCard(
              bgColor: Color(0xfff5f5f5),
              bottomMargin: 0,
              leftMargin: 16,
              rightMargin: 16,
              topMargin: 0,
              child: marketIndicatorCard(basketResponse.response[index]),
            ),
          );
        },
      ),
    );
  }

  Widget marketIndicatorCard(BasketData basketData) {
    return Container(
        decoration: BoxDecoration(color: Color(0xfff5f5f5)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Market Sentiment", style: bodyText4),
                      Padding(
                        padding: EdgeInsets.only(top: getScaledValue(2.0)),
                        child: Text(getEquityByCountryCode(basketData.zone),
                            style: portfolioSummaryZone),
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        _analyticsMarketSentimentEvent();
                        Navigator.pushNamed(context, "/discover")
                            .then((_) => refreshParent());
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text("More", style: graphLink),
                          Icon(Icons.keyboard_arrow_right,
                              size: getScaledValue(12),
                              color: Color(
                                0xff034bd9,
                              )),
                        ],
                      )),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: getScaledValue(10.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        return Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  right: getScaledValue(index != 6 ? 8 : 0),
                                  top: getScaledValue(30)),
                              child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          gradient:
                                              heatGraphGradients()[index]),
                                      height:
                                          spikeIndex(basketData.basketValue) ==
                                                  index
                                              ? getScaledValue(14)
                                              : getScaledValue(6)),
                                  SizedBox(height: getScaledValue(2)),
                                  Text((index + 1).toString(),
                                      style: bodyText7),
                                ],
                              )),
                        );
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: getScaledValue(8.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Stay Defensive".toUpperCase(),
                              style: widgetBubbleTextStyle),
                          Text("Stay Alert".toUpperCase(),
                              style: widgetBubbleTextStyle)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: getScaledValue(12.0)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Current Sentiment:",
                                style: keyStatsBodyText6),
                            Padding(
                                padding: EdgeInsets.only(
                                  left: getScaledValue(5.0),
                                ),
                                child: Text(basketData.miBasketDetails.trend,
                                    style: keyStatsBodyText7)),
                          ]),
                    ),
                  ],
                ),
              ),
            ]));
  }

  List<LinearGradient> heatGraphGradients() {
    return [
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe16c56), Color(0xffe49d62)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe3905f), Color(0xffe7bd6a), Color(0xffcebf6e)]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe7bd6a), Color(0xff85c077)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffb1c072), Color(0xff85c077)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff85c077), Color(0xffe7bd6a)],
          stops: [0.0, 0.9]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffcebf6e), Color(0xffe7bd6a), Color(0xffe3905f)]),
      LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffe49d62), Color(0xffe16c56)],
          stops: [0.0, 0.9]),
    ];
  }

  String getEquityByCountryCode(String code) {
    //logger.e(code);
    if (code.toLowerCase() == "in") {
      return "India Equities";
    } else {
      return "US Equities";
    }
  }

  int spikeIndex(String basketValue) {
    double value = double.parse(basketValue);
    if (isBetween(value, 0, 9, true)) {
      return 0;
    } else if (isBetween(value, 10, 24, true)) {
      return 1;
    } else if (isBetween(value, 25, 39, true)) {
      return 2;
    } else if (isBetween(value, 40, 59, true)) {
      return 3;
    } else if (isBetween(value, 60, 79, true)) {
      return 4;
    } else if (isBetween(value, 80, 99, true)) {
      return 5;
    } else {
      return 6;
    }
  }

  Widget setupProfile(String imgPath, String title, {String navigation = ""}) {
    return widgetCard(
        child: GestureDetector(
            onTap: () {
              if (navigation != "") {
                Navigator.pushNamed(context, navigation);
              }
            },
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      imgPath,
                      width: getScaledValue(19),
                    ),
                  ),
                  SizedBox(width: getScaledValue(15)),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(title, style: appBodyH3),
                          Text("10% left", style: appBodyProfilePercentage),
                        ],
                      ),
                      SizedBox(height: getScaledValue(4)),
                      LinearPercentIndicator(
                        //width:  screenSize(context: context, type: "width") - 20.0,
                        lineHeight: 4.0,
                        percent: (90 / 100),
                        backgroundColor: Color(0xffe7e7e7),
                        progressColor: Color(0xffefc42b),
                      ),
                    ],
                  )),
                ])));
  }

  Widget toolShortcut(String imgPath, String title, String description,
      {String navigation = "",
      var navigationArguments,
      bool alertType = false,
      Color bgColor = Colors.white}) {
    return GestureDetector(
        onTap: () {
          if (navigation == '/riskProfiler') {
            _analyticsDiscoverRiskTolerenceEvent();
          } else if (navigation == '/comingSoon') {
            _analyticsSetYourGoalsEvent();
          }
          if (navigation != "") {
            Navigator.pushNamed(context, navigation,
                    arguments: navigationArguments)
                .then((_) => changeStatusBarColor(Color(0xff0445e4)));
          }
        },
        child: widgetCard(
            bgColor: bgColor,
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
                      Text(title,
                          style: alertType
                              ? appBodyText1.copyWith(
                                  color: Color(0xff707070),
                                  fontWeight: FontWeight.bold)
                              : appBodyH3),
                      alertType
                          ? Divider(
                              height: 20,
                              color: Color(0xffededed),
                            )
                          : emptyWidget,
                      Text(description,
                          style:
                              appBodyText1.copyWith(color: Color(0xff707070)))
                    ],
                  )),
                  Icon(Icons.chevron_right),
                ])));
  }

  Widget _percentageReturn() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(16.0), vertical: getScaledValue(20.0)),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        widget.model.userPortfolioValue['cagr'].toString() +
                            "%",
                        maxLines: 1,
                        style: appBenchmarkReturnValue.copyWith(
                            color: widget.model.userPortfolioValue['cagr'] < 0
                                ? colorRedReturn
                                : colorGreenReturn)),
                    Text("Time Weighted Return", style: appBenchmarkReturnType),
                    Text("(CAGR)", style: appBenchmarkReturnType2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        widget.model.userPortfolioValue['xirr'].toString() +
                            "%",
                        maxLines: 1,
                        style: appBenchmarkReturnValue.copyWith(
                            color: widget.model.userPortfolioValue['xirr'] < 0
                                ? colorRedReturn
                                : colorGreenReturn)),
                    Text("Money Weighted Return",
                        style: appBenchmarkReturnType),
                    Text("(XIRR)", style: appBenchmarkReturnType2),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: getScaledValue(27.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () => bottomAlertBox(
                    context: context,
                    title: "Time Weighted Return",
                    description:
                        "The annualized rate at which the investment has grown since the day it is being tracked, irrespective of the frequency or the amount of cash that has flown into or out of this investment during this period. This allows an investor to compare multiple investment alternatives with each other and set expectations for the future. This is also commonly known as the Compound Annual Growth Rate (CAGR)",
                    title2: "Money Weighted Return",
                    description2:
                        "The annualized rate of return that takes into account the impact of all fund inflows and outflows on the performance of an investment. This, therefore, represents the true return an investor has achieved on a particular investment over time. This is also commonly known as the Extended Internal Rate of Return (XIRR) \n \n If there are no cash inflows or outflows during the investment period, apart from the initial sum invested, then both XIRR and CAGR should deliver the same results"),
                child: Text("What is this?", style: appBenchmarkLink),
              ),
              widget.model.oldestInvestmentDate != null
                  ? Text("since " + widget.model.oldestInvestmentDate,
                      style: appBenchmarkSince)
                  : emptyWidget,
            ],
          )
        ],
      ),
    );
  }

  List<charts.Series<yieldData, DateTime>> fixGraphData() {
    final List<yieldData> yieldDb = [];

    /* log.d('test1');
		log.d(_basketData.miGraphData[1]); */

    for (int i = 0; i < widget.model.portfolioGraphData.length; i++) {
      /* log.d('test2');
			log.d(_basketData.miGraphData[i]); */

      yieldDb.add(yieldData(
        DateTime.fromMillisecondsSinceEpoch(
            widget.model.portfolioGraphData[i][0]),
        //widget.model.portfolioGraphData[i][1],
        widget.model.portfolioGraphData[i][1].toDouble(),
        //widget.model.portfolioGraphData[i][1].toString(),
      ));
    }

    return [
      charts.Series<yieldData, DateTime>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color((0xff787878))),
        domainFn: (yieldData sales, _) => sales.date,
        measureFn: (yieldData sales, _) => sales.total,
        data: yieldDb,
      )
    ];
  }

  Widget sampleGraph() {
    final fromDate = DateTime(2019, 05, 22);
    final toDate = DateTime.now();

    final date1 = DateTime.now().subtract(Duration(days: 2));
    final date2 = DateTime.now().subtract(Duration(days: 3));

    return Center(
      child: Container(
        color: Colors.red,
        height: 150,
        width: double.infinity,
        child: BezierChart(
          fromDate: fromDate,
          bezierChartScale: BezierChartScale.CUSTOM,
          toDate: toDate,
          selectedDate: toDate,
          series: [
            BezierLine(
              label: "Duty",
              onMissingValue: (dateTime) {
                if (dateTime.day.isEven) {
                  return 10.0;
                }
                return 5.0;
              },
              data: [
                DataPoint<DateTime>(value: 10, xAxis: date1),
                DataPoint<DateTime>(value: 50, xAxis: date2),
              ],
            ),
          ],
          config: BezierChartConfig(
            bubbleIndicatorColor: colorBlue,
            verticalIndicatorStrokeWidth: 3.0,
            verticalIndicatorColor: Colors.black26,
            showVerticalIndicator: true,
            verticalIndicatorFixedPosition: false,
            backgroundColor: Colors.red,
            footerHeight: 30.0,
          ),
        ),
      ),
    );
  }

  Widget flLineGraph() {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.orange, strokeWidth: 0),
                  FlDotData(
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(radius: 8, color: colorBlue2)),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              /* getTooltipItems: (List<LineBarSpot> touchedSpots) {
								
								List<LineTooltipItem> tooltipItems = flSpotList.map((FlSpot touchedSpot) {
									
									if (touchedSpot == null) {
										//return null;
									}
									final TextStyle textStyle = TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, );
									return LineTooltipItem('${touchedSpot.y}', textStyle);
								}).toList();
								
							
								return tooltipItems;
							}, */
              tooltipBgColor: colorBlue2,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: flSpotList,
              isCurved: true,
              barWidth: 2,
              colors: [
                colorGraphLinePrimary,
              ],
              dotData: FlDotData(
                show: true,
              ),
            ),
          ],
          /* betweenBarsData: [
						BetweenBarsData(
							fromIndex: 0,
							toIndex: 2,
							colors: [Colors.red.withOpacity(0.3)],
						)
					], */
          minY: 0,
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
                showTitles: true,
                // textStyle: widgetBubbleTextStyle,
                getTitles: (value) {
                  switch (value.toInt()) {
                    case 0:
                      return 'Jan';
                    case 1:
                      return 'Feb';
                    case 2:
                      return 'Mar';
                    case 3:
                      return 'Apr';
                    case 4:
                      return 'May';
                    case 5:
                      return 'Jun';
                    case 6:
                      return 'Jul';
                    case 7:
                      return 'Aug';
                    case 8:
                      return 'Sep';
                    case 9:
                      return 'Oct';
                    case 10:
                      return 'Nov';
                    case 11:
                      return 'Dec';
                    default:
                      return '';
                  }
                }),
            leftTitles: SideTitles(
              showTitles: false,
              getTitles: (value) {
                return '\$ ${value + 0.5}';
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                  color: const Color(0xffdadada),
                  strokeWidth: 1,
                  dashArray: [7, 7]);
            },
          ),
        ),
      ),
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static String pointerValue;
  final Function analyticsCall;

  SimpleLineChart(this.seriesList, {this.animate, this.analyticsCall});

  String _formatMoney(num value1) {
    int value = value1.toInt();
    return NumberFormat.compact().format(value);
  }

  Future<Null> _analyticsGraphInteractionEvent() async {
    // log.d("\n analyticsGraphInteractionEvent called \n");
    await FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "home",
      'item_name': "home_chart_scenario_clicking",
      'content_type': "click_chart",
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 155.0,
        child: !kIsWeb
            ? ShaderMask(
                child: simpleLineChartChild(),
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green, Colors.white],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
              )
            : simpleLineChartChild());
  }

  Widget simpleLineChartChild() {
    _analyticsGraphInteractionEvent();
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      layoutConfig: charts.LayoutConfig(
        leftMarginSpec: charts.MarginSpec.fixedPixel(0),
        topMarginSpec: charts.MarginSpec.fixedPixel(0),
        rightMarginSpec: charts.MarginSpec.fixedPixel(0),
        bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
      ),
      domainAxis: new charts.DateTimeAxisSpec(
        showAxisLine: false,
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: new charts.TextStyleSpec(
            fontSize: 10,
            color: charts.ColorUtil.fromDartColor(
              Color((0xffa5a5a5)),
            ),
          ),
          lineStyle: new charts.LineStyleSpec(
            color: charts.Color.fromHex(code: "#ffffff"),
          ),
        ),
      ),
      defaultRenderer: new charts.LineRendererConfig(
        includeArea: false,
        stacked: true,
        includeLine: true,
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        showAxisLine: false,
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(
          zeroBound: false,
          desiredTickCount: 5,
        ),
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
          _formatMoney,
        ),
        renderSpec: new charts.GridlineRendererSpec(
          labelStyle: new charts.TextStyleSpec(
            fontSize: 10,
            color: charts.ColorUtil.fromDartColor(
                Color((0xffa5a5a5))), // .fromHex(code: "#ffffff"),
          ),
          lineStyle: new charts.LineStyleSpec(
            dashPattern: [10, 5],
            color: charts.Color.fromHex(
              code: "#ffffff",
            ),
          ),
        ),
      ),
      selectionModels: [
        charts.SelectionModelConfig(
          changedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue = DateFormat("MMM dd, yyyy").format(
                        DateTime.parse(datumPair.datum.date.toString())) +
                    "\nValue: " +
                    _formatMoney(datumPair.datum.total.round());
              });
            }
          },
          updatedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue = DateFormat("MMM dd, yyyy").format(
                        DateTime.parse(datumPair.datum.date.toString())) +
                    "\nValue: " +
                    _formatMoney(datumPair.datum.total.round());
              });
            }
          },
        )
      ],
      behaviors: [
        charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tapAndDrag),
        charts.LinePointHighlighter(
          showHorizontalFollowLine:
              charts.LinePointHighlighterFollowLineType.all,
          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.all,
          symbolRenderer: CustomCircleSymbolRenderer(),
        ),
        charts.InitialSelection(
          selectedDataConfig: [
            new charts.SeriesDatumConfig<DateTime>(
              'Goal Term',
              (seriesList.last.data.last as yieldData).date,
            )
          ],
          shouldPreserveSelectionOnDraw: true,
        ),
      ],
    );
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    int positionBox = 5;
    int positionText = 5;

    if (bounds.left + bounds.width + 120 > 300) {
      positionBox = 120;
      positionText = -110;
    }
    //canvas.drawRRect(bounds)

    canvas.drawRect(
      Rectangle(bounds.left - positionBox, bounds.top - 75, bounds.width + 120,
          bounds.height + 45),
      fill: charts.ColorUtil.fromDartColor(Color((0xff1772ff))),
      //radius: 4,
    );

    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontFamily = 'nunito';
    textStyle.fontSize = 13;

    canvas.drawText(TextElement(SimpleLineChart.pointerValue, style: textStyle),
        (bounds.left + positionText).round(), (bounds.top - 63).round());
  }
}

class yieldData {
  final DateTime date;
  final double total;
  //final String total;
  //final double nifty;

  yieldData(this.date, this.total);
}

class LineChartSample2 extends StatefulWidget {
  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  Timer timer;
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  List<FlSpot> _listFlSpots = [FlSpot(0, 3)];
  List<FlSpot> _listFlSpotsMain = [
    FlSpot(0, 3),
    FlSpot(2, 2),
    FlSpot(3, 5),
    FlSpot(4, 3.1),
    FlSpot(5, 4),
    FlSpot(6, 3),
    FlSpot(7, 4),
    FlSpot(8, 5),
    FlSpot(9, 6),
    FlSpot(10, 2),
    FlSpot(11, 6),
    FlSpot(12, 6.6),
    FlSpot(13, 7.1),
    FlSpot(14, 5.3),
    FlSpot(15, 2.0),
  ];

  bool showAvg = false;

  @override
  void initState() {
    super.initState();

    loadFlSpotList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.50,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              //color: Color(0xff232d37)
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
                swapAnimationDuration: Duration(milliseconds: 1500),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: FlatButton(
            onPressed: () {
              setState(() {
                _listFlSpots.clear();
                _listFlSpots.add(_listFlSpotsMain[_listFlSpots.length]);
                loadFlSpotList();
              });
            },
            child: Text(
              'load',
              style: TextStyle(
                  fontSize: 12,
                  color:
                      showAvg ? Colors.white.withOpacity(0.5) : Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  loadFlSpotList() async {
    // runs every 1 second

    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      if (_listFlSpots.length == _listFlSpotsMain.length) {
        timer.cancel();
      }
      setState(() {
        _listFlSpots.add(_listFlSpotsMain[_listFlSpots.length]);
        // log.d('debug 1295');
        // log.d(_listFlSpots.length);
      });
      // add to list
    });
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          // textStyle: const TextStyle(
          //     color: Color(0xff68737d),
          //     fontWeight: FontWeight.bold,
          //     fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          // textStyle: const TextStyle(
          //   color: Color(0xff67727d),
          //   fontWeight: FontWeight.bold,
          //   fontSize: 15,
          // ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 15,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: _listFlSpots,

          /* spots: [
						FlSpot(0, 3),
						FlSpot(2.6, 2),
						FlSpot(4.9, 5),
						FlSpot(6.8, 3.1),
						FlSpot(8, 4),
						FlSpot(9.5, 3),
						FlSpot(11, 4),
					], */
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.8)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: false,
        drawHorizontalLine: false,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 0,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          // textStyle: const TextStyle(
          //     color: Color(0xff68737d),
          //     fontWeight: FontWeight.bold,
          //     fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          // textStyle: const TextStyle(
          //   color: Color(0xff67727d),
          //   fontWeight: FontWeight.bold,
          //   fontSize: 15,
          // ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            /* FlSpot(0, 3.44),
						FlSpot(2.6, 3.44),
						FlSpot(4.9, 3.44),
						FlSpot(6.8, 3.44),
						FlSpot(8, 3.44),
						FlSpot(9.5, 3.44),
						FlSpot(11, 3.44), */
          ],
          isCurved: true,
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            /* colors: [
							Colors.blue,

							ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2).withOpacity(0.1),
							ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2).withOpacity(0.8),
						] */
          ),
        ),
      ],
    );
  }
}
