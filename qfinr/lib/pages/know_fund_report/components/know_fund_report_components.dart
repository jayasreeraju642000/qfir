import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

class KnowFundReportComponents {
  static Widget bulletPointer(String caption,
      {Color color, Color bulletColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: getScaledValue(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: getScaledValue(5)),
            child: Icon(
              Icons.check,
              color: colorBlue,
              size: getScaledValue(10),
            ),
          ),
          SizedBox(width: getScaledValue(10)),
          Expanded(
            child: Text(
              caption,
              style: bodyText1.copyWith(
                color: Color(0xff747474),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
