import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/widget_portfolio_master_selector.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('PortfolioDividend');

class PortfolioDividend extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  PortfolioDividend(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioDividendState();
  }
}

class _PortfolioDividendState extends State<PortfolioDividend> {
  Widget _progressHUD;
  bool _loading = false;
  bool _formResponse = false;
  Map<String, dynamic> _formResponseData;

  String pathPDF = "";

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Portfolio Dividend Page',
        screenClassOverride: 'PortfolioDividend');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Dividend Page",
    });
  }

  @override
  void initState() {
    super.initState();

    _currentScreen();
    _addEvent();

    _progressHUD = new Center(
      child: new CircularProgressIndicator(),
    );

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
      ],
    );

    loadFormData();
  }

  Future loadFormData() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });

      setState(() {
        _loading = false;
      });
    }
  }

  AppBar _appBar() {
    return AppBar(
      //centerTitle: true,
      backgroundColor: Theme.of(context)
          .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

      title: Text(languageText('text_portfolio_dividend'),
          style: TextStyle(color: Colors.white, fontSize: 15.0)),
      actions: <Widget>[
        widget.model.isUserAuthenticated
            ? IconButton(
                icon: Icon(Icons.business_center),
                onPressed: () {
                  Navigator.pushNamed(context, '/manage_portfolio_master');
                },
              )
            : emptyWidget,
      ],
    );
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
    if (_loading) {
      return _progressHUD;
    } else if (_formResponse) {
      return _formResponseWidget();
    } else {
      return mainContainer(
          context: context,
          child:
              _buildBodyContent()); //_autocompleteTextField(); //_buildBodyContent();

    }
  }

  Widget _buildBodyContent() {
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        /* Expanded(
						child: WidgetPortfolioNew(widget.model, showPortfolio: false, fundType: "all", showRiskProfile: false)
					), */
        Expanded(child: WidgetPortfolioMasterSelector(widget.model)),
        Container(padding: EdgeInsets.only(top: 15.0), child: _buttonSubmit()),
      ],
    );
  }

  Widget _buttonSubmit() {
    return RaisedButton(
        child: Text(
          "Submit ",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: widget.model.userPortfoliosByType.isEmpty
            ? null
            : () => formResponse());
  }

  void formResponse() async {
    setState(() {
      _loading = true;
    });

    Map<String, dynamic> responseData = await widget.model.dividendPortfolio(
        widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios']);

    if (responseData['status']) {
      setState(() {
        _loading = false;
      });
      // log.d('debug 194');
      // log.d(responseData);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReportView(widget.model, responseData)));
    } else {
      setState(() {
        _loading = false;
        //_formResponse = true;
      });
      showAlertDialogBox(context, 'Error!', responseData['response']);
    }
  }

  Widget _formResponseWidget() {
    return Flex(
      direction: Axis.vertical,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 30.0),
        Center(
          child: Text(
            'Your risk profile is:',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        SizedBox(height: 20.0),
        Center(
          child: Text(
            _formResponseData['response'],
            style: TextStyle(
                fontSize: 22.0,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

class ReportView extends StatefulWidget {
  MainModel model;

  Map responseData;

  ReportView(this.model, this.responseData);

  @override
  State<StatefulWidget> createState() {
    return _ReportViewState();
  }
}

class _ReportViewState extends State<ReportView> {
  String _dividendTenure = "";
  Map dividendDetails;

  @override
  void initState() {
    super.initState();
    dividendDetails =
        widget.responseData['response']['graphData']['dividendDetails'];
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
        //centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

        title: Text("Forecasted Dividends",
            style: TextStyle(color: Colors.white, fontSize: 15.0)));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        /* drawer: WidgetDrawer(), */
        appBar: _appBar(context),
        body: mainContainer(
            context: context,
            child: widget.responseData['response']['graphData'].isEmpty
                ? _buildBodyEmptyList(context)
                : _buildBody(context, widget.responseData)),
      );
    });
  }

  Widget _buildBodyEmptyList(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            child: Text("No dividend data found for coming 6 months"))
      ],
    );
  }

  Widget _buildBody(BuildContext context, responseData) {
    List<charts.Series<OrdinalSales, String>> chartData =
        chartDataList(responseData['response']['graphData']); //@todo

    return Container(
      padding: EdgeInsets.all(20.0),
      //height: MediaQuery.of(context).size.height,
      child: //SelectionUserManaged(chartData, dividendDetails: responseData['response']['graphData']['dividendDetails']),
          Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Forecasted Dividends",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Text(
            "total over next 6 months: " +
                responseData['response']['totalDividends'],
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          Container(
              child: SelectionUserManaged(chartData,
                  dividendDetails: responseData['response']['graphData']
                      ['dividendDetails'])),
          SizedBox(height: 30.0),
          _basketPerformanceBtns(),
          _dividendTenure != ""
              ? Expanded(child: showDividendDetails())
              : emptyWidget
        ],
      ),
    );
  }

  List<charts.Series<OrdinalSales, String>> chartDataList(graphData) {
    final List<OrdinalSales> graphDataList = [];

    for (var index = 0; index < graphData['graphValue'].length; index++) {
      String graphDate = graphData['graphValue'][index][0].toString();
      double graphValue = graphData['graphValue'][index][2].toDouble();

      graphDataList.add(new OrdinalSales(graphDate, graphValue));
    }

    List<charts.Series<OrdinalSales, String>> chartDataList = [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: graphDataList,
      )
    ];

    return chartDataList;
  }

  Widget _basketPerformanceBtns() {
    List<Widget> buttonLists = [];
    for (var value in widget.responseData['response']['graphData']
        ['graphValue']) {
      if (_dividendTenure == "") {
        _dividendTenure = value[0];
      }
      buttonLists.add(_performanceButton(value[0], value[0]));
    }

    return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 50.0,
        ),
        child: Center(
            child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: buttonLists)));
  }

  Widget _performanceButton(String title, String index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.0),
      child: ButtonTheme(
          minWidth: 47.3,
          padding: EdgeInsets.all(0.0),
          child: RaisedButton(
            padding: EdgeInsets.all(10.0),
            color: Theme.of(context).primaryColor,
            child: Text(title,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: _dividendTenure == index
                          ? Colors.amber
                          : Colors.white,
                    )),
            onPressed: () {
              setState(() {
                _dividendTenure = index;
              });
            },
          )),
    );
  }

  Widget _textStyle(String key,
      {bool header = false, TextAlign alignment = TextAlign.left}) {
    return Text(key,
        textAlign: alignment,
        style: (header == true
            ? Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.black)
            : Theme.of(context).textTheme.bodyText2),
        softWrap: true);
  }

  Widget showDividendDetails() {
    final List dividendData = dividendDetails[_dividendTenure];

    final children = <Widget>[];
    final children2 = <Widget>[];
    children.add(Container(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(child: _textStyle('Stock Name', header: true)),
            Expanded(
                child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(child: _textStyle('Date', header: true)),
                Expanded(
                    child: _textStyle('Total Amount',
                        header: true, alignment: TextAlign.right)),
              ],
            ))
          ],
        )));
    for (int i = 0; i < dividendData.length; i++) {
      //for(int j=1; j < 14; j++){
      children2.add(Divider(height: 10.0));
      children2.add(
        Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                    child: _textStyle(dividendData[i]['ric_name'].toString())),
                Expanded(
                    child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                        child: _textStyle(dividendData[i]['date'].toString())),
                    Expanded(
                        child: _textStyle(dividendData[i]['total_dividend'],
                            alignment: TextAlign.right)),
                  ],
                ))
              ],
            )),
      );
    } //}

    /* return ListView(
			shrinkWrap: true,
			children: children,
		); */
    return Container(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flex(
                  direction: Axis.vertical,
                  children: children,
                ),
                Expanded(
                  child: ListView(
                    //direction: Axis.vertical,
                    children: children2,
                  ),
                )
              ],
            )));
  }
}

