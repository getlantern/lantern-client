import 'package:badges/badges.dart';
import 'package:lantern/common/common.dart';

class CBadge extends StatelessWidget {
  final int count;
  final Widget? child;
  final double fontSize;
  final bool showBadge;
  final double? end;
  final double? top;
  final Widget? customBadge;

  CBadge(
      {this.count = 0,
      this.child,
      this.fontSize = 10.0,
      this.showBadge = false,
      this.end = -5,
      this.top = -3,
      this.customBadge,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      padding: (customBadge != null)
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      position: BadgePosition(
        end: end,
        top: top,
      ),
      showBadge: showBadge,
      animationType: BadgeAnimationType.fade,
      elevation: 0,
      // no drop-shadow
      badgeColor: (customBadge != null) ? Colors.white : pink4,
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
