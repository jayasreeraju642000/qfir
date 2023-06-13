import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';
// import 'package:http/http.dart' as http;

final log = getLogger('GoalPlanner');

class GoalPlanner extends StatefulWidget {
  MainModel model;
  String goalType;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  GoalPlanner(this.model, this.goalType, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _GoalPlannerState();
  }
}

class _GoalPlannerState extends State<GoalPlanner> {
  bool _loading = false;
  String _loaderStepStatus;
  bool _isVisibleFlag = false;
  bool _isGoalVisibleFlag = false;

  String pathPDF = "";

  String currency = "INR";

  int maxGoalLimit = 3;
  int currentGoalCount = 1;

  Map<String, dynamic> _userData = {
    'userName': "",
    'age': "35",
    'risk_profile': "moderate",
  };

  /// @todo hide goal inflation
  ///
  Map<String, dynamic> _goalData = {
    'goal_name': "Home",
    'start_year': "2020",
    'goal_year': "2030",
    'present_value': "5000000",
    'goal_inflation': "6",
    'amt_saved': "500000",
    'annual_increment': "5",
  };
  Map<String, dynamic> _goalDataIN = {
    'goal_name': "Home",
    'start_year': "2020",
    'goal_year': "2030",
    'present_value': "5000000",
    'goal_inflation': "6",
    'amt_saved': "500000",
    'annual_increment': "5",
  };
  Map<String, dynamic> _goalDataSG = {
    'goal_name': "Home",
    'start_year': "2020",
    'goal_year': "2030",
    'present_value': "2000000",
    'goal_inflation': "3",
    'amt_saved': "200000",
    'annual_increment': "2",
  };

  Map<String, dynamic> _goalDataUS = {
    'goal_name': "Home",
    'start_year': "2020",
    'goal_year': "2030",
    'present_value': "2000000",
    'goal_inflation': "3",
    'amt_saved': "200000",
    'annual_increment': "2",
  };

  Map<String, dynamic> _retirementData = {};

  Map<String, dynamic> _retirementDataIN = {
    'goal_name': "retirement",
    'retirement_age': '55',
    'life_expectancy': '85',
    'salary_pm': '400000',
    'annual_salary_increment': '4',
    'rentals_pm': '0',
    'otherincome_pm': '0',
    'living_expenses_pm': '200000',
    'emi_expense': '0',
    'insurance_premium_expense_pm': '0',
    'annual_inflation': '5',
    'amt_saved': '10000000',
    'pf_rate': '6',
    'annual_inc': '0',
    'inital_annual_amt': '0',
    'annual_increase': '0',
    'value_other_lumpsum_at_retirement': '0',
    'legacy_amt': '10000000',
    'non_market_asset': '20000000',
    'retirementGoal': []
  };
  Map<String, dynamic> _retirementDataSG = {
    'goal_name': "retirement",
    'retirement_age': '60',
    'life_expectancy': '90',
    'salary_pm': '10000',
    'annual_salary_increment': '2',
    'rentals_pm': '0',
    'otherincome_pm': '0',
    'living_expenses_pm': '6000',
    'emi_expense': '0',
    'insurance_premium_expense_pm': '0',
    'annual_inflation': '3',
    'amt_saved': '200000',
    'pf_rate': '2',
    'annual_inc': '0',
    'inital_annual_amt': '0',
    'annual_increase': '0',
    'value_other_lumpsum_at_retirement': '0',
    'legacy_amt': '1000000',
    'non_market_asset': '1000000',
    'retirementGoal': [],
    'cpfSector': 'private',
    'cpfCategory': '1',
    'cpfGrowth': '2'
  };
  Map<String, dynamic> _retirementDataUS = {
    'goal_name': "retirement",
    'retirement_age': '60',
    'life_expectancy': '90',
    'salary_pm': '10000',
    'annual_salary_increment': '2',
    'rentals_pm': '0',
    'otherincome_pm': '0',
    'living_expenses_pm': '6000',
    'emi_expense': '0',
    'insurance_premium_expense_pm': '0',
    'annual_inflation': '3',
    'amt_saved': '200000',
    'pf_rate': '2',
    'annual_inc': '0',
    'inital_annual_amt': '0',
    'annual_increase': '0',
    'value_other_lumpsum_at_retirement': '0',
    'legacy_amt': '1000000',
    'non_market_asset': '1000000',
    'retirementGoal': []
  };

