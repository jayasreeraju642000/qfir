import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PortfolioImportExcelStyle {
  static const Color inputBorderColor = Color(0xffe8e8e8);
  static const Color backgroundColor = Color(0xfff5f6fa);
  static const Color textButtonColor = Color(0xffe8efff);
  static const Color dividerColor = Color(0xffe9e9e9);
  static const TextStyle navigationTextLink = TextStyle(
      color: Color(0xff034bd9),
      fontFamily: 'nunito',
      fontSize: 12,
      fontWeight: FontWeight.w600);
  static const TextStyle headlineText = TextStyle(
    color: Color(0xff181818),
    fontFamily: 'nunito',
    fontSize: 25,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );
  static const TextStyle subtitleStyle = TextStyle(
    color: Color(0xff383838),
    fontFamily: 'nunito',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );
  static BoxDecoration uploadContainerBorderStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
    border: Border.all(
      style: BorderStyle.solid,
      color: Color(0xffeeeeee),
      width: 1,
    ),
  );
  static const Color downloadSampleContainerColor = Color(0xffe2edff);
  static BoxDecoration downloadSampleBorderStyle = BoxDecoration(
      color: downloadSampleContainerColor,
      border: Border.all(
          style: BorderStyle.solid, width: 1, color: Color(0xffe9e9e9)));
  static const TextStyle labelStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'nunito',
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
      color: Color(0xff000000));
  static const TextStyle subLabelStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'nunito',
    fontWeight: FontWeight.normal,
    letterSpacing: 0.3,
    color: Color(0xff9f9f9f),
  );

  static const TextStyle inputTextStyle = TextStyle(
      color: Color(0xff383838),
      fontFamily: 'nunito',
      letterSpacing: 0.3,
      fontSize: 16);
  static InputDecoration inputElementDecoration = InputDecoration(
    contentPadding: EdgeInsets.only(top: 13, bottom: 12, right: 15, left: 15),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xffe8e8e8),
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(
        color: Color(0xffe8e8e8),
      ),
    ),
  );
  static const TextStyle buttonText = TextStyle(
      fontFamily: 'nunito',
      fontSize: 12,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w600,
      color: Color(0xff034bd9));

  static RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3),
      side: BorderSide(
          color: Color(0xff034bd9), style: BorderStyle.solid, width: 1));

  static const TextStyle downloadContainerSubtitle = TextStyle(
    fontFamily: 'nunito',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.29,
    color: Color(0xff034bd9),
  );

  static const TextStyle downloadSampleBodyContent = TextStyle(
    fontFamily: 'nunito',
    fontSize: 16,
    letterSpacing: 0.3,
    color: Color(0xff383838),
  );
  static const TextStyle copyRightText = TextStyle(
      color: Color(0xff8e8e8e),
      fontFamily: 'nunito',
      fontSize: 12,
      letterSpacing: 0.22);

  static const TextStyle selectSourceStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'nunito',
    fontWeight: FontWeight.normal,
    letterSpacing: 0.3,
    color: Color(0xff9f9f9f),
  );

  static BoxDecoration updateButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xff0941cc), Color(0xff0055fe)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(5.0),
  );

  static TextStyle uploadTextStyle = TextStyle(
    fontSize: ScreenUtil().setSp(3.0) < 9.0 ? 9.0 : ScreenUtil().setSp(3.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 2,
    color: Colors.white,
  );
}
