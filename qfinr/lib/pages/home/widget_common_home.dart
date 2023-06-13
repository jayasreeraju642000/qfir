import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

buildSelectBoxCustomHomePage(
    {BuildContext context,
    String title,
    String value,
    List<Map<String, String>> options,
    Function onChangeFunction,
    String modelType = "bottomSheet"}) {
  /* List<Map<String, String>> days = [
		{ 'value': 'mon', 'title': 'Monday' },
		{ 'value': 'tue', 'title': 'Tuesday' },
	]; */

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
        content: Wrap(
          children: <Widget>[
            Container(
              color: Colors.grey[50],
              padding: EdgeInsets.symmetric(
                  horizontal: getScaledValue(10), vertical: getScaledValue(5)),
              margin: EdgeInsets.only(bottom: getScaledValue(10)),
              child: Column(
                children: _childrenOption,
              ),
            ),
          ],
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

  // showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) {
  //       return Wrap(
  //         children: <Widget>[
  //           Container(
  //               width: double.infinity,
  //               padding: EdgeInsets.symmetric(
  //                   horizontal: getScaledValue(15),
  //                   vertical: getScaledValue(10)),
  //               margin: const EdgeInsets.only(
  //                   bottom: 6.0), //Same as `blurRadius` i guess
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(5.0),
  //                 color: Colors.white,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey,
  //                     offset: Offset(0.0, 1.0), //(x,y)
  //                     blurRadius: 3.0,
  //                   ),
  //                 ],
  //               ),
  //               child: Text(title, style: selectBoxTitle)),
  //           Container(
  //             color: Colors.grey[50],
  //             padding: EdgeInsets.symmetric(
  //                 horizontal: getScaledValue(10), vertical: getScaledValue(5)),
  //             margin: EdgeInsets.only(bottom: getScaledValue(10)),
  //             child: Column(
  //               children: _childrenOption,
  //             ),
  //           ),
  //         ],
  //       );

  //     });
}
