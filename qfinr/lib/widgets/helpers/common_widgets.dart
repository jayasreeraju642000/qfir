import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/details/common_widgets_analyse_details.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../styles.dart';
import '../widget_common.dart';

final log = getLogger('common_widgets');

Widget statsRow(
    {String title,
    String description,
    String value1,
    String value2,
    bool includeBottomBorder = false}) {
  return Container(
    padding: EdgeInsets.symmetric(
        vertical: getScaledValue(13), horizontal: getScaledValue(8)),
    decoration: BoxDecoration(
        border: includeBottomBorder
            ? Border(
                bottom: BorderSide(
                color: Color(0xffdadada),
                width: 1.0,
              ))
            : null),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: keyStatsBodyText1),
              description != null
                  ? Text(description, style: keyStatsBodyText2)
                  : emptyWidget,
            ],
          ),
        ),
        Text(value1, style: keyStatsBodyText1),
        value2 != null ? SizedBox(width: getScaledValue(22)) : emptyWidget,
        value2 != null ? Text(value2, style: keyStatsBodyText2) : emptyWidget,
      ],
    ),
  );
}

Widget statsRow2(
    {String title, String value1, bool includeBottomBorder = false}) {
  return Container(
    padding: EdgeInsets.symmetric(
        vertical: getScaledValue(9), horizontal: getScaledValue(8)),
    decoration: includeBottomBorder
        ? BoxDecoration(
            border: Border(
                bottom: BorderSide(
            color: Color(0xffdadada),
            width: 1.0,
          )))
        : null,
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: keyStatsBodyText3),
            ],
          ),
        ),
        Text(value1, style: keyStatsBodyText4),
      ],
    ),
  );
}

Widget sectionSeparator({Color color, double height}) {
  return Container(
    color: color != null ? color : Color(0xffecf1fa),
    height: height != null ? getScaledValue(height) : getScaledValue(6),
  );
}

Widget stillHaveQuestions(
    {BuildContext context,
    String title = "Still have questions?",
    String subtitle = "Read here >"}) {
  return GestureDetector(
    onTap: () async {
      const url = 'https://www.qfinr.com/faq/';
      if (await canLaunch(url)) {
        await FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
          'item_id': "home",
          'item_name': "home_have_questions",
          'content_type': "query_button",
        });
        await launch(url, forceWebView: true, enableJavaScript: true);
      }
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: getScaledValue(65)),
      padding: EdgeInsets.only(
          left: getScaledValue(19),
          top: getScaledValue(10),
          bottom: getScaledValue(10)),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffffd24e), Color(0xfff3dc31)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(5.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: stillHaveQuestionsTitle),
              Text(subtitle, style: stillHaveQuestionsSubtitle)
            ],
          )),
          svgImage("assets/icon/question.svg")
        ],
      ),
    ),
  );
}

Widget starScore({dynamic score, double total = 5}) {
  List<Widget> children = [];
  if (score == "nan" || score == null) {
    return Text("Not Rated");
  }
  if (score is String) {
    score = double.parse(score);
  }
  for (double i = 1; i <= total; i++) {
    if (i <= score) {
      children.add(svgImage("assets/icon/star_filled.svg"));
    } else {
      children.add(svgImage("assets/icon/star_empty.svg"));
    }
  }

  return Row(
    children: children,
  );
}

