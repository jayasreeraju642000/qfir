import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/main_model.dart';
import '../../widgets/helpers/common_widgets.dart';
import '../../widgets/styles.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('RiskProfiler');

class RiskProfilerForSmallScreen extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  RiskProfilerForSmallScreen(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _RiskProfilerForSmallScreen();
  }
}

class _RiskProfilerForSmallScreen extends State<RiskProfilerForSmallScreen> {
  bool _loading = false;
  bool _formResponse = false;
  Map<String, dynamic> _formResponseData;

  String pageType = "intro";

  int _currentStep = 1;
  int _totalStep = 17;
  int _graphActiveTab = 0;

  Map<String, dynamic> _defaultValues = {
    "question1": 1,
    "question2": 1,
    "question3": 1,
    "question4": 1,
    "question5": 1,
    "question6": 1,
    "question7": 1,
    "question8": 1,
    "question9": 1,
    "question10": 1,
    "question11": 1,
    "question12": 1,
    "question13": 0.0, // graph 1
    "question14": 0.0, // graph 2
    "question15": 1, // mcq
    "question16": 1, // mcq
    "question17": 1, // mcq
  }; // storing default answers for each question; overwritting if changed

  Map questionData = {
    1: {
      "question": "People who know me would describe me as a cautious person",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question1"
    },
    2: {
      "question": "I feel comfortable about investing in the stock market",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question2"
    },
    3: {
      "question":
          "I generally look for safer investments, even if that means lower returns",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question3"
    },
    4: {
      "question":
          "Usually it takes me a long time to make up my mind on investment matters",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question4"
    },
    5: {
      "question": "I associate the word “risk” with the idea of “opportunity”",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question5"
    },
    6: {
      "question": "I generally prefer bank deposits to other investments",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question6"
    },
    7: {
      "question": "I find investment matters easy to understand",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question7"
    },
    8: {
      "question":
          "I’m willing to take substantial investment risk to earn substantial returns",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question8"
    },
    9: {
      "question":
          "I have little experience of investing in stocks and mutual funds",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question9"
    },
    10: {
      "question":
          "I tend to be anxious about the investment decisions I have made",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question10"
    },
    11: {
      "question":
          "I would prefer to save less and take more risks to earn extra, rather than increase the amount I am saving",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question11"
    },
    12: {
      "question":
          "I am concerned about the up and down behavior of the stock markets",
      "options": [
        "Strongly agree",
        "Agree",
        "No strong opinion",
        "Disagree",
        "Strongly disagree"
      ],
      "key": "question12"
    },
    13: {
      "question": "I’m concerned by the volatility of stockmarket investments",
      "key": "question13"
    },
    14: {
      "question": "I’m concerned by the volatility of stockmarket investments",
      "key": "question14"
    },
    15: {
      "question":
          "Once you plan and invest how soon do you wish to withdraw from your investment?",
      "options": ["Less than 3 years", "3-5 Years", "5-10 Years", "10+ Years"],
      "key": "question15"
    },
    16: {
      "question":
          "Imagine that you had made an investment for a 3-5 year period this year. If it's value goes down by 20% this year, what would you do?",
      "options": [
        "Immediately switch into a more conservative investment strategy to preserve what’s left of your investment",
        "Wait three months and, if markets continue to decline, switch to a more conservative investment strategy to preserve what’s left of your investment.",
        "Wait a year and, if markets continue to decline, switch to a more conservative investment strategy to preserve what’s left of your investment",
        "Stay with the current investment strategy recognizing that markets go up and down",
        "Buy into the market – after all it is an opportunity"
      ],
      "key": "question16"
    },
    17: {
      "question":
          "Imagine that you had made an investment for a 7-10 year period this year. If it's value goes down by 20% this year, what would you do?",
      "options": [
        "Immediately switch into a more conservative investment strategy to preserve what’s left of your investment",
        "Wait three months and, if markets continue to decline, switch to a more conservative investment strategy to preserve what’s left of your investment.",
        "Wait a year and, if markets continue to decline, switch to a more conservative investment strategy to preserve what’s left of your investment",
        "Stay with the current investment strategy recognizing that markets go up and down",
        "Buy into the market – after all it is an opportunity"
      ],
      "key": "question17"
    },
  };

