import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('ForgotPasswordPage');

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordPageState();
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _loading = false;

  String _emailForgotValue;

  Widget _forgotPasswordForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  labelText: 'Email address*',
                  icon: Icon(
                    Icons.email,
                    color: Colors.grey[500],
                    size: 20.0,
                  ),
                  labelStyle:
                      TextStyle(color: Colors.grey[500], fontSize: 14.0)),
              keyboardType: TextInputType.emailAddress,
              onChanged: (String value) {
                _emailForgotValue = value;
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
          child: widgetButtonText('Reset Password'),
          onPressed: () {
            formResponse(model);
          },
        ),
      );
    });
  }

  void formResponse(MainModel model) async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> responseData =
        await model.forgotPassword(context, _emailForgotValue);

    setState(() {
      _loading = false;
    });
    if (responseData['status']) {
      showAlertDialogBox(context, 'Password Sent!', responseData['response']);
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
          title: Image.asset(
            'assets/images/logo_white.png',
            fit: BoxFit.fill,
            height: 25.0,
          ),
          centerTitle: true,
        ),
        body: _loading
            ? preLoader()
            : mainContainer(
                containerColor: Colors.white,
                context: context,
                child: _buildBody()));
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        SizedBox(height: 70.0),
        Text(
          '- New password will be send to your registered email address -',
          style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 50.0,
        ),
        _forgotPasswordForm(),
        SizedBox(
          height: 10.0,
        ),
        _submitButton(),
      ],
    );
  }
}
