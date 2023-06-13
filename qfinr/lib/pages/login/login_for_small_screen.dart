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
import 'package:qfinr/utils/validator.dart';
import 'package:qfinr/widgets/disclaimer_alert.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final log = getLogger('LoginPage');

class LoginForSmallScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  LoginForSmallScreen(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _LoginForSmallScreenState();
  }
}

class _LoginForSmallScreenState extends State<LoginForSmallScreen> {
  String _emailValue;
  String _fcmToken;

  String formAction = "login";
  String errorMessage = "";
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

  // Map countryMap = {
  //   "in": "India",
  //   "sg": "Singapore",
  //   "us": "USA",
  // };

  // Map currencyMap = {
  //   "in": {"code": "inr", "value": "Indian Rupees (INR)"},
  //   "sg": {"code": "sgd", "value": "US Dollars (USD)"},
  //   "us": {"code": "usd", "value": "Singapore Dollars (SGD)"},
  // };

  // List<Map> countries = [
  //   {
  //     "code": "in",
  //     "country": "India",
  //     "currency": {
  //       "value": "inr",
  //       "symbol": "₹",
  //       "title": "Indian Rupees (INR)"
  //     }
  //   },
  //   {
  //     "code": "sg",
  //     "country": "Singapore",
  //     "currency": {"value": "usd", "symbol": "\$", "title": "US Dollars (USD)"}
  //   },
  //   {
  //     "code": "us",
  //     "country": "USA",
  //     "currency": {
  //       "value": "sgd",
  //       "symbol": "S\$",
  //       "title": "Singapore Dollars (SGD)"
  //     }
  //   },
  // ];

  String _country;

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

