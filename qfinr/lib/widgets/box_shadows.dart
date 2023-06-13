import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';

import 'custom_box_shadow.dart';

abstract class BoxShadows {

  static final List<BoxShadow> cardShadow = [
    CustomBoxShadow(
        color: AppColor.shadowColor.withAlpha(Alpha.P10),
        offset: Offset(2.0, 2.0),
        blurRadius: 5.0,
        spreadRadius: 3,
        blurStyle: BlurStyle.normal),
    CustomBoxShadow(
        color: Colors.white.withAlpha(Alpha.P60),
        offset: Offset(0, -1),
        blurRadius: 1,
        spreadRadius: -1,
        blurStyle: BlurStyle.outer)
  ];
}