import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/validator.dart';
import 'package:qfinr/widgets/styles.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('SetPasscodePage');

class SetPasscodePageSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final bool setPasscode;
  final bool registrationFlag;

  final bool isBiometric;

  SetPasscodePageSmall(this.model, this.setPasscode, this.isBiometric,
      {this.analytics, this.observer, this.registrationFlag = false});

  @override
  State<StatefulWidget> createState() {
    return _SetPasscodePageState();
  }
}

class _SetPasscodePageState extends State<SetPasscodePageSmall> {
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
  }

  Widget _passcodeForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
      child: TextFormField(
        focusNode: passcodeFocusNode['passcode'],
        controller: textEditingController['passcode'],
        obscureText: true,
        validator: (value) {
          if (Validator.validateStructure(value)) {
            return "A minimum 8 characters password contains a combination of an uppercase and a lowercase letter and a number and a special character.";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: passcodeFocusNode['passcode'].hasFocus
              ? inputLabelFocusStyle
              : inputLabelStyle,
        ),
        keyboardType: TextInputType.text,
        style: inputFieldStyle,
        onChanged: (value) {
          _passcode = value;
        },
      ),
    );
  }

  Widget _passcodeFormConfirm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
      child: TextFormField(
        focusNode: passcodeFocusNode['passcodeConfirm'],
        controller: textEditingController['passcodeConfirm'],
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          labelStyle: passcodeFocusNode['passcodeConfirm'].hasFocus
              ? inputLabelFocusStyle
              : inputLabelStyle,
        ),
        keyboardType: TextInputType.text,
        style: inputFieldStyle,
        onChanged: (value) {
          _passcodeConfirm = value;
        },
      ),
    );
  }

  Widget _submitButton() {
    if (page == "passcode") {
      return gradientButton(
        context: context,
        caption: "Continue",
        onPressFunction: () {
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
      );
    } else {
      return gradientButton(
        context: context,
        caption: "Set Password",
        onPressFunction: () {
          setState(() {
            if (_passcode == _passcodeConfirm) {
              errorMessage = "";
              formResponse(widget.model);
            } else {
              errorMessage = "Password Mismatch";
            }
          });
        },
      );
    }
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
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(360, 740),
    );

    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Colors.white,

          /// Theme.of(context).primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

          iconTheme: IconThemeData(color: Theme.of(context).buttonColor),
          // Colors.white), //
          leading: page != "passcode"
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      page = "passcode";
                      _passcode = "";
                      _passcodeConfirm = "";
                      textEditingController['passcode'].clear();
                      textEditingController['passcodeConfirm'].clear();
                      passcodeFocusNode['passcode'].requestFocus();
                    });
                  },
                )
              : emptyWidget,
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
    return Container(
      child: Flex(
        direction: Axis.vertical,
        //shrinkWrap: true,
        children: <Widget>[
          Expanded(
            child: page == "passcode"
                ? Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: getScaledValue(10.0)),
                        alignment: Alignment.centerLeft,
                        child: Text('Set a password', style: headline1),
                      ),
                      SizedBox(height: getScaledValue(6.0)),
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: getScaledValue(10.0)),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'create a passcode for ease of access on\nmultiple devices',
                            style: footerText1,
                          )),
                      SizedBox(height: getScaledValue(63.0)),
                      _passcodeForm(),
                      SizedBox(height: getScaledValue(10.0)),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          errorMessage,
                          style: inputError,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: getScaledValue(10.0)),
                        alignment: Alignment.centerLeft,
                        child: Text('Confirm password', style: headline1),
                      ),
                      SizedBox(height: getScaledValue(6.0)),
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: getScaledValue(10.0)),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '',
                            style: footerText1,
                          )),
                      SizedBox(height: getScaledValue(63.0)),
                      _passcodeFormConfirm(),
                      SizedBox(height: getScaledValue(10.0)),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          errorMessage,
                          style: inputError,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
          ),
          _submitButton(),

          /* !widget.setPasscode ? FlatButton(
						child: widgetFlatButton("Change User", TextAlign.right),
						onPressed: () {
							widget.model.logout();
							Navigator.pop(context);
							Navigator.pushReplacementNamed(context, '/');
						},
					) : Container(), */
        ],
      ),
    );
  }
}
