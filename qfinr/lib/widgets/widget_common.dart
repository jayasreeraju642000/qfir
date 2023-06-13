import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/widgets/canvasKitWeb.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// models
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'package:url_launcher/url_launcher.dart';

import '../all_translations.dart';
import '../fonts/my_flutter_app_icons.dart';
import '../models/main_model.dart';
import 'box_shadows.dart';
import 'gradients.dart';
import 'navigation_bar.dart';
import 'styles.dart';

final log = getLogger('widget_common');

int _themeColor = 0xFF535971;

class DashSeparator extends StatelessWidget {
  final double height;
  final Color color;

  const DashSeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

class WidgetDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WidgetDrawerState();
  }
}

class _WidgetDrawerState extends State<WidgetDrawer> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Qfinr',
    packageName: 'Unknown',
    version: '1.0.0',
    buildNumber: 'Unknown',
  );

  var invite_available_count;

  void getSharepref_available() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      invite_available_count = prefs.getInt('invite_available_count');
      //envelope_ic = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharepref_available();

    if (!kIsWeb) {
      _initPackageInfo();
    }
  }

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<Null> _analyticsSignOutEvent() async {
    // log.d("\n _analyticsSignOutEvent called \n");
    await FirebaseAnalytics().logEvent(name: 'select_content', parameters: {
      'item_id': "universal",
      'item_name': "universal_signout",
      'content_type': "signout_button",
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      var deviceType = getDeviceType(MediaQuery.of(context).size);
      if (deviceType == DeviceScreenType.tablet) {
        return _drawerForTablet(context, child, model);
      } else {
        return _drawerForMobile(context, child, model);
      }
    });
  }

  _drawerForTablet(BuildContext context, Widget child, MainModel model) {
    return NavigationLeftBar(
      isSideMenuHeadingSelected: 0,
      isSideMenuSelected: 0,
    );
  }

  _drawerForMobile(BuildContext context, Widget child, MainModel model) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 160.0,
                    //padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: DrawerHeader(
                        margin: EdgeInsets.all(0.0),
                        child: Row(
                          children: <Widget>[
                            (!model.isUserAuthenticated ||
                                    (model.isUserAuthenticated &&
                                        model.userData.displayImage ==
                                            'noImage')
                                ? Container(
                                    width: 60.0,
                                    height: 60.0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      minRadius: 40.0,
                                      child: Text(model.isUserAuthenticated
                                          ? model.userData.custFirstName
                                                  .substring(0, 1)
                                                  .toUpperCase() +
                                              model.userData.custLastName
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                          : "G"),
                                    ),
                                  )
                                : Container(
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(model
                                                .userData.displayImage))))),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                model.isUserAuthenticated
                                    ? model.userData.custName
                                    : "Guest",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        )),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff0445e4), Color(0xff0033cc)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.share,
                      color: Color(_themeColor),
                      size: 22.0,
                    ),
                    title: TextThemeColor("Share"),
                    onTap: () {
                      Share.share(
                        'check out this amazing app https://www.qfinr.com/join',
                        subject: 'Look what I found!',
                      );
                    },
                  ),
                  /*
							Divider(
								color: Color(_themeColor),
								height: 1.0,
							), */

                  /* ListTile(
								leading: new Icon(
								Icons.text_format,
								color: Color(_themeColor),
								size: 22.0,
								),
								title: TextThemeColor(languageText('text_change_language') ),
								onTap: () {
								Navigator.pushNamed(context, '/languageSelector');
								},
							) ,
							 */
                  /* model.isUserAuthenticated ?
								ListTile(
									leading: new Icon(
									Icons.settings,
									color: Color(_themeColor),
									size: 22.0,
									),
									title: TextThemeColor(languageText('text_settings') ),
									onTap: () {
									Navigator.pushNamed(context, '/settings');
									},
								):
								emptyWidget ,

							ListTile(
								leading: SizedBox(
									height: 22,
									width: 22,
									child: Image.asset("assets/flag/"+ model.userSettings['default_zone'] +".png"),
								),
								title: TextThemeColor('Zone' ),
								onTap: () {
									Navigator.pushNamed(context, '/zoneSelector');
								},
							), */

                  /* IconButton(
								icon: Image.asset("assets/flag/"+ model.userSettings['default_zone'] +".png"),
								iconSize: 48.0, //, color: Color(0xFF0F52BA),),
								onPressed: () {
									Navigator.pushNamed(context, '/zoneSelector');
								},
							), */

                  ListTile(
                    leading: Image.asset(
                      invite_available_count != 0
                          ? "assets/images/envelope_notify_ic.png"
                          : "assets/images/envelope.png",
                      fit: BoxFit.contain,
                      height: 22,
                      width: 22,
                    ),
                    title: TextThemeColor("Invite friends"),
                    onTap: () {
                      Navigator.pushNamed(context, '/inviteFriends')
                          .then((_) => changeStatusBarColor(Color(0xff0445e4)));
                    },
                  ),
                  model.isUserAuthenticated
                      ? ListTile(
                          leading: Icon(
                            Icons.exit_to_app,
                            color: Color(_themeColor),
                            size: 22.0,
                          ),
                          title: TextThemeColor(languageText('text_signout_l')),
                          onTap: () {
                            _analyticsSignOutEvent();
                            model.logout();
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/login');
                            changeStatusBarColor(Colors.white);
                          },
                        )
                      : ListTile(
                          leading: new Icon(
                            Icons.lock_outline,
                            color: Color(_themeColor),
                            size: 22.0,
                          ),
                          title: TextThemeColor(languageText('text_signin_l') +
                              ' / ' +
                              languageText('text_signup_l')),
                          onTap: () {
                            _analyticsSignOutEvent();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),

                  /* model.isUserAuthenticated ?
								ListTile(
								leading: new Icon(
									Icons.account_box,
									color: Color(_themeColor),
									size: 22.0,
								),
								title: TextThemeColor('My Account'),
								onTap: () {
									Navigator.pushReplacementNamed(context, '/home');
								},
								)
								: Container(), */
                ],
              ),
            ),
          ),
          Expanded(
              flex: 0,
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                padding: EdgeInsets.all(20.0),
                alignment: FractionalOffset.bottomCenter,
                //color: Colors.white,
                child: widgetAppDetails(context),
              )),
        ],
      ),
    );
  }

  Widget widgetAppDetails(BuildContext context) {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.end,
      direction: Axis.vertical,
      children: <Widget>[
        //Image.asset('assets/images/logo_white.png', fit: BoxFit.fill, height: 20.0,),
        //widgetAppDetailItem('Multiiplyy'), ///_packageInfo.appName),
        //widgetAppDetailItem(' (Elitio Technologies Private Limited) '),
        //widgetAppDetailItem(' SEBI Registered Investment Advisor (#INA100006588)'),
        !kIsWeb
            ? widgetAppDetailItem('App Version: ' + _packageInfo.version)
            : widgetAppDetailItem('App Version: ' + "0.0.0"),
      ],
    );
  }

  Widget widgetAppDetailItem(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white30, fontSize: 12.0),
      textAlign: TextAlign.center,
    );
  }
}

