import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/controller_switch.dart';

import '../../models/main_model.dart';
import '../../widgets/styles.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('NotificationPage');

class NotificationPageSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  NotificationPageSmall(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPageSmall>
    with SingleTickerProviderStateMixin {
  bool isNotificationOn;
  TabController controller;

  Map notifications = {};

  @override
  void initState() {
    super.initState();
    isNotificationOn = true;
    controller = new TabController(vsync: this, length: 2);
    controller.addListener(() {
      if (controller.index == 1) {
        _analyticsMarketInsightEvent();
      }
    });

    _analyticsCurrentScreen();
    getNotifications();
  }

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

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n analyticsCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'alerts',
      screenClassOverride: 'alerts',
    );
  }

  Future<Null> _analyticsAlertSwitchEvent() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: !widget.model.isLoading
          ? Column(
              children: [
                FloatingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: BackButton(color: Colors.black),
                        actions: [
                          /* Padding(
								padding: EdgeInsets.symmetric(horizontal: 16),
								child: svgImage("assets/icon/setting.svg"),
								) */
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16, top: 12, bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Alerts",
                              style: headline1,
                            ),
                            /* Expanded(child: MaterialSwitch(
											padding: const EdgeInsets.symmetric(vertical:  5.0, horizontal: 10.0),
											margin: const EdgeInsets.all(5.0),
											selectedOption: widget.model.userSettings['notification'] == '1' ? "On" : "Off",
											options: ['On', 'Off'],
											selectedBackgroundColor: widget.model.userSettings['notification'] == "1" ? Colors.indigo : Colors.grey[800],
											selectedTextColor: Colors.white,
											onSelect: (String selectedOption) async {
												setState(() {
													if(selectedOption == "On"){
														widget.model.userSettings['notification'] = "1";
													}else if(selectedOption == "Off"){
														widget.model.userSettings['notification'] = "2";
													}
												});
												
												//widget.model.saveSettings(customerSettings);
												var responseData = await widget.model.updateCustomerSettings({'notification': widget.model.userSettings['notification']});
												setState(() {
													widget.model.setLoader(false);  
												});
											},
										)), */
                            ControlledSwitch(
                                value:
                                    widget.model.userSettings['notification'] ==
                                            "1"
                                        ? true
                                        : false,
                                onChanged: (newValue) async {
                                  await _analyticsAlertSwitchEvent();
                                  setState(() {
                                    //isNotificationOn = newValue;
                                    if (newValue) {
                                      widget.model
                                          .userSettings['notification'] = "1";
                                    } else {
                                      widget.model
                                          .userSettings['notification'] = "2";
                                    }
                                    //widget.model.setLoader(true);
                                  });

                                  await widget.model.updateCustomerSettings({
                                    'notification': widget
                                        .model.userSettings['notification']
                                  });
                                  setState(() {
                                    //widget.model.setLoader(false);
                                  });
                                }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TabBar(
                            controller: controller,
                            unselectedLabelColor: Color(0xffa5a5a5),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: AppColor.colorBlue,
                            labelStyle: bodyText4.apply(
                              fontWeightDelta: 2,
                            ),
                            unselectedLabelStyle: bodyText4.apply(
                              fontWeightDelta: 2,
                            ),
                            indicator: BoxDecoration(
                              color: Colors.transparent,
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.colorBlue, width: 2)),
                            ),
                            tabs: [
                              Tab(text: "Your Portfolio"),
                              Tab(
                                text: "Market",
                              )
                            ]),
                      ),
                      divider()
                    ],
                  ),
                  cornerRadius: 0,
                ),
                Expanded(
                    child:
                        TabBarView(controller: controller, children: <Widget>[
                  MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: notificationContainer('Portfolio Insight')),
                  MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: notificationContainer('Market Insight')),
                ]))
              ],
            )
          : preLoader(),
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
          padding: EdgeInsets.symmetric(
              horizontal: getScaledValue(10), vertical: getScaledValue(20)),
          child: Text("You have no new notification",
              textAlign: TextAlign.center, style: headline6));
    }
  }

  Widget notificationRow(Map notificationData, {Color bgColor = Colors.white}) {
    return Container(
        decoration: BoxDecoration(color: bgColor),
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
                        Text(notificationData['title'],
                            style: bodyText4.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff747474))),
                        SizedBox(height: getScaledValue(5)),
                        Text(notificationData['description'],
                            style: bodyText4.apply(color: Color(0xff747474))),
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
                  style: bodyText3.apply(letterSpacingDelta: -1)),
            )
          ],
        ));
  }
}
