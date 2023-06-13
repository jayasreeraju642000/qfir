import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/log_printer.dart';

import 'helpers/search_bank.dart';
import 'styles.dart';
import 'widget_common.dart';

final log = getLogger('AddDeposit');

class AddDeposit extends StatefulWidget {
  final MainModel model;
  final String portfolioMasterID;
  final String portfolioDepositID;

  AddDeposit(this.model, this.portfolioMasterID, this.portfolioDepositID);

  @override
  State<StatefulWidget> createState() {
    return _AddDeposit();
  }
}

class _AddDeposit extends State<AddDeposit> {
  Map<String, FocusNode> focusNodes = {
    'portfolio_name': new FocusNode(),
    'ric': new FocusNode(),
    'portfolio_amount': new FocusNode(),
    'display_name': new FocusNode(),
    'bank_name': new FocusNode(),
    'amount': new FocusNode(),
    'interest': new FocusNode(),
    'start_date': new FocusNode(),
    'end_date': new FocusNode(),
    'type_of_deposit_acc': new FocusNode(),
    'deposit_type': new FocusNode(),
    'currency': new FocusNode(),
    'frequency': new FocusNode(),
  };

  Map<String, TextEditingController> _controller = {
    'portfolio_name': new TextEditingController(),
    'ric': new TextEditingController(),
    'portfolio_amount': new TextEditingController(),
    'display_name': new TextEditingController(),
    'bank_name': new TextEditingController(),
    'amount': new TextEditingController(),
    'interest': new TextEditingController(),
    'start_date': new TextEditingController(),
    'end_date': new TextEditingController()
  };

  Map accTypeDepositMap = {
    "Fixed Deposit": {"value": "1", "ric": "FDEP"},
    "Recurring Deposit": {"value": "2", "ric": "RDEP"},
    "Savings Account": {"value": "3", "ric": "SDEP"},
    "Current Account": {"value": "4", "ric": "CDEP"}
  };

  Map frequencyMap = {
    "Monthly": {"value": "M"},
    "Quarterly": {"value": "Q"},
    "Half Yearly": {"value": "H"},
    "Yearly": {"value": "Y"},
  };

  Map depositTypeMap = {
    "Cumulative": {"value": "C"},
    "Non cumulative": {"value": "NC"},
  };

  Map deposite_list = {
    "Deposit": "",
  };

  List<Map> type_of_acc_Map = [
    {"type_acc": "Fixed Deposit", "value": "FDEP"},
    {"type_acc": "Recurring Deposit", "value": "RDEP"},
    {"type_acc": "Savings Account", "value": "SDEP"},
    {"type_acc": "Current Account", "value": "CDEP"}
  ];

  List<Map> deposit_type_Map = [
    {"deposit_type": "Cumulative", "value": "C"},
    {"deposit_type": "Non cumulative", "value": "NC"},
  ];

  List<Map> frequency_Map = [
    {"frequency": "Monthly", "value": "M"},
    {"frequency": "Quarterly", "value": "Q"},
    {"frequency": "Half Yearly", "value": "H"},
    {"frequency": "Yearly", "value": "Y"},
  ];

  Map filterOptionSelection = {
    'sort_order': 'asc',
    'sortby': 'name',
    'type': 'funds',
  };

  List deposit_arrays = [];
  List display_arrays = [];

  final GlobalKey<FormState> _addDepositForm = GlobalKey<FormState>();

  String ricUpdateValue;
  String _selectedTypeAcc;
  String _selectedDeposit;
  String _selectedCurrency;
  String _selectedFrequency;
  String auto_renew = "0";
  String bank_id = "0";
  bool value_auto_renew = false;
  bool depositPortfolio = false;
  DateTime _depositStartDate = DateTime.now();
  DateTime _depositEndDate;
  List bank_items = [];
  Map<dynamic, dynamic> _banksData;
  String search_key = "";
  Map filterOptionSelectionReset;
  bool isLoading = false;

  StateSetter _setState;

  void getBanks(key) async {
    _banksData = await widget.model.getBanks(key);

    if (!bank_items.isEmpty) {
      bank_items.clear();
    }

    for (var item in _banksData['response']) {
      HashMap<String, dynamic> banks_dataMap = new HashMap();
      banks_dataMap['zone'] = item['zone'];
      banks_dataMap['bank_name'] = item['bank_name'];
      banks_dataMap['bank_id'] = item['bank_id'];

      bank_items.add(banks_dataMap);
    }
  }

