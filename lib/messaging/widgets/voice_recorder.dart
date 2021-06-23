import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/package_store.dart';

class VoiceRecorder extends StatelessWidget {
  const VoiceRecorder({
    Key? key,
    required this.willCancelRecording,
    required this.onSwipeLeft,
    required this.isRecording,
    required this.onRecording,
    required this.onStopRecording,
    required this.onTapUpListener,
  }) : super(key: key);

  final bool willCancelRecording;
  final bool isRecording;
  final VoidCallback onSwipeLeft;
  final VoidCallback onRecording;
  final VoidCallback onStopRecording;
  final Function onTapUpListener;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        isRecording
            ? Transform.scale(
                scale: 2,
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(38)),
                  ),
                  child: const SizedBox(
                    height: 50,
                    width: 40,
                  ),
                ),
              )
            : const SizedBox(),
        GestureDetector(
          onLongPressMoveUpdate: _onPanUpdate,
          onLongPressEnd: _onPressEnd,
          onLongPressStart: _onLongPressStart,
          child: Icon(
            Icons.mic,
            size: isRecording ? 30.0 : 25,
            color: isRecording ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _onPanUpdate(LongPressMoveUpdateDetails details) =>
      _handlePan(details.localPosition, false);

  /// If the user drag a finger on the widget `_handlePan` is called.
  /// to check if a swipe is gonna be used, we just need to check if the `dx` is lower than 200.0
  /// if true then we proceeds to call [onSwipeLeft] if not then [onStopRecording] is called
  void _handlePan(Offset details, bool isPanEnd) {
    if (isPanEnd && details.dx < -150.0) {
      print('is ended and dx is lower than -150');
      onSwipeLeft();
    }
    if (isPanEnd && details.dx > -150.0) {
      print('is ended and dx is higher than -150');
      onStopRecording();
    }
  }

  void _onPressEnd(LongPressEndDetails details) =>
      _handlePan(details.localPosition, true);

  void _onLongPressStart(LongPressStartDetails details) => onRecording();
}
