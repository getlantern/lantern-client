import 'package:lantern/common/common.dart';

class CustomAssetImage extends StatelessWidget {
  final String path;
  final double? size;
  final Color? color;

  const CustomAssetImage({required this.path, this.size, this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
