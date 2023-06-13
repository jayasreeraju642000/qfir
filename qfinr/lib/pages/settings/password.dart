import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('SettingsPasswordPage');

class SettingsPasswordPage extends StatefulWidget {
  MainModel model;

  bool forcePassword;

  SettingsPasswordPage(this.model, {this.forcePassword = false});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPasswordPageState();
  }
}

class _SettingsPasswordPageState extends State<SettingsPasswordPage> {
  bool _loading = false;

  Map passwordData = {
    "old_password": "",
    "new_password": "",
    "confirm_password": "",
  };

  bool _oldPasswordRequired = true;

  void initState() {
    super.initState();

    loadSettings();
  }

  Future loadSettings() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });

      Map verifyPassword = await widget.model.verifyPassword();

      log.d('verify Password');
      log.d(verifyPassword);

      if (verifyPassword['requiredOldPassword'] == false) {
        _oldPasswordRequired = false;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  AppBar _startAppBarPage() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white, //Color(0xFFE7EDF8), //
      /* title: new Image.asset(
				'assets/images/logo_white.png',
				fit: BoxFit.fill,
				height: 25.0,
			), */
      actions: <Widget>[
        //widget.forcePassword ? _skipButton() : emptyWidget
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (_startAppBarPage()),
        body: Container(alignment: Alignment.center, child: _buildBody()));
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      return mainContainer(
          context: context,
          paddingTop: 20.0,
          paddingLeft: 10.0,
          paddingRight: 10.0,
          containerColor: Colors.white,
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    _changePasswordForm(),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: _submitButton()),
            ],
          ));
    }
  }

  Widget _changePasswordForm() {
    return Container(
        child: Flex(
      direction: Axis.vertical,
      children: <Widget>[
        _buildTextField(
            context, "Current password", 'old_password', 'changePassword', '',
            fieldRequired: _oldPasswordRequired, obscure: true),
        _buildTextField(
            context, "New password", 'new_password', 'changePassword', '',
            obscure: true),
        _buildTextField(context, "Confirm password", 'confirm_password',
            'changePassword', '',
            obscure: true),
      ],
    ));
  }

  TextInputType keyboardType(type) {
    if (type == "number") {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  Widget _buildTextField(BuildContext context, String labelText, String key,
      String type, String defaultValue,
      {String inputType,
      String suffix,
      bool fieldRequired = true,
      bool obscure = false}) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14.0,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 5.0,
        ),
        TextField(
          enabled: fieldRequired,
          obscureText: obscure,
          keyboardType: keyboardType(inputType),
          /* controller: initialValue(defaultValue), */
          decoration: InputDecoration(
            /* labelText: labelText, labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0), */
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: defaultValue,
            suffixText: suffix,
          ),

          /* obscureText: true, */

          onChanged: (String value) {
            setState(() {
              if (type == "changePassword") {
                passwordData[key] = value;
              }
            });
          },
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
        ),
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _submitButton() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(90.0, 15.0, 90.0, 15.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          textColor: Colors.white,
          child: widgetButtonText("Submit"),
          onPressed: () async {
            setState(() {
              _loading = true;
            });
            Map responseData = await widget.model.changePassword(passwordData);
            if (responseData['status']) {
              showAlertDialogBox(context, 'Updated!', responseData['response']);
              _oldPasswordRequired = true;

              if (widget.forcePassword) {
                Navigator.pushReplacementNamed(context, '/home_new');
              }
            } else {
              showAlertDialogBox(context, 'Error!', responseData['response']);
            }
            setState(() {
              _loading = false;
            });
          },
        ));
  }
}
