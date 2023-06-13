import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

final log = getLogger('PortfolioMasterSelector');

class BenchmarkSelectorLarge extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  final Map selectedPortfolioMasterIDs;

  BenchmarkSelectorLarge(this.model,
      {this.analytics,
      this.observer,
      this.action = "",
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _BenchmarkSelectorState();
  }
}

class _BenchmarkSelectorState extends State<BenchmarkSelectorLarge> {
  final controller = ScrollController();
  bool benchMarkAnalyzeLoader = false;

  String _selectedBenchmarks = "";
  Map benchmarks = {};
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedZone = "in";
  Map zoneBenchmarks = {};
  Map zoneBenchmarks_old = {
    "in": {
      'NIFTY50': {
        'value': 'NIFTY 50',
        'zone': 'in',
        'description':
            'An Index of top 50 companies listed on NSE, based on their free-float market-caps'
      },
      'NIFTY100': {
        'value': 'NIFTY 100',
        'zone': 'in',
        'description':
            'An Index of top 100 companies listed on NSE, based on their full market-caps'
      },
      'BSE200': {
        'value': 'BSE 200',
        'zone': 'in',
        'description':
            'An Index of top 200 companies listed on BSE, based on their free-float market-caps'
      },
      'NIFTY500': {
        'value': 'NIFTY 500',
        'zone': 'in',
        'description':
            'An Index of top 500 companies listed on NSE, based on their full market-caps'
      },
    },
    "us": {
      'GSPC': {
        'value': 'S&P 500 PR',
        'zone': 'us',
        'description':
            'An Index of top 500 companies listed on NASDAQ, based on their full market-caps'
      },
      'NASDAQ': {
        'value': 'NASDAQ 100 PR',
        'zone': 'us',
        'description':
            'An Index of top 100, most actively traded, non-financial companies listed on NASDAQ'
      },
    },
    "sg": {
      'STI': {
        'value': 'Straits Times Index TR',
        'zone': 'sg',
        'description':
            'An Index of top 30 companies by market cap, listed on the Singapore Exchange'
      },
    }
  };