class TextThemeColor extends StatelessWidget {
  final String _displayText;

  TextThemeColor(this._displayText);

  @override
  Widget build(BuildContext context) {
    return Text(this._displayText,
        style: TextStyle(
            color: Color(0xFF535971),
            fontSize: 14.0,
            fontWeight: FontWeight.normal));
  }
}

changeStatusBarColor(Color color) {
  if (!kIsWeb) {
    FlutterStatusbarcolor.setStatusBarColor(color);
  }
}

Widget widgetCustomDivider() {
  return new SizedBox(
    height: 10.0,
    child: new Center(
      child: new Container(
        margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 5.0,
        color: Colors.black,
      ),
    ),
  );
}

Widget vDivider(BuildContext context) {
  return RotatedBox(
    quarterTurns: 1,
    child: Divider(),
  );
}

Widget widgetButtonText(String text,
    {bool useContext = false,
    BuildContext context,
    bool miniButton = false,
    bool textNormal = false}) {
  return Text(
    textNormal ? text : text.toUpperCase(),
    style: buttonStyle.copyWith(
      fontSize: (miniButton ? 11 : null),
    ),
  );
}

Widget widgetButtonTextSmall(String text) {
  return Text(
    text.toUpperCase(),
    style: TextStyle(
        color: Colors.white,
        fontSize: 11.0,
        letterSpacing: 2.0,
        fontWeight: FontWeight.normal),
  );
}

Widget widgetButtonTextLarge(String text,
    {bool useContext = false, BuildContext context, bool miniButton = false}) {
  return Text(text.toUpperCase(),
      style: TextStyle(
          fontSize: ScreenUtil().setSp(11.0),
          fontWeight: FontWeight.w800,
          fontFamily: 'nunito',
          letterSpacing: 0.2,
          color: Colors.white));
}

Widget widgetGreyText(String text) {
  return Text(
    text,
    style: TextStyle(color: Colors.grey, fontSize: 12.0),
    textAlign: TextAlign.center,
  );
}

Widget widgetParaText(String text) {
  return Text(
    text,
    style: TextStyle(color: Colors.grey, fontSize: 12.0, height: 1.1),
    textAlign: TextAlign.left,
  );
}

Widget widgetHeading(BuildContext context, String text) {
  return Text(
    text,
    style: Theme.of(context)
        .textTheme
        .subtitle1
        .copyWith(color: Theme.of(context).primaryColor),
    textAlign: TextAlign.center,
  );
}

Widget widgetFlatButton(String text, TextAlign align) {
  return Text(
    text,
    style: linkText1,
    textAlign: align,
  );
}

Future<bool> showAlertDialogBox(BuildContext context, String title, String text,
    {bool confirmButton = false, Function continueFunction}) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: title != "" ? Text(title) : emptyWidget,
        content: Column(
          children: [
            Text(text),
            SizedBox(height: 20),
            !confirmButton
                ? Container(
                    width: 166,
                    child: gradientButton(
                        context: context,
                        caption: 'Close',
                        onPressFunction: () => Navigator.pop(context),
                        miniButton: true,
                        textNormal: true),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: textButton('Cancel',
                            borderColor: colorBlue,
                            textColor: colorBlue,
                            onPressFunction: () => Navigator.of(context).pop()),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          width: 166,
                          child: gradientButton(
                            context: context,
                            caption: 'Continue',
                            onPressFunction: () {
                              // return true;
                            },
                            miniButton: true,
                            textNormal: true,
                          ),
                        ),
                      ),
                    ],
                  )
          ],
        ),
        // actions: !confirmButton
        //     ? [
        //         CupertinoDialogAction(
        //             isDefaultAction: true,
        //             /* isDestructiveAction: true, */
        //             onPressed: () {
        //               Navigator.pop(context);
        //             },
        //             child: new Text("Close"))
        //       ]
        //     : [
        //         CupertinoDialogAction(
        //             //isDefaultAction: true,
        //             /* isDestructiveAction: true, */
        //             onPressed: () {
        //               return true;
        //             },
        //             child: new Text("Continue")),
        //         CupertinoDialogAction(
        //             isDefaultAction: true,
        //             /* isDestructiveAction: true, */
        //             onPressed: () {
        //               Navigator.pop(context);
        //             },
        //             child: new Text("Cancel"))
        //       ],
      );
    },
  );
}

Widget textButton(title,
    {Function onPressFunction,
    Color borderColor = Colors.white,
    Color textColor = Colors.black,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w800,
    Alignment alignment = Alignment.center,
    double width = 166,
    double height = 40}) {
  return TextButton(
    onPressed: onPressFunction,
    child: Container(
      alignment: alignment,
      padding: EdgeInsets.all(0),
      width: width,
      height: height,
      decoration: BoxDecoration(
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
        textAlign: TextAlign.center,
      ),
    ),
  );
}

// ignore: todo
// TODO : gradientButton_large large screen : shariyath
Widget gradientButtonLarge(
    {BuildContext context,
    String caption,
    Function onPressFunction,
    bool buttonDisabled = false,
    bool miniButton = false}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.15,
      child: ElevatedButton(
        style: qfButtonStyle(ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
        // style: ElevatedButton.styleFrom(
        //   //padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        //   padding: EdgeInsets.all(0.0),
        //   textStyle: TextStyle(color: Colors.white),
        // ),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: miniButton ? 40 : 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: buttonDisabled || onPressFunction == null
                    ? [Colors.grey, Colors.grey[400]]
                    : [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: ScreenUtil().setHeight(miniButton ? 40 : 50)),
            alignment: Alignment.center,
            child: widgetButtonTextLarge(caption,
                useContext: true, context: context, miniButton: miniButton),
          ),
        ),
        onPressed: onPressFunction,
      ));
}

Widget widgetContainerBox(Widget child) {
  return Container(
    //color: Colors.white,
    decoration: BoxDecoration(color: Colors.white, boxShadow: [
      new BoxShadow(
        color: Colors.grey,
        //blurRadius: 4.0,
        //spreadRadius: 10.0,
      ),
    ]),
    margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 40.0),
    padding: EdgeInsets.only(top: 10.0),
    child: child,
  );
}

