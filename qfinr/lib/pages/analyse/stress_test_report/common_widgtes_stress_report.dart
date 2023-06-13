import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/stress_test_report/stress_test_report_styles.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

Widget statsRowStressLarge(
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
              Text(title,
                  style: StressTestReportScreenStyle.stressBodyText1.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              description != null
                  ? Text(description,
                      style:
                          StressTestReportScreenStyle.stressBodyText1.copyWith(
                        fontWeight: FontWeight.w700,
                      ))
                  : emptyWidget,
            ],
          ),
        ),
        Text(value1,
            style: StressTestReportScreenStyle.stressBodyText1.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.25,
            )),
        value2 != null ? SizedBox(width: getScaledValue(22)) : emptyWidget,
        value2 != null
            ? Text(value2,
                style: StressTestReportScreenStyle.stressBodyText1.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25,
                ))
            : emptyWidget,
      ],
    ),
  );
}

buildSelectBoxCustomLargeStress(
    {BuildContext context,
    String title,
    String value,
    List<Map<String, String>> options,
    Function onChangeFunction,
    String modelType = "bottomSheet"}) {
  List<Widget> _childrenOption = [];

  options.forEach((option) {
    _childrenOption.add(GestureDetector(
      onTap: () {
        onChangeFunction(option['value']);
        Navigator.pop(context);
      },
      child: Row(
        children: <Widget>[
          Radio(
            groupValue: value,
            value: option['value'],
          ),
          Text(option['title'],
              style: value == option['value']
                  ? selectBoxOptionActive
                  : selectBoxOption),
        ],
      ),
    ));
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: selectBoxTitle,
        ),
        content: Container(
          child: Column(
            children: _childrenOption,
          ),
        ),
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
}

void showPopUp(BuildContext context, {bool isIconAlert}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: _buildCloseButton(context),
        content: Container(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 5,
        ),
      );
    },
  );
}

Align _buildCloseButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerRight,
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Icon(
        Icons.close,
        color: Color(0xffcccccc),
        size: 18.0,
      ),
    ),
  );
}