  Future<Null> _analyticsAnalyseEvent() async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "analyse_portfolio",
      'item_name': "analyse_portfolio_benchmark_next_button",
      'content_type': "click_next_button",
    });
  }

  Future<Null> _analyticsBenchmarkSelectorEvent(String benchmarkValue) async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "analyse_portfolio",
      'item_name': "analyse_portfolio_select_benchmark",
      'content_type': "select_benchmark_icon_click",
      'item_list_name': benchmarkValue
    });
  }

  Future<Null> _analyticsZoneFlagSelectorEvent(String zone) async {
    await widget.analytics.logEvent(name: 'view_item', parameters: {
      'item_id': "analyse_portfolio",
      'item_name': "analyse_portfolio_select_country_flag",
      'content_type': "select_country_flag_click",
      'item_list_name': zone
    });
  }

  List<String> zone_list = [];

  void getBenchmarkSelectors() async {
    setState(() {
      widget.model.setLoader(true);
    });
    final response = await widget.model.getBenchmarkSelectors();

    int i = 0;
    if (response['status'] == true) {
      zoneBenchmarks = response['response'];

      zoneBenchmarks[zone_list[0]].forEach((key, value) {
        i++;
        benchmarks[key] = value;
        if (i == 1) {
          _selectedBenchmarks = key;
        }
      });

      _selectedZone = zone_list[0].toString();
    }

    setState(() {
      widget.model.setLoader(false);
    });
  }

  void initState() {
    log.d(widget.selectedPortfolioMasterIDs);

    if (!zone_list.isEmpty) {
      zone_list.clear();
    }
    zone_list.add("in");
    zone_list.add("gl");
    getBenchmarkSelectors();

    // _selectedBenchmarks = 'NIFTY50';

    // widget.model.userSettings['allowed_zones'].forEach((zone) {
    //   if (zoneBenchmarks.containsKey(zone)) {
    //     log.d("Testing zoneBenchmarks");
    //     log.d(zoneBenchmarks);

    //     zone_list.add(zone);

    //     zoneBenchmarks[zone].forEach((key, value) {
    //       benchmarks[key] = value;
    //     });
    //   }
    // });

    // _selectedZone = zone_list[0].toString();

    super.initState();
  }

  void formResponseAnalyseReport() async {
    setState(() {
      widget.model.setLoader(true);
    });
    Map<String, dynamic> responseData = await widget.model.analyzerPortfolio(
        {'benchmark': _selectedBenchmarks, 'risk_profile': 'moderate'},
        widget.selectedPortfolioMasterIDs);

    if (responseData['status'] == true) {
      changeStatusBarColor(Color(0xffefd82b));
      Navigator.pushNamed(context, '/portfolioAnalyzerReport', arguments: {
        'responseData': responseData,
        'selectedPortfolioMasterIDs': widget.selectedPortfolioMasterIDs,
        'benchmark': _selectedBenchmarks
      }).then((value) => changeStatusBarColor(Colors.white));
    } else {
      showAlertDialogBox(context, 'Error!', responseData['response']);
      // customAlertBox(
      //     context: context,
      //     type: "error",
      //     title: "Error!",
      //     description: responseData['response'],
      //     buttons: null);
    }

    setState(() {
      widget.model.setLoader(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
    );

    return PageWrapper(
      child: Scaffold(
          key: _scaffoldKey,
          drawer: WidgetDrawer(),
          appBar: PreferredSize(
            // for larger & medium screen sizes
            preferredSize: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            child: NavigationTobBar(
              widget.model,
              openDrawer: () => _scaffoldKey.currentState.openDrawer(),
            ),
          ),
          body: _buildBodyNvaigationLeftBar()),
    );
  }

  Widget _buildBodyNvaigationLeftBar() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        deviceType == DeviceScreenType.tablet
            ? emptyWidget
            : NavigationLeftBar(
                isSideMenuHeadingSelected: 2, isSideMenuSelected: 0),
        Expanded(
            child: widget.model.isLoading
                ? preLoader()
                : benchMarkAnalyzeLoader
                    ? _preLoaderLarge()
                    : _buildBodyContentLarge()),
      ],
    );
  }

  Widget _buildBodyContentLarge() {
    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(left: 27.0, top: 55.0, right: 60.0, bottom: 87),
      color: Color(0xfff5f6fa),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectBenchMark(),
        ],
      ),
    ));
  }

  refreshParent(bool isloading) {
    setState(() {
      // benchMarkAnalyzeLoader = isloading;
      widget.model.setLoader(isloading);
    });
  }

  Widget _submitButtonAnalyseReport() {
    return gradientButtonLarge(
        context: context,
        caption: "analyse",
        onPressFunction: () async {
          _analyticsAnalyseEvent();
          formResponseAnalyseReport();
        });
  }