Widget widgetRating(
    {BuildContext context,
    String title,
    String description,
    dynamic score = 1,
    dynamic total = 5}) {
  List<Widget> _children = [];

  if (score != null && score != "nan") {
    score = double.parse(score);
  }

  for (dynamic i = 1; i <= total; i++) {
    _children.add(
      Expanded(
        child: Container(
          margin: EdgeInsets.only(left: getScaledValue(i != 1 ? 6 : 0)),
          child: Column(
            children: [
              Container(
                color: i == score ? Color(0xffe8cf13) : Color(0xffe4e4e4),
                height: getScaledValue(5),
                // width: getScaledValue(45),
              ),
              Text(i.toString(), style: bodyText7),
            ],
          ),
        ),
      ),
    );
  }

  return Container(
    padding: EdgeInsets.symmetric(
      vertical: getScaledValue(8),
      horizontal: getScaledValue(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            SizedBox(width: getScaledValue(5)),
            Tooltip(
              padding: EdgeInsets.all(10),
              textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              message: "$title\n$description",
              child: InkWell(
                onTap: () => bottomAlertBox(
                    context: context, title: title, description: description),
                child: svgImage(
                  'assets/icon/information.svg',
                  width: getScaledValue(9),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: getScaledValue(6)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _children,
        )
      ],
    ),
  );
}

Widget widgetRatingLarge(
    {BuildContext context,
    String title,
    String description,
    dynamic score = 1,
    dynamic total = 5}) {
  List<Widget> _children = [];

  if (score != null && score != "nan") {
    score = double.parse(score);
  }

  for (dynamic i = 1; i <= total; i++) {
    _children.add(Expanded(
        child: Container(
      margin: EdgeInsets.only(left: getScaledValue(i != 1 ? 6 : 0)),
      child: Column(
        children: [
          Container(
              color: i == score ? Color(0xffe8cf13) : Color(0xffe4e4e4),
              height: getScaledValue(5),
              width: getScaledValue(80)),
          Text(i.toString(), style: bodyText7),
        ],
      ),
    )));
  }

  return Container(
    padding: EdgeInsets.only(
        left: getScaledValue(30),
        top: getScaledValue(12),
        right: getScaledValue(30),
        bottom: 0.0),
    //padding:  EdgeInsets.symmetric(vertical: getScaledValue(8), horizontal: getScaledValue(15)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: getScaledValue(12)),
        Row(
          children: [
            Text(title, style: bodyText1_analyse),
            SizedBox(width: getScaledValue(5)),
            Tooltip(
              padding: EdgeInsets.all(10),
              textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              message: "$title\n$description",
              child: InkWell(
                onTap: () => bottomAlertBoxLargeAnalyse(
                    context: context, title: title, description: description),
                child: svgImage('assets/icon/information.svg',
                    width: getScaledValue(9)),
              ),
            )
          ],
        ),
        SizedBox(height: getScaledValue(12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _children,
        )
      ],
    ),
  );
}

Widget widgetRiskRating(
    {BuildContext context,
    String title,
    String description,
    dynamic score = 1,
    dynamic total = 7}) {
  List<Widget> _children = [];

  if (score == "nan" || score == null) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: getScaledValue(8), horizontal: getScaledValue(15)),
        color: Color(0xfff3f3f3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text(title),
              SizedBox(width: getScaledValue(5)),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message: "$title\n$description",
                child: InkWell(
                  onTap: () => bottomAlertBoxLargeAnalyse(
                      context: context, title: title, description: description),
                  child: svgImage('assets/icon/information.svg',
                      width: getScaledValue(9)),
                ),
              )
            ],
          ),
          SizedBox(height: getScaledValue(6)),
          Text(
            'Not Rated',
            textAlign: TextAlign.center,
          ),
        ]));
  }

  Map colorArray = {
    1: Color(0xff63ce48),
    2: Color(0xff80d53a),
    3: Color(0xffddd938),
    4: Color(0xffedc63d),
    5: Color(0xffed8f3d),
    6: Color(0xffeb6555),
    7: Color(0xffce3a3a),
  };

  for (dynamic i = 1; i <= total; i++) {
    _children.add(
      Expanded(
        child: Container(
          margin: EdgeInsets.only(left: getScaledValue(i != 1 ? 6 : 0)),
          child: Column(
            children: [
              Container(
                color: i == double.parse(score)
                    ? colorArray[i]
                    : colorArray[i].withOpacity(0.4),
                height: getScaledValue(i == double.parse(score) ? 10 : 5),
                // width: getScaledValue(30),
              ),
              Text(i.toString(), style: bodyText7),
            ],
          ),
        ),
      ),
    );
  }

  return Container(
    padding: EdgeInsets.symmetric(
        vertical: getScaledValue(8), horizontal: getScaledValue(15)),
    color: Color(0xfff3f3f3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            SizedBox(width: getScaledValue(5)),
            Tooltip(
              padding: EdgeInsets.all(10),
              textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              message: "$title\n$description",
              child: InkWell(
                onTap: () => bottomAlertBox(
                    context: context, title: title, description: description),
                child: svgImage('assets/icon/information.svg',
                    width: getScaledValue(9)),
              ),
            )
          ],
        ),
        SizedBox(height: getScaledValue(6)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _children,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lower risk', style: bodyText7),
            Text('Higher risk', style: bodyText7),
          ],
        )
      ],
    ),
  );
}

