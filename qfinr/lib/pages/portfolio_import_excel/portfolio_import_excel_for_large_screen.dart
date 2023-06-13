import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/painting/basic_types.dart' as axis;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qfinr/models/main_model.dart';
import 'package:qfinr/pages/portfolio_import_excel/portfolio_import_excel_style.dart';
import 'package:qfinr/pages/portfolio_import_excel/select_brokerage_widget.dart';
import 'package:qfinr/utils/constants.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:qfinr/utils/page_wrapper.dart';
import 'package:qfinr/widgets/navigation_bar.dart';
import 'package:qfinr/widgets/styles.dart';
import 'package:qfinr/widgets/widget_common.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

const _url = 'https://app.qfinr.com/sample/qfinr_portfolio_upload_sample.xlsx';
const _url_fd = 'https://app.qfinr.com/sample/fd2.xlsx';
final log = getLogger('PortfolioImportExcelForLargeScreen');

class PortfolioImportExcelForLargeScreen extends StatefulWidget {
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  PortfolioImportExcelForLargeScreen(this.model,
      {this.analytics, this.observer});

  @override
  _PortfolioImportExcelForLargeScreenState createState() =>
      _PortfolioImportExcelForLargeScreenState();
}

class _PortfolioImportExcelForLargeScreenState
    extends State<PortfolioImportExcelForLargeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _importForm = GlobalKey<FormState>();
  TextEditingController portfolioNameController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController uploadFileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String _selectedSource = "";
  List<String> sourceNames = [];
  List file_format;
  String password_required = "";
  String provider_name = "";
  String choose_format = ".xlsx, .xls, .csv";
  Uint8List uploadedImage;
  String file_name = "";
  var file_reader;
  List<String> provider_list = [];
  Map<dynamic, dynamic> _providersData;
  bool visible_name = false;
  bool visible_source = false;
  bool visible_file = false;
  bool visible_password = false;
  bool visible_validation_password = false;
  List<String> format_added = [];
  bool _isObscure = true;
  List<dynamic> failedRics = [];

  choosedFile() async {
    var fileFormatAllow =
        file_format.toString().substring(1, file_format.toString().length - 1);

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: fileFormatAllow.isNotEmpty
          ? [fileFormatAllow]
          : ['xlsx', 'xls', 'csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      file_reader = file.bytes;

      setState(() {
        uploadFileController.text = file.name;
        visible_file = false;
      });
    } else {
      // User canceled the picker
    }
  }

  Future uploadFile() async {
    setState(() {
      widget.model.setLoader(true);
    });

    final response = await widget.model.sendFile(
        file_reader,
        uploadFileController.text.toString(),
        portfolioNameController.text.toString(),
        provider_name,
        passwordController.text.toString());

    // final respStr = await response.stream.bytesToString();
    // final body = json.decode(respStr);

    if (response['status'] == true) {
      setState(() {
        widget.model.setLoader(false);
      });

      failedRics = response['failedRics'];
      if (failedRics.length > 0) {
        showSuccessPopUp(context, Contants.unableToImport, response['status']);
      } else {
        showSuccessPopUp(context, "success", response['status']);
      }
      // Navigator.pushReplacementNamed(context, '/manage_portfolio_master_view');

    } else if (response['status'] == false) {
      setState(() {
        widget.model.setLoader(false);
      });
      failedRics = response['failedRics'];

      log.d("failedRics");
      log.d(failedRics);

      showSuccessPopUp(
          context, response['message'].toString(), response['status']);
    }
  }

  void getProviders() async {
    _providersData = await widget.model.getProviders();

    log.d("_providersData");
    log.d(_providersData);

    _providersData['response'].forEach((key, value) {
      sourceNames.add(value['name']);
    });
  }

  void getFileFormat() {
    if (!file_format.isEmpty) {
      if (format_added.isNotEmpty) {
        format_added.clear();
      }
      for (int i = 0; i < file_format.length; i++) {
        var acceptable_format = file_format[i];
        format_added.add("." + acceptable_format);
      }

      var fileFormatDisplay = format_added
          .toString()
          .substring(1, format_added.toString().length - 1);

      setState(() {
        choose_format = fileFormatDisplay;
      });
    } else {
      setState(() {
        choose_format = ".xlsx, .xls, .csv";
      });
    }
  }

  List convert(String input) {
    List output;
    try {
      output = json.decode(input);
      return output;
    } catch (err) {
      return null;
    }
  }

  Future<Null> _anayticsCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'import_excel',
      screenClassOverride: 'import_excel',
    );
  }

  Future<Null> _analyticsAddEvent() async {
    await widget.analytics
        .logEvent(name: "page_change", parameters: <String, dynamic>{
      "pageName": "Import Excel Page",
    });
  }

  void initState() {
    getProviders();
    _analyticsAddEvent();
    _anayticsCurrentScreen();
    super.initState();
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

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return PageWrapper(
          child: Scaffold(
            bottomNavigationBar: _bottomBar(),
            key: _scaffoldKey,
            drawer: WidgetDrawer(),
            appBar: PreferredSize(
              // for larger & medium screen sizes
              preferredSize: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              child: NavigationTobBar(
                widget.model,
                openDrawer: () => _scaffoldKey.currentState.openDrawer(),
              ),
            ),
            body: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        leftNavBar(),
        widget.model.isLoading
            ? Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.0,
                  child: preLoader(),
                ),
              )
            : _bodyContent(),
      ],
    );
  }

  Widget _bottomBar() => Container(
        color: Colors.white,
        height: 47,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 22, top: 16, bottom: 14),
        alignment: Alignment.centerRight,
        child: Text(
          "Copyright 2021 Qfinr. All rights reserved",
          style: PortfolioImportExcelStyle.copyRightText,
        ),
      );

  Widget leftNavBar() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return deviceType == DeviceScreenType.tablet
        ? Container()
        : NavigationLeftBar(
            isSideMenuHeadingSelected: 1,
            isSideMenuSelected: 2,
          );
  }

  Widget _bodyContent() => Expanded(
        child: SingleChildScrollView(
          scrollDirection: axis.Axis.horizontal,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 50, left: 27, right: 59),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backToPortfolio(),
                  _title(),
                  _subTitle(),
                  _mainContent(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _backToPortfolio() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _backToPortfolioIcon(),
          _backToPortfolioText(),
        ],
      );

  Widget _backToPortfolioIcon() => GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Icon(
        Icons.keyboard_arrow_left,
        color: colorBlue,
        size: 12,
      ));

  Widget _backToPortfolioText() => GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(
              context, '/manage_portfolio_master_view');
          //  Navigator.pop(context);
        },
        behavior: HitTestBehavior.opaque,
        child: Text("Back to Portfolios",
            style: PortfolioImportExcelStyle.navigationTextLink),
      );

  Widget _title() => Container(
        margin: EdgeInsets.only(top: 25, bottom: 2),
        padding: EdgeInsets.all(0),
        child: Text("Add new Portfolio",
            style: PortfolioImportExcelStyle.headlineText),
      );

  Widget _subTitle() => Text(
        "Create a new portfolio by uploading an excel with all the holdings from your favourite broker, or via Qfinr template",
        style: PortfolioImportExcelStyle.subtitleStyle,
      );

  Widget _mainContent() => Container(
        margin: EdgeInsets.only(top: 21, right: 59, bottom: 460),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _uploadDetailsContainer(),
            _downloadSampleContainer(),
          ],
        ),
      );

  Widget _uploadDetailsContainer() => Container(
        decoration: PortfolioImportExcelStyle.uploadContainerBorderStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _uploadContainerTitle(),
            _divider(),
            _detailsInputContainer(),
          ],
        ),
      );

  Widget _downloadSampleContainer() => Container(
        width: getScaledValue(312),
        height: getScaledValue(312),
        // MediaQuery.of(context).size.width * 0.20,
        margin: EdgeInsets.only(left: 29, bottom: 0),
        padding: EdgeInsets.only(left: 30, top: 17, bottom: 0),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            _downloadSampleImage(),
            _downloadSampleSubtitle(),
            _downloadSampleBodyContent(),
            _downloadButton(),
            _downloadButtonFD(),
            _downloadPortflioImg()
          ],
        ),
        decoration: PortfolioImportExcelStyle.downloadSampleBorderStyle,
      );

  Widget _uploadContainerTitle() => Container(
        padding: EdgeInsets.only(top: 22, right: 100, left: 29, bottom: 14.5),
        child: Text(
          "Upload your holding statement from your broker or filled Qfinr template",
          style: headline6_analyse,
        ),
      );

  Widget _divider() => Divider(
        color: PortfolioImportExcelStyle.dividerColor,
        thickness: 1,
      );

  Widget _detailsInputContainer() {
    return Form(
        key: _importForm,
        child: Container(
          padding: EdgeInsets.only(top: 25, right: 100, left: 29, bottom: 41),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                portfolioNameLabel(),
                _portfolioNameInput(),
                Visibility(
                  visible: visible_name,
                  child: Text(
                    "Enter portfolio name",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                sourceNameLabel(),
                sourceNameList(),
                Visibility(
                  visible: visible_source,
                  child: Text(
                    "Select source name",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                uploadFileLabel(),
                uploadFileInput(),
                Visibility(
                  visible: visible_file,
                  child: Text("Choose the file",
                      style: TextStyle(color: Colors.red)),
                ),
                Visibility(visible: visible_password, child: passwordLabel()),
                Visibility(visible: visible_password, child: _passwordInput()),
                Visibility(
                  visible: visible_validation_password,
                  child: Text("Enter the password",
                      style: TextStyle(color: Colors.red)),
                ),
                uploadButton()
              ],
            ),
          ),
        ));
  }

  Widget portfolioNameLabel() => Container(
        margin: EdgeInsets.only(bottom: 4),
        child: Text(
          "Portfolio Name",
          style: PortfolioImportExcelStyle.labelStyle,
        ),
      );

  Widget _portfolioNameInput() => Container(
        //height: 47,
        width: MediaQuery.of(context).size.width * 0.37,
        child: TextFormField(
          cursorColor: Color(0xff383838),
          style: PortfolioImportExcelStyle.inputTextStyle,
          controller: portfolioNameController,
          focusNode: nameFocusNode,
          decoration: PortfolioImportExcelStyle.inputElementDecoration,
          // validator: (value) {
          //   if (value.isEmpty || value == 0) {
          //     return "Enter portfolio name";
          //   }
          //   return null;
          // },
          onChanged: (text) {
            setState(() {
              if (!text.toString().isEmpty) {
                visible_name = false;
              }
            });
          },
        ),
      );

  Widget sourceNameLabel() => Container(
        margin: EdgeInsets.only(bottom: 4, top: 26),
        child: Text(
          "Source Name",
          style: PortfolioImportExcelStyle.labelStyle,
        ),
      );

  Widget sourceNameList() {
    return GestureDetector(
      onTap: () {
        showBrokerListDialog();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.37,
        padding: EdgeInsets.only(
          top: 13,
          bottom: 13,
          right: 15,
          left: 15,
        ),
        decoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(
              color: PortfolioImportExcelStyle.inputBorderColor,
            ),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _selectedSource == "" ? "Select Source" : _selectedSource,
          style: PortfolioImportExcelStyle.selectSourceStyle,
        ),
      ),
    );
  }

  void showBrokerListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          content: SelectBrokerageWidget(_providersData, _selectedSecurity),
        );
      },
    );
  }

  void _selectedSecurity(String value) {
    setState(() {
      _selectedSource = value;
      _providersData['response'].forEach((key, value) {
        if (value['name'] == _selectedSource) {
          provider_name = key;

          file_format = value['acceptable_format'].toList();
          getFileFormat();

          if (value['password_required'] == true) {
            visible_password = true;
          } else {
            visible_password = false;
          }
        }
      });
      uploadFileController.text = "";
      visible_source = false;
    });
  }

  Widget uploadFileLabel() => Container(
        margin: EdgeInsets.only(bottom: 4, top: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Upload File",
              style: PortfolioImportExcelStyle.labelStyle,
            ),
            Text(
              "(" + choose_format + ")",
              style: PortfolioImportExcelStyle.subLabelStyle,
            ),
          ],
        ),
      );

  Widget uploadFileInput() => Container(
        // height: 47,
        width: MediaQuery.of(context).size.width * 0.37,
        child: TextFormField(
          style: PortfolioImportExcelStyle.inputTextStyle,
          controller: uploadFileController,
          focusNode: AlwaysDisabledFocusNode(),
          // validator: (value) {
          //   if (value.isEmpty || value == 0) {
          //     return "Choose the file";
          //   }
          //   return null;
          // },
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(top: 13, bottom: 12, right: 15, left: 15),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: PortfolioImportExcelStyle.inputBorderColor,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: PortfolioImportExcelStyle.inputBorderColor,
              ),
            ),
            hintText: "Select File…",
            suffixIcon: _chooseFileButton(),
          ),
        ),
      );

  Widget passwordLabel() => Container(
        margin: EdgeInsets.only(bottom: 4, top: 26),
        child: Text(
          "Password",
          style: PortfolioImportExcelStyle.labelStyle,
        ),
      );

  Widget _passwordInput() => Container(
        //height: 47,
        width: MediaQuery.of(context).size.width * 0.37,
        child: TextFormField(
          cursorColor: Color(0xff383838),
          style: PortfolioImportExcelStyle.inputTextStyle,
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: _isObscure,
          // decoration: PortfolioImportExcelStyle.inputElementDecoration,
          decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.only(top: 13, bottom: 12, right: 15, left: 15),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffe8e8e8),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Color(0xffe8e8e8),
                ),
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  })),

          // validator: (value) {
          //   if (value.isEmpty || value == 0) {
          //     return "Enter portfolio name";
          //   }
          //   return null;
          // },
          onChanged: (text) {
            setState(() {
              if (!text.toString().isEmpty) {
                visible_validation_password = false;
              }
            });
          },
        ),
      );

  Widget uploadButton() => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (portfolioNameController.text.isEmpty) {
              setState(() {
                visible_name = true;
              });
            }

            if (_selectedSource == null) {
              setState(() {
                visible_source = true;
              });
            }

            if (uploadFileController.text.isEmpty) {
              setState(() {
                visible_file = true;
              });
            }

            // if (visible_password == true) {
            //   if (passwordController.text.isEmpty) {
            //     setState(() {
            //       visible_validation_password = true;
            //     });
            //   }
            // }

            if (visible_password == true) {
              if (portfolioNameController.text.isNotEmpty &&
                  uploadFileController.text.isNotEmpty &&
                  _selectedSource != null) {
                uploadFile();
              }
            } else {
              if (portfolioNameController.text.isNotEmpty &&
                  uploadFileController.text.isNotEmpty &&
                  _selectedSource != null) {
                uploadFile();
              }
            }
          },
          child: Container(
            width: 238,
            height: 49,
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 30),
            decoration: PortfolioImportExcelStyle.updateButtonDecoration,
            child: Text(
              "UPLOAD FILE",
              style: PortfolioImportExcelStyle.uploadTextStyle,
            ),
          ),
        ),
      );

  Widget _chooseFileButton() => Container(
      margin: const EdgeInsets.all(8), child: textButton("Choose File"));

  Widget _downloadButton() => Positioned(
      top: 196,
      left: 3,
      child: Container(
        width: getScaledValue(165),
        child: textButton("Download Security"),
      ));

  Widget _downloadButtonFD() => Positioned(
      top: 240,
      left: 3,
      child: Container(
        width: getScaledValue(165),
        child: textButton("Download Fixed Deposit"),
      ));

  Widget textButton(String text) => TextButton(
        onPressed: () {
          if (text == "Choose File") {
            choosedFile();
          }
          if (text == "Download Security") {
            _launchURL();
          }

          if (text == "Download Fixed Deposit") {
            _launchURLFD();
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: PortfolioImportExcelStyle.textButtonColor,
          // padding: text == "Download Fixed Deposit"
          //     ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
          //     : const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: PortfolioImportExcelStyle.buttonShape,
        ),
        child: Text(
          text,
          style: PortfolioImportExcelStyle.buttonText,
          textAlign: TextAlign.center,
        ),
      );

  Widget _downloadSampleSubtitle() => Positioned(
        top: 82,
        child: Container(
          height: 48,
          margin: EdgeInsets.only(right: 18),
          child: Text("Don't have a holding \nstatement from your broker?",
              style: PortfolioImportExcelStyle.downloadContainerSubtitle),
        ),
      );

  Widget _downloadSampleBodyContent() => Positioned(
        top: 132,
        child: Container(
          margin: EdgeInsets.only(top: 14, right: 42),
          child: Text(
            "Download our qfinr template",
            style: PortfolioImportExcelStyle.downloadSampleBodyContent,
          ),
        ),
      );

  Widget _downloadPortflioImg() => Positioned(
        child: Image.asset(
          "assets/images/download_portfolio_sample.png",
          fit: BoxFit.fill,
        ),
        top: 190,
        right: 18,
      );

  Widget _downloadSampleImage() => Positioned(
        top: 0,
        right: 5,
        child: Container(
          width: 274,
          height: 90,
          child: Image.asset(
            "assets/images/download_sample.png",
            alignment: Alignment.topLeft,
            fit: BoxFit.fill,
          ),
        ),
      );

  void showSuccessPopUp(
      BuildContext context, String error_msg, bool status) async {
    showDialog(
      barrierDismissible: error_msg == 'success'
          ? false
          : status == true
              ? false
              : true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // title: Text(''),
          content: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: error_msg == 'success'
                    ? MainAxisAlignment.center
                    : status == true
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                crossAxisAlignment: error_msg == 'success'
                    ? CrossAxisAlignment.center
                    : status == true
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                children: [
                  error_msg == 'success'
                      ? successImageContainer()
                      : emptyWidget,
                  error_msg == 'success'
                      ? alertTitle(error_msg)
                      : status == true
                          ? alertTitleWithOutImport(error_msg)
                          : alertTitle(error_msg),
                  error_msg == 'success'
                      ? portfolioName()
                      : portfolioErrorMessage(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      viewPortfolioButton(error_msg, status),
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  Widget portfolioErrorMessage() {
    return Container(
      width: getScaledValue(400),
      height: getScaledValue(400), // Change as per your requirement
      // Change as per your requirement
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: failedRics.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.symmetric(
                vertical: getScaledValue(6), horizontal: getScaledValue(6)),
            child: Text(failedRics[index],
                textAlign: TextAlign.left,
                style: bodyText1.copyWith(
                    color: Color(0xff8e8e8e), fontSize: 14.0)),
          );
        },
      ),
    );
  }

  Widget successImageContainer() => Container(
        width: 87,
        height: 93,
        alignment: Alignment.center,
        child: Image(
            image: AssetImage("assets/animation/tickAnimation_white.gif")),
      );

  Widget alertTitle(String error_msg) => Text(
        error_msg == 'success' ? 'Successfully Created' : error_msg,
        style: headline1.copyWith(fontSize: 20),
        textAlign: TextAlign.center,
      );

  Widget alertTitleWithOutImport(String error_msg) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Contants.portfolioSuccessfully,
            style: headline1.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(
            error_msg,
            style: headline1.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          )
        ],
      );

  Widget portfolioName() => Container(
        margin: EdgeInsets.only(top: 7),
        child: Text(
          portfolioNameController.text.toString(),
          style: bodyText1.copyWith(color: Color(0xff8e8e8e), fontSize: 14.0),
          textAlign: TextAlign.center,
        ),
      );

  Widget viewPortfolioButton(String error_msg, bool status) => Container(
      margin: EdgeInsets.only(top: 25, left: 30, right: 30),
      width: 180,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(0.0),
        ),
        child: Ink(
          width: MediaQuery.of(context).size.width,
          height: 42,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0941cc), Color(0xff0055fe)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                minHeight: 42),
            alignment: Alignment.center,
            child: Text(
              error_msg == 'success'
                  ? "VIEW PORTFOLIO"
                  : status == true
                      ? "GO TO PORTFOLIO"
                      : "OK",
              style: buttonStyle.copyWith(fontSize: 9, letterSpacing: 2),
            ),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop(true);
          // error_msg == 'success'
          status == true
              ? Navigator.pushReplacementNamed(
                  context, '/manage_portfolio_master_view')
              : "";
        },
      ));

  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  void _launchURLFD() async => await canLaunch(_url_fd)
      ? await launch(_url_fd)
      : throw 'Could not launch $_url_fd';
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