  Map<String, dynamic> _retirementGoalData = {
    'IN': {
      'goal_name': "Home",
      'start_year': "2020",
      'goal_year': "2030",
      'present_value': "10000000.00",
      'goal_inflation': "5",
      'amt_saved': "2000000.00",
      'annual_increment': "4",
    },
    'SG': {
      'goal_name': "Home",
      'start_year': "2020",
      'goal_year': "2030",
      'present_value': "250000.00",
      'goal_inflation': "3",
      'amt_saved': "40000.00",
      'annual_increment': "2",
    },
    'US': {
      'goal_name': "Home",
      'start_year': "2020",
      'goal_year': "2030",
      'present_value': "300000.00",
      'goal_inflation': "3",
      'amt_saved': "50000.00",
      'annual_increment': "2",
    },
  };

  List<Map<String, dynamic>> cpfSector = [
    {'key': 'private', 'value': 'Private'},
  ];
  List<Map<String, dynamic>> cpfCategory = [
    {'key': '1', 'value': 'Singapore Citizen/3rd year SPR'},
    {'key': '2', 'value': 'Graduated Employer/Employee (1st year SPR)'},
    {'key': '3', 'value': 'Graduated Employer/Employee (2nd year SPR)'},
    {'key': '4', 'value': 'Full Employer & Graduated Employee (1st year SPR)'},
    {'key': '5', 'value': 'Full Employer & Graduated Employee (2nd year SPR)'},
  ];

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Goal Planner Page', screenClassOverride: 'GoalPlanner');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Goal Planner Page",
    });
  }

  @override
  void initState() {
    super.initState();

    _currentScreen();
    _addEvent();

    //widget.model.fetchBaskets();

    _userData['userName'] = (widget.model.isUserAuthenticated
        ? widget.model.userData.custName
        : "Guest");

    if (widget.goalType == "retirement") {
      if (widget.model.userSettings['default_zone'] == "in") {
        currency = "INR";
        _retirementData = _retirementDataIN;
        _retirementData['retirementGoal'].add(_retirementGoalData['IN']);
      } else if (widget.model.userSettings['default_zone'] == "sg") {
        currency = 'S\$';
        _retirementData = _retirementDataSG;
        _retirementData['retirementGoal'].add(_retirementGoalData['SG']);
        //_retirementData['retirementGoal'][0] = _retirementGoalData['SG'];
      } else if (widget.model.userSettings['default_zone'] == "us") {
        currency = '\$';
        _retirementData = _retirementDataUS;
        _retirementData['retirementGoal'].add(_retirementGoalData['US']);
        //_retirementData['retirementGoal'][0] = _retirementGoalData['US'];
      } else {
        log.w('Invalid default zone!');
      }
      _goalData = _retirementData;
    } else {
      if (widget.model.userSettings['default_zone'] == "in") {
        currency = "INR";
        _goalData = _goalDataIN;
      } else if (widget.model.userSettings['default_zone'] == "sg") {
        currency = 'S\$';
        _goalData = _goalDataSG;
      } else if (widget.model.userSettings['default_zone'] == "us") {
        currency = '\$';
        _goalData = _goalDataUS;
      } else {
        log.w('Invalid default zone!');
      }
    }

    loadFormData();
  }

  updateProgressHUD() {}

  Future loadFormData() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });

      if (widget.goalType == "retirement") {
        Map formData = await widget.model.getFormData(
            'form_retirement_planner_' +
                widget.model.userSettings['default_zone']);
        log.d(formData);
        if (formData['status']) {
          /* _listPortfolio = json.decode(formData['response']['form_value']['portfolioData']);
					log.d(_listPortfolio); */
          setState(() {
            _userData['userName'] =
                formData['response']['form_value']['userName'];
            _userData['age'] = formData['response']['form_value']['age'];
            _retirementData =
                json.decode(formData['response']['form_value']['goalDataRaw']);

            if (widget.model.userSettings['default_zone'] == "sg") {
              if (!_retirementData.containsKey('cpfSector')) {
                _retirementData['cpfSector'] = 'Private';
              }
              if (!_retirementData.containsKey('cpfCategory')) {
                _retirementData['cpfSector'] = '1';
              }
              if (!_retirementData.containsKey('cpfGrowth')) {
                _retirementData['cpfGrowth'] = '2';
              }
            }

            if (!_retirementData.containsKey('retirementGoal')) {
              List retirementGoalList = [];
              if (widget.model.userSettings['default_zone'] == "in") {
                retirementGoalList.add(_retirementGoalData['IN']);
              } else if (widget.model.userSettings['default_zone'] == "sg") {
                retirementGoalList.add(_retirementGoalData['SG']);
              } else if (widget.model.userSettings['default_zone'] == "us") {
                retirementGoalList.add(_retirementGoalData['US']);
              }

              _retirementData['retirementGoal'] = retirementGoalList;
            }
          });
        }
      }

      Map riskProfile = await widget.model.getFormData('risk_profiler');
      log.d(riskProfile);
      if (riskProfile['status']) {
        _userData['risk_profile'] = riskProfile['response']['form_value'];
      }

      setState(() {
        _loading = false;
        updateProgressHUD();
      });
    } else {
      updateProgressHUD();
    }
  }

  String _appBarTitle() {
    if (widget.goalType == "goal") {
      return languageText('text_goal_planner');
    } else if (widget.goalType == "retirement") {
      return languageText('text_retirement_planner');
    } else {
      return 'Planner';
    }
  }

  AppBar _appBar() {
    return AppBar(
        //centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

        title: Text(_appBarTitle(),
            style: TextStyle(color: Colors.white, fontSize: 15.0)));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        /* drawer: WidgetDrawer(), */
        appBar: _appBar(),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    _loaderStepStatus = '1';
    //return _progressHUD;
    if (widget.model.isLoading || _loading) {
      return preLoader();
    } else {
      if (widget.goalType == "goal") {
        return mainContainer(
            context: context,
            containerColor: Colors.white,
            child: _goalPlannerForm());
      } else if (widget.goalType == "retirement") {
        return mainContainer(
            context: context,
            containerColor: Colors.white,
            child: _retirementPlannerForm());
      } else {
        return Container();
      }
    }
  }

  Widget _goalPlannerForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: ListView(
          children: <Widget>[
            _buildTextField(context, "Your Name", "userName", "user",
                _userData['userName'], "text", "Full Name"),
            SizedBox(height: 10.0),
            _buildTextField(context, "Your Current Age", "age", "user",
                _userData['age'], "number", ""),
            SizedBox(height: 10.0),
            _buildSelectField(context, "Investing Style", "risk_profile",
                "user", _userData['risk_profile'], "text", ""),
            SizedBox(height: 10.0),
            _buildTextField(context, "Goal Name", "goal_name", "goal",
                _goalData['goal_name'], "text", ""),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "When would you like start investing for your goal?",
                "start_year",
                "goal",
                _goalData['start_year'],
                "number",
                ""),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "When would you like to achieve your goal?",
                "goal_year",
                "goal",
                _goalData['goal_year'],
                "number",
                ""),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "What is the cost of your goal today?",
                "present_value",
                "goal",
                _goalData['present_value'],
                "number",
                currency),
            SizedBox(height: 10.0),
            _buildTextField(context, "Goal Inflation Rate", "goal_inflation",
                "goal", _goalData['goal_inflation'], "number", "%"),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "Please input any savings that you have already done to achieve this goal?",
                "amt_saved",
                "goal",
                _goalData['amt_saved'],
                "number",
                currency),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "By how much would you like to increase your saving towards the goal each year?",
                "annual_increment",
                "goal",
                _goalData['annual_increment'],
                "number",
                "%"),
            SizedBox(height: 10.0),
            _submitButton()
          ],
        ));
  }

  Widget _retirementPlannerForm() {
    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: ListView(
          children: <Widget>[
            _buildTextField(context, "Your Name", "userName", "user",
                _userData['userName'], "text", "Full Name"),
            SizedBox(height: 10.0),
            _buildTextField(context, "Your Current Age", "age", "user",
                _userData['age'], "number", ""),
            SizedBox(height: 10.0),
            _buildSelectField(context, "Investing Style", "risk_profile",
                "user", _userData['risk_profile'], "text", ""),
            SizedBox(height: 10.0),

            /* _buildTextField(context, "Goal Name", "goal_name", "retirement", "retirement", "text"),
				SizedBox(height: 10.0), */

            _buildTextField(
                context,
                "Age at which you plan to retire",
                "retirement_age",
                "retirement",
                _retirementData['retirement_age'],
                "number",
                ""),
            SizedBox(height: 10.0),
            _buildTextField(context, "Life Expectancy", "life_expectancy",
                "retirement", _retirementData['life_expectancy'], "number", ""),
            SizedBox(height: 10.0),
            _buildTextField(context, "Salary / Pension per month", "salary_pm",
                "retirement", _retirementData['salary_pm'], "number", currency),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "Annual salary increment",
                "annual_salary_increment",
                "retirement",
                _retirementData['annual_salary_increment'],
                "number",
                "%"),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "Monthly living expenses",
                "living_expenses_pm",
                "retirement",
                _retirementData['living_expenses_pm'],
                "number",
                currency),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "Savings towards goal: Financial instruments",
                "amt_saved",
                "retirement",
                _retirementData['amt_saved'],
                "number",
                currency),
            SizedBox(height: 10.0),
            _buildTextField(
                context,
                "Non Financial instruments: e.g. House, Gold",
                "non_market_asset",
                "retirement",
                _retirementData['non_market_asset'],
                "number",
                currency),
            SizedBox(height: 10.0),
            RaisedButton(
                onPressed: () {
                  displayButtons('other');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Other Inputs',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.white)),
                    Icon(
                      (_isVisibleFlag
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down),
                      color: Colors.white,
                    )
                  ],
                )),
            Visibility(
              child: Column(
                children: <Widget>[
                  Column(
                    children: _zoneBasedFields(),
                  ),
                  _buildTextField(
                      context,
                      "Monthly income from Rentals",
                      "rentals_pm",
                      "retirement",
                      _retirementData['rentals_pm'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Other Regular Monthly Income",
                      "otherincome_pm",
                      "retirement",
                      _retirementData['otherincome_pm'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "EMI Expense",
                      "emi_expense",
                      "retirement",
                      _retirementData['emi_expense'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Insurance Premium",
                      "insurance_premium_expense_pm",
                      "retirement",
                      _retirementData['insurance_premium_expense_pm'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Annual Inflation",
                      "annual_inflation",
                      "retirement",
                      _retirementData['annual_inflation'],
                      "number",
                      "%"),
                  SizedBox(height: 10.0),
                  _buildTextField(context, "PF Rate", "pf_rate", "retirement",
                      _retirementData['pf_rate'], "number", "%"),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Annual Increase in saving for goal",
                      "annual_inc",
                      "retirement",
                      _retirementData['annual_inc'],
                      "number",
                      "%"),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Pension Amount",
                      "inital_annual_amt",
                      "retirement",
                      _retirementData['inital_annual_amt'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Pension Annual Increase",
                      "annual_increase",
                      "retirement",
                      _retirementData['annual_increase'],
                      "number",
                      "%"),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "One time corpus at retirement",
                      "value_other_lumpsum_at_retirement",
                      "retirement",
                      _retirementData['value_other_lumpsum_at_retirement'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  _buildTextField(
                      context,
                      "Legacy to bequeath",
                      "legacy_amt",
                      "retirement",
                      _retirementData['legacy_amt'],
                      "number",
                      currency),
                  SizedBox(height: 10.0),
                  SizedBox(height: 10.0),
                ],
              ),
              visible: _isVisibleFlag,
            ),
            RaisedButton(
                onPressed: () {
                  displayButtons('goal');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Goal Inputs',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.white)),
                    Icon(
                      (_isGoalVisibleFlag
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down),
                      color: Colors.white,
                    )
                  ],
                )),
            Visibility(
              child: _retirementGoals(),
              visible: _isGoalVisibleFlag,
            ),
            _submitButton()
          ],
        ));
  }

  List _zoneBasedFields() {
    List<Widget> _zoneBasedFields = [];

    if (widget.model.userSettings['default_zone'] == "sg") {
      _zoneBasedFields.add(_buildSelectFieldCustom(
          context,
          "Sector",
          "cpfSector",
          "retirement",
          cpfSector,
          cpfSector[0]['key'],
          "text",
          ""));
      _zoneBasedFields.add(SizedBox(height: 10.0));
      _zoneBasedFields.add(_buildSelectFieldCustom(
          context,
          "Category",
          "cpfCategory",
          "retirement",
          cpfCategory,
          cpfCategory[0]['key'],
          "text",
          ""));
      _zoneBasedFields.add(SizedBox(height: 10.0));
      _zoneBasedFields.add(_buildTextField(context, "Growth", "cpfGrowth",
          "retirement", _retirementData['cpfGrowth'], "number", "%"));
      _zoneBasedFields.add(SizedBox(height: 10.0));
    }

    return _zoneBasedFields;
  }

  void displayButtons(String goalType) {
    setState(() {
      if (goalType == "goal") {
        _isGoalVisibleFlag = !_isGoalVisibleFlag;
      } else if (goalType == "other") {
        _isVisibleFlag = !_isVisibleFlag;
      }
    });
  }

  Widget _retirementGoals() {
    return Column(
      children: <Widget>[
        _generateRetirementGoalList(),
        RaisedButton(
          padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          textColor: Colors.white,
          child: widgetButtonText('Add Another Goal',
              useContext: true, context: context),
          onPressed: () {
            setState(() {
              if (currentGoalCount < maxGoalLimit) {
                currentGoalCount++;
                if (widget.model.userSettings['default_zone'] == "in") {
                  _retirementData['retirementGoal']
                      .add(_retirementGoalData['IN']);
                } else if (widget.model.userSettings['default_zone'] == "sg") {
                  _retirementData['retirementGoal']
                      .add(_retirementGoalData['SG']);
                } else if (widget.model.userSettings['default_zone'] == "us") {
                  _retirementData['retirementGoal']
                      .add(_retirementGoalData['US']);
                }
              }
            });
          },
        ),
      ],
    );
  }

  Widget _generateRetirementGoalList() {
    List<Widget> _retirementGoalList = [];

    for (var i = 0; i < _retirementData['retirementGoal'].length; i++) {
      _retirementGoalList.add(_retirementGoalBox(context, i));
    }

    return Column(
      children: _retirementGoalList,
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 1.0),
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) //         <--- border radius here
          ),
    );
  }

  Widget _retirementGoalBox(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: myBoxDecoration(),
      child: Column(
        children: <Widget>[
          _buildTextField(context, "Goal Name", "goal_name", "retirementGoal",
              _retirementData['retirementGoal'][index]['goal_name'], "text", "",
              index: index),
          SizedBox(height: 10.0),
          _buildTextField(
              context,
              "When would you like start investing for your goal?",
              "start_year",
              "retirementGoal",
              _retirementData['retirementGoal'][index]['start_year'],
              "number",
              "",
              index: index),
          SizedBox(height: 10.0),
          _buildTextField(
              context,
              "When would you like to achieve your goal?",
              "goal_year",
              "retirementGoal",
              _retirementData['retirementGoal'][index]['goal_year'],
              "number",
              "",
              index: index),
          SizedBox(height: 10.0),
          _buildTextField(
              context,
              "What is the cost of your goal today?",
              "present_value",
              "retirementGoal",
              _retirementData['retirementGoal'][index]['present_value'],
              "number",
              currency,
              index: index),
          SizedBox(height: 10.0),
          _buildTextField(
              context,
              "Goal Inflation Rate",
              "goal_inflation",
              "retirementGoal",
              _retirementData['retirementGoal'][index]['goal_inflation'],
              "number",
              "%",
              index: index),
          SizedBox(height: 10.0),
          _buildTextField(
              context,
              "Please input any savings that you have already done to achieve this goal?",
              "amt_saved",
              "retirementGoal",
              _retirementData['retirementGoal'][index]['amt_saved'],
              "number",
              currency,
              index: index),
          SizedBox(height: 10.0),
          _buildTextField(
              context,
              "By how much would you like to increase your saving towards the goal each year?",
              "annual_increment",
              "retirementGoal",
              _retirementData['retirementGoal'][index]['annual_increment'],
              "number",
              "%",
              index: index),
          SizedBox(height: 10.0),
          RaisedButton(
            padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0)),
            textColor: Colors.white,
            child: widgetButtonText('Remove this Goal',
                useContext: true, context: context),
            onPressed: () {
              log.d(index);
              setState(() {
                log.d('---------------------------');
                log.d(_retirementData);
                _retirementData['retirementGoal'].removeAt(index);
                log.d(_retirementData);
                log.d('---------------------------');
                currentGoalCount--;
              });
            },
          ),
        ],
      ),
    );
  }

  initialValue(val) {
    return TextEditingController(text: val);
  }

  TextInputType keyboardType(type) {
    if (type == "number") {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  Widget _buildTextField(BuildContext context, String labelText, String key,
      String type, String defaultValue, String inputType, String suffix,
      {int index = 0}) {
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
        ),
        TextField(
            keyboardType: keyboardType(inputType),
            /* controller: initialValue(defaultValue), */
            decoration: InputDecoration(
              /* labelText: labelText, labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0), */
              border: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.teal)),
              hintText: defaultValue,
              suffixText: suffix,
            ),

            /* obscureText: true, */

            onChanged: (String value) {
              setState(() {
                if (type == "goal") {
                  _goalData[key] = value;
                } else if (type == "user") {
                  _userData[key] = value;
                } else if (type == "retirement") {
                  _retirementData[key] = value;
                } else if (type == "retirementGoal") {
                  _retirementData['retirementGoal'][index][key] = value;
                }
              });
            },
            style: Theme.of(context)
                .textTheme
                .bodyText2 // TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
        SizedBox(height: 5.0),
      ],
    );
  }

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

  String getListValue(List<Map<String, dynamic>> fieldLists, String key) {
    String returnValue = "";
    fieldLists.forEach((Map fieldList) {
      if (fieldList['key'] == key) {
        returnValue = fieldList['value'];
      }
    });
    return returnValue;
  }

  Widget _buildSelectField(BuildContext context, String labelText, String key,
      String type, String defaultValue, String inputType, String suffix) {
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
        ),
        DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
              /*  borderRadius: , */
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: DropdownButton<String>(
                isExpanded: true,
                items: riskProfiles.map((Map riskProfile) {
                  return DropdownMenuItem<String>(
                    value: riskProfile['key'],
                    child: Text(riskProfile['value']),
                  );
                }).toList(),
                hint: Text(
                  (_userData[key] != ""
                      ? getRiskProfile(_userData[key])
                      : labelText),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onChanged: (String value) {
                  setState(() {
                    if (type == "goal") {
                      _goalData[key] = value;
                    } else if (type == "user") {
                      _userData[key] = value;
                    } else if (type == "retirement") {
                      _retirementData[key] = value;
                    }
                  });
                },
              ),
            )),

        /* TextField(  
					keyboardType: keyboardType(inputType),
					decoration: InputDecoration(
						border: new OutlineInputBorder(
							borderSide: new BorderSide(color: Colors.teal)),
						hintText: defaultValue,
						suffixText: suffix,
					),
					
					style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
				), */
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _buildSelectFieldCustom(
      BuildContext context,
      String labelText,
      String key,
      String type,
      List<Map<String, dynamic>> fieldLists,
      String defaultValue,
      String inputType,
      String suffix) {
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
                    value: fieldList['key'],
                    child: Text(fieldList['value']),
                  );
                }).toList(),
                hint: Text((_retirementData[key] != ""
                    ? getListValue(fieldLists, _retirementData[key])
                    : labelText)),
                onChanged: (String value) {
                  setState(() {
                    if (type == "goal") {
                      _goalData[key] = value;
                    } else if (type == "user") {
                      _userData[key] = value;
                    } else if (type == "retirement") {
                      _retirementData[key] = value;
                    }
                  });
                },
              ),
            )),
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _submitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          textColor: Colors.white,
          child: widgetButtonText('Generate Report',
              useContext: true, context: context),
          onPressed: () {
            _loaderStepStatus = '1';
            setState(() {
              _loaderStepStatus = '1';
            });
            log.d(_loaderStepStatus);

            formResponse(model);
          },
        ),
      );
    });
  }

  void formResponse(MainModel model) async {
    //widget.model.setLoader(true);
    _loading = true;

    Map<String, dynamic> responseData = await widget.model.goalPlanner(
        widget.goalType,
        _userData,
        widget.goalType == "retirement" ? _retirementData : _goalData);

    if (responseData['status']) {
      String filePath;
      bool downloadFile = false;

      if (responseData['response']['link'] != false &&
          responseData['response']['link'] != "false") {
        downloadFile = true;
        filePath = responseData['response']['link'];
      }

      widget.model.setLoader(true);

      _loaderStepStatus = '2';
      setState(() {
        _loaderStepStatus = '2';
      });

      log.d(_loaderStepStatus);

      widget.model.setLoader(false);
      _loading = false;

      _loaderStepStatus = '0';

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReportView(widget.model, responseData,
                  downloadFile: downloadFile,
                  filePath: filePath,
                  reportType: widget.goalType)));
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  void pdfModal(BuildContext context, responseData, String filePath) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return pdfAction(context, responseData, filePath);
        });
  }

  Widget pdfAction(BuildContext context, responseData, String filePath) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.close),
          alignment: Alignment.centerRight,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/icon_report.png',
            height: 90.0,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            'Planner is ready',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Do you want to?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(height: 400.0),
          items: [1, 2, 3, 4, 5].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(color: Colors.amber),
                    child: Text(
                      'text $i',
                      style: TextStyle(fontSize: 16.0),
                    ));
              },
            );
          }).toList(),
        ),
        Divider(),
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8.0)),
                textColor: Colors.white,
                child: _widgetButtonText('View', Icon(Icons.search)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PDFScreen(widget.model, pathPDF)));
                  //FlutterPdfViewer.loadFilePath(filePath);
                },
              ),
            )),
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8.0)),
                textColor: Colors.white,
                child: _widgetButtonText('Email Me', Icon(Icons.send)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PDFEmail(widget.model, pathPDF,
                              responseData['response']['identifier'])));
                },
              ),
            ))
          ],
        )
      ],
    );
  }

  Widget _widgetButtonText(String text, Icon iconData) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      iconData,
      SizedBox(
        width: 5.0,
      ),
      Text(text,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.normal)),
    ]);
  }
}

