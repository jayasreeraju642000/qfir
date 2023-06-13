import 'dart:async';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/utils/spacer_widget.dart';
import 'package:qfinr/utils/validator.dart';
import 'package:qfinr/widgets/disclaimer_alert.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_style.dart';

final log = getLogger('LoginPage');

class LoginForLargeScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  LoginForLargeScreen(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _LoginForLargeScreen();
  }
}

class _LoginForLargeScreen extends State<LoginForLargeScreen> {
  String _emailValue;
  String _fcmToken;

  String formAction = "login";
  String errorMessage = "";
  int id = 0;
  bool accept_qfinr = true;

  final emailTxtController = TextEditingController();
  final countryTxtController = TextEditingController();
  final nameTxtController = TextEditingController();
  final refCodeTxtController = TextEditingController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Map<String, FocusNode> focusNodes = {
    'passcode': new FocusNode(),
    'confirmPasscode': new FocusNode(),
    'email_id': new FocusNode(),
    'first_name': new FocusNode(),
    'last_name': new FocusNode(),
    'country_code': new FocusNode(),
    'mobile_number': new FocusNode(),
    'country': new FocusNode(),
    'currency': new FocusNode(),
    'referral_code': new FocusNode(),
  };

  Map<String, TextEditingController> _controller = {
    'passcode': new TextEditingController(),
    'confirmPasscode': new TextEditingController(),
    'email_id': new TextEditingController(),
    'first_name': new TextEditingController(),
    'last_name': new TextEditingController(),
    'country_code': new TextEditingController(),
    'mobile_number': new TextEditingController(),
    'country': new TextEditingController(),
    'currency': new TextEditingController(),
    'referral_code': new TextEditingController(),
  };

  Map _userData = {
    "passcode": "",
    "confirmPasscode": "",
    "email_id": "",
    "first_name": "",
    "last_name": "",
    "country_code": "",
    "mobile_number": "",
    "country": "in",
    "currency": "inr",
    "referral_code": "",
  };

  Map countryMap = {
    "in": "India",
    "sg": "Singapore",
    "us": "USA",
  };

  Map currencyMap = {
    "in": {"code": "inr", "value": "Indian Rupees (INR)"},
    "sg": {"code": "sgd", "value": "US Dollars (USD)"},
    "us": {"code": "usd", "value": "Singapore Dollars (SGD)"},
  };

  List<Map> countries = [
    {
      "code": "in",
      "country": "India",
      "currency": {
        "value": "inr",
        "symbol": "₹",
        "title": "Indian Rupees (INR)"
      }
    },
    {
      "code": "sg",
      "country": "Singapore",
      "currency": {"value": "usd", "symbol": "\$", "title": "US Dollars (USD)"}
    },
    {
      "code": "us",
      "country": "USA",
      "currency": {
        "value": "sgd",
        "symbol": "S\$",
        "title": "Singapore Dollars (SGD)"
      }
    },
  ];

  String _country;
  String _currency;

  //final _loginKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registrationKey = GlobalKey<FormState>();

  Future<Null> _analyticsLoginCurrentScreen() async {
    // log.d("\n analyticsLoginCurrentScreen called \n");
    await widget.analytics
        .setCurrentScreen(screenName: 'login', screenClassOverride: 'login');
  }

