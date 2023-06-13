import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/controller_switch.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

final log = getLogger('SuccessPageForSmallScreen');

class SuccessPageForSmallScreen extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  String action;

  Map arguments;

  SuccessPageForSmallScreen(this.model,
      {this.analytics, this.observer, this.action = "edit", this.arguments});

  @override
  State<StatefulWidget> createState() {
    return _SuccessPageForSmallScreenState();
  }
}

class _SuccessPageForSmallScreenState extends State<SuccessPageForSmallScreen> {
  Future<Null> _analyticsWatchlistToggleEvent() async {
    widget.analytics.logEvent(name: 'add_to_wishlist', parameters: {
      'item_id': "add_manually",
      'item_name': "portfolio_success_watchlist_on_off",
      'content_type': "watchlist_toggle_button",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Theme.of(context).buttonColor),
          centerTitle: true,
          elevation: 0,
        ),
        body: mainContainer(
            containerColor: Colors.white,
            context: context,
            paddingLeft: getScaledValue(16),
            paddingRight: getScaledValue(16),
            child: widget.model.isLoading ? preLoader() : _buildBody()));
  }

  Widget _buildBody() {
    return ListView(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Image(
              image:
                  new AssetImage("assets/animation/tickAnimation_white.gif")),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (widget.arguments['action'] == "newInstrument"
                  ? 'Holding added'
                  : 'Successfully added'),
              style: headline1,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: getScaledValue(11),
            ),
            Text(
              (widget.arguments['action'] == "newInstrument"
                  ? widget.arguments['holdingName']
                  : widget.arguments['portfolio_name']),
              style: bodyText1.copyWith(color: Color(0xff8e8e8e)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(
          height: getScaledValue(20),
        ),
        gradientButton(
            context: context,
            caption: "view portfolio",
            onPressFunction: () {
              _analyticsViewPortfolioSuccessEvent(
                  widget.arguments['portfolio_name']);
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context,
                  '/portfolio_view/' +
                      widget.arguments['portfolioMasterID'].toString(),
                  arguments: {"readOnly": false});
            }),
        widget.arguments['action'] == "newPortfolio"
            ? setPortfolioLive()
            : emptyWidget,
      ],
    );
  }

  Future<Null> _analyticsViewPortfolioSuccessEvent(String portfolioName) async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "add_manually",
      'item_name': "portfolio_success_view",
      'content_type': "view_portfolio_button",
      'item_list_name': portfolioName
    });
  }

  Widget setPortfolioLive() {
    if (widget.model
                .userPortfoliosData[widget.arguments['portfolioMasterID']] ==
            null ||
        widget.model.userPortfoliosData[widget.arguments['portfolioMasterID']]
                ['type'] ==
            null) {
      return Container();
    }
    return Column(
      children: [
        SizedBox(
          height: getScaledValue(16),
        ),
        Text(
            "You will be able to monitor daily activity in this portfolio via your home page. You will also receive hyper-personalized insights. To disable these, you can mark your portfolio as a watchlist instead",
            style: bodyText4),
        SizedBox(
          height: getScaledValue(5),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mark as Watchlist:",
              style: bodyText5,
            ),
            ControlledSwitch(
                value: widget.model.userPortfoliosData[
                            widget.arguments['portfolioMasterID']]['type'] ==
                        "1"
                    ? false
                    : true,
                onChanged: (newValue) async {
                  await _analyticsWatchlistToggleEvent();
                  var type;
                  setState(() {
                    if (newValue) {
                      type = 0;
                    } else {
                      type = 1;
                    }
                    widget.model.setLoader(true);
                  });

                  Map<String, dynamic> responseData = await widget.model
                      .setPortfolioMasterDefault(
                          widget.arguments['portfolioMasterID'].toString(),
                          type);
                  if (responseData['status'] == true) {
                    setState(() {
                      widget.model.setLoader(false);
                    });
                  }
                })
          ],
        ),
      ],
    );
  }
}
