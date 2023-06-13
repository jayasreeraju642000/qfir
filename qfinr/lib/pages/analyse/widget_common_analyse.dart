import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

customAlertBoxLargeAnalyse(
    {BuildContext context,
    String type = "info",
    String title,
    String description,
    Widget childContent,
    List<Widget> buttons}) {
  List<Widget> buttonRow = [];

  if (buttons == null || buttons.length == 0) {
    buttonRow.add(Expanded(
        child: gradientButtonLarge(
            context: context,
            caption: "Ok",
            onPressFunction: () => Navigator.pop(context))));
  } else {
    int i = 1;
    buttons.forEach((element) {
      buttonRow.add(Expanded(child: element));
      if (i < buttons.length) {
        buttonRow.add(SizedBox(width: getScaledValue(10)));
        i++;
      }
    });
  }

  Widget content = Container(
    padding: EdgeInsets.all(getScaledValue(10)),
    child: Column(children: <Widget>[
      title != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
              child: Text(title, style: appBodyH3))
          : emptyWidget,
      title != null
          ? Divider(height: getScaledValue(5), color: Colors.grey)
          : emptyWidget,
      title != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
      childContent != null ? childContent : emptyWidget,
      description != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
              child: Text(description, style: bodyText4))
          : emptyWidget,
      SizedBox(height: getScaledValue(20)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: buttonRow)
    ]),
  );

  loadPopup(context: context, content: content);
}

loadPopup(
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
            color: bgColor,
            width: getScaledValue(550),
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

        // actions: <Widget>[
        //   TextButton(
        //     style: qfButtonStyle0,
        //     child: Text("Close", style: dialogBoxActionInactive),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      );
    },
  );
}
