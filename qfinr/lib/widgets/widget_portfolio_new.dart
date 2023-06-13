import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('WidgetPortfolioNew');

class WidgetPortfolioNew extends StatefulWidget {
  MainModel model;

  bool showPortfolio = false;
  bool showRiskProfile = false;
  String fundType = "all"; // all, fund, stock

  bool managePortfolio = false;
  bool reloadData;
  bool viewPortfolio;

  String portfolioMasterID;

  Function() notifyParent;

  WidgetPortfolioNew(this.model,
      {this.showPortfolio,
      this.showRiskProfile,
      this.fundType,
      this.managePortfolio = false,
      this.portfolioMasterID = "0",
      this.reloadData = true,
      this.viewPortfolio = false,
      this.notifyParent});

  @override
  State<StatefulWidget> createState() {
    return _WidgetPortfolioNewState();
  }
}

class _WidgetPortfolioNewState extends State<WidgetPortfolioNew> {
  bool _loading = false;
  bool portfolioChanged = false;

  Map<String, dynamic> _selectedSuggestion = null;
  String _quantity = null;
  TextEditingController _searchTxt = new TextEditingController();
  TextEditingController _quantityTxt = new TextEditingController();

  TextEditingController portfolioTxt = new TextEditingController();

  final qtyFocusNode = new FocusNode();
  final autoCompleteFocusNode = new FocusNode();

  var textEditingControllers = <TextEditingController>[];

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

  Map _tmpUserPortfolios = {};

  @override
  void initState() {
    super.initState();

    loadFormData();

    if (widget.managePortfolio &&
        (widget.model.userPortfoliosData[
                widget.model.defaultPortfolioSelectorKey]['portfolios'] !=
            null)) {
      widget
          .model
          .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
              ['portfolios']
          .forEach((type, portfolioListData) {
        _tmpUserPortfolios[type] = List.from(portfolioListData);
      });
    }
    portfolioTxt.text = widget
            .model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
        ['portfolio_name'];
  }

  Future loadFormData() async {
    if (!widget.managePortfolio) {
      if (widget.reloadData) {
        if (widget.model.isUserAuthenticated) {
          setState(() {
            _loading = true;
          });
          await widget.model.getCustomerPortfolio();
          setState(() {
            _loading = false;
          });
        }

        widget.model.userPortfoliosData.forEach((key, value) {
          if (widget.model.defaultPortfolioSelectorValue == "" ||
              value['default'] == '1') {
            widget.model.defaultPortfolioSelectorKey = key;
            widget.model.defaultPortfolioSelectorValue =
                value['portfolio_name'];
          }
        });
      } else {
        widget.model.defaultPortfolioSelectorKey = widget.portfolioMasterID;
        widget.model.defaultPortfolioSelectorValue = widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolio_name'];
      }
    } else {
      if (widget.portfolioMasterID == "0" &&
          !widget.model.userPortfoliosData.containsKey("0")) {
        widget.model.userPortfoliosData["0"] = {
          'id': "0",
          'default': '0',
          'portfolio_name': '',
          'portfolios': {}
        };
      }
      widget.model.defaultPortfolioSelectorKey = widget.portfolioMasterID;
      widget.model.defaultPortfolioSelectorValue = widget.model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
          ['portfolio_name'];
    }
  }

  refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _exitApp(BuildContext context) {
    bool changeFound = false;

    if (widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios'] !=
        null) {
      widget
          .model
          .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
              ['portfolios']
          .forEach((type, portfolioListData) {
        if (_tmpUserPortfolios.containsKey(type)) {
          if (listEquals(_tmpUserPortfolios[type], portfolioListData) != true) {
            changeFound = true;
          }
        } else {
          changeFound = true;
        }
      });
    }

    if (changeFound && widget.managePortfolio) {
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
                    onPressed: () {
                      setState(() {
                        _tmpUserPortfolios.forEach((type, portfolioListData) {
                          widget.model.userPortfoliosData[widget.model
                                  .defaultPortfolioSelectorKey]['portfolios']
                              [type] = List.from(portfolioListData);
                        });
                      });
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          ) ??
          false;
    } else {
      Navigator.of(context).pop(true);
    }
    /* 	}else{
			Navigator.of(context).pop(true);
		} */
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
          if (_loading) {
            return preLoader();
          } else {
            return _buildBodyContent(); //_autocompleteTextField(); //_buildBodyContent();

          }
        }));
  }

  Widget _buildBodyContent() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).backgroundColor,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            /* widget.managePortfolio ?
                        IconButton(
                            icon: Icon(Icons.add), //, color: Color(0xFF0F52BA),),
                            onPressed: () {
                                addNewPortfolio(context);
                            },
                        )
                        :
                        emptyWidget, */

            Expanded(child: _portfolioListType()),

            /* !widget.viewPortfolio ? Flex(
						direction: Axis.horizontal,
						children: <Widget>[
							widget.showRiskProfile ? Expanded(child: _buildSelectField(context, "Investing Style", "risk_profile", "user", widget.model.newUserRiskProfile, "text", "") ) : emptyWidget,
							widget.showRiskProfile ? SizedBox(width: 10.0) : emptyWidget,
							Expanded(
								child:
									),
						],
					) : emptyWidget */
          ],
        ));
  }

  Widget _autocompleteTextField() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        color: Colors.white,
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              focusNode: autoCompleteFocusNode,
              controller: _searchTxt,
              //autofocus: true,
              style: DefaultTextStyle.of(context).style.copyWith(
                    /* fontStyle: FontStyle.italic, */
                    fontStyle: FontStyle.normal,
                    fontSize: 13.0,
                    color: Colors.black,
                    height: 0,
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
          onSuggestionSelected: (suggestion) async {
            _selectedSuggestion = suggestion;
            _searchTxt.text = suggestion['name'];

            FocusScope.of(context).requestFocus(qtyFocusNode);
            //addPortfolio();
          },
        ));
  }

  addPortfolio() {
    if (_selectedSuggestion != null && _quantity != null) {
      setState(() {
        if (validateRIC(
            _selectedSuggestion['ric'], _selectedSuggestion['type'])) {
          if (!widget
              .model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
                  ['portfolios']
              .containsKey(_selectedSuggestion['type'])) {
            // log.d(widget.model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]['portfolios']);
            widget.model.userPortfoliosData[
                    widget.model.defaultPortfolioSelectorKey]['portfolios']
                [_selectedSuggestion['type']] = [];
            // log.d(widget.model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]['portfolios']);
          }

          if (widget.model.userPortfoliosData[
                  widget.model.defaultPortfolioSelectorKey]['portfolios'] ==
              null) {
            widget.model.userPortfoliosData[
                widget.model.defaultPortfolioSelectorKey]['portfolios'] = {};
          }
          widget
              .model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
                  ['portfolios'][_selectedSuggestion['type']]
              .add({
            'zone': widget.model.userSettings['default_zone'],
            'ric': _selectedSuggestion['ric'],
            'name': _selectedSuggestion['name'],
            'asset': _selectedSuggestion['asset'],
            'type': _selectedSuggestion['type'],
            'weightage': _quantity,
          });

          _selectedSuggestion = null;
          _quantity = null;

          _searchTxt.clear();
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

      portfolioChanged = true;
      Navigator.pop(context);
    }
  }

  bool validateRIC(String ric, String type) {
    bool found = false;
    if (widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios'] ==
        null) {
      widget.model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
          ['portfolios'] = {};
    }

    if (!widget
        .model
        .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios']
        .containsKey(type)) {
      return true;
    }
    widget
        .model
        .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios'][type]
        .forEach((portfolio) {
      if (portfolio['ric'] == ric) {
        // log.d('match found!');
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

  /* portfolio list container */
  Widget _portfolioListType() {
    List<Widget> widgetBodyList = [];

    widgetBodyList.add(Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: widget.viewPortfolio
                  ? Text(
                      widget
                          .model
                          .userPortfoliosData[widget.model
                              .defaultPortfolioSelectorKey]['portfolio_name']
                          .toString(),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Color(0xff3c4257)),
                    )
                  : widget.model.userPortfoliosData != null
                      ? widget.managePortfolio
                          ? _buildTextFieldPortfolio(context, "Portfolio",
                              "portfolio", "portfolio", "", "text", "")
                          : _buildSelectFieldPortfolio(context, "Portfolio",
                              "portfolio", "portfolio", "", "text", "")
                      : emptyWidget),
          Expanded(
              child: widget.model.defaultPortfolioSelectorKey != '0' &&
                      !widget.managePortfolio
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          widget
                              .model
                              .userPortfoliosData[widget
                                  .model.defaultPortfolioSelectorKey]['value']
                              .toString(),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: Colors.grey[600]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            widget.model.userPortfoliosData[widget
                                            .model.defaultPortfolioSelectorKey]
                                        ['change_sign'] ==
                                    "up"
                                ? Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                    size: 16.0,
                                  )
                                : widget.model.userPortfoliosData[widget.model
                                                .defaultPortfolioSelectorKey]
                                            ['change_sign'] ==
                                        "down"
                                    ? Icon(
                                        Icons.trending_down,
                                        color: Colors.red,
                                        size: 16.0,
                                      )
                                    : emptyWidget,
                            Text(
                              widget
                                      .model
                                      .userPortfoliosData[widget.model
                                              .defaultPortfolioSelectorKey]
                                          ['change']
                                      .toString() +
                                  "%",
                              style: TextStyle(
                                  color: widget.model.userPortfoliosData[widget
                                                  .model
                                                  .defaultPortfolioSelectorKey]
                                              ['change_sign'] ==
                                          "up"
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12.0), // ""1.5%""
                            )
                          ],
                        )
                      ],
                    )
                  : Container())
        ],
      ),
    ));

    widgetBodyList.add(
      DashSeparator(
        color: Colors.grey,
      ),
    );

    /* widgetBodyList.add(_autocompleteTextField()); */
    if (widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios'] !=
        null) {
      if (widget.fundType == "all") {
        if (widget
                .model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
                    ['portfolios']
                .length ==
            0) {
          widgetBodyList.add(_noPortfolio());
        } else {
          widget
              .model
              .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
                  ['portfolios']
              .forEach((type, portfolioList) => widgetBodyList
                  .add(_portfolioTypeBuilder(type, portfolioList)));
        }
      } else {
        if (widget.model.userPortfoliosData[
                    widget.model.defaultPortfolioSelectorKey]['portfolios']
                [capitalize(widget.fundType)] !=
            null) {
          widgetBodyList.add(_portfolioTypeBuilder(
              capitalize(widget.fundType),
              widget.model.userPortfoliosData[
                      widget.model.defaultPortfolioSelectorKey]['portfolios']
                  [capitalize(widget.fundType)]));
        } else {
          widgetBodyList.add(_noPortfolio());
        }
      }
    } else {
      widgetBodyList.add(_noPortfolio());
    }

    return ListView(
      children: widgetBodyList,
    );
  }

  Widget _noPortfolio() {
    return Container(
        margin: EdgeInsets.only(top: 20.0),
        alignment: Alignment.center,
        child: widget.model.isUserAuthenticated
            ? Text(
                "You haven\'t added your portfolio",
                style: Theme.of(context).textTheme.subtitle1,
              )
            : _requireLogin());
  }

  Widget _requireLogin() {
    return Container(
      //margin: EdgeInsets.only(top: 50.0),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Sign In / Sign Up to  \n add your portfolio',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(),
          Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                  child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(8.0)),
                  textColor: Colors.white,
                  child: widgetButtonText(languageText('text_signin_l')),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              )),
              Expanded(
                  child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(8.0)),
                  textColor: Colors.white,
                  child: widgetButtonText(languageText('text_signup_l')),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ))
            ],
          )
        ],
      ),
    );
  }

  Widget _portfolioTypeBuilder(String type, List _portfolioList) {
    return Container(
      margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        /* direction: Axis.vertical, */
        children: <Widget>[
          /* Text(
						type,
						style: Theme.of(context).textTheme.subtitle.copyWith(color: Theme.of(context).focusColor)
					),
					SizedBox(height: 2.0),
					DashSeparator(color: Colors.grey,), */
          widget.managePortfolio
              ? _buildPortfolioEdit(type, _portfolioList)
              : _buildPortfolioList(type, _portfolioList),
        ],
      ),
    );
  }

  Widget _buildPortfolioList(String type, List _portfolioList) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: _portfolioList.length,
        itemBuilder: (context, index) {
          Map portfolioData = _portfolioList[index];

          Widget container = containerCard(
              context: context,
              child: Flex(
                crossAxisAlignment: CrossAxisAlignment.start,
                direction: Axis.vertical,
                children: <Widget>[
                  Text(portfolioData['name'],
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(color: Color(0xff3c4257))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          widgetBubble(
                              title: portfolioData['zone'].toUpperCase(),
                              bgColor: Color(0xfff6f9fc),
                              textColor: Color(0xff6b7c93),
                              leftMargin: 0),
                          widgetBubble(
                              title: type.toUpperCase(),
                              bgColor: Color(0xfff6f9fc),
                              textColor: Color(0xff6b7c93),
                              leftMargin: 0),
                        ],
                      ),
                      Text(portfolioData['value'].toString()),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text(portfolioData['weightage'] + " units")),
                      Row(
                        children: <Widget>[
                          portfolioData['change_sign'] == "up"
                              ? Icon(
                                  Icons.trending_up,
                                  color: Colors.green,
                                  size: 16.0,
                                )
                              : portfolioData['change_sign'] == "down"
                                  ? Icon(
                                      Icons.trending_down,
                                      color: Colors.red,
                                      size: 16.0,
                                    )
                                  : emptyWidget,
                          Text(
                            portfolioData['change'].toString() + "%",
                            style: TextStyle(
                                color: portfolioData['change_sign'] == "up"
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12.0), // ""1.5%""
                          )
                        ],
                      )
                    ],
                  )
                ],
              ));
          return container;
        });
  }

  Widget _buildPortfolioEdit(String type, List _portfolioList) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: _portfolioList.length,
        itemBuilder: (context, index) {
          Map portfolioData = _portfolioList[index];

          Widget container = containerCard(
              context: context,
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget
                            .model
                            .userPortfoliosData[
                                widget.model.defaultPortfolioSelectorKey]
                                ['portfolios'][type]
                            .removeWhere(
                                (item) => item['ric'] == portfolioData['ric']);
                        widget.notifyParent();
                        portfolioChanged = true;
                      });
                    },
                    child: Icon(
                      Icons.remove_circle,
                      color: Colors.redAccent,
                      size: 18.0,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                      child: Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text(portfolioData['name'],
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: Color(0xff3c4257))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          widgetBubble(
                              title: portfolioData['zone'].toUpperCase(),
                              bgColor: Color(0xfff6f9fc),
                              textColor: Color(0xff6b7c93),
                              leftMargin: 0),
                          widgetBubble(
                              title: type.toUpperCase(),
                              bgColor: Color(0xfff6f9fc),
                              textColor: Color(0xff6b7c93),
                              leftMargin: 0),
                        ],
                      ),
                      Text(portfolioData['weightage'].toString() + " units")
                    ],
                  )),
                  SizedBox(width: 10.0),
                  Container(
                      margin: const EdgeInsets.all(0.0),
                      padding: const EdgeInsets.all(1.0),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                    context,
                                    '/edit_ric/' +
                                        widget
                                            .model.defaultPortfolioSelectorKey +
                                        "/" +
                                        type +
                                        "/" +
                                        portfolioData['ric'] +
                                        "/" +
                                        portfolioData['zone'] +
                                        "/" +
                                        index.toString())
                                .then((value) {
                              setState(() {});
                            });
                          }, //editRIC(type, index, portfolioData),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.edit),
                            ],
                          )))
                ],
              ));
          return container;
        });
  }

  editRIC(String type, int index, Map portfolioData) async {
    Function f;
    // log.d('debug 698');
    // log.d( widget.model.defaultPortfolioSelectorKey);
    // log.d(type);
    // log.d(portfolioData['ric']);

    //f = await Navigator.pushNamed(context, '/edit_ric/' + widget.model.defaultPortfolioSelectorKey + "/" + type + "/" + portfolioData['ric'] + "/" + portfolioData['zone'] + "/" + index.toString());
    Navigator.pushNamed(
            context,
            '/edit_ric/' +
                widget.model.defaultPortfolioSelectorKey +
                "/" +
                type +
                "/" +
                portfolioData['ric'] +
                "/" +
                portfolioData['zone'] +
                "/" +
                index.toString())
        .then((value) {
      setState(() {
        // refresh state
      });
    });
    ;
    f();
  }