Widget widgetRiskRatingLarge(
    {BuildContext context,
    String title,
    String description,
    dynamic score = 1,
    dynamic total = 7}) {
  List<Widget> _children = [];

  if (score == "nan" || score == null) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: getScaledValue(8), horizontal: getScaledValue(15)),
        color: Color(0xfff3f3f3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: getScaledValue(12)),
          Row(
            children: [
              Text(title, style: bodyText1_analyse),
              SizedBox(width: getScaledValue(5)),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message: "$title\n$description",
                child: InkWell(
                  onTap: () => bottomAlertBoxLargeAnalyse(
                      context: context, title: title, description: description),
                  child: svgImage('assets/icon/information.svg',
                      width: getScaledValue(9)),
                ),
              )
            ],
          ),
          SizedBox(height: getScaledValue(12)),
          Text(
            'Not Rated',
            textAlign: TextAlign.center,
          ),
        ]));
  }

  Map colorArray = {
    1: Color(0xff63ce48),
    2: Color(0xff80d53a),
    3: Color(0xffddd938),
    4: Color(0xffedc63d),
    5: Color(0xffed8f3d),
    6: Color(0xffeb6555),
    7: Color(0xffce3a3a),
  };

  for (dynamic i = 1; i <= total; i++) {
    _children.add(Expanded(
        child: Container(
      margin: EdgeInsets.only(left: getScaledValue(i != 1 ? 6 : 0)),
      child: Column(
        children: [
          Container(
              color: i == double.parse(score)
                  ? colorArray[i]
                  : colorArray[i].withOpacity(0.4),
              height: getScaledValue(i == double.parse(score) ? 10 : 5),
              width: getScaledValue(37)),
          Text(i.toString(), style: bodyText7),
        ],
      ),
    )));
  }

  return Container(
    padding: EdgeInsets.symmetric(
        vertical: getScaledValue(8), horizontal: getScaledValue(15)),
    color: Color(0xfff3f3f3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: getScaledValue(6)),
        Row(
          children: [
            Text(title, style: bodyText1_analyse),
            SizedBox(width: getScaledValue(5)),
            Tooltip(
              padding: EdgeInsets.all(10),
              textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              message: "$title\n$description",
              child: InkWell(
                onTap: () => bottomAlertBoxLargeAnalyse(
                    context: context, title: title, description: description),
                child: svgImage('assets/icon/information.svg',
                    width: getScaledValue(9)),
              ),
            )
          ],
        ),
        SizedBox(height: getScaledValue(6)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _children,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lower risk', style: bodyText7),
            Text('Higher risk', style: bodyText7),
          ],
        )
      ],
    ),
  );
}

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  final int speed;
  ExpandedSection({this.expand = false, this.child, this.speed = 0});

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.speed));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}

Widget dividendRow(
    {String title,
    String value1,
    String value2,
    bool includeBottomBorder = false}) {
  return Container(
    padding: EdgeInsets.symmetric(
        vertical: getScaledValue(13), horizontal: getScaledValue(8)),
    decoration: BoxDecoration(
        border: includeBottomBorder
            ? Border(
                bottom: BorderSide(
                color: Color(0xffdadada),
                width: 1.0,
              ))
            : null),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: keyStatsBodyText1),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value1, style: keyStatsBodyText1),
            value2 != null ? SizedBox(width: getScaledValue(22)) : emptyWidget,
            value2 != null
                ? Text(value2, style: keyStatsBodyText2)
                : emptyWidget,
          ],
        )
      ],
    ),
  );
}

String fundTypeCaption(String fundTypeKey) {
  Map fundType = {
    'funds': 'Mutual Fund',
    'etf': 'ETF',
    'stocks': 'Stocks',
    'bonds': 'Bonds',
    'commodity': 'Commodity'
  };
  return fundType[fundTypeKey];
}
