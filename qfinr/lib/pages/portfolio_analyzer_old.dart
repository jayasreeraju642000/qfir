import 'dart:async';
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
import '../widgets/widget_portfolio_master_selector.dart';

final log = getLogger('PortfolioAnalyzerOld');

class PortfolioAnalyzerOld extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  PortfolioAnalyzerOld(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerOldState();
  }
}

class _PortfolioAnalyzerOldState extends State<PortfolioAnalyzerOld> {
  Widget _progressHUD;
  bool _loading = false;
  bool _formResponse = false;
  Map<String, dynamic> _formResponseData;

  String pathPDF = "";

  Map<String, dynamic> _userData = {
    'risk_profile': "moderate",
    'benchmark': "No Benchmark",
  };
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

  Future<Null> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Porfolio Analyzer Page',
        screenClassOverride: 'PortfolioAnalyzer');
  }

  Future<Null> _addEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Portfolio Analyzer Page",
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
    await widget.model.getZoneBenchmarks();
  }

  AppBar _appBar() {
    return AppBar(
      //centerTitle: true,
      backgroundColor: Theme.of(context)
          .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

      title: Text(languageText('text_portfolio_analyzer'),
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
        Expanded(child: WidgetPortfolioMasterSelector(widget.model)),
        Container(
            padding: EdgeInsets.only(
                top: 0.0, left: 20.0, right: 20.0, bottom: 10.0),
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                    child: _buildSelectField("Benchmark", "benchmark",
                        datasets: widget.model.zoneBenchmarks,
                        datasetKey: "market",
                        datasetValue: "market")),
                Expanded(child: _buttonSubmit())
              ],
            )),
      ],
    );
  }

  Widget _buildSelectField(String labelText, String key,
      {List<Map> datasets, String datasetKey, String datasetValue}) {
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
          width: 5.0,
        ),
        DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
              /*  borderRadius: , */
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              child: DropdownButton<String>(
                isExpanded: true,
                items: datasets.map((datasetMap) {
                  return DropdownMenuItem<String>(
                    value: datasetMap[datasetKey],
                    child: Text(datasetMap[datasetValue]),
                  );
                }).toList(),
                hint: Text(
                    (_userData['benchmark'] != ""
                        ? getListValue(datasets, _userData['benchmark'],
                            matchKey: datasetKey, returnKey: datasetKey)
                        : labelText),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey[600])),
                onChanged: (String value) {
                  setState(() {
                    _userData['benchmark'] = value;
                  });
                },
              ),
            )),
      ],
    );
  }

  Widget _buttonSubmit() {
    return Container(
        margin: EdgeInsets.only(top: 0.0, left: 10.0, right: 0.0),
        child: RaisedButton(
            child: Text(
              "Submit ",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: widget.model.userPortfoliosByType.isEmpty
                ? null
                : () => formResponse()));
  }

  void formResponse() async {
    setState(() {
      _loading = true;
    });

    Map<String, dynamic> responseData = await widget.model.analyzerPortfolio(
        {
          'risk_profile': widget.model.newUserRiskProfile,
          'benchmark': _userData['benchmark']
        },
        widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios']);

    if (responseData['status']) {
      String filePath;
      bool downloadFile = false;
      if (responseData['response']['link'] != false &&
          responseData['response']['link'] != "false") {
        downloadFile = true;
        filePath = responseData['response']['link'];
      }

      setState(() {
        _loading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReportView(widget.model, responseData,
                  downloadFile: downloadFile, filePath: filePath)));

      /* 
			Future.delayed(const Duration(milliseconds: 1500), () {
				createFileOfPdfUrl(filePath).then((f) {
					setState(() {
						pathPDF = f.path;
						log.d(pathPDF);
						
						setState(() {
							_loading = false;
							//_formResponse = true;
						});
					});
					Navigator.push(context, MaterialPageRoute(builder: (context) => ReportView(widget.model, pathPDF, responseData, filePath)));
				});
			});
			 */

      /* setState(() {
			  	_formResponseData =  responseData;
			}); */
      //showAlertDialogBox(context, 'File Created', responseData['response']);
    } else {
      setState(() {
        _loading = false;
        //_formResponse = true;
      });
      //showAlertDialogBox(context, 'Error!', responseData['response']);
    }
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
            'Portfolio Analysis is ready',
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
  String pathPDF = "";
  String pathPDFLocal = "";

  Map responseData;
  bool downloadFile = false;
  String filePath = "";

  ReportView(this.model, this.responseData, {this.filePath, this.downloadFile});

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

  AppBar _appBar(BuildContext context) {
    return AppBar(
        //centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //

        title: Text("Portfolio Analyzer",
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
            child: _buildBody(context, widget.responseData, widget.filePath)),
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
                      Image.network(
                        i['image'],
                        fit: BoxFit.contain,
                      ), //  Text('text $i', style: TextStyle(fontSize: 16.0),)
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PDFScreen(widget.model, pathPDFLocal)));
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
              : emptyWidget
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
            'Email my Portfolio Analysis',
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
        await widget.model.emailPDF(_email, "portfolio");

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
