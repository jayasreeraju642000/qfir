import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';

class DiscoverStyles {
  static const Color backgroundColor = Color(0xFFf5f6fa);
  static const Color blueColor = Color(0xFF034bd9);
  static const Color dividerColor = Color(0xFFe9e9e9);

  static const String marketTodayContentText =
      'A quantitave indicator showing consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et';

  static const String knowYourAssetContentText =
      'Uncover deep insights and analysis on Mutual Funds, ETFs, stocks and bonds across multiple countries. Compare with benchmarks. Assess suitability for your portfolios';

  static const String searchText =
      'Search across stocks, bonds, mutual funds, ETFs, commodities from multiple countries. Use our smart search feature to make it fast.';

  static const String sortAndFilterText =
      'Shortlist assets using one or more criteria. Deep dive into those that fit your yardstick';

  static const TextStyle heading = TextStyle(
    color: Color(0xFF282828),
    fontSize: 32.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.bold,
    letterSpacing: 0.89,
  );

  static const TextStyle subHeading = TextStyle(
    color: Color(0xFF383838),
    fontSize: 18.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.bold,
    letterSpacing: 0.29,
  );

  static const TextStyle content = TextStyle(
    color: Color(0xFF979797),
    fontSize: 14.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );

  static const TextStyle howToCalculate = TextStyle(
    color: blueColor,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle discoverRowTextDark = TextStyle(
    fontSize: 12.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.w800,
    color: Color(0xFF272727),
  );

  static const TextStyle discoverRowTextLight = TextStyle(
    fontSize: 12.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.normal,
    color: Color(0xFF707070),
  );

  static const TextStyle discoverRowTextRed = TextStyle(
    fontSize: 12.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.normal,
    color: Color(0xFFc42f2f),
  );

  static const TextStyle discoverRowTextRed1 = TextStyle(
    fontSize: 12.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.bold,
    color: Color(0xFFc42f2f),
  );

  static const TextStyle discoverRowTextGreen = TextStyle(
    fontSize: 12.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.normal,
    color: Color(0xFF30c50c),
  );

  static const TextStyle discoverRowTextGreen1 = TextStyle(
    fontSize: 12.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.bold,
    color: Color(0xFF30c50c),
  );

  static const TextStyle discoverKnowAssetCard = TextStyle(
    fontSize: 16.0,
    fontFamily: 'nunito',
    fontWeight: FontWeight.w800,
    color: Color(0xFF383838),
  );

  static BoxDecoration marketContainerDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: Color(0xFFeeeeee),
    ),
  );

  static BoxDecoration buildBorder(bool val) {
    return BoxDecoration(
      border: Border(
        bottom: val
            ? BorderSide(
                color: DiscoverStyles.blueColor,
                width: 2.0,
              )
            : BorderSide.none,
      ),
    );
  }

  static Container buildDivider(double width) {
    return Container(
      color: dividerColor,
      width: width,
      height: 1.0,
    );
  }

  static const TextStyle graphTitle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xFF8e8e8e),
  );

  static const TextStyle portfolioSummaryZone = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'nunito',
    letterSpacing: 0.8,
    color: Color(0xFF272727),
  );

  static const TextStyle graphText1 = TextStyle(
    fontSize: 9.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.56,
    color: Color(0xFFa7a7a7),
  );

  static const TextStyle trendText = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xFF383838),
  );

  static const TextStyle graphDataRowTitle = TextStyle(
    fontSize: 9.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.56,
    color: Color(0xFFa7a7a7),
  );

  static const TextStyle graphDataRowValue = TextStyle(
    fontSize: 9.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.56,
    color: Color(0xFFa7a7a7),
  );

  static const TextStyle graphDataRowSubTitle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'nunito',
    letterSpacing: 0.25,
    color: Color(0xFF000000),
  );

  static const TextStyle graphFooterAsOf = TextStyle(
    fontSize: 9.0,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.19,
    color: Color(0xFF8b8b8b),
  );

  static const TextStyle graphHowToCalculate = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'nunito',
    letterSpacing: 0.0,
    color: Color(0xFF034bd9),
  );

  static const TextStyle sortAndFilterConentTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w800,
    fontFamily: 'nunito',
    letterSpacing: 0.3,
    color: Color(0xFF383838),
  );

  static const TextStyle sortAndFilterContentDescription = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    fontFamily: 'nunito',
    letterSpacing: 0.22,
    color: Color(0xFF8e8e8e),
  );

  static void showPopUp(BuildContext context, {bool isIconAlert}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildCloseButton(context),
          content: isIconAlert ? Container(
              width: MediaQuery.of(context).size.width * 0.3,
            child: _iconAlert,
          ) : Container(
              width: MediaQuery.of(context).size.width * 0.3,
            child: _howToCalculateAlert,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          scrollable: true,
          // insetPadding: EdgeInsets.symmetric(
          //   horizontal: MediaQuery.of(context).size.width / 5,
          // ),
        );
      },
    );
  }

  static Align _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(
          Icons.close,
          color: Color(0xffcccccc),
          size: 18.0,
        ),
      ),
    );
  }

  static Widget _iconAlert = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Overall Sentiment',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'A quantitative indicator showing the market sentiment ranging from Bearish to Euphoria. We compute this indicator looking at a number of factors that reflect sentiment\n\nEach numbered bar represents the following sentiment:\n1: Bearish\n2: Negative\n3: Neutral\n4: Bullish\n5: Strongly Bullish\n6. Overheated\n7: Exuberant',
        style: bodyText4,
      ),
    ],
  );

  static Widget _howToCalculateAlert = 
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
       Text(
        'Momentum Indicator',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'Shows the market uptrend momentum as a score from 0 (low momentum) to 100 (high momentum), where 100 implies all stocks in the Nifty500 are showing strong upward momentum',
        style: bodyText4,
      ),
      SizedBox(height: 5.0),
      Text(
        'Trend Indicator',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'Shows the trend in the market calculated as the percentage of stocks in the Nifty500 that are trading above their 200 day moving average. The indicator ranges from 0 (weak trend) to 100 (strong trend), where 0 means that all the Nifty500 stocks are trading below their respective 200 day moving average',
        style: bodyText4,
      ),
      SizedBox(height: 5.0),
      Text(
        'Volatility Indicator',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'Shows the riskiness in the market. We measure the deviation of the current prices against the respective 20 day moving average. The indicator ranges from 0 (lower risk) to 100 (higher risk), where 100 means that the prices of all stocks in the Nifty500 are more than 2 standard deviations away from their 20 day moving average',
        style: bodyText4,
      ),
    ],
  );
  
}
