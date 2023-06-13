import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('SettingsNotificationPage');

class SettingsNotificationPage extends StatefulWidget {
  final MainModel model;

  SettingsNotificationPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _SettingsNotificationPageState();
  }
}

class _SettingsNotificationPageState extends State<SettingsNotificationPage> {
  bool _loading = false;

  List<String> switchOptions = ["On", "Off"];

  Map customerSettings = {
    "notification": "1",
  };
  String selectedSwitchOption = "On";

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
      return mainContainer(
          context: context,
          paddingTop: 20.0,
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
                    _toggleNotification(),
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

  Widget _toggleNotification() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(child: Text("Daily notification")),
        // Expanded(
        //   child: MaterialSwitch(
        //     padding:
        //         const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        //     margin: const EdgeInsets.all(5.0),
        //     selectedOption:
        //         customerSettings['notification'] == '1' ? "On" : "Off",
        //     options: switchOptions,
        //     selectedBackgroundColor: customerSettings['notification'] == "1"
        //         ? Colors.indigo
        //         : Colors.grey[800],
        //     selectedTextColor: Colors.white,
        //     onSelect: (String selectedOption) {
        //       setState(() {
        //         if (selectedOption == "On") {
        //           customerSettings['notification'] = "1";
        //         } else if (selectedOption == "Off") {
        //           customerSettings['notification'] = "2";
        //         }

        //         //widget.model.saveSettings(customerSettings);
        //       });
        //     },
        //   ),
        // ),
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
            Map responseData =
                await widget.model.updateCustomerSettings(customerSettings);

            setState(() {
              _loading = false;
            });

            if (responseData['status']) {
              Navigator.pop(context);
            }
          },
        ));
  }
}