Widget widgetContainerBoxNoBottomPadding(Widget child) {
  return Container(
    //color: Colors.white,
    decoration: BoxDecoration(color: Colors.white, boxShadow: [
      new BoxShadow(
        color: Colors.grey,
      ),
    ]),
    margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
    padding: EdgeInsets.only(top: 10.0, left: 10.0),
    child: child,
  );
}

Widget widgetContainerBoxNoPadding(Widget child) {
  return Container(
    //color: Colors.white,
    decoration: BoxDecoration(color: Colors.white, boxShadow: [
      new BoxShadow(
        color: Colors.grey,
      ),
    ]),
    margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
    padding: EdgeInsets.all(0.0),
    child: child,
  );
}

Widget widgetLoginAlert(BuildContext context) {
  return Flex(
    direction: Axis.vertical,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        alignment: Alignment.centerRight,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      Container(
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/icon_login.png',
          height: 90.0,
        ),
      ),
      SizedBox(
        height: 10.0,
      ),
      Container(
        alignment: Alignment.center,
        child: Text(
          'Sign In / Sign Up',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 18.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20.0),
        child: Text(
          'To access this, please Sign In or Sign Up',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.left,
        ),
      ),
      Divider(),
      Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: RaisedButton(
              padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
              textColor: Colors.white,
              child: widgetButtonText('Login'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          )),
          Expanded(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: RaisedButton(
              padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
              textColor: Colors.white,
              child: widgetButtonText('Register'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
            ),
          ))
        ],
      )
    ],
  );
}

void showLoginAlert(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return widgetLoginAlert(context);
      });
}

Widget widgetBasketCategoryItem(BuildContext context, String category) {
  Color bgColor = Theme.of(context).primaryColor;

  if (category == languageText('text_largecap') ||
      category == languageText('text_debt') ||
      category == languageText("text_planner")) {
    bgColor = Colors.green[300];
  } else if (category == languageText('text_multicap') ||
      category == languageText('text_equity')) {
    bgColor = Colors.blue[300];
  } else if (category == languageText('text_fundamental')) {
    bgColor = Colors.greenAccent[700];
  } else if (category == languageText('text_model_based')) {
    bgColor = Colors.orangeAccent[700];
  } else if (category == languageText('text_sectoral')) {
    bgColor = Colors.purpleAccent[700];
  } else if (category == languageText('text_monthly')) {
    bgColor = Colors.tealAccent[700];
  } else if (category == languageText('text_quarterly')) {
    bgColor = Colors.amberAccent[700];
  } else if (category == languageText('text_daily')) {
    bgColor = Colors.cyanAccent[700];
  } else if (category == languageText('text_weekly')) {
    bgColor = Colors.lightGreenAccent[700];
  }

// Fundamental

  return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      margin: EdgeInsets.only(bottom: 5.0, right: 5.0),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.all(Radius.circular(2.0))),
      child: Text(category,
          style: TextStyle(color: Colors.white, fontSize: 10.0)));
}

Widget widgetCacheImage(BuildContext context, String imagePath, double height) {
  return Image(
    image: (kIsWeb)
        ? NetworkImage(imagePath)
        : CachedNetworkImageProvider(imagePath),
    height: height,
  );

  //return Image.network(imagePath, height: height,);
}

String firstUpper(String input) {
  if (input == null) {
    throw new ArgumentError("string: $input");
  }
  if (input.length == 0) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

Widget widgetComingSoon() {
  Widget child = Container(
    padding: EdgeInsets.all(10.0),
    alignment: Alignment.center,
    child: Text(
      'Coming\nSoon',
      style: headline2,
      textAlign: TextAlign.center,
    ),
  );
  return widgetContainerBox(child);
}

void homeBottomNavBar(BuildContext context, int index) {
  if (index == 0) {
    Navigator.pushReplacementNamed(context, '/home_new');
  } else if (index == 1) {
    Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');
  } else if (index == 2) {
    Navigator.pushReplacementNamed(context, '/portfolioAnalyzer');
    //Navigator.pushNamed(context, '/portfolioDividend');
    //Navigator.pushNamed(context, '/goalPlanner/retirement');
  } else if (index == 3) {
    Navigator.pushReplacementNamed(context, '/comingSoon');
  } else if (index == 4) {
    Navigator.pushNamed(context, '/discover');
  }
}

Widget widgetBottomNavBar(BuildContext context, int index) {
  return Container(
    margin: EdgeInsets.all(0),
    padding: EdgeInsets.all(0),
    decoration: BoxDecoration(
      color: Colors.white,
    ),
    child: BottomNavigationBar(
      //backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      onTap: (newIndex) {
        homeBottomNavBar(context, newIndex);
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      elevation: 0,
      currentIndex: index,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          activeIcon: _buildIcon(
            context: context,
            imgPath: "home",
            title: "home",
            index: 0,
            activeIndex: index,
          ),
          icon: _buildIcon(
            context: context,
            imgPath: "home",
            title: "home",
            index: 0,
            activeIndex: index,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          activeIcon: _buildIcon(
            context: context,
            imgPath: "manage",
            title: "manage",
            index: 1,
            activeIndex: index,
          ),
          icon: _buildIcon(
            context: context,
            imgPath: "manage",
            title: "manage",
            index: 1,
            activeIndex: index,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(
            context: context,
            imgPath: "analysis",
            title: "analyse",
            index: 2,
            activeIndex: index,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(
            context: context,
            imgPath: "plan",
            title: "plan",
            index: 3,
            activeIndex: index,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(
            context: context,
            imgPath: "discover",
            title: "discover",
            index: 4,
            activeIndex: index,
          ),
          label: "",
        ),
      ],
    ),
  );
}

Widget _buildIcon(
    {BuildContext context,
    String imgPath,
    String title,
    int index,
    int activeIndex}) {
  return Container(
    padding: EdgeInsets.all(0),
    margin: EdgeInsets.all(0),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0x80e8e8e8),
          blurRadius: 4.0, // soften the shadow
          spreadRadius: 0.5, //extend the shadow
          offset: Offset(
            7, // Move to right 10  horizontally
            -1, // Move to bottom 10 Vertically
          ),
        )
      ],
    ),
    width: double.infinity,
    height: MediaQuery.of(context).size.shortestSide > 600
        ? 100
        : kBottomNavigationBarHeight,
    child: Material(
      color: index == activeIndex ? Color(0xffecf1fa) : Colors.white,
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            svgImage(
              "assets/icon/icon_bottom_" +
                  imgPath +
                  (index == activeIndex ? "_active" : "") +
                  ".svg",
              height: getScaledValue(
                MediaQuery.of(context).size.shortestSide > 600 ? 5 : 16,
              ),
            ),
            SizedBox(height: getScaledValue(4)),
            Text(title,
                style:
                    index == activeIndex ? bottomBarTextActive : bottomBarText),
          ],
        ),
        onTap: () => homeBottomNavBar(context, index),
      ),
    ),
  );
}

