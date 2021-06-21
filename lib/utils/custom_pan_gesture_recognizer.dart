import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Handle a native gesture detection without the need to have more than one listener
class ForcedPanDetector extends StatelessWidget {
  const ForcedPanDetector({
    required this.child,
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onDoubleTap,
    required this.onTap,
  });

  ///when the widget is been pressed
  final bool Function(Offset) onPanDown;

  ///update the position of the tap each frame
  final Function(Offset) onPanUpdate;

  ///when the user lift the finger from the screen, [onPanEnd] is called
  final Function(Offset) onPanEnd;

  ///called when the user tap more than once.
  final Function onDoubleTap;

  ///called after onPanEnd, same functionality as a noromal [onTap]
  final Function onTap;

  ///widget wrapped inside the native gesture detector
  final Widget child;

  @override
  Widget build(BuildContext context) => RawGestureDetector(
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

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  CustomPanGestureRecognizer();

  ForcedPanDetector? _detector;
  Duration? _tapTimestamp;

  /// Check if the user has tapped on a widget, using time differences.
  bool _isTap(Duration timestamp) =>
      _detector?.onTap != null &&
      _tapTimestamp != null &&
      timestamp - _tapTimestamp! < kDoubleTapTimeout * 0.5;

  /// Same as `_isTap` but this check if the user has tapped more than once on a widget.
  bool _isDoubleTap(Duration timestamp) =>
      _detector?.onDoubleTap != null &&
      _tapTimestamp != null &&
      timestamp - _tapTimestamp! < kDoubleTapTimeout;

  /// Set the position of where the user is pressing.
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

  ///Any interaction that the user do `handleEvent` is called, however to detect
  ///if the user do something unrelated to movement, ex: tap or double tap.
  ///is required to use `_isTap` or `_isDoubleTap`.
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
