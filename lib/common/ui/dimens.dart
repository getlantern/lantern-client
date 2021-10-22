import '../common.dart';

const double borderRadius = 8;
const double activeIconSize = 8;
const double iconSize = 24;
const double badgeSize = 36;
const double messageBarHeight = 57;
const double scrollBarRadius = 50;

bool isLTR(BuildContext context) =>
    !forceRTL && Directionality.of(context) == TextDirection.ltr;

Widget mirrorLTR({required BuildContext context, required Widget child}) =>
    Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(isLTR(context) ? 0 : pi),
        child: child);
