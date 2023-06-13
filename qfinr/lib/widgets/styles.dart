import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

MaterialColor customMaterialColor(colorCode) {
  return MaterialColor(colorCode, color);
}

class Alpha {
  //10% alpha(a number between 0-255
  static const P05 = 13;
  static const P10 = 25;
  static const P15 = 38;
  static const P20 = 51;
  static const P30 = 76;
  static const P35 = 89;
  static const P40 = 102;
  static const P50 = 127;
  static const P60 = 153;
  static const P70 = 178;
  static const P80 = 204;
  static const P90 = 229;
}

class AppColor {
  static const Color colorRed = Color(0xffcc3333);
  static const Color colorGreenReturn = Color(0xff40c710);
  static const Color colorRedReturn = Color(0xffc31a1a);
  static const Color colorBlue = Color(0xff034bd9);
  static const Color colorBlue2 = Color(0xff1772ff);
  static const Color colorGreen = Color(0xff39b01d);
  static const Color colorGreen2 = Color(0xff63aa43);
  static const Color shadowColor = Color(0x293D4170);
  static const Color colorInactive = Color(0xff878787);
  static const Color colorActive = Color(0xff034bd9);
  static const Color veryLightPink = Color(0xffe9e9e9);
  static const Color cardShadowTop = Color(0xfff3f3f3);

  static const Color appBarBGColor = Color(0xff0445e4);
  static const Color appBarBGColorYellow = Color(0xffefd82b);
  static const Color colorGraphLinePrimary = Color(0xff787878);

  static const Color bottomBarIconColor = Color(0xff9c9c9c);
  static const Color bottomBarIconColorActive = Color(0xff034bd9);

  static const Color bottomBarBG = Color(0xffeeeeee);
  static const Color bottomBarBGActive = Color(0xffecf1fa);
  static const Color inputFocusColor = Color(0xff2454ec);

  static const Color divider = Color(0xffeaeaea);
  static const Color navigateIconColor = Color(0xff959595);

  static const Color heatGradientStart = Color(0xffd2c34c);
  static const Color heatGradientEnd = Color(0xff90ca48);
  static const Color yellowToolbar = Color(0xfffcdf01);
  static const Color headlineProfile = Color(0xfffcdf01);
  static const Color statusContainer = Color(0xffffefde);
  static const Color statusTextColor = Color(0xffac745a);
  static const Color optionMenuColor = Color(0xffa1a0a0);
  static const Color fillGrey6 = Color(0xfff7f7f7);
}

Color colorRed = Color(0xffcc3333);
Color colorGreenReturn = Color(0xff40c710);
Color colorRedReturn = Color(0xffc31a1a);
Color colorBlackReturn = Color(0xff000000);
Color colorBlue = Color(0xff034bd9);
Color colorBlue2 = Color(0xff1772ff);
Color colorGreen = Color(0xff39b01d);
Color colorGreen2 = Color(0xff63aa43);

Color colorDarkGrey = Color(0xff707070);

Color colorInactive = Color(0xff878787);
Color colorActive = Color(0xff034bd9);

const Color appBarBGColor = Color(0xff0445e4);
const Color appBarBGColorYellow = Color(0xffefd82b);
const Color colorGraphLinePrimary = Color(0xff787878);

ButtonStyle qfButtonStyle0 = ElevatedButton.styleFrom(
  padding: EdgeInsets.symmetric(horizontal: 16.0),
);

ButtonStyle qfButtonStyle(
    {double ph = 20.0, double pv: 15.0, double br: 8.0, tc: Colors.white}) {
  return ElevatedButton.styleFrom(
    padding: EdgeInsets.fromLTRB(ph, pv, ph, pv),
    shape:
        new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(br)),
    textStyle: TextStyle(color: tc),
  );
}

ButtonStyle qfButtonStyle2 = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
      side: BorderSide(color: colorBlue, width: 1.25, style: BorderStyle.solid),
      borderRadius: BorderRadius.circular(5)),
  padding: EdgeInsets.all(0.0),
);

