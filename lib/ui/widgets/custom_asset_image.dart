import 'package:lantern/package_store.dart';

class CustomAssetImage extends StatelessWidget {
  final String path;
  final double? size;
  final Color? color;
  const CustomAssetImage({required this.path, this.size = null, this.color = null, Key? key}) : super(key: key);

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