class ReportView extends StatefulWidget {
  MainModel model;
  String pathPDF = "";
  String pathPDFLocal = "";

  Map responseData;
  bool downloadFile = false;
  String filePath = "";

  String reportType = "goal";

  ReportView(this.model, this.responseData,
      {this.filePath, this.downloadFile, this.reportType});

  @override
  State<StatefulWidget> createState() {
    return _ReportViewState();
  }
}

class _ReportViewState extends State<ReportView> {
  List childCarousel;
  bool pdfStatus = false;
  bool pdfLinkResponse;

  String pathPDFLocal = "";

  @override
  void initState() {
    super.initState();
    if (widget.downloadFile) fBuilder();
  }

  fBuilder() {
    Timer.periodic(new Duration(seconds: 5), (timer) async {
      pdfLinkResponse = await widget.model.pdfLinkResponse(widget.filePath);
      if (pdfLinkResponse) {
        timer.cancel();

        createFileOfPdfUrl(widget.filePath).then((f) {
          setState(() {
            pathPDFLocal = f.path;
            pdfStatus = true;
            log.d(f.path);
          });
        });
      }
    });
  }

  Future<File> createFileOfPdfUrl(String url) async {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future checkPDFFile() async {
    bool pdfLinkResponse;
    pdfLinkResponse = await widget.model.pdfLinkResponse(widget.filePath);
    if (pdfLinkResponse) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        createFileOfPdfUrl(widget.filePath).then((f) {
          //setState(() {
          widget.pathPDF = f.path;
          log.d(widget.pathPDF);
          //});
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        //pdfLinkResponse =  widget.model.pdfLinkResponse(filePath);
      });
    }
  }