TextStyle buttonStyle = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Colors.white);

TextStyle widgetBubbleTextStyle = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    //letterSpacing: 0.9,
    color: Color(0xffa7a7a7)); // Colors.black);

TextStyle textLink = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: colorBlue);
TextStyle textLink1 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: colorBlue);
TextStyle textLink2 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: colorBlue);

TextStyle headline1 = TextStyle(
    fontSize: ScreenUtil().setSp(25),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.40,
    color: Color(0xff181818));
TextStyle headline2 = TextStyle(
    fontSize: ScreenUtil().setSp(18),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.29,
    color: Color(0xff181818));
TextStyle headline3 = TextStyle(
    fontSize: ScreenUtil().setSp(20),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.32,
    color: Colors.black);
TextStyle headline4 = TextStyle(
    fontSize: ScreenUtil().setSp(18),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.32,
    color: Colors.black);
TextStyle headline5 = TextStyle(
    fontSize: ScreenUtil().setSp(22),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.35,
    color: Color(0xff181818));
TextStyle headline6 = TextStyle(
    fontSize: ScreenUtil().setSp(16),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.26,
    color: Colors.black);
TextStyle headline7 = TextStyle(
    fontSize: ScreenUtil().setSp(16),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.26,
    color: Colors.black);

TextStyle bodyText0 = TextStyle(
    fontSize: ScreenUtil().setSp(13.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.24,
    color: Color(0xff111111));
TextStyle bodyText1 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff989898));
TextStyle bodyText2 = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff5e5e5e));
TextStyle bodyText3 = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(1),
    color: Color(0xffa4a4a4));
TextStyle bodyText4 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff8e8e8e));
TextStyle bodyText5 = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle bodyText6 = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle bodyText7 = TextStyle(
    fontSize: ScreenUtil().setSp(9),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.9,
    color: Color(0xffa7a7a7));
TextStyle bodyText8 = TextStyle(
    fontSize: ScreenUtil().setSp(9),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.55,
    color: Color(0xffa7a7a7));
TextStyle bodyText9 = TextStyle(
    fontSize: ScreenUtil().setSp(9),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.19,
    color: Color(0xff474747));
TextStyle bodyText10 = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.17,
    color: Color(0xff474747));
TextStyle bodyText11 = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff1e1c1a));
TextStyle bodyText12 = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.17,
    color: Color(0xff474747));
TextStyle appBodyH3 = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.19,
    color: Color(0xff383838));
TextStyle appBodyH4 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));

TextStyle appBodyText1 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff9dc4ff));
TextStyle appBodyText2 = TextStyle(
    fontSize: ScreenUtil().setSp(25.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.4,
    color: Colors.white);

TextStyle inputLabelStyle = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Colors.grey);
TextStyle inputLabelFocusStyle = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Color(0xff2454ec));

Color inputFocusColor = Color(0xff2454ec);
TextStyle inputFieldStyle = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    fontFamily: 'nunito',
    color: Colors.black);
TextStyle inputFieldStyleInactive = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    color: Colors.grey);

TextStyle footerText1 = TextStyle(
    fontSize: ScreenUtil().setSp(13.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.24),
    color: Color(0xff989898));
TextStyle footerText2 = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.24),
    color: Color(0xff989898));
TextStyle linkText1 = TextStyle(
    fontSize: ScreenUtil().setSp(13.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.24),
    color: colorBlue);

TextStyle passcodeText = TextStyle(
    fontSize: ScreenUtil().setSp(25.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.5),
    color: Color(0xff000000)); // 0xffffc35d
TextStyle inputError = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0),
    color: Color(0xfff44336));

TextStyle inputError2 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0),
    color: Color(0xfff44336));

