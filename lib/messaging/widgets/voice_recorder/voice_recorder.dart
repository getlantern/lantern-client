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
  }) : super(key: key);

  final bool isRecording;
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
    return GestureDetector(
      key: const ValueKey('btnRecord'),
      onPanDown: _onTapDown,
      onPanEnd: _onTapEnd,
      child: Transform.scale(
        scale: widget.isRecording ? 2 : 1,
        alignment: Alignment.bottomRight,
        child: Container(
          width: 50,
          height: 50,
          margin: widget.isRecording ? const EdgeInsets.only(top: 10) : null,
          decoration: BoxDecoration(
            color: widget.isRecording ? Colors.red : Colors.transparent,
            borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(100)),
          ),
          child: widget.isRecording
              ? const Padding(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.mic,
                  color: Colors.black,
                ),
        ),
      ),
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
