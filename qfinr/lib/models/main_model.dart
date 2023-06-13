import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:qfinr/application.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import '../plugins/google_sign_in/google_sign_in.dart';
import '../widgets/widget_common.dart';

/* GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
); */
final log = getLogger('MainModel');

class MainModel extends Model
    with
        BasketModel,
        MFBasketModel,
        MIBasketModel,
        ConnectedModel,
        UserModel,
        UtilityModel {
  void reloadData() async {
    //await fetchBaskets();
    //await fetchMFBaskets();
    //await fetchMIBaskets(true);
    await getCurrencyList();
    await getCustomerPortfolio();

    /* await fetchNews();
		await fetchTweets(); */
  }

  Future<Map<String, dynamic>> callHTTP(
      {String url, bool postData = false, Map postDataValues}) async {
    log.d('callHTTP | url: ${url} postdata: ${postData}');
    if (postDataValues != null) {
      log.d('postValues: ${postDataValues}');
    }

    http.Response response;

    if (postData) {
      response = await http.post(Uri.parse(url), body: postDataValues);
    } else {
      response = await http.get(Uri.parse(url));
    }

    final Map<String, dynamic> responseData =
        json.decode(response.body == '' ? '{}' : response.body);
    log.d('callHTTP | url: ${url} response:${responseData}');
    if (responseData.containsKey("status") &&
        responseData.containsKey("response_code")) {
      if (responseData["status"] == false &&
          responseData["response_code"] == "a-er01") {
        logout();
        Application.navKey.currentState.pushReplacementNamed("/login");
      }
    }
    return responseData;
  }
}

class ConnectedModel extends Model {
  List<Basket> _baskets = [];
  List<MFBasket> _mfbaskets = [];

  // List<MIBasket> _mibaskets = [];
  List<ShortlistedBasket> _shortlistedBaskets = [];
  List<ShortlistedMFBasket> _shortlistedmfBaskets = [];

  // List<ShortlistedMIBasket> _shortlistedmiBaskets = [];

  List<News> _news = [];
  List<Tweet> _tweets = [];
  List shuffledImages = [];

  User _userData;
  bool _isUserAuthenticated = false;

  Map userSettings = {
    'default_zone': 'in',
    'enable_biometric': "1",
    'force_password': '0',
    'allowed_zones': [],
  };

  bool registrationSetPasscode = false;
  bool loginVerifyPasscode = false;

  List userPortfolios = [];
  Map userPortfoliosByType = {};
  Map userPortfoliosByTypeTmp;

  Map userPortfoliosData = {};
  Map userPortfoliosDataTmp;

  String oldestInvestmentDate;

  String userRiskProfile;

  List newUserPortfolios = [];
  String newUserRiskProfile = "moderate";

  dynamic userPortfolioValue;
  dynamic userPortfolioGraph;
  dynamic portfolioTotalSummary;
  dynamic summaryLiveCount;
  List portfolioGraphData = [];

  //Map<String, dynamic> _userData;

  String hostName = "https://api.qfinr.com/api/";
  // String hostName = "https://www.qfinr.com/api/";

  //String hostName = "http://qfinr.local/api/";
  //String hostName = "http://uat.qfinr.com/api/";

  bool _isLoading = true;

  Map customerSettings;

  String defaultPortfolioSelectorKey = "";
  String defaultPortfolioSelectorValue = "";

  Map userSelectedPortfolios = {};

  Map addPortfolioData = {};

  List<Map<String, dynamic>> currencies = [
    // {'key': 'inr', 'value': 'INR'},
    // {'key': 'usd', 'value': 'USD'},
    // {'key': 'sgd', 'value': 'SGD'},
  ];

  List<Map<String, dynamic>> zoneList = [];

  String redirectBase = "/home_new";

  BasketResponse miBasketResponseMain;
}

class UtilityModel extends ConnectedModel {
  String pdfLink = "";
  String pdfIdentifier = "";

  String portfolioIdentifier = "";

  List<Map<String, dynamic>> zoneBenchmarks = [];

  bool get isLoading {
    return _isLoading;
  }

  void setLoaderTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setLoader(bool status) {
    _isLoading = status;
    notifyListeners();
  }

  Future getBanks(key) async {
    String url = hostName +
        'utility/getBanks?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&bank_name=' +
        key;

    // http.Response response;
    // response = await http.get(Uri.parse(url));
    // final Map<String, dynamic> responseData = json.decode(response.body);
    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    notifyListeners();
    return responseData;
  }

  Future validateIP(key) async {
    String url = hostName + 'utility/validateIP?ip_address=' + key;

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    notifyListeners();
    return responseData;
  }

