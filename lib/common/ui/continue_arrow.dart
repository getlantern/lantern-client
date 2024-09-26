import 'package:lantern/core/utils/common.dart';

//// An arrow that indicates that clicking on the containing control will continue to a new
//// screen. It is sensitive to the current language's directionality.
class ContinueArrow extends StatelessWidget {
  const ContinueArrow();

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(
        Directionality.of(context) == TextDirection.rtl ? pi : 0,
      ),
      child: const CAssetImage(
        path: ImagePaths.keyboard_arrow_right,
      ),
    );
  }
}