TextStyle appBodyPortfolioPrice = TextStyle(
    fontSize: ScreenUtil().setSp(25.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.4,
    color: Colors.white);

TextStyle bottomBarText = TextStyle(
    fontSize: ScreenUtil().setSp(9.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.4,
    color: Color(0xff9c9c9c));
TextStyle bottomBarTextActive = TextStyle(
    fontSize: ScreenUtil().setSp(9.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.4,
    color: Color(0xff034bd9));

TextStyle preLoaderBodyText1 = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Color(0xffb8b6b6));
TextStyle preLoaderBodyText2 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));

Color bottomBarIconColor = Color(0xff9c9c9c);
Color bottomBarIconColorActive = Color(0xff034bd9);

Color bottomBarBG = Color(0xffeeeeee);
Color bottomBarBGActive = Color(0xffecf1fa);

TextStyle graphTimestamp = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.0,
    color: Color(0xff979797),
    decoration: TextDecoration.underline);
TextStyle graphLink = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.0,
    color: Color(0xff034bd9));

TextStyle graphBubble = TextStyle(
    fontSize: ScreenUtil().setSp(9.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.19,
    color: Colors.white);

TextStyle selectBoxTitle = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.45,
    color: Colors.grey[850]);
TextStyle selectBoxOption = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.45,
    color: Colors.grey[700]);
TextStyle selectBoxOptionActive =
    selectBoxOption.copyWith(fontWeight: FontWeight.w600);

TextStyle appBodyProfilePercentage = TextStyle(
    fontSize: ScreenUtil().setSp(9.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.45,
    color: Color(0xffb1b1b1));
TextStyle appBenchmarkTitle = TextStyle(
    fontSize: ScreenUtil().setSp(25.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.45,
    color: Color(0xff63a0ff));

TextStyle appBenchmarkValue = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.23,
    color: Colors.white);
TextStyle appBenchmarkReturnPercentage = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff9dc4ff));
TextStyle appBenchmarkReturnValue = TextStyle(
    fontSize: ScreenUtil().setSp(18.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.45,
    color: colorRedReturn);
TextStyle appBenchmarkReturnType = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.23,
    color: Color(0xff474747));
TextStyle appBenchmarkReturnType2 = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff8c8c8c));
TextStyle appBenchmarkLink = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff034bd9));
TextStyle appBenchmarkSince = TextStyle(
    fontSize: ScreenUtil().setSp(9.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xffaeaeae));

TextStyle appBenchmarkPortfolioName = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff383838));
TextStyle appBenchmarPortfolioValue = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff8e8e8e));

TextStyle appBenchmarkPerformerHeading = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));
TextStyle appBenchmarkPerformerName = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle appBenchmarkPerformerReturn = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.16,
    color: Color(0xff818181));

TextStyle currencyConvert = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.85,
    color: Color(0xff82b3ff));
TextStyle currencyConvertActive = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xffffffff));
TextStyle currencyConvert2 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: colorBlue);

TextStyle appGraphOptBtn = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Color(0xff949494));
TextStyle appGraphOptBtnActive = TextStyle(
    fontSize: ScreenUtil().setSp(26.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Color(0xff034bd9));

TextStyle appGraphTitle = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));

TextStyle portfolioSummaryZone = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.8,
    color: Color(0xff272727));
TextStyle portfolioSummaryValue = TextStyle(
    fontSize: ScreenUtil().setSp(20.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.32,
    color: Color(0xff8a8a8a));

TextStyle portfolioBoxName = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: Color(0xff383838));

TextStyle lastCloseText = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: Color(0xff383838));
TextStyle portfolioBoxValue = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff272727));
TextStyle portfolioBoxReturn = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.16,
    color: Color(0xff818181));
TextStyle portfolioBoxStockCount = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff383838));
TextStyle portfolioBoxStockCountType = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff979797));
TextStyle portfolioBoxHolding = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff8e8e8e));

TextStyle tabLabel = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.86,
    color: Color(0xffa5a5a5));
TextStyle tabLabelActive = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.86,
    color: Color(0xff034bd9));
TextStyle tabBarActive = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.3,
    color: Color(0xff000000));
TextStyle tabBarInactive = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.3,
    color: Color(0x30000000));

