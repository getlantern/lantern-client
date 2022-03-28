import 'package:lantern/common/common.dart';

class CInkWell extends StatelessWidget {
  final Widget child;
  final Function? onTap;
  final RoundedRectangleBorder? customBorder;
  final bool disableSplash;

  const CInkWell({
    required this.child,
    this.onTap,
    this.customBorder,
    this.disableSplash = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent,
      child: InkWell(
        focusColor: disableSplash ? transparent : grey4,
        splashColor: disableSplash ? transparent : grey4,
        highlightColor: disableSplash ? transparent : grey4,
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        onTap: () => onTap!(),
        customBorder: customBorder,
        child: child,
      ),
    );
  }
}
