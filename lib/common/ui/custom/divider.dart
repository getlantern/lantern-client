import 'package:lantern/core/utils/common.dart';

class CDivider extends StatelessWidget {
  final Color? color;
  final double thickness;
  final double margin;
  final double height;

  const CDivider({
    Key? key,
    this.thickness = 1,
    this.height = 1,
    this.margin = 0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Divider(
        color: color ?? grey3,
        thickness: thickness,
        indent: margin,
        endIndent: margin,
        height: height,
      );
}
