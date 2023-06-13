import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('SettingsCurrencyPage');

class SettingsCurrencyPage extends StatefulWidget {
	MainModel model;
	SettingsCurrencyPage(this.model);

	@override
	State<StatefulWidget> createState() {
		return _SettingsCurrencyPageState();
	}
}

class _SettingsCurrencyPageState extends State<SettingsCurrencyPage> {
	bool _loading = false;

	Map customerSettings;

	List<Map<String, dynamic>> currencies = [
		{'name': 'INR', 'value': 'inr'},
		{'name': 'USD', 'value': 'usd'},
		{'name': 'SGD', 'value': 'sgd'},
	];

	void initState(){ 
		super.initState();
		
		loadSettings();
	}

	Future loadSettings() async{
		if(widget.model.isUserAuthenticated ){
			setState(() {
			  	_loading = true;
			});

			customerSettings = await widget.model.getCustomerSettings();
			log.d('debug 48');
			log.d(customerSettings);

			setState(() {
			  	_loading = false;
			});
		}
	}


	AppBar _startAppBarPage(){
		return AppBar(
		centerTitle: true,
		backgroundColor: Theme.of(context).primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
		title: new Image.asset(
			'assets/images/logo_white.png',
			fit: BoxFit.fill,
			height: 25.0,
		)
		);
	}

  	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: (_startAppBarPage()),
			body:
			Container(
				alignment: Alignment.center,
				child: _buildBody()
			)
		);
	}



 	Widget buildSelectFieldCustom(BuildContext context, String labelText, String key, List <Map<String, dynamic>> fieldLists){
		return Flex(
			direction: Axis.vertical,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				Text(labelText, style: TextStyle(color: Colors.grey[700], fontSize: 14.0,), textAlign: TextAlign.start,),
				SizedBox(height: 5.0,),
				DecoratedBox(
					decoration: BoxDecoration(
						border: Border.all(color: Colors.grey),
						borderRadius: BorderRadius.circular(5.0),
					),
					child: 
						Container(
							padding: EdgeInsets.symmetric(horizontal: 10.0),
							child: 
								DropdownButton<String>(
									isExpanded: true,
									items: fieldLists.map((Map fieldList) {
										return DropdownMenuItem<String>(
											value: fieldList['value'],
											child: Text(fieldList['name']),
										);
									}).toList(),
									hint: Text( getListValue(fieldLists, customerSettings['base_currency'][customerSettings['default_zone']], matchKey: 'value', returnKey: 'name') ),
									onChanged: (String value) {
										setState(() {
											customerSettings['base_currency'][customerSettings['default_zone']] = value;
										});
									},
								),
						)
						
				),
				SizedBox(height: 5.0),
			],
		);
	
	}

	Widget submitButton(){
		return Container(
			margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
			child: 
				RaisedButton(
					padding: EdgeInsets.fromLTRB(90.0, 15.0, 90.0, 15.0),
					shape: new RoundedRectangleBorder(
						borderRadius: new BorderRadius.circular(8.0)),
					textColor: Colors.white,
					child: widgetButtonText("Submit"),
					onPressed: () async{
						setState(() {
							_loading = true;
						});
						Map responseData = await widget.model.updateCustomerSettings(customerSettings);
						
						setState(() {
							_loading = false;
						});

						if(responseData['status']){
							Navigator.pop(context);
						}
						
					},
				)
		);
	}

	Widget buildBodySettings(){
		return Container(
			padding:EdgeInsets.symmetric(horizontal: 20.0),
			margin:EdgeInsets.only(top: 20.0),
			child: 
				Flex(
					mainAxisAlignment: MainAxisAlignment.start,
					crossAxisAlignment: CrossAxisAlignment.center,
					direction: Axis.vertical,
					children: <Widget>[
						Expanded(
							child: Flex(
								direction: Axis.vertical,
								children: <Widget>[
									buildSelectFieldCustom(context, "Currency", 'currency',  currencies),
								],
							),
						),
								
						Container(margin: EdgeInsets.only(bottom: 20.0), child: submitButton()),
					],
				)
		);
	}

	
	Widget _buildBody(){
		if (_loading) {
			return preLoader();
		}else{
			return mainContainer(context: context, containerColor: Colors.white, paddingTop: 20.0, child:  buildBodySettings());
		}
	}

	

}
