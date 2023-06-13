import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_portfolio/manage_portfolio.dart';
import 'package:qfinr/widgets/styles.dart';

class SuccessPageForLargeScreen extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  String action;

  Map arguments;

  SuccessPageForLargeScreen(
    this.model, {
    this.analytics,
    this.observer,
    this.action = "edit",
    this.arguments,
  });

  @override
  _SuccessPageForLargeScreenState createState() =>
      _SuccessPageForLargeScreenState();
}

class _SuccessPageForLargeScreenState extends State<SuccessPageForLargeScreen> {
  Future<Null> _analyticsViewPortfolioSuccessEvent(String portfolioName) async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "add_manually",
      'item_name': "portfolio_success_view",
      'content_type': "view_portfolio_button",
      'item_list_name': portfolioName
    });
  }

  void showSuccessPopUp(BuildContext context) async {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return alertDialogBox();
    //     });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // title: Text(''),
          content: Container(
            color: Colors.white,
            // height: MediaQuery.of(context)
            //         .size
            //         .height *
            //     0.5,
            // height: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  successImageContainer(),
                  alertTitle(),
                  portfolioName(),
                  viewPortfolioButton()
                ],
              ),
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showSuccessPopUp(context));
    return ManagePortfolio(
      widget.model,
      analytics: widget.analytics,
      observer: widget.observer,
      portfolioMasterID: widget.arguments['portfolioMasterID'] != null
          ? widget.arguments['portfolioMasterID']
          : "",
      readOnly: false,
      managePortfolio: false,
      reloadData: false,
      viewPortfolio: true,
    );
    // return Scaffold(
    //   body: Container(),
    // );
  }

  // Widget alertDialogBox() => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       content: Container(
  //         alignment: Alignment.center,
  //         color: Colors.white,
  //         width: MediaQuery.of(context).size.width * 0.1,
  //         padding: EdgeInsets.only(bottom: 5, right: 10, left: 10),
  //         // height: MediaQuery.of(context).size.height * 0.34,
  //         // height: 200,
  //         child: ListView(
  //           children: [
  //             successImageContainer(),
  //             alertTitle(),
  //             portfolioName(),
  //             viewPortfolioButton()
  //           ],
  //         ),
  //       ),
  //     );

  Widget successImageContainer() => Container(
        width: 87,
        height: 93,
        alignment: Alignment.center,
        child: Image(
            image: AssetImage("assets/animation/tickAnimation_white.gif")),
      );

  Widget alertTitle() => Text(
        (widget.arguments['action'] == "newInstrument"
            ? 'Holding added'
            : 'Successfully Created'),
        style: headline1.copyWith(fontSize: 20),
        textAlign: TextAlign.center,
      );

  Widget portfolioName() => Container(
        margin: EdgeInsets.only(top: 7),
        child: Text(
          (widget.arguments['action'] == "newInstrument"
              ? widget.arguments['holdingName']
              : widget.arguments['portfolio_name']),
          style: bodyText1.copyWith(color: Color(0xff8e8e8e), fontSize: 12.0),
          textAlign: TextAlign.center,
        ),
      );

  Widget viewPortfolioButton() => Container(
      margin: EdgeInsets.only(top: 25, left: 30, right: 30),
      width: 180,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(0.0),
        ),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 42,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                minHeight: 42),
            alignment: Alignment.center,
            child: Text(
              "VIEW PORTFOLIO",
              style: buttonStyle.copyWith(fontSize: 9, letterSpacing: 2),
            ),
          ),
        ),
        onPressed: () {
          _analyticsViewPortfolioSuccessEvent(
              widget.arguments['portfolio_name']);
          Navigator.of(context).pop(true);
          Navigator.of(context).pushReplacementNamed(
              '/portfolio_view/' +
                  widget.arguments['portfolioMasterID'].toString(),
              arguments: {"readOnly": false});
        },
      ));
}
