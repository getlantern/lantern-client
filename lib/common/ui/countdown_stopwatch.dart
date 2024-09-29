import 'package:lantern/core/utils/common.dart';

/// A stopwatch countdown timer.
class CountdownStopwatch extends StatelessWidget {
  final int startMillis;
  final int endMillis;
  final int durationMillis;
  final Color color;
  final double size;

  CountdownStopwatch({
    required this.startMillis,
    required this.endMillis,
    required this.color,
    this.size = 14,
  }) : durationMillis = endMillis - startMillis;

  @override
  Widget build(BuildContext context) {
    if (durationMillis == 0) {
      // There's no duration, don't bother displaying a timer
      return const SizedBox();
    }

    return NowBuilder<int>(
      calculate: (now) => max(
        0.0,
        12.0 * (endMillis - now.millisecondsSinceEpoch) / durationMillis,
      ).round(),
      builder: (context, value) => CAssetImage(
        path: ImagePaths.countdownPath(value),
        color: color,
        size: size,
      ),
    );
  }
}
