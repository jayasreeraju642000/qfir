import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/pages/login/login_style.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/utils/spacer_widget.dart';
import 'package:qfinr/utils/validator.dart';
import 'package:qfinr/widgets/styles.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('SetPasscodePage');

class SetPasscodePageLarge extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;
  final bool registrationFlag;

  final bool isBiometric;

  SetPasscodePageLarge(this.model, this.setPasscode, this.isBiometric,
      {this.analytics, this.observer, this.registrationFlag = false});

  @override
  State<StatefulWidget> createState() {
    return _SetPasscodePageState();
  }
}

class _SetPasscodePageState extends State<SetPasscodePageLarge> {
  String _passcode = "";
  String _passcodeConfirm = "";
  String _fcmToken;
  String errorMessage = "";
  String page = "passcode";

  Map<String, FocusNode> passcodeFocusNode = {
    "passcode": new FocusNode(),
    "passcodeConfirm": new FocusNode(),
  };
  FocusNode passcodeConfirmFocusNode = new FocusNode();

  Map<String, TextEditingController> textEditingController = {
    'passcode': new TextEditingController(),
    'passcodeConfirm': new TextEditingController(),
  };

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

    widget.model.setLoader(false);
  }

  confirmPasscode() {
    setState(() {
      page = "confirmPasscode";
      //passcodeFocusNode['passcodeConfirm'].nextFocus();
      //passcodeFocusNode['passcodeConfirm'].requestFocus();
      _passcodeConfirm = "";
      textEditingController['passcode'].clear();
      textEditingController['passcodeConfirm'].clear();
      //passcodeConfirmFocusNode.requestFocus();
    });
  }

  void formResponse(MainModel model) async {
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
        Navigator.pushReplacementNamed(
            context, '/setting/SettingsForcePasswordPage');
      } else {
        Navigator.pushReplacementNamed(context, '/home_new');
      }
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context,
    //     designSize: Size(MediaQuery.of(context).size.width,
    //         MediaQuery.of(context).size.height),
    //     allowFontScaling: true);
    return Scaffold(
        body: widget.model.isLoading
            ? preLoader()
            : PageWrapper(
                child: _buildBody(),
              ));
  }

  Widget _buildBody() {
    return Container(
      child: page == "passcode" ? _setPasscodeBody() : _confirmPasscodeBody(),
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
        _randomImageList[2],
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
            ],
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
        focusNode: passcodeFocusNode['passcode'],
        controller: textEditingController['passcode'],
        obscureText: true,
        autofocus: true,
        validator: (value) {
          if (Validator.validateStructure(value)) {
            return "A minimum 8 characters password contains a combination of an uppercase and a lowercase letter and a number and a special character.";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: passcodeFocusNode['passcode'].hasFocus
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          fontFamily: 'nunito',
          color: Colors.black,
        ),
        onChanged: (value) {
          _passcode = value;
        },
      ),
    );
  }

  _rightSideSetPasscodeContinueButton() {
    if (page == "passcode") {
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
              if (Validator.validateStructure(_passcode)) {
                errorMessage = "";
                confirmPasscode();
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

  _loginButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff0941cc), Color(0xff0055fe)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(5.0),
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
        _randomImageList[3],
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
            ],
          ),
        ),
      ),
    );
  }

  _rightSideConfirmPasscodeHeader() {
    return Text(
      "Confirm password",
      style: LoginScreenStyle.headerStyleForLargeScreen,
    );
  }

  _rightSideConfirmPasscodeSubHeader() {
    return Text(
      "Setup a password to ensure all your data is protected",
      style: subTitleTextStyle,
    );
  }

  Widget _rightSideConfirmPasswordForm() {
    return Container(
      width: 400,
      child: TextFormField(
        focusNode: passcodeFocusNode['passcodeConfirm'],
        controller: textEditingController['passcodeConfirm'],
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'nunito',
            letterSpacing: 0.5,
            color: Colors.grey,
          ),
        ),
        keyboardType: TextInputType.text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          fontFamily: 'nunito',
          color: Colors.black,
        ),
        onChanged: (value) {
          _passcodeConfirm = value;
        },
      ),
    );
  }

  _rightSideConfirmPasscodeContinueButton() {
    if (page == "confirmPasscode") {
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
                "Set password",
                style: _loginTextLabelStyle(),
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              if (_passcodeConfirm != null && _passcode == _passcodeConfirm) {
                errorMessage = "";
                formResponse(widget.model);
              } else {
                errorMessage = "Password mismatch!";
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
}
