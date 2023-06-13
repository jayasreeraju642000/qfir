import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/controller_switch.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

class NotificationPageLarge extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  NotificationPageLarge(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPageLarge>
    with SingleTickerProviderStateMixin {
  bool isNotificationOn;
  TabController controller;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map notifications = {};

  @override
  void initState() {
    super.initState();
    isNotificationOn = true;
    controller = new TabController(vsync: this, length: 2);

    getNotifications();
    _analyticsCurrentScreen();
  }

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n analyticsCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'alerts',
      screenClassOverride: 'alerts',
    );
  }

  Future<Null> _analyticsAlertToggleEvent() async {
    // log.d("\n analyticsAlertSwitchEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "alerts",
      'item_name': "alerts_on_and_off",
      'content_type': "toggle_button",
    });
  }

  Future<Null> _analyticsMarketInsightEvent() async {
    // log.d("\n analyticsMarketInsightEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "alerts",
      'item_name': "alerts_selecting_marketing_insights",
      'content_type': "marketing_insights_tab",
    });
  }

//
  @override
  dispose() {
    //animationController.dispose(); // you need this
    super.dispose();
  }

  getNotifications() async {
    setState(() {
      widget.model.setLoader(true);
    });
    notifications = await widget.model.getLocalNotification(makeRead: true);
    setState(() {
      widget.model.setLoader(false);
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
      child: Scaffold(
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          backgroundColor: PlatformCheck.isSmallScreen(context)
              ? Colors.white
              : Color(0xfff5f6fa),
          appBar: PreferredSize(
              // for larger & medium screen sizes
              preferredSize: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              child: NavigationTobBar(
                widget.model,
                openDrawer: () => _scaffoldKey.currentState.openDrawer(),
              )),
          body: _buildBodyLarge()),
    );
  }

  Widget notificationContainer(String type) {
    List notificationList = notifications.values
        .where((element) => element['type'] == type)
        .toList();

    notificationList.sort((a, b) {
      var firstDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(a['date_added']);
      var secondDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(b['date_added']);
      return firstDate.compareTo(secondDate);
    });
    List notificationListReverse = notificationList.reversed.toList();

    if (notificationListReverse.length > 0) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return notificationRow(notificationListReverse[index],
                bgColor: index % 2 == 0 ? Color(0xfffffaee) : Colors.white);
          },
          itemCount: notificationListReverse.length,
          separatorBuilder: (BuildContext context, int index) => divider());
    } else {
      return Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/group_ic.png"),
          SizedBox(height: getScaledValue(10)),
          Text("No alerts currently", style: bodyText5),
        ],
      ));
    }
  }

  Widget notificationRow(Map notificationData, {Color bgColor = Colors.white}) {
    return Container(
        decoration: BoxDecoration(color: bgColor),
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16, top: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: getScaledValue(24)),
                        Text(notificationData['title'], style: body0_alerts),
                        SizedBox(height: getScaledValue(5)),
                        Text(notificationData['description'],
                            style: body0_alerts),
                        SizedBox(height: getScaledValue(24)),

                        // Text( notificationData['title'], style:bodyText4.copyWith(fontWeight: FontWeight.bold, color: Color(0xff747474) )),
                        // SizedBox(height: getScaledValue(5)),
                        // Text( notificationData['description'], style:bodyText4.apply( color: Color(0xff747474) )),
                      ],
                    ))),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: Text(
                  notificationData['date_added'] != null
                      ? displayTimeAgoFromTimestamp(
                          DateFormat("yyyy-MM-dd HH:mm:ss")
                              .parse(notificationData['date_added'], true)
                              .toLocal()
                              .toString())
                      : " ",
                  style: bodyText4),
            )
          ],
        ));
  }

  Widget _buildBodyLarge() {
    return _buildBodyNvaigationLeftBar(); //_autocompleteTextField(); //_buildBodyContent();
  }

  Widget _buildBodyNvaigationLeftBar() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        deviceType == DeviceScreenType.tablet
            ? emptyWidget
            : NavigationLeftBar(
                isSideMenuHeadingSelected: 0, isSideMenuSelected: 0),
        Expanded(child: _buildBodyContentLarge()), // _buildBodyContentLarge
      ],
    );
  }

// _bodyLarge
  Widget _buildBodyContentLarge() {
    return !widget.model.isLoading
        ? SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(
                    left: 27.0, top: 24.5, right: 60.0, bottom: 24.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                            child: Text("< Back", style: body_text3_portfolio),
                          ),
                          SizedBox(height: getScaledValue(32.5)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(
                                  "Alerts",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(25.0),
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'nunito',
                                      letterSpacing: 0.4,
                                      color: Color(0xff181818)),
                                ),
                              ),
                              Container(
                                child: ControlledSwitch(
                                    value: widget.model
                                                .userSettings['notification'] ==
                                            "1"
                                        ? true
                                        : false,
                                    onChanged: (newValue) async {
                                      await _analyticsAlertToggleEvent();
                                      setState(() {
                                        //isNotificationOn = newValue;
                                        if (newValue) {
                                          widget.model.userSettings[
                                              'notification'] = "1";
                                        } else {
                                          widget.model.userSettings[
                                              'notification'] = "2";
                                        }
                                        //widget.model.setLoader(true);
                                      });

                                      //	var responseData = await widget.model.updateCustomerSettings({'notification': widget.model.userSettings['notification']});
                                      setState(() {
                                        //widget.model.setLoader(false);
                                      });
                                    }),
                              )
                            ],
                          ),
                          SizedBox(height: getScaledValue(11)),
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: TabBar(
                              isScrollable: true,
                              controller: controller,
                              unselectedLabelColor: Color(0xff979797),
                              labelColor: Color(0xff034bd9),
                              indicatorWeight: getScaledValue(2),
                              indicatorColor: Color(0xff034bd9),
                              unselectedLabelStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(12.0),
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0.86,
                                  color: Color(0xff979797)),
                              labelStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(12.0),
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0.86,
                                  color: Color(0xff034bd9)),

                              // indicator: BoxDecoration(
                              // 	color: Colors.transparent,
                              // 	border: Border(
                              // 		bottom: BorderSide(
                              // 			color: AppColor.colorBlue, width: 2)),
                              // ),
                              tabs: [
                                Tab(text: "Your Portfolio"),
                                Tab(text: "Market"),
                              ],
                              onTap: (tab) {
                                if (tab == 0) {
                                  _analyticsMarketInsightEvent();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      //cornerRadius: 0,
                    ),
                    SizedBox(height: getScaledValue(1)),
                    Container(
                        color: Colors.white,
                        height: getScaledValue(400),
                        child: TabBarView(
                            controller: controller,
                            children: <Widget>[
                              notificationContainer('Portfolio Insight'),
                              notificationContainer('Market Insight'),
                            ])),
                    SizedBox(height: getScaledValue(12)),
                    FlatButton(
                      minWidth: 120,
                      height: 40,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text('Go Back',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(12.0),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'nunito',
                            color: Color(0xff034bd9),
                            letterSpacing: 0.0,
                          )),
                      textColor: colorBlue,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: colorBlue,
                              width: 1.25,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                )))
        : preLoader();
  }
}