  List<Map<String, dynamic>> _graphData1 = [
    {
      "caption1":
          "Win {{currencySymbol}}50,000 or Lose {{currencySymbol}}60,000",
      "data1": [
        ["", 0, 0, 0, 0],
        ["profit", 0, 50, 0, 70],
        ["loss", 0, 0, 60, 10]
      ],
      "caption2": "No gain or No loss",
      "data2": [
        ["", 120, 0, 0, 0],
        ["profit", 0, 1, 0, 70],
        ["loss", 0, 0, 1, 70]
      ],
    },
    {
      "caption1":
          "Win {{currencySymbol}}50,000 or Lose {{currencySymbol}}50,000",
      "data1": [
        ["", 0, 0, 0, 0],
        ["profit", 0, 50, 0, 70],
        ["loss", 0, 0, 50, 20]
      ],
      "caption2": "No gain or No loss",
      "data2": [
        ["", 120, 0, 0, 0],
        ["profit", 0, 1, 0, 70],
        ["loss", 0, 0, 1, 70]
      ],
    },
    {
      "caption1":
          "Win {{currencySymbol}}50,000 or Lose {{currencySymbol}}40,000",
      "data1": [
        ["", 0, 0, 0, 0],
        ["profit", 0, 50, 0, 70],
        ["loss", 0, 0, 40, 30]
      ],
      "caption2": "No gain or No loss",
      "data2": [
        ["", 120, 0, 0, 0],
        ["profit", 0, 1, 0, 70],
        ["loss", 0, 0, 1, 70]
      ],
    },
    {
      "caption1":
          "Win {{currencySymbol}}50,000 or Lose {{currencySymbol}}30,000",
      "data1": [
        ["", 0, 0, 0, 0],
        ["profit", 0, 50, 0, 70],
        ["loss", 0, 0, 30, 40]
      ],
      "caption2": "No gain or No loss",
      "data2": [
        ["", 120, 0, 0, 0],
        ["profit", 0, 1, 0, 70],
        ["loss", 0, 0, 1, 70]
      ],
    },
    {
      "caption1":
          "Win {{currencySymbol}}50,000 or Lose {{currencySymbol}}20,000",
      "data1": [
        ["", 0, 0, 0, 0],
        ["profit", 0, 50, 0, 70],
        ["loss", 0, 0, 20, 50]
      ],
      "caption2": "No gain or No loss",
      "data2": [
        ["", 120, 0, 0, 0],
        ["profit", 0, 1, 0, 70],
        ["loss", 0, 0, 1, 70]
      ],
    },
  ];

  List<Map<String, dynamic>> _graphData2 = [
    {
      "caption1": "{{currencySymbol}}40,000",
      "data1": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 50, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
      "caption2": "{{currencySymbol}}10,000",
      "data2": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 10, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
    },
    {
      "caption1": "{{currencySymbol}}40,000",
      "data1": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 50, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
      "caption2": "{{currencySymbol}}15,000",
      "data2": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 15, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
    },
    {
      "caption1": "{{currencySymbol}}40,000",
      "data1": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 50, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
      "caption2": "{{currencySymbol}}20,000",
      "data2": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 20, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
    },
    {
      "caption1": "{{currencySymbol}}40,000",
      "data1": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 50, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
      "caption2": "{{currencySymbol}}25,000",
      "data2": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 25, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
    },
    {
      "caption1": "{{currencySymbol}}40,000",
      "data1": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 50, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
      "caption2": "{{currencySymbol}}30,000",
      "data2": [
        ["", 60, 0, 0, 0],
        ["profit", 0, 30, 0, 0],
        ["loss", 0, 0, 0, 0]
      ],
    },
  ];
  int _graphSelected1 = 0;
  int _graphSelected2 = 0;

  List<charts.Series<yieldData, int>> _graphListData;
  String _graphSelector = "yield";

  String _selectedYear = '5';
  List<Map<String, String>> listYears = [
    {'value': '1', 'title': '1 Year'},
    {'value': '3', 'title': '3 Years'},
    {'value': '5', 'title': '5 Years'},
    {'value': '8', 'title': '8 Years'},
    {'value': '10', 'title': '10 Years'},
  ];

