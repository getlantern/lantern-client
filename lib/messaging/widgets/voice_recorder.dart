import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/custom_pan_gesture_recognizer.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class VoiceRecorder extends StatelessWidget {
  const VoiceRecorder({
    Key? key,
    required this.stopWatchTimer,
    required this.willCancelRecording,
    required this.onSwipeLeft,
    required this.onTapUpListener,
  }) : super(key: key);

  final StopWatchTimer stopWatchTimer;
  final bool willCancelRecording;
  final VoidCallback onSwipeLeft;
  final Function onTapUpListener;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Flexible(
        child: ColoredBox(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 17),
                child: Icon(Icons.circle, color: Colors.red),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 22),
                child: StreamBuilder<int>(
                  stream: stopWatchTimer.rawTime,
                  initialData: stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(
                        value ?? 0,
                        minute: true,
                        second: true,
                        hours: false,
                        milliSecond: false);
                    return Text(displayTime,
                        style: const TextStyle(fontWeight: FontWeight.bold));
                  },
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 63,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                          willCancelRecording
                              ? 'will cancel'.i18n
                              : '< ' + 'swipe to cancel'.i18n,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
              ForcedPanDetector(
                onPanDown: _onPanDown,
                onPanEnd: _onPanEnd,
                onPanUpdate: _onPanUpdate,
                onTap: () {},
                onDoubleTap: () {},
                // onTapUp: (details) => onTapUpListener(),
                child: Transform.scale(
                  scale: 2,
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(38)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                          left: 15, top: 15, right: 4, bottom: 4),
                      child: Icon(Icons.mic_none),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  void _onPanUpdate(Offset details) => _handlePan(details, false);

  void _onPanEnd(Offset details) => _handlePan(details, true);

  void _handlePan(Offset details, bool isPanEnd) {
    if (isPanEnd && details.dx <= 200.0) {
      onSwipeLeft();
    }
  }

  bool _onPanDown(Offset details) {
    _handlePan(details, false);
    return true;
  }
}
