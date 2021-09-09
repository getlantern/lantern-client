import 'package:flutter/material.dart';
import 'package:lantern/config/colors.dart';

class QRScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var h = size.height;
    var w = size.width;
    var r = 14.0;
    var cw = size.height * 0.2;

    var greenPaint = Paint()
      ..color = green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var greyPaint = Paint()
      ..color = grey5
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // draw a green rectangle with rounded corners
    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, w, h, Radius.circular(r)), greenPaint);

    // break the lines of the rectangle on the left, right, top and bottom sides
    canvas.drawLine(Offset(0, cw), Offset(0, h - cw), greyPaint);
    canvas.drawLine(Offset(w, cw), Offset(w, h - cw), greyPaint);
    canvas.drawLine(Offset(cw, 0), Offset(w - cw, 0), greyPaint);
    canvas.drawLine(Offset(cw, h), Offset(w - cw, h), greyPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
