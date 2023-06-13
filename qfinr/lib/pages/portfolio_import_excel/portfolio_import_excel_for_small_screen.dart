import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'dart:async';

final log = getLogger('PortfolioImportExcel');

class PortfolioImportExcelForSmallScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  PortfolioImportExcelForSmallScreen(this.model,
      {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioImportExcelForSmallScreenState();
  }
}

class _PortfolioImportExcelForSmallScreenState
    extends State<PortfolioImportExcelForSmallScreen> {
  final controller = ScrollController();

  Future<Null> _anayticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'import_excel',
      screenClassOverride: 'import_excel',
    );
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Import Excel Page",
    });
  }

  Future<Null> _analyticsAddExcelPortfolio() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "import_excel",
      'item_name': "import_excel_send_mail",
      'content_type': "click_send_email_button",
    });
  }

  @override
  void initState() {
    super.initState();

    _anayticsCurrentScreen();
    _analyticsAddEvent();
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
    changeStatusBarColor(Colors.white);
    controller.appBar.height =
        getScaledValue(MediaQuery.of(context).padding.top + 56);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          key: myGlobals.scaffoldKey,
          /* drawer: WidgetDrawer(), */
          appBar: commonAppBar(
              /* controller: controller,  */ bgColor: Colors.white,
              actions: [
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                      context, widget.model.redirectBase),
                  child: AppbarHomeButton(),
                )
              ]),
          body: mainContainer(
              context: context,
              paddingLeft: getScaledValue(16),
              paddingRight: getScaledValue(16),
              containerColor: Colors.white,
              child: _buildBody()));
    });
  }

  Widget _buildBody() {
    return Column(
      //controller: controller,
      //physics: ClampingScrollPhysics(),
      children: <Widget>[
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Import from Excel",
                    style: importPortfolioHeading,
                  ),
                  SizedBox(height: getScaledValue(3)),
                  Text(
                      "Create a new portfolio by uploading an excel with all the holdings from your favourite broker, or via Qfinr template",
                      style: importPortfolioBody),
                ],
              ),
            ),
            SizedBox(height: getScaledValue(40)),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: getScaledValue(30), horizontal: getScaledValue(33)),
              decoration: BoxDecoration(
                color: Color(0xffecf1fa),
                borderRadius: BorderRadius.circular(getScaledValue(4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/icon/icon_email.png',
                    width: getScaledValue(90),
                  ),
                  SizedBox(height: getScaledValue(25)),
                  Text(
                    "An email will be sent to your email address '" +
                        widget.model.userData.emailID +
                        "' with steps to upload.",
                    style: importPortfolioBody2,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),

            /* SizedBox(height: getScaledValue(40)),
						Text("How it works", style: importPortfolioHelpTitle),
						SizedBox(height: getScaledValue(10)),
						Text('Step 1: You will receive an Excel file on email with the name "sample.xlsx". Simply add all transaction details in the "portfolio tab" of this excel file. Follow the template of the information entered in the "sample tab"', style: importPortfolioBody),
						SizedBox(height: getScaledValue(6)),
						Text('Step 2: Save the file with a filename that you want to identify this portfolio with on Qfinr', style: importPortfolioBody),
						SizedBox(height: getScaledValue(6)),
						Text('Step 3: Reply back to the email you had received with this saved file as an attachment. You need not write anything on the email when you reply.', style: importPortfolioBody),
						SizedBox(height: getScaledValue(6)),
						Text("Note: To identify the right RIC (Column 1) for each asset that you want to add, you can refer to the country-specific lists shared in the same excel file on separate tabs.", style: importPortfolioBody),
						SizedBox(height: getScaledValue(16)), */
          ],
        )),
        gradientButton(
            context: context,
            caption: "Send Mail",
            onPressFunction: () => functionSendPortfolioImportSample()),
      ],
    );
  }

  functionSendPortfolioImportSample() async {
    await widget.model.generateSample();
    showAlertDialogBox(context, '',
        'An email will be sent to your verified email address with the steps to upload the excel');
    await _analyticsAddExcelPortfolio();
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