  String _appBarTitle() {
    if (widget.reportType == "goal") {
      return languageText('text_goal_planner');
    } else if (widget.reportType == "retirement") {
      return languageText('text_retirement_planner');
    } else {
      return 'Planner';
    }
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
        //centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

        title: Text(_appBarTitle(),
            style: TextStyle(color: Colors.white, fontSize: 15.0)));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        /* drawer: WidgetDrawer(), */
        appBar: _appBar(context),
        body: _buildBody(context, widget.responseData, widget.filePath),
      );
    });
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget _buildBody(BuildContext context, responseData, String filePath) {
    childCarousel = map<Widget>(responseData['response']['images'], (index, i) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text(i['caption'],
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center),
                      SizedBox(height: 10.0),
                      Image.network(
                        i['image'],
                        fit: BoxFit.contain,
                      ), //  Text('text $i', style: TextStyle(fontSize: 16.0),)
                      SizedBox(height: 10.0),
                      Text(i['subtitle'],
                          style: Theme.of(context).textTheme.overline,
                          textAlign: TextAlign.center),
                    ],
                  )));
        },
      );
    }).toList();

    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          /* IconButton(icon: Icon(Icons.close), alignment: Alignment.centerRight, onPressed: (){
						Navigator.pop(context);
					},),
					Container(
						alignment: Alignment.center,
						child: Image.asset('assets/images/icon_report.png', height: 90.0,),
					),
					SizedBox(height: 10.0,),
					Container(
						alignment: Alignment.center,
						child: Text('Your report is ready', style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 18.0,), textAlign: TextAlign.center,),
					),
					Container(
						alignment: Alignment.center,
						padding: EdgeInsets.all(10.0),
						child: Text('Do you want to?', style: TextStyle(color: Colors.grey, fontSize: 14.0,), textAlign: TextAlign.center,),
					), */

          responseData['response']['images'].length > 1
              ? CarouselSlider(
                  items: childCarousel,
                  options: CarouselOptions(
                    height: 300.00,
                    viewportFraction: 0.9,
                  ),
                )
              : childCarousel[0],
          widget.downloadFile ? Divider() : emptyWidget,
          widget.downloadFile
              ? Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.0),
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(8.0)),
                        textColor: Colors.white,
                        child: pdfStatus
                            ? _widgetButtonText('View', Icon(Icons.search))
                            : _widgetButtonTextLoader(),
                        onPressed: () {
                          if (pdfStatus) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PDFScreen(widget.model, pathPDFLocal)));
                          }
                          //FlutterPdfViewer.loadFilePath(filePath);
                        },
                      ),
                    )),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.0),
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(8.0)),
                        textColor: Colors.white,
                        child: _widgetButtonText('Email Me', Icon(Icons.send)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PDFEmail(
                                      widget.model,
                                      widget.pathPDF,
                                      responseData['response']['identifier'])));
                        },
                      ),
                    ))
                  ],
                )
              : emptyWidget,
        ],
      ),
    );
  }

  Widget _widgetButtonTextLoader() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      )),
    ]);
  }

  Widget _widgetButtonText(String text, Icon iconData) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      iconData,
      SizedBox(
        width: 5.0,
      ),
      Text(text,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.normal)),
    ]);
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  MainModel model;

  PDFScreen(this.model, this.pathPDF);

  Widget build(BuildContext context) {
    log.d(pathPDF);
    return PDFViewerScaffold(
        appBar: AppBar(
          /* title: Text("Document"), */
          actions: <Widget>[],
        ),
        path: pathPDF);
  }
}

