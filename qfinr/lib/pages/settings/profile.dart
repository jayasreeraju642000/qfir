import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/main_model.dart';
import '../../widgets/widget_common.dart';

class SettingsProfilePage extends StatefulWidget {
  MainModel model;

  SettingsProfilePage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _SettingsProfilePageState();
  }
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  bool _loading = false;

  Map _userData = {"displayPicture": "1", "name": "", "file": {}};

  String _displayImageType = "";

  void initState() {
    super.initState();

    loadSettings();
  }

  Future loadSettings() async {
    if (widget.model.isUserAuthenticated) {
      setState(() {
        _loading = true;
      });

      _userData['name'] = widget.model.userData.custName;

      setState(() {
        _loading = false;
      });
    }
  }

  AppBar _startAppBarPage() {
    return AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, //,Colors.white, //Color(0xFFE7EDF8), //
        title: new Image.asset(
          'assets/images/logo_white.png',
          fit: BoxFit.fill,
          height: 25.0,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (_startAppBarPage()),
        body: Container(alignment: Alignment.center, child: _buildBody()));
  }

  Widget _buildBody() {
    if (_loading) {
      return preLoader();
    } else {
      return mainContainer(
        context: context,
        containerColor: Colors.white,
        paddingTop: 20.0,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _userDisplayPicture(),
                      SizedBox(
                        height: 10.0,
                      ),
                      (!kIsWeb ? _uploadImage() : emptyWidget),
                    ],
                  ),
                  _buildTextField(
                      context, "Name", 'name', '', _userData['name']),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(bottom: 20.0), child: _submitButton()),
          ],
        ),
      );
    }
  }

  Widget _userDisplayPicture() {
    setState(() {
      if (_userData['file'].containsKey('filepath')) {
        _displayImageType = "file";
      } else if (!widget.model.isUserAuthenticated ||
          (widget.model.isUserAuthenticated &&
              widget.model.userData.displayImage == 'noImage')) {
        _displayImageType = "name";
      } else {
        _displayImageType = "image";
      }
    });

    if (_displayImageType == "file") {
      return Container(
          width: 160.0,
          height: 160.0,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: FileImage(_userData['file']['filepath']))));
    } else if (_displayImageType == "name") {
      return Container(
        width: 160.0,
        height: 160.0,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          minRadius: 40.0,
          child: Text(widget.model.isUserAuthenticated
              ? widget.model.userData.custName.substring(0, 2).toUpperCase()
              : "G"),
        ),
      );
    } else if (_displayImageType == "image") {
      return Container(
          width: 160.0,
          height: 160.0,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(widget.model.userData.displayImage))));
    } else {
      Container();
    }
  }

  Widget _uploadImage() {
    return RaisedButton(
      padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(8.0)),
      textColor: Colors.white,
      child: widgetButtonTextSmall("Upload Image"),
      onPressed: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                  heightFactor: 0.3,
                  alignment: Alignment.center,
                  child: _cameraOptionModal());
            });
      },
    );
  }

  Widget _cameraOptionModal() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        iconGallery(Icons.photo_camera, 'Camera', 'camera'),
        iconGallery(Icons.insert_photo, 'Gallery', 'gallery'),
      ],
    );
  }

  Widget iconGallery(IconData icon, String text, String type) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
              icon: Icon(icon),
              iconSize: 64.0,
              alignment: Alignment.centerRight,
              onPressed: () {
                getImage(type);
              }),
          Text(text),
        ]);
  }

  void getImage(String type) async {
    var image;
    // if (type == "camera") {
    //   image = await ImagePicker.pickImage(source: ImageSource.camera);
    // } else if (type == "gallery") {
    //   image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // }
    setState(() {
      _userData['file'] = {
        'filepath': image,
        'base64': base64Encode(image.readAsBytesSync()),
        'fileName': image.path.split("/").last,
      };
      _displayImageType = "file";
    });
  }

  TextInputType keyboardType(type) {
    if (type == "number") {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  initialValue(val) {
    return TextEditingController(text: val);
  }

  Widget _buildTextField(BuildContext context, String labelText, String key,
      String type, String defaultValue,
      {String inputType,
      String suffix,
      bool fieldRequired = true,
      bool obscure = false}) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14.0,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 5.0,
        ),
        TextField(
          enabled: fieldRequired,
          obscureText: obscure,
          keyboardType: keyboardType(inputType),
          /* controller: initialValue(defaultValue), */
          decoration: InputDecoration(
            /* labelText: labelText, labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0), */
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: defaultValue,
            suffixText: suffix,
          ),

          /* obscureText: true, */

          onChanged: (String value) {
            setState(() {
              _userData[key] = value;
            });
          },
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
        ),
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _submitButton() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(90.0, 15.0, 90.0, 15.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          textColor: Colors.white,
          child: widgetButtonText("Submit"),
          onPressed: () async {
            setState(() {
              _loading = true;
            });
            Map responseData =
                await widget.model.updateCustomerProfile(_userData);
            if (responseData['status']) {
              setState(() {
                _displayImageType = "image";
              });
            }
            setState(() {
              _loading = false;
            });
          },
        ));
  }
}
