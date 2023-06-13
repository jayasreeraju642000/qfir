import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectBrokerageWidget extends StatefulWidget {
  final Map<dynamic, dynamic> providersData;
  final Function onChanged;

  SelectBrokerageWidget(this.providersData, this.onChanged);

  @override
  State<StatefulWidget> createState() {
    return _SelectBrokerageWidget();
  }
}

class _SelectBrokerageWidget extends State<SelectBrokerageWidget> {
  List<String> _sourceListType = [];
  String _selectedSecurity;
  String _selectedBroker;

  @override
  void initState() {
    Set<String> uniqueTypeList = Set();
    widget.providersData['response'].forEach((key, value) {
      uniqueTypeList.add(value['type']);
    });
    _sourceListType.addAll(uniqueTypeList);
    _selectedBroker = _sourceListType[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Divider(
            height: 1,
          ),
          _body(),
          Divider(
            height: 1,
          ),
          _footer(),
        ],
      ),
    );
  }

  _header() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Source Name",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'nunito',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: Color(0xff383838),
            ),
          ),
          Text(
            "Shortlist assets using one or more criteria. Add those that fit your yardsticks.",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'nunito',
              fontWeight: FontWeight.normal,
              letterSpacing: 0.3,
              color: Color(0xff707070),
            ),
          ),
        ],
      ),
    );
  }

  _body() {
    return Expanded(
      child: Container(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _brokerList(),
            ),
            VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: _securityList(),
            ),
          ],
        ),
      ),
    );
  }

  _brokerList() {
    return Container(
      color: Color(0xFFFCFCFC),
      child: ListView.separated(
        itemCount: _sourceListType.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBroker = _sourceListType[index];
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _sourceListType[index],
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'nunito',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: Color(0xff383838),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(height: 1),
      ),
    );
  }

  _securityList() {
    List<String> securityList = [];
    widget.providersData['response'].forEach((key, value) {
      if (value["type"] == _selectedBroker) {
        securityList.add(value["name"]);
      }
    });
    return Container(
      child: ListView.builder(
        itemCount: securityList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSecurity = securityList[index];
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: securityList[index] == _selectedSecurity,
                    onChanged: (value) {
                      setState(() {
                        _selectedSecurity = securityList[index];
                      });
                    },
                    activeColor: Color(0xff034bd9),
                    checkColor: Color(0xffcedfff),
                    side: BorderSide(
                      color: Color(0xff034bd9),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                    tristate: false,
                  ),
                  Text(
                    securityList[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'nunito',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: Color(0xff383838),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _footer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.onChanged(_selectedSecurity);
              Navigator.pop(context);
            },
            child: Container(
              width: 150,
              height: 45,
              alignment: Alignment.center,
              margin: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0941cc), Color(0xff0055fe)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                "APPLY",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(3.0) < 9.0
                      ? 9.0
                      : ScreenUtil().setSp(3.0),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'nunito',
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
