import 'package:Install_Pay/web_view_screen.dart';
import 'package:flutter/material.dart';

class SliderScreen extends StatefulWidget {
  @override
  _SliderScreenState createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  List<Widget> introPageWidgets = [
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset(
            'assets/images/splash screen 2.jpg',
          ).image,
          fit: BoxFit.fill,
        ),
      ),
    ),
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset(
            'assets/images/splash screen 3.jpg',
          ).image,
          fit: BoxFit.fill,
        ),
      ),
    ),
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset(
            'assets/images/splash screen 4.jpg',
          ).image,
          fit: BoxFit.fill,
        ),
      ),
    )
  ];
  int currentPageValue = 0;
  PageController controller = PageController();

  void changePageViewPostion(int whichPage) {
    if (controller != null) {
      whichPage = whichPage + 1;

      for (int i = 0; i < introPageWidgets.length; i++) {
        controller.jumpToPage(whichPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() => Stack(
        children: [
          PageView.builder(
              controller: controller,
              itemCount: introPageWidgets.length,
              itemBuilder: (context, index) {
                return introPageWidgets[index];
              },
              onPageChanged: (int page) {
                setState(() {
                  currentPageValue = page;
                });
              }),
          currentPageValue == introPageWidgets.length - 1
              ? Positioned(
                  bottom: 25,
                  right: 15,
                  child: _tikIcon(),
                )
              : Stack(
                  children: [
                    Positioned(
                      bottom: 25,
                      left: 15,
                      child: skipButton(),
                    ),
                    Positioned(
                      bottom: 25,
                      right: 15,
                      child: _nextArrowIcon(),
                    ),
                  ],
                ),
        ],
      );

  Widget _nextArrowIcon() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          changePageViewPostion(currentPageValue);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(90)),
            color: Colors.teal[500],
          ),
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 17,
          ),
        ),
      );

  Widget _tikIcon() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(90)),
            color: Colors.teal[500],
          ),
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.done,
            color: Colors.white,
            size: 17,
          ),
        ),
      );

  Widget skipButton() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(),
            ),
          );
        },
        child: Text(
          'Skip',
          style: TextStyle(
            color: Colors.teal[500],
            fontWeight: FontWeight.bold,
            fontSize: 16,
            // decoration: TextDecoration.underline,
          ),
        ),
      );
}
