import 'package:flutter/material.dart';

class InheritedPosition extends InheritedWidget {
  InheritedPosition({
    required Widget child,
    required this.position,
  }) : super(child: child);

  final int position;

  @override
  bool updateShouldNotify(covariant InheritedPosition oldWidget) {
    return position != oldWidget.position;
  }
}
