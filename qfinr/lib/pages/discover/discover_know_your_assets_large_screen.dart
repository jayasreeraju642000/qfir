import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/discover/discover_styles.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/helpers/common_widgets.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DiscoverKnowYorAssetLargeScreen extends StatefulWidget {
  final MainModel model;

  const DiscoverKnowYorAssetLargeScreen(this.model, {Key key})
      : super(key: key);

  @override
  _DiscoverKnowYorAssetLargeScreenState createState() =>
      _DiscoverKnowYorAssetLargeScreenState();
}

class _DiscoverKnowYorAssetLargeScreenState
    extends State<DiscoverKnowYorAssetLargeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RangeValues _currentRangeValues;
  TextEditingController _popupSearchFieldController = TextEditingController();
  OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(
      color: Color(0xffeeeeee),
    ),
  );

  List<RICs> _searchList = [];
  RICs selectedRICs;

  List _filterList = [];

  StateSetter _setState;

  bool _showFilterProgress = false;

  // Constants begin here.........

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
        },
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
      ]
    },
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
    'bonds': {'Govt': 'Govt'},
    'commodity': {'Commodity': 'Commodity'},
  };

  Map filterOptionSelection = {
    'sort_order': 'desc',
    'sortby': 'tna',
    'type': 'funds'
  };

  Future<Null> _analyticsCurrentScreen() async {
    await FirebaseAnalytics().setCurrentScreen(
        screenName: 'know_your_assets',
        screenClassOverride: 'know_your_assets');
  }

  Future<Null> _analyticsSearchEvent(String searchTerm) async {
    await FirebaseAnalytics().logEvent(name: 'search', parameters: {
      'search_term': searchTerm,
      'item_id': "know_your_assets",
      'item_name': "know_your_assets_search",
      'content_type': "search_button",
    });
  }

  Future<Null> _analyticsSortEvent(String sortTerm) async {
    await FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "add_manually",
      'item_name': "add_new_asset_sort",
      'content_type': "click_sort_box",
      'content': sortTerm
    });
  }

  Future<Null> _analyticsResultCountEvent(String count) async {
    await FirebaseAnalytics()
        .logEvent(name: 'view_search_results', parameters: {
      'item_id': "know_your_assets",
      'item_name': "know_your_assets_analyse_result_content",
      'content_type': "click_content_body",
      'content': count
    });
  }

  String activeFilterOption = 'sortby';

  // Constanst ends here..........

  Map filterOptionSelectionReset;

  bool _showSearchLoader = false;

  // Functions Strats here........

  void updateKeyStatsRange() async {
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

  // Functions ends here..........

  @override
  void initState() {
    _analyticsCurrentScreen();
    filterOptionSelectionReset = Map.from(filterOptionSelection);
    widget.model.userSettings['allowed_zones'].forEach((zone) {
      filterOptions['zone']['optionGroups'][0]['options'][zone] =
          zone.toUpperCase();

      if (zone == "in") {
        filterOptionSelection['zone'] = ['in'];
      }
    });
    updateKeyStatsRange();
    _popupSearchFieldController.addListener(() {
      if (_popupSearchFieldController.text.length >= 3) {
        _showSearchLoader = true;
      }
    });
    super.initState();
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
        backgroundColor: DiscoverStyles.backgroundColor,
        appBar: _buildAppBar(),
        drawer: WidgetDrawer(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
      child: NavigationTobBar(
        widget.model,
        openDrawer: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftMenu(),
          _buildBodyChild(),
        ],
      ),
    );
  }

  _buildLeftMenu() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return deviceType == DeviceScreenType.tablet
        ? SizedBox()
        : NavigationLeftBar(
            isSideMenuHeadingSelected: 3,
            isSideMenuSelected: 7,
          );
  }

  Widget _buildBodyChild() {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
            left: 27.0,
            right: 60.0,
            bottom: 10.0,
          ),
          child: _buildKnowAssetContent(),
        ),
      ),
    );
  }

  Column _buildKnowAssetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        SizedBox(height: 11.0),
        _buildContentText(),
        SizedBox(height: 12.0),
        _buildSearchSortAndFilterView(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Know your Assets',
      style: DiscoverStyles.heading,
    );
  }

  Widget _buildContentText() {
    return Text(
      DiscoverStyles.knowYourAssetContentText,
      style: DiscoverStyles.content,
    );
  }

  Widget _buildSearchSortAndFilterView() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(24.0),
        child: ResponsiveBuilder(
          builder: (BuildContext context, SizingInformation sizingInformation) {
            if (sizingInformation.isDesktop) {
              return GridView.count(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(4.0),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildImageContainer(
                    'assets/images/icons/icon_discover_search.png',
                    'Search',
                    DiscoverStyles.searchText,
                    _searchPopUp,
                  ),
                  _buildImageContainer(
                    'assets/images/icons/icon_discover_filter.png',
                    'Sort & Filter',
                    DiscoverStyles.sortAndFilterText,
                    _filterPopUp,
                  ),
                ],
              );
            } else if (sizingInformation.isTablet) {
              return GridView.count(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                padding: const EdgeInsets.all(4.0),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildImageContainer(
                      'assets/images/icons/icon_discover_search.png',
                      'Search',
                      DiscoverStyles.searchText,
                      _searchPopUp,
                      isTablet: true),
                  _buildImageContainer(
                      'assets/images/icons/icon_discover_filter.png',
                      'Sort & Filter',
                      DiscoverStyles.sortAndFilterText,
                      _filterPopUp,
                      isTablet: true),
                ],
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Widget _buildImageContainer(
      String image, String title, String content, Function onTap,
      {bool isTablet = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFe9e9e9),
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                width: 65,
                height: 65,
              ),
              SizedBox(height: isTablet ? 20 : 54),
              Text(
                title,
                style: DiscoverStyles.sortAndFilterConentTitle,
              ),
              SizedBox(height: 8),
              Text(
                content,
                style: DiscoverStyles.sortAndFilterContentDescription,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Search Pop-up window strats here........

  void _searchPopUp() {
    setState(() {
      selectedRICs = null;
      _popupSearchFieldController.clear();
      _searchList = [];
      _showSearchLoader = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Container(
                width: 700,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _smartSearchContainer(),
                    _searchBody(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _smartSearchContainer() {
    return Container(
      width: 160,
      height: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Qfinr Smart Search\n",
              style: appBenchmarkPortfolioName,
            ),
            Text(
              "To search for any asset, you can either type the name in full (for ex: Reliance Industries), or use our Smart Search feature. Smart Search makes it faster and more efficient for you to access your favorite stocks, ETFs, or mutual funds\n",
              style: bodyText4,
            ),
            Text(
              "To use Smart Search, before you type the name that you are looking to search, just type in one of the letters shown below followed by a space:\n",
              style: bodyText4,
            ),
            Text(
              "'s' - to search for stocks (ex: 's nippon')",
              style: bodyText4,
            ),
            Text(
              "'e' - to search for ETFs (ex: 'e nippon')",
              style: bodyText4,
            ),
            Text(
              "'f' - to search for Mutual Funds (ex: 'f nippon')",
              style: bodyText4,
            ),
          ],
        ),
      ),
    );
  }

  _searchBody() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Enter instrument name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'nunito',
                  letterSpacing: 0.26,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: _searchBox(),
            ),
            divider(),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: resetButton(
                'Cancel',
                borderColor: colorBlue,
                textColor: colorBlue,
                onPressFunction: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _popupsearchfield(),
          _popupSearchList(),
        ],
      ),
    );
  }

  Widget _popupsearchfield() {
    return TextField(
      autofocus: true,
      controller: _popupSearchFieldController,
      keyboardType: TextInputType.text,
      onChanged: (String value) {
        _analyticsSearchEvent(value);
        _setState(() {
          selectedRICs = null;
        });
        if (value.length >= 3) {
          _getALlPosts(value);
        } else {
          _setState(() {
            _searchList = [];
          });
        }
      },
      onSubmitted: (value) {
        if (value.length >= 3) {
          _getALlPosts(value);
        } else {
          _setState(() {
            _searchList = [];
          });
        }
      },
      style: inputFieldStyle,
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color(0xff9f9f9f),
          letterSpacing: 1.0,
        ),
        enabledBorder: _border,
        disabledBorder: _border,
        focusedBorder: _border,
        errorBorder: _border,
        prefixIcon: Icon(
          Icons.search,
          color: colorActive,
        ),
      ),
    );
  }

  Widget _popupSearchList() {
    return Expanded(
      child: _showSearchLoader
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _searchList.length == 0
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    'No record found',
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Color(0xff3c4257),
                        ),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchList.length ?? 0,
                  itemBuilder: (context, index) {
                    Map element = {
                      'ric': _searchList[index].ric,
                      'name': _searchList[index].name,
                      'type': _searchList[index].fundType,
                      'zone': _searchList[index].zone,
                    };
                    return fundBoxForFiltration1(
                      context,
                      element,
                      onTap: () {
                        formResponse(
                          singleRIC: true,
                          ric: element['ric'],
                          ricType: element['type'],
                        );
                      },
                      isSelected: selectedRICs == null
                          ? false
                          : selectedRICs.ric == _searchList[index].ric
                              ? true
                              : false,
                      isSearch: true,
                    );
                  },
                ),
    );
  }

  Widget fundBoxForFiltration1(BuildContext context, Map portfolio,
      {Function refreshParentState,
      Function onTap,
      Widget sortWidget,
      String sortCaption,
      bool readOnly = false,
      bool isSelected = false,
      bool isSearch = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSearch
              ? isSelected
                  ? Color(0xffe2edff)
                  : Colors.white
              : Colors.white,
          border: Border.all(
            color: isSearch
                ? Color(0xffe8e8e8)
                : isSelected
                    ? colorActive
                    : Color(0xffe8e8e8),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(limitChar(portfolio['name'], length: 35),
                style: portfolioBoxName),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    widgetBubble(
                      title: portfolio['type'] != null
                          ? portfolio['type'].toUpperCase()
                          : "",
                      leftMargin: 0,
                      bgColor: isSearch
                          ? isSelected
                              ? Color(0xffe2edff)
                              : Colors.white
                          : Colors.white,
                      textColor: Color(0xffa7a7a7),
                    ),
                    SizedBox(width: 7),
                    widgetZoneFlag(portfolio['zone']),
                  ],
                ),
                Row(
                  children: [
                    sortCaption != null ? Text(sortCaption) : emptyWidget,
                    portfolio.containsKey('sortby') &&
                            portfolio['sortby'] != null
                        ? Text(roundDouble(portfolio['sortby'],
                            decimalLength: sortWidget != null ? 0 : 2))
                        : emptyWidget,
                    sortWidget != null ? sortWidget : emptyWidget
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget resetButton(title,
      {Function onPressFunction,
      Color bgColor: Colors.white,
      Color borderColor = Colors.white,
      Color textColor = Colors.black,
      double fontSize = 10,
      FontWeight fontWeight = FontWeight.w800,
      Alignment alignment = Alignment.center}) {
    return TextButton(
      onPressed: onPressFunction,
      child: Container(
        alignment: alignment,
        padding: EdgeInsets.all(0),
        width: 166,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(width: 1.0, color: borderColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: 'nunito',
            letterSpacing: 0,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // Search Pop-Up window ends here...................

  // Filter Pop-Up window Starts here.................

  void _filterPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Container(
                width: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort & Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'nunito',
                        letterSpacing: 0.26,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                        "Shortlist assets using one or more criteria. Add those that fit your yardsticks.",
                        style: bodyText4),
                    SizedBox(height: 9),
                    divider(),
                    Expanded(
                        flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: filterOptions.entries
                                  .map((entry) => filterOptionWidget(entry))
                                  .toList(),
                            ),
                            Expanded(
                              child: filterOptionContainer(),
                            ),
                          ],
                        )),
                    ResponsiveBuilder(
                      builder: (context, sizingInformation) {
                        if (sizingInformation.deviceScreenType ==
                            DeviceScreenType.desktop) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 13, vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                resetButton(
                                  'Cancel',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: () {
                                    _resetFilter();
                                    Navigator.pop(context);
                                  },
                                ),
                                SizedBox(width: 10),
                                resetButton(
                                  'Reset',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: _resetFilter,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    width: 166,
                                    child: gradientButton(
                                      context: context,
                                      caption: 'Apply',
                                      onPressFunction: _applyFilter,
                                      miniButton: true,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                        if (sizingInformation.deviceScreenType ==
                            DeviceScreenType.tablet) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                resetButton(
                                  'Cancel',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: () {
                                    _resetFilter();
                                    Navigator.pop(context);
                                  },
                                ),
                                SizedBox(width: 5),
                                // SizedBox(width: 10),
                                resetButton(
                                  'Reset',
                                  borderColor: colorBlue,
                                  textColor: colorBlue,
                                  onPressFunction: _resetFilter,
                                ),
                                SizedBox(width: 5),
                                // SizedBox(width: 10),
                                Container(
                                  width: 166,
                                  child: gradientButton(
                                    context: context,
                                    caption: 'Apply',
                                    onPressFunction: _applyFilter,
                                    miniButton: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget filterOptionWidget(var filterOption) {
    if ((['share_class', 'aum_size'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                !['funds'].contains(filterOptionSelection['type'])) ||
        ['overall_score'].contains(filterOption.key) &&
            (!filterOptionSelection.containsKey('type') ||
                !['funds', 'etf'].contains(filterOptionSelection['type'])) ||
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
        padding: EdgeInsets.symmetric(
              vertical: getScaledValue(16),
            ) +
            EdgeInsets.only(
              left: getScaledValue(16),
              right: getScaledValue(10),
            ),
        width: getScaledValue(140),
        decoration: BoxDecoration(
          color: activeFilterOption == filterOption.key
              ? Color(0xffecf4ff)
              : Colors.white,
          border: Border(
            bottom: BorderSide(
              width: getScaledValue(1),
              color: Color(0xffeeeeee),
            ),
            right: BorderSide(
              width: getScaledValue(1),
              color: Color(0xffeeeeee),
            ),
          ),
        ),
        child: Row(
          children: [
            (filterOptionSelection.containsKey(filterOption.key) &&
                        filterOptionSelection[filterOption.key] != null &&
                        filterOptionSelection[filterOption.key].length != 0) ||
                    keyStatsSelected(filterOption.key)
                ? svgImage('assets/icon/oval.svg')
                : SizedBox(width: getScaledValue(4)),
            SizedBox(width: getScaledValue(5)),
            Expanded(
              child: Text(
                filterOption.value['title'],
                style: keyStatsBodyText7,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget filterOptionContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      child: ListView(
        shrinkWrap: true,
        children: [
          filterOptions[activeFilterOption]['type'] == "sort"
              ? Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      sortRow('Low to High', 'asc'),
                      sortRow('High to Low', 'desc'),
                    ],
                  ),
                )
              : emptyWidget,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...filterOptions[activeFilterOption]['optionGroups']
                  .map((optionGroup) => filterOptionGroup(optionGroup))
                  .toList()
            ],
          )
        ],
      ),
    );
  }

  Widget sortRow(String caption, String orderby) {
    return GestureDetector(
      onTap: () {
        _analyticsSortEvent(caption);
        _setState(() {
          filterOptionSelection['sort_order'] = orderby;
        });
      },
      child: boxContainer(caption,
          isActive:
              filterOptionSelection['sort_order'] == orderby ? true : false),
    );
  }

  Container boxContainer(String optionName, {bool isActive = false}) {
    return Container(
      height: 33,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Color(0xffe2edff) : Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: isActive ? colorActive : Color(0xffeeeeee),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            optionName,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'nunito',
              letterSpacing: 0,
              color: isActive ? colorActive : Color(0xff979797),
            ),
          ),
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
    return Container(
        padding: EdgeInsets.only(bottom: getScaledValue(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            optionGroup['group_title'] != ""
                ? Text(optionGroup['group_title'].toUpperCase(),
                    style: keyStatsBodyText7)
                : emptyWidget,
            optionGroup['group_title'] != ""
                ? SizedBox(height: getScaledValue(9))
                : emptyWidget,
            filterOptions[activeFilterOption]['optionType'] == "radio"
                ? radioBoxOption(optionGroup)
                : otherOptions(optionGroup)
          ],
        ));
  }

  Wrap radioBoxOption(var optionGroup) {
    return Wrap(
      children: [
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
          return Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 5),
            child: Container(
              width: getScaledValue(125),
              child: GestureDetector(
                onTap: () => filterOptionValueUpdate(value: entry.key),
                child: boxContainer(
                  entry.value,
                  isActive: filterOptionSelection['sortby'] == entry.key ||
                          filterOptionSelection['type'] == entry.key ||
                          filterOptionSelection['share_class'] == entry.key
                      ? true
                      : false,
                ),
              ),
            ),
          );
        }).toList()
      ],
    );
  }

  Column otherOptions(var optionGroup) {
    var start = 0.00;
    var end = 0.00;
    return Column(
      children: [
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

            _currentRangeValues = RangeValues(start.toDouble(), end.toDouble());
          }
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                filterOptions[activeFilterOption]['optionType'] == "checkbox"
                    ? ListTileTheme(
                        contentPadding: EdgeInsets.all(0),
                        child: CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: filterOptionTextRow(entry.value),
                          value: filterOptionSelection
                                      .containsKey(activeFilterOption) &&
                                  filterOptionSelection[activeFilterOption]
                                      .contains(entry.key)
                              ? true
                              : false,
                          onChanged: (bool value) {
                            filterOptionValueUpdate(value: entry.key);
                          },
                          activeColor: colorBlue,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value['title'],
                            style: bodyText1.copyWith(color: colorDarkGrey),
                          ),

                          RangeSlider(
                            values: _currentRangeValues,
                            min: double.parse(entry.value['min']),
                            max: double.parse(entry.value['max']),
                            divisions:
                                double.parse(entry.value['max']).toInt() -
                                    double.parse(entry.value['min']).toInt(),
                            labels: RangeLabels(
                              _currentRangeValues.start.round().toString(),
                              _currentRangeValues.end.round().toString(),
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
                          //   lowerValue: double.parse(filterOptionSelection
                          //           .containsKey(optionGroup['key'])
                          //       ? filterOptionSelection[optionGroup['key']]
                          //           ['min']
                          //       : entry.value['min']),
                          //   upperValue: double.parse(filterOptionSelection
                          //           .containsKey(optionGroup['key'])
                          //       ? filterOptionSelection[optionGroup['key']]
                          //           ['max']
                          //       : entry.value['max']),
                          //   divisions:
                          //       double.parse(entry.value['max']).toInt() -
                          //           double.parse(entry.value['min']).toInt(),
                          //   showValueIndicator: true,
                          //   onChanged:
                          //       (double newLowerValue, double newUpperValue) {
                          //     filterOptionValueUpdate(
                          //       value: newLowerValue.toString(),
                          //       value2: newUpperValue.toString(),
                          //       optionKey: optionGroup['key'],
                          //     );
                          //   },
                          // ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filterOptionSelection
                                        .containsKey(optionGroup['key'])
                                    ? filterOptionSelection[optionGroup['key']]
                                        ['min']
                                    : entry.value['min'],
                                style: appBenchmarkReturnType2,
                              ),
                              Text(
                                filterOptionSelection
                                        .containsKey(optionGroup['key'])
                                    ? filterOptionSelection[optionGroup['key']]
                                        ['max']
                                    : entry.value['max'],
                                style: appBenchmarkReturnType2,
                              ),
                            ],
                          ),
                          SizedBox(height: getScaledValue(6))
                        ],
                      )
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget filterOptionTextRow(String title) {
    if (activeFilterOption == "zone") {
      return Row(
        children: [
          widgetZoneFlag(title.toLowerCase()),
          SizedBox(width: 5),
          Text(
            title,
            style: bodyText1.copyWith(color: colorDarkGrey),
          ),
        ],
      );
    } else {
      return Text(
        title,
        style: bodyText1.copyWith(color: colorDarkGrey),
      );
    }
  }

  // Filter Pop-up window ends here...................

  // FilterResult Pop-up window strats here...........

  void _filterResultPopup() {
    _analyticsResultCountEvent(_filterList.length.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Container(
                width: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Results',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'nunito',
                                  letterSpacing: 0.26,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                _filterList.length.toString() +
                                    " " +
                                    fundTypeCaption(
                                        filterOptionSelection['type']) +
                                    " shortlisted",
                                style: bodyText4,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _resetFilter();
                          },
                          child: Icon(
                            Icons.close,
                            color: Color(0xffa5a5a5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 9),
                    divider(),
                    _showFilterProgress
                        ? Expanded(
                            child: preLoader(title: ""),
                          )
                        : _filterList?.length == 0
                            ? Center(child: Text('No record found'))
                            : Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: ListView(
                                        children: [
                                          SizedBox(height: 10),
                                          ..._filterList
                                              .map(
                                                (element) =>
                                                    fundBoxForFiltration1(
                                                  context,
                                                  element,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _showNavigationLoaderPopUp();
                                                    formResponse(
                                                      singleRIC: true,
                                                      ric: element['ric'],
                                                      ricType: element['type'],
                                                    );
                                                  },
                                                  isSelected:
                                                      selectedRICs == null
                                                          ? false
                                                          : selectedRICs.ric ==
                                                                  element['ric']
                                                              ? true
                                                              : false,
                                                  sortCaption: sortByCaption(),
                                                  sortWidget: filterOptionSelection
                                                              .containsKey(
                                                                  'sortby') &&
                                                          [
                                                            'overall_rating',
                                                            'tr_rating',
                                                            'alpha_rating',
                                                            'srri',
                                                            'tracking_rating'
                                                          ].contains(
                                                            filterOptionSelection[
                                                                'sortby'],
                                                          )
                                                      ? svgImage(
                                                          "assets/icon/star_filled.svg")
                                                      : (filterOptionSelection[
                                                                  'sortby'] ==
                                                              "tna"
                                                          ? Text('M')
                                                          : null),
                                                ),
                                              )
                                              .toList()
                                        ],
                                      ),
                                    ),
                                    divider(),
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: resetButton(
                                        'Cancel',
                                        borderColor: colorBlue,
                                        textColor: colorBlue,
                                        onPressFunction: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  selectInstrumentAction(RICs selectedRIC, {Map ricMap}) {
    _setState(() {
      if (selectedRIC == null) {
        selectedRICs = RICs(
          name: ricMap['name'],
          zone: ricMap['zone'],
          ric: ricMap['ric'],
          fundType: ricMap['type'],
        );
      } else {
        selectedRICs = selectedRIC;
      }
    });
  }

  void formResponse(
      {bool singleRIC = false, String ric = "", String ricType}) async {
    if (['Funds', 'ETF'].contains(ricType)) {
      Navigator.pop(context);
      _showNavigationLoaderPopUp();
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
        Navigator.pop(context);
        Navigator.pushNamed(context, '/knowFundReport',
            arguments: {'responseData': responseData});
      } else {
        Navigator.pop(context);
        showAlertDialogBox(context, 'Error!', responseData['response']);
      }
    } else {
      Navigator.pop(context);
      Navigator.of(context).pushNamed('/fund_info', arguments: {'ric': ric});
    }
  }

  void _showNavigationLoaderPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            padding: EdgeInsets.all(50),
            width: 560,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      svgImage(
                        'assets/icon/icon_analyzer_loader.svg',
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Analyzing your investments…',
                        style: preLoaderBodyText1,
                      ),
                    ],
                  ),
                ),
                Text(
                  'HOLD ON TIGHT',
                  style: preLoaderBodyText2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FilterResult Pop-up window ends here.............

  _getALlPosts(String search) async {
    List funds = await widget.model.getFundName(search, 'all');
    List<RICs> searchList = List.generate(funds.length, (int index) {
      return RICs(
        ric: funds[index]['ric'],
        name: funds[index]['name'],
        zone: funds[index]['zone'],
        fundType: funds[index]['type'],
      );
    });

    _setState(() {
      _searchList = searchList;
      _showSearchLoader = false;
    });
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

  void _resetFilter() {
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

  _applyFilter() async {
    Navigator.of(context).pop();
    setState(() {
      _showFilterProgress = true;
      selectedRICs = null;
      _filterResultPopup();
      _filterList = [];
      // log.d("Filter List length before api call:- ${_filterList.length}");
    });
    Map responseData = await widget.model.fundScreener(filterOptionSelection);
    _setState(() {
      if (responseData.isNotEmpty) {
        _filterList = responseData['response'];
        // log.d("Filter List length after api call:- ${_filterList.length}");
        _showFilterProgress = false;
      }
    });
  }
}

// class RICs {
//   final String ric;
//   final String zone;
//   final String fundType;
//   final String name;

//   RICs({this.ric, this.zone, this.fundType, this.name});
// }