PreferredSizeWidget mainAppBar(BuildContext context, MainModel model,
    {bool homeScreen = false}) {
  //log.d(model.userSettings);
  return AppBar(
      titleSpacing: 5.0,
      backgroundColor: Theme.of(context).primaryColor,
      //,Colors.white, //Color(0xFFE7EDF8), //
      iconTheme: IconThemeData(color: Colors.white),
      //Theme.of(context).primaryColor),
      actions: <Widget>[
        /* IconButton(
				icon: Image.asset("assets/flag/"+ model.userSettings['default_zone'] +".png"),
				iconSize: 48.0, //, color: Color(0xFF0F52BA),),
				onPressed: () {
					Navigator.pushNamed(context, '/zoneSelector');
				},
			), */
        /* IconButton(
				icon: Icon(Icons.business_center), //, color: Color(0xFF0F52BA),),
				onPressed: () {
				model.isUserAuthenticated ? Navigator.pushNamed(context, '/shortlistedBaskets') : showLoginAlert(context);
				},
			), */
        /* IconButton(
				icon: Icon(Icons.notifications),//, color: Color(0xFF0F52BA),),
				onPressed: () {
				Navigator.pushNamed(context, '/comingSoon');
				},
			), */
      ],
      title: Image.asset(
        'assets/images/logo_white.png',
        fit: BoxFit.fill,
        height: 25.0,
      ));
}

PreferredSizeWidget newsAppBar(BuildContext context, MainModel model) {
  return AppBar(
    titleSpacing: 20.0,
    backgroundColor: Theme.of(context).primaryColor,
    //,Colors.white, //Color(0xFFE7EDF8), //
    iconTheme: IconThemeData(color: Colors.white),
    //Theme.of(context).primaryColor),
    actions: <Widget>[
      IconButton(
        icon: Image.asset(
            "assets/flag/" + model.userSettings['default_zone'] + ".png"),
        iconSize: 64.0, //, color: Color(0xFF0F52BA),),
        onPressed: () {
          Navigator.pushNamed(context, '/zoneSelector');
        },
      ),
      IconButton(
        icon: Icon(Icons.business_center), //, color: Color(0xFF0F52BA),),
        onPressed: () {
          model.isUserAuthenticated
              ? Navigator.pushNamed(context, '/shortlistedBaskets')
              : showLoginAlert(context);
        },
      ),
      /* IconButton(
				icon: Icon(Icons.notifications),//, color: Color(0xFF0F52BA),),
				onPressed: () {
				Navigator.pushNamed(context, '/comingSoon');
				},
			), */
    ],

    title: Image.asset(
      'assets/images/logo_white.png',
      fit: BoxFit.fill,
      height: 25.0,
    ),
    bottom: TabBar(
      labelStyle: TextStyle(fontSize: 10.0),
      isScrollable: true,
      indicatorColor: Colors.white,
      tabs: [
        _tabGenerator(MyFlutterApp.newspaper, 'News'),
        _tabGenerator(MyFlutterApp.twitter, 'Twitter'),
      ],
    ),
  );
}

PreferredSizeWidget commonAppBar(
    {Color bgColor = appBarBGColor,
    Color iconColor,
    Brightness brightness,
    String title = "",
    List<Widget> actions,
    PreferredSizeWidget bottom,
    Widget leading,
    bool automaticallyImplyLeading = true}) {
  return AppBar(
    elevation: 0,
    titleSpacing: 5.0,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    backgroundColor: bgColor,
    iconTheme: IconThemeData(
        color: iconColor != null
            ? iconColor
            : bgColor == Colors.white || bgColor == Color(0xffefd82b)
                ? Colors.black
                : Colors.white),
    brightness: brightness != null
        ? brightness
        : (bgColor == Colors.white ? Brightness.light : Brightness.dark),
    actions: actions,
    bottom: bottom,
    title: Text(
      title,
      style: TextStyle(
          color: bgColor == Colors.white || bgColor == Color(0xffefd82b)
              ? Colors.black
              : Colors.white),
    ),
  );
}

PreferredSizeWidget commonScrollAppBar(
    {ScrollController controller,
    Color iconColor,
    Color bgColor = appBarBGColor,
    Brightness brightness,
    String title = "",
    List<Widget> actions,
    PreferredSizeWidget bottom,
    Widget leading}) {
  return ScrollAppBar(
    controller: controller,
    elevation: 0,
    titleSpacing: 5.0,
    leading: leading,
    backgroundColor: bgColor,
    iconTheme: IconThemeData(
        color: iconColor != null
            ? iconColor
            : bgColor == Colors.white ||
                    bgColor == Color(0xffefd82b) ||
                    bgColor == Color(0xfffcdf01)
                ? Colors.black
                : Colors.white),
    brightness: brightness != null
        ? brightness
        : (bgColor == Colors.white ? Brightness.light : Brightness.dark),
    actions: actions,
    bottom: bottom,
    title: Text(
      title,
      style: TextStyle(
          color: bgColor == Colors.white ||
                  bgColor == Color(0xffefd82b) ||
                  bgColor == Color(0xfffcdf01)
              ? Colors.black
              : Colors.white),
    ),
  );
}

Tab _tabGenerator(iconData, String title) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(iconData, size: 20.0),
        SizedBox(
          width: 10.0,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    ),
  );
}

String languageText(String key) {
  return allTranslations.text(key);
}

Future<String> getLanguage() async {
  String selectedLanguage = await allTranslations.getPreferredLanguage();
  return selectedLanguage;
}

final Widget emptyWidget = new Container(width: 0.0, height: 0.0);

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

String getListValue(List<Map<String, dynamic>> fieldLists, String key,
    {String matchKey = "key", String returnKey = "value"}) {
  String returnValue = "";
  fieldLists.forEach((Map fieldList) {
    if (fieldList[matchKey] == key) {
      returnValue = fieldList[returnKey];
    }
  });
  return returnValue;
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

Widget preLoader({width = 80.0, title = "Fetching your details...."}) {
  return Container(
      padding: EdgeInsets.all(getScaledValue(16)),
      color: Colors.white,
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.vertical,
        children: <Widget>[
          Center(
              child: Image.asset(
            "assets/theme_preloader.gif",
            width: width,
          )),
          title != ""
              ? Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                        decoration: TextDecoration.none),
                  ),
                )
              : emptyWidget
        ],
      ));
}