  Future getAppVersion() async {
    String url = hostName + 'utility/appVersion';
    if (_isUserAuthenticated) {
      url =
          url + '?cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }
    return await MainModel().callHTTP(url: url);
  }

  Future getKeyStatsRange() async {
    String url = hostName + 'utility/keyStatsRange';
    return await MainModel().callHTTP(url: url);
  }

  Future getZoneBenchmarks() async {
    zoneBenchmarks.clear();
    zoneBenchmarks
        .add({"market": "No Benchmark", "zone": userSettings['default_zone']});
    String url = hostName + 'utility/getZoneBenchmarks';
    url = url + "?zone=" + userSettings['default_zone'];
    if (_isUserAuthenticated) {
      url =
          url + '&cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }

    Map<String, dynamic> response = await MainModel().callHTTP(url: url);
    for (var item in response['response']) {
      //zoneBenchmarks.add({item['market']: item});
      zoneBenchmarks.add(item);
    }
    notifyListeners();
  }

  List<News> get newsData {
    return List.from(_news);
  }

  Future fetchNews() async {
    _isLoading = true;
    notifyListeners();

    String url = "";
    if (userSettings['default_zone'] != "sg") {
      url = hostName + 'news/getNews?zone=' + userSettings['default_zone'];
      log.d(url);

      // Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

      http.get((Uri.parse(url))).then((http.Response response) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        _news.clear();
        responseData['response'].forEach((dynamic newsItem) {
          final News newsData = News(
            image: newsItem['image'],
            title: newsItem['title'],
            url: newsItem['news'],
            source: newsItem['source'],
            date_published: newsItem['date_published'],
          );
          _news.add(newsData);
        });
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  List<Tweet> get tweetData {
    return List.from(_tweets);
  }

  Future fetchTweets() async {
    _isLoading = true;
    notifyListeners();

    String url = "";
    url = hostName + 'news/getTwitter?zone=' + userSettings['default_zone'];
    log.d(url);

    http.get((Uri.parse(url))).then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      _tweets.clear();
      responseData['response'].forEach((dynamic tweetItem) {
        final Tweet tweetData = Tweet(
          tweet: tweetItem['tweet'],
          url: tweetItem['url'],
          date_published: tweetItem['date_published'],
        );
        _tweets.add(tweetData);
      });
      _isLoading = false;
      notifyListeners();
    });
  }

//[{key: usd, value: USD}, {key: inr, value: INR}, {key: sgd, value: SGD}, {key: gbp, value: GBP}]
  Future<List<Map<String, dynamic>>> getCurrencyList() async {
    String url = hostName + "utility/fetchCurrencies";
    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    List list = responseData['response'];
    List<Map<String, dynamic>> currencyList = [];
    list.forEach((element) {
      Map<String, dynamic> map = element as Map;
      currencyList.add(map);
    });
    currencies = currencyList;
    return currencies;
  }

  Future<Map<String, dynamic>> emailPDF(String email, String type) async {
    _isLoading = true;
    notifyListeners();

    String url = "";
    if (type == "planner") {
      url = hostName +
          'report/goalplanner/emailPDF?identifier=' +
          pdfIdentifier +
          '&email=' +
          email;
    } else if (type == "portfolio") {
      url = hostName +
          'portfolio/emailPDF?identifier=' +
          pdfIdentifier +
          '&email=' +
          email;
    }

    // http.Response response;
    // response = await http.get((Uri.parse(url)));
    // final Map<String, dynamic> responseData = json.decode(response.body);
    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    _isLoading = false;
    notifyListeners();

    return responseData;
  }

  Future<Map<String, dynamic>> goalPlanner(
      String type, Map userData, Map goalData) async {
    String goalDataValue;
    Map<String, dynamic> _userPostData = userData;

    if (type == "goal") {
      goalDataValue = "";
      goalDataValue += goalData['goal_name'] + "|";
      goalDataValue += goalData['start_year'] + "|";
      goalDataValue += goalData['goal_year'] + "|";
      goalDataValue += goalData['present_value'] + "|";
      goalDataValue += goalData['goal_inflation'] + "|";
      goalDataValue += goalData['amt_saved'] + "|";
      goalDataValue += goalData['annual_increment'];
    } else if (type == "retirement") {
      goalDataValue = "retirement|";
      goalDataValue += goalData['retirement_age'] + "|";
      goalDataValue += goalData['life_expectancy'] + "|";
      goalDataValue += goalData['salary_pm'] + "|";
      goalDataValue += goalData['annual_salary_increment'] + "|";
      goalDataValue += goalData['rentals_pm'] + "|";
      goalDataValue += goalData['otherincome_pm'] + "|";
      goalDataValue += goalData['living_expenses_pm'] + "|";
      goalDataValue += goalData['emi_expense'] + "|";
      goalDataValue += goalData['insurance_premium_expense_pm'] + "|";
      goalDataValue += goalData['annual_inflation'] + "|";
      goalDataValue += goalData['amt_saved'] + "|";
      goalDataValue += goalData['pf_rate'] + "|";
      goalDataValue += goalData['annual_inc'] + "|";
      goalDataValue += goalData['inital_annual_amt'] + "|";
      goalDataValue += goalData['annual_increase'] + "|";
      goalDataValue += goalData['value_other_lumpsum_at_retirement'] + "|";
      goalDataValue += goalData['legacy_amt'] + "|";
      goalDataValue += goalData['non_market_asset'];

      if (userSettings['default_zone'] == "sg") {
        goalDataValue += "|" + goalData['cpfSector'];
        goalDataValue += "|" + goalData['cpfCategory'];
        goalDataValue += "|" + goalData['cpfGrowth'];
      }
      try {
        _userPostData['retirementGoalData'] =
            json.encode(goalData['retirementGoal']);
      } catch (e) {}
    }

    _userPostData['goalData'] = goalDataValue;
    try {
      _userPostData['goalDataRaw'] = json.encode(goalData);
    } catch (e) {}

    log.d(_userPostData);
    _isLoading = true;
    notifyListeners();
    log.d('Loader status' + _isLoading.toString());

    String url = hostName + 'report/goalplanner/generateReport';
    if (_isUserAuthenticated) {
      url =
          url + '?cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;

      url = url + "&default_zone=" + userSettings['default_zone'];
    }
    // response = await http.post(Uri.parse(url), body: _userPostData);
    // final Map<String, dynamic> responseData = json.decode(response.body);

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: _userPostData);

    if (responseData['status']) {
      //pdfLink = responseData['response']['link'];
      //pdfIdentifier = responseData['response']['identifier'];
    }
    _isLoading = false;
    notifyListeners();
    return responseData;
  }

  Future pdfLinkResponse(String url) async {
    http.Response response;
    log.d('pdfLinkResponse: Getting response for: ' + url);
    response = await http.get(Uri.parse(url));
    bool statusCode;
    if (response.statusCode == 200) {
      statusCode = true;
    } else {
      statusCode = false;
    }
    log.d('pdfLinkResponse: HTTP Response: ' + response.statusCode.toString());
    notifyListeners();
    return statusCode;
  }

  Future<Map<String, dynamic>> riskProfiler(Map defaultValues) async {
    // log.d(defaultValues);
    Map<String, dynamic> postValues = {
      "question1": defaultValues['question1'].toString(),
      "question2": defaultValues['question2'].toString(),
      "question3": defaultValues['question3'].toString(),
      "question4": defaultValues['question4'].toString(),
      "question5": defaultValues['question5'].toString(),
      "question6": defaultValues['question6'].toString(),
      "question7": defaultValues['question7'].toString(),
      "question8": defaultValues['question8'].toString(),
      "question9": defaultValues['question9'].toString(),
      "question10": defaultValues['question10'].toString(),
      "question11": defaultValues['question11'].toString(),
      "question12": defaultValues['question12'].toString(),
      "question13": defaultValues['question13'].toString(),
      "question14": defaultValues['question14'].toString(),
      "question15": defaultValues['question15'].toString(),
      "question16": defaultValues['question16'].toString(),
      "question17": defaultValues['question17'].toString(),
      "default_zone": userSettings['default_zone'],
    };
    // log.d(postValues);
    // http.Response response;
    String url = hostName + 'riskprofiler/compute';
    if (_isUserAuthenticated) {
      url =
          url + '?cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    // response = await http.post(Uri.parse(url), body: postValues);
    // final Map<String, dynamic> responseData = json.decode(response.body);

    notifyListeners();
    return responseData;
  }

  Future<Map<String, dynamic>> updateRiskProfile(String riskProfile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> postValues = {
      "riskProfile": riskProfile,
    };

    // http.Response response;

    String url = hostName + 'riskprofiler/updateRiskProfile';

    if (_isUserAuthenticated) {
      url =
          url + '?cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    if (responseData['response'].containsKey('riskProfile')) {
      if (responseData['response']['riskProfile'] != false) {
        userRiskProfile = responseData['response']['riskProfile'];
      } else {
        userRiskProfile = null;
      }

      newUserRiskProfile = userRiskProfile;
      await prefs.setString('userRiskProfile', userRiskProfile);
    }

    notifyListeners();
    return responseData;
  }

  Future getFundName(String pattern, String getFunds,
      {bool include = false}) async {
    pattern = pattern.replaceAll("&", "::");

    String url = hostName + 'portfolio/getFundName?ric_wildcard=' + pattern;

    if (getFunds == "fund") {
      url = url + "&type=Funds";
    } else if (getFunds == "stock") {
      url = url + "&type=Stocks";
    } else {
      url = url + "&type=" + getFunds;
    }

    if (include == true) {
      url = url + "&include=true";
    }

    if (_isUserAuthenticated) {
      url =
          url + '&cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }

    //url = url + "&default_zone=" + userSettings['default_zone'];

    log.d(url);

    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    notifyListeners();
    return responseData['response'];
  }

  Future fundScreener(Map filterData) async {
    String url = hostName + 'portfolio/fundScreener';
    url = url + '?cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    var _filterdata;
    try {
      _filterdata = json.encode(filterData);
    } catch (e) {}
    Map<String, dynamic> postValues = {
      "filterData": _filterdata,
    };
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    notifyListeners();
    return responseData;
  }

  Future getFormData(String formName) async {
    // http.Response response;
    String url = hostName +
        'customer/getCustomerFormData?form_name=' +
        formName +
        '&cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;
    // log.d(url);
    // response = await http.get(Uri.parse(url));
    // final Map<String, dynamic> responseData = json.decode(response.body);

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    notifyListeners();
    return responseData;
  }

  Future<Map<String, dynamic>> analyzerPortfolio(
      Map userData, Map portfolios) async {
    Map<String, dynamic> postValues = {
      "riskProfile": userData['risk_profile'],
      "benchmark": userData['benchmark'],
      "portfolioSelected": json.encode(portfolios),
      "updateByMulti": "true",
      //"portfolioSelected": json.encode(userSelectedPortfolios)
    };

    // log.d('postValues');
    // log.d(postValues);

    String url = hostName + 'portfolio/portfolioAnalyzer';
    url = url + "?default_zone=" + userSettings['default_zone'];
    if (_isUserAuthenticated) {
      url =
          url + '&cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    if (responseData['status']) {
      // log.d(responseData['response']);
      pdfIdentifier = responseData['response']['identifier'];
    }

    notifyListeners();
    return responseData;
  }

  Future<Map<String, dynamic>> portfolioStressTest(Map portfolios) async {
    var _portfolios = '';
    try {
      _portfolios = json.encode(portfolios);
    } catch (e) {}

    Map<String, dynamic> postValues = {
      "portfolioSelected": _portfolios,
    };

    String url = hostName +
        "portfolio/stressTestAnalyzer?default_zone=" +
        userSettings['default_zone'];
    if (_isUserAuthenticated) {
      url =
          url + '&cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    notifyListeners();
    return responseData;
  }

  Future<Map<String, dynamic>> knowYourPortfolio(Map portfolios) async {
    //log.d(portfolio);

    Map<String, dynamic> postValues = {
      "portfolio": json.encode(portfolios),
      "updateByType": "false",
      "updateByMulti": "false",
      "portfolioSelected": json.encode(userSelectedPortfolios)
    };

    // log.d(postValues);

    String url = hostName + 'portfolio/knowFundNew';
    url = url + "?default_zone=" + userSettings['default_zone'];
    if (_isUserAuthenticated) {
      url =
          url + '&cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    if (responseData['status']) {
      pdfIdentifier = responseData['response']['identifier'];
    }

    notifyListeners();
    return responseData;
  }

  Future<Map<String, dynamic>> dividendPortfolio(Map portfolios) async {
    Map<String, dynamic> postValues = {
      /* "portfolio": json.encode(portfolios), */
      //"riskProfile":userData['risk_profile'],
      //"updateByMulti": "true",
      "portfolioSelected": json.encode(portfolios)
    };

    //String url = hostName + 'portfolio/dividend';
    String url = hostName + 'portfolio/cashflow';
    url = url + "?zone=" + userSettings['default_zone'];
    if (_isUserAuthenticated) {
      url =
          url + '&cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);
    if (responseData['status']) {
      log.d(responseData['response']);
    }

    notifyListeners();
    return responseData;
  }

  Future fetchFundInfo(String ric) async {
    Map<String, dynamic> postValues = {"ric": ric};

    log.d(postValues);
    String url = hostName +
        'portfolio/getFundInfo?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    // log.d(responseData);

    notifyListeners();
    return responseData;
  }

  Future fetchPortfolioChart(String portfolioMasterID) async {
    Map<String, dynamic> postValues = {"portfolioMasterID": portfolioMasterID};
    String url = hostName +
        'portfolio/portfolioChart?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    notifyListeners();
    return responseData;
  }

  Future getProviders() async {
    String url = hostName +
        'PortfolioImport/getProviders?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    notifyListeners();
    return responseData;
  }

  Future getCustomerSettings({Map userModelData}) async {
    String url = "";
    if (userModelData != null) {
      url = hostName +
          'customer/getCustomerSettings?cust_id=' +
          (userModelData['custID'] ?? '') +
          '&api_key=' +
          (userModelData['apiKey'] ?? '');
    } else {
      url = hostName +
          'customer/getCustomerSettings?cust_id=' +
          (_userData.custID ?? '') +
          '&api_key=' +
          (_userData.apiKey ?? '');
    }

    // http.Response response;
    // log.d(url);
    // response = await http.get(Uri.parse(url));
    // //final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final Map<String, dynamic> responseData = json.decode(response.body);

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    if ((responseData['status'] ?? false)) {
      setCustomerSettings(responseData['response']);
    }
    notifyListeners();
    return responseData['response'];
  }

  Future updateCustomerSettings(Map customerSettings) async {
    /*final SharedPreferences prefs = await SharedPreferences.getInstance();
		if(customerSettings.containsKey('default_zone')){
			userSettings['default_zone'] = customerSettings['default_zone'];
			prefs.setString('default_zone', userSettings['default_zone']);
		}
		if(customerSettings.containsKey('enable_biometric')){
			userSettings['enable_biometric'] = customerSettings['enable_biometric'];
			prefs.setString('enable_biometric', userSettings['enable_biometric'].toString());
		} */
    notifyListeners();
    if (_isUserAuthenticated) {
      // http.Response response;
      String url = hostName +
          'customer/updateCustomerSettings?cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey;

      Map<String, dynamic> postValues = {
        "customerSettings": json.encode(customerSettings),
      };

      final Map<String, dynamic> responseData = await MainModel()
          .callHTTP(url: url, postData: true, postDataValues: postValues);

      // response = await http.post(Uri.parse(url), body: postValues);
      // final Map<String, dynamic> responseData = json.decode(response.body);

      setCustomerSettings(responseData['response']);

      notifyListeners();
      return responseData; // responseData;
    } else {
      /* if(customerSettings.containsKey('default_zone')){
				userSettings['default_zone'] = customerSettings['default_zone'];
				final SharedPreferences prefs = await SharedPreferences.getInstance();
				prefs.setString('default_zone', userSettings['default_zone']);
				notifyListeners();

				return true;
			} */
    }
  }

  Future setCustomerSettings(Map newUserSettings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userSettings = newUserSettings;
    try {
      try {
        await prefs.setString('settings', json.encode(newUserSettings));
      } catch (e) {
        log.e(
            'SharedPreferences setCustomerSettings-settings:  ' + e.toString());
      }

      if (userSettings.containsKey('default_zone')) {
        await prefs.setString('default_zone', userSettings['default_zone']);
      }

      if (userSettings.containsKey('allowed_zones')) {
        try {
          await prefs.setString(
              'allowed_zones', json.encode(userSettings['allowed_zones']));
        } catch (e) {
          log.e('SharedPreferences setCustomerSettings-allowed_zones:  ' +
              e.toString());
        }
      }

      if (userSettings.containsKey('enable_biometric')) {
        await prefs.setString(
            'enable_biometric', userSettings['enable_biometric']?.toString());
      }
    } catch (e) {
      log.e('SharedPreferences setCustomerSettings: ' + e.toString());
    }

    notifyListeners();
  }

  String currencyFormat(String value) {
    String currencySymbol = "₹";
    if (userSettings['default_zone'] == "us") {
      currencySymbol = "\$";
    } else if (userSettings['default_zone'] == "sg") {
      currencySymbol = "S\$";
    }

    return currencySymbol + value;
  }

  Future changeCurrency(String currency) async {
    if (_isUserAuthenticated) {
      // http.Response response;
      String url = hostName +
          'customer/changeCurrency?cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey;

      Map<String, dynamic> postValues = {
        "currency": currency,
      };
      final Map<String, dynamic> responseData = await MainModel()
          .callHTTP(url: url, postData: true, postDataValues: postValues);

      // response = await http.post(Uri.parse(url), body: postValues);
      // final Map<String, dynamic> responseData = json.decode(response.body);

      setCustomerSettings(responseData['response']);

      notifyListeners();
      return responseData;
    }
  }

  Future getStockList() async {
    String url = hostName + 'portfolio/getStockNames';
    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    // StocksResponse stocksResponse;
    if (responseData['status']) {
      return StocksResponse.fromJson(responseData);
    } else {
      return null;
    }
  }

  Future discover(postData) async {
    String url = hostName +
        'portfolio/discover?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;
    ;

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postData);

    StockIdeaResponse networkResponse =
        StockIdeaResponse.fromJson(responseData);
    if (networkResponse != null) {
      return networkResponse;
    } else {
      return null;
    }
  }
}

class User {
  final String custID;
  String custName;
  String custFirstName;
  String custLastName;
  final String emailID;
  final String fcmID;
  final String apiKey;
  String displayImage;

  User({
    @required this.custID,
    @required this.custName,
    @required this.custFirstName,
    @required this.custLastName,
    @required this.emailID,
    this.fcmID,
    @required this.apiKey,
    this.displayImage,
  });
}

class UserModel extends ConnectedModel {
  User get userData {
    return _userData;
  }

  bool get isUserAuthenticated {
    return _isUserAuthenticated;
  }

  void fetchOtherData() async {
    if (_userData == null) return;
    _isLoading = true;
    notifyListeners();
    await getCurrencyList();
    _isLoading = true;
    notifyListeners();
    await getCustomerNotifications();
    _isLoading = true;
    notifyListeners();
    await MIBasketModel().getMIBasket();
    _isLoading = true;
    notifyListeners();
    await getCustomerPortfolio();
    _isLoading = true;
    notifyListeners();
    await UtilityModel().getCustomerSettings(userModelData: {
      'custID': _userData?.custID,
      'apiKey': _userData?.apiKey
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getCurrencyList() async {
    String url = hostName + "utility/fetchCurrencies";
    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    List list = responseData['response'];
    List<Map<String, dynamic>> currencyList = [];
    list.forEach((element) {
      Map<String, dynamic> map = element as Map;
      currencyList.add(map);
    });
    currencies = currencyList;
    return currencies;
  }

  Future<void> getZoneList() async {
    _isLoading = true;
    notifyListeners();
    String url = hostName + "utility/fetchZones";
    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    List list = responseData['response'];
    List<Map<String, dynamic>> zones = [];
    list.forEach((element) {
      Map<String, dynamic> map = element as Map;
      zones.add(map);
    });
    zoneList = zones;
    _isLoading = false;
    notifyListeners();
  }

  void setSharedPrefUserData(var data) async {
    if (data == null ||
        data['id'] == null ||
        data['name'] == null ||
        data['first_name'] == null ||
        data['last_name'] == null ||
        data['email_id'] == null ||
        data['default_zone'] == null) {
      removeSharedPrefUserData();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('custID', data['id']);
    await prefs.setString('custName', data['name']);
    await prefs.setString('custFirstName', data['first_name']);
    await prefs.setString('custLastName', data['last_name']);
    await prefs.setString('emailID', data['email_id']);
    await prefs.setString('apiKey', data['api_key']);
    await prefs.setString('displayImage', data['displayImage']);
    await prefs.setString('default_zone', data['default_zone']);
    try {
      await prefs.setString(
          'allowed_zones', json.encode(data['allowed_zones']));
    } catch (e) {}
  }

  void removeSharedPrefUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    List<String> myPrefsKeys = [
      'custID',
      'custName',
      'apiKey',
      'allowed_zones',
      'userPortfolios',
      'userRiskProfile',
      'userNotifications'
    ];

    for (var i = 0; i < myPrefsKeys.length; i++) {
      if (prefs.containsKey(myPrefsKeys[i])) {
        await prefs.remove(myPrefsKeys[i]);
      }
    }
  }

  Future<Map<String, dynamic>> checkLogin(BuildContext context, String email,
      String password, String fcmToken) async {
    Map<String, dynamic> _userPostData = {
      'email_id': email,
      'password': password,
      'fcm_id': fcmToken
    };

    String url = hostName + 'customer/login';
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: _userPostData);

    // http.Response response;
    // response = await http.post(Uri.parse(hostName + 'customer/login'),
    //     body: _userPostData);
    // Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['status']) {
      var data = responseData['response'];
      setSharedPrefUserData(data);

      User user = User(
        custID: data['id'],
        custName: data['name'],
        custFirstName: data['first_name'],
        custLastName: data['last_name'],
        emailID: data['email_id'],
        apiKey: data['api_key'],
        fcmID: _userPostData['fcm_id'],
        displayImage: data['displayImage'],
      );

      userSettings['default_zone'] = data['default_zone'];
      userSettings['allowed_zones'] = data['allowed_zones'];

      // @Todo remove above user settings code
      UtilityModel().setCustomerSettings(data['settings']);

      _userData = user;
      _isUserAuthenticated = true;
      await getCurrencyList();
      await getCustomerPortfolio();
    }
    return responseData;
  }

  Future<Map<String, dynamic>> verifyEmail(
      BuildContext context, String email) async {
    Map<String, dynamic> _userPostData = {
      'email_id': email,
    };
    Map<String, dynamic> response = await MainModel().callHTTP(
        url: hostName + 'customer/verifyEmail',
        postData: true,
        postDataValues: _userPostData);

    if (response['status']) {
      User user = User(
        custID: response['response']['id'],
        custName: response['response']['name'],
        custFirstName: response['response']['first_name'],
        custLastName: response['response']['last_name'],
        emailID: response['response']['email_id'],
        apiKey: "",
        /*fcmID: _userPostData['fcm_id'], */
        displayImage: response['response']['displayImage'],
      );
      _isUserAuthenticated = true;
      _userData = user;
      // log.d('debug main model 762');
      // log.d(_userData.custID);
    }
    return response;
  }

  Future<Map<String, dynamic>> verifyPasscode(BuildContext context,
      String emailID, String passcode, String fcmToken) async {
    Map<String, dynamic> _userPostData = {
      'email_id': emailID,
      'passcode': passcode,
      'fcm_id': fcmToken
    };
    String url = hostName + 'customer/verifyPasscode';

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: _userPostData);

    // log.d("Testing_purpose-----------------------------verifyPasscode");
    // log.d(responseData);

    if (responseData['status']) {
      var data = responseData['response'];
      setSharedPrefUserData(data);
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('custID', responseData['response']['id']);
      // prefs.setString('custName', responseData['response']['name']);
      // prefs.setString('custFirstName', responseData['response']['first_name']);
      // prefs.setString('custLastName', responseData['response']['last_name']);
      // prefs.setString('emailID', responseData['response']['email_id']);
      // prefs.setString('apiKey', responseData['response']['api_key']);
      // prefs.setString('displayImage', responseData['response']['displayImage']);
      // prefs.setString('default_zone', responseData['response']['default_zone']);
      // prefs.setString('allowed_zones',
      //     json.encode(responseData['response']['allowed_zones']));

      userSettings['default_zone'] = data['default_zone'];
      userSettings['allowed_zones'] = data['allowed_zones'];

      // @Todo remove above user settings code
      UtilityModel().setCustomerSettings(data['settings']);

      User user = User(
        custID: data['id'],
        custName: data['name'],
        custFirstName: data['first_name'],
        custLastName: data['last_name'],
        emailID: data['email_id'],
        apiKey: data['api_key'],
        fcmID: _userPostData['fcm_id'],
        displayImage: data['displayImage'],
      );

      _userData = user;
      _isUserAuthenticated = true;
      await getCurrencyList();
      await getCustomerPortfolio();
    }
    return responseData;
  }

  Future<Map<String, dynamic>> setPasscode(
      BuildContext context, String passcode, String fcmToken) async {
    Map<String, dynamic> _userPostData = {
      'passcode': passcode,
      'fcm_id': fcmToken,
    };

    String url = hostName + 'customer/setPasscode';
    if (_isUserAuthenticated) {
      url =
          url + '?cust_id=' + _userData.custID + '&api_key=' + _userData.apiKey;
    }
    Map<String, dynamic> response = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: _userPostData);

    if (response['status']) {
      _isUserAuthenticated = true;
      await getCurrencyList();
      await getCustomerPortfolio();
    }
    return response;
  }

  Future<Map<String, dynamic>> forgotPassword(
      BuildContext context, String email) async {
    Map<String, dynamic> _userPostData = {
      'email_id': email,
    };

    String url = hostName + 'customer/forgotPassword';
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: _userPostData);

    // http.Response response;
    // response = await http.post(Uri.parse(hostName + 'customer/forgotPassword'),
    //     body: _userPostData);
    // Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['status']) {}
    return responseData;
  }

  Future<Map<String, dynamic>> register(Map userData, String fcmToken) async {
    // log.d('debug main model 838');

    Map<String, dynamic> _userPostData = {
      'fcm_id': fcmToken,
      'email_id': userData['email_id'],
      'first_name': userData['first_name'],
      'last_name': userData['last_name'],
      'country': userData['country'],
      'currency': userData['currency'],
      'mobile_number':
          userData['country_code'] + '-' + userData['mobile_number'],
      'passcode': userData['passcode'],
      'referral_code': userData['referral_code'],
    };

    Map<String, dynamic> responseData = await MainModel().callHTTP(
        url: hostName + 'customer/register',
        postData: true,
        postDataValues: _userPostData);

    if (responseData['status']) {
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('custID', (responseData['response']['id']).toString());
      // prefs.setString('custName', responseData['response']['name']);
      // prefs.setString('custFirstName', responseData['response']['first_name']);
      // prefs.setString('custLastName', responseData['response']['last_name']);
      // prefs.setString('emailID', responseData['response']['email_id']);
      // prefs.setString('apiKey', responseData['response']['api_key']);
      // prefs.setString('displayImage', responseData['response']['displayImage']);

      // prefs.setString('default_zone', responseData['response']['default_zone']);
      // prefs.setString('allowed_zones',
      //     json.encode(responseData['response']['allowed_zones']));
      setSharedPrefUserData(responseData['response']);

      userSettings['default_zone'] = responseData['response']['default_zone'];
      userSettings['allowed_zones'] = responseData['response']['allowed_zones'];

      // @Todo remove above user settings code
      UtilityModel().setCustomerSettings(responseData['response']['settings']);

      User user = User(
        custID: (responseData['response']['id']).toString(),
        custName: responseData['response']['name'],
        custFirstName: responseData['response']['first_name'],
        custLastName: responseData['response']['last_name'],
        emailID: responseData['response']['email_id'],
        apiKey: responseData['response']['api_key'],
        fcmID: _userPostData['fcm_id'],
        displayImage: responseData['response']['displayImage'],
      );

      // log.d('debug 934');
      // log.d(user.custFirstName);
      // log.d(responseData['response']);

      _userData = user;
      _isUserAuthenticated = true;
      await getCurrencyList();
      await getCustomerPortfolio();
    }
    return responseData;
  }

  Future<bool> autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiKey = prefs.getString('apiKey');
    userSettings['default_zone'] = prefs.getString('default_zone') ?? 'in';

    if (apiKey != null) {
      final String custID = await prefs.getString('custID') ?? '';
      final String custName = await prefs.getString('custName') ?? '';
      final String custFirstName = await prefs.getString('custFirstName') ?? '';
      final String custLastName = await prefs.getString('custLastName') ?? '';
      final String emailID = await prefs.getString('emailID') ?? '';
      final String displayImage = await prefs.getString('displayImage') ?? '';

      final String settings = await prefs.getString('userSettings') ?? '';
      final String allowedZones = await prefs.getString('allowed_zones') ?? '';
      final String portfolios = await prefs.getString('userPortfolios') ?? '';

      userRiskProfile = await prefs.getString('userRiskProfile') ?? '';

      User user = User(
        custID: custID,
        custName: custName,
        custFirstName: custFirstName,
        custLastName: custLastName,
        emailID: emailID,
        apiKey: apiKey,
        displayImage: displayImage,
      );

      _userData = user;
      _isUserAuthenticated = true;

      if (settings != '') {
        try {
          userSettings = json.decode(settings);
        } catch (e) {}
      }
      if (allowedZones != '') {
        try {
          userSettings['allowed_zones'] = json.decode(allowedZones);
        } catch (e) {}
      }
      if (portfolios != '') {
        try {
          userPortfolios = json.decode(portfolios);
        } catch (e) {}
      }

      newUserPortfolios = userPortfolios;
      newUserRiskProfile = userRiskProfile;

      await fetchOtherData();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future getRandomImages(List _items) async {
    shuffledImages = _items;
    return shuffledImages;
  }

  List get randomImages {
    return shuffledImages;
  }

  void logout() async {
    removeSharedPrefUserData();
    _userData = null;
    _isUserAuthenticated = false;
    userPortfolioValue = null;
    userPortfolioGraph = null;
    portfolioTotalSummary = null;
    summaryLiveCount = null;
  }

  Future getCustomerPortfolio() async {
    if (_userData == null) return;
    String url = hostName +
        'portfolio/getCustomerPortfolio?cust_id=' +
        _userData?.custID +
        '&api_key=' +
        _userData?.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    log.d("CHECKING_URL-----------$url");

    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    if (responseData['status'] == false) {
      logout();
    } else {
      setCustomerPortfolio(responseData);

      // log.d("responseData--------------------------------------$responseData");
    }

    return responseData;
  }

  Future getCustomerNotifications() async {
    String url = hostName +
        'customer/fetchNotification?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    // log.d("Cusromer_notification");
    // log.d(url);

    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map userNotifications = {};
    if (prefs.containsKey('userNotifications')) {
      var date = new DateTime.now();
      var newDate = new DateTime(date.year, date.month, date.day - 5);

      // check for 3 days older
      userNotifications = jsonDecode(prefs.get('userNotifications'));
      Map userNotifications2 = new Map.from(userNotifications);

      userNotifications2.forEach((key, value) {
        var notificationDate =
            DateFormat("yyyy-MM-dd hh:mm:ss").parse(value['date_added']);

        if (notificationDate.isBefore(newDate)) {
          userNotifications.remove(key);
        }
      });
      try {
        await prefs.setString(
            'userNotifications', jsonEncode(userNotifications));
      } catch (e) {}
    }

    if (responseData['status'] && responseData['response'].isNotEmpty) {
      // fetch existing
      Map responseFromServer = responseData['response'];
      responseFromServer.forEach((key, value) {
        if (userNotifications.containsKey(key)) {
          value["unread"] = userNotifications[key]["unread"];
        }
      });
      await prefs.setString(
          'userNotifications',
          jsonEncode({}
            ..addAll(userNotifications)
            ..addAll(responseFromServer)));
    }
  }

  Future getLocalNotification({makeRead = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('userNotifications')) {
      var notifications = jsonDecode(prefs.get('userNotifications'));

      if (makeRead) {
        notifications.forEach((k, e) {
          if (e['unread'] == true) {
            notifications[k]['unread'] = false;
          }
        });
        try {
          await prefs.setString('userNotifications', jsonEncode(notifications));
        } catch (e) {}
      }
      return notifications;
    } else {
      return {};
    }
  }

  Future generateSample() async {
    // http.Response response;
    String url = hostName +
        'portfolio/generateSample?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);
    return responseData;
  }

  Future sendFile(
      file, file_name, portfolio_name, provider_name, password) async {
    String header_url = hostName +
        'PortfolioImport/upload?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    var url = Uri.parse(header_url);
    var request = new http.MultipartRequest(
      "POST",
      url,
    );
    // Uint8List _bytesData =
    //     Base64Decoder().convert(file.toString().split(",").last);
    List<int> _selectedFile = file;

    request.headers['Content-Type'] = "application/octet-stream";
    request.fields['portfolio_name'] = portfolio_name;
    request.fields['provider'] = provider_name;
    request.fields['password'] = password;

    request.files.add(http.MultipartFile.fromBytes('portfolio', _selectedFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: file_name));

    var response = await request.send();

    final respStr = await response.stream.bytesToString();
    final body = json.decode(respStr);

    if (body['status'] == true) {
      await getCustomerPortfolio();
    }

    return body;
  }

  Future updateCustomerPortfolio({List portfolios, String riskProfile}) async {
    portfolios = newUserPortfolios;
    riskProfile = newUserRiskProfile;

    // http.Response response;
    String url = hostName +
        'portfolio/updateCustomerPortfolio?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    Map<String, dynamic> postValues = {
      "portfolio": json.encode(portfolios),
    };

    if (riskProfile != "" && riskProfile != null) {
      postValues['risk_profile'] = riskProfile;
    }

    final Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    // response = await http.post(Uri.parse(url), body: postValues);
    // final Map<String, dynamic> responseData = json.decode(response.body);

    setCustomerPortfolio(responseData);

    return true;
  }

  Future updateCustomerPortfolioByType(
      {Map portfolios, String riskProfile}) async {
    String url = hostName +
        'portfolio1/updateCustomerPortfolio?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    Map<String, dynamic> postValues = {
      "portfolio": json.encode(portfolios),
      'updateByType': "true",
    };
    if (riskProfile != "" && riskProfile != null) {
      postValues['risk_profile'] = riskProfile;
    }

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);
    setCustomerPortfolio(responseData);
    return responseData;
  }

  Future updateCustomerPortfolioData(
      {Map portfolios,
      String zone,
      String riskProfile,
      String portfolioMasterID,
      String portfolioName,
      bool depositPortfolio = false}) async {
    String url = hostName +
        'portfolio/updateCustomerPortfolioData?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    Map<String, dynamic> postValues = {
      'investmentType': depositPortfolio ? "deposit" : "",
      "portfolio_master_id": portfolioMasterID,
      "portfolio_name": portfolioName,
      "portfolio": json.encode(portfolios),
      "zone": depositPortfolio
          ? ""
          : zone != null
              ? zone
              : "false",
      'updateByType': "true",
    };

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    setCustomerPortfolio(responseData);

    notifyListeners();
    return responseData;
  }

