import '../../core/utils/common.dart';

class PlayButton extends StatelessWidget {
  final double size;
  final Color? color;
  final bool custom;
  final bool playing;

  final void Function()? onPressed;

  PlayButton({
    this.size = 24,
    this.color,
    this.custom = false,
    this.playing = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      diameter: size,
      padding: 0,
      backgroundColor: transparent,
      icon: CAssetImage(
        size: size,
        color: color,
        path: playing
            ? custom
                ? ImagePaths.pause_circle_outline_custom
                : ImagePaths.pause_circle_filled
            : custom
                ? ImagePaths.play_circle_filled_custom
                : ImagePaths.play_circle_filled,
      ),
      onPressed: () {
        if (onPressed != null) onPressed!();
      },
    );
  }
}
