import 'package:lantern/package_store.dart';
import 'package:lantern/config/colors.dart';

class CustomHorizontalDivider extends StatelessWidget {
  final Color? color;
  final double thickness;
  final double margin;
  final double size;

  const CustomHorizontalDivider({
    Key? key,
    this.margin = 16,
    this.thickness = 0.0,
    this.size = 16.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Divider(
      color: color ?? grey3,
      thickness: thickness,
      indent: margin,
      endIndent: margin,
      height: size);
}
