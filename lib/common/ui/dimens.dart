import '../common.dart';

const double borderRadius = 8;
const double activeIconSize = 8;
const double iconSize = 24;
const double badgeSize = 36;
const double messageBarHeight = 57;
const double scrollBarRadius = 50;

bool isLTR(BuildContext context) =>
    Directionality.of(context) == TextDirection.ltr;

Widget mirrorBy180deg({required BuildContext context, required Widget child}) =>
    Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(isLTR(context) ? 0 : pi),
        child: child);

double calculateStickerHeight(BuildContext context, int messageCount) {
  final conversationInnerHeight = MediaQuery.of(context).size.height -
      100.0 -
      100.0; // rough approximation for inner height - top bar height - message bar height
  final messageHeight =
      60.0; // rough approximation of how much space a message takes up, including paddings
  final minStickerHeight = 350.0;
  return conversationInnerHeight - ((messageCount - 1) * messageHeight) >
          minStickerHeight
      ? conversationInnerHeight - ((messageCount - 1) * messageHeight)
      : minStickerHeight;
}
