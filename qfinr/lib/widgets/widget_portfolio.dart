import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('WidgetPortfolio');

class WidgetPortfolio extends StatefulWidget {
  MainModel model;

  bool showPortfolio = false;
  bool showRiskProfile = false;
  String fundType = "all"; // all, fund, stock

  WidgetPortfolio(this.model,
      {this.showPortfolio, this.showRiskProfile, this.fundType});

  @override
  State<StatefulWidget> createState() {
    return _WidgetPortfolioState();
  }
}

class _WidgetPortfolioState extends State<WidgetPortfolio> {
  Widget _progressHUD;
  bool _loading = false;

  Map<String, dynamic> _selectedSuggestion = null;
  String _quantity = null;

  String pathPDF = "";

  TextEditingController _searchTxt = new TextEditingController();
  TextEditingController _quantityTxt = new TextEditingController();

  List<Map<String, dynamic>> riskProfiles = [
    {'key': 'conservative', 'value': 'Conservative'},
    {'key': 'm_conservative', 'value': 'Moderate Conservative'},
    {'key': 'moderate', 'value': 'Moderate'},
    {'key': 's_aggressive', 'value': 'Moderate Aggressive'},
    {'key': 'aggressive', 'value': 'Aggressive'},
  ];

  String getRiskProfile(String key) {
    String returnValue = "";
    riskProfiles.forEach((Map riskProfile) {
      if (riskProfile['key'] == key) {
        returnValue = riskProfile['value'];
      }
    });
    return returnValue;
  }

  List _tmpUserPortfolios = [];

  @override
  void initState() {
    super.initState();

    _tmpUserPortfolios = new List.from(widget.model.newUserPortfolios);

    _progressHUD = new Center(
      child: new CircularProgressIndicator(),
    );

    _progressHUD = Flex(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      direction: Axis.vertical,
      children: <Widget>[
        Center(
            child: Image.asset(
          "assets/preloader.gif",
          width: 50.0,
        )),
      ],
    );

    //loadFormData();
  }

  @override
  void dispose() {
    // log.d("Back To old Screen");

    // log.d('newUserPortfolios');
    // log.d(widget.model.newUserPortfolios);

    // log.d('_tmpUserPortfolios');
    // log.d(_tmpUserPortfolios);

    if (listEquals(_tmpUserPortfolios, widget.model.newUserPortfolios) !=
        true) {
      log.d('mismatch list');
    } else {
      log.d('matched list');
    }
    super.dispose();
  }

