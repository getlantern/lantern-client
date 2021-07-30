import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RectangleSliderThumbShapes extends SliderComponentShape {
  const RectangleSliderThumbShapes({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.height = 50,
  });

  final double enabledThumbRadius;
  final double height;

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
      ..color = HexColor('#FFC107')
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        Rect.fromCenter(center: center, width: 1, height: height), paintBorder);
  }
}
