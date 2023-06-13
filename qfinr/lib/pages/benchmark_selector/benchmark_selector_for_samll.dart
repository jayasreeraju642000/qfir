import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';

final log = getLogger('BenchmarkSelector');

class BenchmarkSelectorSmall extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final String action;

  final Map selectedPortfolioMasterIDs;

  BenchmarkSelectorSmall(this.model,
      {this.analytics,
      this.observer,
      this.action = "",
      this.selectedPortfolioMasterIDs});

  @override
  State<StatefulWidget> createState() {
    return _BenchmarkSelectorState();
  }
}

class _BenchmarkSelectorState extends State<BenchmarkSelectorSmall>
    with SingleTickerProviderStateMixin {
  final controller = ScrollController();
  TabController _tabController;
  int tabIndex = 0;
  bool benchMarkSelectedLoaded = false;

  String _selectedBenchmarks = "";

  Map benchmarks = {
    /* 'NIFTY50': {
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
		}, */
    /* 'FSTLM'			:	{'value': 'FSTLM', 'zone': 'sg', 'description': ''},
				'GSPC'			:	{'value': 'GSPC', 'zone': 'us', 'description': ''},
				'STI'			:	{'value': 'STI', 'zone': 'sg', 'description': ''},
				'VIX'			:	{'value': 'VIX', 'zone': 'us', 'description': ''},
				'NASDAQ'		:	{'value': 'NASDAQ', 'zone': 'us', 'description': ''}, */
  };

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
  List<String> zone_list = [];
  Map zoneBenchmarks = {};

  // Map benchmarks = {};
  void getBenchmarkSelectors() async {
    setState(() {
      widget.model.setLoader(true);
      benchMarkSelectedLoaded = true;
    });
    final response = await widget.model.getBenchmarkSelectors();

    if (response['status'] == true) {
      zoneBenchmarks = response['response'];

      int i = 0;
      zoneBenchmarks[zone_list[0]].forEach((key, value) {
        i++;
        benchmarks[key] = value;
        if (i == 1) {
          _selectedBenchmarks = key;
        }
      });

      // _selectedZone = zone_list[0].toString();
    }

    setState(() {
      widget.model.setLoader(false);
      benchMarkSelectedLoaded = false;
    });
  }

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

  void initState() {
    super.initState();

    if (!zone_list.isEmpty) {
      zone_list.clear();
    }
    zone_list.add("in");
    zone_list.add("gl");

    getBenchmarkSelectors();
    // _selectedBenchmarks = 'NIFTY50';

    // int tabCounter = 0;

    // widget.model.userSettings['allowed_zones'].forEach((zone) {
    //   if (zoneBenchmarks.containsKey(zone)) {
    //     tabCounter++;
    //     ;
    //     zoneBenchmarks[zone].forEach((key, value) {
    //       benchmarks[key] = value;
    //     });
    //   }
    //   //benchmarks.addAll(zoneBenchmarks[zone].toList());
    // });

    _tabController = TabController(
        length: zone_list.length, vsync: this, initialIndex: tabIndex);

    // log.d(widget.model.userSettings);
  }

  Widget _submitButton() {
    return gradientButton(
        context: context,
        caption: "next",
        onPressFunction: () async {
          await _analyticsAnalyseEvent();
          formResponse();
        });
  }

  void formResponse() async {
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
      customAlertBox(
          context: context,
          type: "error",
          title: "Error!",
          description: responseData['response'],
          buttons: null);
    }

    setState(() {
      widget.model.setLoader(false);
    });
  }

  Widget tabbar() {
    List<Widget> _children = [];
    zone_list.forEach((element) {
      _children.add(Tab(
        child: Row(
          children: [
            widgetZoneFlag(element),
            SizedBox(width: getScaledValue(10)),
            Text(
              element.toUpperCase(),
              style: TextStyle(fontSize: getScaledValue(14)),
            ),
          ],
        ),
      ));
    });

    // zoneBenchmarks.forEach((zone, benchmarks) {
    //   if (widget.model.userSettings['allowed_zones'].contains(zone)) {
    //     _children.add(Tab(
    //       child: Row(
    //         children: [
    //           widgetZoneFlag(zone),
    //           SizedBox(width: getScaledValue(10)),
    //           Text(
    //             zone.toUpperCase(),
    //             style: TextStyle(fontSize: getScaledValue(14)),
    //           ),
    //         ],
    //       ),
    //     ));
    //   }
    // });

    return TabBar(
        isScrollable: true,
        controller: _tabController,
        unselectedLabelColor: Color(0x30000000),
        labelColor: Colors.black,
        indicatorWeight: getScaledValue(2),
        indicatorColor: Colors.black,
        unselectedLabelStyle: tabBarInactive,
        labelStyle: tabBarActive,
        onTap: (index) {
          setState(() {
            tabIndex = index;
          });
        },
        tabs: _children);
  }

  @override
  Widget build(BuildContext context) {
    //controller.appBar.height = getScaledValue(MediaQuery.of(context).padding.top + 56);
    changeStatusBarColor(Colors.white);
    return Scaffold(
        appBar: commonAppBar(
          bgColor: Colors.white,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                  context, widget.model.redirectBase),
              child: AppbarHomeButton(),
            )
          ],
          //bottom: tabbar(),
        ),
        body: mainContainer(
            containerColor: Colors.white,
            context: context,
            paddingLeft: getScaledValue(16),
            paddingRight: getScaledValue(16),
            child: widget.model.isLoading
                ? benchMarkSelectedLoaded
                    ? preLoader()
                    : _preLoader()
                : _buildBody())); //_preLoader
  }

  Widget _preLoader() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              svgImage('assets/icon/icon_analyzer_loader.svg',
                  height: getScaledValue(125)),
              SizedBox(height: getScaledValue(33)),
              Text('Analyzing your investments…', style: preLoaderBodyText1),
            ],
          ),
        ),
        Expanded(
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Text('hold on tight'.toUpperCase(),
                    style: preLoaderBodyText2))),
      ],
    );
  }

  Widget _buildBody() {
    List<Widget> _children = [];
    List<Widget> _tabBarChildren = [];

    _children.add(
      Container(
          margin: EdgeInsets.only(
              left: getScaledValue(10.0),
              right: getScaledValue(10.0),
              top: getScaledValue(5.0),
              bottom: getScaledValue(25.0)),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a Benchmark', style: headline1),
              SizedBox(height: getScaledValue(5)),
              Text(
                  "Select a benchmark for comparison with the portfolio combination that you have made. This will provide the appropriate context to the performance of your portfolio(s) and help you make the right decisions",
                  style: bodyText1)
            ],
          )),
    );

    _children.add(tabbar());

    _children.add(SizedBox(height: getScaledValue(15)));

    zone_list.forEach((element) {
      if (element == 'in') {
        _tabBarChildren.add(_benchmarkList(benchmarks));
      }
      if (element == 'gl') {
        Map benchmarks_gl = {};

        zoneBenchmarks.forEach((zone, benchmarks) {
          if (zone != 'in') {
            // benchmarks_gl = benchmarks;
            benchmarks_gl.addAll(benchmarks);
          }
        });
        _tabBarChildren.add(_benchmarkList(benchmarks_gl));
      }
    });
    _children.add(Expanded(
        child: TabBarView(
      children: _tabBarChildren,
      controller: _tabController,
    )));

    return Container(
      color: Colors.white,
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
              child: Column(
            //controller: controller,
            //physics: ClampingScrollPhysics(),
            children: _children,
          )),
          //SizedBox(height: getScaledValue(15),),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _benchmarkList(Map benchmarkList) {
    List<Widget> _children = [];
    benchmarkList.forEach((benchmark, benchmarkData) {
      _children.add(_benchmarkBox(benchmark, benchmarkData));
    });

    return Container(
      child: ListView(
          shrinkWrap: true,
          //physics: ClampingScrollPhysics(),
          children: _children),
    );
  }

  Widget _benchmarkBox(String key, Map benchmarkData) {
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
                    Text(benchmarkData['value'] ?? "", style: portfolioBoxName),
                    widgetZoneFlag(benchmarkData['zone'])
                  ],
                ),
                SizedBox(height: getScaledValue(10)),
                Text(benchmarkData['description'] ?? ""),
              ],
            )));
  }
}
