import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_arrow_path/flutter_arrow_path.dart';
import 'package:lantern/vpn/vpn.dart';

class ArrowPainter extends CustomPainter {
  // more examples https://pub.dev/packages/flutter_arrow_path/example
  @override
  void paint(Canvas canvas, Size size) {
    Path path;

    // The arrows usually looks better with rounded caps.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4.0;

    /// Draw a single arrow.
    path = Path();
    path.moveTo(size.width * 0.3, 20);
    path.relativeCubicTo(0, size.height, size.width * 0.3, size.height * 0.3,
        size.width * 0.6, size.height * 0.7);
    path = ArrowPath.make(path: path);
    canvas.drawPath(path, paint..color = blue4);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => true;
}
