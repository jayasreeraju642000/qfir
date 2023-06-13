import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/add_deposit.dart';

import '../styles.dart';
import '../widget_common.dart';

final log = getLogger('portfolio_helper');
//
Widget portfolioMasterBox(BuildContext context, Map portfolioData,
    {Function refreshParent}) {
  List zones = portfolioData['portfolio_zone'].split('_');
  log.d(portfolioData['change_sign'].toString());
  return GestureDetector(
    onTap: () => Navigator.pushNamed(
        context, '/portfolio_view/' + portfolioData['id'],
        arguments: {"readOnly": false}).then((_) => refreshParent()),
    child: Container(
      decoration: BoxDecoration(
          border:
              Border.all(color: Color(0xffe8e8e8), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(4)),
      padding: EdgeInsets.all(getScaledValue(16)),
      //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),
      child: Column(
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(limitChar(portfolioData['portfolio_name'], length: 25),
                        style: portfolioBoxName),
                    fundCount(portfolioData)
                  ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
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
                    portfolioData['type'] == '1'
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
                            textColor: Color(0xffbc9f91)),
                  ],
                ),
                SizedBox(height: getScaledValue(4)),
                Row(
                    children: zones
                        .map((item) => Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: widgetZoneFlag(item)))
                        .toList()),
              ],
            ),
          ]),
          SizedBox(height: getScaledValue(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  //width: MediaQuery.of(context).size.width * 0.55,
                  child: Text(portfolioData['value'],
                      style: appBodyH3.copyWith(
                        fontSize: ScreenUtil().setSp(16.0),
                      )),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Contants.oneDayReturns,
                            textAlign: TextAlign.end, style: keyStatsBodyText2),
                        SizedBox(width: getScaledValue(5)),
                        (portfolioData['change_sign'] == "up" ||
                                portfolioData['change_sign'] == "down"
                            ? Text(
                                portfolioData['change'].toString() + "%",
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: bodyText12.copyWith(
                                  color: returnColor(
                                    portfolioData['change'].toString(),
                                  ),
                                ),
                              )
                            : emptyWidget),
                      ],
                    ),
                    Text(
                      portfolioData['change_amount'].toString(),
                      style: bodyText12.copyWith(
                        color: returnColor(
                          portfolioData['change'].toString(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            height: getScaledValue(18),
            color: AppColor.veryLightPink,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(Contants.monthToDate, style: keyStatsBodyText2),
                          SizedBox(width: getScaledValue(5)),
                          (portfolioData['changeMonth_sign'] == "up" ||
                                  portfolioData['changeMonth_sign'] == "down"
                              ? Expanded(
                                  child: Text(
                                    portfolioData['changeMonth'].toString() +
                                        "%",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: bodyText12.copyWith(
                                      color: returnColor(
                                        portfolioData['changeMonth'].toString(),
                                      ),
                                    ),
                                  ),
                                )
                              : emptyWidget),
                        ],
                      ),
                      Text(
                        portfolioData['changeMonth_amount'].toString(),
                        style: bodyText12.copyWith(
                          color: returnColor(
                            portfolioData['changeMonth'].toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Contants.yearToDate,
                            textAlign: TextAlign.end, style: keyStatsBodyText2),
                        SizedBox(width: getScaledValue(5)),
                        (portfolioData['changeYear_sign'] == "up" ||
                                portfolioData['changeYear_sign'] == "down"
                            ? Text(
                                portfolioData['changeYear'].toString() + "%",
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: bodyText12.copyWith(
                                  color: returnColor(
                                    portfolioData['changeYear'].toString(),
                                  ),
                                ),
                              )
                            : emptyWidget),
                      ],
                    ),
                    Text(
                      portfolioData['changeYear_amount'].toString(),
                      style: bodyText12.copyWith(
                        color: returnColor(
                          portfolioData['changeYear'].toString(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // return Row(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: <Widget>[
  //     Expanded(
  //         child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Text(limitChar(portfolioData['portfolio_name'], length: 25),
  //             style: portfolioBoxName),
  //         SizedBox(height: getScaledValue(10)),
  //         Row(
  //           children: <Widget>[
  //             portfolioData['type'] == '1'
  //                 ? widgetBubble(
  //                     title: 'LIVE',
  //                     includeBorder: false,
  //                     leftMargin: 0,
  //                     bgColor: Color(0xffe9f4ff),
  //                     textColor: Color(0xff708bc1))
  //                 : widgetBubble(
  //                     title: 'WATCHLIST',
  //                     includeBorder: false,
  //                     leftMargin: 0,
  //                     bgColor: Color(0xffffece3),
  //                     textColor: Color(0xffbc9f91)),
  //             SizedBox(width: getScaledValue(7)),
  //             Row(
  //                 children: zones
  //                     .map((item) => Padding(
  //                         padding: EdgeInsets.only(right: 4.0),
  //                         child: widgetZoneFlag(item)))
  //                     .toList()),
  //           ],
  //         ),
  //         SizedBox(height: getScaledValue(16)),
  //         fundCount(portfolioData)
  //       ],
  //     )),
  //     SizedBox(width: getScaledValue(20)),
  //     Column(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: <Widget>[
  //         Text(removeDecimal(portfolioData['value']), style: portfolioBoxValue),
  //         Row(
  //           children: <Widget>[
  //             (portfolioData['change_sign'] == "up"
  //                 ? Icon(Icons.trending_up,
  //                     color: Colors.green, size: getScaledValue(16.0))
  //                 : portfolioData['change_sign'] == "down"
  //                     ? Icon(Icons.trending_down,
  //                         color: colorRed, size: getScaledValue(16.0))
  //                     : emptyWidget),
  //             SizedBox(width: getScaledValue(6)),
  //             (portfolioData['change_sign'] == "up" ||
  //                     portfolioData['change_sign'] == "down"
  //                 ? Text(portfolioData['change'].toString() + "%",
  //                     style: portfolioBoxReturn)
  //                 : emptyWidget),
  //           ],
  //         )
  //       ],
  //     )
  //   ],
  // );
}

Color returnColor(String number) {
  try {
    double percentage = double.parse(number);
    if (percentage == 0.0) {
      return colorBlackReturn;
    } else if (percentage > 0.0) {
      return colorGreenReturn;
    } else {
      return colorRedReturn;
    }
  } catch (e) {
    return colorBlackReturn;
  }
}

Widget fundCount(Map portfolioData) {
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
              style: portfolioBoxStockCount,
              children: [
            TextSpan(
                text: " " + (fundType != null ? fundType.toUpperCase() : ""),
                style: portfolioBoxStockCountType)
          ])));
      fundCount += count.toString() + " " + fundType.toUpperCase();
    });
  }

  return Text(limitChar(fundCount, length: 20),
      style: portfolioBoxStockCountType);
}

