import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_widget_common.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/widgets/add_deposit_large.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';
import 'package:qfinr/widgets/helpers/portfolio_helper.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

Widget portfolioMasterBoxForLarge(BuildContext context, Map portfolioData,
    {Function refreshParent}) {
  List zones = portfolioData['portfolio_zone'].split('_');
  print(portfolioData['public']);
  return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pushNamed(
              context, '/portfolio_view/' + portfolioData['id'],
              arguments: {"readOnly": false}).then((_) => refreshParent()),
          child: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType ==
                  DeviceScreenType.desktop) {
                return Column(
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        // color: Colors.yellow,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 6.0, right: 6.0, bottom: 6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                portfolioData['portfolio_name'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Color(0xff383838),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    PlatformCheck.isSmallScreen(context)
                                        ? portfolioData['type'] == '1'
                                            ? widgetBubble(
                                                title: 'LIVE',
                                                includeBorder: false,
                                                leftMargin: 0,
                                                bgColor: Color(0xffe9f4ff),
                                                textColor: Color(0xff708bc1))
                                            : widgetBubble(
                                                title: 'WATCHLIST',
                                                includeBorder: false,
                                                leftMargin: 0,
                                                bgColor: Color(0xffffece3),
                                                textColor: Color(0xffbc9f91))
                                        : PlatformCheck.isMediumScreen(context)
                                            ? portfolioData['type'] == '1'
                                                ? widgetBubbleForWeb(
                                                    title: 'LIVE',
                                                    includeBorder: false,
                                                    leftMargin: 0,
                                                    bgColor: Color(0xffe9f4ff),
                                                    textColor:
                                                        Color(0xff708bc1))
                                                : widgetBubbleForWeb(
                                                    title: 'WATCHLIST',
                                                    includeBorder: false,
                                                    leftMargin: 0,
                                                    bgColor: Color(0xffffece3),
                                                    textColor:
                                                        Color(0xffbc9f91))
                                            : PlatformCheck.isLargeScreen(
                                                    context)
                                                ? portfolioData['type'] == '1'
                                                    ? widgetBubbleForWeb(
                                                        title: 'LIVE',
                                                        includeBorder: false,
                                                        leftMargin: 0,
                                                        bgColor:
                                                            Color(0xffe9f4ff),
                                                        textColor:
                                                            Color(0xff708bc1))
                                                    : widgetBubbleForWeb(
                                                        title: 'WATCHLIST',
                                                        includeBorder: false,
                                                        leftMargin: 0,
                                                        bgColor:
                                                            Color(0xffffece3),
                                                        textColor:
                                                            Color(0xffbc9f91))
                                                : Container(),
                                    Expanded(
                                        child: Row(
                                            children: zones
                                                .map((item) => Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10.0,
                                                        left: 10.0),
                                                    child: widgetZoneFlagForWeb(
                                                        item)))
                                                .toList())),
                                  ],
                                ),
                              ),
                              fundCountForWeb(portfolioData),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        //color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8.0, left: 8.0, top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  Container(
                                      // color: Colors.pink,
                                      width: MediaQuery.of(context).size.width *
                                          0.10,
                                      child: Text(
                                        "Current Value",
                                        maxLines: 2,
                                        style: portfolioBoxHolding.copyWith(
                                          fontSize: 12.0,
                                        ),
                                      )),
                                  SizedBox(width: getScaledValue(3)),
                                  Container(
                                    // color: Colors.orange,
                                    width: MediaQuery.of(context).size.width *
                                        0.10,
                                    child: Text(portfolioData['value'],
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'nunito',
                                            letterSpacing: 0.19,
                                            color: Color(0xff383838))),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(Contants.oneDayReturns,
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.16,
                                              color: Color(0xff818181))),
                                      SizedBox(width: getScaledValue(5)),
                                      (portfolioData['change_sign'] == "up" ||
                                              portfolioData['change_sign'] ==
                                                  "down"
                                          ? Text(
                                              portfolioData['change']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'nunito',
                                                      letterSpacing: 0.17,
                                                      color: Color(0xff474747))
                                                  .copyWith(
                                                      color: portfolioData[
                                                                  'change_sign'] ==
                                                              "up"
                                                          ? colorGreenReturn
                                                          : colorRedReturn))
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                      portfolioData['change_amount'].toString(),
                                      style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.17,
                                              color: Color(0xff474747))
                                          .copyWith(
                                              color: portfolioData[
                                                          'change_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(Contants.monthToDate,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.16,
                                              color: Color(0xff818181))),
                                      SizedBox(width: getScaledValue(5)),
                                      (portfolioData['changeMonth_sign'] ==
                                                  "up" ||
                                              portfolioData[
                                                      'changeMonth_sign'] ==
                                                  "down"
                                          ? Text(
                                              portfolioData['changeMonth']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'nunito',
                                                      letterSpacing: 0.17,
                                                      color: Color(0xff474747))
                                                  .copyWith(
                                                      color: portfolioData[
                                                                  'changeMonth_sign'] ==
                                                              "up"
                                                          ? colorGreenReturn
                                                          : colorRedReturn))
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                      portfolioData['changeMonth_amount']
                                          .toString(),
                                      style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.17,
                                              color: Color(0xff474747))
                                          .copyWith(
                                              color: portfolioData[
                                                          'changeMonth_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(Contants.yearToDate,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.16,
                                              color: Color(0xff818181))),
                                      SizedBox(width: getScaledValue(5)),
                                      (portfolioData['changeYear_sign'] ==
                                                  "up" ||
                                              portfolioData[
                                                      'changeYear_sign'] ==
                                                  "down"
                                          ? Text(
                                              portfolioData['changeYear']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'nunito',
                                                      letterSpacing: 0.17,
                                                      color: Color(0xff474747))
                                                  .copyWith(
                                                      color: portfolioData[
                                                                  'changeYear_sign'] ==
                                                              "up"
                                                          ? colorGreenReturn
                                                          : colorRedReturn))
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                      portfolioData['changeYear_amount']
                                          .toString(),
                                      style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.17,
                                              color: Color(0xff474747))
                                          .copyWith(
                                              color: portfolioData[
                                                          'changeYear_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: portfolioData['public'].toString() == "1"
                                        ? true
                                        : false,
                                    child: widgetBubble(
                                        title: Contants.publicportfolio,
                                        includeBorder: false,
                                        leftMargin: 0,
                                        bgColor: Color(0xfffffce3),
                                        textColor: Color(0xffe6c672)),
                                  ),
                                  Visibility(
                                    visible: portfolioData['public'].toString() == "1",
                                    child: SizedBox(
                                      height: 6,
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => Navigator.pushNamed(
                                            context,
                                            '/portfolio_view/' +
                                                portfolioData['id'],
                                            arguments: {"readOnly": false})
                                        .then((_) => refreshParent()),
                                    child: Text(
                                      "Details",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorBlue,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
                    ]),
                    _horizontalDivider(context),
                  ],
                );
              }
              if (sizingInformation.deviceScreenType ==
                  DeviceScreenType.tablet) {
                return Column(
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.20,
                        // color: Colors.yellow,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 6.0, right: 6.0, bottom: 6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                portfolioData['portfolio_name'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Color(0xff383838),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    PlatformCheck.isSmallScreen(context)
                                        ? portfolioData['type'] == '1'
                                            ? widgetBubble(
                                                title: 'LIVE',
                                                includeBorder: false,
                                                leftMargin: 0,
                                                bgColor: Color(0xffe9f4ff),
                                                textColor: Color(0xff708bc1))
                                            : widgetBubble(
                                                title: 'WATCHLIST',
                                                includeBorder: false,
                                                leftMargin: 0,
                                                bgColor: Color(0xffffece3),
                                                textColor: Color(0xffbc9f91))
                                        : PlatformCheck.isMediumScreen(context)
                                            ? portfolioData['type'] == '1'
                                                ? widgetBubbleForWeb(
                                                    title: 'LIVE',
                                                    includeBorder: false,
                                                    leftMargin: 0,
                                                    bgColor: Color(0xffe9f4ff),
                                                    textColor:
                                                        Color(0xff708bc1))
                                                : widgetBubbleForWeb(
                                                    title: 'WATCHLIST',
                                                    includeBorder: false,
                                                    leftMargin: 0,
                                                    bgColor: Color(0xffffece3),
                                                    textColor:
                                                        Color(0xffbc9f91))
                                            : PlatformCheck.isLargeScreen(
                                                    context)
                                                ? portfolioData['type'] == '1'
                                                    ? widgetBubbleForWeb(
                                                        title: 'LIVE',
                                                        includeBorder: false,
                                                        leftMargin: 0,
                                                        bgColor:
                                                            Color(0xffe9f4ff),
                                                        textColor:
                                                            Color(0xff708bc1))
                                                    : widgetBubbleForWeb(
                                                        title: 'WATCHLIST',
                                                        includeBorder: false,
                                                        leftMargin: 0,
                                                        bgColor:
                                                            Color(0xffffece3),
                                                        textColor:
                                                            Color(0xffbc9f91))
                                                : Container(),
                                    Expanded(
                                        child: Row(
                                            children: zones
                                                .map((item) => Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10.0,
                                                        left: 10.0),
                                                    child: widgetZoneFlagForWeb(
                                                        item)))
                                                .toList())),
                                  ],
                                ),
                              ),
                              fundCountForWeb(portfolioData),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        // color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8.0, left: 8.0, top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  Container(
                                      // color: Colors.pink,
                                      width: MediaQuery.of(context).size.width *
                                          0.13,
                                      child: Text(
                                        "Current Value",
                                        maxLines: 2,
                                        style: portfolioBoxHolding.copyWith(
                                          fontSize: 12.0,
                                        ),
                                      )),
                                  SizedBox(width: getScaledValue(3)),
                                  Container(
                                    // color: Colors.orange,
                                    width: MediaQuery.of(context).size.width *
                                        0.13,
                                    child: Text(portfolioData['value'],
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'nunito',
                                            letterSpacing: 0.19,
                                            color: Color(0xff383838))),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(Contants.oneDayReturns,
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.16,
                                              color: Color(0xff818181))),
                                      SizedBox(width: getScaledValue(5)),
                                      (portfolioData['change_sign'] == "up" ||
                                              portfolioData['change_sign'] ==
                                                  "down"
                                          ? Text(
                                              portfolioData['change']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'nunito',
                                                      letterSpacing: 0.17,
                                                      color: Color(0xff474747))
                                                  .copyWith(
                                                      color: portfolioData[
                                                                  'change_sign'] ==
                                                              "up"
                                                          ? colorGreenReturn
                                                          : colorRedReturn))
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                      portfolioData['change_amount'].toString(),
                                      style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.17,
                                              color: Color(0xff474747))
                                          .copyWith(
                                              color: portfolioData[
                                                          'change_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(Contants.monthToDate,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.16,
                                              color: Color(0xff818181))),
                                      SizedBox(width: getScaledValue(5)),
                                      (portfolioData['changeMonth_sign'] ==
                                                  "up" ||
                                              portfolioData[
                                                      'changeMonth_sign'] ==
                                                  "down"
                                          ? Text(
                                              portfolioData['changeMonth']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'nunito',
                                                      letterSpacing: 0.17,
                                                      color: Color(0xff474747))
                                                  .copyWith(
                                                      color: portfolioData[
                                                                  'changeMonth_sign'] ==
                                                              "up"
                                                          ? colorGreenReturn
                                                          : colorRedReturn))
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                      portfolioData['changeMonth_amount']
                                          .toString(),
                                      style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.17,
                                              color: Color(0xff474747))
                                          .copyWith(
                                              color: portfolioData[
                                                          'changeMonth_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(Contants.yearToDate,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.16,
                                              color: Color(0xff818181))),
                                      SizedBox(width: getScaledValue(5)),
                                      (portfolioData['changeYear_sign'] ==
                                                  "up" ||
                                              portfolioData[
                                                      'changeYear_sign'] ==
                                                  "down"
                                          ? Text(
                                              portfolioData['changeYear']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'nunito',
                                                      letterSpacing: 0.17,
                                                      color: Color(0xff474747))
                                                  .copyWith(
                                                      color: portfolioData[
                                                                  'changeYear_sign'] ==
                                                              "up"
                                                          ? colorGreenReturn
                                                          : colorRedReturn))
                                          : emptyWidget),
                                    ],
                                  ),
                                  Text(
                                      portfolioData['changeYear_amount']
                                          .toString(),
                                      style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'nunito',
                                              letterSpacing: 0.17,
                                              color: Color(0xff474747))
                                          .copyWith(
                                              color: portfolioData[
                                                          'changeYear_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: portfolioData['public'].toString() == "1"
                                        ? true
                                        : false,
                                    child: widgetBubble(
                                        title: Contants.publicportfolio,
                                        includeBorder: false,
                                        leftMargin: 0,
                                        bgColor: Color(0xfffffce3),
                                        textColor: Color(0xffe6c672)),
                                  ),
                                  Visibility(
                                    visible: portfolioData['public'].toString() == "1",
                                    child: SizedBox(
                                      height: 6,
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => Navigator.pushNamed(
                                            context,
                                            '/portfolio_view/' +
                                                portfolioData['id'],
                                            arguments: {"readOnly": false})
                                        .then((_) => refreshParent()),
                                    child: Text(
                                      "Details",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorBlue,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
                    ]),
                    _horizontalDivider(context),
                  ],
                );
              }
              return Container();
            },
          )));
}

