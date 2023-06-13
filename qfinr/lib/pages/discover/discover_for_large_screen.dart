import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/discover/discover_graph_view.dart';
import 'package:qfinr/pages/discover/discover_styles.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DiscoverForLargeScreen extends StatefulWidget {
  final MainModel model;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  DiscoverForLargeScreen(this.model, {this.analytics, this.observer});

  @override
  _DiscoverForLargeScreenState createState() => _DiscoverForLargeScreenState();
}

class _DiscoverForLargeScreenState extends State<DiscoverForLargeScreen> {
  final log = getLogger('DiscoverForLargeScreen');
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BasketResponse basketResponse;
  IndicesPerformance indicesResponse;

  List<String> _tabData = [];
  List<bool> _activeList = [];
  String _selectedTabText = '';
  String graphSelectedZone = '';
  int graphDataPosition = 0;

  Future getBasket() async {
    setState(() {
      widget.model.setLoader(true);
    });
    basketResponse = await widget.model.getLocalMIBaskets();
    indicesResponse = await widget.model.getIndicesPerformance();
    await callTabData();

    setState(() {
      widget.model.setLoader(false);
    });
  }

  void callTabData() async {
    setState(() {
      Map<String, IndicesPerformanceData> map =
          indicesResponse.response.toJson();
      map.forEach((key, value) {
        _tabData.add(value.zone.toString().toUpperCase());
      });
      _tabData = _tabData.toSet().toList();
    });
    await setData();
  }

  void setData() async {
    setState(() {
      for (int i = 0; i < _tabData?.length; i++) {
        _activeList.add(false);
      }
      _activeList[0] = true;
      _selectedTabText = _tabData[0];

      for (var i = 0; i < basketResponse.response.length; i++) {
        var selected_zone = basketResponse.response[i].zone;
        if (_selectedTabText.toLowerCase() == selected_zone) {
          graphSelectedZone = basketResponse.response[i].zone;
          graphDataPosition = i;

          break;
        }
      }
    });
  }

  void _changeSelectedTab(int index) {
    setState(() {
      for (int i = 0; i < _activeList?.length; i++) {
        _activeList[i] = false;
      }
      _activeList[index] = true;
      _selectedTabText = _tabData[index];

      for (var i = 0; i < basketResponse.response.length; i++) {
        var selected_zone = basketResponse.response[i].zone;
        if (_selectedTabText.toLowerCase() == selected_zone) {
          graphSelectedZone = basketResponse.response[i].zone;
          graphDataPosition = i;

          break;
        }
      }
    });
  }

