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
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('VerifyRegisterPasscodePage');

class VerifyRegisterPasscodePage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;

  final bool isBiometric;

  VerifyRegisterPasscodePage(this.model, this.setPasscode, this.isBiometric,
      {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _VerifyRegisterPasscodePageState();
  }
}

class _VerifyRegisterPasscodePageState
    extends State<VerifyRegisterPasscodePage> {
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

  Future<void> _asyncMethod() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await widget.model.getCustomerSettings();

    // bypassing biometric authentication in debug mode
    if (isInDebugMode) {
      //Navigator.pushReplacementNamed(context, '/home_new');
      //return;
    }

    // log.d('printing key');
    String biometricStatus = prefs.getString('enable_biometric');

    // log.d(biometricStatus);

    localAuth = LocalAuthentication();

    bool _boimetricAvailable = false;
    bool canCheckBiometrics;

    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      log.e('check auth error. code: ' + e.code + ' details: ' + e.details);
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
        //log.d('face available');
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        //log.d('touch available');
      }
    }

    if (_boimetricAvailable &&
        (biometricStatus == "1" || biometricStatus == null) &&
        widget.model.registrationSetPasscode == false) {
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
          } else {
            Navigator.pushReplacementNamed(context, '/home_new');
          }
        }
        log.i(didAuthenticate);
      } on PlatformException catch (e) {
        log.e('check auth error. code: ' + e.code + ' details: ' + e.details);
        if (e.code == auth_error.notAvailable) {
          // Handle this exception here.
          log.e('auth not available');
        }
      }
    }
  }

  Widget _passcodeForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Column(
          children: <Widget>[
            //
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '******',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Color(0xffdcdcdc), fontSize: 14.0),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (String value) {
                setState(() {
                  _passcode = value;
                });
              },
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
          ],
        ));
  }

  Widget _submitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          height: 50,
          buttonColor: Theme.of(context).buttonColor,
          child: RaisedButton(
            //padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0)),
            textColor: Colors.white,
            child: widgetButtonText('Continue'),
            onPressed: () {
              formResponse(model);
            },
          ),
        ),
      );
    });
  }

  void formResponse(MainModel model) async {
    if (widget.setPasscode) {
      Map<String, dynamic> responseData =
          await model.setPasscode(context, _passcode, _fcmToken);
      log.d('debug 136');
      log.d(responseData);
      formResponseHandler(responseData);
    } else {
      Map<String, dynamic> responseData = await model.verifyPasscode(
          context, widget.model.userData.emailID, _passcode, _fcmToken);
      formResponseHandler(responseData);
    }
  }

  void formResponseHandler(responseData) {
    if (responseData['status']) {
      //widget.model.fetchBaskets();
      //widget.model.fetchMFBaskets();
      //widget.model.fetchMIBaskets(true);

      if (responseData['response'].containsKey('force_password') &&
          responseData['response']['force_password'] == "1") {
        Navigator.pushReplacementNamed(
            context, '/setting/SettingsForcePasswordPage');
      } else {
        Navigator.pushReplacementNamed(context, '/home_new');
      }
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  void formResponseForgotPasscode() async {
    Map<String, dynamic> responseData = await widget.model
        .forgotPassword(context, widget.model.userData.emailID);

    if (responseData['status']) {
      showAlertDialogBox(context, 'Password Sent!', responseData['response']);
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  Widget _userDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          (!widget.model.isUserAuthenticated ||
                  (widget.model.isUserAuthenticated &&
                      widget.model.userData.displayImage == 'noImage')
              ? Container(
                  width: 60.0,
                  height: 60.0,
                  child: CircleAvatar(
                    backgroundColor:
                        Color(0xff6772e5), // Theme.of(context).buttonColor,
                    minRadius: 40.0,
                    child: Text(widget.model.isUserAuthenticated
                        ? widget.model.userData.custName
                            .substring(0, 2)
                            .toUpperCase()
                        : "G"),
                  ),
                )
              : Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              widget.model.userData.displayImage))))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 0.0),
                child: Text(
                  widget.model.isUserAuthenticated
                      ? widget.model.userData.custName
                      : "Guest",
                  style: TextStyle(
                      color: Color(0xff6772e5),
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Colors.white,

          /// Theme.of(context).primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

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
                child: _buildBody()));
  }

  Widget _buildBody() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        /* direction: Axis.vertical, */
        //shrinkWrap: true,
        children: <Widget>[
          /* Flexible(
  						fit: FlexFit.tight,
						child:
						Flex(
							direction: Axis.vertical,
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[

							],
						)

					), */
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 10.0),
            child: Text('Welcome to Qfinr',
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontSize: 22.0,
                      color: Theme.of(context).buttonColor,
                    )),
          ),
          SizedBox(height: 20.0),
          !widget.setPasscode ? _userDetails() : Container(),
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
                (widget.setPasscode
                    ? 'Set your password'
                    : 'Enter your password'),
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Color(0xFF6b7c93),
                    )),
          ),
          SizedBox(height: 20.0),
          /* Container(
						margin: EdgeInsets.symmetric(horizontal: 10.0),
						child: Text('Email:', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16.0),),
					), */
          _passcodeForm(),
          FlatButton(
            //padding: EdgeInsets.fromLTRB(30.0, 20.0, 10.0, 20.0),
            child: widgetFlatButton('Forgot Password?', TextAlign.right),
            onPressed: () {
              formResponseForgotPasscode();
              //Navigator.pushNamed(context, '/forgotPassword');
            },
          ),

          /* _submitButton(),

					!widget.setPasscode ? Container(
						alignment: Alignment.center,
						child: FlatButton(
						child: widgetFlatButton("Change User", TextAlign.right),
						onPressed: () {
							widget.model.logout();
							Navigator.pop(context);
							Navigator.pushReplacementNamed(context, '/');
						},
						),
					) : Container(), */
          _submitButton(),
          !widget.setPasscode
              ? FlatButton(
                  child: widgetFlatButton("Change User", TextAlign.right),
                  onPressed: () {
                    widget.model.logout();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/');
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
