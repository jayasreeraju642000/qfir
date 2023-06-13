import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

Widget widgetBubbleForWeb(
    {Color bgColor,
    Color textColor,
    double fontSize = 8,
    String title,
    Widget icon,
    double horizontalPadding = 2.0,
    double verticalPadding = 1.5,
    double leftMargin,
    bool includeBorder = true,
    Color borderColor,
    double rightMargin}) {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(horizontalPadding),
          vertical: getScaledValue(verticalPadding)),
      width: title == "LIVE"
          ? 42
          : title == "WATCHLIST"
              ? 85
              : 0,
      decoration: BoxDecoration(
        color: (bgColor != null ? bgColor : Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        border: includeBorder
            ? Border.all(
                color: borderColor != null ? borderColor : Color(0xffc2c2c2),
                width: 1.0,
              )
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon != null ? icon : emptyWidget,
            icon != null ? SizedBox(width: getScaledValue(10)) : emptyWidget,
            Text(title,
                textAlign: TextAlign.center,
                style: textColor != null
                    ? widgetBubbleTextStyle.copyWith(
                        color: textColor, fontSize: fontSize)
                    : widgetBubbleTextStyle.copyWith(fontSize: fontSize)),
          ],
        ),
      ));
}

Widget widgetZoneFlagForWeb(String zone) {
  return Image.asset(
    "assets/flag/" + zone + ".png",
    // width: getScaledValue(6),
    // height: getScaledValue(4),
    width: 14,
    height: 12,
  );
}

Widget flatButtonTextForWeb(title, BuildContext context,
    {Function onPressFunction,
    Color bgColor: Colors.white,
    Color borderColor = Colors.white,
    Color textColor = Colors.black,
    double fontSize,
    FontWeight fontWeight = FontWeight.w800,
    Alignment alignment = Alignment.center}) {
  return Container(
    alignment: alignment,
    // padding: EdgeInsets.all(getScaledValue(0)),
    width: 120,
    decoration: new BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1.0, color: borderColor),
        borderRadius: BorderRadius.circular(5)),
    child: FlatButton(
      splashColor: bgColor,
      minWidth: 120,
      height: 40,
      highlightColor: bgColor,
      onPressed: onPressFunction,
      child: Text(
        title,
        style: buttonStyle.copyWith(fontSize: (11), color: colorBlue),
      ),
    ),
  );
}

Widget gradientButtonForWeb(
    {BuildContext context,
    String caption,
    Function onPressFunction,
    bool buttonDisabled = false,
    bool miniButton = false}) {
  return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        //padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: miniButton ? 40 : 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: buttonDisabled || onPressFunction == null
                    ? [Colors.grey, Colors.grey[400]]
                    : [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: miniButton ? 40 : 50),
            alignment: Alignment.center,
            child: widgetButtonTextForWeb(caption,
                useContext: true, context: context, miniButton: miniButton),
          ),
        ),
        textColor: Colors.white,
        onPressed: onPressFunction,
      ));
}

Widget widgetButtonTextForWeb(String text,
    {bool useContext = false, BuildContext context, bool miniButton = false}) {
  return Text(
    text.toUpperCase(),
    style: buttonStyle.copyWith(
      fontSize: (11),
    ),
  );
}
