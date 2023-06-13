import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_html_css/simple_html_css.dart';

class DisClaimDialog extends StatefulWidget {
  DisClaimDialog(this.popuptitle, this.popupbody);

  final String popuptitle;
  final String popupbody;

  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DisClaimDialog> {
  final formKey = GlobalKey<FormState>();
  int i_v = 0;
  String finalDate = '';
  var dateParse;
  var htmlData;

  @override
  void initState() {
    super.initState();
    getCurrentDate();
    htmlData = widget.popupbody;
  }

  getCurrentDate() {
    var date = new DateTime.now().toString();

    dateParse = DateTime.parse(date);

    //  var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
  }

  @override
  void dispose() {
    super.dispose();
  }

  var deviceType;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
    );
    MediaQuery.of(context).orientation == Orientation.portrait;
    deviceType = getDeviceType(MediaQuery.of(context).size);
    return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: deviceType == DeviceScreenType.mobile
            ? Container(
                child: _commonPopUp(),
              )
            : Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
                child: _commonPopUp(), //this right here
              ));
  }

  Widget _commonPopUp() {
    return Container(
      width: deviceType == DeviceScreenType.mobile
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 1.0 / 1.25,
      height: deviceType == DeviceScreenType.mobile
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height * 1.0 / 1.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          deviceType == DeviceScreenType.mobile
              ? emptyWidget
              : Container(
                  padding: EdgeInsets.all(25),
                  color: Color(0xffefd82b),
                  width: MediaQuery.of(context).size.width * 1.0 / 6,
                  child: leftSide(),
                ),
          Expanded(
            child: Container(
              padding: deviceType == DeviceScreenType.mobile
                  ? EdgeInsets.symmetric(vertical: 6, horizontal: 25)
                  : EdgeInsets.all(25),
              color: Colors.white,
              child: rigthSide(),
            ),
          )
        ],
      ),
    );
  }

  Widget leftSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 30),
          child: _leftSideQfinrLogo(),
        ),
        Container(
          //  margin: EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              _termsAndConditionLink(),
              SizedBox(
                height: 16,
              ),
              _privacyPolicyLink()
            ],
          ),
        )
      ],
    );
  }

  _leftSideQfinrLogo() {
    return Container(
      child: svgImage(
        'assets/images/logo.svg',
        width: 120,
      ),
    );
  }

  _termsAndConditionLink() {
    return Container(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: "",
          style: deviceType == DeviceScreenType.mobile
              ? bodyText2.copyWith(decoration: TextDecoration.underline)
              : _termsAndConditionTextStyle(),
          children: <TextSpan>[
            TextSpan(
              text: "Terms of Service",
              style: deviceType == DeviceScreenType.mobile
                  ? bodyText2.copyWith(decoration: TextDecoration.underline)
                  : _termsAndConditionTextStyle()
                      .copyWith(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchURL("https://www.qfinr.com/terms-of-services/");
                },
            ),
          ],
        ),
      ),
    );
  }

  _privacyPolicyLink() {
    return Container(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: "",
          style: deviceType == DeviceScreenType.mobile
              ? bodyText2.copyWith(decoration: TextDecoration.underline)
              : _termsAndConditionTextStyle(),
          children: <TextSpan>[
            TextSpan(
              text: "Privacy Policy",
              style: deviceType == DeviceScreenType.mobile
                  ? bodyText2.copyWith(decoration: TextDecoration.underline)
                  : _termsAndConditionTextStyle()
                      .copyWith(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchURL("https://www.qfinr.com/privacy/");
                },
            ),
          ],
        ),
      ),
    );
  }

  _termsAndConditionTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      letterSpacing: 0.2,
      color: deviceType == DeviceScreenType.mobile
          ? Color(0xff5e5e5e)
          : Color(0xff000000),
    );
  }

  _titleTextStyle() {
    return TextStyle(
      fontSize: deviceType == DeviceScreenType.mobile
          ? getScaledValue(16)
          : getScaledValue(24),
      fontWeight: FontWeight.w700,
      fontFamily: 'roboto',
      letterSpacing: 0.2,
      color: Color(0xff000000),
    );
  }

  // _descriptionTextStyle() {
  //   return TextStyle(
  //     fontSize: deviceType == DeviceScreenType.mobile
  //         ? getScaledValue(12)
  //         : getScaledValue(20),
  //     fontWeight: FontWeight.w400,
  //     fontFamily: 'nunito',
  //     letterSpacing: 0.2,
  //     color: Color(0xff000000),
  //   );
  // }

  Widget rigthSide() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Scrollbar(
          isAlwaysShown: true,
          child: SingleChildScrollView(
            child: Column(
              children: [_rigthsideHeader()],
            ),
          ),
        )),
        Container(
          padding: deviceType == DeviceScreenType.mobile
              ? EdgeInsets.symmetric(vertical: 6)
              : EdgeInsets.symmetric(vertical: 30),
          //  margin: EdgeInsets.only(bottom: 30),
          child: _rigthsidefooter(),
        )
      ],
    ));
  }

  _rigthsideHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Text(
          widget.popuptitle,
          style: _titleTextStyle(),
        ),
        SizedBox(
          height: getScaledValue(30),
        ),
        // Html(
        //   data: htmlData,
        // ),
        HTML.toRichText(context, htmlData,
            defaultTextStyle: TextStyle(decoration: TextDecoration.none))
        // Text(
        //   widget.popupbody,
        //   style: _descriptionTextStyle(),
        // ),
      ],
    );
  }

  _rigthsidefooter() {
    return Container(
      //height: getScaledValue(100),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: getScaledValue(43),
                  width: deviceType == DeviceScreenType.mobile
                      ? getScaledValue(85)
                      : getScaledValue(120),
                  child: ElevatedButton(
                    style: qfButtonStyle(
                        ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
                    child: Ink(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff0941cc), Color(0xff0055fe)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                            minHeight: 50),
                        alignment: Alignment.center,
                        child: Text(
                          "Accept",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      log.d("dateParse_year");
                      log.d(dateParse.year);
                      log.d(dateParse.month);
                      log.d(dateParse.day);

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setInt('Year', dateParse.year);
                      await prefs.setInt('Month', dateParse.month);
                      await prefs.setInt('Date', dateParse.day);

                      Navigator.of(context).pop();
                    },
                  )),
              SizedBox(
                width: getScaledValue(16),
              ),
              Container(
                  height: getScaledValue(43),
                  width: deviceType == DeviceScreenType.mobile
                      ? getScaledValue(85)
                      : getScaledValue(120),
                  child: ElevatedButton(
                    style: qfButtonStyle(
                        ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
                    child: Ink(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.white],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Container(
                        color: Colors.white,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                            minHeight: 50),
                        alignment: Alignment.center,
                        child: Text(
                          "Decline",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop("Decline");
                    },
                  )),
            ],
          ),
          deviceType == DeviceScreenType.mobile
              ? SizedBox(
                  height: 16,
                )
              : emptyWidget,
          Row(
            children: [
              deviceType == DeviceScreenType.mobile
                  ? _termsAndConditionLink()
                  : emptyWidget,
              deviceType == DeviceScreenType.mobile
                  ? SizedBox(
                      width: 16,
                    )
                  : emptyWidget,
              deviceType == DeviceScreenType.mobile
                  ? _privacyPolicyLink()
                  : emptyWidget,
            ],
          ),
        ],
      ),
    );
  }

// showDialog(
//     context: context,
//     builder: ((BuildContext context) {
//       return DisClaimDialog();
//     }));

// showModalBottomSheet(
//           context: context,
//           builder: ((BuildContext context) {
//             return DisClaimDialog();
//           }));

}
