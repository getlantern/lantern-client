import 'package:lantern/common/common.dart';

class CAssetImage extends StatelessWidget {
  final String path;
  final double size;
  final Color? color;

  const CAssetImage(
      {required this.path, this.size = iconSize, this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      color: color,
      fit: BoxFit.scaleDown,
    );
  }
}
