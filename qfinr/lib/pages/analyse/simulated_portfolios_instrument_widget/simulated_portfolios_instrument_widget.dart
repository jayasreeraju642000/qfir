import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/pages/analyse/details/common_widgets_analyse_details.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SimulatedPortfoliosInstrumentsWidget extends StatefulWidget {
  final Map minVol;
  final Map maxReturn;
  final Map maxSharpe;
  final String mainHeading1;
  final String mainHeading2;
  final String mainHeading3;
  SimulatedPortfoliosInstrumentsWidget(
      {this.minVol,
      this.maxReturn,
      this.maxSharpe,
      this.mainHeading1,
      this.mainHeading2,
      this.mainHeading3});

  @override
  _SimulatedPortfoliosInstrumentsWidgetState createState() =>
      _SimulatedPortfoliosInstrumentsWidgetState();
}

class _SimulatedPortfoliosInstrumentsWidgetState
    extends State<SimulatedPortfoliosInstrumentsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ResponsiveBuilder(
        builder: (BuildContext context, SizingInformation sizingInformation) {
          if (sizingInformation.isMobile) {
            return Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSimulatedPortfoliosInstrumentListWidgets(
                      widget.mainHeading1),
                  _verticalSpacer(15),
                  _buildSimulatedPortfoliosInstrumentListWidgets(
                      widget.mainHeading2),
                  _verticalSpacer(15),
                  _buildSimulatedPortfoliosInstrumentListWidgets(
                      widget.mainHeading3),
                  _verticalSpacer(15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _disclaimersSimulatedPortfolio(),
                  ),
                  _verticalSpacer(15),
                ],
              ),
            );
          } else if (sizingInformation.isTablet) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _buildSimulatedPortfoliosInstrumentListWidgets(
                            widget.mainHeading1)),
                    _horizontalSpacer(),
                    Expanded(
                        child: _buildSimulatedPortfoliosInstrumentListWidgets(
                            widget.mainHeading2)),
                    _horizontalSpacer(),
                    Expanded(
                        child: _buildSimulatedPortfoliosInstrumentListWidgets(
                            widget.mainHeading3)),
                  ],
                ),
                _disclaimersSimulatedPortfolio()
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _buildSimulatedPortfoliosInstrumentListWidgets(
                            widget.mainHeading1)),
                    _horizontalSpacer(),
                    Expanded(
                        child: _buildSimulatedPortfoliosInstrumentListWidgets(
                            widget.mainHeading2)),
                    _horizontalSpacer(),
                    Expanded(
                        child: _buildSimulatedPortfoliosInstrumentListWidgets(
                            widget.mainHeading3)),
                  ],
                ),
                _disclaimersSimulatedPortfolio()
              ],
            );
          }
        },
      ),
    );
  }

  Widget _disclaimersSimulatedPortfolio() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
          ),
          Text(Contants.Disclaimers_for_Simulated_Portfolio,
              style: headline6_analyse)
        ],
      );

  Widget _horizontalSpacer() => SizedBox(
        width: 15,
      );

  Widget _buildSimulatedPortfoliosInstrumentListWidgets(mainHeading) =>
      ResponsiveBuilder(
        builder: (BuildContext context, SizingInformation sizingInformation) {
          if (sizingInformation.isMobile) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Color(0xFFe9e9e9))),
              child: Column(
                children: [
                  _headingContainer(mainHeading),
                  _subHeadingContainer(),
                  _divider(),
                  _instrumentsList(mainHeading),
                  _verticalSpacer(12),
                ],
              ),
            );
          } else if (sizingInformation.isTablet) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Color(0xFFe9e9e9))),
              height: 300,
              child: Column(
                children: [
                  _headingContainer(mainHeading),
                  _subHeadingContainer(),
                  _divider(),
                  Expanded(child: _instrumentsList(mainHeading)),
                  _verticalSpacer(12),
                ],
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Color(0xFFe9e9e9))),
              height: 300,
              child: Column(
                children: [
                  _headingContainer(mainHeading),
                  _subHeadingContainer(),
                  _divider(),
                  Expanded(child: _instrumentsList(mainHeading)),
                  _verticalSpacer(12),
                ],
              ),
            );
          }
        },
      );

  Widget _verticalSpacer(double height) => SizedBox(
        height: height,
      );

  Widget _instrumentsList(mainHeading) => ResponsiveBuilder(
        builder: (BuildContext context, SizingInformation sizingInformation) {
          if (sizingInformation.isMobile) {
            return _instrumentListItems(mainHeading, sizingInformation);
          } else if (sizingInformation.isTablet) {
            return _instrumentListItems(mainHeading, sizingInformation);
          } else {
            return _instrumentListItems(mainHeading, sizingInformation);
          }
        },
      );

  Widget _instrumentListItems(
      mainHeading, SizingInformation sizingInformation) {
    List<String> list = [];
    if (mainHeading == "Min vol") {
      list = widget.minVol.keys.toList();
    } else if (mainHeading == "Max Return") {
      list = widget.maxReturn.keys.toList();
    } else if (mainHeading == "Max Sharpe") {
      list = widget.maxSharpe.keys.toList();
    }
    return ListView.builder(
      shrinkWrap: sizingInformation.isMobile ? true : false,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var name = list[index];
        var value = "";
        if (mainHeading == "Min vol") {
          value = widget.minVol[list[index]].toString();
        } else if (mainHeading == "Max Return") {
          value = widget.maxReturn[list[index]].toString();
        } else {
          value = widget.maxSharpe[list[index]].toString();
        }
        return Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _instrumentName(name, true)),
              Expanded(child: _instrumentName(value + "%", false)),
            ],
          ),
        );
      },
    );
  }

  Widget _instrumentName(String instrumentName, bool isInstrumentName) => Text(
        instrumentName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: isInstrumentName ? TextAlign.start : TextAlign.end,
        style: TextStyle(
            color: Color(0xFF383838),
            fontSize: 11,
            fontWeight: FontWeight.bold),
      );

  Widget _headingContainer(mainHeading) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            color: Color(0xFFf7f7f7),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _heading(mainHeading),
                  Expanded(child: _addToWishListButton()),
                ],
              ),
            ),
          ))
        ],
      );

  Widget _subHeadingContainer() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _subHeading("Instrument Name", false)),
                  Expanded(child: _subHeading("Portfolio %", true)),
                ],
              ),
            ),
          ))
        ],
      );

  Widget _subHeading(String subHeading, bool isPortfolioPercentage) => Text(
        subHeading,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: isPortfolioPercentage ? TextAlign.end : TextAlign.start,
        style: TextStyle(
            color: Color(0xFF707070),
            fontSize: 11,
            fontWeight: FontWeight.w400),
      );

  Widget _heading(mainHeading) {
    var title = "";
    var description = "";
    title = mainHeading.toString();
    if (mainHeading == "Min vol") {
      description = Contants.MinVol;
    } else if (mainHeading == "Max Return") {
      description = Contants.MaxReturn;
    } else {
      description = Contants.MaxSharpe;
    }

    return Row(
      children: [
        Text(
          mainHeading,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
              color: Color(0xFFa5a5a5),
              fontSize: 13,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        ResponsiveBuilder(
          builder: (BuildContext context, SizingInformation sizingInformation) {
            if (sizingInformation.isMobile) {
              return InkWell(
                onTap: () => bottomAlertBox(
                    context: context, title: title, description: description),
                child: svgImage('assets/icon/information.svg',
                    width: getScaledValue(12)),
              );
            } else {
              return InkWell(
                onTap: () => bottomAlertBoxLargeAnalyse(
                    context: context, title: title, description: description),
                child: svgImage('assets/icon/information.svg',
                    width: getScaledValue(14)),
              );
            }
          },
        )
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Divider(
          color: Color(0xFFdadada),
          thickness: 1,
          height: 1,
        ),
      );

  Widget _addToWishListButton() => Text(
        '+ Add to Watchlist',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.end,
        style: TextStyle(
            color: Color(0xFF034bd9),
            fontSize: 12,
            fontWeight: FontWeight.w600),
      );
}
