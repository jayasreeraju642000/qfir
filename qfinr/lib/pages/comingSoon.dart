import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../widgets/widget_common.dart';
import '../widgets/styles.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/main_model.dart';

final log = getLogger('ComingSoonPage');

class ComingSoonPage extends StatefulWidget {
  final MainModel model;

  ComingSoonPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ComingSoonPageState();
  }
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    changeStatusBarColor(Colors.white);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        // appBar: commonAppBar(bgColor: Colors.white),
        body: mainContainer(
          context: context,
          paddingBottom: 0,
          containerColor: Colors.white,
          child: _buildBody(),
        ),
        bottomNavigationBar: widgetBottomNavBar(context, 3),
      );
    });
  }

  Widget _buildBody() {
    return Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            svgImage("assets/icon/qfinr.svg", height: getScaledValue(98)),
            SizedBox(height: getScaledValue(18)),
            Text('Coming Soon',
                style: headline1.copyWith(color: Color(0xfff5cb01))),
          ],
        ));
  }
}
