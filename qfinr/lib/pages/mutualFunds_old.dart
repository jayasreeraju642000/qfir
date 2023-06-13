import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../widgets/widget_common.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/main_model.dart';

final log = getLogger('MutualFundsPage');

class MutualFundsPage extends StatefulWidget {
  final MainModel model;

  MutualFundsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _MutualFundsPageState();
  }
}

class _MutualFundsPageState extends State<MutualFundsPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          drawer: WidgetDrawer(),
          appBar: mainAppBar(context, model),
          body: _buildBody(context),
          bottomNavigationBar: widgetBottomNavBar(context, 1));
    });
  }

  Widget _buildBody(BuildContext context) {
    return widgetComingSoon();
  }
}
