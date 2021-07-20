import 'dart:ui';

import 'package:flutter/rendering.dart';

class Waveform extends CustomPainter {
  final List<int> waveData;
  final double height;
  final double width;
  final double startingHeight;
  final double finishedHeight;
  final Color color;
  final Paint wavePaint;
  final int density;
  final int gap;

  Waveform(
      {required this.waveData,
      required this.height,
      required this.width,
      required this.color,
      this.startingHeight = 2.0,
      this.finishedHeight = 2.0,
      this.density = 100,
      this.gap = 2})
      : wavePaint = Paint()
          ..color = color.withOpacity(1.0)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 20
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    var barWidth = width / density;
    var div = waveData.length / density;
    wavePaint.strokeWidth = barWidth - gap;
    for (var i = 0; i < density; i++) {
      var bytePosition = (i * div).ceil();
      var top = (height / 2 - (((waveData[bytePosition]) - 64).abs()));
      var barX = (i * barWidth) + (barWidth / 2);
      if (top > height) {
        top = top - height;
      }
      canvas.drawLine(Offset(barX, height / startingHeight),
          Offset(barX, top / finishedHeight), wavePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
