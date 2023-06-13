import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

final log = getLogger('AuthenticationPage');

class AuthenticationPage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  AuthenticationPage(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _AuthenticationPageState();
  }
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  String _emailValue;
  String _passwordValue;
  String _fcmToken;

  var localAuth; // = LocalAuthentication();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void initState() {
    super.initState();

    _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
    );

    _firebaseMessaging.getToken().then((String token) {
      _fcmToken = token;
      log.d(token);
    });

    if (_fcmToken == null || _fcmToken == "") {
      _fcmToken = "iOs generated token";
      log.d('new generated token:');
      log.d(_fcmToken);
    }

    _asyncMethod();

    widget.model.setLoader(false);
  }

  Future<void> _asyncMethod() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await widget.model.getCustomerSettings();

    // bypassing biometric authentication in debug mode
    /* if(isInDebugMode){
			Navigator.pushReplacementNamed(context, '/home_new');
			return;
		} */

    log.d('printing key');
    String biometricStatus = prefs.getString('enable_biometric');

    log.d(biometricStatus);

    localAuth = LocalAuthentication();

    bool _boimetricAvailable = false;
    bool canCheckBiometrics;

    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      log.e('check auth error' + e.code + e.details);
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
        (biometricStatus == "1" || biometricStatus == null)) {
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
        log.e('_asyncMethod: auth error. code:' +
            e.code +
            'details:' +
            e.details);
        if (e.code == auth_error.notAvailable) {
          // Handle this exception here.
          log.e('auth not available');
        }
      }
    }
  }

  Widget _socialLogin() {
    return Container(
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              borderSide: BorderSide(
                  color: Colors.grey[700],
                  style: BorderStyle.solid,
                  width: 1.0),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Image.asset(
                    'assets/images/icon_facebook.png',
                    height: 20.0,
                  ),
                  SizedBox(
                    width: 7.5,
                  ),
                  Text(
                    'FACEBOOK',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF0A0B21),
                        fontWeight: FontWeight.normal),
                  )
                ],
              ),
              onPressed: () {
                socialResponse('facebook');
                //Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            SizedBox(width: 10.0),
            OutlineButton(
              borderSide: BorderSide(
                  color: Colors.grey[700],
                  style: BorderStyle.solid,
                  width: 1.0),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Image.asset(
                    'assets/images/icon_google.png',
                    height: 20.0,
                  ),
                  SizedBox(
                    width: 7.5,
                  ),
                  Text(
                    'GOOGLE',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF0A0B21),
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              onPressed: () {
                socialResponse('google');
                //Navigator.pushReplacementNamed(context, '/googleSignin');
              },
            ),
          ],
        ));
  }

  Widget _loginForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (!widget.model.isUserAuthenticated ||
                        (widget.model.isUserAuthenticated &&
                            widget.model.userData.displayImage == 'noImage')
                    ? Container(
                        width: 60.0,
                        height: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
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
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                      child: Text(
                        widget.model.isUserAuthenticated
                            ? widget.model.userData.custName
                            : "Guest",
                        style: TextStyle(
                            color: Colors.grey[850],
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    FlatButton(
                      child: widgetFlatButton(
                          widget.model.isUserAuthenticated
                              ? "Not " +
                                  widget.model.userData.custName +
                                  "? Sign Out"
                              : "Not Guest? Sign Out",
                          TextAlign.right),
                      onPressed: () {
                        widget.model.logout();
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[],
            ),
            SizedBox(height: 10.0),
            TextField(
              decoration: InputDecoration(
                  labelText: languageText('text_password') + '*',
                  icon: Icon(
                    Icons.lock,
                    color: Colors.grey[500],
                    size: 20.0,
                  ),
                  labelStyle:
                      TextStyle(color: Colors.grey[500], fontSize: 14.0)),
              obscureText: true,
              onChanged: (String value) {
                setState(() {
                  _passwordValue = value;
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
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          textColor: Colors.white,
          child: widgetButtonText(languageText('text_signin')),
          onPressed: () {
            formResponse(model);
          },
        ),
      );
    });
  }

  Widget _switchAction() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'New to Qfinr? ',
              style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF0A0B21),
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text(
                ' Sign Up',
                style: new TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).primaryColor),
              ),
            ),
            Text(' now',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF0A0B21),
                    fontWeight: FontWeight.normal)),
          ],
        ));
  }

  Widget _policyTerms() {
    return GestureDetector(
        onTap: () {
          launchURL("https://www.qfinr.com/privacy/");
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            alignment: Alignment.center,
            child: RichText(
                text: TextSpan(
                    text: "By signing in you agree to our ",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ]))));
  }

  void formResponse(MainModel model) async {
    /*log.d('test abc');
		log.d('******* printing data *******');
		log.d(_emailValue);
		log.d(_passwordValue);
		log.d(_fcmToken);
		log.d('******* printing data ends *******'); */

    Map<String, dynamic> responseData =
        await model.checkLogin(context, _emailValue, _passwordValue, _fcmToken);
    // log.d('test1');

    loadCustomerData(responseData);
  }

  void socialResponse(String socialType) async {
    Map<String, dynamic> responseData;

    setState(() {
      widget.model.setLoader(true);
    });

    if (socialType == "facebook") {
      //responseData = await widget.model.facebookLogin(_fcmToken);
    } else if (socialType == "google") {
      //responseData = await widget.model.googleLogin(_fcmToken);
    }
    setState(() {
      widget.model.setLoader(false);
    });

    loadCustomerData(responseData);
  }

  void loadCustomerData(responseData) {
    if (responseData['status']) {
      //widget.model.fetchBaskets();
      //widget.model.fetchMFBaskets();
      //widget.model.fetchMIBaskets(false);

      if (responseData['response'][''])
        Navigator.pushReplacementNamed(context, '/home_new');
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Theme.of(context)
              .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
          iconTheme: IconThemeData(
              color: Colors.white), //Theme.of(context).primaryColor),
          actions: <Widget>[],
          title: Image.asset(
            'assets/images/logo_white.png',
            fit: BoxFit.fill,
            height: 25.0,
          ),
          centerTitle: true,
        ),
        body: widget.model.isLoading
            ? preLoader()
            : mainContainer(context: context, child: _buildBody()));
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        SizedBox(height: 30.0),
        Text(
          languageText('text_form_social'),
          style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20.0,
        ),
        _socialLogin(),
        SizedBox(height: 10.0),
        Divider(
          height: 10.0,
        ),
        SizedBox(height: 10.0),
        _loginForm(),
        SizedBox(
          height: 10.0,
        ),
        _policyTerms(),
        SizedBox(height: 10.0),
        _submitButton(),
        FlatButton(
          //padding: EdgeInsets.fromLTRB(30.0, 20.0, 10.0, 20.0),
          child: widgetFlatButton('FORGOT PASSWORD?', TextAlign.right),
          onPressed: () {
            Navigator.pushNamed(context, '/forgotPassword');
          },
        ),
        SizedBox(height: 20.0),
        _switchAction(),
      ],
    );
  }
}
