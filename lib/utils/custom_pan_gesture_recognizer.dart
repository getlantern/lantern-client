import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ForcedPanDetector extends StatelessWidget {
  const ForcedPanDetector({
    required this.child,
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onDoubleTap,
    required this.onTap,
  });

  final bool Function(Offset) onPanDown;
  final Function(Offset) onPanUpdate;
  final Function(Offset) onPanEnd;
  final Function onDoubleTap;
  final Function onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
          () => CustomPanGestureRecognizer(),
          (CustomPanGestureRecognizer instance) {
            instance._detector = this;
          },
        ),
      },
      child: child,
    );
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  CustomPanGestureRecognizer();

  ForcedPanDetector? _detector;
  Duration? _tapTimestamp;

  bool _isTap(Duration timestamp) =>
      _detector?.onTap != null &&
      _tapTimestamp != null &&
      timestamp - _tapTimestamp! < kDoubleTapTimeout * 0.5;

  bool _isDoubleTap(Duration timestamp) =>
      _detector?.onDoubleTap != null &&
      _tapTimestamp != null &&
      timestamp - _tapTimestamp! < kDoubleTapTimeout;

  @override
  void addPointer(PointerDownEvent event) {
    if (_detector!.onPanDown(event.position)) {
      if (_isDoubleTap(event.timeStamp)) {
        _detector!.onDoubleTap();
        _tapTimestamp = null;
        stopTrackingPointer(event.pointer);
      } else {
        _tapTimestamp = event.timeStamp;
        startTrackingPointer(event.pointer);
        resolve(GestureDisposition.accepted);
      }
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _detector!.onPanUpdate(event.position);
    } else if (event is PointerUpEvent) {
      if (_detector?.onPanEnd != null) {
        _detector!.onPanEnd(event.position);
      }
      if (_isTap(event.timeStamp)) {
        _detector!.onTap();
      }
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'CustomPanRecognizer';
}
