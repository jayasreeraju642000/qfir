import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/manage_portfolio_master/large_widget_common.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';

final log = getLogger('SearchBankName');

class SearchBankName extends StatefulWidget {
  MainModel model;
  final bool isLarge;

  SearchBankName(this.model, {this.isLarge});

  @override
  State<StatefulWidget> createState() {
    return _SearchBankNamePageState();
  }
}

class _SearchBankNamePageState extends State<SearchBankName> {
  final controller = ScrollController();

  Map<dynamic, dynamic> _banksData;
  List bank_items = [];
  String search_key = "";

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

  final format = DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    super.initState();
    getBanks(search_key);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search the bank name',
                  style: headline5_analyse,
                ),
                SizedBox(
                  height: 6.0,
                ),
                Container(
                  child: Theme(
                    data: new ThemeData(
                      primaryColor: Colors.blue,
                      primaryColorDark: Colors.blue,
                    ),
                    child: new TextField(
                      autofocus: true,
                      onChanged: (text) {
                        if (text.length >= 3) {
                          setState(() {
                            _banksData.clear();
                            getBanks(text.toString().trim());
                          });
                        } else {
                          setState(() {
                            _banksData.clear();
                            getBanks(search_key);
                          });
                        }
                      },
                      decoration: new InputDecoration(
                        hintText: 'Enter the bank name',
                        labelText: 'Bank Name',
                        labelStyle: inputLabelFocusStyleDep,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        prefixText: ' ',
                        suffixText: '',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: bank_items.length,
                    separatorBuilder: (_, __) => Divider(height: 0.5),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          bank_items[index]['bank_name'],
                          style: inputFieldStyleDep,
                        ),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop(bank_items[index]['bank_id']);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 6.0,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 120,
                    child: widget.isLarge == null
                        ? gradientButton(
                            context: context,
                            caption: "CLOSE",
                            onPressFunction: () => {
                              Navigator.of(context, rootNavigator: true).pop()
                            },
                          )
                        : gradientButtonForWeb(
                            context: context,
                            caption: "CLOSE",
                            onPressFunction: () => {
                              Navigator.of(context, rootNavigator: true).pop()
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