// benchMark

  Widget _preLoaderLarge() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            svgImage('assets/icon/icon_analyzer_loader.svg',
                height: getScaledValue(125)),
            SizedBox(height: getScaledValue(33)),
            Text('Analyzing your investments…', style: preLoaderBodyText1),
          ],
        ),
        Container(
            alignment: Alignment.bottomCenter,
            child:
                Text('hold on tight'.toUpperCase(), style: preLoaderBodyText2)),
      ],
    );
  }

  Widget _buildSelectBenchMark() {
    return Container(
      color: Color(0xfff5f6fa),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectBenchHeader(),
          SizedBox(
            height: getScaledValue(1),
          ),
          _portfolioBenchMarkList(),
          SizedBox(
            height: getScaledValue(24),
          ),
          _submitButtonAnalyseReport()
        ],
      ),
    );
  }

  _selectBenchHeader() {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      padding: EdgeInsets.only(left: 24.0, top: 0.0, right: 24.0, bottom: 0.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: getScaledValue(24),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select a BenchMark", style: headline5_analyse),
                  Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Country", style: headline2_analyse),
                          SizedBox(
                            width: getScaledValue(14),
                          ),

                          Container(
                            height: getScaledValue(33),
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: colorBlue, width: 1.25),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  hint: Text(
                                    _selectedZone.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: colorBlue,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: colorBlue,
                                  ),
                                  items: zone_list.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedZone = value;
                                    });
                                    //  _currencySelectionForWeb(currencyValues);
                                  }),
                            ),
                          ),

                          // Container(
                          //   padding: EdgeInsets.only(
                          //       left: 6, top: 2, right: 6, bottom: 2),
                          //   height: getScaledValue(30),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(5.0),
                          //     border: Border.all(color: colorBlue, width: 1.25),
                          //   ),
                          //   alignment: Alignment.center,
                          //   child: GestureDetector(
                          //       onTap: () => filterPopup(),
                          //       child: Row(
                          //         children: [
                          //           Text(
                          //               _selectedZone1.toUpperCase().toString(),
                          //               style: heading_alert_view_all),
                          //           Icon(Icons.keyboard_arrow_down,
                          //               color: Color(0xff034bd9)),
                          //         ],
                          //       )
                          //       /* Image.asset('assets/icon/icon_filter.png', height: getScaledValue(16), width: getScaledValue(20)) */
                          //       ),
                          // ),
                        ]),
                  )
                ]),
            SizedBox(
              height: getScaledValue(2),
            ),
            Text(
                "Select a benchmark for comparison with the portfolio combination that you have made.",
                style: headline6_analyse),
            SizedBox(
              height: getScaledValue(19),
            ),
          ]),
    );
  }

  Widget _portfolioBenchMarkList() {
    List<Widget> _children_benchmark = [];

    // zoneBenchmarks.forEach((zone, benchmarks) {
    //   if (widget.model.userSettings['allowed_zones'].toString().contains(_selectedZone)) {
    //     _children.add(_benchmarkList(benchmarks));
    //   }
    // });
    //

    benchmarks.clear();
    if (_selectedZone == 'gl') {
      zoneBenchmarks.forEach((key, value) {
        if (key != 'in') {
          zoneBenchmarks[key].forEach((key, value) {
            benchmarks[key] = value;
          });
        }
      });
    } else {
      zoneBenchmarks[_selectedZone].forEach((key, value) {
        benchmarks[key] = value;
      });
    }

    benchmarks.forEach((benchmark, benchmarkData) {
      _children_benchmark.add(_benchmarkBoxLarge(benchmark, benchmarkData));
    });

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 1.0,
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: MediaQuery.of(context).size.width *
                1.0 /
                MediaQuery.of(context).size.height *
                1.25,
            shrinkWrap: true,
            controller: controller,
            physics: ClampingScrollPhysics(),
            children: _children_benchmark,
          ),

          // ListView(
          //   shrinkWrap: true,
          // 	controller: controller,
          // 	physics: ClampingScrollPhysics(),
          // 	children: _children_benchmark,
          // ),
        ],
      ),
    );

    // return Container(
    // 	child: ListView(
    // 		shrinkWrap: true,
    // 		//physics: ClampingScrollPhysics(),
    // 		children: _children_benchmark
    // 	),
    // );

    // return Container(
    // 	color: Colors.white,
    // 	child: Flex(
    // 		direction: Axis.vertical,
    // 		children: <Widget>[
    // 			 Column(
    // 			//controller: controller,
    // 			//physics: ClampingScrollPhysics(),
    // 			children: _children,
    // 		),
    // 		//SizedBox(height: getScaledValue(15),),
    // 		_submitButton(),

    // 		],
    // 	),
    // );
  }

  Widget _benchmarkBoxLarge(String key, Map benchmarkData) {
    return GestureDetector(
        onTap: () async {
          _analyticsBenchmarkSelectorEvent(benchmarkData['value']);
          _analyticsZoneFlagSelectorEvent(benchmarkData['zone']);
          setState(() {
            _selectedBenchmarks = key;
          });
        },
        child: Container(
            margin: EdgeInsets.symmetric(
                vertical: getScaledValue(10), horizontal: getScaledValue(10)),
            padding: EdgeInsets.symmetric(
                vertical: getScaledValue(16), horizontal: getScaledValue(16)),
            decoration: BoxDecoration(
              border: Border.all(
                  color: (_selectedBenchmarks == key
                      ? colorBlue
                      : Color(0xffe8e8e8)),
                  width: 1),
              borderRadius: BorderRadius.circular(getScaledValue(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: getScaledValue(6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(benchmarkData['value'], style: portfolioBoxName),
                    widgetZoneFlag(benchmarkData['zone'])
                  ],
                ),
                SizedBox(height: getScaledValue(10)),
                Text(benchmarkData['description']),
              ],
            )));
  }
}
