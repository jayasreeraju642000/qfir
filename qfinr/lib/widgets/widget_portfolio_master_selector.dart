import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('WidgetPortfolioMasterSelector');

class WidgetPortfolioMasterSelector extends StatefulWidget {
  final MainModel model;

  WidgetPortfolioMasterSelector(this.model);

  @override
  State<StatefulWidget> createState() {
    return _WidgetPortfolioMasterSelectorState();
  }
}

class _WidgetPortfolioMasterSelectorState
    extends State<WidgetPortfolioMasterSelector> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    loadFormData();
  }

  Future loadFormData() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });
      await widget.model.getCustomerPortfolio();
      setState(() {
        _loading = false;
      });
    }

    widget.model.userSelectedPortfolios.clear();
    widget.model.userPortfoliosData
        .forEach((portfolioMasterID, portfolioMaster) {
      if (portfolioMaster['default'] == '1') {
        widget.model.userSelectedPortfolios[portfolioMasterID] = true;
      } else {
        widget.model.userSelectedPortfolios[portfolioMasterID] = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (_loading) {
        return preLoader();
      } else {
        return _buildBodyContent(); //_autocompleteTextField(); //_buildBodyContent();

      }
    });
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
            Expanded(
                child: (widget.model.userPortfoliosData == null ||
                        widget.model.userPortfoliosData.isEmpty)
                    ? _noPortfolio()
                    : _portfolioMasterList()),
          ],
        ));
  }

  Widget _portfolioMasterList() {
    List<Widget> _listPortfolios = [];
    widget.model.userPortfoliosData.forEach((portfolioMasterID, portfolio) {
      _listPortfolios.add(portfolioItem(portfolio));
    });
    return ListView(
      children: _listPortfolios,
    );
  }

  Widget _listZones(Map portfolio) {
    List<Widget> _children = [];
    List<String> _selectedZones = portfolio['portfolio_zone'].split('_');

    Map _zonePortfolioCount = {
      'in': {'Stocks': 0, 'ETF': 0, 'Funds': 0, 'Bonds': 0},
      'sg': {'Stocks': 0, 'ETF': 0, 'Funds': 0, 'Bonds': 0},
      'us': {'Stocks': 0, 'ETF': 0, 'Funds': 0, 'Bonds': 0},
    };

    if (portfolio['portfolios'] != null && portfolio['portfolios'] != false) {
      portfolio['portfolios'].forEach((portfolioType, portfolioList) {
        for (Map _portfolioData in portfolioList) {
          _zonePortfolioCount[_portfolioData['zone']][portfolioType]++;
        }
      });
    }
    for (String zone in _selectedZones) {
      _children.add(Container(
          margin: EdgeInsets.symmetric(vertical: 3.0),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              widgetBubble(
                  title: zone.toUpperCase(),
                  bgColor: Color(0xfff6f9fc),
                  textColor: Color(0xff6b7c93),
                  leftMargin: 0),
              _zonePortfolioCount[zone]['Stocks'] != 0
                  ? widgetBubble(
                      title: _zonePortfolioCount[zone]['Stocks'].toString() +
                          " Stocks",
                      bgColor: Color(0xfff6f9fc),
                      textColor: Color(0xff6b7c93))
                  : Container(),
              _zonePortfolioCount[zone]['ETF'] != 0
                  ? widgetBubble(
                      title:
                          _zonePortfolioCount[zone]['ETF'].toString() + " ETF",
                      bgColor: Color(0xfff6f9fc),
                      textColor: Color(0xff6b7c93))
                  : Container(),
              _zonePortfolioCount[zone]['Funds'] != 0
                  ? widgetBubble(
                      title: _zonePortfolioCount[zone]['Funds'].toString() +
                          " Funds",
                      bgColor: Color(0xfff6f9fc),
                      textColor: Color(0xff6b7c93))
                  : Container(),
              _zonePortfolioCount[zone]['Bonds'] != 0
                  ? widgetBubble(
                      title: _zonePortfolioCount[zone]['Bonds'].toString() +
                          " Bonds",
                      bgColor: Color(0xfff6f9fc),
                      textColor: Color(0xff6b7c93))
                  : Container(),
            ],
          )));
    }

    return Container(
        child: Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.vertical,
      children: _children,
    ));
  }

  Widget portfolioItem(Map portfolio) {
    List<Widget> _children = [];

    _children.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            portfolio['portfolio_name'],
            style: Theme.of(context).textTheme.subtitle2,
          ),
          portfolio['default'] == '1'
              ? widgetBubble(
                  title: 'Core Portfolio',
                  textColor: Color(0xff3ecf8e),
                  bgColor: Color(0xfff6f9fc),
                  leftMargin: 0.0)
              : widgetBubble(
                  title: 'Transient Portfolio',
                  textColor: Color(0xff408af8),
                  bgColor: Color(0xfff6f9fc),
                  leftMargin: 0.0)
        ],
      ),
    );
    _children.add(Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: _listZones(portfolio)),
      ],
    ));

    if (portfolio['date_added'] != null)
      _children.add(Text(
        'Created on: ' + portfolio['date_added'].toString(),
        style: Theme.of(context).textTheme.bodyText2,
      ));

    return containerCard(
        child: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 10.0),
          child: Checkbox(
            value: widget.model.userSelectedPortfolios[portfolio['id']],
            onChanged: portfolio['default'] == '1'
                ? null
                : (bool value) {
                    setState(() {
                      widget.model.userSelectedPortfolios[portfolio['id']] =
                          value;
                    });
                  },
          ),
        ),
        Expanded(
            child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/portfolio_view/' + portfolio['id'],
                arguments: {'readOnly': true});
          },
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _children,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18.0),
            ],
          ),
        )),
      ],
    ));
    /* return Container(
			padding: EdgeInsets.all(5.0),
			child: Row(
				children: <Widget>[
					Checkbox(
						value: widget.model.userSelectedPortfolios[portfolio['id']],
						onChanged: portfolio['default'] == '1' ? null : (bool value) {
							setState(() {
								widget.model.userSelectedPortfolios[portfolio['id']] = value;
							});
						},

					),
					Expanded(
						child: GestureDetector(
							onTap: () => setState(() { widget.model.userSelectedPortfolios[portfolio['id']] = !widget.model.userSelectedPortfolios[portfolio['id']]; }),
							child: Text(portfolio['portfolio_name']),
						)
					),
					portfolio['default'] == "1" ? Icon(Icons.vpn_key, size: 20,) : SizedBox(width: 20.0,),
					SizedBox(width: 10.0,),
					GestureDetector(
						onTap: (){
							Navigator.pushNamed(context, '/portfolio_view/' + portfolio['id'] );
						},
						child: Icon(Icons.search, size: 24),
					)
				],
			)
		); */
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
            : requireLogin(context));
  }
}
