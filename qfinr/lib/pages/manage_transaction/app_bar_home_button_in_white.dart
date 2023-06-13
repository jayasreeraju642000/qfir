import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/widgets/widget_common.dart';

class AppbarHomeButtonInWhite extends StatelessWidget {
  const AppbarHomeButtonInWhite({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: getScaledValue(16)),
        child: svgImage('assets/icon/home.svg', color: Colors.white),
        height: 16,
        width: 17);
  }
}
