import 'package:flutter/material.dart';
import 'package:qfinr/widgets/helpers/platform_check.dart';

class LargeControlledSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color trackColor;
  final Color tractActiveColor;
  final Color knobColor;
  LargeControlledSwitch({
    Key key,
    this.value,
    this.knobColor=Colors.white,
    this.trackColor=Colors.grey,
    this.tractActiveColor=Colors.green,
    this.onChanged})
      : super(key: key);

  @override
  _LargeCustomSwitchState createState() => _LargeCustomSwitchState();
}

class _LargeCustomSwitchState extends State<LargeControlledSwitch>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _circleAnimation = AlignmentTween(
        begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        end: widget.value ? Alignment.centerLeft :Alignment.centerRight).animate(CurvedAnimation(
      parent: _animationController, curve: Curves.linear,));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: Container(
            width: PlatformCheck.isSmallScreen(context) ? 48 : 38,
            height: PlatformCheck.isSmallScreen(context) ? 28 : 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _circleAnimation.value ==
                  Alignment.centerLeft
                  ? widget.trackColor
                  : widget.tractActiveColor,),
            child: Container(
              alignment: widget.value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Container(
                  width: PlatformCheck.isSmallScreen(context) ? 24 : 14,
                  height: PlatformCheck.isSmallScreen(context) ? 24 : 14,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.knobColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
