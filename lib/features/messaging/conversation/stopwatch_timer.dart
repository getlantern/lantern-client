import 'package:lantern/features/messaging/messaging.dart';

class StopwatchTimer extends StatelessWidget {
  final StopWatchTimer stopWatchTimer;
  final CTextStyle style;

  const StopwatchTimer({
    required this.stopWatchTimer,
    required this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stopWatchTimer.rawTime,
      initialData: stopWatchTimer.rawTime.value,
      builder: (context, snap) {
        final value = snap.data;
        final displayTime = StopWatchTimer.getDisplayTime(
          value ?? 0,
          minute: true,
          second: true,
          hours: false,
          milliSecond: false,
        );
        return CText(
          displayTime,
          style: style,
        );
      },
    );
  }
}
