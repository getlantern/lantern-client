import 'package:flutter/material.dart';

class BorderPainter extends CustomPainter {
  final double controller;

  BorderPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    double _sh = size.height; // For path shortage
    double _sw = size.width; // For path shortage
    double _line = 30.0; // Length of the animated line
    double _c1 = controller * 2; // Controller value for top and left border.
    double _c2 = controller >= 0.5
        ? (controller - 0.5) * 2
        : 0; // Controller value for bottom and right border.

    Paint paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path _top = Path()
      ..moveTo(_sw * _c1 > _sw ? _sw : _sw * _c1, 0)
      ..lineTo(_sw * _c1 + _line >= _sw ? _sw : _sw * _c1 + _line, 0);

    Path _left = Path()
      ..moveTo(0, _sh * _c1 > _sh ? _sh : _sh * _c1)
      ..lineTo(0, _sh * _c1 + _line >= _sh ? _sh : _sh * _c1 + _line);

    Path _right = Path()
      ..moveTo(_sw, _sh * _c2)
      ..lineTo(
          _sw,
          _sh * _c2 + _line > _sh
              ? _sh
              : _sw * _c1 + _line >= _sw
                  ? _sw * _c1 + _line - _sw
                  : _sh * _c2);

    Path _bottom = Path()
      ..moveTo(_sw * _c2, _sh)
      ..lineTo(
          _sw * _c2 + _line > _sw
              ? _sw
              : _sh * _c1 + _line >= _sh
                  ? _sh * _c1 + _line - _sh
                  : _sw * _c2,
          _sh);

    canvas.drawPath(_top, paint);
    canvas.drawPath(_left, paint);
    canvas.drawPath(_right, paint);
    canvas.drawPath(_bottom, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}
