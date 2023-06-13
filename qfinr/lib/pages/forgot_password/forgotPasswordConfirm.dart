import 'package:flutter/material.dart';
import 'package:qfinr/pages/forgot_password/forgotPasswordConfirm_for_large.dart';
import 'package:qfinr/pages/forgot_password/forgotPasswordConfirm_for_small.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';

final log = getLogger('ForgotPasswordConfirmPage');

class ForgotPasswordConfirmPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordConfirmPageState();
  }
}

class _ForgotPasswordConfirmPageState extends State<ForgotPasswordConfirmPage> {
  bool _loading = false;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.isMobile) {
          return _forSmallSizedScreen();
        } else if (sizingInformation.isTablet) {
          return _forMediumSizedScreen();
        } else {
          return _forLargeScreen();
        }
      },
    );
  }

  Widget _forLargeScreen() {
    return ForgotPasswordConfirmPageLarge();
  }

  Widget _forMediumSizedScreen() {
    return ForgotPasswordConfirmPageLarge();
  }

  Widget _forSmallSizedScreen() {
    return ForgotPasswordConfirmPageSmall();
  }
}
