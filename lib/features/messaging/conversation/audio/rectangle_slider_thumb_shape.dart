import 'package:lantern/features/messaging/messaging.dart';

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class RectangleSliderThumbShapes extends SliderComponentShape {
  const RectangleSliderThumbShapes({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    required this.height,
    this.isPlaying = false,
  });

  final double enabledThumbRadius;
  final double height;
  final bool isPlaying;

  final double? disabledThumbRadius;

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
      isEnabled == true ? enabledThumbRadius : _disabledThumbRadius,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final paintBorder = Paint()
      ..color = yellow4
      ..strokeWidth = isPlaying ? 2 : 0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: isPlaying ? 2 : 0,
        height: isPlaying ? height : 0,
      ),
      paintBorder,
    );
  }
}
