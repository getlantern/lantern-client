import 'package:flutter/material.dart';

class PulsatingContainer extends StatefulWidget {
  final Duration duration;
  final Widget? child;
  final EdgeInsets? padding;
  final double width;
  final double height;
  final Color? color;
  final Color? pulseColor;

  const PulsatingContainer({
    Key? key,
    required this.duration,
    this.child,
    this.padding,
    required this.width,
    required this.height,
    this.color,
    required this.pulseColor,
  }) : super(key: key);

  @override
  _PulsatingContainerState createState() => _PulsatingContainerState();
}

class _PulsatingContainerState extends State<PulsatingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animationController.repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 5).animate(_animationController)
      ..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.color ?? Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: widget.pulseColor?.withOpacity(0.3) ??
                Colors.black.withOpacity(0.3),
            spreadRadius: _animation.value,
            blurRadius: _animation.value,
          ),
        ],
      ),
      child: widget.child ?? const SizedBox(),
    );
  }
}
