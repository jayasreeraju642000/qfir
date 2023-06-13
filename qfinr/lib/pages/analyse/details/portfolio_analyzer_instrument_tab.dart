import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'common_widgets_analyse_details.dart';

class PortfolioAnalyzerInstrumentTab extends StatefulWidget {
  final Map summary;

  PortfolioAnalyzerInstrumentTab(this.summary);

  @override
  State<StatefulWidget> createState() {
    return _PortfolioAnalyzerInstrumentTab();
  }
}

class _PortfolioAnalyzerInstrumentTab
    extends State<PortfolioAnalyzerInstrumentTab> {
  bool sortCorrByAsc = true;
  int currentSortColumn = 1;
  bool sortStatByAsc = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getCorrelationData(),
          SizedBox(height: 50),
          _getSummaryStatisticsData(),
        ],
      ),
    );
  }

  _getCorrelationData() {
    if (widget.summary['instrumentCorelation'] == null) {
      return Container();
    }
    List instrumentCorelationList =
        widget.summary['instrumentCorelation'] as List;
    if (instrumentCorelationList.length == 0 ||
        instrumentCorelationList.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Correlation",
          style: _headerStyle(),
        ),
        Text(
          "Correlation only shows some of the correlated pairs",
          style: _subHeaderStyle(),
        ),
        SizedBox(height: 16),
        _corelation(),
      ],
    );
  }

  _corelation() {
    List<TableRow> rowList = [];
    rowList.add(_corelationHeader());
    List instrumentCorelationList =
        widget.summary['instrumentCorelation'] as List;
    !sortCorrByAsc
        ? instrumentCorelationList
            .sort((a, b) => (b['value']).compareTo(a['value']))
        : instrumentCorelationList
            .sort((a, b) => (a['value']).compareTo(b['value']));
    instrumentCorelationList.forEach((element) {
      String firstPortfolio = "";
      String secondPortfolio = "";
      String corelationValue = "";
      Map portfolioCorelation = element as Map;
      portfolioCorelation.forEach((key, value) {
        if (key == "instrument_1") {
          firstPortfolio = value;
        } else if (key == "instrument_2") {
          secondPortfolio = value;
        } else {
          corelationValue = value.toString();
        }
      });
      rowList.add(_corelationRow(
        firstPortfolio,
        secondPortfolio,
        corelationValue,
      ));
    });
    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: IntrinsicColumnWidth(),
      children: rowList,
    );
  }

  _corelationHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xfff5f6fa),
      ),
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Instrument 1",
            style: _tableHeaderStyle(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Instrument 2",
            style: _tableHeaderStyle(),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              sortCorrByAsc = !sortCorrByAsc;
              _corelation();
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Text(
                  "Corr",
                  style: _tableHeaderStyle(),
                ),
                SizedBox(
                  width: 12,
                ),
                Image.asset(
                  sortCorrByAsc
                      ? "assets/images/asc_sort.png"
                      : "assets/images/desc_sort.png",
                  width: 16,
                  height: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _corelationRow(
      String firstInstrument, String secondInstrument, String value) {
    return TableRow(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12.0),
          width: 200,
          child: Text(
            firstInstrument,
            style: _tableCorrTextStyle(value),
            softWrap: true,
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          width: 200,
          child: Text(
            secondInstrument,
            style: _tableCorrTextStyle(value),
            softWrap: true,
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            value,
            style: _tableCorrTextStyle(value),
          ),
        ),
      ],
    );
  }

  _getSummaryStatisticsData() {
    if (widget.summary['instrumentStats'] == null) {
      return Container();
    }
    List instrumentStatsList = widget.summary['instrumentStats'] as List;
    if (instrumentStatsList.length == 0 || instrumentStatsList.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Summary Statistics",
          style: _headerStyle(),
        ),
        SizedBox(height: 16),
        _stats(0),
      ],
    );
  }

  _stats(columnPos) {
    List<TableRow> rowList = [];
    rowList.add(_statRowHeader());
    List instrumentStatsList = widget.summary['instrumentStats'] as List;
    if (columnPos == 1) {
      !sortStatByAsc
          ? instrumentStatsList.sort((a, b) =>
              (b['name'].toString().toLowerCase())
                  .compareTo(a['name'].toString().toLowerCase()))
          : instrumentStatsList.sort((a, b) =>
              (a['name'].toString().toLowerCase())
                  .compareTo(b['name'].toString().toLowerCase()));
    } else if (columnPos == 2) {
      !sortStatByAsc
          ? instrumentStatsList
              .sort((a, b) => (b['fund_type']).compareTo(a['fund_type']))
          : instrumentStatsList
              .sort((a, b) => (a['fund_type']).compareTo(b['fund_type']));
    } else if (columnPos == 3) {
      !sortStatByAsc
          ? instrumentStatsList.sort((a, b) => (b['cagr']).compareTo(a['cagr']))
          : instrumentStatsList
              .sort((a, b) => (a['cagr']).compareTo(b['cagr']));
    } else if (columnPos == 4) {
      !sortStatByAsc
          ? instrumentStatsList
              .sort((a, b) => (b['stddev']).compareTo(a['stddev']))
          : instrumentStatsList
              .sort((a, b) => (a['stddev']).compareTo(b['stddev']));
    } else if (columnPos == 5) {
      !sortStatByAsc
          ? instrumentStatsList
              .sort((a, b) => (b['drawdown']).compareTo(a['drawdown']))
          : instrumentStatsList
              .sort((a, b) => (a['drawdown']).compareTo(b['drawdown']));
    } else if (columnPos == 6) {
      !sortStatByAsc
          ? instrumentStatsList
              .sort((a, b) => (b['rawsharpe']).compareTo(a['rawsharpe']))
          : instrumentStatsList
              .sort((a, b) => (a['rawsharpe']).compareTo(b['rawsharpe']));
    } else if (columnPos == 7) {
      !sortStatByAsc
          ? instrumentStatsList.sort((a, b) => (b['srri']).compareTo(a['srri']))
          : instrumentStatsList
              .sort((a, b) => (a['srri']).compareTo(b['srri']));
    }

    instrumentStatsList.forEach((element) {
      String name = "";
      String fundType = "";
      String cagr = "";
      String stddev = "";
      String srri = "";
      String rawsharpe = "";
      String drawdown = "";
      String rollretmean = "";
      Map portfolioCorelation = element as Map;
      portfolioCorelation.forEach((key, value) {
        if (key == "name") {
          name = value;
        } else if (key == "fund_type") {
          fundType = value;
        } else if (key == "cagr") {
          cagr = roundDouble(value, decimalLength: 1) == "0.0"
              ? "N/A"
              : roundDouble(value, decimalLength: 1);
        } else if (key == "stddev") {
          stddev = roundDouble(value, decimalLength: 1) == "0.0"
              ? "N/A"
              : roundDouble(value, decimalLength: 1);
        } else if (key == "drawdown") {
          drawdown = roundDouble(value, decimalLength: 1) == "0.0"
              ? "N/A"
              : roundDouble(value, decimalLength: 1);
        } else if (key == "rawsharpe") {
          rawsharpe = roundDouble(value, decimalLength: 1) == "0.0"
              ? "N/A"
              : roundDouble(value, decimalLength: 1);
        } else if (key == "rollretmean") {
          rollretmean = roundDouble(value, decimalLength: 1) == "0.0"
              ? "N/A"
              : roundDouble(value, decimalLength: 1);
        } else if (key == "srri") {
          srri = roundDouble(value, decimalLength: 1) == "0.0"
              ? "N/A"
              : roundDouble(value, decimalLength: 1);
        }
      });
      rowList.add(_statRowWidget(
        name,
        fundType,
        cagr,
        stddev,
        drawdown,
        rawsharpe,
        rollretmean,
        srri,
      ));
    });
    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: IntrinsicColumnWidth(),
      children: rowList,
    );
  }

  _statRowHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xfff5f6fa),
      ),
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 1) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 1;
              _stats(1);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 100,
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Instrument\nName",
                      style: _tableHeaderStyle(),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(1),
                  width: 16,
                  height: 16,
                  color: _getSortColor(1),
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 2) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 2;
              _stats(2);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 100,
                padding: EdgeInsets.all(12.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Type",
                        style: _tableHeaderStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(2),
                  width: 16,
                  height: 16,
                  color: _getSortColor(2),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 3) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 3;
              _stats(3);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 100,
                margin: EdgeInsets.only(right: 16.0),
                padding: EdgeInsets.all(12.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Column(
                    children: [
                      Text(
                        "Return",
                        style: _tableHeaderStyle(),
                      ),
                      Text(
                        "3 yrs CAGR",
                        style: _subTableHeaderStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 8,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  child: _infoIcon(
                    "Return",
                    "The annualized 3 year returns using data as of the end of the preceding month",
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(3),
                  width: 16,
                  height: 16,
                  color: _getSortColor(3),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 4) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 4;
              _stats(4);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 100,
                margin: EdgeInsets.only(right: 16.0),
                padding: EdgeInsets.all(12.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Column(
                    children: [
                      Text(
                        "Risk",
                        style: _tableHeaderStyle(),
                      ),
                      Text(
                        "Annualised\nVolatility",
                        style: _subTableHeaderStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 8,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  child: _infoIcon(
                    "Risk",
                    "The annualized volatility of monthly returns over 3 years as of the end of the preceding month",
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(4),
                  width: 16,
                  height: 16,
                  color: _getSortColor(4),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 5) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 5;
              _stats(5);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 120,
                margin: EdgeInsets.only(right: 16.0),
                padding: EdgeInsets.all(12.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Column(
                    children: [
                      Text(
                        "Maximum\nLoss",
                        style: _tableHeaderStyle(),
                      ),
                      Text(
                        "Max\nDrawdown",
                        style: _subTableHeaderStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 8,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  child: _infoIcon(
                    "Maximum Loss",
                    "The maximum observed loss from a peak to a trough, before a new peak is attained over the past 3 years using daily prices. Maximum drawdown is an indicator of downside risk over the time period",
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(5),
                  width: 16,
                  height: 16,
                  color: _getSortColor(5),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 6) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 6;
              _stats(6);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 100,
                margin: EdgeInsets.only(right: 16.0),
                padding: EdgeInsets.all(12.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Column(
                    children: [
                      Text(
                        "Sharpe",
                        style: _tableHeaderStyle(),
                      ),
                      Text(
                        "Returns per\nunit Risk",
                        style: _subTableHeaderStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 8,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  child: _infoIcon(
                    "Sharpe",
                    "The ‘Sharpe Ratio’ calculated using the monthly returns in excess of the risk free rate over 3 years as of the end of the preceding month. We calculate the risk free rate from short term government bills",
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(6),
                  width: 16,
                  height: 16,
                  color: _getSortColor(6),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentSortColumn == 7) {
                sortStatByAsc = !sortStatByAsc;
              } else {
                sortStatByAsc = true;
              }
              currentSortColumn = 7;
              _stats(7);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                height: 100,
                margin: EdgeInsets.only(right: 16.0),
                padding: EdgeInsets.all(12.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Column(
                    children: [
                      Text(
                        "Risk\nRating",
                        style: _tableHeaderStyle(),
                      ),
                      Text(
                        "Srri",
                        style: _subTableHeaderStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 8,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  child: _infoIcon(
                    "Risk Rating",
                    "This is a synthetic risk return indicator based on the volatility of your portfolio. We use 3 year information to categorize the risk of your portfolio into 7 categories, with 7 being the most volatile and 1 the least volatile",
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  _getSortIcon(7),
                  width: 16,
                  height: 16,
                  color: _getSortColor(7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _infoIcon(String title, String description) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        if (sizingInformation.isMobile) {
          return InkWell(
            onTap: () => bottomAlertBox(
              context: context,
              title: title,
              description: description,
            ),
            child: svgImage(
              'assets/icon/information.svg',
              width: 24,
              height: 24,
            ),
          );
        } else {
          return InkWell(
            onTap: () => bottomAlertBoxLargeAnalyse(
              context: context,
              title: title,
              description: description,
            ),
            child: svgImage(
              'assets/icon/information.svg',
              width: 24,
              height: 24,
            ),
          );
        }
      },
    );
  }

  _statRowWidget(
    String ric,
    String fundType,
    String cagr,
    String stddev,
    String drawdown,
    String rawsharpe,
    String rollretmean,
    String srri,
  ) {
    return TableRow(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12.0),
          width: 200,
          child: Text(
            ric,
            style: _tableTextStyle(),
            softWrap: true,
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            fundType,
            style: _tableTextStyle(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            cagr,
            textAlign: TextAlign.right,
            style: _tableTextStyle(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            stddev,
            textAlign: TextAlign.right,
            style: _tableTextStyle(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            drawdown,
            textAlign: TextAlign.right,
            style: _tableTextStyle(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            rawsharpe,
            textAlign: TextAlign.right,
            style: _tableTextStyle(),
          ),
        ),
        // Container(
        //   padding: EdgeInsets.all(12.0),
        //   child: Text(
        //     rollretmean,
        //     textAlign: TextAlign.right,
        //     style: _tableTextStyle(),
        //   ),
        // ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            srri,
            textAlign: TextAlign.right,
            style: _tableTextStyle(),
          ),
        ),
      ],
    );
  }

  _getSortIcon(int currentCol) {
    if (currentSortColumn == currentCol) {
      if (sortStatByAsc) {
        return "assets/images/asc_sort.png";
      } else {
        return "assets/images/desc_sort.png";
      }
    }
    return "assets/images/sorting.png";
  }

  _getSortColor(int currentCol) {
    if (currentSortColumn == currentCol) {
      return Colors.black;
    }
    return Colors.grey[400];
  }

  _headerStyle() {
    return TextStyle(
      fontSize: ScreenUtil().setSp(18.0),
      fontWeight: FontWeight.w800,
      fontFamily: 'nunito',
      letterSpacing: 1,
      color: Color(0xff000000),
    );
  }

  _subHeaderStyle() {
    return TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 1,
    );
  }

  _tableHeaderStyle() {
    return TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w800,
      fontFamily: 'nunito',
      letterSpacing: 1,
      color: Color(0xff000000),
    );
  }

  _subTableHeaderStyle() {
    return TextStyle(
      fontSize: ScreenUtil().setSp(10.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 1,
    );
  }

  _tableTextStyle() {
    return TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 1,
    );
  }

  _tableCorrTextStyle(value) {
    Color color = null;
    if (double.parse(value) > 0.95) {
      color = Colors.red;
    } else if (double.parse(value) > 0.9) {
      color = Colors.orange;
    } else if (double.parse(value) <= 0.9 && double.parse(value) >= 0.5) {
      color = null;
    } else {
      color = Colors.green;
    }
    return TextStyle(
      fontSize: ScreenUtil().setSp(14.0),
      fontWeight: FontWeight.w400,
      fontFamily: 'nunito',
      letterSpacing: 1,
      color: color,
    );
  }
}