Widget mainContainer(
    {Widget child,
    BuildContext context,
    double paddingBottom: 20.0,
    double paddingTop: 0.0,
    double paddingLeft: 0.0,
    double paddingRight: 0.0,
    double marginBottom: 0.0,
    double marginTop: 0.0,
    double marginLeft: 0.0,
    double marginRight: 0.0,
    Color containerColor}) {
  return Container(
      color: containerColor != null
          ? containerColor
          : Theme.of(context).backgroundColor,
      padding: EdgeInsets.only(
          bottom: paddingBottom,
          top: paddingTop,
          right: paddingRight,
          left: paddingLeft),
      margin: EdgeInsets.only(
          bottom: marginBottom,
          top: marginTop,
          right: marginRight,
          left: marginLeft),
      /* margin: EdgeInsets.only(left: includeMargin ? 6.0 : 0, right: includeMargin ? 6.0 : 0, bottom: includeMargin ? 6.0 : 0), */
      alignment: Alignment.topCenter,
      child: Container(
          width: screenSize(context: context, type: "width"), child: child));
}

double screenSize({String type = "width", BuildContext context}) {
  if (type == "width") {
    if (kIsWeb) {
      return 768.0;
    } else {
      return MediaQuery.of(context).size.width;
    }
  } else if (type == "height") {
    return MediaQuery.of(context).size.height;
  } else {
    return 0.0;
  }
}

Widget requireLogin(BuildContext context) {
  return Container(
    //margin: EdgeInsets.only(top: 50.0),
    child: Flex(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      direction: Axis.vertical,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Sign In / Sign Up to  \n add your portfolio',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(),
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8.0)),
                textColor: Colors.white,
                child: widgetButtonText(languageText('text_signin_l')),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            )),
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8.0)),
                textColor: Colors.white,
                child: widgetButtonText(languageText('text_signup_l')),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ))
          ],
        )
      ],
    ),
  );
}

Widget containerCard(
    {BuildContext context,
    Widget child,
    double paddingLeft = 10,
    double paddingTop = 10,
    double paddingRight = 10,
    double paddingBottom = 10}) {
  return Container(
      padding: EdgeInsets.only(
          left: paddingLeft,
          top: paddingTop,
          right: paddingRight,
          bottom: paddingBottom),
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200],
            blurRadius: 5.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              0.5, // Move to right 10  horizontally
              0.5, // Move to bottom 10 Vertically
            ),
          )
        ],
        color: Colors.white, // Theme.of(context).primaryColor,// Colors.purple,
        border: Border(
            //bottom: BorderSide(color: Colors.grey, width: 1)
            ),
        borderRadius: BorderRadius.all(Radius.circular(getScaledValue(4))),
      ),
      child: child);
}

Widget widgetBubble(
    {Color bgColor,
    Color textColor,
    double fontSize = 9,
    String title,
    Widget icon,
    double horizontalPadding = 8.0,
    double verticalPadding = 5.0,
    double leftMargin,
    bool includeBorder = true,
    Color borderColor,
    double rightMargin}) {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
          horizontal: getScaledValue(horizontalPadding),
          vertical: getScaledValue(verticalPadding)),
      margin: EdgeInsets.only(
          left: leftMargin != null ? leftMargin : 5.0,
          right: rightMargin != null ? leftMargin : 2.0),
      decoration: BoxDecoration(
        color: (bgColor != null ? bgColor : Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        border: includeBorder
            ? Border.all(
                color: borderColor != null ? borderColor : Color(0xffc2c2c2),
                width: 1.0,
              )
            : null,
      ),
      child: Row(
        children: [
          icon != null ? icon : emptyWidget,
          icon != null ? SizedBox(width: getScaledValue(10)) : emptyWidget,
          Text(title,
              textAlign: TextAlign.center,
              style: textColor != null
                  ? widgetBubbleTextStyle.copyWith(
                      color: textColor,
                      fontSize: fontSize,
                    )
                  : widgetBubbleTextStyle.copyWith(fontSize: fontSize)),
        ],
      ));
}

Widget widgetCard(
    {Widget child,
    Color bgColor = Colors.white,
    double topMargin = 7.5,
    double rightMargin = 15,
    double bottomMargin = 7.5,
    double leftMargin = 15,
    bool boxShadow = true}) {
  return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.only(
        top: getScaledValue(topMargin),
        right: getScaledValue(rightMargin),
        bottom: getScaledValue(bottomMargin),
        left: getScaledValue(leftMargin),
      ),
      decoration: BoxDecoration(
        boxShadow: boxShadow
            ? [
                BoxShadow(
                  color: Colors.grey[200],
                  blurRadius: 11.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: Offset(
                    0.5, // Move to right 10  horizontally
                    0, // Move to bottom 10 Vertically
                  ),
                )
              ]
            : null,
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(
          color: Color(0xffe9e9e9),
          width: 1.0,
        ),
      ),
      child: child);
}

Widget widgetZoneFlag(String zone) {
  return Image.asset(
    "assets/flag/" + zone.toLowerCase() + ".png",
    width: getScaledValue(16),
    height: getScaledValue(10),
  );
}

Widget gradientButton(
    {BuildContext context,
    String caption,
    Function onPressFunction,
    bool buttonDisabled = false,
    bool miniButton = false,
    bool textNormal = false}) {
  return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        //padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: miniButton ? 40 : 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: buttonDisabled || onPressFunction == null
                    ? [Colors.grey, Colors.grey[400]]
                    : [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: ScreenUtil().setHeight(miniButton ? 40 : 50)),
            alignment: Alignment.center,
            child: widgetButtonText(caption,
                useContext: true,
                context: context,
                miniButton: miniButton,
                textNormal: textNormal),
          ),
        ),
        textColor: Colors.white,
        onPressed: onPressFunction,
      ));
}

