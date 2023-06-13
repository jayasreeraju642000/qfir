import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('SettingsPage');

class SettingsPage extends StatefulWidget {
  MainModel model;

  SettingsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = false;

  List<String> switchOptions = ["On", "Off"];

  Map customerSettings = {
    "notification": "1",
  };
  String selectedSwitchOption = "On";

  List<Map> _settings = [
    {
      'name': 'Profile',
      'icon': 'assets/icon/icon_profile.png',
      'description': '',
      'route': '/setting/SettingsProfilePage'
    },
    {
      'name': 'Language',
      'icon': 'assets/icon/icon_language.png',
      'description': '',
      'route': '/languageSelector'
    },
    {
      'name': 'Preferred Currency',
      'icon': 'assets/icon/icon_currency.png',
      'description': '',
      'route': '/setting/SettingsCurrencyPage'
    },
    {
      'name': 'Notification',
      'icon': 'assets/icon/icon_notification.png',
      'description': '',
      'route': '/setting/SettingsNotificationPage'
    },
    {
      'name': 'Biometric / Face ID',
      'icon': 'assets/icon/icon_biometric.png',
      'description': '',
      'route': '/setting/SettingsBiometricPage'
    },
    {
      'name': 'Password',
      'icon': 'assets/icon/icon_password.png',
      'description': '',
      'route': '/setting/SettingsPasswordPage'
    },
  ];

  void initState() {
    super.initState();

    loadSettings();
  }

  Future loadSettings() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });

      Map customerSettingsResponse = await widget.model.getCustomerSettings();
      customerSettings = customerSettingsResponse['response'];

      log.d(customerSettings);

      setState(() {
        _loading = false;
      });
    }
  }

  AppBar _startAppBarPage() {
    return AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
        title: new Image.asset(
          'assets/images/logo_white.png',
          fit: BoxFit.fill,
          height: 25.0,
        ));
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
      return mainContainer(context: context, child: _buildSettingList());
    }
  }

  Widget _buildSettingList() {
    return Container(
        child: ListView.builder(
            itemCount: _settings.length,
            itemBuilder: (context, index) {
              Map _settingData = _settings[index];
              return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, _settingData['route']);
                  },
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: _settingRow(_settingData)));
            }));
  }

  Widget _settingRow(Map settingData) {
    return Card(
        color: Colors.white,
        child: Container(
            child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5.0),
                child: Image.asset(
                  settingData['icon'],
                  fit: BoxFit.contain,
                  width: 60.0,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              settingData['name'],
                              softWrap: true,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                      child: Text(
                        settingData['description'],
                        /* overflow: TextOverflow.clip,
													softWrap: true, */
                        /* textAlign: TextAlign.left, */

                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ])));
  }
}
