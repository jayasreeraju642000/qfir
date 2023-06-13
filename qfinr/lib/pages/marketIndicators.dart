import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/main_model.dart';

final log = getLogger('MarketIndicatorsPage');

class MarketIndicatorsPage extends StatefulWidget {
  final MainModel model;

  MarketIndicatorsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _MarketIndicatorsPageState();
  }
}

class _MarketIndicatorsPageState extends State<MarketIndicatorsPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          drawer: WidgetDrawer(),
          appBar: mainAppBar(context, model),
          body: _buildBody(context),
          bottomNavigationBar: widgetBottomNavBar(context, 2));
    });
  }

  Widget _buildBody(BuildContext context) {
    Widget containerChild = Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(15.0),
        child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _textWidget(
                  'We will launch unique market indicators that will help you better manage short term and long term investment allocations, and time your entries and exits into market efficiently.'),
              SizedBox(height: 15.0),
              _textWidget(
                  'Our indicators run time-tested proprietary algorithms on latest market data and information to derive intelligent insights and calibrate future market expectations.'),
            ]));
    return widgetContainerBox(containerChild);
    //return widgetComingSoon(context);
  }

  Widget _textWidget(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey),
    );
  }
}
