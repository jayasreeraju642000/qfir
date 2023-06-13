import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:qfinr/application.dart';
import 'package:qfinr/pages/add_portfolio/add_portfolio.dart';
import 'package:qfinr/pages/add_portfolio_mannually/add_portfolio_manually.dart';
import 'package:qfinr/pages/analyse/analyse_summary/analyse_summary.dart';
import 'package:qfinr/pages/discover/discover.dart';
import 'package:qfinr/pages/discover/discover_know_your_assets_large_screen.dart';
import 'package:qfinr/pages/explore_ideas/explore_ideas.dart';
import 'package:qfinr/pages/explore_ideas_result/explore_ideas_result.dart';
import 'package:qfinr/pages/fund_info/fund_info.dart';
import 'package:qfinr/pages/home/home_new.dart';
import 'package:qfinr/pages/invite_friends/invitations/invite_ref_code.dart';
import 'package:qfinr/pages/know_fund_detail/know_fund_detail.dart';
import 'package:qfinr/pages/know_fund_report/know_fund_report.dart';
import 'package:qfinr/pages/manage_portfolio/manage_portfolio.dart';
import 'package:qfinr/pages/manage_transaction/manage_transaction.dart';
import 'package:qfinr/pages/portfolio_chart.dart';
import 'package:qfinr/pages/portfolio_import_excel/portfolio_import_excel.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_strategy/url_strategy.dart';

import './pages/authentication.dart';
import './pages/benchmark_performance.dart';
import './pages/comingSoon.dart';
import './pages/forgotPassword.dart';
import './pages/goal_planner.dart';
import './pages/intro_slider.dart';
import './pages/language_selector.dart';
import './pages/loadPDF.dart';
import './pages/login_main.dart';
import './pages/marketIndicators.dart';
import './pages/news.dart';
import './pages/not_found.dart';
import './pages/portfolio_analyzer.dart';
import './pages/portfolio_knowfund.dart';
import './pages/register.dart';
import './pages/settings.dart';
import './pages/settings/biometric.dart';
import './pages/settings/currency.dart';
import './pages/settings/notification.dart';
import './pages/settings/password.dart';
import './pages/settings/profile.dart';
import './pages/sort_filter.dart';
import './pages/tools.dart';
import './pages/zone_selector.dart';
import './widgets/helpers/custom_route.dart';
import 'all_translations.dart';
import 'models/main_model.dart';
import 'pages/analyse/details/portfolio_analyzer_detail.dart';
import 'pages/analyse/dividend_report/portfolio_dividend_report.dart';
import 'pages/analyse/portfolio_master_selector.dart';
import 'pages/analyse/report/portfolio_analyzer_report.dart';
import 'pages/analyse/stress_test_report/stress_test_report.dart';
import 'pages/benchmark_selector/benchmark_selector.dart';
import 'pages/forgot_password/forgotPasswordConfirm.dart';
import 'pages/login/login.dart';
import 'pages/manage_portfolio_master/manage_portfolio_master.dart';
import 'pages/notifications/notifications.dart';
import 'pages/portfolio_analyzer_old.dart';
import 'pages/profile_risk/risk_profiler.dart';
import 'pages/risk_profile_alert.dart/risk_profiler_alert.dart';
import 'pages/set_passcode/set_passcode.dart';
import 'pages/success_page/success_page.dart';
import 'pages/verify_passcode/verify_passcode.dart';

