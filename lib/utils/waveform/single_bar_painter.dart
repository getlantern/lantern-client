import 'package:flutter/material.dart';

class SingleBarPainter extends CustomPainter {
  static Color barColor = Colors.transparent;
  final Color backgroundColor;
  final double singleBarWidth;
  final double barBorderRadius;
  final Paint trackPaint;
  final Paint aboveAndBelowPaint;
  final double maxSeekBarHeight;
  final double actualSeekBarHeight;
  final double startingPosition;
  final double heightOfContainer;

  SingleBarPainter({
    required this.backgroundColor,
    this.barBorderRadius = 0,
    required this.singleBarWidth,
    required this.maxSeekBarHeight,
    required this.actualSeekBarHeight,
    required this.heightOfContainer,
    required this.startingPosition,
  })  : trackPaint = Paint()
          ..color = barColor
          ..style = PaintingStyle.fill,
        aboveAndBelowPaint = Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerSideHeight = maxSeekBarHeight - actualSeekBarHeight;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startingPosition, -heightOfContainer / 1.9,
            singleBarWidth, outerSideHeight / 2),
        const Radius.circular(0),
      ),
      aboveAndBelowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            startingPosition,
            outerSideHeight / 2 - heightOfContainer / 2,
            singleBarWidth,
            actualSeekBarHeight),
        Radius.circular(barBorderRadius),
      ),
      trackPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            startingPosition,
            (outerSideHeight / 2) - heightOfContainer / 2 + actualSeekBarHeight,
            singleBarWidth,
            outerSideHeight / 2),
        const Radius.circular(0),
      ),
      aboveAndBelowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startingPosition, -heightOfContainer / 2,
            0.2 * singleBarWidth, heightOfContainer),
        const Radius.circular(0),
      ),
      aboveAndBelowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