  Map<String, Color> optionBorderColor = {
    "option1": Color(0xffe9e9e9),
    "option2": Color(0xffe9e9e9),
  };
  Map<String, Color> optionBGColor = {
    "option1": Colors.white,
    "option2": Colors.white,
  };

  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Basket Page',
      screenClassOverride: 'BasketPage',
    );
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Risk Profiler",
    });
  }

  Future<Null> _analyticsRiskTolerenceFirstCurrentScreen() async {
    // log.d("\n _nalyticsRiskTolerenceFirstCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'risk_tolerance_survey',
      screenClassOverride: 'risk_tolerance_survey',
    );
  }

  Future<Null> _analyticsStratButtonEvent() async {
    // log.d("\n analyticsStratButtonEvent called \n");
    await widget.analytics.logEvent(name: 'tutorial_begin', parameters: {
      'item_id': "risk_tolerance_survey",
      'item_name': "risk_tolerance_survey_start",
      'content_type': "lets_start_button",
    });
  }

  Future<Null> _analyticsSurveyStartCurrentScreen() async {
    // log.d("\n analyticsSurveyStartCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'survey_start',
      screenClassOverride: 'survey_start',
    );
  }

  Future<Null> _analyticsStartSurveyEvent() async {
    // log.d("\n analyticsStartSurveyEvent called \n");
    await widget.analytics.logEvent(name: 'tutorial_begin', parameters: {
      'item_id': "risk_tolerance_survey",
      'item_name': "risk_tolerance_survey_start",
      'content_type': "view_survey",
    });
  }

  Future<Null> _analyticsSurveyCompletionCurrentScreen() async {
    // log.d("\n analyticsSurveyCompletionCurrentScreen called \n");
    await widget.analytics.setCurrentScreen(
      screenName: 'survey_completion',
      screenClassOverride: 'survey_completion',
    );
  }

  Future<Null> _analyticsSurvayCompletionEvent() async {
    // log.d("\n analyticsSurvayCompletionEvent called \n");
    await widget.analytics.logEvent(name: 'tutorial_complete', parameters: {
      'item_id': "risk_tolerance_survey",
      'item_name': "risk_tolerance_survey_end",
      'content_type': "click_confirm_button",
    });
  }

  Future<Null> _analyticsSurvayRetakeEvent() async {
    // log.d("\n analyticsSurvayRetakeEvent called \n");
    await widget.analytics.logEvent(name: 'tutorial_begin', parameters: {
      'item_id': "survey_completion",
      'item_name': "survey_completion_retake",
      'content_type': "click_retake_button",
    });
  }

  @override
  void initState() {
    _analyticsCurrentScreen();
    _analyticsAddEvent();

    _graphData1 = fixGraphList(_graphData1);
    _graphData2 = fixGraphList(_graphData2);
    super.initState();
  }

  List<Map<String, dynamic>> fixGraphList(
      List<Map<String, dynamic>> _graphList) {
    for (var i = 0; i < _graphList.length; i++) {
      _graphList[i]['caption1'] = _graphList[i]['caption1']
          .replaceAll('{{currencySymbol}}', widget.model.currencyFormat(''));
      _graphList[i]['caption2'] = _graphList[i]['caption2']
          .replaceAll('{{currencySymbol}}', widget.model.currencyFormat(''));
    }

    return _graphList;
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: commonAppBar(
            bgColor: Colors.white,
            automaticallyImplyLeading:
                pageType != "intro" && !_loading && !_formResponse
                    ? false
                    : true,
            leading: pageType != "intro" && !_loading && !_formResponse
                ? Container(
                    // padding: EdgeInsets.only(top: getScaledValue(20), left: getScaledValue(15)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: getScaledValue(5)),
                        child: Text(_currentStep.toString() + " / 17",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  )
                : null,
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !_loading
                      ? GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, widget.model.redirectBase),
                          child: AppbarHomeButton(),
                        )
                      : emptyWidget
                ],
              )
            ]),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else if (_formResponse) {
      return mainContainer(
          context: context,
          containerColor: Colors.white,
          paddingTop: getScaledValue(10),
          child: _formResponseWidget());
    } else {
      return mainContainer(
          context: context,
          containerColor: Colors.white,
          paddingTop: getScaledValue(10),
          paddingLeft: getScaledValue(16),
          paddingRight: getScaledValue(16),
          child:
              pageType == "intro" ? _introPage() : _buildQuestionContainer());
    }
  }

  Widget _introPage() {
    _analyticsRiskTolerenceFirstCurrentScreen();
    return Column(
      children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What is a Risk Profile", style: headline1),
            SizedBox(height: getScaledValue(11)),
            Text(
                "A Risk Profile is a quantified measure of an investor's attitude towards taking risks while investing. Every individual has a unique approach towards accepting and managing risks that come with investing their hard-earned money. It depends as much on the ability and stability of current/future incomes and expenses, as it does on the investor's temperament.",
                style: bodyText4),
            SizedBox(height: getScaledValue(14)),
            Text(
                "A Risk Profile is used by investors to assess the suitability of any potential investment opportunity, and also to design the right portfolio mix that aligns with their risk tolerance.",
                style: bodyText4),
            SizedBox(height: getScaledValue(14)),
            Text(
                "Answer a set of questions to understand your tolerance towards taking risks when investing.",
                style: bodyText4),
            SizedBox(height: getScaledValue(20)),
            Text(
                "Take your time to think through and answer, and remember, there are no right or wrong answers!",
                style: bodyText4.copyWith(fontWeight: FontWeight.bold)),
          ],
        )),
        gradientButton(
            context: context,
            caption: "Let's Start",
            onPressFunction: () {
              _analyticsStratButtonEvent();
              setState(() {
                pageType = "question";
              });
            }),
      ],
    );
  }

  Widget _buildQuestionContainer() {
    _analyticsSurveyStartCurrentScreen();
    _analyticsStartSurveyEvent();
    return Column(
      children: <Widget>[
        Expanded(flex: 1, child: _stepContainer()),
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(width: getScaledValue(120), child: _buttonBack()),
            Container(width: getScaledValue(120), child: _buttonFwd()),
          ],
        )),
      ],
    );
  }

  Widget _buttonBack() {
    return flatButtonText("Back",
        textColor: _currentStep == 1 ? Colors.grey : colorBlue,
        fontSize: getScaledValue(12),
        alignment: Alignment.centerLeft,
        onPressFunction: _currentStep == 1
            ? null
            : () {
                setState(() {
                  _currentStep = _currentStep - 1;
                });
              });
  }

  Widget _buttonFwd() {
    if (_currentStep == _totalStep) {
      return gradientButton(
          caption: "Submit",
          context: context,
          onPressFunction: () => formResponse());
    } else {
      return gradientButton(
          caption: "Next",
          context: context,
          buttonDisabled:
              _currentStep == 13 || _currentStep == 14 ? true : false,
          onPressFunction: (_currentStep == _totalStep ||
                  _currentStep == 13 ||
                  _currentStep == 14)
              ? null
              : () {
                  setState(() {
                    _currentStep = _currentStep + 1;
                  });
                });
    }
  }

  Widget _stepContainer() {
    if (_currentStep == 13) {
      return _containerStep13();
    } else if (_currentStep == 14) {
      return _containerStep14();
    } else {
      return _mcqQuestionContainer(
          questionIndex: _currentStep,
          questionKey: questionData[_currentStep]['key'],
          question: questionData[_currentStep]['question'],
          options: questionData[_currentStep]['options']);
    }
  }

  // graph 1
  Widget _containerStep13() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text:
                'Imagine the following investment opportunity : With option 1 you have an equal (50/50 chance) to ',
            style: headline6,
            children: <TextSpan>[
              TextSpan(
                  text: _graphData1[_graphSelected1]['caption1'] + ". ",
                  style: headline6),
              TextSpan(
                  text:
                      "With option 2 you will leave empty-handed, but you can't lose anything. Which option would you choose?"),
            ],
          ),
        ),
        SizedBox(height: getScaledValue(20.0)),
        Expanded(
            child: Row(
          children: <Widget>[
            optionSelector(
                questionIndex: "question13",
                optionIndex: "1",
                title: "50% probability of gain or loss",
                graphDataList: _graphData1,
                graphSelector: _graphSelected1),
            SizedBox(width: getScaledValue(14)),
            optionSelector(
                questionIndex: "question13",
                optionIndex: "2",
                title: "No gain or No loss",
                graphDataList: _graphData1,
                graphSelector: _graphSelected1),
          ],
        )),
        SizedBox(height: getScaledValue(20.0)),
      ],
    );
  }

  // graph 2
  Widget _containerStep14() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text:
                'Now imagine the following opportunity: With option 1 you have an equal (50/50) chance of either winning ',
            style: headline6,
            children: <TextSpan>[
              TextSpan(
                  text: _graphData2[_graphSelected2]['caption1'] + " ",
                  style: headline6),
              TextSpan(
                  text:
                      " or leaving empty-handed. With option 2 you are sure of making a small gain of "),
              TextSpan(
                  text: _graphData2[_graphSelected2]['caption2'] + ", ",
                  style: headline6),
              TextSpan(
                  text:
                      "but won’t lose anything. Which option would you choose?"),
            ],
          ),
        ),
        SizedBox(height: 30.0),
        Expanded(
            child: Row(
          children: <Widget>[
            optionSelector(
                questionIndex: "question14",
                optionIndex: "1",
                title: "50% probability of gain or \n 50% probability neutral",
                graphDataList: _graphData2,
                graphSelector: _graphSelected2),
            SizedBox(width: getScaledValue(14)),
            optionSelector(
                questionIndex: "question14",
                optionIndex: "2",
                title: "100% probability \n of gain",
                graphDataList: _graphData2,
                graphSelector: _graphSelected2),
          ],
        )),
        SizedBox(height: getScaledValue(20.0)),
      ],
    );
  }

  Widget optionSelector(
      {String questionIndex,
      String optionIndex,
      String title,
      dynamic graphDataList,
      int graphSelector}) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        setState(() {
          if (questionIndex == "question13") {
            if (optionIndex == "1") {
              _defaultValues[questionIndex] =
                  "option" + optionIndex + "_" + _graphSelected1.toString();
              _currentStep++;
            } else if (optionIndex == "2") {
              if (_graphSelected1 < 4) {
                _graphSelected1++;
              } else {
                _defaultValues['question13'] = "option2";
                _currentStep++;
              }
            }
          } else if (questionIndex == "question14") {
            if (optionIndex == "1") {
              if (_graphSelected2 < 4) {
                _graphSelected2++;
              } else {
                _defaultValues['question14'] = "option1";
                _currentStep++;
              }
            } else if (optionIndex == "2") {
              _defaultValues['question14'] =
                  "option2_" + _graphSelected2.toString();
              _currentStep++;
            }
          }
        });
      },
      onLongPressStart: (LongPressStartDetails) {
        setState(() {
          optionBorderColor["option" + optionIndex] = colorBlue;
        });
      },
      onLongPressEnd: (LongPressEndDetails) {
        setState(() {
          optionBorderColor["option" + optionIndex] = Color(0xffe9e9e9);
        });
      },
      child: Container(
        height: getScaledValue(300),
        padding: EdgeInsets.symmetric(vertical: getScaledValue(14)),
        decoration: BoxDecoration(
          border: Border.all(color: optionBorderColor["option" + optionIndex]),
          borderRadius: BorderRadius.circular(getScaledValue(4)),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: getScaledValue(10), vertical: getScaledValue(5)),
              child: gradientButton(
                  context: context,
                  caption: "Option " + optionIndex,
                  miniButton: true,
                  onPressFunction: () {
                    setState(() {
                      if (questionIndex == "question13") {
                        if (optionIndex == "1") {
                          _defaultValues[questionIndex] = "option" +
                              optionIndex +
                              "_" +
                              _graphSelected1.toString();
                          _currentStep++;
                        } else if (optionIndex == "2") {
                          if (_graphSelected1 < 4) {
                            _graphSelected1++;
                          } else {
                            _defaultValues['question13'] = "option2";
                            _currentStep++;
                          }
                        }
                      } else if (questionIndex == "question14") {
                        if (optionIndex == "1") {
                          if (_graphSelected2 < 4) {
                            _graphSelected2++;
                          } else {
                            _defaultValues['question14'] = "option1";
                            _currentStep++;
                          }
                        } else if (optionIndex == "2") {
                          _defaultValues['question14'] =
                              "option2_" + _graphSelected2.toString();
                          _currentStep++;
                        }
                      }
                    });
                  }),
            ),
            Expanded(
                child: StackedFillColorBarChart(_buildGraphSeriesList(
                    graphDataList,
                    graphSelector,
                    'data' + optionIndex,
                    questionIndex == "question13" ? true : false))),
            SizedBox(
                height: getScaledValue(35),
                child:
                    Text(title, textAlign: TextAlign.center, style: bodyText4)),
          ],
        ),
      ),
    ));
  }

  Widget _mcqQuestionContainer(
      {String questionKey, int questionIndex, String question, List options}) {
    List<Widget> _children = [];
    int counter = 1;

    options.forEach((element) {
      _children.add(_mcqOptions(element, questionKey, counter));
      counter++;
    });
    return ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(question, style: headline3)),
            /* SizedBox(width: getScaledValue(10)),
						Text(questionIndex.toString() + " / 17"), */
          ],
        ),
        SizedBox(height: 30.0),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _children),
      ],
    );
  }

  Widget _mcqOptions(String option, String key_question, int key_answer) {
    bool selectedOption = false;
    if (_defaultValues[key_question] == key_answer) {
      selectedOption = true;
    }
    return GestureDetector(
        onTap: () {
          setState(() {
            _defaultValues[key_question] = key_answer;
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(getScaledValue(16)),
          margin: EdgeInsets.symmetric(vertical: getScaledValue(8)),
          decoration: BoxDecoration(
            color: selectedOption ? Color(0xffeff4ff) : Colors.white,
            border: Border.all(
                width: getScaledValue(1),
                color: selectedOption ? Color(0xff034bd9) : Color(0xffe9e9e9)),
            borderRadius: BorderRadius.circular(getScaledValue(4)),
          ),
          child: Text(option, style: bodyText5),
        ));
  }

  List<charts.Series<OrdinalSales, String>> _buildGraphSeriesList(
      graphDataList, int graphSelector, String dataField, bool showLine) {
    final List<OrdinalSales> profitData = [];
    final List<OrdinalSales> lossData = [];
    final List<OrdinalSales> spacingData = [];

    for (int i = 0; i < graphDataList[graphSelector][dataField].length; i++) {
      List graphData = graphDataList[graphSelector][dataField][i];

      spacingData.add(OrdinalSales(graphData[0], graphData[4]));
      if (graphData[0] == "profit" || graphData[0] == "loss") {
        graphData[2] != 0
            ? profitData.add(OrdinalSales(graphData[0], graphData[2]))
            : "";
        graphData[3] != 0
            ? lossData.add(OrdinalSales(graphData[0], graphData[3]))
            : "";
      } else {
        profitData.add(OrdinalSales(graphData[0], graphData[2]));
        lossData.add(OrdinalSales(graphData[0], graphData[3]));
      }
      spacingData.add(OrdinalSales(' ', graphData[1]));
    }

    final lineData = [
      new OrdinalSales('', 70),
      new OrdinalSales('profit', 70),
      new OrdinalSales('loss', 70),
      new OrdinalSales(' ', 70),
    ];

    List<charts.Series<OrdinalSales, String>> _seriesList = [];
    _seriesList.add(new charts.Series<OrdinalSales, String>(
      id: 'Profit Series',
      domainFn: (OrdinalSales sales, _) => sales.year,
      measureFn: (OrdinalSales sales, _) => sales.sales,
      data: profitData,
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      fillColorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
    ));
    _seriesList.add(new charts.Series<OrdinalSales, String>(
      id: 'Loss Series',
      measureFn: (OrdinalSales sales, _) => sales.sales,
      data: lossData,
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (OrdinalSales sales, _) => sales.year,
    ));

    _seriesList.add(
      new charts.Series<OrdinalSales, String>(
          id: 'Spacing',
          domainFn: (OrdinalSales sales, _) => sales.year,
          measureFn: (OrdinalSales sales, _) => sales.sales,
          data: spacingData,
          colorFn: (_, __) => charts.MaterialPalette.transparent,
          //blue.shadeDefault, //green.shadeDefault,
          fillColorFn: (_, __) =>
              charts.MaterialPalette.transparent //blue.shadeDefault,//,
          ),
    );

    if (showLine) {
      _seriesList.add(
        new charts.Series<OrdinalSales, String>(
            id: 'Line Seperator',
            colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
            domainFn: (OrdinalSales sales, _) => sales.year,
            measureFn: (OrdinalSales sales, _) => sales.sales,
            data: lineData)
          // Configure our custom line renderer for this series.
          ..setAttribute(charts.rendererIdKey, 'customLine'),
      );
    }

    return _seriesList;
  }

  void formResponse() async {
    setState(() {
      _loading = true;
    });

    Map<String, dynamic> responseData =
        await widget.model.riskProfiler(_defaultValues);

    setState(() {
      _loading = false;
      _formResponse = true;
    });
    if (responseData['status']) {
      setState(() {
        _formResponseData = responseData;

        _graphListData = fixYieldData();
      });
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  /* Report Widgets */
  Widget infoReport() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(16), vertical: getScaledValue(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You have a",
            style: headline2,
          ),
          Text(_formResponseData['response'], style: headline1),
          Text(
            "approach towards investing",
            style: headline2,
          ),
          SizedBox(height: getScaledValue(27)),
          Text(riskProfileDescription(_formResponseData['response']),
              style: bodyText4),
        ],
      ),
    );
  }

  String riskProfileDescription(String riskProfileType) {
    switch (riskProfileType) {
      case "Conservative":
        return "You want to take minimum risks while investing. You always prefer to play it safe, even if it means you earn much less on your investments. Your only exposure to risk (that too unintentional) is likely to be through products that invest for the very long term";
        break;
      case "Moderate Conservative":
        return "You are open to taking very measured risks while investing. You mostly prefer to play it safe but are open to experimenting a little with more adventurous opportunities. However, at no point in time, you would like to lose sleep over the changing values of your investments";
        break;
      case "Moderate":
        return "You like to always keep a balance between the risks and rewards in your investment decisions. You are open to taking some risks and in lieu of that, you would like to see above-average returns. You would however find it unpalatable to see a significant drop in the value of your investments at any point";
        break;
      case "Moderately Aggressive":
        return "You have no problems in taking risks while investing, however, you stop short of outright gambling with your hard-earned money. You can stomach violent ups and downs in the value of your investments and do not mind playing the waiting game with your invested capital";
        break;
      case "Aggressive":
        return "You seek the highest returns possible whenever you invest, even if they come by taking substantial risks. You are willing to stomach even violent ups and downs in the value of your investments if there is potential for you to eventually earn more. You like to be a go-getter while investing";
        break;
      default:
        return " ";
    }
  }

  Widget expectedPerformance() {
    return Container(
      padding: EdgeInsets.all(getScaledValue(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  style: appBodyH4,
                  text: ("expected performance".toUpperCase()),
                  children: [
                TextSpan(
                    text: _selectedYear != null
                        ? " in " + _selectedYear + " year"
                        : " Select Year",
                    style: appBodyH4.copyWith(color: colorBlue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => buildSelectBoxCustom(
                          context: context,
                          value: _selectedYear,
                          title: 'Select Year',
                          options: listYears,
                          onChangeFunction: (value) => setState(() {
                                _selectedYear = value;
                              }))),
                WidgetSpan(
                  child: Icon(Icons.keyboard_arrow_down,
                      color: colorBlue, size: 14),
                ),
              ])),
          expectedPerformanceStats(
              "Returns possible",
              "per annum",
              roundDouble(_formResponseData['yieldData']
                      [int.parse(_selectedYear) - 1][1]) +
                  "%",
              "This value projects the average annual returns that you can expect from your investments over the period of your investment tenor"),
          expectedPerformanceStats(
              "Expected Risks",
              null,
              roundDouble(_formResponseData['stdevData']
                      [int.parse(_selectedYear) - 1][1]) +
                  "%",
              "This value projects the standard range around the possible returns (+/- the possible returns), within which you can expect the returns at the end of the selected investment tenor")
        ],
      ),
    );
  }

  Widget expectedPerformanceStats(
      String title, String subtitle, String value, String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getScaledValue(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: bodyText6),
              Text(value, style: bodyText6),
            ],
          ),
          subtitle != null ? Text(subtitle, style: bodyText7) : emptyWidget,
          SizedBox(height: getScaledValue(10)),
          Text(description, style: bodyText4)
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getScaledValue(16)),
      child: Row(
        children: <Widget>[
          Expanded(
              child: flatButtonText("Re-Evaluate",
                  borderColor: colorBlue,
                  textColor: colorBlue,
                  onPressFunction: () => {reInitState()})),
          SizedBox(width: getScaledValue(20)),
          Expanded(
              child: gradientButton(
                  context: context,
                  caption: "confirm",
                  onPressFunction: () => {setRiskProfile()}))
        ],
      ),
    );
  }

  reInitState() {
    setState(() {
      _defaultValues = {
        "question1": 1,
        "question2": 1,
        "question3": 1,
        "question4": 1,
        "question5": 1,
        "question6": 1,
        "question7": 1,
        "question8": 1,
        "question9": 1,
        "question10": 1,
        "question11": 1,
        "question12": 1,
        "question13": 0.0, // graph 1
        "question14": 0.0, // graph 2
        "question15": 1, // mcq
        "question16": 1, // mcq
        "question17": 1, // mcq
      };
      _currentStep = 1;
      _selectedYear = "1";
      _graphActiveTab = 0;
      _graphSelected1 = 0;
      _graphSelected2 = 0;

      pageType = "intro";
      _formResponse = false;
    });
    _analyticsSurvayRetakeEvent();
  }

  setRiskProfile() async {
    setState(() {
      _loading = true;
    });

    Map<String, dynamic> responseData =
        await widget.model.updateRiskProfile(_formResponseData['response']);

    setState(() {
      _loading = false;
    });
    if (responseData['status']) {
      await _analyticsSurvayCompletionEvent();
      customAlertBox(
          context: context,
          title: "Updated",
          description: "Your risk profile has been set for your account.",
          buttons: [
            gradientButton(
              context: context,
              caption: "Ok",
              onPressFunction: () {
                Navigator.of(context).pop(true);
                Navigator.pushReplacementNamed(context, '/home_new');
              },
            ),
          ]);
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  Widget graph() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: getScaledValue(20), vertical: getScaledValue(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customTabs(
              tabs: ['Returns', 'Volatility/Risk'],
              activeIndex: _graphActiveTab,
              onTap: (i) => {
                    setState(() {
                      if (i == 0) {
                        _graphListData = fixYieldData();
                        _graphSelector = "yield";
                      } else if (i == 1) {
                        _graphListData = fixSTDEVData();
                        _graphSelector = "stdev";
                      }
                      _graphActiveTab = i;
                    })
                  }),
          SizedBox(height: 12.0),
          SizedBox(
              height: getScaledValue(230),
              child: Container(
                  child: SimpleLineChart(_graphListData, _graphSelector))),
          Text(
              "Tap on the charts to see expected Returns and Risks for the chosen investment time period",
              style: bodyText4),
          SizedBox(height: getScaledValue(12)),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: getScaledValue(10), vertical: getScaledValue(10)),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffe9e9e9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Portfolios built for longer time periods can take higher risks and hope for better returns",
                    style: bodyText4),
                SizedBox(height: getScaledValue(7)),
                Text(
                    "*Charts based on 10 years historical multi-asset market data",
                    style: bodyText4)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _formResponseWidget() {
    _analyticsSurveyCompletionCurrentScreen();
    return ListView(
      children: [
        infoReport(),
        sectionSeparator(),
        expectedPerformance(),
        sectionSeparator(),
        graph(),
        Container(
            padding: EdgeInsets.all(getScaledValue(15)),
            child: stillHaveQuestions(
                context: context,
                title: "Have Questions",
                subtitle: "stillHaveQuestions")),
        actionButtons(),
      ],
    );
  }

  List<charts.Series<yieldData, int>> fixYieldData() {
    final List<yieldData> yieldDb = [];

    for (int i = 0; i < _formResponseData['yieldData'].length; i++) {
      yieldDb.add(yieldData(_formResponseData['yieldData'][i][0],
          _formResponseData['yieldData'][i][1]));
    }

    return [
      new charts.Series<yieldData, int>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (yieldData sales, _) => sales.goalTerm,
        measureFn: (yieldData sales, _) => sales.percentage,
        data: yieldDb,
      )
    ];
  }

  List<charts.Series<yieldData, int>> fixSTDEVData() {
    final List<yieldData> yieldDb = [];
    for (int i = 0; i < _formResponseData['stdevData'].length; i++) {
      yieldDb.add(yieldData(_formResponseData['stdevData'][i][0],
          _formResponseData['stdevData'][i][1]));
    }

    return [
      new charts.Series<yieldData, int>(
        id: 'Goal Term',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (yieldData sales, _) => sales.goalTerm,
        measureFn: (yieldData sales, _) => sales.percentage,
        data: yieldDb,
      )
    ];
  }
}

class StackedFillColorBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedFillColorBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.OrdinalComboChart(
      seriesList,
      animate: true,
      //animate,
      // Configure a stroke width to enable borders on the bars.
      defaultRenderer: new charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),

      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
      domainAxis: new charts.OrdinalAxisSpec(
          showAxisLine: false, renderSpec: new charts.NoneRenderSpec()),

      customSeriesRenderers: [
        new charts.LineRendererConfig(customRendererId: 'customLine')
      ],
    );
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  static String pointerValue;

  final String graphSelector;

  SimpleLineChart(this.seriesList, this.graphSelector, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList,
        animate: animate,
        domainAxis: charts.NumericAxisSpec(
          showAxisLine: true,
          //renderSpec: charts.NoneRenderSpec(),
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            showAxisLine: true,
            renderSpec: charts.GridlineRendererSpec(
              lineStyle: charts.LineStyleSpec(
                  thickness: 0,
                  color: charts.ColorUtil.fromDartColor(Colors.white)),
              axisLineStyle: charts.LineStyleSpec(
                  thickness: 1,
                  color: charts.ColorUtil.fromDartColor(Colors.black)),
            )),
        selectionModels: [
          charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue = roundDouble(datumPair.datum.percentage) +
                    "% in " +
                    datumPair.datum.goalTerm.toString() +
                    (datumPair.datum.goalTerm > 1 ? " yrs" : " yr");
              });
            }
          })
        ],
        behaviors: [
          charts.SelectNearest(
              eventTrigger: charts.SelectionTrigger.tapAndDrag),
          charts.LinePointHighlighter(
              showHorizontalFollowLine:
                  charts.LinePointHighlighterFollowLineType.all,
              showVerticalFollowLine:
                  charts.LinePointHighlighterFollowLineType.all,
              symbolRenderer: CustomCircleSymbolRenderer()),
          new charts.ChartTitle(
              graphSelector == "yield"
                  ? 'Possible returns per annum (in %)'
                  : 'Expected Volatility (in %)',
              behaviorPosition: charts.BehaviorPosition.start,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
              titleOutsideJustification:
                  charts.OutsideJustification.endDrawArea),
          new charts.ChartTitle('Investment Time period (in years)',
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
              titleOutsideJustification:
                  charts.OutsideJustification.endDrawArea),
        ]);
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    int positionBox = 5;
    int positionText = 5;

    if (bounds.left + bounds.width + 120 > 300) {
      positionBox = 120;
      positionText = -110;
    }
    //canvas.drawRRect(bounds)

    canvas.drawRect(
      Rectangle(bounds.left - positionBox, bounds.top - 25, bounds.width + 110,
          bounds.height + 25),
      fill: charts.ColorUtil.fromDartColor(Color((0xff1772ff))),
      //radius: 4,
    );

    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontFamily = 'nunito';
    textStyle.fontSize = 13;

    canvas.drawText(TextElement(SimpleLineChart.pointerValue, style: textStyle),
        (bounds.left + positionText).round(), (bounds.top - 13).round());
  }
}

class yieldData {
  final int goalTerm;
  final double percentage;

  yieldData(this.goalTerm, this.percentage);
}