  @override
  void initState() {
    // if (widget.action == 'newPortfolio') {
    //   _analyticsAddManuallyCurrentScreen();
    // }
    // _addEvent();
    getBanks(search_key);

    filterOptionSelectionReset = Map.from(filterOptionSelection);
    // zones as per user allowed //
    // updateKeyStatsRange();

    Map PortfolioData = {};
    List PortfolioDepositData;

    if (widget.portfolioDepositID != null) {
      PortfolioData = new Map.from(
          widget.model.userPortfoliosData[widget.portfolioMasterID]);

      PortfolioDepositData = PortfolioData['portfolios']['Deposit'];

      for (int i = 0; i < PortfolioDepositData.length; i++) {
        if (PortfolioDepositData[i]['portfolio_id'] ==
            widget.portfolioDepositID) {
          setState(() {
            if (PortfolioDepositData[i]['depositData'] != null) {
              deposit_type_Map.forEach((element) {
                if (element['value'] ==
                    PortfolioDepositData[i]['depositData']['payout']) {
                  _selectedDeposit = element['deposit_type'];
                }
              });

              frequency_Map.forEach((element) {
                if (element['value'] ==
                    PortfolioDepositData[i]['depositData']['frequency']) {
                  _selectedFrequency = element['frequency'];
                }
              });

              type_of_acc_Map.forEach((element) {
                if (element['value'] == PortfolioDepositData[i]['ticker']) {
                  _selectedTypeAcc = element['type_acc'];
                  ricUpdateValue = PortfolioDepositData[i]['ric'];
                }
              });

              widget.model.currencies.forEach((element) {
                if (element['key'] ==
                    PortfolioDepositData[i]['depositData']['currency']) {
                  _selectedCurrency = element['key'].toString();
                }
              }); //

              _controller['display_name'].text =
                  PortfolioDepositData[i]['depositData']['display_name'];
              _controller['bank_name'].text =
                  PortfolioDepositData[i]['depositData']['bank_name'];

              var amount = PortfolioDepositData[i]['depositData']['amount'];
              amount = amount.replaceAll(",", "");
              amount = amount.substring(1);
              _controller['amount'].text = amount;

              _controller['interest'].text =
                  PortfolioDepositData[i]['depositData']['rate'];
              _controller['start_date'].text =
                  PortfolioDepositData[i]['depositData']['start_date'];
              _controller['end_date'].text =
                  PortfolioDepositData[i]['depositData']['maturity_date'];

              bank_id = PortfolioDepositData[i]['depositData']['bank_id'];
              ;
              auto_renew = PortfolioDepositData[i]['depositData']['auto_renew'];
              if (auto_renew == "1") {
                value_auto_renew = true;
              } else {
                value_auto_renew = false;
              }
            }
          });
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Form(
      key: _addDepositForm,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: getScaledValue(40)),

            Container(
              padding: EdgeInsets.only(right: 16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                    onTap: () => {
                          setState(() {
                            _selectedTypeAcc = null;
                            _selectedCurrency = null;
                            _controller['display_name'].text = "";
                            _controller['bank_name'].text = "";
                            _controller['amount'].text = "";
                            _controller['interest'].text = "";
                            _controller['start_date'].text = "";
                            _controller['end_date'].text = "";
                            _selectedFrequency = null;
                            _selectedDeposit = null;

                            bank_id = "";
                            auto_renew = "";
                          }),
                          Navigator.pop(context),
                        },
                    child: Icon(Icons.close, color: Color(0xffa5a5a5))),
              ),
            ),

            SizedBox(height: getScaledValue(16)),

            Expanded(
                child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: getScaledValue(16)),
                      child: Text(
                        widget.portfolioDepositID != null
                            ? "Edit Deposit"
                            : "Add new Deposit",
                        style: headline1,
                      ),
                    ),
                    SizedBox(height: 30),
                    _depositForm(),
                    SizedBox(
                      height: getScaledValue(8),
                      child: Container(
                        color: Color(0xffecf1fa),
                      ),
                    ),
                    SizedBox(height: getScaledValue(24)),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: getScaledValue(16)),
                      child: Text(
                        "Other Details",
                        style: headline5_analyse,
                      ),
                    ),
                    SizedBox(height: getScaledValue(26)),
                    _depositOtherDetails(),
                    SizedBox(height: getScaledValue(24)),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            activeColor: Color(0xffcedfff),
                            checkColor: Color(0xff034bd9),
                            value: this.value_auto_renew,
                            onChanged: (bool value) {
                              setState(() {
                                this.value_auto_renew = value;
                                if (value == false) {
                                  auto_renew = "0";
                                } else {
                                  auto_renew = "1";
                                }
                                // log.d("auto_renew$auto_renew");
                              });
                            },
                          ),
                          SizedBox(width: getScaledValue(8)),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  "Auto-renew",
                                  style: bodyText0_dashboard,
                                ),
                                Tooltip(
                                  padding: EdgeInsets.all(10),
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal),
                                  message:
                                      "Auto-renew\nThis deposit will be auto-renewed in your portfolio for the same tenor and interest rate on maturity, if this option is selected",
                                  child: InkWell(
                                      onTap: () => bottomAlertBox(
                                            context: context,
                                            title: 'Auto-renew',
                                            description:
                                                "This deposit will be auto-renewed in your portfolio for the same tenor and interest rate on maturity, if this option is selected",
                                          ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 6.0),
                                        child: svgImage(
                                          "assets/icon/information.svg",
                                          color: AppColor.colorBlue,
                                          height: 16,
                                          width: 12,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: getScaledValue(24)),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: getScaledValue(16)),
                            child: gradientButton(
                                context: context,
                                caption: widget.portfolioDepositID != null
                                    ? "Save"
                                    : "Add",
                                onPressFunction: () => addDepositValue())),
                    SizedBox(height: getScaledValue(24)),
                  ],
                ),
              ),
            )),
            // _registerCountryForm(),
            //	Expanded(child: _searchBox()),
          ],
        ),
      ),
    );
  }

  Widget _depositForm() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
        //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Column(
            // direction: Axis.vertical,//
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _type_of_deposit_acc(),
              SizedBox(height: getScaledValue(4)),
              TextFormField(
                  focusNode: focusNodes['display_name'],
                  controller: _controller['display_name'],
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter the display name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: focusNodes['display_name'].hasFocus
                          ? inputLabelFocusStyleDep
                          : inputLabelStyleDep),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onChanged: (String value) {},
                  onFieldSubmitted: (term) {
                    setState(() {
                      _fieldFocusChange(context, focusNodes['display_name'],
                          focusNodes['bank_name']);
                    });
                  },
                  style: inputFieldStyleDep),
              SizedBox(height: getScaledValue(14)),
              _bankNameTextfield(),
              SizedBox(height: getScaledValue(26)),
              _deposit_type(),
              SizedBox(height: getScaledValue(14)),
            ]));
  }

  Widget _depositOtherDetails() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
        //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Column(
            //direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                  focusNode: focusNodes['amount'],
                  controller: _controller['amount'],
                  validator: (value) {
                    if (value.isEmpty || value == 0) {
                      return "Enter valid amount";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Amount of Deposit',
                      labelStyle: focusNodes['amount'].hasFocus
                          ? inputLabelFocusStyleDep
                          : inputLabelStyleDep),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, focusNodes['amount'], focusNodes['currency']);
                  },
                  onChanged: (String value) {},
                  style: inputFieldStyleDep),
              SizedBox(height: getScaledValue(26)),
              _currency_of_deposit(),
              SizedBox(height: getScaledValue(4)),
              TextFormField(
                  focusNode: focusNodes['interest'],
                  controller: _controller['interest'],
                  validator: (value) {
                    if (value.isEmpty || value == 0) {
                      return "Enter valid interest";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Annual rate of interest',
                      suffix: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("%"),
                      ),
                      labelStyle: focusNodes['interest'].hasFocus
                          ? inputLabelFocusStyleDep
                          : inputLabelStyleDep),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (String value) {},
                  style: inputFieldStyleDep),
              SizedBox(height: getScaledValue(26)),
              _frequency_deposit(),
              SizedBox(height: getScaledValue(14)),
              _strat_date(),
              SizedBox(height: getScaledValue(14)),
              _end_date()
            ]));
  }

  addDepositValue() async {
    final form = _addDepositForm.currentState;

    if (form.validate()) {
      form.save();

      Map deposite_data = {
        "type": accTypeDepositMap[_selectedTypeAcc]['value'],
        "display_name": _controller['display_name'].text,
        "currency": _selectedCurrency,
        "amount": _controller['amount'].text,
        "rate": _controller['interest'].text,
        "frequency": frequencyMap[_selectedFrequency]['value'],
        "payout": depositTypeMap[_selectedDeposit]['value'],
        "start_date": _controller['start_date'].text,
        "maturity_date": _controller['end_date'].text,
        "bank_id": bank_id,
        "auto_renew": auto_renew
      };

      Map deposite_json_value = {
        "currency": _selectedCurrency.toUpperCase(),
        "zone": "gl",
        "ric": widget.portfolioDepositID != null
            ? ricUpdateValue
            : accTypeDepositMap[_selectedTypeAcc]['ric'],
        "weightage": "1.00",
        "type": "Deposit",
        "depositData": deposite_data,
      };

      //ricUpdateValue

      deposit_arrays.add(deposite_json_value);
      display_arrays.add(_controller['display_name'].text);

      deposite_list['Deposit'] = deposit_arrays;

      Map PortfolioData = {};

      if (widget.portfolioMasterID != null) {
        PortfolioData = new Map.from(
            widget.model.userPortfoliosData[widget.portfolioMasterID]);

        setState(() {
          isLoading = true;
          depositPortfolio = true;
        });

        if (widget.portfolioDepositID != null) {
          // remove the deposit item if exists
          widget
              .model
              .userPortfoliosData[widget.portfolioMasterID]['portfolios']
                  ['Deposit']
              ?.removeWhere((item) => item["ric"] == ricUpdateValue);
        }

        widget
            .model
            .userPortfoliosData[widget.portfolioMasterID]['portfolios']
                ['Deposit']
            .add({
          "currency": _selectedCurrency.toUpperCase(),
          "zone": "gl",
          "ric": widget.portfolioDepositID != null
              ? ricUpdateValue
              : accTypeDepositMap[_selectedTypeAcc]['ric'],
          "weightage": "1.00",
          "type": "Deposit",
          "depositData": deposite_data,
        });

        Map<String, dynamic> responseData =
            await widget.model.updateCustomerPortfolioData(
          portfolios: widget.model.userPortfoliosData[widget.portfolioMasterID]
              ['portfolios'],
          portfolioMasterID:
              widget.portfolioMasterID != null ? widget.portfolioMasterID : '0',
          portfolioName: widget.portfolioMasterID != null
              ? PortfolioData['portfolio_name']
              : widget.model.userPortfoliosData['0']['portfolio_name'],
          depositPortfolio: depositPortfolio ? true : false,
        );
        // log.d(responseData);
        if (responseData['status'] == true) {
          // var portfolioMasterId = widget.portfolioMasterID;
          Navigator.of(context).pop();
          // Navigator.of(context).pop();
          // Navigator.pushNamed(context, '/portfolio_view/' + portfolioMasterId,
          //     arguments: {"readOnly": false});
          //  Navigator.pushReplacementNamed(context, '/portfolio_view/' + widget.portfolioMasterID, arguments: {"readOnly": false});
          // Navigator.pushReplacementNamed(context, '/success_page', arguments: {
          //   'type': 'newPortfolio',
          //   'portfolio_name': widget.portfolioMasterID != null
          //       ? PortfolioData['portfolio_name']
          //       : widget.model.userPortfoliosData['0']['portfolio_name'],
          //   'portfolioMasterID': responseData['portfolioMasterID'],
          //   'action': 'newPortfolio'
          // });
        }
      } else {
        setState(() {
          depositPortfolio = true;
          _selectedTypeAcc = null;
          _selectedCurrency = null;
          _controller['display_name'].text = "";
          _controller['bank_name'].text = "";
          _controller['amount'].text = "";
          _controller['interest'].text = "";
          _controller['start_date'].text = "";
          _controller['end_date'].text = "";
          _selectedFrequency = null;
          _selectedDeposit = null;

          bank_id = "";
          auto_renew = "";
          // var portfolioMasterId = widget.portfolioMasterID;
          Navigator.of(context).pop();
          // Navigator.of(context).pop();
          // Navigator.pushReplacementNamed(
          //     context, '/portfolio_view/' + portfolioMasterId,
          //     arguments: {"readOnly": false});
        });
      }
    }
  }

  Widget _type_of_deposit_acc() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Type of Deposit", style: inputLabelStyleDep),
        DropdownButtonFormField<String>(
          //focusNode: focusNodes['type_of_deposit_acc'],
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          isExpanded: true,
          items: type_of_acc_Map.map((Map item) {
            return new DropdownMenuItem<String>(
                value: item['type_acc'], //country['code'],//
                child: Text(item['type_acc'],
                    style: TextStyle(color: Colors.black)));
          }).toList(),
          hint: Text(
            ("Select"),
          ),
          value: _selectedTypeAcc,
          style: inputFieldStyleDep,

          validator: (value) => value == null ? 'Select type of deposit' : null,

          onChanged: widget.portfolioDepositID != null
              ? null
              : (value) {
                  _selectedTypeAcc = value;
                },
        ),
      ],
    ));
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _bankNameTextfield() {
    return Container(
      child: InkWell(
        onTap: () {
          // log.d("I'm here!!!");
          _fieldFocusChange(
              context, focusNodes['display_name'], focusNodes['bank']);
          showDialogBankName();
        },
        child: IgnorePointer(
          child: TextFormField(
              // enabled: false,
              // showCursor: false,
              // readOnly: true,
              focusNode: focusNodes['bank_name'],
              controller: _controller['bank_name'],
              validator: (value) {
                if (value.isEmpty) {
                  return "Select the bank name";
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: 'Bank Name',
                  labelStyle: focusNodes['bank_name'].hasFocus
                      ? inputLabelFocusStyleDep
                      : inputLabelStyleDep),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: (String value) {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  // _userData['bank_name'] = value;
                });
              },
              onFieldSubmitted: (term) {
                //  // _setState(() {
                //     _fieldFocusChange(context, focusNodes['display_name'],
                //         focusNodes['deposit_type']);
                //});
              },
              style: inputFieldStyleDep),
        ),
      ),
    );
  }

  Widget _deposit_type() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Deposit Type", style: inputLabelStyleDep),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message:
                    "Deposit Type\nA cumulative deposit pays out the entire interest at maturity while a non-cumulative deposit pays out the interest on a monthly, quarterly, half-yearly or a yearly basis. Over interest earned is higher in a cumulative deposit",
                child: InkWell(
                    onTap: () => bottomAlertBox(
                          context: context,
                          title: 'Deposit Type',
                          description:
                              "A cumulative deposit pays out the entire interest at maturity while a non-cumulative deposit pays out the interest on a monthly, quarterly, half-yearly or a yearly basis. Over interest earned is higher in a cumulative deposit",
                        ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: svgImage(
                        "assets/icon/information.svg",
                        color: AppColor.colorBlue,
                        height: 16,
                        width: 12,
                      ),
                    )),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            //focusNode: focusNodes['deposit_type'],
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 20,
            isExpanded: true,
            items: deposit_type_Map.map((Map deposit_type_Map) {
              return new DropdownMenuItem<String>(
                value: deposit_type_Map['deposit_type'], //country['code'],
                child: Text(deposit_type_Map['deposit_type'],
                    style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            hint: Text(
              ("Select"),
            ),
            value: _selectedDeposit,
            style: inputFieldStyleDep,

            validator: (value) => value == null ? 'Select deposit type' : null,

            onChanged: (value) {
              FocusScope.of(context).requestFocus(FocusNode());
              _selectedDeposit = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _currency_of_deposit() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Currency of deposit", style: inputLabelStyleDep),
        DropdownButtonFormField<String>(
          //focusNode: focusNodes['interest'],
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          isExpanded: true,
          items: widget.model.currencies.map((Map item) {
            return new DropdownMenuItem<String>(
              value: item['key'],
              child: Text(item['value']),
            );
          }).toList(),
          hint: Text(
            ("Select"),
          ),
          value: _selectedCurrency,
          style: inputFieldStyleDep,
          validator: (value) =>
              value == null ? 'Select currency of deposit' : null,

          onChanged: (value) {
            // log.d("schecking_purpose----------------");
            //log.d(item['value']);
            FocusScope.of(context).requestFocus(FocusNode());
            _selectedCurrency = value;

            // log.d(value);
            // log.d(_selectedCurrency);
          },
        ),
      ],
    ));
  }

  Widget _frequency_deposit() {
    // _fieldFocusChange(
    //     context, focusNodes['bank_name'], focusNodes['deposit_type']);
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Interest compounding frequency", style: inputLabelStyleDep),
            Tooltip(
              padding: EdgeInsets.all(10),
              textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              message:
                  "Interest compounding frequency\nCompounding frequency is the time period when interest will be calculated on top of the original loan amount. It is usually expressed as the number of periods in a year. Higher the frequency, more is the interest accrued",
              child: InkWell(
                  onTap: () => bottomAlertBox(
                        context: context,
                        title: 'Interest compounding frequency',
                        description:
                            "Compounding frequency is the time period when interest will be calculated on top of the original loan amount. It is usually expressed as the number of periods in a year. Higher the frequency, more is the interest accrued",
                      ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: svgImage(
                      "assets/icon/information.svg",
                      color: AppColor.colorBlue,
                      height: 16,
                      width: 12,
                    ),
                  )),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          //focusNode: focusNodes['frequency'],
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          isExpanded: true,
          items: frequency_Map.map((Map frequency_Map) {
            return new DropdownMenuItem<String>(
              value: frequency_Map['frequency'], //country['code'],
              child: Text(frequency_Map['frequency'],
                  style: TextStyle(color: Colors.black)),
            );
          }).toList(),
          hint: Text(
            ("Select"),
          ),
          value: _selectedFrequency,
          style: inputFieldStyleDep,
          validator: (value) =>
              value == null ? 'Select interest compounding frequency' : null,

          onChanged: (value) {
            // log.d("checking_purpose----------------");
            // log.d(value);
            // log.d(frequencyMap[value]['value']);
            FocusScope.of(context).requestFocus(FocusNode());
            _selectedFrequency = value;
          },
        ),
      ],
    ));
  }

  Widget _strat_date() {
    return Container(
        child: InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: _depositStartDate ?? DateTime.now(),
                firstDate: DateTime(2001),
                lastDate: DateTime.now(),
              ).then((date) {
                if (date == null) return;
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  _depositStartDate = date;
                  final f = new DateFormat('yyyy-MM-dd');
                  _controller['start_date'].text = f.format(date);
                  _controller['end_date'].text = '';
                });
              });
            },
            child: IgnorePointer(
                child: TextFormField(
                    focusNode: focusNodes['start_date'],
                    controller: _controller['start_date'],
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Select strat date";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      hintText: "YYYY-MM-DD",
                      labelStyle: focusNodes['start_date'].hasFocus
                          ? inputLabelFocusStyleDep
                          : inputLabelStyleDep,
                      contentPadding:
                          EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (String value) {
                      setState(() {});
                    },
                    style: inputFieldStyleDep))));
  }

  Widget _end_date() {
    return Container(
      child: InkWell(
        onTap: () {
          // log.d(_controller['start_date'].text);
          if (_controller['start_date'].text == '') {
            return;
          }
          showDatePicker(
                  context: context,
                  initialDate: _depositEndDate != null
                      ? _depositEndDate
                      : _depositStartDate.add(Duration(days: 365)),
                  firstDate: _depositStartDate ?? DateTime.now(),
                  lastDate: DateTime(2050))
              .then((date) {
            if (date == null) return;
            FocusScope.of(context).requestFocus(FocusNode());
            setState(() {
              final f = new DateFormat('yyyy-MM-dd');
              _controller['end_date'].text = f.format(date);
              _depositEndDate = date;
            });
          });
        },
        child: IgnorePointer(
          child: TextFormField(
              focusNode: focusNodes['end_date'],
              controller: _controller['end_date'],
              validator: (value) {
                if (value.isEmpty) {
                  return "Select end date";
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'End Date',
                hintText: "YYYY-MM-DD",
                labelStyle: focusNodes['end_date'].hasFocus
                    ? inputLabelFocusStyleDep
                    : inputLabelStyleDep,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
              ),
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {});
              },
              style: inputFieldStyleDep),
        ),
      ),
    );
  }

  showDialogBankName() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SearchBankName(widget.model),
            );
          });
        }).then((value) => {
          _setState(() {
            for (int i = 0; i < bank_items.length; i++) {
              var bank_v = bank_items[i]['bank_id'];
              if (bank_v == value) {
                _controller['bank_name'].text = bank_items[i]["bank_name"];
                bank_id = value;
                break;
              }
            }
            _fieldFocusChange(
                context, focusNodes['bank_name'], focusNodes['deposit_type']);
          })
        });
  }
}