// confirmDeleteForDeposit(BuildContext context, MainModel model, Map portfolio,
//     Function refreshParentState) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               width: 200,
//               //  color: Colors.orange,
//               child: Text(
//                 "Confirm Delete!",
//                 textAlign: TextAlign.start,
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'roboto',
//                     letterSpacing: 0.25,
//                     color: Color(0xffa5a5a5)),
//               ),
//             ),
//             GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Icon(Icons.close, color: Color(0xffcccccc), size: 18),
//             )
//           ],
//         ),
//         content: Container(
//             //  color: Colors.pink,
//             width: MediaQuery.of(context).size.width * 0.4,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "This will delete the deposit. Are you sure you want to proceed?",
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'roboto',
//                         letterSpacing: 0.25,
//                         color: Color(0xffa5a5a5)),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 15.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Container(
//                             height: 40,
//                             child: flatButtonTextForWeb("NO", context,
//                                 borderColor: colorBlue,
//                                 fontSize: 11,
//                                 onPressFunction: () =>
//                                     Navigator.of(context).pop(false))),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 8.0),
//                           child: Container(
//                             height: 40,
//                             width: 120,
//                             child: gradientButtonForWeb(
//                               context: context,
//                               caption: "Yes",
//                               onPressFunction: () {
//                                 // Navigator.of(context)
//                                 //     .popUntil((route) => route.isFirst);
//                                 deleteAlertForDeposit(context, model, portfolio,
//                                     refreshParentState);
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             )),
//         actions: <Widget>[],
//       );
//     },
//   );
// }

// deleteAlertForDeposit(BuildContext context, MainModel model, Map portfolio,
//     Function refreshParentState) async {
//   Navigator.of(context).pop(true);
//   confirmDeleteForLargeDeposit(
//     context,
//     model,
//     portfolio['portfolio_master_id'],
//     portfolio['portfolio_id'],
//     portfolio['depositData']['ric'],
//     refreshParentState,
//   );
// }

// confirmDeleteForLargeDeposit(context, MainModel model, String portfolioMasterID,
//     String portfolioDepositID, String ric, Function callback) async {
//   int portfolioCount = 0;

//   model.setLoader(true);

//   model.userPortfoliosData[portfolioMasterID]['portfolios']
//       .forEach((key, portfolios) {
//     portfolios.forEach((element) {
//       portfolioCount++;
//     });
//   });

//   Map<String, dynamic> responseData;

//   if (portfolioCount == 1) {
//     responseData = await model.removePortfolioMaster(portfolioMasterID);
//   } else {
//     // remove the deposit item if exists
//     model.userPortfoliosData[portfolioMasterID]['portfolios']['Deposit']
//         ?.removeWhere((item) => item["ric"] == ric);

//     responseData = await model.updateCustomerPortfolioData(
//         portfolios: model.userPortfoliosData[portfolioMasterID]['portfolios'],
//         portfolioMasterID: portfolioMasterID,
//         portfolioName: model.userPortfoliosData[portfolioMasterID]
//             ['portfolio_name']);
//   }

//   if (responseData['status'] == true) {
//     if (portfolioCount == 1) {
//       Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');
//     }
//   }
//   callback();
//   // model.setLoader(false);
// }

_horizontalDivider(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: 1.25,
        width: MediaQuery.of(context).size.width,
        color: Color(0xffeaeaea),
      ),
    );

Widget fundCountForWeb(Map portfolioData) {
  List<Widget> _children = [];

  String fundCount = "";
  if (portfolioData['portfolios'] != null) {
    bool firstLoop = true;

    portfolioData['portfolios'].forEach((fundType, portfolio) {
      if (!firstLoop) {
        _children.add(Container(
            margin: EdgeInsets.symmetric(horizontal: getScaledValue(9)),
            child: Text("|", style: TextStyle(color: Color(0xffdddddd)))));
        fundCount += " | ";
      } else {
        firstLoop = false;
      }
      int count = 0;

      portfolio.forEach((e) {
        if (double.parse(e['weightage']) > 0.0001) {
          count++;
        }
      });
      _children.add(RichText(
          text: TextSpan(
              text: count.toString(),
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'nunito',
                  letterSpacing: 0.21,
                  color: Color(0xff383838)),
              children: [
            TextSpan(
                text: " " + (fundType != null ? fundType.toUpperCase() : ""),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'nunito',
                    letterSpacing: 0.21,
                    color: Color(0xff979797)))
          ])));
      fundCount += count.toString() + " " + fundType.toUpperCase();
    });
  }

  return Text(fundCount,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          fontFamily: 'nunito',
          letterSpacing: 0.21,
          color: Color(0xff979797)));
}

Widget fundCountForWeb2(Map portfolioData) {
  List<Widget> _children = [];

  if (portfolioData['portfolios'] != null) {
    bool firstLoop = true;

    portfolioData['portfolios'].forEach((fundType, portfolio) {
      if (!firstLoop) {
        _children.add(Container(
            margin: EdgeInsets.symmetric(horizontal: getScaledValue(9)),
            child: Text("  ", style: TextStyle(color: Color(0xffdddddd)))));
      } else {
        firstLoop = false;
      }
      int count = 0;

      portfolio.forEach((e) {
        if (double.parse(e['weightage']) > 0.0001) {
          count++;
        }
      });
      _children.add(RichText(
          text: TextSpan(
              text: (fundType != null ? fundType.toUpperCase() + ": " : ""),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'nunito',
                  letterSpacing: 0.21,
                  color: Color(0xff979797)),
              children: [
            TextSpan(
              text: count.toString(),
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'nunito',
                  letterSpacing: 0.21,
                  color: Color(0xff383838)),
            )
          ])));
    });
  }

  // return Text(fundCount,
  //     overflow: TextOverflow.ellipsis,
  //     maxLines: 2,
  //     style: TextStyle(
  //     fontSize: 12.0,
  //     fontWeight: FontWeight.w500,
  //     fontFamily: 'nunito',
  //     letterSpacing: 0.21,
  //     color: Color(0xff979797)));

  return Wrap(children: _children);
}

Widget portfolioListBoxForLarge(
    BuildContext context, String type, dynamic portfolioList,
    {String portfolioMasterID,
    MainModel model,
    Function callBackForDelete,
    Function refreshParentState,
    bool readOnly = false,
    String sortType,
    String sortOrder,
    Widget sortWidget}) {
  List<Widget> _widgetList = [];

  List portfolioListData = [];

  if (portfolioList != null) {
    DateTime pastholdDate = DateTime.now();

    portfolioList.forEach((fundType, portfolios) {
      portfolios.map((item) {
        int index = portfolios.indexOf(item);
        dynamic weightage;

        if (item['weightage'] is String) {
          weightage = double.parse(item['weightage']);
        } else {
          weightage = item['weightage'];
        }

        if (item['depositData'] != null) {
          pastholdDate = DateTime.parse(item['depositData']['maturity_date']);

          if (type == "all" || type == "current") {
            if (pastholdDate.isBefore(DateTime.now())) {
            } else {
              _widgetList.add(portfolioBoxForLarge(portfolioMasterID, model,
                  callBackForDelete, type, context, index, item,
                  refreshParentState: refreshParentState, readOnly: readOnly));

              portfolioListData.add({"index": index, "item": item});
            }
          } else {
            if (pastholdDate.isBefore(DateTime.now())) {
              _widgetList.add(portfolioBoxForLarge(portfolioMasterID, model,
                  callBackForDelete, type, context, index, item,
                  refreshParentState: refreshParentState, readOnly: readOnly));

              portfolioListData.add({"index": index, "item": item});
            } else {}
          }
        } else {
          if (((type == "all" || type == "current") && weightage > 0) ||
              ((type == "all" || type == "past") &&
                  weightage <= 0 &&
                  item['transactions'] != null)) {
            _widgetList.add(portfolioBoxForLarge(portfolioMasterID, model,
                callBackForDelete, type, context, index, item,
                refreshParentState: refreshParentState, readOnly: readOnly));
            portfolioListData.add({"index": index, "item": item});
          }
        }
      }).toList();
    });
  }

  if (sortType != null) {
    portfolioListData;
    if (sortType == "change" || sortType == "weightage") {
      //portfolioListData.sort((a, b) => double.parse(a['item'][sortType]).compareTo(double.parse(b['item'][sortType])));
      portfolioListData.sort((a, b) => strictNum(a['item'][sortType])
          .compareTo(strictNum(b['item'][sortType])));
    } else {
      portfolioListData
          .sort((a, b) => a['item'][sortType].compareTo(b['item'][sortType]));
    }

    if (sortOrder == "desc") {
      portfolioListData = portfolioListData.reversed.toList();
    }
  }

  Widget portfolioListDataForWeb = Padding(
    padding: EdgeInsets.only(top: 20.0),
    child: ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: portfolioListData
          .map((item) => portfolioBoxForLarge2(portfolioMasterID, model,
              callBackForDelete, type, context, item['index'], item['item'],
              refreshParentState: refreshParentState, readOnly: readOnly))
          .toList(),
    ),
  );

  Widget returnForWeb = Column(
    children: [
      // sortWidget,
      portfolioListDataForWeb,
      portfolioListData.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                "No holdings",
                style: portfolioBoxName.copyWith(
                  fontSize: 14.0,
                ),
              ),
            )
          : Container(),
    ],
  );

  if (PlatformCheck.isSmallScreen(context)) {
    return ListView(
        //children: _widgetList,
        children: [
          sortWidget,
          ...portfolioListData.map((item) => portfolioBoxForLarge(
              portfolioMasterID,
              model,
              callBackForDelete,
              type,
              context,
              item['index'],
              item['item'],
              refreshParentState: refreshParentState,
              readOnly: readOnly))
        ]);
  } else if (PlatformCheck.isMediumScreen(context) ||
      PlatformCheck.isLargeScreen(context)) {
    return returnForWeb;
  } else {
    return Container();
  }
}

_showAddDepositBottonsheet(context, MainModel model, String portfolioMasterID,
    String portfolioDepositID, Function callback) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: AddDepositLarge(
              model,
              portfolioMasterID,
              portfolioDepositID,
            ),
          );
        });
      }).then((value) {
    callback();
  });
}

