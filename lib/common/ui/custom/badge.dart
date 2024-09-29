import 'package:badges/badges.dart';
import 'package:lantern/core/utils/common.dart' hide Badge;

class CBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final double fontSize;
  final bool showBadge;
  final double end;
  final double top;
  final Widget? customBadge;
  final EdgeInsetsGeometry? customPadding;

  CBadge({
    this.count = 0,
    required this.child,
    this.fontSize = 10.0,
    this.showBadge = false,
    this.end = -5,
    this.top = -3,
    this.customBadge,
    this.customPadding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showBadge) {
      return child;
    }

    return Badge(
      position: BadgePosition.topEnd(top: top, end: end),
      badgeAnimation: const BadgeAnimation.fade(),
      badgeStyle: BadgeStyle(
        badgeColor: (customBadge != null) ? Colors.white : pink4,
        elevation: 0,
        padding: (customPadding != null)
            ? customPadding!
            : (customBadge != null)
                ? const EdgeInsetsDirectional.all(0)
                : const EdgeInsetsDirectional.only(
                    start: 6,
                    end: 6,
                    top: 2,
                    bottom: 2,
                  ),
      ),
      badgeContent: (customBadge != null)
          ? customBadge
          : CText(
              count.toString(),
              style: CTextStyle(
                fontSize: fontSize,
                lineHeight: fontSize,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
      child: child,
    );
  }
}
