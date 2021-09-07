import 'package:lantern/package_store.dart';
import 'package:lantern/config/colors.dart';

class CustomSeparator extends StatelessWidget {
  final bool vertical;
  final Color? color;
  final double thickness;
  final double margin;
  final double size;

  const CustomSeparator(
      {Key? key,
      this.margin = 16,
      this.thickness = 0.0,
      this.size = 16.0,
      this.color,
      this.vertical = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) => (vertical)
      ? VerticalDivider(
          color: color ?? grey3,
          thickness: thickness,
          indent: margin,
          endIndent: margin,
          width: size,
        )
      : Divider(
          color: color ?? grey3,
          thickness: thickness,
          indent: margin,
          endIndent: margin,
          height: size);
}
