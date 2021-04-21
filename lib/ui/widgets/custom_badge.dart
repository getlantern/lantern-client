import 'package:badges/badges.dart';
import 'package:lantern/package_store.dart';

class CustomBadge extends StatefulWidget {
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
  _CustomBadgeState createState() => _CustomBadgeState();
}

class _CustomBadgeState extends State<CustomBadge> {
  @override
  Widget build(BuildContext context) {
    return Badge(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      position: BadgePosition(
        end: -5,
        top: -3,
      ),
      showBadge: widget.showBadge,
      animationType: BadgeAnimationType.fade,
      badgeColor: HexColor(primaryPink),
      badgeContent: Text(
        widget.count.toString(),
        style: GoogleFonts.roboto().copyWith(
          fontSize: widget.fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: widget.child,
    );
  }
}