  Future updateCustomerPortfolioDataDeposit(
      {Map portfolios, String portfolioMasterID, String portfolioName}) async {
    String url = hostName +
        'portfolio/updateCustomerPortfolioData?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    // log.d(url);
    Map<String, dynamic> postValues = {
      "portfolio_master_id": portfolioMasterID,
      "portfolio_name": portfolioName,
      "portfolio": json.encode(portfolios),
      'updateByType': "true",
      'investmentType': "deposit"
    };
    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    if (responseData['status'] == true) {
      setCustomerPortfolio(responseData);
    }
    notifyListeners();
    return responseData;
  }

  Future mergePortfolios({List portfolios, String portfolioName}) async {
    String url = hostName +
        'portfolio/mergePortfolios?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];
    // log.d('debug 1162');
    // log.d(json.encode(portfolios));
    Map<String, dynamic> postValues = {
      "portfolios": json.encode(portfolios),
      "portfolio_name": portfolioName
    };
    // log.d(postValues);

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    setCustomerPortfolio(responseData);

    return responseData;
  }

  Future insertPortfolioIdeas(
      {List portfolios, String portfolioName, DateTime rebalanceDate}) async {
    String url = hostName +
        'portfolio/insertPortfolioIdeas?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    Map<String, dynamic> postValues = {
      "portfolios": json.encode(portfolios),
      "portfolio_name": portfolioName,
      "rebalanceDate": dateString(rebalanceDate),
    };

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);
    setCustomerPortfolio(responseData);

    return responseData;
  }

  Future setDefaultPortfolios({List portfolios}) async {
    String url = hostName +
        'portfolio/setDefaultPortfolios?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    Map<String, dynamic> postValues = {
      "portfolios": json.encode(portfolios),
    };

    Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);
    setCustomerPortfolio(responseData);
    return responseData;
  }

  // Future notify() {
  //   notifyListeners();
  // }

  Future removePortfolioMaster(String portfolioMasterID) async {
    String url = hostName +
        'portfolio/removePortfolioMaster?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'] +
        "&portfolio_master_id=" +
        portfolioMasterID;
    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    setCustomerPortfolio(responseData);

    return responseData;
  }

  Future setPortfolioMasterDefault(String portfolioMasterID, int status) async {
    String url = hostName +
        'portfolio/setPortfolioMasterDefault?status=' +
        status.toString() +
        '&cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'] +
        "&portfolio_master_id=" +
        portfolioMasterID;
    // log.d(url);
    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    setCustomerPortfolio(responseData);

    return responseData;
  }

  Future updateCustomerProfile(Map customerData) async {
    // unset file from data
    Map userData = {
      'name': customerData['name'],
      'file': {
        'base64': customerData['file']['base64'],
        'fileName': customerData['file']['fileName'],
      }
    };
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // http.Response response;
    String url = hostName +
        'customer/updateProfile?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    Map<String, dynamic> postValues = {
      "customerData": json.encode(userData),
    };

    final Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);

    // log.d(url);
    // response = await http.post(Uri.parse(url), body: postValues);
    // final Map<String, dynamic> responseData = json.decode(response.body);

    // log.d(responseData);

    _userData.custName = responseData['response']['name'];
    _userData.displayImage = responseData['response']['displayImage'];
    await prefs.setString('custName', responseData['response']['name']);
    await prefs.setString(
        'displayImage', responseData['response']['displayImage']);

    notifyListeners();
    return responseData;
  }

  Future validateCustomerSession() async {
    String url = hostName +
        'customer/validateCustomerSession?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;
    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);
    notifyListeners();
    return responseData;
  }

  Future verifyPassword() async {
    _isLoading = true;
    String url = hostName +
        'customer/verifyPassword?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    // http.Response response;
    // response = await http.get(Uri.parse(url));
    // final Map<String, dynamic> responseData = json.decode(response.body);

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    _isLoading = false;
    notifyListeners();
    return responseData;
  }

  Future changePassword(Map postValues) async {
    String url = hostName +
        'customer/changePassword?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];

    // response = await http.post(Uri.parse(url), body: postValues);
    // final Map<String, dynamic> responseData = json.decode(response.body);

    final Map<String, dynamic> responseData = await MainModel()
        .callHTTP(url: url, postData: true, postDataValues: postValues);
    return responseData;
  }

  Future setCustomerPortfolio(Map responseData) async {
    if (!responseData.containsKey('response')) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (responseData['response'].containsKey('portfolio')) {
      //if(responseData['response']['portfolio'] != false){
      if (responseData['response']['portfolio'] != false) {
        userPortfolios = responseData['response']['portfolio'];
      } else {
        userPortfolios = [];
      }
      newUserPortfolios = userPortfolios;
      await prefs.setString('userPortfolios', json.encode(userPortfolios));
    }

    if (responseData['response'].containsKey('portfolioByType')) {
      if (responseData['response']['portfolioByType'] != null) {
        userPortfoliosByType = responseData['response']['portfolioByType'];
        userPortfoliosByTypeTmp = Map.from(userPortfoliosByType);
      }
    }

    if (responseData['response'].containsKey('portfolioData')) {
      if (responseData['response']['portfolioData'] != null) {
        userPortfoliosData = responseData['response']['portfolioData'];
        userPortfoliosDataTmp = Map.from(userPortfoliosData);
        oldestInvestmentDate =
            responseData['response']['portfolioValue']['oldestTransactionDate'];
      } else {
        userPortfoliosData = {};
        userPortfoliosDataTmp = Map.from(userPortfoliosData);
        oldestInvestmentDate = null;
      }
    }

    if (responseData['response'].containsKey('portfolioGraphData')) {
      if (responseData['response']['portfolioGraphData'] != false) {
        portfolioGraphData = responseData['response']['portfolioGraphData'];
      }
    }

    if (responseData['response'].containsKey('riskProfile')) {
      //if(responseData['response']['riskProfile'] != false){
      if (responseData['response']['riskProfile'] != false) {
        userRiskProfile = responseData['response']['riskProfile'];
      } else {
        userRiskProfile = null;
      }

      newUserRiskProfile = userRiskProfile;
      try {
        await prefs.setString('userRiskProfile', userRiskProfile);
      } catch (e) {}
    }

    if (responseData['response']['portfolioValue'] != "") {
      userPortfolioValue = responseData['response']['portfolioValue'];
    }

    if (responseData['response']['portfolioGraph'] != "") {
      userPortfolioGraph = responseData['response']['portfolioGraph'];
    }

    if (responseData['response']['summary'] != "") {
      portfolioTotalSummary = responseData['response']['summary'];
    }

    if (responseData['response']['summaryLiveCount'] != "") {
      summaryLiveCount = responseData['response']['summaryLiveCount'];
    }

    userPortfoliosData.forEach((key, value) {
      if (value['default'] == '1') {
        defaultPortfolioSelectorKey = key;
        defaultPortfolioSelectorValue = value['portfolio_name'];
      }
    });

    notifyListeners();
  }

  Future getBenchmarkPerformance() async {
    String url = hostName +
        'portfolio/getBenchmarkPerformance?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey +
        '&zone=' +
        userSettings['default_zone'];
    // log.d(url);
    log.d("getBenchmarkPerformance====================");

    // http.Response response;
    // response = await http.get(Uri.parse(url));
    // final Map<String, dynamic> responseData = json.decode(response.body);
    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    //setCustomerPortfolio(responseData);
    notifyListeners();
    return responseData;
  }

  Future getBenchmarkSelectors() async {
    String url = hostName +
        'utility/getBenchmarkSelectors?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    log.d("getBenchmarkSelectors====================");
    log.d(url);

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    log.d(responseData);
    //setCustomerPortfolio(responseData);
    notifyListeners();
    return responseData;
  }

  Future getAnalyseSummary() async {
    // String url = hostName +
    //   'portfolio/portfolioSummary?cust_id=' +
    //   '158' +
    //   '&api_key=' +
    //   '3a52db2261f37f81a1df52b02d7541f7';
    String url = hostName +
        'portfolio/portfolioSummary?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    log.d("getAnalyseSummary====================");
    log.d(url);

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);
    log.d(responseData);
    //setCustomerPortfolio(responseData);
    notifyListeners();
    return responseData;
  }

  // sharis created api for getIndicesPerformance
  Future getIndicesPerformance() async {
    String url = hostName +
        '/portfolio/getIndicesPerformance?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;
    Map<String, dynamic> responseData = await MainModel().callHTTP(
      url: url,
      postData: true,
    );
    log.d('getIndicesPerformance url: ${url} ||| response: ${responseData}');
    IndicesPerformance indicesPerformance;
    if (responseData['status']) {
      indicesPerformance = IndicesPerformance.fromJson(responseData);
      return indicesPerformance;
    } else {
      return null;
    }
  }

  Future getReferralCode() async {
    String url = hostName +
        'customer/getReferralCode?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    notifyListeners();
    return responseData;
  }

  Future getReferralHistory() async {
    String url = hostName +
        'customer/getReferralHistory?cust_id=' +
        _userData.custID +
        '&api_key=' +
        _userData.apiKey;

    final Map<String, dynamic> responseData =
        await MainModel().callHTTP(url: url);

    notifyListeners();
    return responseData;
  }
}

