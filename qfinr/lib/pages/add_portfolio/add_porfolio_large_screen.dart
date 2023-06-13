import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/add_portfolio/add_portfolio_styles.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';

class AddPortfolioLargeScreen extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  AddPortfolioLargeScreen(this.model, {this.analytics, this.observer});

  @override
  _AddPortfolioLargeScreenState createState() =>
      _AddPortfolioLargeScreenState();
}

class _AddPortfolioLargeScreenState extends State<AddPortfolioLargeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String heading = "Add new portfolio";
  String subHeading =
      "Create new portfolios of your current holdings across stocks, bonds, mutual funds, ETFs and more";

  Future<Null> _analyticsCurrentScreen() async {
    // log.d("\n _analyticsCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'portfolio',
      screenClassOverride: 'portfolio',
    );
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Add Portfolio Page",
    });
  }

  Future<Null> _analyticsClickImportFromExelEvent() async {
    // log.d("\n analyticsClickImportFromExelEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "portfolio",
      'item_name': "portfolio_import_from_excel",
      'content_type': "click_import_from_excel",
    });
  }

  Future<Null> _analyticsClickAddmanuallyEvent() async {
    // log.d("\n analyticsClickAddmanuallyEvent called \n");
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "portfolio",
      'item_name': "portfolio_add_manually",
      'content_type': "click_add_manually",
    });
  }

  @override
  void initState() {
    _analyticsCurrentScreen();
    _addEvent();
    super.initState();
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
      // if (widget.model.isLoading || _benchmarkPerformance == null) {
      //   return preLoader();
      // } else {
      return PageWrapper(
        child: Scaffold(
          // key: myGlobals.scaffoldKey,
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          appBar: _buildAppBar(),
          body: _bodyContainer(),
        ),
      );
      // }
    });
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
      child: NavigationTobBar(
        widget.model,
        openDrawer: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  Widget _bodyContainer() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            deviceType == DeviceScreenType.tablet
                ? SizedBox()
                : NavigationLeftBar(
                    isSideMenuHeadingSelected: 1,
                    isSideMenuSelected: 2,
                  ),
            _webBuildBody(),
          ],
        )),
      ],
    );
  }

  Widget _webBuildBody() => Expanded(
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: getScaledValue(30),
                    horizontal: getScaledValue(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_left,
                          color: colorBlue,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/manage_portfolio_master_view');
                            //  Navigator.pop(context);
                          },
                          child: Text(
                            "Back to Portfolios",
                            style: AddPortfolioStyles.blueLinkTextBold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getScaledValue(19)),
                    Text(
                      heading,
                      style: AddPortfolioStyles.heding,
                    ),
                    SizedBox(height: getScaledValue(13)),
                    Text(
                      subHeading,
                      style: AddPortfolioStyles.subHeading,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: widgetCard(
                  // boxShadow: false,
                  child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      _analyticsClickImportFromExelEvent();

                      Navigator.pushNamed(context, "/portfolio_import_excel");
                    },
                    child: webToolShortcut(
                        AddPortfolioStyles.iconImportExcel,
                        AddPortfolioStyles.tileHedingImportExcel,
                        AddPortfolioStyles.tileContentTextImportExcel,
                        "Import",
                        navigation: '/portfolio_import_excel'),
                  )),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _analyticsClickAddmanuallyEvent();

                        Navigator.pushNamed(context, "/add_portfolio_manually");
                      },
                      child: webToolShortcut(
                        AddPortfolioStyles.iconAddManually,
                        AddPortfolioStyles.tileHedingAddManually,
                        AddPortfolioStyles.tileContentTextAddManually,
                        "Add New",
                        navigation: "/add_portfolio_manually",
                        // isColored: true
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Opacity(
                  //       opacity: 0.4,
                  //       child: webToolShortcut(
                  //           AddPortfolioStyles.iconStatement,
                  //           AddPortfolioStyles.tileHedingStatement,
                  //           AddPortfolioStyles.tileContentTextStatement,
                  //           "")),
                  // ),
                ],
              )),
            )
          ],
        ),
      );

  Widget webToolShortcut(
      String imgPath, String title, String description, String buttonName,
      {String navigation = "",
      bool alertType = false,
      bool isColored = false}) {
    return widgetCard(
      boxShadow: false,
      bgColor: Colors.white,
      child: Container(
        height: getScaledValue(385),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imgPath,
              width: getScaledValue(60),
              height: getScaledValue(60),
            ),
            SizedBox(height: getScaledValue(13)),
            Container(
              // height: getScaledValue(110),
              child: Column(
                children: [
                  Text(
                    title,
                    style: AddPortfolioStyles.tileTilte,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getScaledValue(10)),
                  Text(
                    description,
                    style: AddPortfolioStyles.tileDescription,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: getScaledValue(13)),
            navigation != ""
                ? _webButton(buttonName, navigation: navigation)
                : Text(
                    "Coming soon",
                    style: AddPortfolioStyles.blueLinkTextBold,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _webButton(String buttonName, {String navigation}) {
    return Container(
      width: 120,
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        border: Border.all(width: 1.0, color: colorBlue),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextButton(
        onPressed: () {
          if (buttonName == "Import") {
            _analyticsClickImportFromExelEvent();
          } else if (buttonName == "Add New") {
            _analyticsClickAddmanuallyEvent();
          }

          if (navigation != "") {
            Navigator.pushNamed(context, navigation);
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 40,
          child: Text(
            buttonName,
            style: AddPortfolioStyles.blueLinkTextBold,
            textAlign: TextAlign.center,
          ),
        ),
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
