import 'package:lantern/core/utils/common.dart';

class Countdown extends AnimatedWidget {
  final Animation<int> animation;
  late final CTextStyle textStyle;

  Countdown({required this.animation, CTextStyle? textStyle})
      : super(listenable: animation) {
    this.textStyle = textStyle ?? tsDisplayBlack;
  }

  Countdown.build({
    required AnimationController controller,
    required int durationSeconds,
    CTextStyle? textStyle,
  }) : this(
          animation: StepTween(
            begin: durationSeconds,
            end: 0,
          ).animate(controller),
          textStyle: textStyle,
        );

  @override
  Widget build(BuildContext context) {
    var clockTimer = Duration(seconds: animation.value);
    var timerText = clockTimer.inSeconds >= 60
        ? '0${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}'
        : clockTimer.inSeconds >= 10
            ? '00:${clockTimer.inSeconds}'
            : '00:0${clockTimer.inSeconds}';
    return CText(timerText, style: textStyle);
  }
}
