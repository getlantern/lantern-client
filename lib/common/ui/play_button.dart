import '../common.dart';

class PlayButton extends StatelessWidget {
  final double size;
  late final Color color;
  final bool playing;
  final void Function()? onPressed;
  final Color? backgroundColor;

  PlayButton({
    this.size = 24,
    Color? color,
    this.playing = false,
    this.onPressed,
    this.backgroundColor,
  }) {
    this.color = color ?? white;
  }

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      diameter: size,
      padding: 0,
      backgroundColor: backgroundColor ?? transparent,
      icon: CAssetImage(
        path: playing
            ? ImagePaths.pause_circle_filled
            : ImagePaths.play_circle_filled,
        color: color,
        size: size,
      ),
      onPressed: () {
        if (onPressed != null) onPressed!();
      },
    );
  }
}