final log = getLogger('Main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPaintSizeEnabled = false;

  await allTranslations.init();

  if (kReleaseMode) {
    Logger.level = Level.info;
  } else {
    Logger.level = Level.verbose;
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    ScreenBreakpoints(desktop: 1285, tablet: 768, watch: 200),
  );

  if (!kIsWeb) {
    //FirebaseCrashlytics.instance.crash();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  
  }

  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const commonPrimaryColor = const Color(0xFF0F52BA);
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const PrimaryColor1 = const Color(0xFF535971);
  static const PrimaryColor = const Color(0xFF0F52BA);

  static const TextPrimaryColor = const Color(0xFF0F52BA);
  // static const TextAccentColor = const Color(0xFF6b7c93);

  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  void getModel(MainModel model) async {
    await model.autoAuthenticate();
    //await model.fetchBaskets();
    //await model.fetchMFBaskets();
    //await model.fetchMIBaskets(false);

    /* await model.fetchNews();
		await model.fetchTweets(); */
    model.setLoader(false);
  }

  void getRandomImages(MainModel model) async {
    var _randomImageList = [
      "assets/images/random01.jpg",
      "assets/images/random02.jpg",
      "assets/images/random03.jpg",
      "assets/images/random04.jpg",
      "assets/images/random05.jpg"
    ];

    _randomImageList.shuffle();

    await model.getRandomImages(_randomImageList);
  }

  void initState() {
    super.initState();

    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
  }

  _onLocaleChanged() async {
    // do anything you need to do if the language changes
    log.i('Language has been changed to: ${allTranslations.currentLanguage}');
  }

  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();
    getRandomImages(model);
    getModel(model);

    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        navigatorKey: Application.navKey,
        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,
        // Color(0xFF535971)
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: createMaterialColor(Color(0xFF0F52BA)),
            //disabledColor: Colors.grey,
            primaryColor: PrimaryColor,
            primaryColorDark: PrimaryColor1,
            backgroundColor: Colors.white, //Color(0xFFf2f2f2),
            highlightColor: Color(0xFF6b7c93),
            focusColor: TextPrimaryColor,
            fontFamily: 'nunito',
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'nunito',
                  letterSpacing: 0.4,
                  color: Colors.black),
              // for input labels
              headline5: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'nunito',
                  letterSpacing: 0.5,
                  color: Color(0xff2454ec)),
              bodyText2: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'nunito',
                  letterSpacing: 0.2,
                  color: Color(0xff5e5e5e)),

              headline6: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: TextPrimaryColor),
              subtitle1: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
              subtitle2: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
              bodyText1: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
              overline: TextStyle(
                  fontSize: 8.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600]),
              button: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'nunito',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.0),
            )),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        // Tells the system which are the supported languages
        supportedLocales: allTranslations.supportedLocales(),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant(
                builder: (BuildContext context, Widget child, MainModel model) {
                  return IntroSliderPage(model,
                      analytics: analytics,
                      observer:
                          observer); //model.isUserAuthenticated  ? VerifyPasscodePage(model, false, true,) : LoginPage(model, analytics: analytics, observer: observer); //IntroSliderPage();
                },
              ),
          //'/': (BuildContext context) =>  model.isUserAuthenticated ? HomePage(model) : IntroSliderPage(),
          /*'/languageSelector': (BuildContext context) => LanguageSelectorPage(model, true),
					'/intro': (BuildContext context) => IntroSliderPage(),
					'/login': (BuildContext context) => LoginPage(model, analytics: analytics, observer: observer),
					'/register': (BuildContext context) => RegisterPage(model, analytics: analytics, observer: observer),
					'/forgotPassword': (BuildContext context) => ForgotPasswordPage(),
					'/home': (BuildContext context) => HomePage(model, analytics: analytics, observer: observer),
					'/homemf': (BuildContext context) => HomePageMF(model, analytics: analytics, observer: observer),
					'/homemi': (BuildContext context) => HomePageMI(model, analytics: analytics, observer: observer), 
					'/shortlistedBaskets': (BuildContext context) => ShortlistedPage(model),*/
          //'/mutualFunds': (BuildContext context) => MutualFundsPage(model),
          '/marketIndicators': (BuildContext context) =>
              MarketIndicatorsPage(model),
        },
        navigatorObservers: <NavigatorObserver>[observer],
        onGenerateRoute: (RouteSettings settings) {
          log.i(
              'onGenerateRoute | name: ${settings.name} arguments: ${settings.arguments}');
          final List<String> pathElements = settings.name.split('/');
          final arguments = settings.arguments as Map;
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'comingSoon') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ComingSoonPage(model),
            );
            /* }else if (pathElements[1] == 'basket') {
						final String basketIndex = pathElements[2];
						return CustomSlideRoute<bool>(
							builder: (BuildContext context) => BasketPage(model, basketIndex, analytics: analytics, observer: observer),
						);
					}else if (pathElements[1] == 'mfbasket') {
						final String basketIndex = pathElements[2];
						return CustomSlideRoute<bool>(
							builder: (BuildContext context) => MFBasketPage(model, basketIndex, analytics: analytics, observer: observer),
						);
					}else if (pathElements[1] == 'mibasket') {
						final String basketIndex = pathElements[2];
						return CustomSlideRoute<bool>(
							builder: (BuildContext context) => MIBasketPage(model, basketIndex, analytics: analytics, observer: observer),
						);				
					}else if (pathElements[1] == 'home') {
						return CustomFadeRoute<bool>(
							builder: (BuildContext context) => HomePage(model, analytics: analytics, observer: observer),
						);
					}else if (pathElements[1] == 'homemf') {
						return CustomFadeRoute<bool>(
							builder: (BuildContext context) => HomePageMF(model, analytics: analytics, observer: observer),
						);
					}else if (pathElements[1] == 'homemi') {
						return CustomFadeRoute<bool>(
							builder: (BuildContext context) => HomePageMI(model, analytics: analytics, observer: observer),
						);*/

          } else if (pathElements[1] == 'tools') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  Tools(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'news') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  NewsPage(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'languageSelector') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  LanguageSelectorPage(model, true),
            );
          } else if (pathElements[1] == 'languageSelectorFalse') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  LanguageSelectorPage(model, false),
            );
          } else if (pathElements[1] == 'intro') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => IntroSliderPage(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'authenticaton') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AuthenticationPage(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'setPasscode') {
            bool registrationFlag = false;
            if (pathElements[2] == "true") {
              registrationFlag = true;
            }
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => SetPasscodePage(
                model,
                true,
                false,
                analytics: analytics,
                observer: observer,
                registrationFlag: registrationFlag,
              ),
              //builder: (BuildContext context) => VerifyPasscodePage(model, true, false, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'verifyPasscodeStartup') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => VerifyPasscodePage(
                  model, false, true,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'verifyPasscode') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => VerifyPasscodePage(
                  model, false, false,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'login') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  LoginPage(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'login_main') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => LoginMainPage(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'register') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  RegisterPage(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'forgotPassword') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => ForgotPasswordPage(),
            );
          } else if (pathElements[1] == 'forgotPasswordConfirm') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => ForgotPasswordConfirmPage(),
            );

