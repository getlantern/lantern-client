import 'package:lantern/package_store.dart';
import 'package:lantern/common/ui/colors.dart';

class CustomVerticalDivider extends StatelessWidget {
  final Color? color;
  final double thickness;
  final double margin;
  final double size;

  const CustomVerticalDivider({
    Key? key,
    this.margin = 16,
    this.thickness = 0.0,
    this.size = 16.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => VerticalDivider(
        color: color ?? grey3,
        thickness: thickness,
        indent: margin,
        endIndent: margin,
        width: size,
      );
}
