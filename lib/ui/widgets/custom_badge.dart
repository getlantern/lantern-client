import 'package:badges/badges.dart';
import 'package:lantern/package_store.dart';

class CustomBadge extends StatelessWidget {
  final int count;
  final Widget? child;
  final double fontSize;
  final bool showBadge;

  CustomBadge(
      {this.count = 0,
      this.child,
      this.fontSize = 10.0,
      this.showBadge = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      position: const BadgePosition(
        end: -5,
        top: -3,
      ),
      showBadge: showBadge,
      animationType: BadgeAnimationType.fade,
      elevation: 0, // no drop-shadow
      badgeColor: primaryPink,
      badgeContent: Text(
        count.toString(),
        style: GoogleFonts.roboto().copyWith(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: child,
    );
  }
}
