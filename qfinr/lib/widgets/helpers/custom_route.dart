import 'package:flutter/material.dart';

class CustomSlideRoute<T> extends MaterialPageRoute<T> {
  CustomSlideRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    /* if (settings.isInitialRoute) {
      return child;
    } */
    
    return SlideTransition(
      position: new Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
      /* opacity: animation, */
      child: child,
    );
  }
}

class CustomFadeRoute<T> extends MaterialPageRoute<T> {
  CustomFadeRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    /* if (settings.isInitialRoute) {
      return child;
    } */

    //return Transition
    // log.d(animation);
    
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomScaleRoute<T> extends MaterialPageRoute<T> {
  CustomScaleRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    /* if (settings.isInitialRoute) {
      return child;
    } */

    //return Transition
    // log.d(animation);
    

    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
