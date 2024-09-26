import 'package:lantern/core/utils/common.dart';

extension PathBuilding on BorderRadius {
  /// Creates a path that fills the given size and rounds corners to match this
  /// BorderRadius.
  Path toPath(Size size) {
    return Path()
      ..moveTo(topLeft.x / 2, 0)
      ..lineTo(size.width - topRight.x / 2, 0)
      ..arcToPoint(Offset(size.width, topRight.y / 2), radius: topRight)
      ..lineTo(size.width, size.height - bottomRight.y / 2)
      ..arcToPoint(Offset(size.width - bottomRight.x / 2, size.height),
          radius: bottomRight,)
      ..lineTo(bottomLeft.x / 2, size.height)
      ..arcToPoint(Offset(0, size.height - bottomLeft.y / 2),
          radius: bottomLeft,)
      ..lineTo(0, topLeft.y / 2)
      ..arcToPoint(Offset(topLeft.x / 2, 0), radius: topLeft);
  }

  CustomClipper<Path> toClipper() {
    return BorderRadiusClipper(this);
  }
}

class BorderRadiusClipper extends CustomClipper<Path> {
  final BorderRadius radius;

  BorderRadiusClipper(this.radius);

  @override
  Path getClip(Size size) {
    return radius.toPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
