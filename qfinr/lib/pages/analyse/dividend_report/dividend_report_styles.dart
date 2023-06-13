import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DividendReportScreenStyle {
  static TextStyle dividendBodyText1 = TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.2,
      color: Color(0xff383838));

  static TextStyle dividendBodyText2 = TextStyle(
      fontSize: ScreenUtil().setSp(25.0),
      fontWeight: FontWeight.w800,
      fontFamily: 'nunito',
      letterSpacing: 0.4,
      color: Color(0xff034bd9));

  static TextStyle dividendBodyText3 = TextStyle(
      fontSize: ScreenUtil().setSp(12.0),
      fontWeight: FontWeight.w700,
      fontFamily: 'roboto',
      letterSpacing: 1,
      color: Color(0xff0b0b0b));

  static TextStyle dividendBodyText4 = TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      letterSpacing: 0.2,
      color: Color(0xff8e8e8e));
}