Widget portfolioListBox(
    BuildContext context, String type, dynamic portfolioList,
    {Function refreshParentState,
    bool readOnly = false,
    String sortType,
    String sortOrder,
    Widget sortWidget}) {
  List<Widget> _widgetList = [];

  List portfolioListData = [];

  if (portfolioList != null) {
    portfolioList.forEach((fundType, portfolios) {
      portfolios.map((item) {
        int index = portfolios.indexOf(item);
        dynamic weightage;
        if (item['weightage'] is String) {
          weightage = double.parse(item['weightage']);
        } else {
          weightage = item['weightage'];
        }
        if (((type == "all" || type == "current") && weightage > 0) ||
            ((type == "all" || type == "past") &&
                weightage <= 0 &&
                item['transactions'] != null)) {
          _widgetList.add(portfolioBox(context, index, item,
              refreshParentState: refreshParentState, readOnly: readOnly));

          portfolioListData.add({"index": index, "item": item});
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
  return ListView(children: [
    sortWidget,
    ...portfolioListData.map((item) => portfolioBox(
        context, item['index'], item['item'],
        refreshParentState: refreshParentState, readOnly: readOnly))
  ]);
}

Widget portfolioBox(BuildContext context, int index, Map portfolio,
    {Function refreshParentState, bool readOnly = false}) {
  dynamic weightage;
  if (portfolio['weightage'] is String) {
    weightage = double.parse(portfolio['weightage']);
  } else {
    weightage = portfolio['weightage'];
  }

  return GestureDetector(
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
        : Navigator.pushNamed(
            context,
            '/edit_ric/' +
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
        border: Border.all(color: Color(0xffe8e8e8), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(getScaledValue(16)),
      //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),

      child: portfolio['type'] == "Deposit" && portfolio['depositData'] != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(portfolio['depositData']['bank_name'] ?? '',
                                  style: body_text2_dashboardPerfomer),
                              portfolio['depositData']['display_name'] != null
                                  ? Text(
                                      limitChar(
                                          portfolio['depositData']
                                              ['display_name'],
                                          length: (weightage > 0 ? 25 : 35)),
                                      style: portfolioBoxName)
                                  : emptyWidget,
                            ]),
                      ),
                      Text("view details", style: body_text3_portfolio),
                    ]),
                SizedBox(height: getScaledValue(10)),
                Row(
                  children: <Widget>[
                    widgetBubble(
                        title: portfolio['name'] != null
                            ? portfolio['name'].toUpperCase()
                            : "",
                        leftMargin: 0,
                        textColor: Color(0xffa7a7a7)),
                    SizedBox(height: getScaledValue(4)),
                    widgetZoneFlag(portfolio['zone']),
                  ],
                ),

                //	Divider(height: getScaledValue(18), color: AppColor.veryLightPink,),
                SizedBox(height: getScaledValue(13)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Value", style: transactionBoxLabel),
                        SizedBox(height: 2),
                        Text(portfolio['depositData']['amount'],
                            style: transactionBoxDetail),
                      ],
                    ),
                    SizedBox(width: getScaledValue(72)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Annual Interest Rate",
                            style: transactionBoxLabel),
                        SizedBox(height: 2),
                        Text(
                            portfolio['depositData']['rate'] +
                                "%" +
                                "(Frequency)",
                            style: transactionBoxDetail),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: getScaledValue(13)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Maturity Value", style: transactionBoxLabel),
                        SizedBox(height: 2),
                        Text(portfolio['depositData']['maturity_amount'] ?? "",
                            style: transactionBoxDetail),
                      ],
                    ),
                    SizedBox(width: getScaledValue(72)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Maturity On", style: transactionBoxLabel),
                        SizedBox(height: 2),
                        Text(portfolio['depositData']['maturity_date'],
                            style: transactionBoxDetail),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: <Widget>[
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
                  ],
                ),
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
                                      : holdingPeriod(
                                          portfolio), //1 Jan - 28 Aug, 2020
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
                                          color:
                                              portfolio['changeMonth_sign'] ==
                                                      "up"
                                                  ? colorGreenReturn
                                                  : colorRedReturn))
                                  : emptyWidget),
                            ],
                          ),
                          Text(
                            portfolio['changeAmountMonth'].toString(),
                            style: bodyText12.copyWith(
                                color: portfolio['changeMonth_sign'] == "up"
                                    ? colorGreenReturn
                                    : colorRedReturn),
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
                            Text(Contants.yearToDate, style: keyStatsBodyText2),
                            SizedBox(width: getScaledValue(5)),
                            (portfolio['changeYear_sign'] == "up" ||
                                    portfolio['changeYear_sign'] == "down"
                                ? Text(
                                    portfolio['changeYear'].toString() + "%",
                                    style: bodyText12.copyWith(
                                        color:
                                            portfolio['changeYear_sign'] == "up"
                                                ? colorGreenReturn
                                                : colorRedReturn),
                                  )
                                : emptyWidget),
                          ],
                        ),
                        Text(
                          portfolio['changeAmountYear'].toString(),
                          style: bodyText12.copyWith(
                              color: portfolio['changeYear_sign'] == "up"
                                  ? colorGreenReturn
                                  : colorRedReturn),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
    ),
  );
}

