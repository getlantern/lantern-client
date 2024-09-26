import 'package:lantern/core/utils/common.dart';

class PulseAnimation extends StatefulWidget {
  final Widget child;

  PulseAnimation(this.child) : super();

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
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
      lowerBound: 0,
      upperBound: 1,
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
      color: transparent,
      child: Opacity(
        opacity: _animation.value,
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