  Future<bool> _exitApp(BuildContext context) {
    if (listEquals(_tmpUserPortfolios, widget.model.newUserPortfolios) !=
        true) {
      return showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('You have\'t saved your portfolios?'),
                  content: Text('Are you sure you want to exit?'),
                  actions: <Widget>[
                    TextButton(
                      style: qfButtonStyle0,
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('No'),
                    ),
                    TextButton(
                      style: qfButtonStyle0,
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Yes'),
                    ),
                  ],
                );
              }) ??
          false;
    } else {
      log.d('matched list');
      Navigator.of(context).pop(true);
    }
  }

  Future loadFormData() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });

      Map formData = await widget.model.getFormData('portfolio_analyzer_form_' +
          widget.model.userSettings['default_zone']);
      Map riskProfile = await widget.model.getFormData('risk_profiler');

      // log.d(formData);
      // log.d(riskProfile);

      if (formData['status']) {
        //_listPortfolio = json.decode(formData['response']['form_value']['portfolioData']);
      }

      if (riskProfile['status']) {
        //_userData['risk_profile'] = riskProfile['response']['form_value'];
      }

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
          if (_loading) {
            return _progressHUD;
          } else {
            return _buildBodyContent(); //_autocompleteTextField(); //_buildBodyContent();

          }
        }));
  }

  Widget _buildBodyContent() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        width: MediaQuery.of(context).size.width,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            _autocompleteTextField(),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _quantityBox()),
                _buttonAdd(),
              ],
            ),
            Divider(
              height: 50.0,
            ),
            Expanded(child: _buildPortfolioList()),
            widget.showRiskProfile
                ? _buildSelectField(context, "Investing Style", "risk_profile",
                    "user", widget.model.newUserRiskProfile, "text", "")
                : emptyWidget,
          ],
        ));
  }

  Widget _autocompleteTextField() {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
          controller: _searchTxt,
          //autofocus: true,
          style: DefaultTextStyle.of(context).style.copyWith(
                /* fontStyle: FontStyle.italic, */
                fontStyle: FontStyle.normal,
                fontSize: 14.0,
                color: Colors.black,
              ),
          decoration: InputDecoration(
              icon: Icon(Icons.search),
              labelText: (widget.fundType == "all"
                  ? 'Stocks / Funds'
                  : widget.fundType.toUpperCase()),
              labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0)
              /* border: OutlineInputBorder() */
              )),
      suggestionsCallback: (pattern) async {
        if (pattern.length >= 3) {
          return await widget.model.getFundName(pattern, widget.fundType);
        }
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Text(suggestion['type']),
          title: Text(suggestion['name']),
          subtitle: Text(suggestion['core']),
        );
      },
      onSuggestionSelected: (suggestion) {
        _selectedSuggestion = suggestion;
        _searchTxt.text = suggestion['name'];
      },
    );
  }

  Widget _quantityBox() {
    return TextField(
      controller: _quantityTxt,
      decoration: InputDecoration(
          labelText: 'Units Held',
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0)),
      keyboardType: TextInputType.number,
      onChanged: (String value) {
        setState(() {
          _quantity = value;
        });
      },
      style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
    );
  }

  Widget _buttonAdd() {
    return ElevatedButton(
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: addPortfolio,
    );
  }

  addPortfolio() {
    if (_selectedSuggestion != null && _quantity != null) {
      setState(() {
        if (validateRIC(_selectedSuggestion['ric'])) {
          widget.model.newUserPortfolios.add({
            'ric': _selectedSuggestion['ric'],
            'name': _selectedSuggestion['name'],
            'asset': _selectedSuggestion['asset'],
            'type': _selectedSuggestion['type'],
            'weightage': _quantity
          });

          _selectedSuggestion = null;
          _quantity = null;

          _searchTxt.clear();
          _quantityTxt.clear();
        } else {
          showAlertDialogBox(
              context,
              'Already exists!',
              (widget.fundType == "all"
                      ? 'Stock / Fund'
                      : widget.fundType.toUpperCase()) +
                  'already selected!');
        }
      });

      // log.d(widget.model.newUserPortfolios);
    }
  }

  bool validateRIC(String ric) {
    bool found = false;
    widget.model.newUserPortfolios.forEach((portfolio) {
      // log.d('Printing portfolio');
      // log.d(portfolio['ric']);
      // log.d(ric);
      if (portfolio['ric'] == ric) {
        log.d('match found!');
        found = true;
      }
      /* log.d('each portfolio');
			log.d(portfolio); */
    });
    if (found) {
      return false;
    } else {
      return true;
    }
  }

  Widget _buildPortfolioList() {
    return ListView.builder(
        itemCount: widget.model.newUserPortfolios.length,
        itemBuilder: (context, index) {
          Map portfolioData = widget.model.newUserPortfolios[index];

          return Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                      child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        portfolioData['name'],
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14.0),
                      ),
                      /* Text(portfolioData['type'] + " : " + portfolioData['asset'], textAlign: TextAlign.left,), */
                    ],
                  )),
                  Text(
                    portfolioData['weightage'],
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.model.newUserPortfolios.removeWhere(
                            (item) => item['ric'] == portfolioData['ric']);
                      });
                    },
                    child: Icon(
                      Icons.remove_circle,
                      color: Colors.redAccent,
                    ),
                  ),
                ]),
          );
        });
  }

/* 	Widget _buttonSubmit(){
		return RaisedButton(
			child: Text("Submit ", style: TextStyle(color: Colors.white),),
			onPressed: (){
				formResponse();
			}
		);
	} */

  Widget _buildSelectField(BuildContext context, String labelText, String key,
      String type, String defaultValue, String inputType, String suffix) {
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
        DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
              /*  borderRadius: , */
            ),
            child: (widget.showRiskProfile
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      items: riskProfiles.map((Map riskProfile) {
                        return DropdownMenuItem<String>(
                          value: riskProfile['key'],
                          child: Text(riskProfile['value']),
                        );
                      }).toList(),
                      hint: Text((widget.model.newUserRiskProfile != ""
                          ? getRiskProfile(widget.model.newUserRiskProfile)
                          : labelText)),
                      onChanged: (String value) {
                        setState(() {
                          widget.model.newUserRiskProfile = value;
                        });
                      },
                    ),
                  )
                : emptyWidget)),
      ],
    );
  }
}
