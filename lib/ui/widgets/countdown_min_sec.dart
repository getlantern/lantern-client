import 'package:flutter/material.dart';
import 'package:lantern/config/index.dart';

class Countdown extends AnimatedWidget {
  final Animation<int> animation;
  late TextStyle textStyle;

  Countdown({required this.animation, TextStyle? textStyle})
      : super(listenable: animation) {
    this.textStyle = textStyle ?? tsCountdownTimer;
  }

  Countdown.build(
      {required AnimationController controller,
      required int durationSeconds,
      TextStyle? textStyle})
      : this(
            animation: StepTween(
              begin: durationSeconds,
              end: 0,
            ).animate(controller),
            textStyle: textStyle);

  @override
  Widget build(BuildContext context) {
    var clockTimer = Duration(seconds: animation.value);
    var timerText = clockTimer.inSeconds >= 60
        ? '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}'
        : clockTimer.inSeconds >= 10
            ? '00:${clockTimer.inSeconds}'
            : '00:0${clockTimer.inSeconds}';
    return Padding(
      padding: const EdgeInsetsDirectional.all(10.0),
      child: Text(timerText, style: textStyle),
    );
  }
}
