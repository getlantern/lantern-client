import 'package:flutter/material.dart';
import 'package:lantern/package_store.dart';

class RectangleSliderThumbShapes extends SliderComponentShape {
  const RectangleSliderThumbShapes({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.height = 50,
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
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;

    final paintBorder = Paint()
      ..color = primaryYellow
      ..strokeWidth = isPlaying ? 2 : 0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        Rect.fromCenter(
            center: center,
            width: isPlaying ? 2 : 0,
            height: isPlaying ? height : 0),
        paintBorder);
  }
}