class Basket {
  final String basketID;
  final String basketName;
  final String slug;
  final String category;
  List<dynamic> subcategory;
  final String image;
  final String shortDescription;
  final String longDescription;
  DateTime rebalanceDate;
  final String sortOrder;
  final String status;
  bool isSubscribed;
  DateTime subscribedSince;
  List<dynamic> weightage;
  Map<String, dynamic> dateArray;
  Map<String, dynamic> stockBasketDetails;

  Basket({
    @required this.basketID,
    @required this.basketName,
    @required this.slug,
    this.category,
    this.subcategory,
    @required this.image,
    this.shortDescription,
    this.longDescription,
    this.rebalanceDate,
    this.sortOrder,
    this.status,
    this.isSubscribed,
    this.subscribedSince,
    this.weightage,
    this.dateArray,
    this.stockBasketDetails,
  });
}

class ShortlistedBasket {
  final String basketID;
  final String basketName;
  final String slug;
  final String category;
  final String image;
  final String shortDescription;
  bool isSubscribed;
  DateTime subscribedSince;
  int basketIndex;

  ShortlistedBasket({
    @required this.basketID,
    @required this.basketName,
    @required this.slug,
    this.category,
    @required this.image,
    this.shortDescription,
    this.isSubscribed,
    this.subscribedSince,
    this.basketIndex,
  });
}