  @override
  void initState() {
    getBasket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftMenu(),
        _buildBodyChild(),
      ],
    );
  }

  _buildLeftMenu() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return deviceType == DeviceScreenType.tablet
        ? SizedBox()
        : NavigationLeftBar(
            isSideMenuHeadingSelected: 3,
            isSideMenuSelected: 5,
          );
  }

  Widget _buildBodyChild() {
    return Expanded(
      child: !widget.model.isLoading && basketResponse != null
          ? _buildChildView()
          : widget.model.isLoading
              ? Center(child: preLoader())
              : Center(
                  child: Text("Something is not right!"),
                ),
    );
  }

  SingleChildScrollView _buildChildView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 50.0,
          left: 27.0,
          right: 60.0,
          bottom: 10.0,
        ),
        child: _buildDiscoverContent(),
      ),
    );
  }

  Column _buildDiscoverContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        SizedBox(height: 11.0),
        _buildMarketTodayContainer(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Discover Market Insights',
      style: DiscoverStyles.heading,
    );
  }

  Widget _buildMarketTodayContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 27.0,
        vertical: 22.0,
      ),
      decoration: DiscoverStyles.marketContainerDecoration,
      child: _buildMarketTodayChild(),
    );
  }

  Widget _buildMarketTodayChild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubTitle(),
        SizedBox(height: 24.0),
        _buildMenuTabView(),
        _buildRowView(),
      ],
    );
  }

  Widget _buildSubTitle() {
    return Text(
      'Market Today',
      style: DiscoverStyles.subHeading,
    );
  }

  Widget _buildMenuTabView() {
    return Stack(
      children: [
        _buildMenuItemHolder(),
        _howAreTheseCalculatedQn(),
        _buildUnderLine(),
      ],
    );
  }

  Widget _buildMenuItemHolder() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: _buildMenuTabs(),
    );
  }

  Widget _buildMenuTabs() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: _tabData?.length,
      itemBuilder: (_, int index) {
        return _buildSingleMenuTab(
          _tabData[index],
          index,
        );
      },
    );
  }

  Widget _buildSingleMenuTab(String text, int index) {
    final isSelected = _activeList.indexWhere((element) => element);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: 50.0,
      decoration: DiscoverStyles.buildBorder(
        isSelected == index ? true : false,
      ),
      child: _buildMenuButton(index, text),
    );
  }

  TextButton _buildMenuButton(int index, String text) {
    return TextButton(
      onPressed: () => _changeSelectedTab(index),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _howAreTheseCalculatedQn() {
    return Positioned(
      bottom: 10.0,
      right: 10.0,
      child: GestureDetector(
        onTap: () {
          DiscoverStyles.showPopUp(
            context,
            isIconAlert: false,
          );
        },
        child: Text(
          "How are these calculated?",
          style: DiscoverStyles.howToCalculate,
        ),
      ),
    );
  }

  Widget _buildUnderLine() {
    return Positioned(
      bottom: 0.0,
      child: DiscoverStyles.buildDivider(
        MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget _buildRowView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildMenuDataRow()),
        Visibility(
            visible: _selectedTabText.toLowerCase() == graphSelectedZone
                ? true
                : false,
            child: Expanded(flex: 3, child: _buildGraphContainer()))
      ],
    );
  }

  Widget _buildMenuDataRow() {
    Map<String, IndicesPerformanceData> dataMap =
        indicesResponse.response.indicesPreformanceMap;
    return ListView.separated(
      padding: EdgeInsets.only(top: 25.0),
      shrinkWrap: true,
      itemCount: dataMap?.length,
      separatorBuilder: (BuildContext context, int pos) {
        String key = dataMap.keys.elementAt(pos);
        return Visibility(
          visible: _selectedTabText.toLowerCase() ==
                  dataMap[key].zone.toString().toLowerCase()
              ? true
              : false,
          child: Divider(
            color: Colors.grey[200],
            height: 40.0,
            thickness: 2.0,
          ),
        );
      },
      itemBuilder: (_, int index) {
        String key = dataMap.keys.elementAt(index);
        return Visibility(
          visible: _selectedTabText.toLowerCase() ==
                  dataMap[key].zone.toString().toLowerCase()
              ? true
              : false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBenchmarkColumnData(dataMap, key),
              _buildDayReturnColumnData(dataMap, key),
              _buildMonthToDateColumnData(dataMap, key),
              _buildYearToDateColumnData(dataMap, key),
            ],
          ),
        );
      },
    );
  }

  Expanded _buildBenchmarkColumnData(
      Map<String, IndicesPerformanceData> dataMap, String key) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dataMap[key].name.toString()}',
            style: DiscoverStyles.discoverRowTextDark,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${dataMap[key].data.day.value.toString()} ',
                  style: DiscoverStyles.discoverRowTextLight,
                ),
                TextSpan(
                  text: '(${dataMap[key].data.day.change.toString()})',
                  style: _setValueColor(
                    dataMap[key].data.day.changeSign.toString(),
                    false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildDayReturnColumnData(
      Map<String, IndicesPerformanceData> dataMap, String key) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day Returns',
            style: DiscoverStyles.discoverRowTextLight,
          ),
          Text(
            '${dataMap[key].data.day.changeDifference.toString()}',
            style: _setValueColor(
              dataMap[key].data.month.changeSign.toString(),
              true,
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildMonthToDateColumnData(
      Map<String, IndicesPerformanceData> dataMap, String key) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Month to Date ',
                  style: DiscoverStyles.discoverRowTextLight,
                ),
                TextSpan(
                  text: '${dataMap[key].data.month.change.toString()}',
                  style: _setValueColor(
                    dataMap[key].data.month.changeSign.toString(),
                    true,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${dataMap[key].data.month.changeDifference.toString()}',
            style: _setValueColor(
              dataMap[key].data.month.changeSign.toString(),
              true,
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildYearToDateColumnData(
      Map<String, IndicesPerformanceData> dataMap, String key) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Year to Date ',
                  style: DiscoverStyles.discoverRowTextLight,
                ),
                TextSpan(
                  text: '${dataMap[key].data.year.change.toString()}',
                  style: _setValueColor(
                    dataMap[key].data.year.changeSign.toString(),
                    true,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${dataMap[key].data.year.changeDifference.toString()}',
            style: _setValueColor(
              dataMap[key].data.year.changeSign.toString(),
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphContainer() {
    return Container(
      height: 450,
      child: DiscoverGraphView(
          basketResponse: this.basketResponse,
          selectedTabText: this._selectedTabText,
          graphDataPosition: this.graphDataPosition),
    );
  }

  TextStyle _setValueColor(String value, bool isDark) {
    if (value.toLowerCase() == 'changesign.up') {
      if (isDark) {
        return DiscoverStyles.discoverRowTextGreen1;
      }
      return DiscoverStyles.discoverRowTextGreen;
    } else {
      if (isDark) {
        return DiscoverStyles.discoverRowTextRed1;
      }
    }
    return DiscoverStyles.discoverRowTextRed;
  }
}