class SelectionUserManaged extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final dividendDetails;

  SelectionUserManaged(this.seriesList, {this.animate, this.dividendDetails});

  /// Creates a [BarChart] with sample data and no transition.
  factory SelectionUserManaged.withSampleData() {
    return new SelectionUserManaged(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('2014', 5.0),
      new OrdinalSales('2015', 25.0),
      new OrdinalSales('2016', 100.0),
      new OrdinalSales('2017', 75.0),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  @override
  SelectionUserManagedState createState() {
    return new SelectionUserManagedState();
  }
}

class SelectionUserManagedState extends State<SelectionUserManaged> {
  final _myState = new charts.UserManagedState<String>();
  String dataString = "";

  @override
  Widget build(BuildContext context) {
    final chart = new charts.BarChart(
      widget.seriesList,
      /* domainAxis: charts.OrdinalAxisSpec(
					renderSpec: charts.SmallTickRendererSpec(labelRotation: 60, ),
			), */
      /* domainAxis: new charts.OrdinalAxisSpec(
                    viewport: new charts.OrdinalViewport('AePS', 3),
                ), */
      animate: true, //widget.animate,
      selectionModels: [
        new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            updatedListener: _infoSelectionModelUpdated)
      ],
      // Pass in the state you manage to the chart. This will be used to
      // override the internal chart state.
      userManagedState: _myState,
      // The initial selection can still be optionally added by adding the
      // initial selection behavior.
      behaviors: [
        //new charts.SeriesLegend(),
        new charts.SlidingViewport(),
        new charts.PanAndZoomBehavior(),

        /* new charts.InitialSelection(selectedDataConfig: [
				new charts.SeriesDatumConfig<String>('Sales', '2016')
				]) */
      ],
    );

    final children = [
      new SizedBox(
          child: chart, height: MediaQuery.of(context).size.height * 0.30),
      //_displayData ? showDividendDetails(context) : emptyWidget
    ];

    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  void _infoSelectionModelUpdated(charts.SelectionModel<String> model) {
    // If you want to allow the chart to continue to respond to select events
    // that update the selection, add an updatedListener that saves off the
    // selection model each time the selection model is updated, regardless of
    // if there are changes.
    //
    // This also allows you to listen to the selection model update events and
    // alter the selection.

    if (model.hasDatumSelection) {
      setState(() {
        dataString = model.selectedDatum.first.datum.year;
      });
      //showDividendDetails(_globalContext, model.selectedDatum.first.datum.year);
    }
    _myState.selectionModels[charts.SelectionModelType.info] =
        new charts.UserManagedSelectionModel(model: model);
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final double sales;

  OrdinalSales(this.year, this.sales);
}