class BasketModel extends ConnectedModel {
  List<Basket> get baskets {
    return List.from(_baskets);
  }

  List<ShortlistedBasket> get shortlistedBasket {
    return List.from(_shortlistedBaskets);
  }

  void loadBaskets(List responseBaskets) {
    this._baskets = responseBaskets;
  }

  Future fetchBaskets() async {
    _isLoading = true;
    notifyListeners();

    String language = await getLanguage();

    String url = "";
    if (_isUserAuthenticated) {
      url = hostName +
          'basket/getBaskets?zone=' +
          userSettings['default_zone'] +
          '&language=' +
          language +
          '&cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey;
    } else {
      url = hostName +
          'basket/getBaskets?zone=' +
          userSettings['default_zone'] +
          '&language=' +
          language;
    }

    // log.d(url);

    http.get((Uri.parse(url))).then((http.Response response) {
      final List<Basket> fetchedBasketList = [];
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<dynamic> basketListData = responseData['response'];
      basketListData.forEach((dynamic basketData) {
        /*log.d('-------- print basket start --------');
				log.d(basketData);
				log.d('-------- print basket end --------');*/

        Map<String, dynamic> stockBasketDetailsTmpMap = {};

        basketData['stockBasketDetails'].forEach((String key, dynamic value) {
          stockBasketDetailsTmpMap.addAll({key: value});
        });

        final Basket basket = Basket(
          basketID: basketData['id'],
          basketName: basketData['basket_name'],
          slug: basketData['slug'],
          category: basketData['category'],
          subcategory: basketData['subcategory'],
          shortDescription: basketData['short_description'],
          longDescription: basketData['long_description'],
          image: basketData['image'],
          rebalanceDate: DateTime.parse(basketData['rebalance_date']),
          sortOrder: basketData['sort_order'],
          status: basketData['status'],
          isSubscribed: basketData['isSubscribed'],
          subscribedSince: DateTime.parse(basketData['subscribedSince']),
          weightage: basketData['weightage'],
          dateArray: basketData['dateArray'],
          stockBasketDetails: stockBasketDetailsTmpMap,
        );

        /*basket.dateArray.forEach((String key, dynamic value){
				log.d('-------- print basket date start --------');
					log.d(key);
					log.d('----');
					log.d(value);
				log.d('-------- print basket date end --------');
				});*/
        fetchedBasketList.add(basket);
      });
      _baskets = fetchedBasketList;

      //_isLoading = false;
      notifyListeners();
    });
  }

