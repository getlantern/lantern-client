import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/package_store.dart';

class VoiceRecorder extends StatefulWidget {
  VoiceRecorder({
    Key? key,
    required this.isRecording,
    required this.onRecording,
    required this.onStopRecording,
    required this.onTapUpListener,
    required this.onInmediateSend,
  }) : super(key: key);

  final bool isRecording;
  final VoidCallback onInmediateSend;
  final VoidCallback onRecording;
  final VoidCallback onStopRecording;
  final Function onTapUpListener;

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (widget.isRecording) widget.onStopRecording();
        break;
      case AppLifecycleState.resumed:
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.isRecording
            ? Align(
                alignment: Alignment.bottomRight,
                child: Transform.scale(
                  scale: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                      ),
                    ),
                    child: const SizedBox(
                      height: 60,
                      width: 60,
                    ),
                  ),
                ))
            : const SizedBox(),
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onPanDown: _onTapDown,
            onPanEnd: _onTapEnd,
            child: Icon(
              Icons.mic,
              size: widget.isRecording ? 30.0 : 25,
              color: widget.isRecording ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _onTapEnd(DragEndDetails details) => widget.onStopRecording();

  void _onTapDown(DragDownDetails details) => widget.onRecording();

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