TextStyle transactionBoxUnits = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle transactionBoxLabel = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff8b8b8b));
TextStyle transactionBoxDetail = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff161616));
TextStyle transactionBoxLink = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: colorBlue);

TextStyle sortBy = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.86,
    color: colorBlue);
TextStyle textStyleNote = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    fontFamily: 'nunito',
    letterSpacing: 0.16,
    color: Color(0xff818181));
TextStyle dialogBoxActionInactive = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: Color(0xff878787));
TextStyle dialogBoxActionActive = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0,
    color: colorBlue);

TextStyle importPortfolioHeading = TextStyle(
    fontSize: ScreenUtil().setSp(25.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.40,
    color: Colors.black);
TextStyle importPortfolioBody = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff8e8e8e));
TextStyle importPortfolioBody2 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff2d2d2d));
TextStyle importPortfolioHelpTitle = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));

TextStyle analysisScoreValue = TextStyle(
    fontSize: ScreenUtil().setSp(25.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.40,
    color: Color(0xffb3b3b3));
TextStyle analysisScoreTotal = TextStyle(
    fontSize: ScreenUtil().setSp(21.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xffb3b3b3));

TextStyle analysisPortfolioName = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff916719));
TextStyle analysisPortfolioValue = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff916719));

TextStyle keyStatsBodyHeading = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xffa5a5a5));
TextStyle keyStatsBodyText1 = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle keyStatsBodyText2 = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w500,
    fontFamily: 'nunito',
    letterSpacing: 0.16,
    color: Color(0xff818181));
TextStyle keyStatsBodyText3 = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle keyStatsBodyText4 = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.3,
    color: Color(0xff383838));
TextStyle keyStatsBodyText5 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff8e8e8e));
TextStyle keyStatsBodyText6 = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff8b8b8b));
TextStyle keyStatsBodyText7 = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff383838));

TextStyle innerTabHeading = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 1.2,
    color: Color(0xff000000).withOpacity(0.38));
TextStyle innerTabHeadingActive = TextStyle(
    fontSize: ScreenUtil().setSp(11.0),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 1.2,
    color: colorBlue);

TextStyle sortbyTitle = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 0.25,
    color: Color(0xffa5a5a5));
TextStyle sortbyOptionHeading = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff383838));
TextStyle sortbyOption = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.20,
    color: Color(0xff383838));
TextStyle sortbyOptionActive = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.20,
    color: colorBlue);

TextStyle stillHaveQuestionsTitle = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.34,
    color: Color(0xff4c410e));
TextStyle stillHaveQuestionsSubtitle = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.21,
    color: Color(0xff6e5c06));

//Large
TextStyle inputLabelStyleLarge = TextStyle(
  fontSize: ScreenUtil().setSp(4.0),
  fontWeight: FontWeight.w400,
  fontFamily: 'nunito',
  letterSpacing: 0.5,
  color: Colors.grey,
);

TextStyle inputLabelFocusStyleLarge = TextStyle(
  fontSize: ScreenUtil().setSp(8.0),
  fontWeight: FontWeight.w400,
  fontFamily: 'nunito',
  letterSpacing: 0.5,
  color: Color(0xff2454ec),
);

TextStyle inputFieldStyleLarge = TextStyle(
    fontSize: ScreenUtil().setSp(16.0),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: 'nunito',
    color: Colors.black);

// ignore: todo
// TODO : login & register small screen : shariyath

TextStyle headline_autho_sm_screen = TextStyle(
    fontSize: ScreenUtil().setSp(10),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.4,
    color: Color(0xff181818));

TextStyle headline2_autho_sm_screen = TextStyle(
    fontSize: ScreenUtil().setSp(4),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));

TextStyle headline3_autho_sm_screen = TextStyle(
    fontSize: ScreenUtil().setSp(10),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.32,
    color: Color(0xff034bd9));

TextStyle footer_autho_sm_screen = TextStyle(
    fontSize: ScreenUtil().setSp(4.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));

