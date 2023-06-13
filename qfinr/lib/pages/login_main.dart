import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../widgets/widget_common.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/main_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

final log = getLogger('LoginMainPage');

class LoginMainPage extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  LoginMainPage(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _LoginMainPageeState();
  }
}

class _LoginMainPageeState extends State<LoginMainPage> {
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

    widget.model.setLoader(false);
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
    if (responseData['status']) {
      //widget.model.fetchBaskets();
      //widget.model.fetchMFBaskets();
      //widget.model.fetchMIBaskets(false);

      if (responseData['response']['setPasscode'] == true) {
        Navigator.pushReplacementNamed(context, '/setPasscode');
      } else {
        Navigator.pushReplacementNamed(context, '/verifyPasscode');
      }
      /* if(responseData['response']['force_password'] == "1"){
				Navigator.pushReplacementNamed(context, '/setting/SettingsForcePasswordPage');
			}else{
				Navigator.pushReplacementNamed(context, '/home_new');
			} */
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          backgroundColor: Colors
              .white, //Theme.of(context).primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
          iconTheme: IconThemeData(
              color: Theme.of(context)
                  .buttonColor), //Theme.of(context).primaryColor),
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
    return Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _signinButton('assets/images/icon_facebook.png',
              'Continue with Facebook', 'facebook'),
          SizedBox(height: 40.0),
          _signinButton('assets/images/icon_google.png', 'Continue with Google',
              'google'),
          SizedBox(height: 40.0),
          _signinButton('assets/images/icon_email.png',
              'Continue with other Email', 'email'),
        ],
      ),
    );
  }

  Widget _signinButton(String image, String label, String key) {
    return RaisedButton(
      color: Colors.white,
      elevation: 1,
      splashColor: Theme.of(context).buttonColor,
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            image,
            height: 26.0,
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            label,
            style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).highlightColor,
                fontWeight: FontWeight.normal),
          )
        ],
      ),
      onPressed: () {
        if (key == "facebook" || key == "google") {
          socialResponse(key);
        } else {
          Navigator.pushNamed(context, '/login');
        }
      },
    );
  }
}