  bool _isNextButtonPressedForLogin = false;
  Map<dynamic, dynamic> response_ip_v;

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
        // log.d("\n\n\n\n\n");
        // log.d("Firebase Token :- $_fcmToken");
        // log.d("\n\n\n\n\n");
      });
    }

    if (_fcmToken == null || _fcmToken == "") {
      _fcmToken = "noToken";
    }

    widget.model.setLoader(false);

    widget.model.getZoneList();

    getIpAddress();
  }

  void getIpAddress() async {
    final ipv4 = await Ipify.ipv4();
    log.d(ipv4);

    validateIP(ipv4);
  }

  validateIP(ipv4) async {
    response_ip_v = await widget.model.validateIP(ipv4);
    // response_ip_v =
    //     await widget.model.validateIP('1.32.204.128'); // singapore ip
    if (response_ip_v['status'] == false) {
      var popuptitle = response_ip_v['popuptitle'];
      var popupbody = response_ip_v['popupbody'];

      log.d("Testing ip valid response");
      log.d(popuptitle);
      log.d(popupbody);

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
          showModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: ((BuildContext context) {
                return DisClaimDialog(popuptitle, popupbody);
              })).then((value) {
            if (value == 'Decline') {
              setState(() {
                accept_qfinr = false;
              });

              // bottomAlertBox(
              //     context: context,
              //     title: "Decline accepted",
              //     description:
              //         "You have chosen not to continue to Qfinr Web App");
            }
          });
        }
      } else {
        showModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: ((BuildContext context) {
              return DisClaimDialog(popuptitle, popupbody);
            })).then((value) {
          if (value == 'Decline') {
            setState(() {
              accept_qfinr = false;
            });

            // bottomAlertBox(
            //     context: context,
            //     title: "Decline accepted",
            //     description:
            //         "You have chosen not to continue to Qfinr Web App");
          }
        });
      }
    }
  }

  Widget _passcodeForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
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
              ? inputLabelFocusStyle
              : inputLabelStyle,
        ),
        keyboardType: TextInputType.text,
        onChanged: (String value) {
          _userData['passcode'] = value;
        },
        style: inputFieldStyle,
      ),
    );
  }

  Widget _passcodeFormConfirm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: getScaledValue(10.0)),
      child: TextFormField(
        focusNode: focusNodes['confirmPasscode'],
        controller: _controller['confirmPasscode'],
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          labelStyle: focusNodes['confirmPasscode'].hasFocus
              ? inputLabelFocusStyle
              : inputLabelStyle,
        ),
        keyboardType: TextInputType.text,
        onChanged: (String value) {
          _userData['confirmPasscode'] = value;
        },
        style: inputFieldStyle,
      ),
    );
  }

  Widget _submitPasscodeButton() {
    if (formAction == "passcode") {
      return gradientButton(
        context: context,
        caption: "Continue",
        onPressFunction: () {
          setState(() {
            if (Validator.validateStructure(_userData['passcode'])) {
              errorMessage = "";
              setPasscodeAction();
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
        caption: "Set Passcode",
        onPressFunction: () {
          setState(() {
            if (_userData['passcode'] == _userData['confirmPasscode']) {
              errorMessage = "";
              setPasscodeAction();
            } else {
              errorMessage = "Password Mismatch";
            }
          });
        },
      );
    }
  }

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

  Widget _loginForm() {
    return Form(
      key: _loginKey,
      autovalidateMode: AutovalidateMode.always,
      // autovalidate: _loginAutoValidate,
      child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Please enter your\nemail address', style: headline1),
              SizedBox(height: 53.0),
              TextFormField(
                focusNode: focusNodes['email_id'],
                controller: emailTxtController,
                validator: (value) {
                  if (_isNextButtonPressedForLogin == true) {
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value) ||
                        value.length < 2 ||
                        value.isEmpty) {
                      return "The Email id you have entered is invalid";
                    }
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Email id",
                  hintText: 'name@domain.com',
                  hintStyle: inputLabelStyle,
                  //icon: Icon(Icons.email, color: Colors.grey[500],size: 20.0,),
                  labelStyle: focusNodes['email_id'].hasFocus
                      ? inputLabelFocusStyle
                      : inputLabelStyle,
                  //errorText: loginValidate ? validateFields('email_id', _controller['email_id'].text) : null,
                  //border: UnderlineInputBorder(),
                  //OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (String value) {
                  setState(() {
                    _emailValue = value;
                    _userData['email_id'] = value;
                  });
                },
                style: inputFieldStyle,
              ),
            ],
          )),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _registrationKey,
      autovalidateMode: AutovalidateMode.always,
      // autovalidate: _registrationAutoValidate,
      child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
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
                          ? inputLabelFocusStyle
                          : inputLabelStyle),
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    setState(() {
                      _userData['first_name'] = value;
                    });
                  },
                  style: inputFieldStyle),
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
                          ? inputLabelFocusStyle
                          : inputLabelStyle),
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    setState(() {
                      _userData['last_name'] = value;
                    });
                  },
                  style: inputFieldStyle),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Container(
                      width: getScaledValue(93),
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
                                ? inputLabelFocusStyle
                                : inputLabelStyle,
                            prefix: Text("+"),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (String value) {
                            setState(() {
                              _userData['country_code'] = value;
                            });
                          },
                          style: inputFieldStyle)),
                  SizedBox(width: getScaledValue(10.5)),
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
                                ? inputLabelFocusStyle
                                : inputLabelStyle),
                        keyboardType: TextInputType.phone,
                        onChanged: (String value) {
                          setState(() {
                            _userData['mobile_number'] = value;
                          });
                        },
                        style: inputFieldStyle),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                      ? inputLabelFocusStyle
                      : inputLabelStyle,
                ),
                keyboardType: TextInputType.text,
                onChanged: (String value) {
                  setState(() {
                    _userData['referral_code'] = value;
                  });
                },
                style: inputFieldStyle,
              ),
            ],
          )),
    );
  }

  Widget _registerCountryForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Country", style: inputLabelStyle),
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
              style: inputFieldStyle,
              onChanged: (value) {
                setState(() {
                  _country = widget.model.zoneList.firstWhere(
                      (element) => element["name"] == value)["name"];
                  _userData['country'] = widget.model.zoneList.firstWhere(
                      (element) => element["name"] == value)["zone"];
                  _userData['currency'] = widget.model.zoneList.firstWhere(
                      (element) => element["name"] == value)["currency"];
                });
              },
            ),
            SizedBox(height: getScaledValue(15.0)),
            Text("Currency", style: inputLabelStyle),
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
              style: inputFieldStyle,
              onChanged: (value) {
                return false;
              },
            ),
            SizedBox(
              height: getScaledValue(35),
            ),
            Text(
              '*You can always view your investments in dollar by changing the currency from settings later',
              style: bodyText1,
            ),
          ],
        ));
  }

  Widget _submitButtonLogin() {
    return gradientButton(
        context: context,
        caption: "next",
        buttonDisabled: accept_qfinr ? false : true,
        onPressFunction: () {
          if (accept_qfinr == true) {
            setState(() {
              _isNextButtonPressedForLogin = true;
            });
            if (_loginKey.currentState.validate()) {
              formResponse(widget.model);
            }
          }
        });
  }

  Widget _submitButtonRegistration() {
    if (_country == null) {
      return Container();
    }

    return gradientButton(
        context: context,
        caption: "submit",
        onPressFunction: () => formResponseRegistration(widget.model));
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
      //widget.model.registrationSetPasscode = true;
      //Navigator.pushReplacementNamed(context, '/setPasscode/false');

      //widget.model.fetchBaskets();
      //widget.model.fetchMFBaskets();
      //widget.model.fetchMIBaskets(true);
      await _analyticsAddRegEvent();

      Navigator.pushReplacementNamed(context, '/home_new');
      //Navigator.pushNamed(context, '/setPasscode');
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context, width: 360, allowFontScaling: true);
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

    changeStatusBarColor(Colors.white);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            titleSpacing: 20.0,
            backgroundColor: Colors.white,
            leading: formAction != "login"
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        if (formAction == "passcode") {
                          formAction = "login";
                          _userData['passcode'] = "";
                          _userData['confirmPasscode'] = "";
                          _controller['passcode'].clear();
                          _controller['confirmPasscode'].clear();
                        } else if (formAction == "confirmPasscode") {
                          formAction = "passcode";
                          _userData['passcode'] = "";
                          _userData['confirmPasscode'] = "";
                          _controller['passcode'].clear();
                          _controller['confirmPasscode'].clear();
                          focusNodes['passcode'].requestFocus();
                        } else if (formAction == "registration2") {
                          formAction = "registration";
                        } else if (formAction == "registration") {
                          formAction = "passcode";
                        }
                      });
                    },
                  )
                : emptyWidget,
            iconTheme: IconThemeData(color: Theme.of(context).buttonColor),
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
                  child: _bodySelector()));
    });
  }

  Widget _bodySelector() {
    if (formAction == "passcode" || formAction == "confirmPasscode") {
      _analyticsPassCodeCurrentScreen();
      return _buildPasscode();
    } else if (formAction == "login") {
      _analyticsLoginCurrentScreen();
      return _buildBodyLogin();
    } else if (formAction == "registration") {
      _analyticsRegCurrentScreen();
      return _buildBodyRegistration();
    } else {
      return _buildBodyRegistration2();
    }
  }

  Widget _buildPasscode() {
    return Container(
      child: Flex(
        direction: Axis.vertical,
        //shrinkWrap: true,
        children: <Widget>[
          Expanded(
              child: formAction == "passcode"
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
                              'create a password for ease of access on\nmultiple devices',
                              style: footerText1,
                            )),
                        SizedBox(height: getScaledValue(63.0)),
                        _passcodeForm(),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: getScaledValue(10.0)),
                          child: Text(
                            errorMessage,
                            style: inputError,
                            textAlign: TextAlign.left,
                          ),
                        )
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
                          child: Text('Confirm passcode', style: headline1),
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
                          margin: EdgeInsets.symmetric(
                              horizontal: getScaledValue(10.0)),
                          child: Text(
                            errorMessage,
                            style: inputError,
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    )),
          _submitPasscodeButton(),
        ],
      ),
    );
  }

  Widget _buildBodyLogin() {
    return Container(
      child: Flex(
        direction: Axis.vertical,

        //shrinkWrap: true,
        children: <Widget>[
          Expanded(
              child: ListView(
            children: <Widget>[
              SizedBox(height: 30.0),
              _loginForm(),
            ],
          )),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 10.0),
            child: RichText(
              text: TextSpan(
                text: "by continuing I agree to ",
                style: bodyText2,
                children: <TextSpan>[
                  TextSpan(
                      text: "Terms & Conditions",
                      style: bodyText2.copyWith(
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchURL("https://www.qfinr.com/privacy/");
                        }),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          _submitButtonLogin()
        ],
      ),
    );
  }

  Widget _buildBodyRegistration() {
    return Container(
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
              child: ListView(
            children: <Widget>[
              SizedBox(height: 30.0),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('Few more details', style: headline1),
              ),
              SizedBox(height: 30.0),
              _registerForm()
            ],
          )),
          gradientButton(
            context: context,
            caption: "next",
            onPressFunction: () {
              if (_registrationKey.currentState.validate()) {
                setState(() {
                  _registrationKey.currentState.save();
                  formAction = "registration2";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBodyRegistration2() {
    return Container(
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          SizedBox(height: 30.0),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text('Country of Residence', style: headline1),
          ),
          SizedBox(height: 30.0),
          Expanded(
            child: _registerCountryForm(),
          ),
          Text(
            "COMING SOON IN OTHER COUNTRIES",
            style: bodyText3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setSp(17.0)),
          _submitButtonRegistration(),
        ],
      ),
    );
  }
}
