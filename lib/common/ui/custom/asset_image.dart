import 'package:lantern/core/utils/common.dart';

class CAssetImage extends StatelessWidget {
  final String path;
  final double size;
  final double? width;
  final double? height;
  final Color? color;

  const CAssetImage({
    required this.path,
    this.size = iconSize,
    this.width,
    this.height,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: height ?? size,
      width: width ?? size,
      color: color,
    );
  }
}
