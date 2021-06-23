import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class CountdownTimer extends StatelessWidget {
  final StopWatchTimer stopWatchTimer;
  const CountdownTimer({required this.stopWatchTimer, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stopWatchTimer.rawTime,
      initialData: stopWatchTimer.rawTime.value,
      builder: (context, snap) {
        final value = snap.data;
        final displayTime = StopWatchTimer.getDisplayTime(value ?? 0,
            minute: true, second: true, hours: false, milliSecond: false);
        return Text(displayTime,
            style: const TextStyle(fontWeight: FontWeight.bold));
      },
    );
  }
}
