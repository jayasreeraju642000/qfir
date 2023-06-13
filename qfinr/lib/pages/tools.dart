import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('Tools');

class Tools extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Tools(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _ToolsState();
  }
}

class _ToolsState extends State<Tools> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          drawer: WidgetDrawer(),
          appBar: mainAppBar(context, model),
          body: _buildBody(),
          bottomNavigationBar: widgetBottomNavBar(context, 3));
    });
  }

  Widget _buildBody() {
    return ListView(children: _buildWidgetList());
  }

  List<Widget> _buildWidgetList() {
    List<Widget> widgetList = [];

    widgetList.add(
      Container(
          margin: EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Text(
            languageText('text_tool_caption'),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
          )),
    );

    widgetList.add(
      _buildItem(
          context,
          languageText('text_risk_profiler'),
          "Take the comprehensive risk profiler and find out your risk appetite",
          "/riskProfiler",
          "assets/images/risk_profiler.png"),
    );
    widgetList.add(
      _buildItem(
          context,
          languageText('text_retirement_planner'),
          languageText('text_retirement_planner_description'),
          "/goalPlanner/retirement",
          "assets/images/retirement_planner.png"),
    );
    widgetList.add(
      _buildItem(
          context,
          languageText('text_goal_planner'),
          languageText("text_goal_planner_description"),
          "/goalPlanner/goal",
          "assets/images/goal_planner.png"),
    );
    widgetList.add(
      _buildItem(
          context,
          languageText('text_portfolio_analyzer'),
          "Comprehensive analysis of your portfolio",
          "/portfolioAnalyzer",
          "assets/images/portfolio_analyzer.png"),
    );
    widgetList.add(
      _buildItem1(
          context,
          languageText('text_portfolio_knowfund'),
          languageText("text_portfolio_knowfund_description"),
          "/portfolioKnowFund",
          "assets/images/know_your_fund.png"),
    );
    widgetList.add(
      _buildItem(
          context,
          languageText('text_portfolio_dividend'),
          languageText("text_portfolio_dividend_description"),
          "/portfolioDividend",
          "assets/images/portfolio_dividend.png"),
    );

    return widgetList;
  }

  Widget _buildItem(BuildContext context, String title, String subtitle,
      String route, String image) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Card(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Image.asset(
                            image,
                            height: 60.0,
                          ),

                          /*  Image.network(
								basketData.image,
								height: 60.0,
								) */
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        title,
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.0),
                              _widgetBasketCategory(context),
                              SizedBox(height: 3.0),
                              Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  subtitle,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.grey,
                                      height: 1.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _buildItem1(BuildContext context, String title, String subtitle,
      String route, String image) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Card(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Image.asset(
                            image,
                            height: 60.0,
                          ),

                          /*  Image.network(
								basketData.image,
								height: 60.0,
								) */
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        title,
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.0),
                              _widgetBasketCategory1(context),
                              SizedBox(height: 3.0),
                              Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  subtitle,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.grey,
                                      height: 1.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _widgetBasketCategory(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 10.0),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            widgetBasketCategoryItem(context, languageText('text_portfolio')),
            widgetBasketCategoryItem(context, languageText('text_planner')),
          ],
        ));
  }

  Widget _widgetBasketCategory1(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 10.0),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            widgetBasketCategoryItem(context, languageText('text_fund')),
            widgetBasketCategoryItem(context, languageText('text_planner')),
          ],
        ));
  }
}