  void subscribeBasket(int index) {
    String url;
    if (_isUserAuthenticated) {
      url = hostName +
          'basket/shortlistBasket?cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey +
          '&basket_id=' +
          _baskets[index].basketID;
    } else {
      url = hostName +
          'basket/shortlistBasket' +
          '&basket_id=' +
          _baskets[index].basketID;
    }
    log.d(url);

    http.get((Uri.parse(url))).then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        _baskets[index].isSubscribed = responseData['response']['subscribed'];
        _baskets[index].subscribedSince = DateTime.now();
        rebuildShortlistedList();
      } else {
        log.e('subscribeBasket: error');
      }
      notifyListeners();
    });
  }

  void rebuildShortlistedList() {
    final List<ShortlistedBasket> fetchedBasketList = [];
    for (var i = 0; i < _baskets.length; i++) {
      if (_baskets[i].isSubscribed) {
        Basket basketData = _baskets[i];
        // log.d(basketData.subscribedSince);
        final ShortlistedBasket shortlistedBasket = ShortlistedBasket(
          basketID: basketData.basketID,
          basketName: basketData.basketName,
          slug: basketData.slug,
          category: basketData.category,
          shortDescription: basketData.shortDescription,
          image: basketData.image,
          basketIndex: i,
          isSubscribed: true,
          subscribedSince: basketData.subscribedSince,
        );
        fetchedBasketList.add(shortlistedBasket);
      }
    }
    _shortlistedBaskets = fetchedBasketList;
  }
}

// ***************** mutual fund model
class MFBasket {
  final String basketID;
  final String basketName;
  final String slug;
  final String category;
  List<dynamic> subcategory;
  final String image;
  final String shortDescription;
  final String longDescription;
  final String sortOrder;
  final String status;
  bool isSubscribed;
  DateTime subscribedSince;
  List<dynamic> weightage;
  Map<String, dynamic> dateArray;
  Map<String, dynamic> mfBasketDetails;

  MFBasket({
    @required this.basketID,
    @required this.basketName,
    @required this.slug,
    this.category,
    this.subcategory,
    @required this.image,
    this.shortDescription,
    this.longDescription,
    this.sortOrder,
    this.status,
    this.isSubscribed,
    this.subscribedSince,
    this.weightage,
    this.dateArray,
    this.mfBasketDetails,
  });
}

class ShortlistedMFBasket {
  final String basketID;
  final String basketName;
  final String slug;
  final String category;
  final String image;
  final String shortDescription;
  bool isSubscribed;
  DateTime subscribedSince;
  int basketIndex;

  ShortlistedMFBasket({
    @required this.basketID,
    @required this.basketName,
    @required this.slug,
    this.category,
    @required this.image,
    this.shortDescription,
    this.isSubscribed,
    this.subscribedSince,
    this.basketIndex,
  });
}

class MFBasketModel extends ConnectedModel {
  List<MFBasket> get mfbaskets {
    return List.from(_mfbaskets);
  }

  List<ShortlistedMFBasket> get shortlistedmfBasket {
    return List.from(_shortlistedmfBaskets);
  }

  void loadMFBaskets(List responseBaskets) {
    this._mfbaskets = responseBaskets;
  }

  Future fetchMFBaskets() async {
    _isLoading = true;
    notifyListeners();

    String language = await getLanguage();

    String url = "";
    if (_isUserAuthenticated) {
      url = hostName +
          'mf/getBaskets?zone=' +
          userSettings['default_zone'] +
          '&language=' +
          language +
          '&cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey;
    } else {
      url = hostName +
          'mf/getBaskets?zone=' +
          userSettings['default_zone'] +
          '&language=' +
          language;
    }

    log.d(url);
    http.get((Uri.parse(url))).then((http.Response response) {
      final List<MFBasket> fetchedBasketList = [];
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<dynamic> basketListData = responseData['response'];
      basketListData.forEach((dynamic basketData) {
        /*log.d('-------- print basket start --------');
				log.d(basketData);
				log.d('-------- print basket end --------');*/

        Map<String, dynamic> stockBasketDetailsTmpMap = {};

        basketData['mfBasketDetails'].forEach((String key, dynamic value) {
          stockBasketDetailsTmpMap.addAll({key: value});
        });

        final MFBasket basket = MFBasket(
          basketID: basketData['id'],
          basketName: basketData['basket_name'],
          slug: basketData['slug'],
          category: basketData['category'],
          subcategory: basketData['subcategory'],
          shortDescription: basketData['short_description'],
          longDescription: basketData['long_description'],
          image: basketData['image'],
          sortOrder: basketData['sort_order'],
          status: basketData['status'],
          isSubscribed: basketData['isSubscribed'],
          subscribedSince: DateTime.parse(basketData['subscribedSince']),
          weightage: basketData['weightage'],
          dateArray: basketData['dateArray'],
          mfBasketDetails: stockBasketDetailsTmpMap,
        );

        /*basket.dateArray.forEach((String key, dynamic value){
				log.d('-------- print basket date start --------');
					log.d(key);
					log.d('----');
					log.d(value);
				log.d('-------- print basket date end --------');
				});*/
        fetchedBasketList.add(basket);
      });
      _mfbaskets = fetchedBasketList;
      notifyListeners();
    });
  }

  void fetchShortlistedMFBaskets() {
    rebuildShortlistedListMF();
  }

  void subscribeMFBasket(int index) {
    String url;
    if (_isUserAuthenticated) {
      url = hostName +
          'mf/shortlistBasket?cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey +
          '&basket_id=' +
          _mfbaskets[index].basketID;
    } else {
      url = hostName +
          'mf/shortlistBasket' +
          '&basket_id=' +
          _mfbaskets[index].basketID;
    }
    log.d(url);

    http.get((Uri.parse(url))).then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        _mfbaskets[index].isSubscribed = responseData['response']['subscribed'];
        _mfbaskets[index].subscribedSince = DateTime.now();
        rebuildShortlistedListMF();
      } else {
        log.e('subscribeMFBasket: error getting api data');
      }
      notifyListeners();
    });
  }

  void rebuildShortlistedListMF() {
    final List<ShortlistedMFBasket> fetchedBasketList = [];
    for (var i = 0; i < _mfbaskets.length; i++) {
      if (_mfbaskets[i].isSubscribed) {
        MFBasket basketData = _mfbaskets[i];
        // log.d(basketData.subscribedSince);
        final ShortlistedMFBasket shortlistedmfBasket = ShortlistedMFBasket(
          basketID: basketData.basketID,
          basketName: basketData.basketName,
          slug: basketData.slug,
          category: basketData.category,
          shortDescription: basketData.shortDescription,
          image: basketData.image,
          basketIndex: i,
          isSubscribed: true,
          subscribedSince: basketData.subscribedSince,
        );
        fetchedBasketList.add(shortlistedmfBasket);
      }
    }
    _shortlistedmfBaskets = fetchedBasketList;
  }
}

// ***************** market indicator model
class MIBasket {
  final String basketID;
  final String basketName;
  final String slug;
  final String category;
  List<dynamic> subcategory;
  final String image;
  final String shortDescription;
  final String longDescription;
  final String sortOrder;
  final String status;
  bool isSubscribed;
  DateTime subscribedSince;
  Map miBasketDetails;
  final String miBasketValue;
  List<dynamic> miGraphData;

  MIBasket(
      {@required this.basketID,
      @required this.basketName,
      @required this.slug,
      this.category,
      this.subcategory,
      @required this.image,
      this.shortDescription,
      this.longDescription,
      this.sortOrder,
      this.status,
      this.isSubscribed,
      this.subscribedSince,
      this.miBasketDetails,
      this.miBasketValue,
      this.miGraphData});
}

class ShortlistedMIBasket {
  final String basketID;
  final String basketName;
  final String slug;
  final String category;
  final String image;
  final String shortDescription;
  bool isSubscribed;
  DateTime subscribedSince;
  int basketIndex;

  ShortlistedMIBasket({
    @required this.basketID,
    @required this.basketName,
    @required this.slug,
    this.category,
    @required this.image,
    this.shortDescription,
    this.isSubscribed,
    this.subscribedSince,
    this.basketIndex,
  });
}

