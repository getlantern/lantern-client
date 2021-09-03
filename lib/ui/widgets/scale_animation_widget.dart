import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class ScaleAnimationWidget extends StatefulWidget {
  final Widget child;

  ScaleAnimationWidget(this.child) : super();

  @override
  _ScaleAnimationWidgetState createState() => _ScaleAnimationWidgetState();
}

class _ScaleAnimationWidgetState extends State<ScaleAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ),
      lowerBound: 1,
      upperBound: 1.4,
      vsync: this,
    );
    _animation = _controller
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: _animation,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.child,
          ],
        ),
      ),
    );
  }
}