Widget portfolioListBox2(
    BuildContext context, String type, dynamic portfolioList, MainModel model,
    {Function refreshParentState,
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
              _widgetList.add(portfolioBox(context, index, item,
                  refreshParentState: refreshParentState, readOnly: readOnly));

              portfolioListData.add({"index": index, "item": item});
            }
          } else {
            if (pastholdDate.isBefore(DateTime.now())) {
              _widgetList.add(portfolioBox(context, index, item,
                  refreshParentState: refreshParentState, readOnly: readOnly));

              portfolioListData.add({"index": index, "item": item});
            } else {}
          }
        } else {
          if (((type == "all" || type == "current") && weightage > 0) ||
              ((type == "all" || type == "past") &&
                  weightage <= 0 &&
                  item['transactions'] != null)) {
            _widgetList.add(portfolioBox(context, index, item,
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
  return ListView(children: [
    sortWidget,
    ...portfolioListData.map(
      (item) => portfolioBox2(context, item['index'], item['item'], model,
          refreshParentState: refreshParentState, readOnly: readOnly),
    )
  ]);
}

Widget portfolioBox2(
    BuildContext context, int index, Map portfolio, MainModel model,
    {Function refreshParentState, bool readOnly = false}) {
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

  return GestureDetector(
    onTap: () => portfolio['type'] == "Deposit"
        ? _showAddDepositBottonsheet(
            context,
            model,
            portfolio['portfolio_master_id'],
            portfolio['portfolio_id'],
            refreshParentState)
        // Navigator.pushReplacementNamed(
        //     context,
        //     '/add_instrument',
        //     arguments: {
        //       'portfolioMasterID': portfolio['portfolio_master_id'],
        //       "viewDeposit": true,
        //       "portfolioDepositID": portfolio['portfolio_id']
        //     },
        //   ).then((_) => refreshParentState())
        : portfolio['portfolio_master_id'] == null ||
                portfolio['type'] == null ||
                portfolio['ric'] == null ||
                portfolio['zone'] == null ||
                index == null
            ? {}
            : Navigator.pushNamed(
                context,
                '/edit_ric/' +
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
        border: Border.all(color: Color(0xffe8e8e8), width: getScaledValue(1)),
        borderRadius: BorderRadius.circular(4),
      ),
      // padding: EdgeInsets.all(getScaledValue(16)),
      //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),

      child: portfolio['type'] == "Deposit" && portfolio['depositData'] != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: getScaledValue(12),
                          top: getScaledValue(12),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(portfolio['depositData']['bank_name'] ?? '',
                                  style: body_text2_dashboardPerfomer),
                              portfolio['depositData']['display_name'] != null
                                  ? Text(
                                      limitChar(
                                          portfolio['depositData']
                                              ['display_name'],
                                          length: (weightage > 0 ? 25 : 35)),
                                      style: portfolioBoxName)
                                  : emptyWidget,
                            ]),
                      ),
                    ),
                    PopupMenuButton(
                      padding: EdgeInsets.all(0),
                      onSelected: (value) async {
                        confirmDelete(
                          context,
                          model,
                          portfolio['portfolio_master_id'],
                          portfolio['portfolio_id'],
                          portfolio['depositData']['ric'],
                          refreshParentState,
                        );
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text("Delete"),
                            value: "Delete",
                          )
                        ];
                      },
                    ),
                  ],
                ),
                SizedBox(height: getScaledValue(10)),
                Container(
                  margin: EdgeInsets.only(
                    left: getScaledValue(12),
                    right: getScaledValue(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      widgetBubble(
                          title: portfolio['name'] != null
                              ? portfolio['name'].toUpperCase()
                              : "",
                          leftMargin: 0,
                          textColor: Color(0xffa7a7a7)),
                      SizedBox(width: getScaledValue(8)),
                      widgetZoneFlag(portfolio['zone']),
                    ],
                  ),
                ),

                //	Divider(height: getScaledValue(18), color: AppColor.veryLightPink,),
                SizedBox(height: getScaledValue(13)),

                Container(
                  margin: EdgeInsets.only(
                    left: getScaledValue(12),
                    right: getScaledValue(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Current Value", style: transactionBoxLabel),
                          SizedBox(height: 2),
                          Text(portfolio['value'] ?? '',
                              style: transactionBoxDetail),
                        ],
                      ),
                      SizedBox(width: getScaledValue(72)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Annual Interest Rate",
                              style: transactionBoxLabel),
                          SizedBox(height: 2),
                          Text('$depositRate%($depositFrequency)',
                              style: transactionBoxDetail),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: getScaledValue(13)),
                Container(
                  margin: EdgeInsets.only(
                    left: getScaledValue(12),
                    right: getScaledValue(12),
                    bottom: getScaledValue(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Maturity Value", style: transactionBoxLabel),
                          SizedBox(height: 2),
                          Text(
                              portfolio['depositData']['maturity_amount'] ?? "",
                              style: transactionBoxDetail),
                        ],
                      ),
                      SizedBox(width: getScaledValue(72)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Maturity On", style: transactionBoxLabel),
                          SizedBox(height: 2),
                          Text(maturityDate, style: transactionBoxDetail),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(
              margin: EdgeInsets.all(
                getScaledValue(12),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Text(
                                  Contants.close +
                                      Contants.clone +
                                      " " +
                                      portfolio['latestDatePrice'].toString(),
                                  style: lastCloseText),
                            ]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          widgetBubble(
                              title: portfolio['type'] != null
                                  ? portfolio['type'].toUpperCase()
                                  : "",
                              leftMargin: 0,
                              includeBorder: true,
                              textColor: Color(0xffa7a7a7)),
                          SizedBox(height: getScaledValue(4)),
                          widgetZoneFlag(portfolio['zone']),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: getScaledValue(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
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
                                Expanded(
                                  child: Text(
                                    weightage > 0
                                        ? portfolio['weightage'].toString() +
                                            (portfolio['type'] != null &&
                                                    portfolio['type']
                                                            .toLowerCase() ==
                                                        "commodity"
                                                ? " grams"
                                                : " units")
                                        : holdingPeriod(
                                            portfolio), //1 Jan - 28 Aug, 2020
                                    style: portfolioBoxHolding,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Contants.oneDayReturns,
                                    textAlign: TextAlign.end,
                                    style: keyStatsBodyText2),
                                SizedBox(width: getScaledValue(5)),
                                (portfolio['change_sign'] == "up" ||
                                        portfolio['change_sign'] == "down"
                                    ? Text(
                                        portfolio['change'].toString() + "%",
                                        textAlign: TextAlign.end,
                                        style: bodyText12.copyWith(
                                          color: returnColor(
                                            portfolio['change'].toString(),
                                          ),
                                        ),
                                      )
                                    : emptyWidget),
                              ],
                            ),
                            Text(
                              portfolio['changeAmount'].toString(),
                              textAlign: TextAlign.end,
                              style: bodyText12.copyWith(
                                color: returnColor(
                                  portfolio['change'].toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Divider(
                    height: getScaledValue(18),
                    color: AppColor.veryLightPink,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          // width: MediaQuery.of(context).size.width * 0.55,
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
                                          portfolio['changeMonth_sign'] ==
                                              "down"
                                      ? Text(
                                          portfolio['changeMonth'].toString() +
                                              "%",
                                          style: bodyText12.copyWith(
                                            color: returnColor(
                                              portfolio['changeMonth']
                                                  .toString(),
                                            ),
                                          ),
                                        )
                                      : emptyWidget),
                                ],
                              ),
                              Text(
                                portfolio['changeAmountMonth'].toString(),
                                style: bodyText12.copyWith(
                                  color: returnColor(
                                    portfolio['changeMonth'].toString(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Contants.yearToDate,
                                    textAlign: TextAlign.end,
                                    style: keyStatsBodyText2),
                                SizedBox(width: getScaledValue(5)),
                                (portfolio['changeYear_sign'] == "up" ||
                                        portfolio['changeYear_sign'] == "down"
                                    ? Text(
                                        portfolio['changeYear'].toString() +
                                            "%",
                                        textAlign: TextAlign.end,
                                        style: bodyText12.copyWith(
                                          color: returnColor(
                                            portfolio['changeYear'].toString(),
                                          ),
                                        ),
                                      )
                                    : emptyWidget),
                              ],
                            ),
                            Text(
                              portfolio['changeAmountYear'].toString(),
                              style: bodyText12.copyWith(
                                color: returnColor(
                                  portfolio['changeYear'].toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    ),
  );
}

confirmDelete(context, MainModel model, String portfolioMasterID,
    String portfolioDepositID, String ric, Function callback) async {
  int portfolioCount = 0;

  model.setLoader(true);

  model.userPortfoliosData[portfolioMasterID]['portfolios']
      .forEach((key, portfolios) {
    portfolios.forEach((element) {
      portfolioCount++;
    });
  });

  Map<String, dynamic> responseData;

  if (portfolioCount == 1) {
    responseData = await model.removePortfolioMaster(portfolioMasterID);
  } else {
    // remove the deposit item if exists
    model.userPortfoliosData[portfolioMasterID]['portfolios']['Deposit']
        ?.removeWhere((item) => item["ric"] == ric);

    responseData = await model.updateCustomerPortfolioData(
        portfolios: model.userPortfoliosData[portfolioMasterID]['portfolios'],
        portfolioMasterID: portfolioMasterID,
        portfolioName: model.userPortfoliosData[portfolioMasterID]
            ['portfolio_name']);
  }

  if (responseData['status'] == true) {
    if (portfolioCount == 1) {
      Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');
    }
  }
  callback();
  model.setLoader(false);
}

_showAddDepositBottonsheet(context, MainModel model, String portfolioMasterID,
    String portfolioDepositID, Function callback) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getScaledValue(14)),
          topRight: Radius.circular(getScaledValue(14)),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AddDeposit(model, portfolioMasterID, portfolioDepositID);
        });
      }).then((value) {
    callback();
  });
}