class MIBasketModel extends ConnectedModel {
  Future<bool> fetchMIBaskets(bool statusDelay) async {
    _isLoading = true;
    notifyListeners();

    String language = await getLanguage();

    String url = "";
    if (_isUserAuthenticated) {
      url = hostName +
          'mi/getBaskets?zone=' +
          userSettings['default_zone'] +
          '&language=' +
          language +
          '&cust_id=' +
          _userData.custID +
          '&api_key=' +
          _userData.apiKey;
    } else {
      url = hostName +
          'mi/getBaskets?zone=' +
          userSettings['default_zone'] +
          '&language=' +
          language;
    }

    log.d('fetchMIBaskets: ' + url);
    http.get((Uri.parse(url))).then((http.Response response) async {
      final List<MIBasket> fetchedBasketList = [];
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<dynamic> basketListData = responseData['response'];
      basketListData.forEach((dynamic basketData) {
        final MIBasket basket = MIBasket(
            basketID: basketData['id'],
            basketName: basketData['basket_name'],
            slug: basketData['slug'],
            category: basketData['category'],
            subcategory: basketData['subcategory'],
            shortDescription: basketData['short_description'],
            longDescription: basketData['long_description'],
            image: basketData['image'],
            sortOrder: basketData['sort_order'],
            status: basketData['status'],
            isSubscribed: basketData['isSubscribed'],
            subscribedSince: DateTime.parse(basketData['subscribedSince']),
            miBasketDetails: basketData['miBasketDetails'],
            //stockBasketDetailsTmpMap,
            miBasketValue: basketData['basketValue'],
            miGraphData: basketData['graphData']);

        fetchedBasketList.add(basket);
      });
      // _mibaskets = fetchedBasketList;

      if (statusDelay) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _isLoading = false;
      } else {
        _isLoading = false;
      }

      notifyListeners();
    });
    return true;
  }

  Future getMIBasket() async {
    String url = hostName + 'mi/getBaskets';
    log.d(url);
    Map<String, dynamic> responseData = await MainModel().callHTTP(url: url);

    BasketResponse basketResponse;
    if (responseData['status']) {
      basketResponse = BasketResponse.fromJson(responseData);
      basketResponse.response
          .removeWhere((element) => element.slug != "bull_market");

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        await prefs.setString('miBasketResponse', jsonEncode(basketResponse));
      } catch (e) {}
      return basketResponse;
    } else {
      return null;
    }
  }

  Future getLocalMIBaskets() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('miBasketResponse')) {
      BasketResponse miBasketResponse =
          BasketResponse.fromJson(jsonDecode(prefs.get('miBasketResponse')));

      return miBasketResponse;
    } else {
      return getMIBasket();
    }
  }
}

class News {
  final String title;
  final String source;
  final String url;
  final String date_published;
  final String image;

  News(
      {@required this.title,
      @required this.source,
      @required this.url,
      @required this.date_published,
      @required this.image});
}

class Tweet {
  final String tweet;
  final String url;
  final String date_published;

  Tweet({
    @required this.tweet,
    @required this.url,
    @required this.date_published,
  });
}

class RICs {
  final String ric;
  final String zone;
  final String fundType;
  final String name;
  final num latestPriceBase;
  final String latestPriceString;
  final String latestCurrencyPriceString;
  final String currency;

  RICs(
      {this.ric,
      this.zone,
      this.fundType,
      this.name,
      this.latestPriceBase,
      this.latestPriceString,
      this.latestCurrencyPriceString,
      this.currency});
}

class BasketResponse {
  bool status;
  List<BasketData> response;

  BasketResponse({this.status, this.response});

  BasketResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <BasketData>[];
      json['response'].forEach((v) {
        response.add(new BasketData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.response != null) {
      data['response'] = this.response.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BasketData {
  String id;
  String zone;
  String basketName;
  String slug;
  String category;
  List<String> subcategory;
  String image;
  String shortDescription;
  String longDescription;
  Null rebalanceDate;
  String sortOrder;
  String status;
  String basketNameEn;
  String categoryEn;
  String shortDescriptionEn;
  String longDescriptionEn;
  MiBasketDetails miBasketDetails;
  String basketValue;
  bool isSubscribed;
  String subscribedSince;

  BasketData(
      {this.id,
      this.zone,
      this.basketName,
      this.slug,
      this.category,
      this.subcategory,
      this.image,
      this.shortDescription,
      this.longDescription,
      this.rebalanceDate,
      this.sortOrder,
      this.status,
      this.basketNameEn,
      this.categoryEn,
      this.shortDescriptionEn,
      this.longDescriptionEn,
      this.miBasketDetails,
      this.basketValue,
      this.isSubscribed,
      this.subscribedSince});

  BasketData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    zone = json['zone'];
    basketName = json['basket_name'];
    slug = json['slug'];
    category = json['category'];
    subcategory = json['subcategory'].cast<String>();
    image = json['image'];
    shortDescription = json['short_description'];
    longDescription = json['long_description'];
    rebalanceDate = json['rebalance_date'];
    sortOrder = json['sort_order'];
    status = json['status'];
    basketNameEn = json['basket_name_en'];
    categoryEn = json['category_en'];
    shortDescriptionEn = json['short_description_en'];
    longDescriptionEn = json['long_description_en'];
    miBasketDetails = json['miBasketDetails'] != null
        ? new MiBasketDetails.fromJson(json['miBasketDetails'])
        : null;
    basketValue = json['basketValue'];
    isSubscribed = json['isSubscribed'];
    subscribedSince = json['subscribedSince'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['zone'] = this.zone;
    data['basket_name'] = this.basketName;
    data['slug'] = this.slug;
    data['category'] = this.category;
    data['subcategory'] = this.subcategory;
    data['image'] = this.image;
    data['short_description'] = this.shortDescription;
    data['long_description'] = this.longDescription;
    data['rebalance_date'] = this.rebalanceDate;
    data['sort_order'] = this.sortOrder;
    data['status'] = this.status;
    data['basket_name_en'] = this.basketNameEn;
    data['category_en'] = this.categoryEn;
    data['short_description_en'] = this.shortDescriptionEn;
    data['long_description_en'] = this.longDescriptionEn;
    if (this.miBasketDetails != null) {
      data['miBasketDetails'] = this.miBasketDetails.toJson();
    }
    data['basketValue'] = this.basketValue;
    data['isSubscribed'] = this.isSubscribed;
    data['subscribedSince'] = this.subscribedSince;
    return data;
  }
}

class MiBasketDetails {
  String value;
  String trend;
  String lastUpdated;
  WeeklyData weeklyData;

  MiBasketDetails({this.value, this.trend, this.lastUpdated, this.weeklyData});

  MiBasketDetails.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    trend = json['trend'] ?? null;
    lastUpdated = json['last_updated'];
    weeklyData = json['weeklyData'] != null
        ? new WeeklyData.fromJson(json['weeklyData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['trend'] = this.trend;
    data['last_updated'] = this.lastUpdated;
    if (this.weeklyData != null) {
      data['weeklyData'] = this.weeklyData.toJson();
    }
    return data;
  }
}

class WeeklyData {
  int mTotal;
  int mMax;
  num mPercent;
  int sTotal;
  int sMax;
  num sPercent;
  int bTotal;
  int bMax;
  num bPercent;

  WeeklyData(
      {this.mTotal,
      this.mMax,
      this.mPercent,
      this.sTotal,
      this.sMax,
      this.sPercent,
      this.bTotal,
      this.bMax,
      this.bPercent});

  WeeklyData.fromJson(Map<String, dynamic> json) {
    mTotal = json['MTotal'];
    mMax = json['MMax'];
    mPercent = json['MPercent'];
    sTotal = json['STotal'];
    sMax = json['SMax'];
    sPercent = json['SPercent'];
    bTotal = json['BTotal'];
    bMax = json['BMax'];
    bPercent = json['BPercent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MTotal'] = this.mTotal;
    data['MMax'] = this.mMax;
    data['MPercent'] = this.mPercent;
    data['STotal'] = this.sTotal;
    data['SMax'] = this.sMax;
    data['SPercent'] = this.sPercent;
    data['BTotal'] = this.bTotal;
    data['BMax'] = this.bMax;
    data['BPercent'] = this.bPercent;
    return data;
  }
}

class StocksResponse {
  bool status;
  List<StockData> response;

  StocksResponse({this.status, this.response});

  StocksResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <StockData>[];
      json['response'].forEach((v) {
        response.add(new StockData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.response != null) {
      data['response'] = this.response.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StockData {
  String ric;
  String name;
  String zone;
  String type;
  String core2;
  String cfCurr;
  Null benchmarkInstrumentRic;
  String trbcEconomicSector;

  StockData(
      {this.ric,
      this.name,
      this.zone,
      this.type,
      this.core2,
      this.cfCurr,
      this.benchmarkInstrumentRic,
      this.trbcEconomicSector});

  StockData.fromJson(Map<String, dynamic> json) {
    ric = json['ric'];
    name = json['name'];
    zone = json['zone'];
    type = json['type'];
    core2 = json['core2'];
    cfCurr = json['cf_curr'];
    //benchmarkInstrumentRic = json['benchmark_instrument_ric'] == null ? " " : json['benchmark_instrument_ric'];
    trbcEconomicSector = json['trbc_economic_sector'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ric'] = this.ric;
    data['name'] = this.name;
    data['zone'] = this.zone;
    data['type'] = this.type;
    data['core2'] = this.core2;
    data['cf_curr'] = this.cfCurr;
    //data['benchmark_instrument_ric'] = this.benchmarkInstrumentRic;
    data['trbc_economic_sector'] = this.trbcEconomicSector;
    return data;
  }
}

class Constants {
  static const String PLACE_HOLDER =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
}

class StockIdeaResponse {
  StockIdeaResponse({
    this.status,
    this.response,
  });

  bool status;
  StockIdeaData response;

  factory StockIdeaResponse.fromJson(Map<String, dynamic> json) =>
      StockIdeaResponse(
        status: json["status"],
        response: StockIdeaData.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response.toJson(),
      };
}

class StockIdeaData {
  StockIdeaData({
    this.cmd,
    this.latestPortfolioDate,
    this.portfolios,
    this.stats,
    this.graphData,
  });

  String cmd;
  DateTime latestPortfolioDate;
  Portfolios portfolios;
  Stats stats;
  List<GraphData> graphData;

  factory StockIdeaData.fromJson(Map<String, dynamic> json) {
    List<GraphData> data = [];
    var graph = json["graphData"];
    if (graph.keys.length > 0) {
      graph.forEach(
          (key, value) => data.add(GraphData(key, Nifty.fromJson(value))));
    }
    return StockIdeaData(
      cmd: json["cmd"],
      latestPortfolioDate: DateTime.parse(json["latestPortfolioDate"]),
      portfolios: Portfolios.fromJson(json["portfolios"]),
      stats: Stats.fromJson(json["stats"]),
      graphData: data,
    );
  }

  Map<String, dynamic> toJson() => {
        "cmd": cmd,
        "latestPortfolioDate":
            "${latestPortfolioDate.year.toString().padLeft(4, '0')}-${latestPortfolioDate.month.toString().padLeft(2, '0')}-${latestPortfolioDate.day.toString().padLeft(2, '0')}",
        "portfolios": portfolios.toJson(),
        "stats": stats.toJson(),
        "graphData": graphData.toString(),
      };
}

// class GraphData {
//   GraphData({
//     this.nifty100,
//     this.nifty200,
//     this.nifty50,
//     this.nifty500,
//   });
//
//   Nifty nifty100;
//   Nifty nifty200;
//   Nifty nifty50;
//   Nifty nifty500;
//
//   factory GraphData.fromJson(Map<String, dynamic> json) => GraphData(
//     nifty100: Nifty.fromJson(json["NIFTY100"]),
//     nifty200: Nifty.fromJson(json["NIFTY200"]),
//     nifty50: Nifty.fromJson(json["NIFTY50"]),
//     nifty500: Nifty.fromJson(json["NIFTY500"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "NIFTY100": nifty100.toJson(),
//     "NIFTY200": nifty200.toJson(),
//     "NIFTY50": nifty50.toJson(),
//     "NIFTY500": nifty500.toJson(),
//   };
// }

class GraphData {
  String marketName;
  Nifty stockData;

  GraphData(this.marketName, this.stockData);
}

class Nifty {
  List<YearOption> yearOption = [];

  Nifty({this.yearOption});

  factory Nifty.fromJson(Map<String, dynamic> json) {
    List<YearOption> temp = [];
    json.forEach((key, value) =>
        temp.add(YearOption(key, GraphDurationData.fromJson(value))));
    return Nifty(yearOption: temp);
  }
}

class YearOption {
  String key;
  GraphDurationData data;

  YearOption(this.key, this.data);
}

class GraphDurationData {
  GraphDurationData({
    this.minDate,
    this.maxDate,
    this.title,
    this.portfolioData,
    this.benchmarkData,
  });

  DateTime minDate;
  DateTime maxDate;
  Title title;
  List<List<double>> portfolioData;
  List<List<double>> benchmarkData;

  factory GraphDurationData.fromJson(Map<String, dynamic> json) =>
      GraphDurationData(
        minDate: DateTime.parse(json["minDate"]),
        maxDate: DateTime.parse(json["maxDate"]),
        title: titleValues.map[json["title"]],
        portfolioData: List<List<double>>.from(json["portfolioData"]
            .map((x) => List<double>.from(x.map((x) => x.toDouble())))),
        benchmarkData: List<List<double>>.from(json["benchmarkData"]
            .map((x) => List<double>.from(x.map((x) => x.toDouble())))),
      );

  Map<String, dynamic> toJson() => {
        "minDate":
            "${minDate.year.toString().padLeft(4, '0')}-${minDate.month.toString().padLeft(2, '0')}-${minDate.day.toString().padLeft(2, '0')}",
        "maxDate":
            "${maxDate.year.toString().padLeft(4, '0')}-${maxDate.month.toString().padLeft(2, '0')}-${maxDate.day.toString().padLeft(2, '0')}",
        "title": titleValues.reverse[title],
        "portfolioData": List<dynamic>.from(
            portfolioData.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "benchmarkData": List<dynamic>.from(
            benchmarkData.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}

enum Title { THE_1_YEAR_BACK, THE_3_YEAR_BACK, THE_6_MONTHS_BACK }

final titleValues = EnumValues({
  "1 Year back": Title.THE_1_YEAR_BACK,
  "3 Year back": Title.THE_3_YEAR_BACK,
  "6 Months back": Title.THE_6_MONTHS_BACK
});

class Portfolios {
  List<Ns> stockData;
  var showJson;

  Portfolios({this.showJson, this.stockData});

  factory Portfolios.fromJson(Map<String, dynamic> json) {
    List<Ns> tempStockData = [];
    if (json.isNotEmpty && json.keys.length > 0) {
      json.forEach((key, value) => tempStockData.add(Ns.fromJson(value)));
    }
    return Portfolios(showJson: json, stockData: tempStockData);
  }

  Map<String, dynamic> toJson() => showJson;
}

class Ns {
  Ns({
    this.ric,
    this.name,
    this.zone,
    this.weightage,
  });

  String ric;
  String name;
  String zone;
  num weightage;

  factory Ns.fromJson(Map<String, dynamic> json) => Ns(
        ric: json["ric"],
        name: json["name"],
        zone: json["zone"],
        weightage: json["weightage"],
      );

  Map<String, dynamic> toJson() => {
        "ric": ric,
        "name": name,
        "zone": zone,
        "weightage": weightage,
      };
}

class Stats {
  Stats({
    this.start,
    this.end,
    this.cagr,
    this.oneYear,
    this.totalReturn,
    this.dailySharpe,
    this.dailySortino,
    this.maxDrawdown,
    this.avgDrawdown,
    this.avgDrawdownDays,
    this.bestDay,
    this.bestMonth,
    this.bestYear,
    this.worstDay,
    this.worstMonth,
    this.worstYear,
    this.yearlyVol,
    this.calmar,
    this.twelveMonthWinPerc,
  });

  DateTime start;
  DateTime end;
  double cagr;
  double oneYear;
  double totalReturn;
  double dailySharpe;
  double dailySortino;
  double maxDrawdown;
  double avgDrawdown;
  double avgDrawdownDays;
  double bestDay;
  double bestMonth;
  double bestYear;
  double worstDay;
  double worstMonth;
  double worstYear;
  double yearlyVol;
  double calmar;
  double twelveMonthWinPerc;

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        cagr: json["cagr"].toDouble(),
        oneYear: json["one_year"].toDouble(),
        totalReturn: json["total_return"].toDouble(),
        dailySharpe: json["daily_sharpe"].toDouble(),
        dailySortino: json["daily_sortino"].toDouble(),
        maxDrawdown: json["max_drawdown"].toDouble(),
        avgDrawdown: json["avg_drawdown"].toDouble(),
        avgDrawdownDays: json["avg_drawdown_days"].toDouble(),
        bestDay: json["best_day"].toDouble(),
        bestMonth: json["best_month"].toDouble(),
        bestYear: json["best_year"].toDouble(),
        worstDay: json["worst_day"].toDouble(),
        worstMonth: json["worst_month"].toDouble(),
        worstYear: json["worst_year"].toDouble(),
        yearlyVol: json["yearly_vol"].toDouble(),
        calmar: json["calmar"].toDouble(),
        twelveMonthWinPerc: json["twelve_month_win_perc"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "start":
            "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}",
        "end":
            "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}",
        "cagr": cagr,
        "one_year": oneYear,
        "total_return": totalReturn,
        "daily_sharpe": dailySharpe,
        "daily_sortino": dailySortino,
        "max_drawdown": maxDrawdown,
        "avg_drawdown": avgDrawdown,
        "avg_drawdown_days": avgDrawdownDays,
        "best_day": bestDay,
        "best_month": bestMonth,
        "best_year": bestYear,
        "worst_day": worstDay,
        "worst_month": worstMonth,
        "worst_year": worstYear,
        "yearly_vol": yearlyVol,
        "calmar": calmar,
        "twelve_month_win_perc": twelveMonthWinPerc,
      };
}

// Sharis created IndicesPerformance Model starts here.....
class IndicesPerformance {
  IndicesPerformance({
    this.status,
    this.response,
  });

  bool status;
  IndicesPerformanceResponse response;

  factory IndicesPerformance.fromJson(Map<String, dynamic> json) =>
      IndicesPerformance(
        status: json["status"],
        response: IndicesPerformanceResponse.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response.toJson(),
      };
}

class IndicesPerformanceResponse {
  IndicesPerformanceResponse({
    this.indicesPreformanceMap,
    // this.nifty50,
    // this.nifty500,
    // this.gspc,
    // this.sti,
    // this.bse200,
  });

  Map<String, IndicesPerformanceData> indicesPreformanceMap;
  // IndicesPerformanceData nifty100;
  // IndicesPerformanceData nifty50;
  // IndicesPerformanceData nifty500;
  // IndicesPerformanceData gspc;
  // IndicesPerformanceData sti;
  // IndicesPerformanceData bse200;

  factory IndicesPerformanceResponse.fromJson(Map<String, dynamic> json) {
    Map<String, IndicesPerformanceData> map = Map();
    json.forEach((key, value) {
      map[key] = IndicesPerformanceData.fromJson(json[key]);
    });
    return IndicesPerformanceResponse(
      indicesPreformanceMap: map,
      // nifty100: IndicesPerformanceData.fromJson(json["NIFTY100"]),
      // nifty50: IndicesPerformanceData.fromJson(json["NIFTY50"]),
      // nifty500: IndicesPerformanceData.fromJson(json["NIFTY500"]),
      // gspc: IndicesPerformanceData.fromJson(json["GSPC"]),
      // sti: IndicesPerformanceData.fromJson(json["STI"]),
      // bse200: IndicesPerformanceData.fromJson(json["BSE200"]),
    );
  }

  Map<String, dynamic> toJson() => indicesPreformanceMap;
}

class IndicesPerformanceData {
  IndicesPerformanceData({
    this.benchmark,
    this.name,
    this.zone,
    this.data,
  });

  String benchmark;
  String name;
  String zone;
  Data data;

  factory IndicesPerformanceData.fromJson(Map<String, dynamic> json) =>
      IndicesPerformanceData(
        benchmark: json["benchmark"],
        name: json["name"],
        zone: json["zone"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "benchmark": benchmark,
        "name": name,
        "zone": zone,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    this.day,
    this.month,
    this.year,
  });

  Day day;
  Day month;
  Day year;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        day: Day.fromJson(json["day"]),
        month: Day.fromJson(json["month"]),
        year: Day.fromJson(json["year"]),
      );

  Map<String, dynamic> toJson() => {
        "day": day.toJson(),
        "month": month.toJson(),
        "year": year.toJson(),
      };
}

class Day {
  Day({
    this.value,
    this.oldValue,
    this.change,
    this.changeDifference,
    this.changeSign,
  });

  String value;
  String oldValue;
  String change;
  String changeDifference;
  ChangeSign changeSign;

  factory Day.fromJson(Map<String, dynamic> json) => Day(
        value: json["value"],
        oldValue: json["old_value"],
        change: json["change"],
        changeDifference: json["change_difference"].toString(),
        changeSign: changeSignValues.map[json["change_sign"]],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "old_value": oldValue,
        "change": change,
        "change_difference": changeDifference,
        "change_sign": changeSignValues.reverse[changeSign],
      };
}

enum ChangeSign { UP, DOWN }

final changeSignValues =
    EnumValues({"down": ChangeSign.DOWN, "up": ChangeSign.UP});

// Sharis created IndicesPerformanceModel ends here.....

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
