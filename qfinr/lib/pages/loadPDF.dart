import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/main_model.dart';

final log = getLogger('LoadPDF');

class LoadPDF extends StatefulWidget {
  final MainModel model;

  LoadPDF(this.model);

  @override
  State<StatefulWidget> createState() {
    return _loadPDFState();
  }
}

class _loadPDFState extends State<LoadPDF> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return _buildBody(context);
    });
  }

  Widget _buildBody(BuildContext context) {
    return RaisedButton(
      onPressed: () async {},
      child: Text('download + load as file (cached)'),
    );
  }
}
