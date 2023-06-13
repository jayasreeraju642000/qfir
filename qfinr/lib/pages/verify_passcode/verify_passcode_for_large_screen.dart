import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

class VerifyPasscodeForLargeScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;

  final bool isBiometric;

  VerifyPasscodeForLargeScreen(this.model, this.setPasscode, this.isBiometric,
      {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPasscodeForLargeScreen();
  }
}

class _VerifyPasscodeForLargeScreen
    extends State<VerifyPasscodeForLargeScreen> {
  String _passcode;
  String _fcmToken;
  var localAuth; // = LocalAuthentication();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<String> _randomImageList = [];

  void initState() {
    super.initState();

    _randomImageList = widget.model.randomImages;

    if (!kIsWeb) {
      _firebaseMessaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
      );

      _firebaseMessaging.getToken().then((String token) {
        _fcmToken = token;
      });
    }

    if (_fcmToken == null || _fcmToken == "") {
      _fcmToken = "noToken";
    }

    if (widget.isBiometric && !widget.setPasscode) {
      _asyncMethod();
    }

    widget.model.setLoader(false);
  }

  Future<Null> _analyticsSwitchUserEvent() async {
    widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "login",
      'item_name': "user_switch_user",
      'content_type': "switch_user_button",
    });
  }

  Future<Null> _analyticsForgotPasscodeEvent() async {
    widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "login",
      'item_name': "user_forgot_password",
      'content_type': "forgot_password_button",
    });
  }

  Future<Null> _analyticsSetUserID(responseData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await widget.analytics.setUserId(prefs.getString('custID'));
    Navigator.pushReplacementNamed(context, '/home_new');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.model.isLoading
          ? preLoader()
          : PageWrapper(
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftSideImage(),
          _width(),
          _rightSideOfScreen(),
        ],
      ),
    );
  }

  _leftSideImage() {
    return Expanded(
      flex: 2,
      child: Image.asset(
        _randomImageList[1],
        fit: BoxFit.cover,
        width: double.maxFinite,
        height: 1000,
      ),
    );
  }

  _width() {
    return SizedBox(
      width: 10,
    );
  }

  Widget _rightSideOfScreen() {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.all(25.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _rightSideQfinrLogo(),
            SizedBox(height: getScaledValue(12.0)),
            Text(
              widget.setPasscode
                  ? 'Set your password'
                  : 'Type in your set password for',
              style: subTitleTextStyle,
            ),
            SizedBox(height: getScaledValue(2.0)),
            !widget.setPasscode ? _userDetails() : Container(),
            SizedBox(height: getScaledValue(12.0)),
            _passcodeForm(),
            SizedBox(height: getScaledValue(6.0)),
            _submitButton(),
            SizedBox(height: getScaledValue(6.0)),
            Container(
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  !widget.setPasscode
                      ? TextButton(
                          child:
                              widgetFlatButton("Switch User", TextAlign.left),
                          onPressed: () async {
                            await _analyticsSwitchUserEvent();
                            widget.model.logout();
                            //Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        )
                      : Container(),
                  TextButton(
                    child:
                        widgetFlatButton('Forgot Password?', TextAlign.right),
                    onPressed: () async {
                      await _analyticsForgotPasscodeEvent();
                      formResponseForgotPasscode();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: getScaledValue(30)),
            SizedBox(height: 14),
            _rightSideCopyRightLabel(),
          ],
        ),
      ),
    );
  }

  // _rightSideQfinrLogo() {
  //   return Container(
  //     child: svgImage(
  //       'assets/images/logo.svg',
  //       width: 30,
  //     ),
  //   );
  // }

  _rightSideQfinrLogo() {
    return Image.asset(
      'assets/images/logo.png',
    );
  }

  Widget _userDetails() {
    return Text(
      widget.model.isUserAuthenticated
          ? widget.model.userData.emailID
          : "Guest",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'nunito',
        letterSpacing: 0.24,
        color: Color(0xff111111),
      ),
    );
  }

  Widget _passcodeForm() {
    return Container(
      width: 400,
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'nunito',
            letterSpacing: 0.5,
            color: Color(0xff2454ec),
          ),
        ),
        keyboardType: TextInputType.text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          fontFamily: 'nunito',
          color: Colors.black,
        ),
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _passcode = value;
          });
        },
      ),
    );
  }

  Widget _submitButton() {
    return gradientButton(
      context: context,
      caption: "Login",
      onPressFunction: () => formResponse(widget.model),
    );
  }

  _rightSideCopyRightLabel() {
    return Text(
      "Copyright 2021 Qfinr. All rights reserved",
      style: _copyRightLabelTextStyle(),
    );
  }

  _copyRightLabelTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      letterSpacing: 1.0,
      color: Colors.grey,
    );
  }

  Future<void> _asyncMethod() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await widget.model.getCustomerSettings();

    if (kIsWeb) {
      Navigator.pushReplacementNamed(context, '/home_new');
      return;
    }

    // bypassing biometric authentication in debug mode
    if (isInDebugMode) {
      Navigator.pushReplacementNamed(context, '/home_new');
      return;
    }

    String biometricStatus = prefs.getString('enable_biometric');

    localAuth = LocalAuthentication();

    bool _boimetricAvailable = false;
    bool canCheckBiometrics;

    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Handle this exception here.
      }
    }
    setState(() {
      _boimetricAvailable = canCheckBiometrics;
    });

    const iosStrings = const IOSAuthMessages(
        cancelButton: 'cancel',
        goToSettingsButton: 'settings',
        goToSettingsDescription: 'Please set up your Touch ID.',
        lockOut: 'Please reenable your Touch ID');

    List<BiometricType> availableBiometrics =
        await localAuth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {}
    }

    if (_boimetricAvailable &&
        (biometricStatus == "1" || biometricStatus == null) &&
        widget.model.registrationSetPasscode == false &&
        widget.model.loginVerifyPasscode == false) {
      try {
        var localAuth2 = LocalAuthentication();
        bool didAuthenticate = await localAuth2.authenticateWithBiometrics(
            localizedReason: 'Please authenticate',
            useErrorDialogs: true,
            stickyAuth: true,
            iOSAuthStrings: iosStrings);

        if (didAuthenticate) {
          if (widget.model.userSettings['force_password'] == '1') {
            Navigator.pushReplacementNamed(
                context, '/setting/SettingsForcePasswordPage');
            //Navigator.pushReplacementNamed(context, '/setPasscode/true');
          } else {
            Navigator.pushReplacementNamed(context, '/home_new');
          }
        }
      } on PlatformException catch (e) {
        if (e.code == auth_error.notAvailable) {}
      }
    }
  }

  void formResponse(MainModel model) async {
    setState(() {
      widget.model.setLoader(true);
    });
    if (widget.setPasscode) {
      Map<String, dynamic> responseData =
          await model.setPasscode(context, _passcode, _fcmToken);
      formResponseHandler(responseData);
    } else {
      Map<String, dynamic> responseData = await model.verifyPasscode(
          context, widget.model.userData.emailID, _passcode, _fcmToken);

      formResponseHandler(responseData);
    }
  }

  void formResponseHandler(responseData) {
    if (responseData['status']) {
      if (responseData['response'].containsKey('force_password') &&
          responseData['response']['force_password'] == "1") {
        Navigator.pushReplacementNamed(context, '/setPasscode/true');
      } else {
        _analyticsSetUserID(responseData);
        //Navigator.pushReplacementNamed(context, '/home_new');
      }
    } else {
      setState(() {
        widget.model.setLoader(false);
      });
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  void formResponseForgotPasscode() async {
    setState(() {
      widget.model.setLoader(true);
    });
    Map<String, dynamic> responseData = await widget.model
        .forgotPassword(context, widget.model.userData.emailID);

    if (responseData['status']) {
      // Navigator.pushReplacementNamed(context, '/forgotPasswordConfirm');
      showForgotPasscodePopUp(context);
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
    setState(() {
      widget.model.setLoader(false);
    });
  }

  void showForgotPasscodePopUp(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  successImageContainer(),
                  alertTitle(),
                  subHeadingName(),
                  viewLoginButton()
                ],
              ),
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  Widget successImageContainer() => Container(
        width: 87,
        height: 93,
        alignment: Alignment.center,
        child: Image(
            image: AssetImage("assets/animation/tickAnimation_white.gif")),
      );

  Widget alertTitle() => Text(
        //'Link sent to\nreset passcode',
        'New passcode sent to\nyour registered email id',
        style: headline1.copyWith(fontSize: 20),
        textAlign: TextAlign.center,
      );

  Widget subHeadingName() => Container(
      //margin: EdgeInsets.only(top: 7),
      // child: Text(
      //   'We have sent a mail to your registered email id',
      //   style: bodyText1.copyWith(color: Color(0xff8e8e8e), fontSize: 12.0),
      //   textAlign: TextAlign.center,
      // ),
      );

  Widget viewLoginButton() => Container(
      margin: EdgeInsets.only(top: 25, left: 30, right: 30),
      width: 180,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(0.0),
        ),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 42,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                minHeight: 42),
            alignment: Alignment.center,
            child: Text(
              "Login",
              style: buttonStyle.copyWith(fontSize: 12, letterSpacing: 2),
            ),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/');
        },
      ));

  Widget widgetFlatButton(String text, TextAlign align) {
    return Text(
      text,
      style: linkText1,
      textAlign: align,
    );
  }

  TextStyle linkText1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.24),
    color: colorBlue,
  );

  TextStyle footerText1 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff989898),
  );

  TextStyle footerText2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xff989898),
  );

  TextStyle subTitleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.24,
    color: Color(0xff111111),
  );

  TextStyle bodyText0 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.24,
    color: Color(0xff111111),
  );

  TextStyle passcodeText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.5),
    color: Color(0xff000000),
  );

  Widget gradientButton(
      {BuildContext context,
      String caption,
      Function onPressFunction,
      bool buttonDisabled = false,
      bool miniButton = false}) {
    return Container(
      width: 150,
      child: RaisedButton(
        //padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0941cc), Color(0xff0055fe)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: ScreenUtil().setHeight(40),
            ),
            alignment: Alignment.center,
            child: Text(
              caption,
              style: buttonStyle.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ),
        textColor: Colors.white,
        onPressed: onPressFunction,
      ),
    );
  }
}
