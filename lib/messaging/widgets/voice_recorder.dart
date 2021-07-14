import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/package_store.dart';

// ignore: must_be_immutable
class VoiceRecorder extends StatelessWidget {
  VoiceRecorder({
    Key? key,
    required this.isRecording,
    required this.onRecording,
    required this.onStopRecording,
    required this.onTapUpListener,
    required this.onInmediateSend,
  }) : super(key: key);

  double? _verticalPosition = 0.0;
  double? _horizontalPosition = 0.0;

  final bool isRecording;
  final VoidCallback onInmediateSend;
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
          onPanDown: _onTapDown,
          onPanEnd: _onTapEnd,
          onPanUpdate: _onTapUp,
          child: Icon(
            Icons.mic,
            size: isRecording ? 30.0 : 25,
            color: isRecording ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _onTapUp(DragUpdateDetails details) {
    _verticalPosition = (details.delta.dy).clamp(.0, 1.0);
    _horizontalPosition = (details.delta.dx).clamp(.0, 1.0);
  }

  void _onTapEnd(DragEndDetails details) =>
      (_verticalPosition! >= 1.0) ? onInmediateSend() : onStopRecording();
  //_handlePan(details.localPosition, true);

  void _onTapDown(DragDownDetails details) => onRecording();
}