/* 					}else if (pathElements[1] == 'shortlistedBaskets') {
						return CustomSlideRoute<bool>(
							builder: (BuildContext context) => ShortlistedPage(model),
						); */

          } else if (pathElements[1] == 'goalPlanner') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) =>
                  GoalPlanner(model, pathElements[2]),
            );
          } else if (pathElements[1] == 'loadPDF') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => LoadPDF(model),
            );
          } else if (pathElements[1] == 'riskProfiler') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => RiskProfiler(
                model,
                analytics: analytics,
                observer: observer,
              ),
            );
          } else if (pathElements[1] == 'riskProfilerAlert') {
            if (pathElements[3] == 'web') {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => RiskProfilerAlert(model,
                    analytics: analytics,
                    observer: observer,
                    action: pathElements[2]),
              );
            } else {
              return CustomSlideRoute<bool>(
                builder: (BuildContext context) => RiskProfilerAlert(model,
                    analytics: analytics,
                    observer: observer,
                    action: pathElements[2]),
              );
            }
          } else if (pathElements[1] == 'portfolioAnalyzerOld') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => PortfolioAnalyzerOld(model),
            );
          } else if (pathElements[1] == 'portfolioAnalyzer') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => PortfolioAnalyzer(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'portfolioAnalyzerReport') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => PortfolioAnalyzerReport(model,
                  analytics: analytics,
                  observer: observer,
                  responseData: arguments['responseData'],
                  selectedPortfolioMasterIDs:
                      arguments['selectedPortfolioMasterIDs'],
                  benchmark: arguments['benchmark']),
            );
          } else if (pathElements[1] == 'portfolioAnalyzerDetails') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => PortfolioAnalyzerDetail(model,
                  analytics: analytics,
                  observer: observer,
                  responseData: arguments['responseData'],
                  selectedPortfolioMasterIDs:
                      arguments['selectedPortfolioMasterIDs'],
                  benchmark: arguments['benchmark'],
                  tabIndex: int.parse(pathElements[2])),
            );
          } else if (pathElements[1] == 'stressTestReport') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => StressTestReport(model,
                  analytics: analytics,
                  observer: observer,
                  responseData: arguments['responseData']),
            );
          } else if (pathElements[1] == 'portfolioDividendReport') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => PortfolioDividendReport(model,
                  analytics: analytics,
                  observer: observer,
                  responseData: arguments['responseData']),
            );
          } else if (pathElements[1] == 'sortFilter') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) =>
                  SortFilter(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'portfolioKnowFund') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => PortfolioKnowFund(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'knowFundReport') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => KnowFundReport(model,
                  analytics: analytics,
                  observer: observer,
                  responseData: arguments['responseData']),
            );
          } else if (pathElements[1] == 'knowFundDetail') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => KnowFundDetail(model,
                  analytics: analytics,
                  observer: observer,
                  responseData: arguments['responseData'],
                  tabIndex: int.parse(pathElements[2])),
            );
          } else if (pathElements[1] == 'settings') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => SettingsPage(model),
            );
          } else if (pathElements[1] == 'setting') {
            if (pathElements[2] == "SettingsProfilePage") {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => SettingsProfilePage(model),
              );
            } else if (pathElements[2] == "SettingsNotificationPage") {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) =>
                    SettingsNotificationPage(model),
              );
            } else if (pathElements[2] == "SettingsBiometricPage") {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => SettingsBiometricPage(model),
              );
            } else if (pathElements[2] == "SettingsPasswordPage") {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => SettingsPasswordPage(model),
              );
            } else if (pathElements[2] == "SettingsForcePasswordPage") {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => SettingsPasswordPage(
                  model,
                  forcePassword: true,
                ),
              );
            } else if (pathElements[2] == "SettingsCurrencyPage") {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => SettingsCurrencyPage(model),
              );
            }
          } else if (pathElements[1] == 'zoneSelector') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => ZoneSelectorPage(model),
            );
          } else if (pathElements[1] == 'home_new') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  HomePageNew(model, analytics: analytics, observer: observer),
            );
            /* }else if (pathElements[1] == 'home_baskets') {
						return CustomFadeRoute<bool>(
							builder: (BuildContext context) => HomeBaskets(model, analytics: analytics, observer: observer),
						); */
          } else if (pathElements[1] == 'benchmark_performance') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => BenchmarkPerformance(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'portfolio_edit') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ManagePortfolio(model,
                  portfolioMasterID: pathElements[2],
                  analytics: analytics,
                  observer: observer),
            );
          } else if (pathElements[1] == 'portfolio_edit_new') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ManagePortfolio(model,
                  portfolioMasterID: pathElements[2],
                  newPortfolio: true,
                  portfolioName: pathElements[3],
                  analytics: analytics,
                  observer: observer),
            );
          } else if (pathElements[1] == 'portfolio_view') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ManagePortfolio(model,
                  portfolioMasterID: pathElements[2],
                  managePortfolio: false,
                  reloadData: false,
                  viewPortfolio: true,
                  readOnly: arguments['readOnly'],
                  analytics: analytics,
                  observer: observer),
            );
          } else if (pathElements[1] == 'add_ric') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => ManageTransactionPage(
                model,
                ricSelected: false,
                portfolioMasterID: pathElements[2],
                analytics: analytics,
                observer: observer,
                arguments: arguments,
              ),
            );
          } else if (pathElements[1] == 'edit_ric') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => ManageTransactionPage(
                model,
                ricSelected: true,
                mode: "edit",
                portfolioMasterID: pathElements[2],
                ricType: pathElements[3],
                ricName: pathElements[4],
                ricZone: pathElements[5],
                ricIndex: pathElements[6],
                refreshParentState: arguments['refreshParentState'],
                readOnly: arguments['readOnly'],
                analytics: analytics,
                observer: observer,
                arguments: arguments,
              ),
            );
          } else if (pathElements[1] == 'manage_portfolio_master') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ManagePortfolioMaster(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'manage_portfolio_master_view') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ManagePortfolioMaster(model,
                  analytics: analytics, observer: observer, viewOnly: true),
            );
          } else if (pathElements[1] == 'analyse_summary') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AnalyseSummary(model,
                  analytics: analytics, observer: observer, viewOnly: true),
            );
          } else if (pathElements[1] == 'portfolio_master_selectors') {
            String layout = "checkbox";
            if (arguments['layout'] != null) {
              layout = arguments['layout'];
            }
            if (pathElements[2] == "analyzer") {
              if (pathElements[3] == "web") {
                return CustomFadeRoute<bool>(
                  builder: (BuildContext context) => PortfolioMasterSelector(
                      model,
                      analytics: analytics,
                      observer: observer,
                      action: pathElements[2],
                      portfolioMasterID: arguments['portfolioMasterID'],
                      layout: layout,
                      isSideMenuHeadingSelected:
                          arguments['isSideMenuHeadingSelected'],
                      isSideMenuSelected: arguments['isSideMenuSelected']),
                );
              } else {
                return CustomSlideRoute<bool>(
                  builder: (BuildContext context) => PortfolioMasterSelector(
                      model,
                      analytics: analytics,
                      observer: observer,
                      action: pathElements[2],
                      portfolioMasterID: arguments['portfolioMasterID'],
                      layout: layout,
                      isSideMenuHeadingSelected:
                          arguments['isSideMenuHeadingSelected'],
                      isSideMenuSelected: arguments['isSideMenuSelected']),
                );
              }
            } else {
              return CustomFadeRoute<bool>(
                builder: (BuildContext context) => PortfolioMasterSelector(
                    model,
                    analytics: analytics,
                    observer: observer,
                    action: pathElements[2],
                    portfolioMasterID: arguments['portfolioMasterID'],
                    layout: layout,
                    isSideMenuHeadingSelected:
                        arguments['isSideMenuHeadingSelected'],
                    isSideMenuSelected: arguments['isSideMenuSelected']),
              );
            }
          } else if (pathElements[1] == 'benchmark_selector') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => BenchmarkSelector(model,
                  analytics: analytics,
                  observer: observer,
                  selectedPortfolioMasterIDs:
                      arguments['selectedPortfolioMasterIDs']),
            );
          } else if (pathElements[1] == 'add_portfolio') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioPage(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'add_portfolio_manually') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioManuallyPage(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'portfolio_import_excel') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => PortfolioImportExcel(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'add_instrument') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioManuallyPage(model,
                  analytics: analytics,
                  observer: observer,
                  pageType: "add_instrument",
                  action: "newInstrument",
                  viewDeposit: arguments['viewDeposit'],
                  portfolioMasterID: arguments['portfolioMasterID'],
                  portfolioDepositID: arguments['portfolioDepositID']),
            );
          } else if (pathElements[1] == 'add_transactions') {
            return CustomSlideRoute<bool>(
              builder: (BuildContext context) => ManageTransactionPage(
                model,
                analytics: analytics,
                observer: observer,
                mode: "edit",
                action: "new",
                portfolioMasterID: arguments['portfolioMasterID'],
                ricType: arguments['ricType'],
                ricIndex: arguments['ricIndex'],
                ricSelected: arguments['ricSelected'],
                ricZone: arguments['ricZone'],
                ricName: arguments['ricName'],
                portfolioMasterData: arguments['portfolioMasterData'],
                arguments: arguments,
              ),
            );
          } else if (pathElements[1] == 'merge_portfolio_portfolio_name') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioManuallyPage(model,
                  analytics: analytics,
                  observer: observer,
                  action: 'merge',
                  selectedPortfolioMasterIDs:
                      arguments['selectedPortfolioMasterIDs']),
            );
          } else if (pathElements[1] == 'split_portfolio_portfolio_name') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioManuallyPage(
                model,
                analytics: analytics,
                observer: observer,
                action: 'split',
                portfolioMasterID: arguments['portfolioMasterID'],
              ),
            );
          } else if (pathElements[1] == 'rename_portfolio') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioManuallyPage(
                model,
                analytics: analytics,
                observer: observer,
                action: 'rename',
                portfolioMasterID: arguments['portfolioMasterID'],
              ),
            );
          } else if (pathElements[1] == 'success_page') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => SuccessPage(
                model,
                analytics: analytics,
                observer: observer,
                action: arguments['type'],
                arguments: arguments,
              ),
            );
          } else if (pathElements[1] == 'discover') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  DiscoverPage(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'exploreIdeas') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ExploreScreen(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'exploreIdeasResult') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ExploreIdeasResultScreen(model,
                  analytics: analytics,
                  observer: observer,
                  selectedFilter: arguments['selectedFilter']),
            );
          } else if (pathElements[1] == 'add_portfolio_discover') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => AddPortfolioManuallyPage(model,
                  analytics: analytics,
                  observer: observer,
                  action: 'discover',
                  arguments: arguments),
            );
          } else if (pathElements[1] == 'notification') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => NotificationPage(model,
                  analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'fund_info') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => FundInfo(model,
                  analytics: analytics,
                  observer: observer,
                  ric: arguments['ric']),
            );
          } else if (pathElements[1] == 'portfolio_chart') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => PortfolioChart(model,
                  analytics: analytics,
                  observer: observer,
                  portfolioMasterID: arguments['portfolioMasterID']),
            );
          } else if (pathElements[1] == "riskProfilerFromTopMenuBar") {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => RiskProfiler(
                model,
                analytics: analytics,
                observer: observer,
              ),
            );
          } else if (pathElements[1] == 'edit_ric_large') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => ManageTransactionPage(
                model,
                ricSelected: true,
                mode: "edit",
                portfolioMasterID: pathElements[2],
                ricType: pathElements[3],
                ricName: pathElements[4],
                ricZone: pathElements[5],
                ricIndex: pathElements[6],
                refreshParentState: arguments['refreshParentState'],
                readOnly: arguments['readOnly'],
                analytics: analytics,
                observer: observer,
                arguments: arguments,
              ),
            );
          } else if (pathElements[1] == 'discoverLarge') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  DiscoverPage(model, analytics: analytics, observer: observer),
            );
          } else if (pathElements[1] == 'discoverKnowYorAssetLargeScreen') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) =>
                  DiscoverKnowYorAssetLargeScreen(model),
            );
          } else if (pathElements[1] == 'inviteFriends') {
            return CustomFadeRoute<bool>(
              builder: (BuildContext context) => InvitationRefCode(
                model,
                analytics: analytics,
                observer: observer,
              ),
            );
          }

          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return CustomFadeRoute(
              builder: (BuildContext context) => NotFoundPage());
        },
      ),
    );
  }
}
