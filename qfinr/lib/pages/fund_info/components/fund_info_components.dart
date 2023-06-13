import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';

class FundInfoComponents {
  static void buildSelectBoxCustom({
    BuildContext context,
    String title,
    String value,
    List<Map<String, String>> options,
    Function onChangeFunction,
    String modelType = "bottomSheet",
  }) {
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 5,
          ),
          title: Text(
            'Select benchmark',
            style: selectBoxTitle,
          ),
          content: Column(
            children: _childrenOption,
          ),
        );
      },
    );
  }

  static void showPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildCloseButton(context),
          content: _whatIsThisAlert,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 5,
          ),
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

  static Widget _whatIsThisAlert = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Returns',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'The annualized 3 year returns using data as of the end of the preceding month',
        style: bodyText4,
      ),
      SizedBox(height: 5.0),
      Text(
        'Risks',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'The annualized volatility of monthly returns over 3 years as of the end of the preceding month',
        style: bodyText4,
      ),
      SizedBox(height: 5.0),
      Text(
        'Sensitivity',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'The beta computed from the regression of the monthly excess returns of the fund over risk free returns and the excess returns of the fund’s benchmark. We calculate the risk free rate from short term government bills.  It measures the volatility of the fund compared to the systematic risk of the chosen benchmark',
        style: bodyText4,
      ),
      SizedBox(height: 5.0),
      Text(
        'Maximum Loss',
        style: appBodyH3,
      ),
      Divider(
        height: 5,
        color: Colors.grey,
      ),
      Text(
        'The maximum observed loss from a peak to a trough, before a new peak is attained over the past 3 years using daily prices. Maximum drawdown is an indicator of downside risk over the time period',
        style: bodyText4,
      ),
    ],
  );
}
