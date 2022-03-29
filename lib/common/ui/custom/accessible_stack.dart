import 'package:lantern/common/common.dart';

/// Creates an enlarged tap area behind the tap target to comply with accessibility recs
class CAccessibleStack extends StatelessWidget {
  CAccessibleStack({
    required this.onTap,
    required this.foreground,
    Key? key,
  }) : super(key: key);

  final Function onTap;
  final Widget foreground;

  @override
  Widget build(BuildContext context) {
    final background = GestureDetector(
      onTap: onTap(),
      child: Container(color: transparent, width: 48, height: 48),
    );
    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.passthrough,
      children: [
        background,
        foreground,
      ],
    );
  }
}
