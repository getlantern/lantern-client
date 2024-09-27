import 'package:lantern/features/messaging/messaging.dart';

class PulsatingIndicator extends StatefulWidget {
  final Duration duration;
  final double size;
  late final Color color;
  late final Color pulseColor;

  PulsatingIndicator({
    Key? key,
    this.duration = const Duration(milliseconds: 700),
    this.size = 16,
    Color? color,
    Color? pulseColor,
  }) : super(key: key) {
    this.color = color ?? indicatorRed;
    this.pulseColor = color ?? indicatorRed;
  }

  @override
  _PulsatingIndicatorState createState() => _PulsatingIndicatorState();
}

class _PulsatingIndicatorState extends State<PulsatingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animationController.repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: widget.size * .25)
        .animate(_animationController)
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
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.size / 2),
        boxShadow: [
          BoxShadow(
            color: widget.pulseColor.withOpacity(0.3),
            spreadRadius: _animation.value,
            blurRadius: _animation.value,
          ),
        ],
      ),
      child: SizedBox(
        width: widget.size * .75,
        height: widget.size * .75,
      ),
    );
  }
}
