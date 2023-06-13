import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/helpers/portfolio_helper.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('SortFilter');

class SortFilter extends StatefulWidget {
  MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  SortFilter(this.model, {this.analytics, this.observer});

  @override
  State<StatefulWidget> createState() {
    return _SortFilterState();
  }
}

class _SortFilterState extends State<SortFilter> with TickerProviderStateMixin {
  String page = "main";

  String pathPDF = "";
  RangeValues _currentRangeValues;

  List<Map<String, dynamic>> riskProfiles = [
    {'key': 'conservative', 'value': 'Conservative'},
    {'key': 'm_conservative', 'value': 'Moderate Conservative'},
    {'key': 'moderate', 'value': 'Moderate'},
    {'key': 's_aggressive', 'value': 'Moderate Aggressive'},
    {'key': 'aggressive', 'value': 'Aggressive'},
  ];

  Widget overallRating = Container();
  double rating = 3.5;

  List fundList;

  StateSetter _setState;

  Map filterOptions = {
    'sortby': {
      'title': 'Sort By',
      'type': 'sort',
      'optionType': 'radio',
      'selectedOption': [null],
      'optionGroups': [
        {
          'key': 'scores',
          'group_title': 'Scores',
          'options': {
            'overall_rating': 'Overall Score',
            'tr_rating': 'Return Score',
            'alpha_rating': 'Alpha Score',
            'srri': 'Risk Score',
            'tracking_rating': 'Tracking Score'
          }
        },
        {
          'key': 'key_stats',
          'group_title': 'Key Stats',
          'options': {
            'cagr': '3 Year Return',
            'stddev': '3 Year Risks',
            'sharpe': 'Sharpe Ratio',
            'Bench_alpha': 'Alpha',
            'Bench_beta': 'Beta',
            'successratio': 'Success Rate',
            'inforatio': 'Information Ratio',
            'tna': 'AUM'
          }
        },
        {
          'key': 'name',
          'group_title': 'Name',
          'options': {'name': 'Name'}
        }
      ]
    },
    'zone': {
      'title': 'Country',
      'type': 'filter',
      'optionType': 'checkbox',
      'selectedOption': [null],
      'optionGroups': [
        {'group_title': '', 'options': {}},
      ]
    },
    'type': {
      'title': 'Type',
      'type': 'filter',
      'optionType': 'radio',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {
            'funds': 'Mutual Fund',
            'etf': 'ETF',
            'stocks': 'Stocks',
            'bonds': 'Bonds',
            'commodity': 'Commodity'
          }
        }, //
      ]
    },
    'share_class': {
      'title': 'Investment Share\nClass',
      'type': 'filter',
      'optionType': 'radio',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {'direct': 'Direct', 'regular': 'Regular'}
        },
      ]
    },
    'category': {
      'title': 'Category',
      'type': 'filter',
      'optionType': 'checkbox',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {
            'Balanced': 'Balanced',
            'MMF': 'MMF',
            'Mid Cap Equity': 'Mid Cap Equity',
            'Long Duration Debt': 'Long Duration Debt',
            'Large Cap Equity': 'Large Cap Equity',
            'Short Duration Debt': 'Short Duration Debt',
            'US Equity': 'US Equity',
            'Thematic': 'Thematic',
            'Small Cap Equity': 'Small Cap Equity'
          }
        },
      ]
    },
    'industry': {
      'title': 'Industry',
      'type': 'filter',
      'optionType': 'checkbox',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {
            'Industrials': 'Industrials',
            'Basic Materials': 'Basic Materials',
            'Utilities': 'Utilities',
            'Consumer Cyclicals': 'Consumer Cyclicals',
            'Financials': 'Financials',
            'Healthcare': 'Healthcare',
            'Consumer Non-Cyclicals': 'Consumer Non-Cyclicals',
            'Technology': 'Technology',
            'Energy': 'Energy',
            'Real Estate': 'Real Estate',
            'Precious Metals': 'Precious Metals'
          }
        },
      ]
    },
    'overall_rating': {
      'title': 'Overall Score',
      'type': 'filter',
      'optionType': 'range_slider',
      'selectedOption': [null],
      'optionGroups': [
        {
          'key': 'overall_rating',
          'group_title': ' ',
          'options': {
            'range': {'title': 'Select Range', 'min': '1', 'max': '5'}
          }
        },
      ]
    },
    'key_stats': {
      'title': 'Key Stats',
      'type': 'filter',
      'optionType': 'range_slider',
      'selectedOption': [null],
      'optionGroups': [
        {
          'key': 'cagr',
          'group_title': ' ',
          'options': {
            'range': {'title': '3 Year Return', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'stddev',
          'group_title': '',
          'options': {
            'range': {'title': '3 Year Risks', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'sharpe',
          'group_title': '',
          'options': {
            'range': {'title': 'Sharpe Ratio', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'Bench_alpha',
          'group_title': '',
          'options': {
            'range': {'title': 'Alpha', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'Bench_beta',
          'group_title': '',
          'options': {
            'range': {'title': 'Beta', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'successratio',
          'group_title': '',
          'options': {
            'range': {'title': 'Success Rate', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'inforatio',
          'group_title': '',
          'options': {
            'range': {'title': 'Information Ratio', 'min': '1', 'max': '5'}
          }
        },
        //{'key': '', 'group_title': '', 'options': {'range': {'min': '1', 'max': '5'}}},
      ]
    },
    /* 'aum_size':	{'title': 'AUM Size', 'type': 'filter', 'optionType': 'radio', 'selectedOption': [null],
			'optionGroups': [
				{'group_title': '', 'options': {'all': 'All', 't10': 'Top 10%', 't25': 'Top 25%', 't50': 'Top 50%', 'b25': 'Bottom 25%'}},
			]
		}, */
  };

  Map categoryOptions = {
    'funds': {
      'Balanced': 'Balanced',
      'Cash/MMF': 'Cash/MMF',
      'Commodities': 'Commodities',
      'Debt DM': 'Debt DM',
      'Debt EM': 'Debt EM',
      'Debt Global': 'Debt Global',
      'Debt HY': 'Debt HY',
      'EM Equity': 'EM Equity',
      'Equity DM': 'Equity DM',
      'Equity EM': 'Equity EM',
      'Equity Global': 'Equity Global',
      'Equity SG': 'Equity SG',
      'Equity US': 'Equity US',
      'Europe Equity': 'Europe Equity',
      'Global Equity': 'Global Equity',
      'Large Cap Equity': 'Large Cap Equity',
      'Long Duration Debt': 'Long Duration Debt',
      'Mid Cap Equity': 'Mid Cap Equity',
      'MMF': 'MMF',
      'Short Duration Debt': 'Short Duration Debt',
      'Small Cap Equity': 'Small Cap Equity',
      'Thematic': 'Thematic',
      'US Equity': 'US Equity'
    },
    /* {'Balanced': 'Balanced', 'MMF': 'MMF', 'Mid Cap Equity': 'Mid Cap Equity', 'Long Duration Debt': 'Long Duration Debt', 'Large Cap Equity': 'Large Cap Equity', 'Short Duration Debt': 'Short Duration Debt', 'US Equity': 'US Equity', 'Thematic': 'Thematic', 'Small Cap Equity': 'Small Cap Equity'}, */
    'etf': {
      'Banking': 'Banking',
      'Cash/MMF': 'Cash/MMF',
      'Commodities': 'Commodities',
      'Debt DM': 'Debt DM',
      'Debt EM': 'Debt EM',
      'Debt Global': 'Debt Global',
      'Equity DM': 'Equity DM',
      'Equity EM': 'Equity EM',
      'Equity Global': 'Equity Global',
      'Global EM Equity': 'Global EM Equity',
      'Global Equity': 'Global Equity',
      'IT': 'IT',
      'Large Cap Equity': 'Large Cap Equity',
      'Mid Cap Equity': 'Mid Cap Equity',
      'MMF': 'MMF',
      'SG Equity': 'SG Equity',
      'Thematic': 'Thematic',
      'US Equity': 'US Equity'
    },
    /* {'Mid Cap Equity': 'Mid Cap Equity', 'Commodities': 'Commodities', 'Large Cap Equity': 'Large Cap Equity', 'MMF': 'MMF', 'Banking': 'Banking', 'Thematic': 'Thematic', 'IT': 'IT', 'US Equity': 'US Equity'}, */
    'stocks': {
      'Commercial REIT': 'Commercial REIT',
      'Equity EM': 'Equity EM',
      'Europe Equity': 'Europe Equity',
      'Large Cap Equity': 'Large Cap Equity',
      'Mid Cap Equity': 'Mid Cap Equity',
      'REIT': 'REIT',
      'SG Equity': 'SG Equity',
      'US Equity': 'US Equity'
    },
    /* {'Large Cap Equity': 'Large Cap Equity', 'Mid Cap Equity': 'Mid Cap Equity', 'REIT': 'REIT', 'Commercial REIT': 'Commercial REIT'}, */
    'bonds': {'Govt': 'Govt'},
    'commodity': {'Commodity': 'Commodity'},
  };

  Map filterOptionSelection = {
    'sort_order': 'desc',
    'sortby': 'tna',
    'type': 'funds'
  };
  Map filterOptionSelectionReset;

  String activeFilterOption = 'sortby';

  String getRiskProfile(String key) {
    String returnValue = "";
    riskProfiles.forEach((Map riskProfile) {
      if (riskProfile['key'] == key) {
        returnValue = riskProfile['value'];
      }
    });
    return returnValue;
  }

  Future<Null> _analyticsFundScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Know Your Fund Page',
        screenClassOverride: 'PortfolioKnowFund');
  }

  Future<Null> _analyticsAddFundEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Know Your Fund Page",
    });
  }

  Future<Null> _analyticsKnowYourAssetAnalyseEvent() async {
    await widget.analytics.logEvent(name: 'view_search_results', parameters: {
      'item_id': "know_your_assets",
      'item_name': "know_your_assets_analyse_result_content",
      'content_type': "click_content_body",
    });
  }

  Future<Null> _analyticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'know_your_assets',
        screenClassOverride: 'know_your_assets');
  }

  Future<Null> _analyticsSearchEvent(String searchTerm) async {
    await widget.analytics.logEvent(name: 'search', parameters: {
      'search_term': searchTerm,
      'item_id': "know_your_assets",
      'item_name': "know_your_assets_search",
      'content_type': "search_button",
    });
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Know Your Assets",
    });
  }

  Future<Null> _analyticsSortEvent(String sortTerm) async {
    await widget.analytics.logEvent(name: 'select_content', parameters: {
      'item_id': "add_manually",
      'item_name': "add_new_asset_sort",
      'content_type': "click_sort_box",
      'content': sortTerm
    });
  }

  Future<Null> _analyticsResultCountEvent(String count) async {
    await widget.analytics.logEvent(name: 'view_search_results', parameters: {
      'item_id': "know_your_assets",
      'item_name': "know_your_assets_analyse_result_content",
      'content_type': "click_content_body",
      'content': count
    });
  }

  Widget _preLoader() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                svgImage('assets/icon/icon_analyzer_loader.svg',
                    height: getScaledValue(125)),
                /* Stack(
								alignment: Alignment.topCenter,
								children: <Widget>[
									svgImage('assets/icon/icon_loader_1.svg', height: getScaledValue(125)),
									Align(
										alignment: AlignmentDirectional(0,0.7),
										child: Transform.translate(
											offset: Offset(20, _fraction),
											child: svgImage('assets/icon/icon_loader_2.svg', height: getScaledValue(50)),
										),
									),
								]
							), */
                SizedBox(height: getScaledValue(33)),
                Text('Analyzing your investments…', style: preLoaderBodyText1),
              ],
            ),
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

  @override
  void initState() {
    super.initState();

    _analyticsCurrentScreen();
    _analyticsAddEvent();

    widget.model.newUserPortfolios = [];
    filterOptionSelectionReset = Map.from(filterOptionSelection);

    // zones as per user allowed
    widget.model.userSettings['allowed_zones'].forEach((zone) {
      filterOptions['zone']['optionGroups'][0]['options'][zone] =
          zone.toUpperCase();

      if (zone == "in") {
        filterOptionSelection['zone'] = ['in'];
      }
    });
    updateKeyStatsRange();
  }

  updateKeyStatsRange() async {
    dynamic keyStatsRange = await widget.model.getKeyStatsRange();
    if (keyStatsRange.containsKey('status') &&
        keyStatsRange['status'] == true) {
      filterOptions['key_stats']['optionGroups']
          .asMap()
          .forEach((key, element) {
        if (keyStatsRange['response'].containsKey(element['key'])) {
          setState(() {
            filterOptions['key_stats']['optionGroups'][key]['options']['range']
                    ['min'] =
                keyStatsRange['response'][element['key']]['min'].toString();
            filterOptions['key_stats']['optionGroups'][key]['options']['range']
                    ['max'] =
                keyStatsRange['response'][element['key']]['max'].toString();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }

  AppBar _appBar() {
    changeStatusBarColor(Colors.white);
    return commonAppBar(
        iconColor: Colors.black,
        brightness: Brightness.light,
        bgColor: Colors.white,
        leading: page == "search" || page == "fundList" ? emptyWidget : null,
        actions: [
          page == "search" || page == "fundList"
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      page = "main";
                    });
                  },
                  child: Padding(
                      padding: EdgeInsets.only(right: getScaledValue(16)),
                      child: Icon(Icons.close)),
                )
              : GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                      context, widget.model.redirectBase),
                  child: AppbarHomeButton(),
                )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        /* drawer: WidgetDrawer(), */
        appBar: _appBar(),
        body: mainContainer(
            context: context,
            paddingLeft: getScaledValue(16),
            paddingRight: getScaledValue(16),
            containerColor: Colors.white,
            child: widget.model.isLoading
                ? (['search', 'fundList'].contains(page)
                    ? _preLoader()
                    : preLoader())
                : page == "search"
                    ? _buildBodySearch()
                    : page == "fundList"
                        ? _buildFundList()
                        : _buildBodyMain()),
      );
    });
  }

  Widget _buildFundList() {
    _analyticsResultCountEvent(fundList.length.toString());
    return Container(
      child: ListView(
        children: [
          Text("Search Results", style: keyStatsBodyText4),
          Text(
              fundList.length.toString() +
                  " " +
                  fundTypeCaption(filterOptionSelection['type']) +
                  " shortlisted",
              style: keyStatsBodyText6),
          SizedBox(height: getScaledValue(10)),
          ...fundList
              .map((element) => fundBox(context, element, onTap: () {
                    _analyticsKnowYourAssetAnalyseEvent();
                    formResponse(
                        singleRIC: true,
                        ric: element['ric'],
                        ricType: element['type']);
                  },
                      sortCaption: sortByCaption(),
                      sortWidget: filterOptionSelection.containsKey('sortby') &&
                              [
                                'overall_rating',
                                'tr_rating',
                                'alpha_rating',
                                'srri',
                                'tracking_rating'
                              ].contains(filterOptionSelection['sortby'])
                          ? svgImage("assets/icon/star_filled.svg")
                          : (filterOptionSelection['sortby'] == "tna"
                              ? Text('M')
                              : null)))
              .toList()
        ],
      ),
    );
  }

  String sortByCaption() {
    String caption;
    if (filterOptionSelection.containsKey('sortby')) {
      if (filterOptionSelection['sortby'] == "name") {
        return null;
      }
      filterOptions['sortby']['optionGroups'].forEach((element) {
        element['options'].forEach((key, value) {
          if (key == filterOptionSelection['sortby']) {
            caption = value + ": ";
          }
        });
      });
    }
    return caption;
  }

  Widget _buildBodyMain() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Know your assets", style: headline1),
          SizedBox(height: getScaledValue(4)),
          Text(
              "Uncover deep insights and analysis on Mutual funds, ETFs, stocks, and bonds across multiple countries. Compare with benchmarks. Assess suitability for your portfolios.",
              style: bodyText4),
          SizedBox(height: getScaledValue(21)),
          toolShortcut("assets/icon/search.svg", "Search",
              "Search across Mutual funds, ETFs, stocks, and bonds across multiple countries. Use our smart search feature to make it fast",
              onTap: searchPopup),
          toolShortcut("assets/icon/filter.svg", "Sort & Filter",
              "Shortlist assets using one or more criteria. Deep dive into those that fit your yardstick",
              onTap: fitlerPopup),
        ],
      ),
    );
  }

  searchPopup() {
    setState(() {
      page = "search";
    });
  }

  fitlerPopup() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getScaledValue(14)),
          topRight: Radius.circular(getScaledValue(14)),
        )
            //
            ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return Container(
                color: Colors.white,
                width: double.infinity,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    130,
                margin: const EdgeInsets.only(bottom: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(16),
                          vertical: getScaledValue(16)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sort & Filter'.toUpperCase(),
                                style: appBodyH4),
                            GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child:
                                    Icon(Icons.close, color: Color(0xffa5a5a5)))
                          ]),
                    ),
                    divider(),
                    Expanded(
                        flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ListView(
                                shrinkWrap: true,
                                children: filterOptions.entries
                                    .map((entry) => filterOptionWidget(entry))
                                    .toList(),
                              ),
                            ),
                            Expanded(flex: 2, child: filterOptionContainer()),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: getScaledValue(13),
                          vertical: getScaledValue(13)),
                      child: Row(
                        children: [
                          Expanded(
                              child: flatButtonText('Reset',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: () => resetFilter())),
                          SizedBox(width: getScaledValue(10)),
                          Expanded(
                              child: gradientButton(
                                  context: context,
                                  caption: 'Apply',
                                  onPressFunction: () => applyFilter())),
                        ],
                      ),
                    )
                  ],
                ));
          });
        });
  }

  resetFilter() {
    _setState(() {
      filterOptionSelection = Map.from(filterOptionSelectionReset);

      widget.model.userSettings['allowed_zones'].forEach((zone) {
        filterOptions['zone']['optionGroups'][0]['options'][zone] =
            zone.toUpperCase();

        if (zone == "in") {
          filterOptionSelection['zone'] = ['in'];
        }
      });
    });
  }

  applyFilter() async {
    Navigator.of(context).pop();
    setState(() {
      widget.model.setLoader(true);
    });
    // log.d(json.encode(filterOptionSelection));
    Map responseData = await widget.model.fundScreener(filterOptionSelection);
    setState(() {
      if (responseData.isNotEmpty) {
        fundList = responseData['response'];
        page = "fundList";
      }

      widget.model.setLoader(false);
    });
  }

  Widget filterOptionWidget(var filterOption) {
    if ((['share_class', 'aum_size'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                !['funds'].contains(filterOptionSelection['type'])) ||
        ['overall_score'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                !['funds', 'etf']
                    .contains(filterOptionSelection['type'])) || // 'key_stats',
        ['industry'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                ['funds', 'etf', 'bonds']
                    .contains(filterOptionSelection['type'])) ||
        ['overall_rating'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                ['stocks', 'bonds', 'commodity']
                    .contains(filterOptionSelection['type'])) ||
        ['share_class'].contains(filterOption.key) &&
            (filterOptionSelection.containsKey('zone') &&
                (filterOptionSelection['zone'].length > 1 ||
                    filterOptionSelection['zone'].length == 1 &&
                        !filterOptionSelection['zone'].contains('in'))))) {
      return emptyWidget;
    }
    return GestureDetector(
      onTap: () {
        _setState(() {
          activeFilterOption = filterOption.key;
        });
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: getScaledValue(16)) +
              EdgeInsets.only(
                  left: getScaledValue(16), right: getScaledValue(10)),
          width: getScaledValue(140),
          decoration: BoxDecoration(
              color: activeFilterOption == filterOption.key
                  ? Color(0xffecf4ff)
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                    width: getScaledValue(1), color: Color(0xffeeeeee)),
                right: BorderSide(
                    width: getScaledValue(1), color: Color(0xffeeeeee)),
              )),
          child: Row(
            children: [
              (filterOptionSelection.containsKey(filterOption.key) &&
                          filterOptionSelection[filterOption.key] != null &&
                          filterOptionSelection[filterOption.key].length !=
                              0) ||
                      keyStatsSelected(filterOption.key)
                  ? svgImage('assets/icon/oval.svg')
                  : SizedBox(width: getScaledValue(4)),
              SizedBox(width: getScaledValue(5)),
              Expanded(
                  child: Text(filterOption.value['title'],
                      style: keyStatsBodyText7))
            ],
          )),
    );
  }

  bool keyStatsSelected(String filterOptionKey) {
    bool found = false;
    if (filterOptionKey == "key_stats") {
      [
        'cagr',
        'stddev',
        'sharpe',
        'Bench_alpha',
        'Bench_beta',
        'successratio',
        'inforatio'
      ].forEach((value) {
        if (filterOptionSelection.containsKey(value)) {
          found = true;
        }
      });
    }
    return found;
  }

  Widget filterOptionContainer() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(getScaledValue(12)),
        child: ListView(
          shrinkWrap: true,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filterOptions[activeFilterOption]['type'] == "sort"
                ? Container(
                    padding: EdgeInsets.only(bottom: getScaledValue(18)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        sortRow('Low to High', 'asc'),
                        sortRow('High to Low', 'desc'),
                      ],
                    ),
                  )
                : emptyWidget,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...filterOptions[activeFilterOption]['optionGroups']
                  .map((optionGroup) => filterOptionGroup(optionGroup))
                  .toList()
            ])
          ],
        ));
  }

  Widget sortRow(String caption, String orderby) {
    return GestureDetector(
      onTap: () {
        _analyticsSortEvent(caption);
        _setState(() {
          filterOptionSelection['sort_order'] = orderby;
        });
      },
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                  (orderby == "asc"
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  size: getScaledValue(18),
                  color: filterOptionSelection['sort_order'] == orderby
                      ? colorBlue
                      : colorDarkGrey),
              Text(caption,
                  style: bodyText1.copyWith(
                      fontSize: getScaledValue(11),
                      color: filterOptionSelection['sort_order'] == orderby
                          ? colorBlue
                          : colorDarkGrey))
            ],
          )
        ],
      ),
    );
  }

  Widget filterOptionGroup(var optionGroup) {
    if (optionGroup['key'] == 'scores' &&
        ['stocks', 'bonds', 'commodity']
            .contains(filterOptionSelection['type'])) {
      return emptyWidget;
    }
    var start = 0.0;
    var end = 0.0;
    return Container(
        padding: EdgeInsets.only(bottom: getScaledValue(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            optionGroup['group_title'] != ""
                ? Text(optionGroup['group_title'].toUpperCase(),
                    style: tabLabel)
                : emptyWidget,
            optionGroup['group_title'] != ""
                ? SizedBox(height: getScaledValue(12))
                : emptyWidget,
            ...optionGroup['options'].entries.map((entry) {
              if ((!['funds', 'etf', 'stocks']
                          .contains(filterOptionSelection['type']) &&
                      ['sharpe', 'Bench_alpha', 'successratio', 'inforatio']
                          .contains(entry.key)) ||
                  (['stocks', 'bonds', 'commodity']
                          .contains(filterOptionSelection['type']) &&
                      ['tna'].contains(entry.key))) {
                return emptyWidget;
              }

              if (activeFilterOption == "overall_rating" ||
                  activeFilterOption == "key_stats") {
                start = double.parse(
                        filterOptionSelection.containsKey(optionGroup['key'])
                            ? filterOptionSelection[optionGroup['key']]['min']
                            : entry.value['min'])
                    .toDouble();

                end = double.parse(
                        filterOptionSelection.containsKey(optionGroup['key'])
                            ? filterOptionSelection[optionGroup['key']]['max']
                            : entry.value['max'])
                    .toDouble();

                _currentRangeValues =
                    RangeValues(start.toDouble(), end.toDouble());
              }
              return Container(
                  //padding: EdgeInsets.only(bottom: getScaledValue(18)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    filterOptions[activeFilterOption]['optionType'] == "radio"
                        ? ListTileTheme(
                            contentPadding: EdgeInsets.all(0),
                            child: RadioListTile(
                              groupValue:
                                  filterOptionSelection[activeFilterOption],
                              title: filterOptionTextRow(entry.value),
                              value: entry.key,
                              onChanged: (value) =>
                                  filterOptionValueUpdate(value: entry.key),
                              activeColor: colorBlue,
                              dense: true,
                            ),
                          )
                        : filterOptions[activeFilterOption]['optionType'] ==
                                "checkbox"
                            ? ListTileTheme(
                                contentPadding: EdgeInsets.all(0),
                                child: CheckboxListTile(
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: filterOptionTextRow(entry.value),
                                  value: filterOptionSelection.containsKey(
                                              activeFilterOption) &&
                                          filterOptionSelection[
                                                  activeFilterOption]
                                              .contains(entry.key)
                                      ? true
                                      : false,
                                  // check from
                                  onChanged: (bool value) =>
                                      filterOptionValueUpdate(value: entry.key),
                                  activeColor: colorBlue,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.value['title'],
                                      style: bodyText1.copyWith(
                                          color: colorDarkGrey)),

                                  RangeSlider(
                                    values: _currentRangeValues,
                                    min: double.parse(entry.value['min']),
                                    max: double.parse(entry.value['max']),
                                    divisions: double.parse(entry.value['max'])
                                            .toInt() -
                                        double.parse(entry.value['min'])
                                            .toInt(),
                                    labels: RangeLabels(
                                      _currentRangeValues.start
                                          .round()
                                          .toString(),
                                      _currentRangeValues.end
                                          .round()
                                          .toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      // setState(() {
                                      //   _currentRangeValues = values;
                                      // });

                                      filterOptionValueUpdate(
                                          value: values.start.toString(),
                                          value2: values.end.toString(),
                                          optionKey: optionGroup['key']);
                                    },
                                  ),
                                  // frs.RangeSlider(
                                  //   min: double.parse(entry.value['min']),
                                  //   max: double.parse(entry.value['max']),
                                  //   lowerValue: double.parse(
                                  //       filterOptionSelection
                                  //               .containsKey(optionGroup['key'])
                                  //           ? filterOptionSelection[
                                  //               optionGroup['key']]['min']
                                  //           : entry.value['min']),
                                  //   upperValue: double.parse(
                                  //       filterOptionSelection
                                  //               .containsKey(optionGroup['key'])
                                  //           ? filterOptionSelection[
                                  //               optionGroup['key']]['max']
                                  //           : entry.value['max']),
                                  //   divisions: double.parse(entry.value['max'])
                                  //           .toInt() -
                                  //       double.parse(entry.value['min'])
                                  //           .toInt(),
                                  //   showValueIndicator: true,
                                  //   //valueIndicatorMaxDecimals: 1,
                                  //   onChanged: (double newLowerValue,
                                  //           double newUpperValue) =>
                                  //       filterOptionValueUpdate(
                                  //           value: newLowerValue.toString(),
                                  //           value2: newUpperValue.toString(),
                                  //           optionKey: optionGroup['key']),
                                  // ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          filterOptionSelection.containsKey(
                                                  optionGroup['key'])
                                              ? filterOptionSelection[
                                                  optionGroup['key']]['min']
                                              : entry.value['min'],
                                          style: appBenchmarkReturnType2),
                                      Text(
                                          filterOptionSelection.containsKey(
                                                  optionGroup['key'])
                                              ? filterOptionSelection[
                                                  optionGroup['key']]['max']
                                              : entry.value['max'],
                                          style: appBenchmarkReturnType2),
                                    ],
                                  ),
                                  SizedBox(height: getScaledValue(6))
                                ],
                              )
                  ]));
            }).toList(),
          ],
        ));
  }

  Widget filterOptionTextRow(String title) {
    if (activeFilterOption == "zone") {
      return Row(
        children: [
          widgetZoneFlag(title.toLowerCase()),
          SizedBox(width: getScaledValue(5)),
          Text(title, style: bodyText1.copyWith(color: colorDarkGrey)),
        ],
      );
    } else {
      return Text(title, style: bodyText1.copyWith(color: colorDarkGrey));
    }
  }

  filterOptionValueUpdate({String value, String value2, String optionKey}) {
    _setState(() {
      if (filterOptions[activeFilterOption]['optionType'] == "radio") {
        filterOptionSelection[activeFilterOption] = value;
      } else if (filterOptions[activeFilterOption]['optionType'] ==
          "checkbox") {
        if (filterOptionSelection.containsKey(activeFilterOption)) {
          if (filterOptionSelection[activeFilterOption].contains(value)) {
            filterOptionSelection[activeFilterOption].remove(value);
          } else {
            filterOptionSelection[activeFilterOption].add(value);
          }
        } else {
          filterOptionSelection[activeFilterOption] = [value];
        }
      } else if (filterOptions[activeFilterOption]['optionType'] ==
          "range_slider") {
        filterOptionSelection[optionKey] = {'min': value, 'max': value2};
        filterOptionSelection;
      }

      if (activeFilterOption == "type") {
        filterOptionSelection.remove('category');
        filterOptions['category']['optionGroups'][0]['options'] =
            categoryOptions[value];

        if (['stocks', 'bonds', 'commodity'].contains(value)) {
          filterOptionSelection['sortby'] = 'name';
        }
      }
    });
    return;
  }

  Widget toolShortcut(String imgPath, String title, String description,
      {Function onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: widgetCard(
            leftMargin: 0,
            rightMargin: 0,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: svgImage(
                      imgPath,
                      width: getScaledValue(19),
                    ),
                  ),
                  SizedBox(width: getScaledValue(15)),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: appBodyH3),
                      Text(description,
                          style:
                              appBodyText1.copyWith(color: Color(0xff707070)))
                    ],
                  )),
                  Icon(Icons.chevron_right),
                ])));
  }

  Widget _buildBodySearch() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /* Expanded(
                child: WidgetPortfolioNew(widget.model, showPortfolio: true, fundType: "funds", showRiskProfile: false)
              ), */
        /* Expanded(
                child: WidgetPortfolioMasterSelector(widget.model)
              ), */
        Padding(
            padding: EdgeInsets.symmetric(horizontal: getScaledValue(10)),
            child: Row(children: [
              Text("Enter Instrument name", style: keyStatsBodyText4),
              SizedBox(width: getScaledValue(5)),
              Tooltip(
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
                message:
                    "Smart Search\nTo search for any asset, you can either type the name in full (for ex: Reliance Industries), or use our Smart Search feature. Smart Search makes it faster and more efficient for you to access your favorite stocks, ETFs, or mutual funds\nTo use Smart Search, before you type the name that you are looking to search, just type in one of the letters shown below followed by a space:\n's' - to search for stocks (ex: 's nippon')\n'e' - to search for ETFs (ex: 'e nippon')\n'f' - to search for Mutual Funds (ex: 'f nippon')",
                child: InkWell(
                  onTap: () {
                    bottomAlertBox(
                        context: context,
                        title: "Smart Search",
                        childContent: _smartSearchContainer());
                  },
                  child: svgImage('assets/icon/information.svg',
                      width: getScaledValue(14)),
                ),
              )
            ])),
        Expanded(child: _searchBox()),
        /* Container(
                padding: EdgeInsets.only(top: 15.0),
                child: _buttonSubmit()
              ), */
      ],
    );
  }

  Future<List<RICs>> _getALlPosts(String search) async {
    _analyticsSearchEvent(search);
    List funds = await widget.model.getFundName(search, 'all', include: true);
    //await Future.delayed(Duration(seconds: 2));
    return List.generate(funds.length, (int index) {
      return RICs(
          ric: funds[index]['ric'],
          name: funds[index]['name'],
          zone: funds[index]['zone'],
          fundType: funds[index]['type']);
    });
  }

  Widget _searchBox() {
    return SearchBar<RICs>(
      searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
      headerPadding: EdgeInsets.symmetric(horizontal: 10),
      listPadding: EdgeInsets.symmetric(horizontal: 10),
      minimumChars: 3,
      onSearch: _getALlPosts,
      //hintText: "test",
      //searchBarController: _searchBarController,
      /* placeHolder: Text("placeholder"),
          cancellationWidget: Text("Cancel"), */
      emptyWidget: Container(
          alignment: Alignment.center,
          child: Text('No record found',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: Color(0xff3c4257)))),

      onCancelled: () {
        log.i("Cancelled triggered");
      },
      shrinkWrap: true,
      mainAxisSpacing: 5,
      //crossAxisSpacing: 5,
      crossAxisCount: 1,
      onItemFound: (RICs ric, int index) {
        Map element = {
          'ric': ric.ric,
          'name': ric.name,
          'type': ric.fundType,
          'zone': ric.zone
        };
        return fundBox(context, element, onTap: () {
          formResponse(
              singleRIC: true, ric: element['ric'], ricType: element['type']);
        });
        /* return GestureDetector(
              onTap: (){
                formResponse(singleRIC: true, ric: ric.ric);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: containerCard(
                  child: Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(ric.name, style: Theme.of(context).textTheme.subtitle2.copyWith(color: Color(0xff3c4257))),
                      Row(
                        children: <Widget>[
                          widgetBubble(title: ric.zone.toUpperCase(), bgColor: Color(0xfff6f9fc), textColor: Color(0xff6b7c93), leftMargin: 0),
                          widgetBubble(title: ric.fundType.toUpperCase(), bgColor: Color(0xfff6f9fc), textColor: Color(0xff6b7c93), leftMargin: 0),
                        ],
                      ),
                    ],
                  ),
                )
              )
            ); */
      },
    );
  }

  Widget _smartSearchContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "To search for any asset, you can either type the name in full (for ex: Reliance Industries), or use our Smart Search feature. Smart Search makes it faster and more efficient for you to access your favorite stocks, ETFs, or mutual funds\n"),
        Text(
            "To use Smart Search, before you type the name that you are looking to search, just type in one of the letters shown below followed by a space:\n"),
        Text("'s' - to search for stocks (ex: 's nippon')"),
        Text("'e' - to search for ETFs (ex: 'e nippon')"),
        Text("'f' - to search for Mutual Funds (ex: 'f nippon')"),
      ],
    );
  }

  void formResponse(
      {bool singleRIC = false, String ric = "", String ricType}) async {
    _analyticsKnowYourAssetAnalyseEvent();
    setState(() {
      widget.model.setLoader(true);
    });

    if (['Funds', 'ETF'].contains(ricType)) {
      Map<String, dynamic> responseData;
      if (singleRIC) {
        responseData = await widget.model.knowYourPortfolio({
          ric: {'ric': ric}
        });
      } else {
        responseData = await widget.model.knowYourPortfolio(widget.model
                .userPortfoliosData[widget.model.defaultPortfolioSelectorKey]
            ['portfolios']);
      }

      if (responseData['status']) {
        Navigator.pushNamed(context, '/knowFundReport',
            arguments: {'responseData': responseData});
        setState(() {
          widget.model.setLoader(false);
        });
      } else {
        setState(() {
          widget.model.setLoader(false);
        });
        showAlertDialogBox(context, 'Error!', responseData['response']);
      }
    } else {
      Navigator.of(context).pushNamed('/fund_info', arguments: {'ric': ric});
      setState(() {
        widget.model.setLoader(false);
      });
    }
  }
}

class RICs {
  final String ric;
  final String zone;
  final String fundType;
  final String name;

  RICs({this.ric, this.zone, this.fundType, this.name});
}