String holdingPeriod(Map portfolio) {
  if (portfolio['transactions'] != null &&
      portfolio['transactions'].length > 1) {
    String fromDate = portfolio['transactions'][0]['date'];
    String toDate = portfolio['transactions'].last['date'];

    return 'Period of Holding: \n' +
        Jiffy(fromDate).yMMMMd +
        " - " +
        Jiffy(toDate).yMMMMd;
  } else {
    return "";
  }
}

Widget fundBox(BuildContext context, Map portfolio,
    {Function refreshParentState,
    Function onTap,
    Widget sortWidget,
    String sortCaption,
    bool readOnly = false}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color(0xffe8e8e8), width: getScaledValue(1)),
          borderRadius: BorderRadius.circular(4)),
      padding: EdgeInsets.all(getScaledValue(16)),
      //margin: EdgeInsets.symmetric(vertical: getScaledValue(10), horizontal: getScaledValue(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(limitChar(portfolio['name'], length: 35),
              style: portfolioBoxName),
          SizedBox(height: getScaledValue(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  widgetBubble(
                      title: portfolio['type'] != null
                          ? portfolio['type'].toUpperCase()
                          : "",
                      leftMargin: 0,
                      textColor: Color(0xffa7a7a7)),
                  SizedBox(width: getScaledValue(7)),
                  widgetZoneFlag(portfolio['zone']),
                ],
              ),
              Row(
                children: [
                  sortCaption != null ? Text(sortCaption) : emptyWidget,
                  portfolio.containsKey('sortby') && portfolio['sortby'] != null
                      ? Text(roundDouble(portfolio['sortby'],
                          decimalLength: sortWidget != null ? 0 : 2))
                      : emptyWidget,
                  sortWidget != null ? sortWidget : emptyWidget
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}
