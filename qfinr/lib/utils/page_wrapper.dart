import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final double staticWidth = 1440;
  PageWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    var width = MediaQuery.of(context).size.width;
    if (width > staticWidth) {
      return Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black, width: 4.0),
          // color: Color(0xfff5f6fa),
          color: Color(0xfff5f6fa),
        ),
        child: Center(
          child: Material(
            elevation: 2.0,
            child: Container(
              color: Colors.white,
              width: staticWidth,
              child: child,
            ),
          ),
        ),
      );
    } else {
      return deviceType == DeviceScreenType.tablet
          ? SafeArea(
              child: Center(
                child: Container(
                  child: child,
                ),
              ),
            )
          : Center(
              child: Container(
                child: child,
              ),
            );
    }
  }
}
