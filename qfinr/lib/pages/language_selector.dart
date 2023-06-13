import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../models/main_model.dart';
import '../widgets/widget_common.dart';
import '../all_translations.dart';

final log = getLogger('LanguageSelectorPage');

class LanguageSelectorPage extends StatefulWidget {
  MainModel model;
  bool redirect;
  LanguageSelectorPage(this.model, this.redirect);

  @override
  State<StatefulWidget> createState() {
    return _LanguageSelectorPageState();
  }
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  String _selectedValue;

  List<Map<String, dynamic>> languages = [
    {'name': 'English', 'value': 'en', 'icon': 'assets/flag/en.jpg'},
    {'name': 'हिंदी', 'value': 'hi', 'icon': 'assets/flag/hi.png'},
  ];

  void initState() {
    super.initState();

    setSelectedLanguage();
  }

  void setSelectedLanguage() async {
    String currentLanguage = await getLanguage();
    setState(() {
      _selectedValue = currentLanguage;
    });
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
        appBar: _startAppBarPage(),
        body: Container(
            //height: 500.0,
            alignment: Alignment.center,
            child: mainContainer(
                context: context,
                containerColor: Colors.white,
                paddingTop: 20.0,
                child: widget.redirect ? _buildBodySettings() : _buildBody())));
  }

  Widget _buildBodySettings() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        margin: EdgeInsets.only(top: 20.0),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  _buildSelectFieldCustom(
                      context, "Language", 'language', languages),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(bottom: 20.0), child: _submitButton()),
          ],
        ));
  }

  Widget _buildSelectFieldCustom(BuildContext context, String labelText,
      String key, List<Map<String, dynamic>> fieldLists) {
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
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: DropdownButton<String>(
                isExpanded: true,
                items: fieldLists.map((Map fieldList) {
                  return DropdownMenuItem<String>(
                    value: fieldList['value'],
                    child: Text(fieldList['name']),
                  );
                }).toList(),
                hint: Text(getListValue(fieldLists, _selectedValue,
                    matchKey: 'value', returnKey: 'name')),
                onChanged: (String value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),
            )),
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _buildBody() {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
            child: widget.redirect
                ? _buildBodyTextChangePage()
                : _buildBodyTextStartPage()),
        Expanded(child: _languageList(languages)),
        Container(
            margin: EdgeInsets.only(bottom: 20.0), child: _submitButton()),
      ],
    );
  }

  Widget _buildBodyTextChangePage() {
    return Container(
      margin: EdgeInsets.only(bottom: 50.0),
      alignment: Alignment.bottomCenter,
      child: Text(
        languageText('text_change_language_text'),
        style: TextStyle(color: Colors.grey, fontSize: 13.0),
      ),
    );
  }

  Widget _buildBodyTextStartPage() {
    return Container(
        margin: EdgeInsets.only(bottom: 50.0),
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        alignment: Alignment.bottomCenter,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.end,
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              "Intelligent market insights and\nideas to help you invest right",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 17.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80.0),
            /* Text("Intelligent market insights and\nideas to help you invest right", style: TextStyle(color: Colors.grey, fontSize: 13.0), textAlign: TextAlign.center),
				SizedBox(height: 30.0), */
            Text("Select your preferred language to continue:",
                style: TextStyle(color: Colors.grey, fontSize: 13.0),
                textAlign: TextAlign.center),
          ],
        ));
  }

  Widget _submitButton() {
    return Container(
        /* minWidth: 100.0, */
        //height: 40.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(90.0, 15.0, 90.0, 15.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          textColor: Colors.white,
          child: widgetButtonText(widget.redirect
              ? 'Submit'
              : languageText('text_set_language_button')),
          onPressed: () async {
            await allTranslations.setNewLanguage(_selectedValue, true);

            //widget.model.setLoader(true);
            //await widget.model.fetchBaskets();
            //await widget.model.fetchMFBaskets();
            //await widget.model.fetchMIBaskets(true);

            //widget.model._isLoading = false;

            if (widget.redirect) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/intro');
            }
          },
        ));
  }

  Widget _languageList(List languagesL) {
    return ListView.builder(
        itemCount: languagesL.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> language = languagesL[index];
          return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedValue = language['value'];
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      (index == 0) ? Divider(height: 5.0) : Container(),
                      _buildLanguageRow(language),
                      Divider(height: 5.0),
                    ],
                  )));
        });
  }

  Widget _buildLanguageRow(language) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 30.0,
            child: Image.asset(language['icon']),
          ),
          SizedBox(
            width: 10.0,
          ),
          Container(
            width: 100.0,
            child: Text(
              language['name'],
              style: TextStyle(
                fontWeight: (_selectedValue == language['value']
                    ? FontWeight.bold
                    : (language['value'] == 'en'
                        ? FontWeight.w300
                        : FontWeight.normal)),
              ),
            ),
          ),
          Container(
              width: 20.0,
              child: (_selectedValue == language['value']
                  ? Image.asset('assets/images/tick.png')
                  : Container())),
        ],
      ),
    );
  }
}
