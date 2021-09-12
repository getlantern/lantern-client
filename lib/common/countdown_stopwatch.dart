import 'dart:core';
import 'dart:math';

import 'package:lantern/package_store.dart';

import 'now.dart';

/// A stopwatch countdown timer.
class CountdownStopwatch extends StatefulWidget {
  final int startMillis;
  final int endMillis;
  final int durationMillis;
  final Color color;
  final double size;

  CountdownStopwatch(
      {required this.startMillis,
      required this.endMillis,
      required this.color,
      this.size = 12})
      : durationMillis = endMillis - startMillis;

  @override
  _CountdownStopwatchState createState() => _CountdownStopwatchState();
}

class _CountdownStopwatchState extends NowState<int, CountdownStopwatch> {
  _CountdownStopwatchState() : super(12);

  @override
  int calculateValue(DateTime now) => max(
          0.0,
          12.0 *
              (widget.endMillis - now.millisecondsSinceEpoch) /
              widget.durationMillis)
      .round();

  @override
  Widget build(BuildContext context) {
    if (widget.durationMillis == 0) {
      // There's no duration, don't bother displaying a timer
      return const SizedBox();
    }

    return CustomAssetImage(
        path: ImagePaths.countdownPath(value),
        color: widget.color,
        size: widget.size);
  }
}