Widget portfolioBoxForLarge2(
    String portfolioMasterID,
    MainModel model,
    Function callBackForDelete,
    String type,
    BuildContext context,
    int index,
    Map portfolio,
    {Function refreshParentState,
    bool readOnly = false}) {
  dynamic weightage;
  if (portfolio['weightage'] is String) {
    weightage = double.parse(portfolio['weightage']);
  } else {
    weightage = portfolio['weightage'];
  }
  String depositFrequency = '';
  String depositRate = '';
  String maturityDate = '';
  Map frequencyMap = {
    "M": {"value": "Monthly"},
    "Q": {"value": "Quarterly"},
    "H": {"value": "Half Yearly"},
    "Y": {"value": "Yearly"},
  };
  if (portfolio['type'] == "Deposit" && portfolio['depositData'] != null) {
    depositFrequency = portfolio['depositData']['frequency'] ?? '';
    if (depositFrequency != '')
      depositFrequency = frequencyMap[depositFrequency]['value'];
    depositRate = portfolio['depositData']['rate'] ?? '';

    var parsedDate =
        DateTime.parse(portfolio['depositData']['maturity_date']) ?? '';
    final date_format = DateFormat("dd MMM yyyy");
    maturityDate = date_format.format(parsedDate).toString();
  }

  return ResponsiveBuilder(
    builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: type == "past"
                ? portfolio['type'] == "Deposit" &&
                        portfolio['depositData'] != null
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => portfolio['type'] == "Deposit"
                            ? _showAddDepositBottonsheet(
                                context,
                                model,
                                portfolio['portfolio_master_id'],
                                portfolio['portfolio_id'],
                                refreshParentState)
                            : portfolio['portfolio_master_id'] == null ||
                                    portfolio['type'] == null ||
                                    portfolio['ric'] == null ||
                                    portfolio['zone'] == null ||
                                    index == null
                                ? {}
                                : Navigator.pushNamed(
                                    context,
                                    '/edit_ric_large/' +
                                        portfolio['portfolio_master_id'] +
                                        "/" +
                                        portfolio['type'] +
                                        "/" +
                                        portfolio['ric'] +
                                        "/" +
                                        portfolio['zone'] +
                                        "/" +
                                        index.toString(),
                                    arguments: {
                                        'refreshParentState':
                                            refreshParentState,
                                        'readOnly': readOnly
                                      }).then((_) => refreshParentState()),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  // color: Colors.orangeAccent,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  portfolio['depositData']
                                                          ['bank_name'] ??
                                                      '',
                                                  maxLines: 2,
                                                  style:
                                                      portfolioBoxName.copyWith(
                                                    fontSize: 14.0,
                                                  )),
                                              portfolio['depositData']
                                                          ['display_name'] !=
                                                      null
                                                  ? Text(
                                                      limitChar(
                                                          portfolio[
                                                                  'depositData']
                                                              ['display_name'],
                                                          length: (weightage > 0
                                                              ? 25
                                                              : 35)),
                                                      style: portfolioBoxName
                                                          .copyWith(
                                                        fontSize: 14.0,
                                                      ))
                                                  : emptyWidget,
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: widgetBubble(
                                                  title:
                                                      portfolio['name'] != null
                                                          ? portfolio['name']
                                                              .toUpperCase()
                                                          : "",
                                                  leftMargin: 0,
                                                  textColor: Color(0xffa7a7a7)),
                                            ),
                                            widgetZoneFlag(portfolio['zone']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                              // color: Colors.pink,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(
                                            "Current Value",
                                            maxLines: 2,
                                            style: portfolioBoxHolding.copyWith(
                                              fontSize: 12.0,
                                            ),
                                          )),
                                          SizedBox(width: getScaledValue(3)),
                                          Container(
                                              // color: Colors.green,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child:
                                                  Text(portfolio['value'] ?? '',
                                                      maxLines: 2,
                                                      style: appBodyH3.copyWith(
                                                        fontSize: 12.0,
                                                      ))),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              // color: Colors.pink,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(
                                            "Annual Interest Rate",
                                            maxLines: 2,
                                            style: portfolioBoxHolding.copyWith(
                                              fontSize: 12.0,
                                            ),
                                          )),
                                          SizedBox(width: getScaledValue(3)),
                                          Container(
                                              // color: Colors.green,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(
                                                  '$depositRate%($depositFrequency)',
                                                  maxLines: 2,
                                                  style: appBodyH3.copyWith(
                                                    fontSize: 12.0,
                                                  ))),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              // color: Colors.pink,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(
                                            "Maturity Value",
                                            maxLines: 2,
                                            style: portfolioBoxHolding.copyWith(
                                              fontSize: 12.0,
                                            ),
                                          )),
                                          SizedBox(width: getScaledValue(3)),
                                          Container(
                                              // color: Colors.green,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(
                                                  portfolio['depositData']
                                                          ['maturity_amount'] ??
                                                      "",
                                                  maxLines: 2,
                                                  style: appBodyH3.copyWith(
                                                    fontSize: 12.0,
                                                  ))),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              // color: Colors.pink,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(
                                            "Maturity On",
                                            maxLines: 2,
                                            style: portfolioBoxHolding.copyWith(
                                              fontSize: 12.0,
                                            ),
                                          )),
                                          SizedBox(width: getScaledValue(3)),
                                          Container(
                                              // color: Colors.green,
                                              // width:
                                              //     MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.10,
                                              child: Text(maturityDate,
                                                  maxLines: 2,
                                                  style: appBodyH3.copyWith(
                                                    fontSize: 12.0,
                                                  ))),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                                GestureDetector(
                                  behavior: HitTestBehavior
                                      .opaque, ///////////////////////
                                  onTap: () {
                                    // confirmDeleteForDeposit(context, model,
                                    //     portfolio, refreshParentState);
                                    callBackForDelete(
                                        ricIndex: index,
                                        selectedSuggestion: {
                                          "ric": portfolio['ric'],
                                          "name": model.userPortfoliosData[
                                                          portfolioMasterID]
                                                      ['portfolios']
                                                  [portfolio['type']][index]
                                              ['name'],
                                          'zone': portfolio['zone'],
                                          'type': portfolio['type'],
                                        });
                                  },
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: colorBlue,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: Color(0xffeaeaea),
                              ),
                            ),
                          ],
                        ))
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // color: Colors.orangeAccent,
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(portfolio['ticker'],
                                          style: transactionBoxLabel.copyWith(
                                            fontSize: 10.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                          portfolio['name'] != null
                                              ? portfolio['name']
                                              : "",
                                          maxLines: 2,
                                          style: portfolioBoxName.copyWith(
                                            fontSize: 14.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                          Contants.close +
                                              Contants.clone +
                                              " " +
                                              portfolio['latestDatePrice']
                                                  .toString(),
                                          style: lastCloseText),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: widgetBubble(
                                                title: portfolio['type'] != null
                                                    ? portfolio['type']
                                                        .toUpperCase()
                                                    : "",
                                                leftMargin: 0,
                                                includeBorder: true,
                                                textColor: Color(0xffa7a7a7)),
                                          ),
                                          widgetZoneFlagForWeb(
                                              portfolio['zone']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              //         Image.asset(
                                              // weightage > 0
                                              // 	? "assets/icon/icon_units.png"
                                              // 	: "assets/icon/icon_clock.png",
                                              // width: getScaledValue(14),color: Colors.white,),
                                              Container(
                                                // color: Colors.orangeAccent,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.07,
                                                child: Text(
                                                    weightage > 0
                                                        ? (portfolio['type'] !=
                                                                    null &&
                                                                portfolio['type']
                                                                        .toLowerCase() ==
                                                                    "commodity"
                                                            ? " grams"
                                                            : " units")
                                                        : "", //1 Jan - 28 Aug, 2020
                                                    style: portfolioBoxHolding
                                                        .copyWith(
                                                      fontSize: 12.0,
                                                    )),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: getScaledValue(3)),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5.0),
                                                child: Image.asset(
                                                    weightage > 0
                                                        ? "assets/icon/icon_units.png"
                                                        : "assets/icon/icon_clock.png",
                                                    width: getScaledValue(14)),
                                              ),
                                              Container(
                                                // color: Colors.orangeAccent,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.15,
                                                child: Text(
                                                    weightage > 0
                                                        ? portfolio['weightage']
                                                            .toString()
                                                        : holdingPeriod(
                                                            portfolio),
                                                    //1 Jan - 28 Aug, 2020
                                                    style: portfolioBoxHolding
                                                        .copyWith(
                                                      fontSize: 12.0,
                                                    )),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => portfolio['type'] == "Deposit"
                                    ? Navigator.pushReplacementNamed(
                                        context,
                                        '/add_instrument',
                                        arguments: {
                                          'portfolioMasterID':
                                              portfolio['portfolio_master_id'],
                                          "viewDeposit": true,
                                          "portfolioDepositID":
                                              portfolio['portfolio_id']
                                        },
                                      ).then((_) => refreshParentState())
                                    : portfolio['portfolio_master_id'] ==
                                                null ||
                                            portfolio['type'] == null ||
                                            portfolio['ric'] == null ||
                                            portfolio['zone'] == null ||
                                            index == null
                                        ? {}
                                        : Navigator.pushNamed(
                                                context,
                                                '/edit_ric_large/' +
                                                    portfolio[
                                                        'portfolio_master_id'] +
                                                    "/" +
                                                    portfolio['type'] +
                                                    "/" +
                                                    portfolio['ric'] +
                                                    "/" +
                                                    portfolio['zone'] +
                                                    "/" +
                                                    index.toString(),
                                                arguments: {
                                                'refreshParentState':
                                                    refreshParentState,
                                                'readOnly': readOnly
                                              })
                                            .then((_) => refreshParentState()),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorBlue,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width,
                              color: Color(0xffeaeaea),
                            ),
                          ),
                        ],
                      )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => portfolio['type'] == "Deposit"
                        ? _showAddDepositBottonsheet(
                            context,
                            model,
                            portfolio['portfolio_master_id'],
                            portfolio['portfolio_id'],
                            refreshParentState)
                        : portfolio['portfolio_master_id'] == null ||
                                portfolio['type'] == null ||
                                portfolio['ric'] == null ||
                                portfolio['zone'] == null ||
                                index == null
                            ? {}
                            : Navigator.pushNamed(
                                context,
                                '/edit_ric_large/' +
                                    portfolio['portfolio_master_id'] +
                                    "/" +
                                    portfolio['type'] +
                                    "/" +
                                    portfolio['ric'] +
                                    "/" +
                                    portfolio['zone'] +
                                    "/" +
                                    index.toString(),
                                arguments: {
                                    'refreshParentState': refreshParentState,
                                    'readOnly': readOnly
                                  }).then((_) => refreshParentState()),
                    child: portfolio['type'] == "Deposit" &&
                            portfolio['depositData'] != null
                        ? Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    portfolio['depositData']
                                                            ['bank_name'] ??
                                                        '',
                                                    maxLines: 2,
                                                    style: portfolioBoxName
                                                        .copyWith(
                                                      fontSize: 14.0,
                                                    )),
                                                portfolio['depositData']
                                                            ['display_name'] !=
                                                        null
                                                    ? Text(
                                                        limitChar(
                                                            portfolio[
                                                                    'depositData']
                                                                [
                                                                'display_name'],
                                                            length:
                                                                (weightage > 0
                                                                    ? 25
                                                                    : 35)),
                                                        style: portfolioBoxName
                                                            .copyWith(
                                                          fontSize: 14.0,
                                                        ))
                                                    : emptyWidget,
                                              ]),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['name'] !=
                                                            null
                                                        ? portfolio['name']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Current Value",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    portfolio['value'] ?? '',
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Annual Interest Rate",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    '$depositRate%($depositFrequency)',
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Maturity Value",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    portfolio['depositData'][
                                                            'maturity_amount'] ??
                                                        "",
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Maturity On",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(maturityDate,
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                  GestureDetector(
                                    behavior: HitTestBehavior
                                        .opaque, /////////////////////////////
                                    onTap: () {
                                      // confirmDeleteForDeposit(context, model,
                                      //     portfolio, refreshParentState);
                                      callBackForDelete(
                                          ricIndex: index,
                                          selectedSuggestion: {
                                            "ric": portfolio['ric'],
                                            "name": model.userPortfoliosData[
                                                            portfolioMasterID]
                                                        ['portfolios']
                                                    [portfolio['type']][index]
                                                ['name'],
                                            'zone': portfolio['zone'],
                                            'type': portfolio['type'],
                                          });
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorBlue,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(portfolio['ticker'],
                                              style:
                                                  transactionBoxLabel.copyWith(
                                                fontSize: 10.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                              portfolio['name'] != null
                                                  ? portfolio['name']
                                                  : "",
                                              maxLines: 2,
                                              style: portfolioBoxName.copyWith(
                                                fontSize: 14.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                              Contants.close +
                                                  Contants.clone +
                                                  " " +
                                                  portfolio['latestDatePrice']
                                                      .toString(),
                                              style: lastCloseText),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['type'] !=
                                                            null
                                                        ? portfolio['type']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                //         Image.asset(
                                                // weightage > 0
                                                // 	? "assets/icon/icon_units.png"
                                                // 	: "assets/icon/icon_clock.png",
                                                // width: getScaledValue(14),color: Colors.white,),
                                                Container(
                                                  // color: Colors.orangeAccent,
                                                  // width:
                                                  //     MediaQuery.of(context)
                                                  //             .size
                                                  //             .width *
                                                  //         0.07,
                                                  child: Text(
                                                      weightage > 0
                                                          ? (portfolio['type'] !=
                                                                      null &&
                                                                  portfolio['type']
                                                                          .toLowerCase() ==
                                                                      "commodity"
                                                              ? " grams"
                                                              : " units")
                                                          : "", //1 Jan - 28 Aug, 2020
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      )),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: getScaledValue(3)),
                                            Row(
                                              children: [
                                                Image.asset(
                                                    weightage > 0
                                                        ? "assets/icon/icon_units.png"
                                                        : "assets/icon/icon_clock.png",
                                                    width: getScaledValue(14)),
                                                Container(
                                                  // color: Colors.orangeAccent,
                                                  // width:
                                                  //     MediaQuery.of(context)
                                                  //             .size
                                                  //             .width *
                                                  //         0.07,
                                                  child: Text(
                                                      weightage > 0
                                                          ? portfolio[
                                                                  'weightage']
                                                              .toString()
                                                          : holdingPeriod(
                                                              portfolio),
                                                      //1 Jan - 28 Aug, 2020
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.10,
                                                child: Text(
                                              "Current Value",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.10,
                                                child: Text(portfolio['value'],
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(Contants.oneDayReturns,
                                                    style: keyStatsBodyText2
                                                        .copyWith(
                                                      fontSize: 10.0,
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(5)),
                                                (portfolio['change_sign'] ==
                                                            "up" ||
                                                        portfolio[
                                                                'change_sign'] ==
                                                            "down"
                                                    ? Text(
                                                        portfolio['change']
                                                                .toString() +
                                                            "%",
                                                        style: bodyText12.copyWith(
                                                            fontSize: 12,
                                                            color: portfolio[
                                                                        'change_sign'] ==
                                                                    "up"
                                                                ? colorGreenReturn
                                                                : colorRedReturn))
                                                    : emptyWidget),
                                              ],
                                            ),
                                            Text(
                                                portfolio['changeAmount']
                                                    .toString(),
                                                style: bodyText12.copyWith(
                                                    fontSize: 12,
                                                    color: portfolio[
                                                                'change_sign'] ==
                                                            "up"
                                                        ? colorGreenReturn
                                                        : colorRedReturn)),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(Contants.monthToDate,
                                                    style: keyStatsBodyText2
                                                        .copyWith(
                                                      fontSize: 10.0,
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(5)),
                                                (portfolio['changeMonth_sign'] ==
                                                            "up" ||
                                                        portfolio[
                                                                'changeMonth_sign'] ==
                                                            "down"
                                                    ? Text(
                                                        portfolio['changeMonth']
                                                                .toString() +
                                                            "%",
                                                        style: bodyText12.copyWith(
                                                            fontSize: 12,
                                                            color: portfolio[
                                                                        'changeMonth_sign'] ==
                                                                    "up"
                                                                ? colorGreenReturn
                                                                : colorRedReturn))
                                                    : emptyWidget),
                                              ],
                                            ),
                                            Text(
                                                portfolio['changeAmountMonth']
                                                    .toString(),
                                                style: bodyText12.copyWith(
                                                    fontSize: 12,
                                                    color: portfolio[
                                                                'changeMonth_sign'] ==
                                                            "up"
                                                        ? colorGreenReturn
                                                        : colorRedReturn)),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(Contants.yearToDate,
                                                    style: keyStatsBodyText2
                                                        .copyWith(
                                                      fontSize: 10.0,
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(5)),
                                                (portfolio['changeYear_sign'] ==
                                                            "up" ||
                                                        portfolio[
                                                                'changeYear_sign'] ==
                                                            "down"
                                                    ? Text(
                                                        portfolio['changeYear']
                                                                .toString() +
                                                            "%",
                                                        style: bodyText12.copyWith(
                                                            fontSize: 12,
                                                            color: portfolio[
                                                                        'changeYear_sign'] ==
                                                                    "up"
                                                                ? colorGreenReturn
                                                                : colorRedReturn))
                                                    : emptyWidget),
                                              ],
                                            ),
                                            Text(
                                                portfolio['changeAmountYear']
                                                    .toString(),
                                                style: bodyText12.copyWith(
                                                    fontSize: 12,
                                                    color: portfolio[
                                                                'changeYear_sign'] ==
                                                            "up"
                                                        ? colorGreenReturn
                                                        : colorRedReturn)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      ///////////////////////
                                      callBackForDelete(
                                          ricIndex: index,
                                          selectedSuggestion: {
                                            "ric": portfolio['ric'],
                                            "name": model.userPortfoliosData[
                                                            portfolioMasterID]
                                                        ['portfolios']
                                                    [portfolio['type']][index]
                                                ['name'],
                                            'zone': portfolio['zone'],
                                            'type': portfolio['type'],
                                          });
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorBlue,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          ),
                  ));
      }
      if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: type == "past"
                ? portfolio['type'] == "Deposit" &&
                        portfolio['depositData'] != null
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => portfolio['type'] == "Deposit"
                            ? _showAddDepositBottonsheet(
                                context,
                                model,
                                portfolio['portfolio_master_id'],
                                portfolio['portfolio_id'],
                                refreshParentState)
                            : portfolio['portfolio_master_id'] == null ||
                                    portfolio['type'] == null ||
                                    portfolio['ric'] == null ||
                                    portfolio['zone'] == null ||
                                    index == null
                                ? {}
                                : Navigator.pushNamed(
                                    context,
                                    '/edit_ric_large/' +
                                        portfolio['portfolio_master_id'] +
                                        "/" +
                                        portfolio['type'] +
                                        "/" +
                                        portfolio['ric'] +
                                        "/" +
                                        portfolio['zone'] +
                                        "/" +
                                        index.toString(),
                                    arguments: {
                                        'refreshParentState':
                                            refreshParentState,
                                        'readOnly': readOnly
                                      }).then((_) => refreshParentState()),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  // color: Colors.orangeAccent,
                                  // width:
                                  //     MediaQuery.of(context).size.width * 0.15,
                                  width:
                                      MediaQuery.of(context).size.width * 0.20,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  portfolio['depositData']
                                                          ['bank_name'] ??
                                                      '',
                                                  maxLines: 2,
                                                  style:
                                                      portfolioBoxName.copyWith(
                                                    fontSize: 14.0,
                                                  )),
                                              portfolio['depositData']
                                                          ['display_name'] !=
                                                      null
                                                  ? Text(
                                                      limitChar(
                                                          portfolio[
                                                                  'depositData']
                                                              ['display_name'],
                                                          length: (weightage > 0
                                                              ? 25
                                                              : 35)),
                                                      style: portfolioBoxName
                                                          .copyWith(
                                                        fontSize: 14.0,
                                                      ))
                                                  : emptyWidget,
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: widgetBubble(
                                                  title:
                                                      portfolio['name'] != null
                                                          ? portfolio['name']
                                                              .toUpperCase()
                                                          : "",
                                                  leftMargin: 0,
                                                  textColor: Color(0xffa7a7a7)),
                                            ),
                                            widgetZoneFlag(portfolio['zone']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      child: Container(
                                        // color: Colors.orangeAccent,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    // width:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .width *
                                                    //         0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.13,
                                                    child: Text(
                                                      "Current Value",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    // width:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .width *
                                                    //         0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.13,
                                                    child: Text(
                                                        portfolio['value'] ??
                                                            '',
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                      "Annual Interest Rate",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                        '$depositRate%($depositFrequency)',
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                      "Maturity Value",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                        portfolio['depositData']
                                                                [
                                                                'maturity_amount'] ??
                                                            "",
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                      "Maturity On",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(maturityDate,
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                    GestureDetector(
                                      behavior: HitTestBehavior
                                          .opaque, ///////////////////////
                                      onTap: () {
                                        // confirmDeleteForDeposit(context, model,
                                        //     portfolio, refreshParentState);
                                        callBackForDelete(
                                            ricIndex: index,
                                            selectedSuggestion: {
                                              "ric": portfolio['ric'],
                                              "name": model.userPortfoliosData[
                                                              portfolioMasterID]
                                                          ['portfolios']
                                                      [portfolio['type']][index]
                                                  ['name'],
                                              'zone': portfolio['zone'],
                                              'type': portfolio['type'],
                                            });
                                      },
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: colorBlue,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: Color(0xffeaeaea),
                              ),
                            ),
                          ],
                        ))
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // color: Colors.orangeAccent,
                                width: MediaQuery.of(context).size.width * 0.20,
                                // width: MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(portfolio['ticker'],
                                          style: transactionBoxLabel.copyWith(
                                            fontSize: 10.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                          portfolio['name'] != null
                                              ? portfolio['name']
                                              : "",
                                          maxLines: 2,
                                          style: portfolioBoxName.copyWith(
                                            fontSize: 14.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                          Contants.close +
                                              Contants.clone +
                                              " " +
                                              portfolio['latestDatePrice']
                                                  .toString(),
                                          style: lastCloseText),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: widgetBubbleForWeb(
                                                title: portfolio['type'] != null
                                                    ? portfolio['type']
                                                        .toUpperCase()
                                                    : "",
                                                leftMargin: 0,
                                                textColor: Color(0xffa7a7a7)),
                                          ),
                                          widgetZoneFlagForWeb(
                                              portfolio['zone']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            //         Image.asset(
                                            // weightage > 0
                                            // 	? "assets/icon/icon_units.png"
                                            // 	: "assets/icon/icon_clock.png",
                                            // width: getScaledValue(14),color: Colors.white,),
                                            Container(
                                              // color: Colors.orangeAccent,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                              child: Text(
                                                  weightage > 0
                                                      ? (portfolio['type'] !=
                                                                  null &&
                                                              portfolio['type']
                                                                      .toLowerCase() ==
                                                                  "commodity"
                                                          ? " grams"
                                                          : " units")
                                                      : "", //1 Jan - 28 Aug, 2020
                                                  style: portfolioBoxHolding
                                                      .copyWith(
                                                    fontSize: 12.0,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: getScaledValue(3)),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Image.asset(
                                                  weightage > 0
                                                      ? "assets/icon/icon_units.png"
                                                      : "assets/icon/icon_clock.png",
                                                  width: getScaledValue(14)),
                                            ),
                                            Container(
                                              // color: Colors.orangeAccent,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15,
                                              child: Text(
                                                  weightage > 0
                                                      ? portfolio['weightage']
                                                          .toString()
                                                      : holdingPeriod(
                                                          portfolio),
                                                  //1 Jan - 28 Aug, 2020
                                                  style: portfolioBoxHolding
                                                      .copyWith(
                                                    fontSize: 12.0,
                                                  )),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => portfolio['type'] == "Deposit"
                                    ? Navigator.pushReplacementNamed(
                                        context,
                                        '/add_instrument',
                                        arguments: {
                                          'portfolioMasterID':
                                              portfolio['portfolio_master_id'],
                                          "viewDeposit": true,
                                          "portfolioDepositID":
                                              portfolio['portfolio_id']
                                        },
                                      ).then((_) => refreshParentState())
                                    : portfolio['portfolio_master_id'] ==
                                                null ||
                                            portfolio['type'] == null ||
                                            portfolio['ric'] == null ||
                                            portfolio['zone'] == null ||
                                            index == null
                                        ? {}
                                        : Navigator.pushNamed(
                                                context,
                                                '/edit_ric_large/' +
                                                    portfolio[
                                                        'portfolio_master_id'] +
                                                    "/" +
                                                    portfolio['type'] +
                                                    "/" +
                                                    portfolio['ric'] +
                                                    "/" +
                                                    portfolio['zone'] +
                                                    "/" +
                                                    index.toString(),
                                                arguments: {
                                                'refreshParentState':
                                                    refreshParentState,
                                                'readOnly': readOnly
                                              })
                                            .then((_) => refreshParentState()),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorBlue,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width,
                              color: Color(0xffeaeaea),
                            ),
                          ),
                        ],
                      )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => portfolio['type'] == "Deposit"
                        ? _showAddDepositBottonsheet(
                            context,
                            model,
                            portfolio['portfolio_master_id'],
                            portfolio['portfolio_id'],
                            refreshParentState)
                        : portfolio['portfolio_master_id'] == null ||
                                portfolio['type'] == null ||
                                portfolio['ric'] == null ||
                                portfolio['zone'] == null ||
                                index == null
                            ? {}
                            : Navigator.pushNamed(
                                context,
                                '/edit_ric_large/' +
                                    portfolio['portfolio_master_id'] +
                                    "/" +
                                    portfolio['type'] +
                                    "/" +
                                    portfolio['ric'] +
                                    "/" +
                                    portfolio['zone'] +
                                    "/" +
                                    index.toString(),
                                arguments: {
                                    'refreshParentState': refreshParentState,
                                    'readOnly': readOnly
                                  }).then((_) => refreshParentState()),
                    child: portfolio['type'] == "Deposit" &&
                            portfolio['depositData'] != null
                        ? Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    // width: MediaQuery.of(context).size.width *
                                    //     0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    portfolio['depositData']
                                                            ['bank_name'] ??
                                                        '',
                                                    maxLines: 2,
                                                    style: portfolioBoxName
                                                        .copyWith(
                                                      fontSize: 14.0,
                                                    )),
                                                portfolio['depositData']
                                                            ['display_name'] !=
                                                        null
                                                    ? Text(
                                                        limitChar(
                                                            portfolio[
                                                                    'depositData']
                                                                [
                                                                'display_name'],
                                                            length:
                                                                (weightage > 0
                                                                    ? 25
                                                                    : 35)),
                                                        style: portfolioBoxName
                                                            .copyWith(
                                                          fontSize: 14.0,
                                                        ))
                                                    : emptyWidget,
                                              ]),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['name'] !=
                                                            null
                                                        ? portfolio['name']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        child: Container(
                                          // color: Colors.orangeAccent,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                      // width:
                                                      //     MediaQuery.of(context)
                                                      //             .size
                                                      //             .width *
                                                      //         0.10,
                                                      child: Text(
                                                        "Current Value",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                      // width:
                                                      //     MediaQuery.of(context)
                                                      //             .size
                                                      //             .width *
                                                      //         0.10,
                                                      child: Text(
                                                          portfolio['value'] ??
                                                              '',
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                        "Annual Interest Rate",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                          '$depositRate%($depositFrequency)',
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                        "Maturity Value",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                          portfolio['depositData']
                                                                  [
                                                                  'maturity_amount'] ??
                                                              "",
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                        "Maturity On",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(maturityDate,
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                      GestureDetector(
                                        behavior: HitTestBehavior
                                            .opaque, /////////////////////////////
                                        onTap: () {
                                          // confirmDeleteForDeposit(context, model,
                                          //     portfolio, refreshParentState);
                                          callBackForDelete(
                                              ricIndex: index,
                                              selectedSuggestion: {
                                                "ric": portfolio['ric'],
                                                "name": model.userPortfoliosData[
                                                            portfolioMasterID]
                                                        ['portfolios'][
                                                    portfolio[
                                                        'type']][index]['name'],
                                                'zone': portfolio['zone'],
                                                'type': portfolio['type'],
                                              });
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: colorBlue,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    // width: MediaQuery.of(context).size.width *
                                    //     0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(portfolio['ticker'],
                                              style:
                                                  transactionBoxLabel.copyWith(
                                                fontSize: 10.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                              portfolio['name'] != null
                                                  ? portfolio['name']
                                                  : "",
                                              maxLines: 2,
                                              style: portfolioBoxName.copyWith(
                                                fontSize: 14.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                              Contants.close +
                                                  Contants.clone +
                                                  " " +
                                                  portfolio['latestDatePrice']
                                                      .toString(),
                                              style: lastCloseText),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['type'] !=
                                                            null
                                                        ? portfolio['type']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: [
                                                    //         Image.asset(
                                                    // weightage > 0
                                                    // 	? "assets/icon/icon_units.png"
                                                    // 	: "assets/icon/icon_clock.png",
                                                    // width: getScaledValue(14),color: Colors.white,),
                                                    Container(
                                                      // color: Colors.orangeAccent,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.07,
                                                      child: Text(
                                                          weightage > 0
                                                              ? (portfolio['type'] !=
                                                                          null &&
                                                                      portfolio['type']
                                                                              .toLowerCase() ==
                                                                          "commodity"
                                                                  ? " grams"
                                                                  : " units")
                                                              : "", //1 Jan - 28 Aug, 2020
                                                          style:
                                                              portfolioBoxHolding
                                                                  .copyWith(
                                                            fontSize: 12.0,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                        weightage > 0
                                                            ? "assets/icon/icon_units.png"
                                                            : "assets/icon/icon_clock.png",
                                                        width:
                                                            getScaledValue(14)),
                                                    Container(
                                                      // color: Colors.orangeAccent,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.07,
                                                      child: Text(
                                                          weightage > 0
                                                              ? portfolio[
                                                                      'weightage']
                                                                  .toString()
                                                              : holdingPeriod(
                                                                  portfolio),
                                                          //1 Jan - 28 Aug, 2020
                                                          style:
                                                              portfolioBoxHolding
                                                                  .copyWith(
                                                            fontSize: 12.0,
                                                          )),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                  // color: Colors.pink,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  // width: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width *
                                                  //     0.10,
                                                  child: Text(
                                                    "Current Value",
                                                    maxLines: 2,
                                                    style: portfolioBoxHolding
                                                        .copyWith(
                                                      fontSize: 12.0,
                                                    ),
                                                  )),
                                              SizedBox(
                                                  width: getScaledValue(3)),
                                              Container(
                                                  // color: Colors.green,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  // width: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width *
                                                  //     0.10,
                                                  child: Text(
                                                      portfolio['value'],
                                                      maxLines: 2,
                                                      style: appBodyH3.copyWith(
                                                        fontSize: 16.0,
                                                      ))),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        child: Container(
                                          // color: Colors.orangeAccent,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(
                                                          Contants
                                                              .oneDayReturns,
                                                          style:
                                                              keyStatsBodyText2
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          )),
                                                      SizedBox(
                                                          width: getScaledValue(
                                                              5)),
                                                      (portfolio['change_sign'] ==
                                                                  "up" ||
                                                              portfolio[
                                                                      'change_sign'] ==
                                                                  "down"
                                                          ? Text(
                                                              portfolio['change']
                                                                      .toString() +
                                                                  "%",
                                                              style: bodyText12.copyWith(
                                                                  fontSize: 12,
                                                                  color: portfolio[
                                                                              'change_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                          : emptyWidget),
                                                    ],
                                                  ),
                                                  Text(
                                                      portfolio['changeAmount']
                                                          .toString(),
                                                      style: bodyText12.copyWith(
                                                          fontSize: 12,
                                                          color: portfolio[
                                                                      'change_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(Contants.monthToDate,
                                                          style:
                                                              keyStatsBodyText2
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          )),
                                                      SizedBox(
                                                          width: getScaledValue(
                                                              5)),
                                                      (portfolio['changeMonth_sign'] ==
                                                                  "up" ||
                                                              portfolio[
                                                                      'changeMonth_sign'] ==
                                                                  "down"
                                                          ? Text(
                                                              portfolio['changeMonth']
                                                                      .toString() +
                                                                  "%",
                                                              style: bodyText12.copyWith(
                                                                  fontSize: 12,
                                                                  color: portfolio[
                                                                              'changeMonth_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                          : emptyWidget),
                                                    ],
                                                  ),
                                                  Text(
                                                      portfolio[
                                                              'changeAmountMonth']
                                                          .toString(),
                                                      style: bodyText12.copyWith(
                                                          fontSize: 12,
                                                          color: portfolio[
                                                                      'changeMonth_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(Contants.yearToDate,
                                                          style:
                                                              keyStatsBodyText2
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          )),
                                                      SizedBox(
                                                          width: getScaledValue(
                                                              5)),
                                                      (portfolio['changeYear_sign'] ==
                                                                  "up" ||
                                                              portfolio[
                                                                      'changeYear_sign'] ==
                                                                  "down"
                                                          ? Text(
                                                              portfolio['changeYear']
                                                                      .toString() +
                                                                  "%",
                                                              style: bodyText12.copyWith(
                                                                  fontSize: 12,
                                                                  color: portfolio[
                                                                              'changeYear_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                          : emptyWidget),
                                                    ],
                                                  ),
                                                  Text(
                                                      portfolio[
                                                              'changeAmountYear']
                                                          .toString(),
                                                      style: bodyText12.copyWith(
                                                          fontSize: 12,
                                                          color: portfolio[
                                                                      'changeYear_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          ///////////////////////
                                          callBackForDelete(
                                              ricIndex: index,
                                              selectedSuggestion: {
                                                "ric": portfolio['ric'],
                                                "name": model.userPortfoliosData[
                                                            portfolioMasterID]
                                                        ['portfolios'][
                                                    portfolio[
                                                        'type']][index]['name'],
                                                'zone': portfolio['zone'],
                                                'type': portfolio['type'],
                                              });
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: colorBlue,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          ),
                  ));
      }
      return Container();
    },
  );
}

Widget portfolioBoxForLarge(
    String portfolioMasterID,
    MainModel model,
    Function callBackForDelete,
    String type,
    BuildContext context,
    int index,
    Map portfolio,
    {Function refreshParentState,
    bool readOnly = false}) {
  dynamic weightage;
  if (portfolio['weightage'] is String) {
    weightage = double.parse(portfolio['weightage']);
  } else {
    weightage = portfolio['weightage'];
  }
  if (PlatformCheck.isSmallScreen(context)) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => portfolio['type'] == "Deposit"
            ? Navigator.pushReplacementNamed(
                context,
                '/add_instrument',
                arguments: {
                  'portfolioMasterID': portfolio['portfolio_master_id'],
                  "viewDeposit": true,
                  "portfolioDepositID": portfolio['portfolio_id']
                },
              ).then((_) => refreshParentState())
            : portfolio['portfolio_master_id'] == null ||
                    portfolio['type'] == null ||
                    portfolio['ric'] == null ||
                    portfolio['zone'] == null ||
                    index == null
                ? {}
                : Navigator.pushNamed(
                    context,
                    '/edit_ric_large/' +
                        portfolio['portfolio_master_id'] +
                        "/" +
                        portfolio['type'] +
                        "/" +
                        portfolio['ric'] +
                        "/" +
                        portfolio['zone'] +
                        "/" +
                        index.toString(),
                    arguments: {
                        'refreshParentState': refreshParentState,
                        'readOnly': readOnly
                      }).then((_) => refreshParentState()),
        child: Container(
            margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Color(0xffe8e8e8), width: getScaledValue(1)),
                borderRadius: BorderRadius.circular(4)),
            padding: EdgeInsets.all(getScaledValue(16)),
            //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),
            child: Column(children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(portfolio['ticker'],
                                style: transactionBoxLabel),
                            Text(
                                portfolio['name'] != null
                                    ? limitChar(portfolio['name'],
                                        length: (weightage > 0 ? 25 : 35))
                                    : "",
                                style: portfolioBoxName),
                          ]),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widgetBubble(
                            title: portfolio['type'] != null
                                ? portfolio['type'].toUpperCase()
                                : "",
                            leftMargin: 0,
                            textColor: Color(0xffa7a7a7)),
                        SizedBox(height: getScaledValue(4)),
                        widgetZoneFlag(portfolio['zone']),
                      ],
                    ),
                  ]),
              SizedBox(height: getScaledValue(10)),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(portfolio['value'], style: appBodyH3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                                weightage > 0
                                    ? "assets/icon/icon_units.png"
                                    : "assets/icon/icon_clock.png",
                                width: getScaledValue(14)),
                            SizedBox(width: getScaledValue(3)),
                            Text(
                                weightage > 0
                                    ? portfolio['weightage'].toString() +
                                        (portfolio['type'] != null &&
                                                portfolio['type']
                                                        .toLowerCase() ==
                                                    "commodity"
                                            ? " grams"
                                            : " units")
                                    : holdingPeriod(portfolio),
                                //1 Jan - 28 Aug, 2020
                                style: portfolioBoxHolding),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(Contants.oneDayReturns,
                              style: keyStatsBodyText2),
                          SizedBox(width: getScaledValue(5)),
                          (portfolio['change_sign'] == "up" ||
                                  portfolio['change_sign'] == "down"
                              ? Text(portfolio['change'].toString() + "%",
                                  style: bodyText12.copyWith(
                                      color: portfolio['change_sign'] == "up"
                                          ? colorGreenReturn
                                          : colorRedReturn))
                              : emptyWidget),
                        ],
                      ),
                      Text(portfolio['changeAmount'].toString(),
                          style: bodyText12.copyWith(
                              color: portfolio['change_sign'] == "up"
                                  ? colorGreenReturn
                                  : colorRedReturn)),
                    ],
                  ),
                ],
              ),
              Divider(
                height: getScaledValue(18),
                color: AppColor.veryLightPink,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(Contants.monthToDate,
                                style: keyStatsBodyText2),
                            SizedBox(width: getScaledValue(5)),
                            (portfolio['changeMonth_sign'] == "up" ||
                                    portfolio['changeMonth_sign'] == "down"
                                ? Text(
                                    portfolio['changeMonth'].toString() + "%",
                                    style: bodyText12.copyWith(
                                        color: portfolio['changeMonth_sign'] ==
                                                "up"
                                            ? colorGreenReturn
                                            : colorRedReturn))
                                : emptyWidget),
                          ],
                        ),
                        Text(portfolio['changeAmountMonth'].toString(),
                            style: bodyText12.copyWith(
                                color: portfolio['changeMonth_sign'] == "up"
                                    ? colorGreenReturn
                                    : colorRedReturn)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(Contants.yearToDate, style: keyStatsBodyText2),
                          SizedBox(width: getScaledValue(5)),
                          (portfolio['changeYear_sign'] == "up" ||
                                  portfolio['changeYear_sign'] == "down"
                              ? Text(portfolio['changeYear'].toString() + "%",
                                  style: bodyText12.copyWith(
                                      color:
                                          portfolio['changeYear_sign'] == "up"
                                              ? colorGreenReturn
                                              : colorRedReturn))
                              : emptyWidget),
                        ],
                      ),
                      Text(portfolio['changeAmountYear'].toString(),
                          style: bodyText12.copyWith(
                              color: portfolio['changeYear_sign'] == "up"
                                  ? colorGreenReturn
                                  : colorRedReturn)),
                    ],
                  ),
                ],
              ),
            ])));
  } else if (PlatformCheck.isMediumScreen(context) ||
      PlatformCheck.isLargeScreen(context)) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: type == "past"
                ? portfolio['type'] == "Deposit" &&
                        portfolio['depositData'] != null
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => portfolio['type'] == "Deposit"
                            ? Navigator.pushReplacementNamed(
                                context,
                                '/add_instrument',
                                arguments: {
                                  'portfolioMasterID':
                                      portfolio['portfolio_master_id'],
                                  "viewDeposit": true,
                                  "portfolioDepositID":
                                      portfolio['portfolio_id']
                                },
                              ).then((_) => refreshParentState())
                            : portfolio['portfolio_master_id'] == null ||
                                    portfolio['type'] == null ||
                                    portfolio['ric'] == null ||
                                    portfolio['zone'] == null ||
                                    index == null
                                ? {}
                                : Navigator.pushNamed(
                                    context,
                                    '/edit_ric_large/' +
                                        portfolio['portfolio_master_id'] +
                                        "/" +
                                        portfolio['type'] +
                                        "/" +
                                        portfolio['ric'] +
                                        "/" +
                                        portfolio['zone'] +
                                        "/" +
                                        index.toString(),
                                    arguments: {
                                        'refreshParentState':
                                            refreshParentState,
                                        'readOnly': readOnly
                                      }).then((_) => refreshParentState()),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  // color: Colors.orangeAccent,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  portfolio['depositData']
                                                          ['bank_name'] ??
                                                      '',
                                                  maxLines: 2,
                                                  style:
                                                      portfolioBoxName.copyWith(
                                                    fontSize: 14.0,
                                                  )),
                                              portfolio['depositData']
                                                          ['display_name'] !=
                                                      null
                                                  ? Text(
                                                      limitChar(
                                                          portfolio[
                                                                  'depositData']
                                                              ['display_name'],
                                                          length: (weightage > 0
                                                              ? 25
                                                              : 35)),
                                                      style: portfolioBoxName
                                                          .copyWith(
                                                        fontSize: 14.0,
                                                      ))
                                                  : emptyWidget,
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: widgetBubble(
                                                  title:
                                                      portfolio['name'] != null
                                                          ? portfolio['name']
                                                              .toUpperCase()
                                                          : "",
                                                  leftMargin: 0,
                                                  textColor: Color(0xffa7a7a7)),
                                            ),
                                            widgetZoneFlag(portfolio['zone']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            // color: Colors.pink,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                          "Current Value",
                                          maxLines: 2,
                                          style: portfolioBoxHolding.copyWith(
                                            fontSize: 12.0,
                                          ),
                                        )),
                                        SizedBox(width: getScaledValue(3)),
                                        Container(
                                            // color: Colors.green,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child:
                                                Text(portfolio['value'] ?? '',
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            // color: Colors.pink,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                          "Annual Interest Rate",
                                          maxLines: 2,
                                          style: portfolioBoxHolding.copyWith(
                                            fontSize: 12.0,
                                          ),
                                        )),
                                        SizedBox(width: getScaledValue(3)),
                                        Container(
                                            // color: Colors.green,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                                portfolio['depositData']
                                                        ['rate'] +
                                                    "%" +
                                                    "(Frequency)",
                                                maxLines: 2,
                                                style: appBodyH3.copyWith(
                                                  fontSize: 12.0,
                                                ))),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            // color: Colors.pink,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                          "Maturity Value",
                                          maxLines: 2,
                                          style: portfolioBoxHolding.copyWith(
                                            fontSize: 12.0,
                                          ),
                                        )),
                                        SizedBox(width: getScaledValue(3)),
                                        Container(
                                            // color: Colors.green,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                                portfolio['depositData']
                                                        ['maturity_amount'] ??
                                                    "",
                                                maxLines: 2,
                                                style: appBodyH3.copyWith(
                                                  fontSize: 12.0,
                                                ))),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            // color: Colors.pink,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                          "Maturity On",
                                          maxLines: 2,
                                          style: portfolioBoxHolding.copyWith(
                                            fontSize: 12.0,
                                          ),
                                        )),
                                        SizedBox(width: getScaledValue(3)),
                                        Container(
                                            // color: Colors.green,
                                            // width:
                                            //     MediaQuery.of(context)
                                            //             .size
                                            //             .width *
                                            //         0.10,
                                            child: Text(
                                                portfolio['depositData']
                                                    ['maturity_date'],
                                                maxLines: 2,
                                                style: appBodyH3.copyWith(
                                                  fontSize: 12.0,
                                                ))),
                                      ],
                                    ),
                                  ],
                                )),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => portfolio['type'] == "Deposit"
                                      ? Navigator.pushReplacementNamed(
                                          context,
                                          '/add_instrument',
                                          arguments: {
                                            'portfolioMasterID': portfolio[
                                                'portfolio_master_id'],
                                            "viewDeposit": true,
                                            "portfolioDepositID":
                                                portfolio['portfolio_id']
                                          },
                                        ).then((_) => refreshParentState())
                                      : portfolio['portfolio_master_id'] ==
                                                  null ||
                                              portfolio['type'] == null ||
                                              portfolio['ric'] == null ||
                                              portfolio['zone'] == null ||
                                              index == null
                                          ? {}
                                          : Navigator.pushNamed(
                                              context,
                                              '/edit_ric_large/' +
                                                  portfolio[
                                                      'portfolio_master_id'] +
                                                  "/" +
                                                  portfolio['type'] +
                                                  "/" +
                                                  portfolio['ric'] +
                                                  "/" +
                                                  portfolio['zone'] +
                                                  "/" +
                                                  index.toString(),
                                              arguments: {
                                                  'refreshParentState':
                                                      refreshParentState,
                                                  'readOnly': readOnly
                                                }).then(
                                              (_) => refreshParentState()),
                                  child: Text(
                                    "View Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: colorBlue,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: Color(0xffeaeaea),
                              ),
                            ),
                          ],
                        ))
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // color: Colors.orangeAccent,
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(portfolio['ticker'],
                                          style: transactionBoxLabel.copyWith(
                                            fontSize: 10.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                          portfolio['name'] != null
                                              ? portfolio['name']
                                              : "",
                                          maxLines: 2,
                                          style: portfolioBoxName.copyWith(
                                            fontSize: 14.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: widgetBubbleForWeb(
                                                title: portfolio['type'] != null
                                                    ? portfolio['type']
                                                        .toUpperCase()
                                                    : "",
                                                leftMargin: 0,
                                                textColor: Color(0xffa7a7a7)),
                                          ),
                                          widgetZoneFlagForWeb(
                                              portfolio['zone']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              //         Image.asset(
                                              // weightage > 0
                                              // 	? "assets/icon/icon_units.png"
                                              // 	: "assets/icon/icon_clock.png",
                                              // width: getScaledValue(14),color: Colors.white,),
                                              Container(
                                                // color: Colors.orangeAccent,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.07,
                                                child: Text(
                                                    weightage > 0
                                                        ? (portfolio['type'] !=
                                                                    null &&
                                                                portfolio['type']
                                                                        .toLowerCase() ==
                                                                    "commodity"
                                                            ? " grams"
                                                            : " units")
                                                        : "", //1 Jan - 28 Aug, 2020
                                                    style: portfolioBoxHolding
                                                        .copyWith(
                                                      fontSize: 12.0,
                                                    )),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: getScaledValue(3)),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5.0),
                                                child: Image.asset(
                                                    weightage > 0
                                                        ? "assets/icon/icon_units.png"
                                                        : "assets/icon/icon_clock.png",
                                                    width: getScaledValue(14)),
                                              ),
                                              Container(
                                                // color: Colors.orangeAccent,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.15,
                                                child: Text(
                                                    weightage > 0
                                                        ? portfolio['weightage']
                                                            .toString()
                                                        : holdingPeriod(
                                                            portfolio),
                                                    //1 Jan - 28 Aug, 2020
                                                    style: portfolioBoxHolding
                                                        .copyWith(
                                                      fontSize: 12.0,
                                                    )),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => portfolio['type'] == "Deposit"
                                    ? Navigator.pushReplacementNamed(
                                        context,
                                        '/add_instrument',
                                        arguments: {
                                          'portfolioMasterID':
                                              portfolio['portfolio_master_id'],
                                          "viewDeposit": true,
                                          "portfolioDepositID":
                                              portfolio['portfolio_id']
                                        },
                                      ).then((_) => refreshParentState())
                                    : portfolio['portfolio_master_id'] ==
                                                null ||
                                            portfolio['type'] == null ||
                                            portfolio['ric'] == null ||
                                            portfolio['zone'] == null ||
                                            index == null
                                        ? {}
                                        : Navigator.pushNamed(
                                                context,
                                                '/edit_ric_large/' +
                                                    portfolio[
                                                        'portfolio_master_id'] +
                                                    "/" +
                                                    portfolio['type'] +
                                                    "/" +
                                                    portfolio['ric'] +
                                                    "/" +
                                                    portfolio['zone'] +
                                                    "/" +
                                                    index.toString(),
                                                arguments: {
                                                'refreshParentState':
                                                    refreshParentState,
                                                'readOnly': readOnly
                                              })
                                            .then((_) => refreshParentState()),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorBlue,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width,
                              color: Color(0xffeaeaea),
                            ),
                          ),
                        ],
                      )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => portfolio['type'] == "Deposit"
                        ? Navigator.pushReplacementNamed(
                            context,
                            '/add_instrument',
                            arguments: {
                              'portfolioMasterID':
                                  portfolio['portfolio_master_id'],
                              "viewDeposit": true,
                              "portfolioDepositID": portfolio['portfolio_id']
                            },
                          ).then((_) => refreshParentState())
                        : portfolio['portfolio_master_id'] == null ||
                                portfolio['type'] == null ||
                                portfolio['ric'] == null ||
                                portfolio['zone'] == null ||
                                index == null
                            ? {}
                            : Navigator.pushNamed(
                                context,
                                '/edit_ric_large/' +
                                    portfolio['portfolio_master_id'] +
                                    "/" +
                                    portfolio['type'] +
                                    "/" +
                                    portfolio['ric'] +
                                    "/" +
                                    portfolio['zone'] +
                                    "/" +
                                    index.toString(),
                                arguments: {
                                    'refreshParentState': refreshParentState,
                                    'readOnly': readOnly
                                  }).then((_) => refreshParentState()),
                    child: portfolio['type'] == "Deposit" &&
                            portfolio['depositData'] != null
                        ? Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    portfolio['depositData']
                                                            ['bank_name'] ??
                                                        '',
                                                    maxLines: 2,
                                                    style: portfolioBoxName
                                                        .copyWith(
                                                      fontSize: 14.0,
                                                    )),
                                                portfolio['depositData']
                                                            ['display_name'] !=
                                                        null
                                                    ? Text(
                                                        limitChar(
                                                            portfolio[
                                                                    'depositData']
                                                                [
                                                                'display_name'],
                                                            length:
                                                                (weightage > 0
                                                                    ? 25
                                                                    : 35)),
                                                        style: portfolioBoxName
                                                            .copyWith(
                                                          fontSize: 14.0,
                                                        ))
                                                    : emptyWidget,
                                              ]),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['name'] !=
                                                            null
                                                        ? portfolio['name']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Current Value",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    portfolio['value'] ?? '',
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Annual Interest Rate",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    portfolio['depositData']
                                                            ['rate'] +
                                                        "%" +
                                                        "(Frequency)",
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Maturity Value",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    portfolio['depositData'][
                                                            'maturity_amount'] ??
                                                        "",
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                              "Maturity On",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width:
                                                //     MediaQuery.of(context)
                                                //             .size
                                                //             .width *
                                                //         0.10,
                                                child: Text(
                                                    portfolio['depositData']
                                                        ['maturity_date'],
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 12.0,
                                                    ))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => portfolio['type'] == "Deposit"
                                        ? Navigator.pushReplacementNamed(
                                            context,
                                            '/add_instrument',
                                            arguments: {
                                              'portfolioMasterID': portfolio[
                                                  'portfolio_master_id'],
                                              "viewDeposit": true,
                                              "portfolioDepositID":
                                                  portfolio['portfolio_id']
                                            },
                                          ).then((_) => refreshParentState())
                                        : portfolio['portfolio_master_id'] ==
                                                    null ||
                                                portfolio['type'] == null ||
                                                portfolio['ric'] == null ||
                                                portfolio['zone'] == null ||
                                                index == null
                                            ? {}
                                            : Navigator.pushNamed(
                                                context,
                                                '/edit_ric_large/' +
                                                    portfolio[
                                                        'portfolio_master_id'] +
                                                    "/" +
                                                    portfolio['type'] +
                                                    "/" +
                                                    portfolio['ric'] +
                                                    "/" +
                                                    portfolio['zone'] +
                                                    "/" +
                                                    index.toString(),
                                                arguments: {
                                                    'refreshParentState':
                                                        refreshParentState,
                                                    'readOnly': readOnly
                                                  }).then(
                                                (_) => refreshParentState()),
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorBlue,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(portfolio['ticker'],
                                              style:
                                                  transactionBoxLabel.copyWith(
                                                fontSize: 10.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                              portfolio['name'] != null
                                                  ? portfolio['name']
                                                  : "",
                                              maxLines: 2,
                                              style: portfolioBoxName.copyWith(
                                                fontSize: 14.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['type'] !=
                                                            null
                                                        ? portfolio['type']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                //         Image.asset(
                                                // weightage > 0
                                                // 	? "assets/icon/icon_units.png"
                                                // 	: "assets/icon/icon_clock.png",
                                                // width: getScaledValue(14),color: Colors.white,),
                                                Container(
                                                  // color: Colors.orangeAccent,
                                                  // width:
                                                  //     MediaQuery.of(context)
                                                  //             .size
                                                  //             .width *
                                                  //         0.07,
                                                  child: Text(
                                                      weightage > 0
                                                          ? (portfolio['type'] !=
                                                                      null &&
                                                                  portfolio['type']
                                                                          .toLowerCase() ==
                                                                      "commodity"
                                                              ? " grams"
                                                              : " units")
                                                          : "", //1 Jan - 28 Aug, 2020
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      )),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: getScaledValue(3)),
                                            Row(
                                              children: [
                                                Image.asset(
                                                    weightage > 0
                                                        ? "assets/icon/icon_units.png"
                                                        : "assets/icon/icon_clock.png",
                                                    width: getScaledValue(14)),
                                                Container(
                                                  // color: Colors.orangeAccent,
                                                  // width:
                                                  //     MediaQuery.of(context)
                                                  //             .size
                                                  //             .width *
                                                  //         0.07,
                                                  child: Text(
                                                      weightage > 0
                                                          ? portfolio[
                                                                  'weightage']
                                                              .toString()
                                                          : holdingPeriod(
                                                              portfolio),
                                                      //1 Jan - 28 Aug, 2020
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                // color: Colors.pink,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.10,
                                                child: Text(
                                              "Current Value",
                                              maxLines: 2,
                                              style:
                                                  portfolioBoxHolding.copyWith(
                                                fontSize: 12.0,
                                              ),
                                            )),
                                            SizedBox(width: getScaledValue(3)),
                                            Container(
                                                // color: Colors.green,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width *
                                                //     0.10,
                                                child: Text(portfolio['value'],
                                                    maxLines: 2,
                                                    style: appBodyH3.copyWith(
                                                      fontSize: 16.0,
                                                    ))),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(Contants.oneDayReturns,
                                                    style: keyStatsBodyText2
                                                        .copyWith(
                                                      fontSize: 10.0,
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(5)),
                                                (portfolio['change_sign'] ==
                                                            "up" ||
                                                        portfolio[
                                                                'change_sign'] ==
                                                            "down"
                                                    ? Text(
                                                        portfolio['change']
                                                                .toString() +
                                                            "%",
                                                        style: bodyText12.copyWith(
                                                            fontSize: 12,
                                                            color: portfolio[
                                                                        'change_sign'] ==
                                                                    "up"
                                                                ? colorGreenReturn
                                                                : colorRedReturn))
                                                    : emptyWidget),
                                              ],
                                            ),
                                            Text(
                                                portfolio['changeAmount']
                                                    .toString(),
                                                style: bodyText12.copyWith(
                                                    fontSize: 12,
                                                    color: portfolio[
                                                                'change_sign'] ==
                                                            "up"
                                                        ? colorGreenReturn
                                                        : colorRedReturn)),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(Contants.monthToDate,
                                                    style: keyStatsBodyText2
                                                        .copyWith(
                                                      fontSize: 10.0,
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(5)),
                                                (portfolio['changeMonth_sign'] ==
                                                            "up" ||
                                                        portfolio[
                                                                'changeMonth_sign'] ==
                                                            "down"
                                                    ? Text(
                                                        portfolio['changeMonth']
                                                                .toString() +
                                                            "%",
                                                        style: bodyText12.copyWith(
                                                            fontSize: 12,
                                                            color: portfolio[
                                                                        'changeMonth_sign'] ==
                                                                    "up"
                                                                ? colorGreenReturn
                                                                : colorRedReturn))
                                                    : emptyWidget),
                                              ],
                                            ),
                                            Text(
                                                portfolio['changeAmountMonth']
                                                    .toString(),
                                                style: bodyText12.copyWith(
                                                    fontSize: 12,
                                                    color: portfolio[
                                                                'changeMonth_sign'] ==
                                                            "up"
                                                        ? colorGreenReturn
                                                        : colorRedReturn)),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(Contants.yearToDate,
                                                    style: keyStatsBodyText2
                                                        .copyWith(
                                                      fontSize: 10.0,
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(5)),
                                                (portfolio['changeYear_sign'] ==
                                                            "up" ||
                                                        portfolio[
                                                                'changeYear_sign'] ==
                                                            "down"
                                                    ? Text(
                                                        portfolio['changeYear']
                                                                .toString() +
                                                            "%",
                                                        style: bodyText12.copyWith(
                                                            fontSize: 12,
                                                            color: portfolio[
                                                                        'changeYear_sign'] ==
                                                                    "up"
                                                                ? colorGreenReturn
                                                                : colorRedReturn))
                                                    : emptyWidget),
                                              ],
                                            ),
                                            Text(
                                                portfolio['changeAmountYear']
                                                    .toString(),
                                                style: bodyText12.copyWith(
                                                    fontSize: 12,
                                                    color: portfolio[
                                                                'changeYear_sign'] ==
                                                            "up"
                                                        ? colorGreenReturn
                                                        : colorRedReturn)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      callBackForDelete(
                                          ///////////////////////
                                          ricIndex: index,
                                          selectedSuggestion: {
                                            "ric": portfolio['ric'],
                                            "name": model.userPortfoliosData[
                                                            portfolioMasterID]
                                                        ['portfolios']
                                                    [portfolio['type']][index]
                                                ['name'],
                                            'zone': portfolio['zone'],
                                            'type': portfolio['type'],
                                          });
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorBlue,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          ),
                  ),
          );
        }
        if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: type == "past"
                ? portfolio['type'] == "Deposit" &&
                        portfolio['depositData'] != null
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => portfolio['type'] == "Deposit"
                            ? Navigator.pushReplacementNamed(
                                context,
                                '/add_instrument',
                                arguments: {
                                  'portfolioMasterID':
                                      portfolio['portfolio_master_id'],
                                  "viewDeposit": true,
                                  "portfolioDepositID":
                                      portfolio['portfolio_id']
                                },
                              ).then((_) => refreshParentState())
                            : portfolio['portfolio_master_id'] == null ||
                                    portfolio['type'] == null ||
                                    portfolio['ric'] == null ||
                                    portfolio['zone'] == null ||
                                    index == null
                                ? {}
                                : Navigator.pushNamed(
                                    context,
                                    '/edit_ric_large/' +
                                        portfolio['portfolio_master_id'] +
                                        "/" +
                                        portfolio['type'] +
                                        "/" +
                                        portfolio['ric'] +
                                        "/" +
                                        portfolio['zone'] +
                                        "/" +
                                        index.toString(),
                                    arguments: {
                                        'refreshParentState':
                                            refreshParentState,
                                        'readOnly': readOnly
                                      }).then((_) => refreshParentState()),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  // color: Colors.orangeAccent,
                                  width:
                                      MediaQuery.of(context).size.width * 0.20,
                                  // width:
                                  //     MediaQuery.of(context).size.width * 0.15,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  portfolio['depositData']
                                                          ['bank_name'] ??
                                                      '',
                                                  maxLines: 2,
                                                  style:
                                                      portfolioBoxName.copyWith(
                                                    fontSize: 14.0,
                                                  )),
                                              portfolio['depositData']
                                                          ['display_name'] !=
                                                      null
                                                  ? Text(
                                                      limitChar(
                                                          portfolio[
                                                                  'depositData']
                                                              ['display_name'],
                                                          length: (weightage > 0
                                                              ? 25
                                                              : 35)),
                                                      style: portfolioBoxName
                                                          .copyWith(
                                                        fontSize: 14.0,
                                                      ))
                                                  : emptyWidget,
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: widgetBubble(
                                                  title:
                                                      portfolio['name'] != null
                                                          ? portfolio['name']
                                                              .toUpperCase()
                                                          : "",
                                                  leftMargin: 0,
                                                  textColor: Color(0xffa7a7a7)),
                                            ),
                                            widgetZoneFlag(portfolio['zone']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      child: Container(
                                        // color: Colors.orangeAccent,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.13,
                                                    // width:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .width *
                                                    //         0.10,
                                                    child: Text(
                                                      "Current Value",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    // width:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .width *
                                                    //         0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.13,
                                                    child: Text(
                                                        portfolio['value'] ??
                                                            '',
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                      "Annual Interest Rate",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                        portfolio['depositData']
                                                                ['rate'] +
                                                            "%" +
                                                            "(Frequency)",
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                      "Maturity Value",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                        portfolio['depositData']
                                                                [
                                                                'maturity_amount'] ??
                                                            "",
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    // color: Colors.pink,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                      "Maturity On",
                                                      maxLines: 2,
                                                      style: portfolioBoxHolding
                                                          .copyWith(
                                                        fontSize: 12.0,
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Container(
                                                    // color: Colors.green,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                    child: Text(
                                                        portfolio['depositData']
                                                            ['maturity_date'],
                                                        maxLines: 2,
                                                        style:
                                                            appBodyH3.copyWith(
                                                          fontSize: 12.0,
                                                        ))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => portfolio['type'] ==
                                              "Deposit"
                                          ? Navigator.pushReplacementNamed(
                                              context,
                                              '/add_instrument',
                                              arguments: {
                                                'portfolioMasterID': portfolio[
                                                    'portfolio_master_id'],
                                                "viewDeposit": true,
                                                "portfolioDepositID":
                                                    portfolio['portfolio_id']
                                              },
                                            ).then((_) => refreshParentState())
                                          : portfolio['portfolio_master_id'] ==
                                                      null ||
                                                  portfolio['type'] == null ||
                                                  portfolio['ric'] == null ||
                                                  portfolio['zone'] == null ||
                                                  index == null
                                              ? {}
                                              : Navigator.pushNamed(
                                                  context,
                                                  '/edit_ric_large/' +
                                                      portfolio[
                                                          'portfolio_master_id'] +
                                                      "/" +
                                                      portfolio['type'] +
                                                      "/" +
                                                      portfolio['ric'] +
                                                      "/" +
                                                      portfolio['zone'] +
                                                      "/" +
                                                      index.toString(),
                                                  arguments: {
                                                      'refreshParentState':
                                                          refreshParentState,
                                                      'readOnly': readOnly
                                                    }).then(
                                                  (_) => refreshParentState()),
                                      child: Text(
                                        "View Details",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: colorBlue,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: Color(0xffeaeaea),
                              ),
                            ),
                          ],
                        ))
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // color: Colors.orangeAccent,
                                width: MediaQuery.of(context).size.width * 0.20,
                                // width: MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(portfolio['ticker'],
                                          style: transactionBoxLabel.copyWith(
                                            fontSize: 10.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                          portfolio['name'] != null
                                              ? portfolio['name']
                                              : "",
                                          maxLines: 2,
                                          style: portfolioBoxName.copyWith(
                                            fontSize: 14.0,
                                          )),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: widgetBubbleForWeb(
                                                title: portfolio['type'] != null
                                                    ? portfolio['type']
                                                        .toUpperCase()
                                                    : "",
                                                leftMargin: 0,
                                                textColor: Color(0xffa7a7a7)),
                                          ),
                                          widgetZoneFlagForWeb(
                                              portfolio['zone']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            //         Image.asset(
                                            // weightage > 0
                                            // 	? "assets/icon/icon_units.png"
                                            // 	: "assets/icon/icon_clock.png",
                                            // width: getScaledValue(14),color: Colors.white,),
                                            Container(
                                              // color: Colors.orangeAccent,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                              child: Text(
                                                  weightage > 0
                                                      ? (portfolio['type'] !=
                                                                  null &&
                                                              portfolio['type']
                                                                      .toLowerCase() ==
                                                                  "commodity"
                                                          ? " grams"
                                                          : " units")
                                                      : "", //1 Jan - 28 Aug, 2020
                                                  style: portfolioBoxHolding
                                                      .copyWith(
                                                    fontSize: 12.0,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: getScaledValue(3)),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Image.asset(
                                                  weightage > 0
                                                      ? "assets/icon/icon_units.png"
                                                      : "assets/icon/icon_clock.png",
                                                  width: getScaledValue(14)),
                                            ),
                                            Container(
                                              // color: Colors.orangeAccent,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15,
                                              child: Text(
                                                  weightage > 0
                                                      ? portfolio['weightage']
                                                          .toString()
                                                      : holdingPeriod(
                                                          portfolio),
                                                  //1 Jan - 28 Aug, 2020
                                                  style: portfolioBoxHolding
                                                      .copyWith(
                                                    fontSize: 12.0,
                                                  )),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => portfolio['type'] == "Deposit"
                                    ? Navigator.pushReplacementNamed(
                                        context,
                                        '/add_instrument',
                                        arguments: {
                                          'portfolioMasterID':
                                              portfolio['portfolio_master_id'],
                                          "viewDeposit": true,
                                          "portfolioDepositID":
                                              portfolio['portfolio_id']
                                        },
                                      ).then((_) => refreshParentState())
                                    : portfolio['portfolio_master_id'] ==
                                                null ||
                                            portfolio['type'] == null ||
                                            portfolio['ric'] == null ||
                                            portfolio['zone'] == null ||
                                            index == null
                                        ? {}
                                        : Navigator.pushNamed(
                                                context,
                                                '/edit_ric_large/' +
                                                    portfolio[
                                                        'portfolio_master_id'] +
                                                    "/" +
                                                    portfolio['type'] +
                                                    "/" +
                                                    portfolio['ric'] +
                                                    "/" +
                                                    portfolio['zone'] +
                                                    "/" +
                                                    index.toString(),
                                                arguments: {
                                                'refreshParentState':
                                                    refreshParentState,
                                                'readOnly': readOnly
                                              })
                                            .then((_) => refreshParentState()),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorBlue,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width,
                              color: Color(0xffeaeaea),
                            ),
                          ),
                        ],
                      )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => portfolio['type'] == "Deposit"
                        ? Navigator.pushReplacementNamed(
                            context,
                            '/add_instrument',
                            arguments: {
                              'portfolioMasterID':
                                  portfolio['portfolio_master_id'],
                              "viewDeposit": true,
                              "portfolioDepositID": portfolio['portfolio_id']
                            },
                          ).then((_) => refreshParentState())
                        : portfolio['portfolio_master_id'] == null ||
                                portfolio['type'] == null ||
                                portfolio['ric'] == null ||
                                portfolio['zone'] == null ||
                                index == null
                            ? {}
                            : Navigator.pushNamed(
                                context,
                                '/edit_ric_large/' +
                                    portfolio['portfolio_master_id'] +
                                    "/" +
                                    portfolio['type'] +
                                    "/" +
                                    portfolio['ric'] +
                                    "/" +
                                    portfolio['zone'] +
                                    "/" +
                                    index.toString(),
                                arguments: {
                                    'refreshParentState': refreshParentState,
                                    'readOnly': readOnly
                                  }).then((_) => refreshParentState()),
                    child: portfolio['type'] == "Deposit" &&
                            portfolio['depositData'] != null
                        ? Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    // width: MediaQuery.of(context).size.width *
                                    //     0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    portfolio['depositData']
                                                            ['bank_name'] ??
                                                        '',
                                                    maxLines: 2,
                                                    style: portfolioBoxName
                                                        .copyWith(
                                                      fontSize: 14.0,
                                                    )),
                                                portfolio['depositData']
                                                            ['display_name'] !=
                                                        null
                                                    ? Text(
                                                        limitChar(
                                                            portfolio[
                                                                    'depositData']
                                                                [
                                                                'display_name'],
                                                            length:
                                                                (weightage > 0
                                                                    ? 25
                                                                    : 35)),
                                                        style: portfolioBoxName
                                                            .copyWith(
                                                          fontSize: 14.0,
                                                        ))
                                                    : emptyWidget,
                                              ]),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['name'] !=
                                                            null
                                                        ? portfolio['name']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        child: Container(
                                          // color: Colors.orangeAccent,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                      // width:
                                                      //     MediaQuery.of(context)
                                                      //             .size
                                                      //             .width *
                                                      //         0.10,
                                                      child: Text(
                                                        "Current Value",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                      // width:
                                                      //     MediaQuery.of(context)
                                                      //             .size
                                                      //             .width *
                                                      //         0.10,
                                                      child: Text(
                                                          portfolio['value'] ??
                                                              '',
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                        "Annual Interest Rate",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                          portfolio['depositData']
                                                                  ['rate'] +
                                                              "%" +
                                                              "(Frequency)",
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                        "Maturity Value",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                          portfolio['depositData']
                                                                  [
                                                                  'maturity_amount'] ??
                                                              "",
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      // color: Colors.pink,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                        "Maturity On",
                                                        maxLines: 2,
                                                        style:
                                                            portfolioBoxHolding
                                                                .copyWith(
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                      width: getScaledValue(3)),
                                                  Container(
                                                      // color: Colors.green,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.10,
                                                      child: Text(
                                                          portfolio[
                                                                  'depositData']
                                                              ['maturity_date'],
                                                          maxLines: 2,
                                                          style: appBodyH3
                                                              .copyWith(
                                                            fontSize: 12.0,
                                                          ))),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => portfolio['type'] ==
                                                "Deposit"
                                            ? Navigator.pushReplacementNamed(
                                                context,
                                                '/add_instrument',
                                                arguments: {
                                                  'portfolioMasterID': portfolio[
                                                      'portfolio_master_id'],
                                                  "viewDeposit": true,
                                                  "portfolioDepositID":
                                                      portfolio['portfolio_id']
                                                },
                                              ).then(
                                                (_) => refreshParentState())
                                            : portfolio['portfolio_master_id'] ==
                                                        null ||
                                                    portfolio['type'] == null ||
                                                    portfolio['ric'] == null ||
                                                    portfolio['zone'] == null ||
                                                    index == null
                                                ? {}
                                                : Navigator.pushNamed(
                                                    context,
                                                    '/edit_ric_large/' +
                                                        portfolio[
                                                            'portfolio_master_id'] +
                                                        "/" +
                                                        portfolio['type'] +
                                                        "/" +
                                                        portfolio['ric'] +
                                                        "/" +
                                                        portfolio['zone'] +
                                                        "/" +
                                                        index.toString(),
                                                    arguments: {
                                                        'refreshParentState':
                                                            refreshParentState,
                                                        'readOnly': readOnly
                                                      }).then((_) =>
                                                    refreshParentState()),
                                        child: Text(
                                          "View Details",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: colorBlue,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    // color: Colors.orangeAccent,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    // width: MediaQuery.of(context).size.width *
                                    //     0.15,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(portfolio['ticker'],
                                              style:
                                                  transactionBoxLabel.copyWith(
                                                fontSize: 10.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                              portfolio['name'] != null
                                                  ? portfolio['name']
                                                  : "",
                                              maxLines: 2,
                                              style: portfolioBoxName.copyWith(
                                                fontSize: 14.0,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: widgetBubble(
                                                    title: portfolio['type'] !=
                                                            null
                                                        ? portfolio['type']
                                                            .toUpperCase()
                                                        : "",
                                                    leftMargin: 0,
                                                    textColor:
                                                        Color(0xffa7a7a7)),
                                              ),
                                              widgetZoneFlag(portfolio['zone']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: [
                                                    //         Image.asset(
                                                    // weightage > 0
                                                    // 	? "assets/icon/icon_units.png"
                                                    // 	: "assets/icon/icon_clock.png",
                                                    // width: getScaledValue(14),color: Colors.white,),
                                                    Container(
                                                      // color: Colors.orangeAccent,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.07,
                                                      child: Text(
                                                          weightage > 0
                                                              ? (portfolio['type'] !=
                                                                          null &&
                                                                      portfolio['type']
                                                                              .toLowerCase() ==
                                                                          "commodity"
                                                                  ? " grams"
                                                                  : " units")
                                                              : "", //1 Jan - 28 Aug, 2020
                                                          style:
                                                              portfolioBoxHolding
                                                                  .copyWith(
                                                            fontSize: 12.0,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: getScaledValue(3)),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                        weightage > 0
                                                            ? "assets/icon/icon_units.png"
                                                            : "assets/icon/icon_clock.png",
                                                        width:
                                                            getScaledValue(14)),
                                                    Container(
                                                      // color: Colors.orangeAccent,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.07,
                                                      child: Text(
                                                          weightage > 0
                                                              ? portfolio[
                                                                      'weightage']
                                                                  .toString()
                                                              : holdingPeriod(
                                                                  portfolio),
                                                          //1 Jan - 28 Aug, 2020
                                                          style:
                                                              portfolioBoxHolding
                                                                  .copyWith(
                                                            fontSize: 12.0,
                                                          )),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                  // color: Colors.pink,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  // width: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width *
                                                  //     0.10,
                                                  child: Text(
                                                    "Current Value",
                                                    maxLines: 2,
                                                    style: portfolioBoxHolding
                                                        .copyWith(
                                                      fontSize: 12.0,
                                                    ),
                                                  )),
                                              SizedBox(
                                                  width: getScaledValue(3)),
                                              Container(
                                                  // color: Colors.green,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  // width: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width *
                                                  //     0.10,
                                                  child: Text(
                                                      portfolio['value'],
                                                      maxLines: 2,
                                                      style: appBodyH3.copyWith(
                                                        fontSize: 16.0,
                                                      ))),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        child: Container(
                                          // color: Colors.orangeAccent,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(
                                                          Contants
                                                              .oneDayReturns,
                                                          style:
                                                              keyStatsBodyText2
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          )),
                                                      SizedBox(
                                                          width: getScaledValue(
                                                              5)),
                                                      (portfolio['change_sign'] ==
                                                                  "up" ||
                                                              portfolio[
                                                                      'change_sign'] ==
                                                                  "down"
                                                          ? Text(
                                                              portfolio['change']
                                                                      .toString() +
                                                                  "%",
                                                              style: bodyText12.copyWith(
                                                                  fontSize: 12,
                                                                  color: portfolio[
                                                                              'change_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                          : emptyWidget),
                                                    ],
                                                  ),
                                                  Text(
                                                      portfolio['changeAmount']
                                                          .toString(),
                                                      style: bodyText12.copyWith(
                                                          fontSize: 12,
                                                          color: portfolio[
                                                                      'change_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(Contants.monthToDate,
                                                          style:
                                                              keyStatsBodyText2
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          )),
                                                      SizedBox(
                                                          width: getScaledValue(
                                                              5)),
                                                      (portfolio['changeMonth_sign'] ==
                                                                  "up" ||
                                                              portfolio[
                                                                      'changeMonth_sign'] ==
                                                                  "down"
                                                          ? Text(
                                                              portfolio['changeMonth']
                                                                      .toString() +
                                                                  "%",
                                                              style: bodyText12.copyWith(
                                                                  fontSize: 12,
                                                                  color: portfolio[
                                                                              'changeMonth_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                          : emptyWidget),
                                                    ],
                                                  ),
                                                  Text(
                                                      portfolio[
                                                              'changeAmountMonth']
                                                          .toString(),
                                                      style: bodyText12.copyWith(
                                                          fontSize: 12,
                                                          color: portfolio[
                                                                      'changeMonth_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(Contants.yearToDate,
                                                          style:
                                                              keyStatsBodyText2
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          )),
                                                      SizedBox(
                                                          width: getScaledValue(
                                                              5)),
                                                      (portfolio['changeYear_sign'] ==
                                                                  "up" ||
                                                              portfolio[
                                                                      'changeYear_sign'] ==
                                                                  "down"
                                                          ? Text(
                                                              portfolio['changeYear']
                                                                      .toString() +
                                                                  "%",
                                                              style: bodyText12.copyWith(
                                                                  fontSize: 12,
                                                                  color: portfolio[
                                                                              'changeYear_sign'] ==
                                                                          "up"
                                                                      ? colorGreenReturn
                                                                      : colorRedReturn))
                                                          : emptyWidget),
                                                    ],
                                                  ),
                                                  Text(
                                                      portfolio[
                                                              'changeAmountYear']
                                                          .toString(),
                                                      style: bodyText12.copyWith(
                                                          fontSize: 12,
                                                          color: portfolio[
                                                                      'changeYear_sign'] ==
                                                                  "up"
                                                              ? colorGreenReturn
                                                              : colorRedReturn)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          callBackForDelete(
                                              ///////////////////////
                                              ricIndex: index,
                                              selectedSuggestion: {
                                                "ric": portfolio['ric'],
                                                "name": model.userPortfoliosData[
                                                            portfolioMasterID]
                                                        ['portfolios'][
                                                    portfolio[
                                                        'type']][index]['name'],
                                                'zone': portfolio['zone'],
                                                'type': portfolio['type'],
                                              });
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: colorBlue,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xffeaeaea),
                                ),
                              ),
                            ],
                          ),
                  ),
          );
        }
        return Container();
      },
    );
  } else {
    return Container();
  }
}
