import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('GoalPlanner');


class GoalPlanner extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  GoalPlanner(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _GoalPlannerState();
  }
}

class _GoalPlannerState extends State<GoalPlanner> {
	Widget _progressHUD;

	Map<String, dynamic> _userData = {
		'userName'    : "Ishmeet Singh",
		'age'         : "30",
		'risk_profile': "conservative",
	};
  
  	Map<String, dynamic> _goalData = {
        'goal_name'       : "Home",
        'start_year'      : "2020",
        'goal_year'       : "2026",
        'present_value'   : "9000000",
        'goal_inflation'  : "0.06",
        'amt_saved'       : "100000",
        'annual_increment': "0.08",
	};

  	@override
	void initState() {
		super.initState();
		//widget.model.fetchBaskets();

		_progressHUD = new Center(
		child: new CircularProgressIndicator(),
		);    
	}

  AppBar _appBar(){
    return AppBar(
      //centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
      title: Text(languageText('text_goal_planner'), style: TextStyle(color: Colors.white, fontSize: 15.0))
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return Scaffold(
          /* drawer: WidgetDrawer(), */
          appBar: _appBar(),
          body: _buildBody(),
         );
      }
    );
    
  }

  Widget _buildBody() {
    if (widget.model.isLoading) {
      return _progressHUD;
    } else {
      return _plannerForm();
    }
  }
    

  Widget _plannerForm(){
      return Container(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: ListView(

          children: <Widget>[
            _buildTextField(context, "Your Name", "userName", "user", "Ishmeet Singh", "text"),
            SizedBox(height: 10.0),

            _buildTextField(context, "Your Age", "age", "user", "30", "number"),
            SizedBox(height: 10.0),

            _buildTextField(context, "Risk Profile", "risk_profile", "user", "conservative", "text"),
            SizedBox(height: 10.0),

            _buildTextField(context, "Goal Name", "goal_name", "goal", "Home", "text"),
            SizedBox(height: 10.0),

            _buildTextField(context, "Year Start Saving", "start_year", "goal", "2020", "number"),
            SizedBox(height: 10.0),
            
            _buildTextField(context, "Year Goal Needed", "goal_year", "goal", "2026", "number"),
            SizedBox(height: 10.0),
            
            _buildTextField(context, "Present Goal Cost", "present_value", "goal", "9000000", "number"),
            SizedBox(height: 10.0),
            
            _buildTextField(context, "Goal Inflation Rate", "goal_inflation", "goal", "0.06", "number"),
            SizedBox(height: 10.0),
            
            _buildTextField(context, "Amount Saved", "amt_saved", "goal", "100000", "number"),
            SizedBox(height: 10.0),
            
            _buildTextField(context, "Annual Increment", "annual_increment", "goal", "0.08", "number"),
            SizedBox(height: 10.0),

            _submitButton()
          ],
        ));
  }
  initialValue(val) {
    return TextEditingController(text: val);
  }
  TextInputType keyboardType(type){
    if(type == "number"){
      return TextInputType.number;
    }else{
      return TextInputType.text;
    }
  }
  Widget _buildTextField(BuildContext context, String labelText, String key, String type, String defaultValue, String inputType){
    return TextField(  
        keyboardType: keyboardType(inputType),
/*          *//* controller: initialValue(defaultValue), */
        decoration: InputDecoration(labelText: labelText, labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0)),
        /* obscureText: true, */
        
        onChanged: (String value) {
          setState(() {
            if(type == "goal"){
              _goalData[key] = value;
            }else if(type == "user"){
              _userData[key] = value;
            }
          });
        },
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
      );
  }
  Widget _submitButton(){
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return Container(
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: 
            RaisedButton(
              padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
              textColor: Colors.white,
              child: widgetButtonText('Generate Report'),
              onPressed: () {
                  formResponse(model);
              },
            ),
          );
      }
    );
  
  }
  void formResponse(MainModel model) async{
      Map<String, dynamic> responseData = await model.goalPlanner("goal", _userData, _goalData);

      if(responseData['status']){
        //String filePath = await FlutterPdfViewer.downloadAsFile(responseData['response']['link'],);
        //FlutterPdfViewer.loadFilePath(filePath);
        //Navigator.pushReplacementNamed(context, '/loadPDF');
      }else{
        showAlertDialogBox(context, 'Error!', responseData['response']);
      }
  }
  
  
}
