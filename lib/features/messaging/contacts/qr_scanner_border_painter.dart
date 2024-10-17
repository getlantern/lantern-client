import 'package:lantern/features/messaging/messaging.dart';

class QRScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var h = size.height;
    var w = size.width;
    var r = 8.0;
    var cw = size.height * 0.1;

    var greenPaint = Paint()
      ..color = indicatorGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var greyPaint = Paint()
      ..color = grey5
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // draw a indicatorGreen rectangle with rounded corners
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, w, h, Radius.circular(r)),
      greenPaint,
    );

    // break the lines of the rectangle on the left, right, top and bottom sides
    canvas.drawLine(Offset(0, cw), Offset(0, h - cw), greyPaint);
    canvas.drawLine(Offset(w, cw), Offset(w, h - cw), greyPaint);
    canvas.drawLine(Offset(cw, 0), Offset(w - cw, 0), greyPaint);
    canvas.drawLine(Offset(cw, h), Offset(w - cw, h), greyPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
