import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share/share.dart';

import '../../../models/main_model.dart';
import '../../../widgets/widget_common.dart';

final log = getLogger('PortfolioAnalyzerReport');

class InvitationRefCodeLarge extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  InvitationRefCodeLarge(
    this.model, {
    this.analytics,
    this.observer,
  });

  @override
  State<StatefulWidget> createState() {
    return _InvitationRefCodeLargeState();
  }
}

class _InvitationRefCodeLargeState extends State<InvitationRefCodeLarge> {
  final controller = ScrollController();

  bool _loading = false;
  String pageType = 'invitations';

  Map<dynamic, dynamic> response_referal_code;
  Map<dynamic, dynamic> response_referal_history;
  List historyData = [];
  var referral_code;
  var limit;
  var available;

  void getReferralCode() async {
    setState(() {
      _loading = true;
    });
    response_referal_code = await widget.model.getReferralCode();

    if (response_referal_code['status'] == true) {
      referral_code = response_referal_code['response']['referral_code'];
      limit = response_referal_code['response']['limit'];
      available = response_referal_code['response']['available'];
    } else {
      available = 0;
    }

    getReferralHistory();
    // setState(() {
    //   _loading = false;
    // });
  }

  void getReferralHistory() async {
    setState(() {
      _loading = true;
    });
    response_referal_history = await widget.model.getReferralHistory();

    if (response_referal_history['status'] == true) {
      historyData = response_referal_history['response'];
    }

    if (historyData.isNotEmpty)
      setState(() {
        pageType = 'referralHistory';
      });
    else
      setState(() {
        pageType = 'invitations';
      });

    setState(() {
      _loading = false;
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getReferralCode();
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
      return PageWrapper(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          appBar: PreferredSize(
            // for larger & medium screen sizes
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            child: NavigationTobBar(
              widget.model,
              openDrawer: () => _scaffoldKey.currentState.openDrawer(),
            ),
          ),
          body: _buildBody(),
        ),
      );
    });
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      return Row(
        children: [
          _leftSideNavigator(),
          Expanded(
            child: Container(
              child: mainContainerChild(),
            ),
          ),
        ],
      ); //_autocompleteTextField(); //_buildBodyContent();

    }
  }

  _leftSideNavigator() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return deviceType == DeviceScreenType.tablet
        ? Container()
        : NavigationLeftBar(
            isSideMenuHeadingSelected: 99,
            isSideMenuSelected: 0,
          );
  }

  Widget mainContainerChild() {
    if (widget.model.isLoading) {
      return preLoader();
    } else if (pageType == "referralHistory") {
      return _buildReferralHistory();
    } else if (pageType == "shareReferralCode") {
      return _buildShareRefCode();
    } else {
      return _buildBodyContent();
    }
  }

  TextStyle headline = TextStyle(
      fontSize: ScreenUtil().setSp(22),
      fontWeight: FontWeight.w800,
      fontFamily: 'nunito',
      letterSpacing: 0.41,
      color: Color(0xff383838));

  TextStyle headline1 = TextStyle(
      fontSize: ScreenUtil().setSp(14),
      fontWeight: FontWeight.w800,
      fontFamily: 'nunito',
      letterSpacing: 0.41,
      color: Color(0xff383838));

  TextStyle body0 = TextStyle(
      fontSize: ScreenUtil().setSp(14),
      fontWeight: FontWeight.w700,
      fontFamily: 'nunito',
      letterSpacing: 1.30,
      color: Color(0xff034bd9));

  TextStyle body1 = TextStyle(
      fontSize: ScreenUtil().setSp(16),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.3,
      color: Color(0xff383838));

  TextStyle body2 = TextStyle(
      fontSize: ScreenUtil().setSp(14),
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      letterSpacing: 0.2,
      color: Color(0xff383838));
  TextStyle body3 = TextStyle(
      fontSize: ScreenUtil().setSp(10),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.16,
      color: Color(0xff818181));
  TextStyle body4 = TextStyle(
      fontSize: ScreenUtil().setSp(12),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.22,
      color: Color(0xffededed));

  Widget _buildBodyContent() {
    List<Widget> _children = [];

    _children.add(Container(
      height: 600,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
                height: 400,
                // 185
                padding: EdgeInsets.all(10.0),
                //margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfffcdf01), Color(0xfffcdf01)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text("A Priority Pass to Qfinr",
                          textAlign: TextAlign.center, style: headline),
                    ),
                    SizedBox(
                      height: getScaledValue(30),
                    ),
                    _group_invite_image()
                  ],
                )),
          ),
          Positioned(
              top: 255,
              // 170
              left: getScaledValue(15.0),
              right: getScaledValue(15.0),
              // width: getScaledValue(330.0),
              height: getScaledValue(230),
              child: inviteCard()),
        ],
      ),
    ));

    return ListView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      children: _children,
    );
  }

  _group_invite_image() {
    if (!kIsWeb) {
      return Container(
        child: svgImage(
          'assets/images/group_invite.svg',
          //height: 200
          //width: 35,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Container(
        child: Align(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/group_invite_small.png',
            fit: BoxFit.contain,
            //width: double.maxFinite,
            //height: 1000,
          ),
        ),
      );
    }
  }

  Widget inviteCard() {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Color(0xffe9e9e9), width: getScaledValue(1)),
                borderRadius: BorderRadius.circular(getScaledValue(4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: getScaledValue(24),
                        horizontal: getScaledValue(22)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Invite Your Friends",
                            textAlign: TextAlign.center, style: body0),
                        SizedBox(height: getScaledValue(18)),
                        Text(
                            "Share Your Best Ideas & Power Intelligent Investment Decisions",
                            textAlign: TextAlign.center,
                            style: body1),
                        SizedBox(height: getScaledValue(38)),
                        _submitButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  Widget _submitButton() {
    return gradientButtonLarge(
        context: context,
        caption: "Invite Friends",
        onPressFunction: () {
          share_ref_code(context);
        });
  }

  Widget _submitButtonReferralHistory() {
    return gradientButtonLarge(
        context: context,
        caption: "Invite Friends",
        buttonDisabled: available != 0 ? false : true,
        onPressFunction: () {
          if (available != 0) {
            share_ref_code(context);
          }
        });
  }

  Widget _buildReferralHistory() {
    List<Widget> _children = [];
    if (historyData.isNotEmpty) {
      historyData.forEach((element) {
        final DateTime now = DateTime.parse(element['date_used']);
        final DateFormat formatter = DateFormat('dd,MMM yyyy');
        final String formatted = formatter.format(now);
        _children.add(Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60.0,
                        height: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Color(0xffd9f9f3),
                          minRadius: 40.0,
                          child: Text(
                            getFirstCharString(element),
                            style: body2,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(getString(element), style: body2),
                            Text(formatted, style: body3),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                )
              ],
            )));
      });
    }

    return historyData.isNotEmpty
        ? Container(
            color: Colors.white,
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: available != 0 ? 140 : 120,
                      color: Color(0xfffcdf01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: Text("A Priority Pass to Qfinr",
                                        textAlign: TextAlign.left,
                                        style: headline),
                                  ),
                                ),
                                available != 0
                                    ? Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 6),
                                        decoration: new BoxDecoration(
                                            color: Color(0xffed695f),
                                            border: Border.all(
                                                width: 1.0,
                                                color: Color(0xffed695f)),
                                            borderRadius: BorderRadius.circular(
                                                getScaledValue(5))),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 3),
                                        child: Text('$available invites left!',
                                            textAlign: TextAlign.center,
                                            style: body3.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.18)),
                                      )
                                    : emptyWidget
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset(
                              'assets/images/group_invite_small.png',
                              fit: BoxFit.contain,
                              //width: double.maxFinite,
                              //height: 120,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("REFFERAL HISTORY",
                          textAlign: TextAlign.center, style: headline1),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
                Expanded(
                    child: ListView(
                  // controller: controller,
                  physics: ClampingScrollPhysics(),
                  children: _children,
                )),
                available != 0
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: _submitButtonReferralHistory(),
                      )
                    : _availableEmptyMessage()
              ],
            ),
          )
        : Container(
            child: _refferalhistoryEmptyMessage(),
          );
  }

  String getFirstCharString(dynamic element) {
    try {
      if (element['refer_customer_name'] is bool) {
        return "";
      }
      return element['refer_customer_name'].substring(0, 1).toUpperCase();
    } catch (e) {
      return "";
    }
  }

  String getString(dynamic element) {
    try {
      if (element['refer_customer_name'] is bool) {
        return "";
      }
      return element['refer_customer_name'].toString();
    } catch (e) {
      return "";
    }
  }

  Widget _refferalhistoryEmptyMessage() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                    "No referrals as yet. We look forward to welcoming your friends to qfinr.",
                    textAlign: TextAlign.center,
                    style: body1),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _submitButtonReferralHistory(),
          )
        ],
      ),
    );
  }

  Widget _availableEmptyMessage() {
    return Container(
      decoration: new BoxDecoration(
          color: Color(0xff3e3e3e),
          border: Border.all(width: 1.0, color: Color(0xff3e3e3e)),
          borderRadius: BorderRadius.circular(getScaledValue(5))),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
          "You are a superstar! Thank you for inviting your friends. Unfortunately, no more invitations are currently available.",
          textAlign: TextAlign.center,
          style: body4),
    );
  }

  // share referral code
  Widget _buildShareRefCode() {
    return Container(
      height: MediaQuery.of(context).size.height * 1.0,
      color: Color(0xfffcdf01),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text("A Priority Pass to Qfinr",
                textAlign: TextAlign.center, style: headline),
          ),
          SizedBox(
            height: getScaledValue(30),
          ),
          _group_invite_image(),
          // share_ref_code()
        ],
      ),
    );
  }

  share_ref_code(BuildContext context) async {
    Share.share(
      'Hey - I am using qfinr, an amazing app helping make more intelligent investment decisions. I am sending you a personal priority invitation to join. Please enter this special one-time-use code $referral_code when you register on https://app.qfinr.com or download the app from the AppStore or PlayStore',
      subject: 'Qfinr Referral Code',
    );
  }
}
