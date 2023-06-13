import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/utils/log_printer.dart';
import '../../widgets/widget_common.dart';
import 'package:qfinr/widgets/styles.dart';

final log = getLogger('ForgotPasswordConfirmPage');

class ForgotPasswordConfirmPageLarge extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordConfirmPageState();
  }
}

class _ForgotPasswordConfirmPageState
    extends State<ForgotPasswordConfirmPageLarge> {
  bool _loading = false;

  void initState() {
    super.initState();
  }

  Widget _submitButton() {
    return gradientButton(
        context: context,
        caption: "Login",
        onPressFunction: () => Navigator.pushReplacementNamed(context, '/'));
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
    return Scaffold(
        body: _loading
            ? preLoader()
            : Column(
                children: [
                  Expanded(
                      child: Center(
                    child: mainContainer(
                      containerColor: Colors.white,
                      context: context,
                      paddingLeft: getScaledValue(16),
                      paddingRight: getScaledValue(16),
                      child: _buildBody(),
                    ),
                  ))
                ],
              ));
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
            height: getScaledValue(350),
            image: new AssetImage("assets/animation/tickAnimation_white.gif")),
        /* Lottie.asset(
								'assets/animation/tickAnimation.json',
								controller: _controller,
								onLoaded: (composition) {
									//_controller.duration = composition.duration;
									//_controller.repeat();
								},
							), */
        Text(
          'Link sent to\nreset password',
          style: headline1,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: getScaledValue(30),
        ),
        Text(
          'We have sent a mail to your registered email id',
          style: bodyText1,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: getScaledValue(30),
        ),
        _submitButton(),
      ],
    );
  }
}