/* 	Widget _buttonSubmit(){
		return RaisedButton(
			child: Text("Submit ", style: TextStyle(color: Colors.white),),
			onPressed: (){
				formResponse();
			}
		);
	} */

  Widget _buildSelectFieldPortfolio(
      BuildContext context,
      String labelText,
      String key,
      String type,
      String defaultValue,
      String inputType,
      String suffix) {
    List<DropdownMenuItem<String>> _portfolioOptions = [];

    widget.model.userPortfoliosData.forEach((key, value) {
      _portfolioOptions.add(DropdownMenuItem<String>(
        value: key,
        child: Text(value['portfolio_name']),
      ));
    });

    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).focusColor),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 5.0,
          width: 5.0,
        ),
        DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
              /*  borderRadius: , */
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: DropdownButton<String>(
                isExpanded: true,
                isDense: true,
                items: _portfolioOptions,
                hint: Text(
                    (widget.model.userPortfoliosData != null
                        ? widget.model.userPortfoliosData[widget.model
                            .defaultPortfolioSelectorKey]['portfolio_name']
                        : labelText),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey[600])),
                onChanged: (String value) {
                  setState(() {
                    widget.model.defaultPortfolioSelectorKey = value;
                  });
                },
              ),
            )),
      ],
    );
  }

  Widget _buildTextFieldPortfolio(
      BuildContext context,
      String labelText,
      String key,
      String type,
      String defaultValue,
      String inputType,
      String suffix) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).focusColor),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 5.0,
          width: 5.0,
        ),
        Container(
            /* padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0), */
            child: TextField(
                controller: portfolioTxt,
                decoration: InputDecoration(
                    //labelText: widget.model.userPortfoliosData[widget.model.defaultPortfolioSelectorKey]['portfolio_name'],
                    labelStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey[600]),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0)),
                textAlign: TextAlign.left,
                onChanged: (String value) {
                  setState(() {
                    widget.model.userPortfoliosData[widget.model
                        .defaultPortfolioSelectorKey]['portfolio_name'] = value;
                  });
                },
                style: Theme.of(context).textTheme.bodyText1)),
      ],
    );
  }

  Widget _quantityBoxAddPortfolio() {
    return Flex(direction: Axis.horizontal, children: <Widget>[
      Text(
        "Qty",
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14.0,
        ),
        textAlign: TextAlign.start,
      ),
      SizedBox(width: 10.0),
      Expanded(
        child: TextField(
          focusNode: qtyFocusNode,
          controller: _quantityTxt,
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0)),
          textAlign: TextAlign.right,
          keyboardType: TextInputType.number,
          onChanged: (String value) {
            setState(() {
              _quantity = value;
            });
          },
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 13.0),
        ),
      )
    ]);
  }

  void addNewPortfolio(BuildContext context) {
    _selectedSuggestion = null;
    _quantity = null;

    _searchTxt.clear();
    _quantityTxt.clear();

    FocusScope.of(context).requestFocus(autoCompleteFocusNode);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: Colors.white,
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Flex(direction: Axis.vertical, children: <Widget>[
                        _autocompleteTextField(),
                        SizedBox(height: 20.0),
                        Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Expanded(child: _quantityBoxAddPortfolio()),
                            SizedBox(width: 10.0),
                            RaisedButton(
                                child: Text(
                                  "Add to Portfolio ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () => addPortfolio())
                          ],
                        )
                      ]))
                ],
              ));
        });
  }
}
