import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_instrument_tab.dart';
import 'package:qfinr/pages/analyse/details/portfolio_analyzer_portfolio_tab.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';

final log = getLogger('SmallAnalyseSummary');

class SmallAnalyseSummary extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final bool viewOnly;

  SmallAnalyseSummary(this.model,
      {this.analytics, this.observer, this.viewOnly = false});

  @override
  _SmallAnalyseSummaryState createState() => _SmallAnalyseSummaryState();
}

class _SmallAnalyseSummaryState extends State<SmallAnalyseSummary>
    with TickerProviderStateMixin {
  double deviceWidth, deviceHeight;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  var response;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    getAnalyseSummmary();
  }

  void getAnalyseSummmary() async {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    setState(() {
      widget.model.setLoader(true);
    });
    response = await widget.model.getAnalyseSummary();
    if (response['status'] == true) {}
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
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorBlue,
          elevation: 0.0,
          title: Text(
            "Summary",
            style: appBodyText2.copyWith(
              fontSize: ScreenUtil().setSp(14.0),
            ),
          ),
          actions: <Widget>[],
        ),
        key: _scaffoldKey,
        body: _buildBody(),
      );
    });
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
          _bodyContents(),
        ],
      );

  Widget _bodyContents() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (widget.model.isLoading) {
      return preLoader();
    } else {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: _buildPortFoliosForWeb(),
      );
    }
  }

  Widget _noPortfolio() {
    return Container(
      margin: EdgeInsets.only(top: 40.0, bottom: 40),
      alignment: Alignment.center,
      child: Text(
        "No Data Available",
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  Widget _buildPortFoliosForWeb() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMenuTabs(),
            SizedBox(
              height: getScaledValue(2),
            ),
            response != null &&
                    response['response'] != null &&
                    response['response']['summary'] != null &&
                    response['response']['summary'].length != 0
                ? Row(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: tabIndex == 0
                            ? Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(
                                    left: 24.0,
                                    top: 0.0,
                                    right: 24.0,
                                    bottom: 0.0),
                                child: response != null &&
                                        response['response'] != null &&
                                        response['response']['summary'] !=
                                            null &&
                                        response['response']['summary']
                                                .length !=
                                            0
                                    ? PortfolioAnalyzerPortfolioTab(
                                        response['response']['summary'])
                                    : _noPortfolio(),
                              )
                            : tabIndex == 1
                                ? Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.only(
                                        left: 24.0,
                                        top: 0.0,
                                        right: 24.0,
                                        bottom: 0.0),
                                    child: response != null &&
                                            response['response'] != null &&
                                            response['response']['summary'] !=
                                                null &&
                                            response['response']['summary']
                                                    .length !=
                                                0
                                        ? PortfolioAnalyzerInstrumentTab(
                                            response['response']['summary'])
                                        : _noPortfolio(),
                                  )
                                : Container(),
                      ))
                    ],
                  )
                : _noPortfolio(),
          ],
        ),
      ),
    );
  }

  Container _buildMenuTabs() {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      height: getScaledValue(50),
      // padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              // width: MediaQuery.of(context).size.width * 1.0 / 1.75,
              child: tabbar(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget tabbar() {
    return TabBar(
      isScrollable: true,
      controller: _tabController,
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
      onTap: (index) {
        setState(() {
          tabIndex = index;
        });
      },
      tabs: [
        Tab(
          text: "Portfolio Statistics",
        ),
        Tab(text: "Instrument Statistics"),
      ],
    );
  }
}