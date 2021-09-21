import 'package:lantern/common/common.dart';

class CAssetImage extends StatelessWidget {
  final String path;
  final double? size;
  final Color? color;

  const CAssetImage({required this.path, this.size, this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: size ?? iconSize,
      width: size ?? iconSize,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