Widget gradientButtonWrap(
    {BuildContext context,
    EdgeInsetsGeometry padding,
    String caption,
    Function onPressFunction,
    bool buttonDisabled = false,
    bool miniButton = false}) {
  return Container(
      padding: padding,
      child: ElevatedButton(
        style: qfButtonStyle(ph: 0.0, pv: 0.0, br: 5.0, tc: Colors.white),
        // style: ElevatedButton.styleFrom(
        //   //padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        //   padding: EdgeInsets.all(0.0),
        //   textStyle: TextStyle(color: Colors.white),
        // ),
        child: Ink(
          height: miniButton ? 40 : 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: buttonDisabled || onPressFunction == null
                    ? [Colors.grey, Colors.grey[400]]
                    : [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: ScreenUtil().setHeight(miniButton ? 40 : 50)),
            alignment: Alignment.center,
            child: widgetButtonText(caption,
                useContext: true, context: context, miniButton: miniButton),
          ),
        ),
        onPressed: onPressFunction,
      ));
}

Widget flatButtonText(title,
    {Function onPressFunction,
    Color bgColor: Colors.white,
    Color borderColor = Colors.white,
    Color textColor = Colors.black,
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w800,
    Alignment alignment = Alignment.center}) {
  return Container(
    alignment: alignment,
    padding: EdgeInsets.all(getScaledValue(0)),
    width: getScaledValue(120),
    decoration: new BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1.0, color: borderColor),
        borderRadius: BorderRadius.circular(getScaledValue(5))),
    child: FlatButton(
      splashColor: bgColor,
      highlightColor: bgColor,
      onPressed: onPressFunction,
      child: Text(title,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(fontSize),
              fontWeight: fontWeight,
              fontFamily: 'nunito',
              letterSpacing: 0,
              color: textColor)),
    ),
  );
}

Widget buildSelectBox(
    {BuildContext context,
    String value,
    List<Map<String, String>> options,
    Function onChangeFunction,
    String modelType = "bottomSheet"}) {
  /* List<Map<String, String>> days = [
		{ 'value': 'mon', 'title': 'Monday' },
		{ 'value': 'tue', 'title': 'Tuesday' },
	]; */

  return SmartSelect<String>.single(
      title: 'test',
      value: value,
      //options: options,
      modalType: (modelType == "bottomSheet"
          ? S2ModalType.bottomSheet
          : (modelType == "fullPage"
              ? S2ModalType.fullPage
              : S2ModalType.popupDialog)),
      choiceItems: S2Choice.listFrom<String, Map<String, String>>(
        source: options,
        value: (index, item) => item['value'],
        title: (index, item) => item['title'],
      ),
      onChange: (val) => onChangeFunction(val));
}

Widget customTabs({List tabs, int activeIndex, Function onTap}) {
  List<Widget> childTabs = [];

  for (int i = 0; i < tabs.length; i++) {
    childTabs.add(
      Expanded(
          child: GestureDetector(
              onTap: () {
                onTap(i);
              },
              child: Container(
                padding: EdgeInsets.only(
                    left: getScaledValue(15),
                    right: getScaledValue(15),
                    bottom: getScaledValue(7)),
                decoration: BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                    color: (i == activeIndex ? colorBlue : Color(0xffdedede)),
                    width: 1.0,
                  ),
                )),
                child: Text(tabs[i],
                    style: i == activeIndex
                        ? innerTabHeadingActive
                        : innerTabHeading,
                    textAlign: TextAlign.center),
              ))),
    );
  }

  return Row(
    //shrinkWrap: true,
    //scrollDirection: Axis.horizontal,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: childTabs,
  );
}

buildSelectBoxCustom(
    {BuildContext context,
    String title,
    String value,
    List<Map<String, String>> options,
    Function onChangeFunction,
    String modelType = "bottomSheet"}) {
  /* List<Map<String, String>> days = [
		{ 'value': 'mon', 'title': 'Monday' },
		{ 'value': 'tue', 'title': 'Tuesday' },
	]; */

  List<Widget> _childrenOption = [];

  options.forEach((option) {
    _childrenOption.add(GestureDetector(
      onTap: () {
        onChangeFunction(option['value']);
        Navigator.pop(context);
      },
      child: Row(
        children: <Widget>[
          Radio(
            groupValue: value,
            value: option['value'],
          ),
          Text(option['title'],
              style: value == option['value']
                  ? selectBoxOptionActive
                  : selectBoxOption),
        ],
      ),
    ));
  });

  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: getScaledValue(15),
                    vertical: getScaledValue(10)),
                margin: const EdgeInsets.only(bottom: 6.0),
                //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: Text(title, style: selectBoxTitle)),
            Container(
              color: Colors.grey[50],
              padding: EdgeInsets.symmetric(
                  horizontal: getScaledValue(10), vertical: getScaledValue(5)),
              margin: EdgeInsets.only(bottom: getScaledValue(10)),
              child: Column(
                children: _childrenOption,
              ),
            ),
          ],
        );
      });
}

loadBottomSheet(
    {BuildContext context,
    Widget content,
    bool dismissable = true,
    bool wrap = true,
    Color bgColor}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(getScaledValue(14)),
        topRight: Radius.circular(getScaledValue(14)),
      )
          //
          ),
      isDismissible: dismissable,
      isScrollControlled: wrap,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal) {
          if (wrap) {
            return Wrap(
              children: <Widget>[
                Container(
                    color: bgColor,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: getScaledValue(15),
                        vertical: getScaledValue(10)),
                    margin: const EdgeInsets.only(bottom: 6.0),
                    child: content)
              ],
            );
          } else {
            return Container(
                color: bgColor,
                width: double.infinity,
                //padding: EdgeInsets.symmetric(horizontal: getScaledValue(15), vertical: getScaledValue(10)),
                margin: const EdgeInsets.only(bottom: 6.0),
                child: content);
          }
        });
      });
}

bottomAlertBox({
  BuildContext context,
  String title,
  String subtitle,
  String description,
  String title2,
  String subtitle2,
  String description2,
  String title3,
  String subtitle3,
  String description3,
  String title4,
  String subtitle4,
  String description4,
  Widget childContent,
}) {
  Widget content = Container(
      constraints: BoxConstraints(minHeight: getScaledValue(100)),
      margin: EdgeInsets.symmetric(vertical: getScaledValue(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title, style: appBodyH3))
              : emptyWidget,
          subtitle != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle, style: appBodyH4))
              : emptyWidget,
          title != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          description != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description, style: bodyText4))
              : emptyWidget,
          title2 != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          title2 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title2, style: appBodyH3))
              : emptyWidget,
          subtitle2 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle2, style: appBodyH4))
              : emptyWidget,
          title2 != null || description2 != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title2 != null || description2 != null
              ? SizedBox(height: getScaledValue(10))
              : emptyWidget,
          description2 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description2, style: bodyText4))
              : emptyWidget,
          title3 != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          title3 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title3, style: appBodyH3))
              : emptyWidget,
          subtitle3 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle3, style: appBodyH4))
              : emptyWidget,
          title3 != null || description3 != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title3 != null || description3 != null
              ? SizedBox(height: getScaledValue(10))
              : emptyWidget,
          description3 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description3, style: bodyText4))
              : emptyWidget,
          title4 != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
          title4 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(title4, style: appBodyH3))
              : emptyWidget,
          subtitle4 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(subtitle4, style: appBodyH4))
              : emptyWidget,
          title4 != null || description4 != null
              ? Divider(height: getScaledValue(5), color: Colors.grey)
              : emptyWidget,
          title4 != null || description4 != null
              ? SizedBox(height: getScaledValue(10))
              : emptyWidget,
          description4 != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
                  child: Text(description4, style: bodyText4))
              : emptyWidget,
          childContent != null ? childContent : emptyWidget
        ],
      ));

  loadBottomSheet(context: context, content: content);
}

