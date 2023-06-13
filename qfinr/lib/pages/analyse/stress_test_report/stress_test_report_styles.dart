import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StressTestReportScreenStyle {
  static TextStyle stressBodyText1 = TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.2,
      color: Color(0xff383838));

  static TextStyle stressBodyText2 = TextStyle(
      fontSize: ScreenUtil().setSp(25.0),
      fontWeight: FontWeight.w800,
      fontFamily: 'nunito',
      letterSpacing: 0.4,
      color: Color(0xff034bd9));

  static TextStyle stressBodyText3 = TextStyle(
      fontSize: ScreenUtil().setSp(12.0),
      fontWeight: FontWeight.w700,
      fontFamily: 'roboto',
      letterSpacing: 1,
      color: Color(0xff0b0b0b));

  static TextStyle stressBodyText4 = TextStyle(
      fontSize: ScreenUtil().setSp(12.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.22,
      color: Color(0xff707070));
}