class PDFEmail extends StatefulWidget {
  String pathPDF = "";
  String identifier = "";
  MainModel model;

  PDFEmail(this.model, this.pathPDF, this.identifier);

  @override
  State<StatefulWidget> createState() {
    return _PDFEmailState();
  }
}

class _PDFEmailState extends State<PDFEmail> {
  String _email = "";
  Widget _progressHUD;
  bool isLoader = false;

  @override
  void initState() {
    super.initState();

    if (widget.model.isUserAuthenticated) {
      _email = widget.model.userData.emailID;
    }

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
        SizedBox(
          height: 10.0,
        ),
        Text("Sending...",
            style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          /* drawer: WidgetDrawer(), */
          appBar: AppBar(),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
            child: _buildBody(),
          ));
    });
  }

  Widget _buildBody() {
    if (isLoader) {
      return _progressHUD;
    } else {
      return pdfAction(context);
    }
  }

  Widget pdfAction(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/icon_report.png',
            height: 90.0,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            'Email my planner',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 40.0,
        ),
        _buildTextField(context, "Email Address", "", "", _email, "", ""),
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
                child: _widgetButtonText('Email Me', Icon(Icons.send)),
                onPressed: () {
                  setState(() {
                    isLoader = true;
                  });
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    formResponse();
                  });
                },
              ),
            ))
          ],
        )
      ],
    );
  }

  void formResponse() async {
    Map<String, dynamic> responseData =
        await widget.model.emailPDF(_email, "planner");

    if (responseData['status']) {
      showAlertDialogBox(context, 'Sent!', responseData['response']);
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
    setState(() {
      isLoader = false;
    });
  }

  Widget _buildTextField(BuildContext context, String labelText, String key,
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
        TextField(
          keyboardType: TextInputType.emailAddress,
          /* controller: initialValue(defaultValue), */
          decoration: InputDecoration(
            /* labelText: labelText, labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0), */
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: defaultValue,
            suffixText: suffix,
          ),

          /* obscureText: true, */

          onChanged: (String value) {
            setState(() {
              _email = value;
            });
          },
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
        ),
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _widgetButtonText(String text, Icon iconData) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      iconData,
      SizedBox(
        width: 5.0,
      ),
      Text(text,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.normal)),
    ]);
  }
}