Widget bulletPointer(String caption, {Color color, Color bulletColor}) {
  return Container(
    margin: EdgeInsets.only(bottom: getScaledValue(10)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(top: getScaledValue(5)),
            child: Icon(
              Icons.fiber_manual_record,
              color: colorBlue,
              size: getScaledValue(10),
            )),
        SizedBox(width: getScaledValue(10)),
        Expanded(
            child: Text(caption,
                style: bodyText1.copyWith(color: Color(0xff747474)))),
      ],
    ),
  );
}

Widget bulletPointerLarge(String caption, {Color color, Color bulletColor}) {
  return Container(
    margin: EdgeInsets.only(bottom: getScaledValue(10)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(top: getScaledValue(5)),
            child: Icon(
              Icons.check,
              color: colorBlue,
              size: getScaledValue(10),
            )),
        SizedBox(width: getScaledValue(10)),
        Expanded(
            child: Text(caption,
                style: bodyText1.copyWith(color: Color(0xff747474)))),
      ],
    ),
  );
}

Widget AlertDialogButton(
    {BuildContext context, String title, Function onPressed}) {
  return DialogButton(
    child: Text(
      title,
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
    onPressed: onPressed,
    color: Color.fromRGBO(0, 179, 134, 1.0),
    radius: BorderRadius.circular(0.0),
  );
}

customAlertBox(
    {BuildContext context,
    String type = "info",
    String title,
    String description,
    Widget childContent,
    List<Widget> buttons}) {
  List<Widget> buttonRow = [];

  if (buttons == null || buttons.length == 0) {
    buttonRow.add(Expanded(
        child: gradientButton(
            context: context,
            caption: "Ok",
            onPressFunction: () => Navigator.pop(context))));
  } else {
    int i = 1;
    buttons.forEach((element) {
      buttonRow.add(Expanded(child: element));
      if (i < buttons.length) {
        buttonRow.add(SizedBox(width: getScaledValue(10)));
        i++;
      }
    });
  }

  Widget content = Container(
    padding: EdgeInsets.all(getScaledValue(10)),
    child: Column(children: <Widget>[
      title != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
              child: Text(title, style: appBodyH3))
          : emptyWidget,
      title != null
          ? Divider(height: getScaledValue(5), color: Colors.grey)
          : emptyWidget,
      title != null ? SizedBox(height: getScaledValue(10)) : emptyWidget,
      childContent != null ? childContent : emptyWidget,
      description != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: getScaledValue(15)),
              child: Text(description, style: bodyText4))
          : emptyWidget,
      SizedBox(height: getScaledValue(20)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: buttonRow)
    ]),
  );

  loadBottomSheet(context: context, content: content);
}

double getScaledValue(double size, {bool allowFontScalingSelf = true}) {
  return ScreenUtil().setSp(size);
}

double setHeight(double size) {
  return ScreenUtil().setHeight(size);
}

double setWidth(double size) {
  return ScreenUtil().setWidth(size);
}

String androidMediaHeight(BuildContext context) {
  if (MediaQuery.of(context).size.height <= 640) {
    return "small";
  } else {
    return "large";
  }
}

double getHeight(BuildContext context, double size) {
  // log.d(MediaQuery.of(context).size.height);

  if (Platform.isAndroid) {
    return MediaQuery.of(context).size.height * size;
  } else {
    return MediaQuery.of(context).size.height * (size * 0.82);
  }
}

String removeDecimal(String value) {
  var list = value.split('.');
  return list[0].toString();
}

roundDouble(value,
    {int decimalLength = 2,
    String returnType = "string",
    bool showNa = true,
    String postFix = ""}) {
  if ((value == "nan" || value == "null" || value == null)) {
    if (showNa) {
      return "NA";
    } else {
      value = 0;
    }
  }

  if (value is String) {
    value = double.parse(value);
  }
  if (returnType == "double") {
    return double.parse(value.toStringAsFixed(decimalLength));
  } else if (returnType == "string") {
    return value.toStringAsFixed(decimalLength) + postFix;
  }
}

num strictNum(value) {
  if (value is num) {
    return value;
  } else {
    return num.parse(value);
  }
}

String limitChar(String string, {int length = 20}) {
  return string.length > length ? string.substring(0, length) + "..." : string;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

Widget progressLoader = new Center(
  child: new CircularProgressIndicator(),
);

Widget svgImage(String path,
    {double height, double width, Color color, BoxFit fit}) {
  if (kIsWeb) {
    return isCanvasKit()
        ? SvgPicture.asset(
            path,
            color: color != null ? color : null,
            fit: fit != null ? fit : BoxFit.contain,
            height: height != null ? getScaledValue(height) : null,
            width: width != null ? getScaledValue(width) : null,
          )
        : Image.network(
            "assets/$path",
            color: color != null ? color : null,
            fit: fit != null ? fit : BoxFit.contain,
            height: height != null ? getScaledValue(height) : null,
            width: width != null ? getScaledValue(width) : null,
          );
  }
  return SvgPicture.asset(
    path,
    color: color != null ? color : null,
    fit: fit != null ? fit : BoxFit.contain,
    height: height != null ? getScaledValue(height) : null,
    width: width != null ? getScaledValue(width) : null,
  );
}

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

bool isBetween(num value, num from, num to, bool inclusive) {
  if (inclusive) {
    return from <= value && value <= to;
  } else {
    return from < value && value < to;
  }
}

Widget divider({int dividerHeight = 1, Color dividerColor = AppColor.divider}) {
  return Container(
    height: dividerHeight.toDouble(),
    color: dividerColor,
  );
}

class FloatingCard extends StatelessWidget {
  final Widget child;
  final double cornerRadius;
  final bool addGradient;
  final Color backgroundColor;
  final double opacity;

  const FloatingCard({
    Key key,
    @required this.child,
    this.cornerRadius = 4,
    this.addGradient = true,
    this.backgroundColor = Colors.white,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: BoxShadows.cardShadow,
          color: backgroundColor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: opacity,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      gradient: addGradient
                          ? Gradients.floating_card_white_gradient
                          : null,
                      color: addGradient ? null : backgroundColor),
                ),
              ),
              child
            ],
          ),
        ),
      ),
    );
  }
}

