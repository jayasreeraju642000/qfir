import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

class VerifyPasscodeForSmallScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;

  final bool isBiometric;

  VerifyPasscodeForSmallScreen(this.model, this.setPasscode, this.isBiometric,
      {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPasscodeForSmallScreen();
  }
}

class _VerifyPasscodeForSmallScreen
    extends State<VerifyPasscodeForSmallScreen> {
  String _passcode;
  String _fcmToken;

  var localAuth; // = LocalAuthentication();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void initState() {
    super.initState();

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

  Future<Null> _analyticsSetUserID(responseData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await widget.analytics.setUserId(prefs.getString('custID'));
    Navigator.pushReplacementNamed(context, '/home_new');
  }

  Future<Null> _analyticsSwitchUserEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "login",
      'item_name': "user_switch_user",
      'content_type': "switch_user_button",
    });
  }

  Future<Null> _analyticsForgotpascodeEvent() async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "login",
      'item_name': "user_forgot_password",
      'content_type': "forgot_password_button",
    });
  }

  Future<void> _asyncMethod() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await widget.model.getCustomerSettings();

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
      // log.d'check auth error');
      // log.de.code);
      // log.de.details);
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
        // Face ID.
        //log.d'face available');
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        //log.d'touch available');
      }
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
        // log.d(didAuthenticate);
      } on PlatformException catch (e) {
        // log.d'auth error test');
        // log.de.code);
        // log.de.details);
        if (e.code == auth_error.notAvailable) {
          // Handle this exception here.
          // log.d'auth not available');
        }
      }
    }
  }

  Widget _passcodeForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
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
          _passcode = value;
        },
      ),
    );
  }

  Widget _submitButton() {
    return gradientButton(
        context: context,
        caption: "Login",
        onPressFunction: () {
          formResponse(widget.model);
        });
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
        //Navigator.pushReplacementNamed(context, '/setting/SettingsForcePasswordPage');
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
    Map<String, dynamic> responseData = await widget.model
        .forgotPassword(context, widget.model.userData.emailID);

    if (responseData['status']) {
      //showAlertDialogBox(context, 'Passcode Sent!', responseData['response']);
      Navigator.pushReplacementNamed(context, '/forgotPasswordConfirm');
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  Widget _userDetails() {
    return Container(
      alignment: Alignment.center,
      child: Text(
          widget.model.isUserAuthenticated
              ? widget.model.userData.emailID
              : "Guest",
          style: bodyText0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Theme.of(context).buttonColor),
          // Colors.white), //
          actions: <Widget>[
            //_skipButton()
          ],
          //title:  Image.asset('assets/images/logo_white.png', fit: BoxFit.fill, height: 25.0,),
          centerTitle: true,
          elevation: 0,
        ),
        body: widget.model.isLoading
            ? preLoader()
            : mainContainer(
                containerColor: Colors.white,
                context: context,
                paddingLeft: getScaledValue(16),
                paddingRight: getScaledValue(16),
                child: _buildBody()));
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Text('Enter your passcode', style: headline1),
              ),
              SizedBox(height: getScaledValue(6.0)),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.setPasscode
                        ? 'Set your passcode'
                        : 'Type in your set passcode for',
                    style: footerText1,
                  )),
              !widget.setPasscode ? _userDetails() : Container(),
              SizedBox(height: getScaledValue(63.0)),
              _passcodeForm(),
              SizedBox(height: getScaledValue(12.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  !widget.setPasscode
                      ? FlatButton(
                          child:
                              widgetFlatButton("Switch User", TextAlign.left),
                          onPressed: () async {
                            widget.model.logout();
                            _analyticsSwitchUserEvent();
                            //Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        )
                      : Container(),
                  FlatButton(
                    child:
                        widgetFlatButton('Forgot Password?', TextAlign.right),
                    onPressed: () {
                      _analyticsForgotpascodeEvent();
                      formResponseForgotPasscode();
                      //Navigator.pushNamed(context, '/forgotPassword');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/icon/face_scan.png',
                height: getScaledValue(20.0)),
            SizedBox(width: getScaledValue(10)),
            Text("Enable Face ID in settings after login", style: footerText1),
          ],
        ),
        SizedBox(height: getScaledValue(15)),
        _submitButton(),
      ],
    );
  }
}