  Future<Null> _analyticsRegCurrentScreen() async {
    // log.d("\n analyticsRegCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'register',
      screenClassOverride: 'register',
    );
  }

  Future<Null> _analyticsPassCodeCurrentScreen() async {
    // log.d("\n analyticsPassCodeCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'set_passcode',
      screenClassOverride: 'set_passcode',
    );
  }

  Future<Null> _analyticsAddLoginEvent() async {
    // log.d("\n analyticsAddLoginEvent called \n");
    await widget.analytics.logEvent(name: 'login', parameters: {
      'item_id': "login",
      'item_name': "user_login",
      'content_type': "login_button",
    });
  }

  Future<Null> _analyticsAddRegEvent() async {
    // log.d("\n analyticsAddRegEvent called \n");
    await widget.analytics.logEvent(name: 'sign_up', parameters: {
      'item_id': "register",
      'item_name': "user_register",
      'content_type': "register_button",
    });
  }

  Map<dynamic, dynamic> response_ip_v;

  List<String> _randomImageList = [];

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

    widget.model.setLoader(false);

    widget.model.getZoneList();

    //getCurrentDate();
    getIpAddress();

    _randomImageList = widget.model.randomImages;

    //_randomImageList.shuffle();
  }

  void getIpAddress() async {
    final ipv4 = await Ipify.ipv4();
    log.d(ipv4);

    validateIP(ipv4);
  }

  validateIP(ipv4) async {
    response_ip_v = await widget.model.validateIP(ipv4);
    // response_ip_v =
    //     await widget.model.validateIP('11.32.204.128'); // singapore ip
    if (response_ip_v['status'] == false) {
      var popuptitle = response_ip_v['popuptitle'];
      var popupbody = response_ip_v['popupbody'];

      log.d("Testing ip valid response");

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var _year = prefs.getInt('Year');
      var _month = prefs.getInt('Month');
      var _date = prefs.getInt('Date');
      if (_year != null) {
        final stored_date = DateTime(_year, _month, _date);
        final currentDate = DateTime.now();

        final diff_dy = currentDate.difference(stored_date).inDays;

        log.d("diff_dy");
        log.d(diff_dy);

        if (diff_dy >= 7) {
          showDialog(
              context: context,
              builder: ((BuildContext context) {
                return DisClaimDialog(popuptitle, popupbody);
              })).then((value) {
            if (value == 'Decline') {
              setState(() {
                accept_qfinr = false;
              });

              // bottomAlertBoxLargeAnalyse(
              //   context: context,
              //  title: "Decline accepted",
              //   description: "You have chosen not to continue to Qfinr Web App"
              // );
            }
          });
        }
      } else {
        showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DisClaimDialog(popuptitle, popupbody);
            })).then((value) {
          if (value == 'Decline') {
            setState(() {
              accept_qfinr = false;
            });
            // bottomAlertBoxLargeAnalyse(
            //   context: context,
            //   title: "Decline accepted",
            //   description: "You have chosen not to continue to Qfinr Web App"
            // );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        360,
        740,
      ),
    );

    // ScreenUtil.init(context,
    //     designSize: Size(MediaQuery.of(context).size.width,
    //         MediaQuery.of(context).size.height),
    //     allowFontScaling: true);

    changeStatusBarColor(Colors.white);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: widget.model.isLoading
            ? preLoader()
            : PageWrapper(
                child: _bodySelector(),
              ),
      );
    });
  }

  Widget _bodySelector() {
    if (formAction == "login") {
      _analyticsLoginCurrentScreen();
      return _buildBodyLogin();
    } else if (formAction == "passcode" || formAction == "confirmPasscode") {
      _analyticsPassCodeCurrentScreen();
      return _buildPasscode();
    } else if (formAction == "registration") {
      _analyticsRegCurrentScreen();
      return _registration1Body();
    } else {
      return _registration2Body();
    }
  }

  /**
   * Login Start
   */

  Widget _buildBodyLogin() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leftSideImage(),
          _width(),
          _rightSideLoginForm(),
        ],
      ),
    );
  }

  _leftSideImage() {
    return Expanded(
      flex: 2,
      child: Image.asset(
        _randomImageList[0],
        fit: BoxFit.cover,
        width: double.maxFinite,
        height: 1000,
      ),
    );
  }

  _width() {
    return SizedBox(
      width: 10.0,
    );
  }

  _rightSideLoginForm() {
    return Expanded(
      flex: 3,
      child: Form(
        key: _loginKey,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rightSideQfinrLogo(),
                SpacerWidget.large,
                _rightSideHeader(),
                SpacerWidget.large,
                _rightSideEmailAddressField(),
                SpacerWidget.medium,
                _termsAndConditionLink(),
                SpacerWidget.large,
                _rightSideLoginButton(),
                SpacerWidget.large,
                SpacerWidget.large,
                // _rightSideSignUpText(),
                SpacerWidget.large,
                SpacerWidget.small,
                _rightSideCopyRightLabel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _rightSideQfinrLogo() {
    return Image.asset(
      'assets/images/logo.png',
    );
  }

  // _rightSideQfinrLogo() {
  //   return Container(
  //     child: svgImage(
  //       'assets/images/logo.svg',
  //       width: 35,
  //     ),
  //   );
  // }

  _rightSideHeader() {
    return Text(
      "Enter your registered email address",
      style: LoginScreenStyle.headerStyleForLargeScreen,
    );
  }

  _rightSideEmailAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: _emailTextFormField(),
        ),
      ],
    );
  }

  //Email text form field for both large and small
  Widget _emailTextFormField() {
    return TextFormField(
      focusNode: focusNodes['email_id'],
      controller: emailTxtController,
      validator: (value) {
        return _validateEmail(value);
      },
      decoration: _emailTextFormInputDecoration(),
      keyboardType: TextInputType.emailAddress,
      style: _emailTextFormStyle(),
      onChanged: (value) {
        setState(() {
          _emailValue = value;
          _userData['email_id'] = value;
        });
      },
    );
  }

  _validateEmail(String value) {
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value) ||
        value.length < 2 ||
        value.isEmpty) {
      return "The Email id you have entered is invalid";
    }
    return null;
  }

  _termsAndConditionLink() {
    return Container(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: "by continuing I agree to ",
          style: _termsAndConditionTextStyle(),
          children: <TextSpan>[
            TextSpan(
              text: "Terms & Conditions",
              style: _termsAndConditionTextStyle()
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

  _rightSideLoginButton() {
    return Container(
      width: 150,
      child: ElevatedButton(
        style: qfButtonStyle(
            ph: 0.0,
            pv: 0.0,
            br: 5.0,
            tc: accept_qfinr ? Colors.white : Colors.grey),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 40,
          decoration: _loginButtonDecoration(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: ScreenUtil().setHeight(40),
            ),
            alignment: Alignment.center,
            child: _loginTextLabel(),
          ),
        ),
        onPressed: () {
          if (accept_qfinr == true) {
            setState(() {});
            if (_loginKey.currentState.validate()) {
              formResponse(widget.model);
            }
          }
        },
      ),
    );
  }

  _loginButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: accept_qfinr
            ? [Color(0xff0941cc), Color(0xff0055fe)]
            : [Colors.grey, Colors.grey],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  _loginTextLabel() {
    return Text(
      "NEXT",
      style: _loginTextLabelStyle(),
    );
  }

  _loginTextLabelStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      // letterSpacing: 2.0,
      color: Colors.white,
    );
  }

  _dontHaveAnAccountTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      fontFamily: 'nunito',
      letterSpacing: 1.0,
      color: Colors.grey,
    );
  }

  _signUpTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      letterSpacing: 1.0,
      color: Color(0xff034bd9),
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

  _emailTextFormInputDecoration() {
    return InputDecoration(
      // contentPadding: EdgeInsets.all(5), //  <- you can it to 0.0 for no space
      // isDense: true,
      // contentPadding: EdgeInsets.only(top: 24), //  <- you can it to 0.0 for no space
      // isDense: false,
      hintText: 'name@domain.com',
      hintStyle: _emailInputLabelStyle(),
      labelText: "Email id",
      labelStyle: _emailLabelStyle(),
    );
  }

  _emailLabelStyle() {
    return focusNodes['email_id'].hasFocus
        ? _emailTextFocusStyle()
        : _emailTextFormStyle();
  }

  _emailInputLabelStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.5,
      color: Colors.grey,
    );
  }

  _emailTextFocusStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 0.5,
      color: Color(0xff2454ec),
    );
  }

  _emailTextFormStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamily: 'nunito',
      color: Colors.black,
    );
  }

  _termsAndConditionTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'nunito',
      letterSpacing: 0.2,
      color: Color(0xff5e5e5e),
    );
  }

  /**
   * Login End
   */

  /**
   * Set Passcode Start
   */

  Widget _buildPasscode() {
    return Container(
      child: formAction == "passcode"
          ? _setPasscodeBody()
          : _confirmPasscodeBody(),
    );
  }

  _setPasscodeBody() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftSideSetPasscodeImage(),
          _width(),
          _rightSideSetPasscodeForm(),
        ],
      ),
    );
  }

  _leftSideSetPasscodeImage() {
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

  _rightSideSetPasscodeForm() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rightSideQfinrLogo(),
              SpacerWidget.large,
              _rightSideSetPasscodeHeader(),
              SizedBox(height: getScaledValue(2.0)),
              _rightSideSetPasscodeSubHeader(),
              SizedBox(height: getScaledValue(12.0)),
              _rightSideSetPasscodePinCodeForm(),
              Container(
                width: 400,
                alignment: Alignment.centerLeft,
                child: Text(
                  errorMessage,
                  style: inputError,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: getScaledValue(6.0)),
              _rightSideSetPasscodeContinueButton(),
              SizedBox(height: getScaledValue(6.0)),
              _rightSideSignInText(),
              SpacerWidget.large,
              SpacerWidget.small,
              _rightSideCopyRightLabel(),
            ],
          ),
        ),
      ),
    );
  }

  _rightSideSetPasscodeHeader() {
    return Text(
      "Set a password",
      style: LoginScreenStyle.headerStyleForLargeScreen,
    );
  }

  _rightSideSetPasscodeSubHeader() {
    return Text(
      "Create a password for ease of access on multiple devices",
      style: subTitleTextStyle,
    );
  }

  Widget _rightSideSetPasscodePinCodeForm() {
    return Container(
      width: 400,
      child: TextFormField(
        focusNode: focusNodes['passcode'],
        controller: _controller['passcode'],
        obscureText: true,
        validator: (value) {
          if (Validator.validateStructure(value)) {
            return "A minimum 8 characters password contains a combination of an uppercase and a lowercase letter and a number and a special character.";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: focusNodes['passcode'].hasFocus
              ? TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'nunito',
                  letterSpacing: 0.5,
                  color: Color(0xff2454ec),
                )
              : TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'nunito',
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
        ),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          fontFamily: 'nunito',
          color: Colors.black,
        ),
        keyboardType: TextInputType.text,
        onChanged: (String value) {
          _userData['passcode'] = value;
        },
      ),
    );
  }

  _rightSideSetPasscodeContinueButton() {
    if (formAction == "passcode") {
      return Container(
        width: 150,
        child: ElevatedButton(
          style: qfButtonStyle(
            ph: 0.0,
            pv: 0.0,
            br: 5.0,
            tc: Colors.white,
          ),
          child: Ink(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: _loginButtonDecoration(),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: ScreenUtil().setHeight(40),
              ),
              alignment: Alignment.center,
              child: Text(
                "Continue",
                style: _loginTextLabelStyle(),
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              if (_userData['passcode'] != null &&
                  Validator.validateStructure(_userData['passcode'])) {
                errorMessage = "";
                setPasscodeAction();
              } else {
                errorMessage =
                    "A minimum 8 characters password contains a combination of an uppercase and a lowercase letter and a number and a special character.";
              }
            });
          },
        ),
      );
    }
  }

  _rightSideSignInText() {
    return RichText(
      text: TextSpan(
        text: "Already have an account?",
        style: _dontHaveAnAccountTextStyle(),
        children: <TextSpan>[
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  formAction = "login";
                });
              },
            text: " Sign In",
            style: _signUpTextStyle(),
          ),
        ],
      ),
    );
  }

  TextStyle passcodeText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'nunito',
    letterSpacing: 0.5,
    color: Color(0xff000000),
  );

  TextStyle subTitleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 1.0,
    color: Colors.black,
  );

  /**
   * Set Passcode End
   */

  /**
   * Confirm Passcode Start
   */

  _confirmPasscodeBody() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftSideConfirmPasscodeImage(),
          _width(),
          _rightSideConfirmPasscodeBody(),
        ],
      ),
    );
  }

  _leftSideConfirmPasscodeImage() {
    return Expanded(
      flex: 2,
      child: Image.asset(
        _randomImageList[2],
        fit: BoxFit.cover,
        width: double.maxFinite,
        height: 1000,
      ),
    );
  }

  _rightSideConfirmPasscodeBody() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rightSideQfinrLogo(),
              SpacerWidget.large,
              _rightSideConfirmPasscodeHeader(),
              SizedBox(height: getScaledValue(2.0)),
              _rightSideConfirmPasscodeSubHeader(),
              SizedBox(height: getScaledValue(12.0)),
              _rightSideConfirmPasswordForm(),
              SizedBox(height: getScaledValue(3.0)),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  errorMessage,
                  style: inputError,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: getScaledValue(3.0)),
              _rightSideConfirmPasscodeContinueButton(),
              SpacerWidget.large,
              SpacerWidget.small,
              _rightSideCopyRightLabel(),
            ],
          ),
        ),
      ),
    );
  }

  _rightSideConfirmPasscodeHeader() {
    return Text(
      "Confirm passcode",
      style: LoginScreenStyle.headerStyleForLargeScreen,
    );
  }

  _rightSideConfirmPasscodeSubHeader() {
    return Text(
      "Setup a passcode to ensure all your data is protected",
      style: subTitleTextStyle,
    );
  }

  Widget _rightSideConfirmPasswordForm() {
    return Container(
      width: 400,
      child: TextFormField(
        focusNode: focusNodes['confirmPasscode'],
        controller: _controller['confirmPasscode'],
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          labelStyle: focusNodes['confirmPasscode'].hasFocus
              ? TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'nunito',
                  letterSpacing: 0.5,
                  color: Color(0xff2454ec),
                )
              : TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'nunito',
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
        ),
        keyboardType: TextInputType.text,
        onChanged: (String value) {
          _userData['confirmPasscode'] = value;
        },
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          fontFamily: 'nunito',
          color: Colors.black,
        ),
      ),
    );
  }

  _rightSideConfirmPasscodeContinueButton() {
    if (formAction == "confirmPasscode") {
      return Container(
        width: 150,
        child: ElevatedButton(
          style: qfButtonStyle(
            ph: 0.0,
            pv: 0.0,
            br: 5.0,
            tc: Colors.white,
          ),
          child: Ink(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: _loginButtonDecoration(),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: ScreenUtil().setHeight(40),
              ),
              alignment: Alignment.center,
              child: Text(
                "Continue",
                style: _loginTextLabelStyle(),
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              if (_userData['confirmPasscode'] != null &&
                  _userData['passcode'] == _userData['confirmPasscode']) {
                errorMessage = "";
                setPasscodeAction();
              } else {
                errorMessage = "Password Mismatch";
              }
            });
          },
        ),
      );
    }
  }

  TextStyle inputError = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0),
    color: Color(0xfff44336),
  );

  /**
   * Confirm Passcode End
   */

  /**
   * Registration1 Start
   */

  _registration1Body() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftSideRegistrationImage1(),
          //_leftSideConfirmPasscodeImage(),
          _width(),
          _rightSideRegistration1Form(),
        ],
      ),
    );
  }

  _leftSideRegistrationImage1() {
    return Expanded(
      flex: 2,
      child: Image.asset(
        _randomImageList[3],
        fit: BoxFit.cover,
        width: double.maxFinite,
        height: 1000,
      ),
    );
  }

  _rightSideRegistration1Form() {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.all(25),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rightSideQfinrLogo(),
            SpacerWidget.large,
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Few more details',
                style: LoginScreenStyle.headerStyleForLargeScreen,
              ),
            ),
            SizedBox(height: getScaledValue(2.0)),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'and we are set to manage your investments',
                style: subTitleTextStyle,
              ),
            ),
            SizedBox(height: getScaledValue(12.0)),
            _registerForm(),
            Expanded(
              child: SizedBox(height: getScaledValue(6.0)),
            ),
            _rightSideRegistration1NextButton(),
          ],
        ),
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _registrationKey,
      autovalidateMode: AutovalidateMode.always,
      child: Container(
          width: 500,
          child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                focusNode: focusNodes['first_name'],
                controller: _controller['first_name'],
                validator: (value) {
                  if (value.length < 2 || value.isEmpty) {
                    return "Invalid First Name";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: focusNodes['first_name'].hasFocus
                      ? _emailTextFocusStyle()
                      : _emailTextFormStyle(),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String value) {
                  setState(() {
                    _userData['first_name'] = value;
                  });
                },
                style: _emailTextFormStyle(),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                focusNode: focusNodes['last_name'],
                controller: _controller['last_name'],
                validator: (value) {
                  if (value.length < 2 || value.isEmpty) {
                    return "Invalid Last Name";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: focusNodes['last_name'].hasFocus
                      ? _emailTextFocusStyle()
                      : _emailTextFormStyle(),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String value) {
                  setState(() {
                    _userData['last_name'] = value;
                  });
                },
                style: _emailTextFormStyle(),
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Container(
                    width: 150,
                    child: TextFormField(
                      focusNode: focusNodes['country_code'],
                      controller: _controller['country_code'],
                      validator: (value) {
                        if ((value.length < 2 && value.length > 4) ||
                            value.isEmpty ||
                            !isNumeric(value)) {
                          return "Invalid Country Code";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Country Code',
                        labelStyle: focusNodes['country_code'].hasFocus
                            ? _emailTextFocusStyle()
                            : _emailTextFormStyle(),
                        prefix: Text("+"),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (String value) {
                        setState(() {
                          _userData['country_code'] = value;
                        });
                      },
                      style: _emailTextFormStyle(),
                    ),
                  ),
                  SizedBox(width: 50),
                  Expanded(
                    child: TextFormField(
                      focusNode: focusNodes['mobile_number'],
                      controller: _controller['mobile_number'],
                      validator: (value) {
                        if ((value.length < 7 || value.length > 12) ||
                            value.isEmpty ||
                            !isNumeric(value)) {
                          return "Invalid Mobile Number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: focusNodes['mobile_number'].hasFocus
                            ? _emailTextFocusStyle()
                            : _emailTextFormStyle(),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (String value) {
                        setState(() {
                          _userData['mobile_number'] = value;
                        });
                      },
                      style: _emailTextFormStyle(),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0),
              TextFormField(
                focusNode: focusNodes['referral_code'],
                controller: _controller['referral_code'],
                // validator: (value) {
                //   if (value.length < 2 || value.isEmpty) {
                //     return "Invalid Referral Code";
                //   }
                //   return null;
                // },
                decoration: InputDecoration(
                  labelText: 'Referral Code',
                  labelStyle: focusNodes['referral_code'].hasFocus
                      ? _emailTextFocusStyle()
                      : _emailTextFormStyle(),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String value) {
                  setState(() {
                    _userData['referral_code'] = value;
                  });
                },
                style: _emailTextFormStyle(),
              ),
            ],
          )),
    );
  }

  _rightSideRegistration1NextButton() {
    return Container(
      height: 40,
      width: 150,
      color: Colors.white,
      child: ElevatedButton(
        style: qfButtonStyle(
          ph: 0.0,
          pv: 0.0,
          br: 5.0,
          tc: Colors.white,
        ),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 40,
          decoration: _loginButtonDecoration(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: ScreenUtil().setHeight(40),
            ),
            alignment: Alignment.center,
            child: Text(
              "Next",
              style: _loginTextLabelStyle(),
            ),
          ),
        ),
        onPressed: () {
          if (_registrationKey.currentState.validate()) {
            setState(() {
              _registrationKey.currentState.save();
              formAction = "registration2";
            });
          }
        },
      ),
    );
  }

  /**
   * Registration1 End
   */

  /**
   * Registration2 Start
   */

  _registration2Body() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftSideRegistrationImage2(),
          //_leftSideConfirmPasscodeImage(),
          _width(),
          _rightSideRegistration2Form(),
        ],
      ),
    );
  }

  _leftSideRegistrationImage2() {
    return Expanded(
      flex: 2,
      child: Image.asset(
        _randomImageList[4],
        fit: BoxFit.cover,
        width: double.maxFinite,
        height: 1000,
      ),
    );
  }

  _rightSideRegistration2Form() {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.all(25),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rightSideQfinrLogo(),
            SpacerWidget.large,
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Country of Residence',
                style: LoginScreenStyle.headerStyleForLargeScreen,
              ),
            ),
            SizedBox(height: getScaledValue(12.0)),
            _registerCountryForm(),
            SizedBox(height: getScaledValue(5.0)),
            Expanded(
              child: Text(
                "COMING SOON IN OTHER COUNTRIES",
                style: bodyText3,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: SizedBox(height: getScaledValue(5.0)),
            ),
            // Expanded(
            _submitButtonRegistration(),
            // )
          ],
        ),
      ),
    );
  }

  Widget _registerCountryForm() {
    return Container(
      width: 400,
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Country", style: _emailInputLabelStyle()),
          DropdownButton<String>(
            focusNode: focusNodes['country'],
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 20,
            isExpanded: true,
            items: widget.model.zoneList.map((Map zone) {
              return new DropdownMenuItem<String>(
                value: zone["name"], //country['code'],
                child: Text(
                  zone['name'],
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            value: _country,
            hint: Text(
              "Select country",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            style: _emailTextFormStyle(),
            onChanged: (value) {
              setState(() {
                _country = widget.model.zoneList
                    .firstWhere((element) => element["name"] == value)["name"];
                _userData['country'] = widget.model.zoneList
                    .firstWhere((element) => element["name"] == value)["zone"];
                _userData['currency'] = widget.model.zoneList.firstWhere(
                    (element) => element["name"] == value)["currency"];
                _currency = widget.model.zoneList.firstWhere(
                    (element) => element["name"] == value)["currency"];
              });
            },
          ),
          SizedBox(height: getScaledValue(3.0)),
          Text("Currency", style: _emailLabelStyle()),
          DropdownButton<String>(
            focusNode: focusNodes['currency'],
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 20,
            isExpanded: true,
            items: widget.model.zoneList.map((Map zone) {
              return new DropdownMenuItem<String>(
                value: zone["name"],
                child: Text(
                  "${zone["name"]} (${zone["currency"]})",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            value: _country,
            hint: Text(
              "Select currency",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            style: _emailInputLabelStyle(),
            onChanged: (value) {
              return false;
            },
          ),
          SizedBox(
            height: getScaledValue(5),
          ),
          Text(
            '*You can always view your investments in dollar by changing the currency from settings later',
            style: bodyText1,
          ),
        ],
      ),
    );
  }

  TextStyle bodyText1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xff989898),
  );

  TextStyle bodyText3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: ScreenUtil().setSp(0.25),
    color: Color(0xffa4a4a4),
  );

  /**
   * Registration2 End
   */

  setPasscodeAction() {
    setState(() {
      if (formAction == "passcode") {
        formAction = "confirmPasscode";
        _userData['confirmPasscode'] = "";
        _controller['passcode'].clear();
        _controller['confirmPasscode'].clear();
        focusNodes['confirmPasscode'].requestFocus();
      } else if (formAction == "confirmPasscode") {
        formAction = "registration";
        _controller['passcode'].clear();
        _controller['confirmPasscode'].clear();
      }
    });
  }

  Widget _submitButtonRegistration() {
    if (_currency == null) {
      return Container();
    }

    return Container(
      width: 150,
      child: ElevatedButton(
        style: qfButtonStyle(
          ph: 0.0,
          pv: 0.0,
          br: 5.0,
          tc: Colors.white,
        ),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 40,
          decoration: _loginButtonDecoration(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: ScreenUtil().setHeight(40),
            ),
            alignment: Alignment.center,
            child: Text(
              "Submit",
              style: _loginTextLabelStyle(),
            ),
          ),
        ),
        onPressed: () {
          formResponseRegistration(widget.model);
        },
      ),
    );
  }

  void formResponse(MainModel model) async {
    _loginKey.currentState.save();
    Map<String, dynamic> responseData =
        await model.verifyEmail(context, _emailValue);

    if (responseData['status']) {
      await _analyticsAddLoginEvent();

      if (responseData['response']['setPasscode'] == true) {
        widget.model.registrationSetPasscode = true;
        Navigator.pushReplacementNamed(context, '/setPasscode/false');
      } else if (responseData['response']['setPasscode'] == false) {
        widget.model.loginVerifyPasscode = true;
        Navigator.pushReplacementNamed(context, '/verifyPasscode');
      }
    } else {
      setState(() {
        formAction = "passcode";
      });
      //showAlertDialogBox(context, 'Error!', 'start registration');
    }
  }

  void formResponseRegistration(MainModel model) async {
    Map<String, dynamic> responseData =
        await model.register(_userData, _fcmToken);
    if (responseData['status']) {
      await _analyticsAddRegEvent();
      Navigator.pushReplacementNamed(context, '/home_new');
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }
}
