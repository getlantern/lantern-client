import 'package:flutter/material.dart';

class BackgroundBarPainter extends CustomPainter {
  final double containerWidth;
  final double containerHeight;
  final double progresPercentage;
  final Color initialColor;
  final Color? progressColor;
  final Paint trackPaint;
  final Paint progressPaint;

  BackgroundBarPainter({
    required this.containerWidth,
    required this.containerHeight,
    required this.initialColor,
    required this.progressColor,
    required this.progresPercentage,
  })  : trackPaint = Paint()
          ..color = initialColor
          ..style = PaintingStyle.fill,
        progressPaint = Paint()
          ..color = progressColor ?? Colors.red
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              0, -containerHeight / 2, containerWidth, containerHeight),
          const Radius.circular(0),
        ),
        trackPaint);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, -containerHeight / 2,
              (progresPercentage * containerWidth) / 100, containerHeight),
          const Radius.circular(0),
        ),
        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
