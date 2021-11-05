import 'package:lantern/common/common.dart';

class CInkWell extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final RoundedRectangleBorder? customBorder;

  const CInkWell({
    required this.child,
    required this.onTap,
    this.customBorder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent,
      child: InkWell(
        focusColor: grey4,
        splashColor: grey4,
        highlightColor: grey4,
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        onTap: () => onTap(),
        customBorder: customBorder,
        child: child,
      ),
    );
  }
}
