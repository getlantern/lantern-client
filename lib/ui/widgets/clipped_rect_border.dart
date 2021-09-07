import 'package:flutter/material.dart';

class ClippedRectBorderPainter extends CustomPainter {
  final double rectSize;

  ClippedRectBorderPainter({required this.rectSize}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final radius = const Radius.circular(8);
    final segmentLength = 30.0;

    // construction of continuous rounded border from which we will subtract
    final contRect = Rect.fromLTRB(0, 0, rectSize, rectSize);
    final contRRect = RRect.fromRectAndRadius(contRect, radius);
    final finalContPath = Path()..addRRect(contRRect);

    // single side paths to be clipped
    final topClip =
        Rect.fromLTRB(segmentLength, 0, rectSize - segmentLength, 0);
    final rightClip = Rect.fromLTRB(
        rectSize, segmentLength, rectSize, rectSize - segmentLength);
    final bottomClip = Rect.fromLTRB(
        segmentLength, rectSize, rectSize - segmentLength, rectSize);
    final leftClip =
        Rect.fromLTRB(0, segmentLength, 0, rectSize - segmentLength);

    // sum of all paths we need to subtract from the continuous border
    final clippings = Path()
      ..addRect(topClip)
      ..addRect(rightClip)
      ..addRect(bottomClip)
      ..addRect(leftClip)
      ..close();

    final finalBorder =
        Path.combine(PathOperation.difference, finalContPath, clippings);
    canvas.drawPath(finalBorder, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
