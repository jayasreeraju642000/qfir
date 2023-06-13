import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/details/chart_data.dart';

import 'package:qfinr/pages/analyse/details/portfolio_analyse_detail_styles.dart';
import 'package:qfinr/pages/analyse/details/sales_date.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:collection/collection.dart';

Widget statsRowLarge(
    {String title,
    String description,
    String value1,
    String value2,
    bool includeBottomBorder = false}) {
  return Container(
    padding: EdgeInsets.symmetric(
        vertical: getScaledValue(20), horizontal: getScaledValue(18)),
    decoration: BoxDecoration(
        border: includeBottomBorder
            ? Border(
                bottom: BorderSide(
                color: Color(0xffdadada),
                width: 1.0,
              ))
            : null),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AnalyseDetailScreenStyle.keyStaticBodyText3),
              description != null
                  ? Text(description,
                      style: AnalyseDetailScreenStyle.keyStaticBodyText5)
                  : emptyWidget,
            ],
          ),
        ),
        Text(value1, style: AnalyseDetailScreenStyle.keyStaticBodyText4),
        value2 != null ? SizedBox(width: getScaledValue(22)) : emptyWidget,
        value2 != null
            ? Text(value2, style: AnalyseDetailScreenStyle.keyStaticBodyText4)
            : emptyWidget,
      ],
    ),
  );
}

bottomAlertBoxLargeAnalyse({
  BuildContext context,
  String title,
  String subtitle,
  String description,
  String title2,
  String subtitle2,
  String description2,
  String title3,
  String subtitle3,
  String description3,
  String title4,
  String subtitle4,
  String description4,
  Widget childContent,
}) {
  Widget content = Container(
      constraints: BoxConstraints(minHeight: getScaledValue(100)),
      margin: EdgeInsets.symmetric(vertical: getScaledValue(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
                  child: Text(title, style: appBodyH3))
              : emptyWidget,
          subtitle != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
                  child: Text(subtitle, style: appBodyH4))
              : emptyWidget,
          title != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          description != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
                  child: Text(description, style: bodyText4))
              : emptyWidget,
          title2 != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          title2 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title2, style: appBodyH3))
              : emptyWidget,
          subtitle2 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle2, style: appBodyH4))
              : emptyWidget,
          title2 != null || description2 != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title2 != null || description2 != null
              ? SizedBox(height: getScaledValue(10))
              : emptyWidget,
          description2 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description2, style: bodyText4))
              : emptyWidget,
          title3 != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          title3 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title3, style: appBodyH3))
              : emptyWidget,
          subtitle3 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle3, style: appBodyH4))
              : emptyWidget,
          title3 != null || description3 != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title3 != null || description3 != null
              ? SizedBox(height: getScaledValue(10))
              : emptyWidget,
          description3 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description3, style: bodyText4))
              : emptyWidget,
          title4 != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          title4 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title4, style: appBodyH3))
              : emptyWidget,
          subtitle4 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle4, style: appBodyH4))
              : emptyWidget,
          title4 != null || description4 != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title4 != null || description4 != null
              ? SizedBox(height: getScaledValue(10))
              : emptyWidget,
          description4 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description4, style: bodyText4))
              : emptyWidget,
          childContent != null ? childContent : emptyWidget
        ],
      ));

  loadPopLargeAnalyse(context: context, content: content);
}

loadPopLargeAnalyse(
    {BuildContext context,
    Widget content,
    bool dismissable = true,
    bool wrap = true,
    Color bgColor}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: null,
        content: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            color: bgColor,
            // width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(15), vertical: getScaledValue(10)),
            margin: const EdgeInsets.only(bottom: 6.0),
            child: content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 5,
        ),
        actions: <Widget>[
          TextButton(
            style: qfButtonStyle0,
            child: Text("Close", style: dialogBoxActionInactive),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  // Align _buildCloseButton(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: GestureDetector(
  //       onTap: () => Navigator.pop(context),
  //       child: Icon(
  //         Icons.close,
  //         color: Color(0xffcccccc),
  //         size: 18.0,
  //       ),
  //     ),
  //   );
  // }
}

List<BoxWhiskerChartData> getSalesTypeList(String type, Map NIFTY50) {
  List<BoxWhiskerChartData> chartListData = [];
  List<dynamic> listData = [];
  List<SalesData> salesList = [];

  NIFTY50.forEach((key, value) {
    if (key == type) {
      listData = value;

      listData.forEach((element) {
        SalesData salesData = SalesData();
        salesData.index = element["index"].toString();
        salesData.type = element["Type"].toString() ?? "";
        salesData.date = element["Date"].toString() ?? "";
        salesData.returns = element["Returns"].toString() ?? "";
        salesData.period = element["Period"].toString() ?? "";

        salesList.add(salesData);
      });
    }
  });

  Map<String, List<SalesData>> map =
      groupBy(salesList, (SalesData obj) => obj.period);
  map.forEach((key, value) {
    BoxWhiskerChartData data = BoxWhiskerChartData();
    data.type = key;
    data.list = value;
    chartListData.add(data);
  });

  return chartListData;
}