TextStyle footer_autho_sm_screen_blue = TextStyle(
    fontSize: ScreenUtil().setSp(4.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff034bd9));
TextStyle heading_alert_view_all = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.0,
    color: Color(0xff034bd9));

// ignore: todo
// TODO : login & register large screen : shariyath

TextStyle headline_autho_large_screen = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.4,
    color: Color(0xff181818));

TextStyle headline2_autho_large_screen = TextStyle(
    fontSize: ScreenUtil().setSp(4),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));

TextStyle headline3_autho_large_screen = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.32,
    color: Color(0xff034bd9));

TextStyle footer_autho_large_screen = TextStyle(
    fontSize: ScreenUtil().setSp(5.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle footer_autho_large_screen_blue = TextStyle(
    fontSize: ScreenUtil().setSp(5.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff034bd9));

TextStyle inputLabelFormStyleLarge = TextStyle(
  fontSize: ScreenUtil().setSp(4.0),
  fontWeight: FontWeight.w400,
  fontFamily: 'nunito',
  letterSpacing: 0.5,
  color: Colors.grey,
);
TextStyle inputLabelFocusFormStyleLarge = TextStyle(
  fontSize: ScreenUtil().setSp(4.0),
  fontWeight: FontWeight.w400,
  fontFamily: 'nunito',
  letterSpacing: 0.5,
  color: Color(0xff2454ec),
);
TextStyle inputFieldFormStyleLarge = TextStyle(
    fontSize: ScreenUtil().setSp(4.0),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: 'nunito',
    color: Colors.black);

TextStyle headline1_analyse = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.89,
    color: Color(0xff282828));
TextStyle headline2_analyse = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff707070));

TextStyle headline3_analyse = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.29,
    color: Color(0xff383838));
TextStyle headline4_analyse = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff707070));

TextStyle headline5_analyse = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.3,
    color: Color(0xff383838));
TextStyle headline6_analyse = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff979797));

TextStyle headline7_analyse = TextStyle(
    fontSize: ScreenUtil().setSp(18.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.29,
    color: Color(0xff383838));

TextStyle bodyText0_analyse = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));

TextStyle bodyText0_dashboard = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));

TextStyle bodyText1_analyse = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff383838));

TextStyle appGraphTitleLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));

TextStyle dashboardPerfomer = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5));
TextStyle body_text2_dashboardPerfomer = TextStyle(
    fontSize: ScreenUtil().setSp(10.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.16,
    color: Color(0xff818181));
TextStyle body_textcount_summary = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Color(0xff949494));
TextStyle body_text3_summary = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff797979));
TextStyle body_text0_portfolio = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle body_text1_portfolio = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.17,
    color: Color(0xff9f9f9f));
TextStyle body_text2_portfolio = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff383838));
TextStyle body_text3_portfolio = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.0,
    color: Color(0xff034bd9));
TextStyle body_textred_portfolio = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xffc42f2f));
TextStyle body_textgreen_portfolio = TextStyle(
    fontSize: ScreenUtil().setSp(12.0),
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff30c50c));
TextStyle header_nav_left_black = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff141414));
TextStyle header_nav_left_blue = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff034bd9));
TextStyle sub_header_nav_left_black = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff383838));
TextStyle sub_header_nav_left_blue = TextStyle(
    fontSize: ScreenUtil().setSp(14.0),
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.2,
    color: Color(0xff034bd9));
TextStyle body0_alerts = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff707070));

TextStyle inputLabelStyleDep = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  fontFamily: 'nunito',
  letterSpacing: 0.18,
  color: Color(0xff9c9c9c),
);

TextStyle inputLabelFocusStyleDep = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  fontFamily: 'nunito',
  letterSpacing: 0.18,
  color: Color(0xff034bd9),
);

TextStyle inputFieldStyleDep = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.24,
    fontFamily: 'nunito',
    color: Colors.black);

// ignore: todo
// TODO : END : shariyath
