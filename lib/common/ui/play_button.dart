import '../common.dart';

class PlayButton extends StatelessWidget {
  final double size;
  final void Function()? onPressed;
  final String path;

  PlayButton({
    this.size = 24,
    this.onPressed,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      diameter: size,
      padding: 0,
      backgroundColor: transparent,
      icon: CAssetImage(
        path: path,
        size: size,
      ),
      onPressed: () {
        if (onPressed != null) onPressed!();
      },
    );
  }
}
