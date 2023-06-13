import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('ZoneSelectorPage');

class ZoneSelectorPage extends StatefulWidget {
  final MainModel model;

  ZoneSelectorPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ZoneSelectorPageState();
  }
}

class _ZoneSelectorPageState extends State<ZoneSelectorPage> {
  bool _loading = false;

  List<Map<String, dynamic>> _zones;

  List<String> _selectedZones;

  Map customerSettings = {};

  void initState() {
    super.initState();
    setSelectedZone();

    customerSettings["default_zone"] =
        (widget.model.userSettings['default_zone'] != "" ||
                widget.model.userSettings['default_zone'] != null
            ? widget.model.userSettings['default_zone']
            : "in");

    String defaultZone = customerSettings["default_zone"];
    _selectedZones = defaultZone.split('_');
  }

  void setSelectedZone() async {
    setState(() {
      customerSettings['default_zone'] =
          widget.model.userSettings['default_zone'];
    });
  }

  AppBar _changeAppBarPage() {
    return AppBar(
        //centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
        title: Text(languageText('text_change_zone'),
            style: TextStyle(color: Colors.white, fontSize: 15.0)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _changeAppBarPage(),
        body: Container(
            //height: 500.0,
            alignment: Alignment.center,
            child: _buildBody()));
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      Map zones = {
        "in": {'name': 'India', 'value': 'in', 'icon': 'assets/flag/in.png'},
        "sg": {
          'name': 'Singapore',
          'value': 'sg',
          'icon': 'assets/flag/sg.png'
        },
        "us": {'name': 'USA', 'value': 'us', 'icon': 'assets/flag/us.png'},
      };
      _zones = [];

      widget.model.userSettings['allowed_zones']
          .forEach((zone) => _zones.add(zones[zone]));

      return mainContainer(
        context: context,
        containerColor: Colors.white,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(child: _buildBodyTextChangePage()),
            Expanded(child: _zoneList()),
            Container(
                margin: EdgeInsets.only(bottom: 20.0), child: _submitButton()),
          ],
        ),
      );
    }
  }

  Widget _buildBodyTextChangePage() {
    return Container(
      margin: EdgeInsets.only(bottom: 50.0),
      alignment: Alignment.bottomCenter,
      child: Text(
        languageText('text_change_zone'),
        style: TextStyle(color: Colors.grey, fontSize: 13.0),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
        /* minWidth: 100.0, */
        //height: 40.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: RaisedButton(
            disabledColor: Colors.grey,
            padding: EdgeInsets.fromLTRB(90.0, 15.0, 90.0, 15.0),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0)),
            textColor: Colors.white,
            child: widgetButtonText(languageText('text_change_zone_button')),
            onPressed:
                _selectedZones.length == 0 ? null : () => _submitZone()));
  }

  Future _submitZone() async {
    setState(() {
      _loading = true;
    });
    await widget.model.updateCustomerSettings(customerSettings);
    await widget.model.reloadData();

    //widget.model.setLoader(true);

    setState(() {
      _loading = false;
    });

    Navigator.pushReplacementNamed(context, '/home_new');
  }

  Widget _zoneList() {
    return ListView.builder(
        itemCount: _zones.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> zone = _zones[index];
          return GestureDetector(
              onTap: () {
                setState(() {
                  //customerSettings['default_zone'] = zone['value'];
                  _updateZoneString(zone['value']);
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      (index == 0) ? Divider(height: 5.0) : Container(),
                      _buildZoneRow(zone),
                      Divider(height: 5.0),
                    ],
                  )));
        });
  }

  Widget _buildZoneRow(zone) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 30.0,
            child: Image.asset(zone['icon']),
          ),
          SizedBox(
            width: 10.0,
          ),
          Container(
            width: 80.0,
            child: Text(
              zone['name'],
              style: TextStyle(
                fontWeight: (_selectedZones.contains(zone['value'])
                    ? FontWeight.bold
                    : FontWeight.normal),
              ),
            ),
          ),
          Container(
              width: 20.0,
              //child: (customerSettings['default_zone'] == zone['value'] ? Image.asset('assets/images/tick.png') : Container() )
              child: (_selectedZones.contains(zone['value'])
                  ? Image.asset('assets/images/tick.png')
                  : Container())),
        ],
      ),
    );
  }

  _updateZoneString(String zone) {
    if (_selectedZones.contains(zone)) {
      _selectedZones.remove(zone);
    } else {
      _selectedZones.add(zone);
    }
    customerSettings['default_zone'] = _selectedZones.join('_');
  }
}
