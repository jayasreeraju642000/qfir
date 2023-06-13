import 'dart:async';

import 'package:Install_Pay/slider_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      navigator();
    });
  }

  void navigator() {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => SliderScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.asset('assets/images/splash screen 1.jpg').image,
                fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}
