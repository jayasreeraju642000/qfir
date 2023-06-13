import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('RegisterPage');

class RegisterPage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  RegisterPage(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  String _nameValue;
  String _emailValue;
  String _passwordValue;
  String _referenceCode;
  String _fcmToken;
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
  }

  Widget _skipButton() {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      direction: Axis.horizontal,
      children: <Widget>[
        SizedBox(
          width: 80.0,
          child: TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
            ),
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.end,
              direction: Axis.horizontal,
              children: <Widget>[
                Text(
                  languageText('text_skip'),
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.normal),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ],
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home_new');
            },
          ),
        )
      ],
    );
  }

  Widget _socialLogin() {
    return Container(
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: Colors.grey[700],
                    style: BorderStyle.solid,
                    width: 1.0),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
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
                  ),
                ],
              ),
              onPressed: () {
                socialResponse('facebook');
              },
            ),
            SizedBox(width: 10.0),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: Colors.grey[700],
                    style: BorderStyle.solid,
                    width: 1.0),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
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
              },
            ),
          ],
        ));
  }

  Widget _registerForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  labelText: languageText('text_name') + '*',
                  icon: Icon(
                    Icons.account_box,
                    color: Colors.grey[500],
                    size: 20.0,
                  ),
                  labelStyle:
                      TextStyle(color: Colors.grey[500], fontSize: 14.0)),
              keyboardType: TextInputType.text,
              onChanged: (String value) {
                setState(() {
                  _nameValue = value;
                });
              },
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            SizedBox(height: 10.0),
            TextField(
              decoration: InputDecoration(
                  labelText: languageText('text_email') + '*',
                  icon: Icon(
                    Icons.email,
                    color: Colors.grey[500],
                    size: 20.0,
                  ),
                  labelStyle:
                      TextStyle(color: Colors.grey[500], fontSize: 14.0)),
              keyboardType: TextInputType.emailAddress,
              onChanged: (String value) {
                setState(() {
                  _emailValue = value;
                });
              },
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
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
            TextField(
              decoration: InputDecoration(
                  labelText: 'Reference Code *',
                  icon: Icon(
                    Icons.textsms,
                    color: Colors.grey[500],
                    size: 20.0,
                  ),
                  labelStyle:
                      TextStyle(color: Colors.grey[500], fontSize: 14.0)),
              keyboardType: TextInputType.emailAddress,
              onChanged: (String value) {
                setState(() {
                  _referenceCode = value;
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
              textStyle: TextStyle(
                color: Colors.white,
              )),
          child: widgetButtonText(languageText('text_signup')),
          onPressed: () {
            formResponse(model);
          },
        ),
      );
    });
  }

  void formResponse(MainModel model) async {
    Map<String, dynamic> responseData = await model.register({
      'first_name': _nameValue,
      'email_id': _emailValue,
      'password': _passwordValue,
      'ref_code': _referenceCode
    }, _fcmToken);

    if (responseData['status']) {
      Navigator.pushReplacementNamed(context, '/home_new');
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  void socialResponse(String socialType) async {
    Map<String, dynamic> responseData;
    if (socialType == "facebook") {
      //responseData = await widget.model.facebookLogin(_fcmToken);
    } else if (socialType == "google") {
      //responseData = await widget.model.googleLogin(_fcmToken);
    }

    if (responseData['status']) {
      widget.model.fetchBaskets();
      widget.model.fetchMFBaskets();
      widget.model.fetchMIBaskets(true);
      Navigator.pushReplacementNamed(context, '/home_new');
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
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
              'Already have an account? ',
              style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF0A0B21),
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                ' Sign In',
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
                    text: "By signing up you agree to our ",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Theme.of(context).primaryColor,
          //,Colors.white, //Color(0xFFE7EDF8), //
          iconTheme: IconThemeData(color: Colors.white),
          //Theme.of(context).primaryColor),
          actions: <Widget>[_skipButton()],
          title: Image.asset(
            'assets/images/logo_white.png',
            fit: BoxFit.fill,
            height: 25.0,
          ),
          centerTitle: true,
        ),
        body: widget.model.isLoading
            ? preLoader()
            : mainContainer(
                containerColor: Colors.white,
                context: context,
                child: _buildBody()));
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
        SizedBox(height: 30.0),
        Text(
          languageText('text_form_email'),
          style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.0),
        _registerForm(),
        SizedBox(
          height: 10.0,
        ),
        _policyTerms(),
        SizedBox(height: 10.0),
        _submitButton(),
        SizedBox(
          height: 30.0,
        ),
        _switchAction(),
      ],
    );
  }
}
