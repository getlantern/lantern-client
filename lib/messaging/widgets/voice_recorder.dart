import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/package_store.dart';

class VoiceRecorder extends StatelessWidget {
  const VoiceRecorder({
    Key? key,
    required this.isRecording,
    required this.onRecording,
    required this.onStopRecording,
    required this.onTapUpListener,
  }) : super(key: key);

  final bool isRecording;
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
          onPanEnd: _onTapUp,
          child: Icon(
            Icons.mic,
            size: isRecording ? 30.0 : 25,
            color: isRecording ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _onTapUp(DragEndDetails details) => onStopRecording();
  //_handlePan(details.localPosition, true);

  void _onTapDown(DragDownDetails details) => onRecording();
}