String getCurrencySymbol(String currency) {
  if (currency == "inr" || currency == null) {
    return "₹";
  } else if (currency == "usd") {
    return "\$";
  } else if (currency == "sgd") {
    return "S\$";
  } else {
    return "";
  }
}

Widget gradientButtonWithChild({Widget widget, bool buttonDisabled = false}) {
  return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: buttonDisabled
                    ? [Colors.grey, Colors.grey[400]]
                    : [Color(0xff0941cc), Color(0xff0055fe)],
                stops: [0.0, 0.9]),
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: widget),
        ),
      ));
}

String dateString(var date, {String format = "yyyy-MM-dd"}) {
  if (date is String) {
    date = DateTime.parse(date);
  }
  DateFormat dateFormat = DateFormat(format);
  return dateFormat.format(date != null ? date : DateTime.now());
}

String displayTimeAgoFromTimestamp(String timestamp) {
  final year = int.parse(timestamp.substring(0, 4));
  final month = int.parse(timestamp.substring(5, 7));
  final day = int.parse(timestamp.substring(8, 10));
  final hour = int.parse(timestamp.substring(11, 13));
  final minute = int.parse(timestamp.substring(14, 16));

  final DateTime videoDate = DateTime(year, month, day, hour, minute);
  final int diffInHours = DateTime.now().difference(videoDate).inHours;

  String timeAgo = '';
  String timeUnit = '';
  int timeValue = 0;

  if (diffInHours < 1) {
    final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
    timeValue = diffInMinutes;
    timeUnit = 'minute';
  } else if (diffInHours < 24) {
    timeValue = diffInHours;
    timeUnit = 'hour';
  } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
    timeValue = (diffInHours / 24).floor();
    timeUnit = 'day';
  } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
    timeValue = (diffInHours / (24 * 7)).floor();
    timeUnit = 'week';
  } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
    timeValue = (diffInHours / (24 * 30)).floor();
    timeUnit = 'month';
  } else {
    timeValue = (diffInHours / (24 * 365)).floor();
    timeUnit = 'year';
  }

  timeAgo = timeValue.toString() + ' ' + timeUnit;
  timeAgo += timeValue > 1 ? 's' : '';

  return timeAgo + ' ago';
}

String riskProfileSamplePortfolio(
    {MainModel model, String desiredPath, String riskProfilerPath}) {
  String returnPath = "";
  if (model.userRiskProfile != null) {
    returnPath = desiredPath;
  } else {
    if (model.userPortfolios.length == 1) {
      bool sampleFound = false;
      model.userPortfoliosData
          .forEach((portfolioMasterID, portfolioMasterData) {
        if (portfolioMasterData['sample'] == '1') {
          sampleFound = true;
        }
      });
      if (sampleFound) {
        returnPath = desiredPath;
      } else {
        returnPath = riskProfilerPath;
      }
    } else {
      returnPath = riskProfilerPath;
    }
  }

  return "/" + returnPath;
}

Map portfoliosFundTypeCount(
    {portfolios,
    String portfolioMasterID,
    bool checkLive = false,
    bool checkWeight = false}) {
  Map fundTypeCount = {};

  if (portfolios.length > 0) {
    if (portfolioMasterID != null) {
      var portfolioFundCountData =
          portfolioFundCount(portfolioMaster: portfolios[portfolioMasterID]);

      if (!checkLive ||
          (checkLive && portfolios[portfolioMasterID]['type'] == '1')) {
        portfolioFundCountData.forEach((fundType, count) {
          if (!fundTypeCount.containsKey(fundType)) fundTypeCount[fundType] = 0;
          fundTypeCount[fundType] += count;
        });
      }
    } else {
      portfolios.forEach((portfolioID, portfolioMaster) {
        var portfolioFundCountData =
            portfolioFundCount(portfolioMaster: portfolioMaster);

        if (!checkLive || (checkLive && portfolioMaster['type'] == '1')) {
          portfolioFundCountData.forEach((fundType, count) {
            if (!fundTypeCount.containsKey(fundType))
              fundTypeCount[fundType] = 0;
            fundTypeCount[fundType] += count;
          });
        }
      });
    }
  }
  return fundTypeCount;
}

Map portfolioFundCount({portfolioMaster, bool checkWeight = false}) {
  bool returnCount = true;

  Map fundTypeCount = {};

  if (portfolioMaster['portfolios'].length > 0) {
    portfolioMaster['portfolios'].forEach((fundType, portfolios) {
      if (checkWeight) {
        portfolios.forEach((portfolio) {
          if (num.parse(portfolio['weightage']) <= 0) {
            returnCount = false;
            //count += portfolios.length;
          } else {
            if (!fundTypeCount.containsKey(fundType))
              fundTypeCount[fundType] = 0;
            fundTypeCount[fundType] += portfolios.length;
          }
        });
      } else {
        if (!fundTypeCount.containsKey(fundType)) fundTypeCount[fundType] = 0;
        fundTypeCount[fundType] += portfolios.length;
      }
    });
  }

  if (returnCount) {
    return fundTypeCount;
  } else {
    return {};
  }
}

class AppbarHomeButton extends StatelessWidget {
  const AppbarHomeButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: getScaledValue(16)),
        child: svgImage('assets/icon/home.svg'),
        height: 16,
        width: 17);
  }
}

class RandomImages extends StatefulWidget {
  RandomImages({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WidgetImagesState();
  }
}

class _WidgetImagesState extends State<RandomImages> {
  var listImagesnotFound = [
    "assets/images/random01.jpg",
    "assets/images/random02.jpg",
    "assets/images/random03.jpg",
    "assets/images/random04.jpg",
    "assets/images/random05.jpg"
  ];
  Random rnd;
  String randomImages;
  Set<int> setOfInts = Set();

  @override
  void initState() {
    super.initState();

    int min = 0;
    int max = listImagesnotFound.length - 1;
    rnd = new Random();
    int r = min + rnd.nextInt(max - min);
    setOfInts.add(Random().nextInt(max));
    randomImages = listImagesnotFound[r].toString();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(child: Image.asset(randomImages, fit: BoxFit.cover));
    });
  }
}
